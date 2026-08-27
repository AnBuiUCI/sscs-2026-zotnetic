#!/usr/bin/env python3
"""Density fill for the top GDS.

The sign-off DRC does not check density unless the rules are asked for
separately (`--density`), and when asked the top breaks all of them: they are
MINIMUMS, i.e. metal is missing. This step adds it **after** OpenROAD has
produced the GDS, without touching anything upstream.

Three PDK facts define how this works:

* **The deck adds the dummy in.** `comp = comp_drawn + comp_dummy`, and the same
  per layer. Dummy lives on **datatype 4** of the same layer number.
* **DRC and LVS DO see the dummy.** `layers_def.drc` does
  `metal1 = metal1_drawn + metal1_dummy`, and `layers_definitions.lvs` likewise.
  What is defined as `get_polygons(34, 0)` is the *drawn* layer, not the physical
  one. So the fill **must pass the whole DRC** and shows up in extraction as
  floating metal. Hence only WHOLE squares are placed inside the clear zone:
  clipping them against the free area creates necks and slivers, and that is
  where 6214 width, area and spacing violations came from.
* **The PDK ships no fill generator.** Neither in `libs.tech/klayout` nor in
  `librelane`. Hence this file.

`MT.3` does not measure the `metaltop` layer: for the 5-metal stack the deck
does `top_metal = metal5`, so `MT.3` and `M5.4` look at the same thing.

    python3 scripts/fill_density.py             # canales; mide y reporta
    python3 scripts/fill_density.py --sobre-macros   # also on top of the macros
"""

from __future__ import annotations

import re
import os
import sys
from pathlib import Path

import klayout.db as kdb

ROOT = Path(__file__).resolve().parent.parent
#: Output directory of the top. Defaults to `out`, which is v1's.
#: `TOP_OUT` changes it so the v2 top can be checked without stepping on v1:
#: both have to coexist to be compared.
OUT = ROOT / os.environ.get("TOP_OUT", "out")

#: Which top cell gets checked. `GRADIENT_NAV` builds four GRADIENT blocks
#: (the 98 dB OPAM); `GRADIENT_NAV2` is the same schematic with GRADIENT2,
#: that is with OPAM_LIN_flat. The Makefile sets it with `T=`, like `TOP_OUT`.
TOP = os.environ.get("TOP_CELL", "GRADIENT_NAV")

#: Where we start from: if `decap_fill.py` already dropped the decoupling
#: capacitors into the gaps, we fill ON TOP of that file. Otherwise on the one
#: the flow produces. The submission file is always `_filled`.
GDS_DECAP = OUT / f"{TOP}_decap.gds"
GDS_IN = GDS_DECAP if GDS_DECAP.exists() else OUT / f"{TOP}.gds"
GDS_OUT = OUT / f"{TOP}_filled.gds"
DEF = OUT / f"{TOP}_routed.def"
#: Rectangles of the decoupling tiles, which must be treated as macros: fill
#: cannot put COMP inside their well nor poly over their gates.
GAPS = OUT / "decap_gaps.txt"

#: (name, GDS layer, minimum in %, spacing to real metal, spacing between
#: fill squares, minimum square side, rule).
#:
#: Poly2 uses very different numbers because **magic does have fill rules** even
#: though it has no density ones, and KLayout does not check them: `DPF.1` asks
#: 5.6 um width for poly fill, `DPF.2a` 2.4 um between fill shapes and `DPF.5`
#: **5 um clearance to real poly**. With 0.4 squares magic reported 134,488
#: violations on a file KLayout called clean.
#: Dummy goes on datatype 4 of the same number, which is what the decks add in.
#:
#: Metal5 is special: for the 5-metal stack the deck does `top_metal = metal5`,
#: so the `MT.*` rules apply and not the `M5.*` ones -- 0.36 minimum width,
#: 0.46 spacing and 0.5625 um2 area (exactly a 0.75 square). 0.80 a side is used
#: so as not to depend on rounding.
LAYERS = [
    ("COMP",   22, 25.0, 0.40, 0.40, 1.00, "DCF.1b"),
    ("Poly2",  30, 14.0, 5.00, 2.40, 5.60, "PL.8 / DPF.1 / DPF.2a / DPF.5"),
    ("Metal1", 34, 30.0, 0.23, 0.23, 0.40, "M1.4"),
    ("Metal2", 36, 30.0, 0.28, 0.28, 0.40, "M2.4"),
    ("Metal3", 42, 30.0, 0.28, 0.28, 0.40, "M3.4"),
    ("Metal4", 46, 30.0, 0.28, 0.28, 0.40, "M4.4"),
    ("Metal5", 81, 30.0, 0.46, 0.46, 0.80, "M5.4 / MT.3 / MT.1"),
]

#: MIM markers. `MIMTM.1` asks 1.2 um from the plate to any other metal4, and
#: the rule does not forgive fill.
CAP_MK = (117, 5)
MIM_CLEAR = 1.2

#: How far the square may grow chasing density, in multiples of its minimum
#: side. Relative and not absolute because the minimum sides differ wildly
#: between layers: 0.40 on metal and 5.60 on poly fill because of `DPF.1`. With
#: an absolute cap the poly loop never ran even once.
LADO_FACTOR = 3.0
PASO_HOLGURA = 0.05

#: Guard margin against the die outline. COMP fill was reaching **5 nm** from
#: the edge: in isolation that is DRC clean, because nothing is beside it, but
#: next to a seal ring or another project that is zero spacing. The ports do
#: touch the edge on purpose -- that is the way in -- but the fill has no
#: no.
BORDE_DIE = 2.0


def region(cell, layer_index, dbu: float) -> kdb.Region:
    """Every shape of a layer, flattened and on a 1 nm grid."""
    out = kdb.Region()
    it = cell.begin_shapes_rec(layer_index)
    while not it.at_end():
        out.insert(it.shape().dpolygon.transformed(it.dtrans()).to_itype(1e-3))
        it.next()
    out.merge()
    return out


def colocacion(defpath: Path | None = None) -> list[tuple[str, str, float, float, float, float]]:
    """The placed macros: `(instance, cell, x, y, width, height)`, from the DEF.

    Taken from here and not from the GDS because the top GDS is **flattened**
    (see `def_to_gds.py::flatten_all`) and has no instances left to look at. The
    size comes from each macro's LEF `SIZE`.

    `decap_fill.py` uses it too, to find the shelves: two macros are on the same
    shelf if they share `y` and height, which is the condition for their power
    rails to sit at the same level.
    """
    text = (defpath or DEF).read_text()
    unidades = float(re.search(r"UNITS DISTANCE MICRONS (\d+)", text).group(1))
    tam = {}
    for lef in (ROOT / "lef").glob("*.lef"):
        if lef.name in ("vias.lef", "techlef_patched.tlef"):
            continue
        m = re.search(r"\s*SIZE ([\d.]+) BY ([\d.]+) ;", lef.read_text())
        if m:
            tam[lef.stem] = (float(m.group(1)), float(m.group(2)))
    out = []
    block = text[text.index("COMPONENTS"):text.index("END COMPONENTS")]
    for m in re.finditer(r"-\s+(\S+)\s+(\S+)\s*\+\s+\S+\s+"
                         r"\(\s*(-?\d+)\s+(-?\d+)\s*\)\s+(\w+)", block):
        cell = m.group(2)
        if cell not in tam:
            continue
        x, y = int(m.group(3)) / unidades, int(m.group(4)) / unidades
        w, h = tam[cell]
        out.append((m.group(1), cell, x, y, w, h))
    return out


def huella_macros() -> kdb.Region:
    """The macro footprint PLUS that of the decoupling tiles.

    The tiles do not appear in the DEF -- they go in later, onto the GDS -- but
    for fill purposes they are the same as a macro: inside there is well,
    diffusion and gates, and a COMP fill square landing in there would sit in a
    well with no implant of its own.
    """
    out = kdb.Region()
    for _, _, x, y, w, h in colocacion():
        out.insert(kdb.DBox(x, y, x + w, y + h).to_itype(1e-3))
    if GAPS.exists():
        for line in GAPS.read_text().split("\n"):
            if line.strip():
                x0, y0, x1, y1 = (float(v) for v in line.split())
                out.insert(kdb.DBox(x0, y0, x1, y1).to_itype(1e-3))
    out.merge()
    return out


def rejilla(zona: kdb.Region, lado: float, pitch: float, die: kdb.DBox) -> kdb.Region:
    """Squares of `lado` every `paso`, **whole**, inside `zona`.

    No clipping against the zone: a square either fits whole or is not placed.
    That way minimum width and minimum area hold by construction, which is what
    failed before -- clipping produced 0.1 um necks and pieces below minimum
    area, and DRC flagged thousands of `M*.1` and `M*.3`.
    """
    cuadros = kdb.Region()
    y = die.bottom + pitch / 2
    while y + lado <= die.top:
        x = die.left + pitch / 2
        while x + lado <= die.right:
            cuadros.insert(kdb.DBox(x, y, x + lado, y + lado).to_itype(1e-3))
            x += pitch
        y += pitch
    return cuadros.inside(zona)


def main() -> int:
    sobre_macros = "--sobre-macros" in sys.argv
    if not GDS_IN.exists():
        sys.exit(f"{GDS_IN} is missing -- run `make top` first")

    layout = kdb.Layout()
    layout.read(str(GDS_IN))
    top = layout.top_cell()
    die = top.dbbox()
    area_die = die.width() * die.height()

    #  The die minus the guard margin: that is where fill may go.
    dentro = kdb.DBox(die.left + BORDE_DIE, die.bottom + BORDE_DIE,
                      die.right - BORDE_DIE, die.top - BORDE_DIE)
    macros = huella_macros()
    mim = region(top, layout.layer(*CAP_MK), layout.dbu)
    prohibido_mim = mim.sized(int(MIM_CLEAR * 1000))

    libre_total = kdb.Region(die.to_itype(1e-3)) - macros
    print(f"  parte de {GDS_IN.name}")
    print(f"  die {die.width():.2f} x {die.height():.2f} = {area_die:,.0f} um2   "
          f"macros {macros.area()/1e6:,.0f}   libre {libre_total.area()/1e6:,.0f}")
    print(f"  fill {'in channels AND over the macros' if sobre_macros else 'in channels only'}\n")
    print(f"    {'layer':7s} {'regla':12s} {'antes':>7s} {'despues':>8s} {'pide':>5s}   estado")

    corto = []
    for name, gl, minimo, guarda, sep_relleno, lado_min, regla in LAYERS:
        idx = layout.layer(gl, 0)
        real = region(top, idx, layout.dbu)
        antes = 100 * real.area() / 1e6 / area_die

        #  Where fill MAY go: the die minus the geometry itself grown by its
        #  spacing, minus the macros (unless asked for), and always minus the
        #  MIM guard.
        zona = kdb.Region(dentro.to_itype(1e-3)) - real.sized(int(guarda * 1000))
        if not sobre_macros:
            zona -= macros
        zona -= prohibido_mim
        zona.merge()

        #  The side is raised until the rule passes. The step is tied to the
        #  side, so a bigger square is more coverage and neighbour spacing always
        #  stays at the layer's spacing.
        def buscar(z: kdb.Region) -> kdb.Region:
            puesto, lado = kdb.Region(), lado_min
            while lado <= lado_min * LADO_FACTOR + 1e-9:
                pitch = lado + sep_relleno + PASO_HOLGURA
                puesto = rejilla(z, lado, pitch, die)
                if 100 * (real.area() + puesto.area()) / 1e6 / area_die >= minimo:
                    break
                lado += 0.20
            return puesto

        puesto = buscar(zona)
        #  If channels are not enough, fill also goes OVER the macros, but only
        #  on that layer and only where needed. GRADIENT_NAV2 is 22 % bigger than
        #  GRADIENT_NAV with the same macros inside, so its metals 2 to 5 fall
        #  below minimum where v1's reached it: `M2.4`, `M3.4`, `M4.4`, `M5.4`
        #  and `MT.3`, one violation per rule in the density pass. Over a macro
        #  fill only fits where none of its own metal is, because the zone
        #  already comes from subtracting its geometry with the layer's spacing.
        #  with the layer's spacing.
        encima = False
        if (not sobre_macros
                and 100 * (real.area() + puesto.area()) / 1e6 / area_die < minimo):
            ampliada = kdb.Region(dentro.to_itype(1e-3)) - real.sized(int(guarda * 1000))
            ampliada -= prohibido_mim
            ampliada.merge()
            otro = buscar(ampliada)
            if otro.area() > puesto.area():
                puesto, encima = otro, True

        capa_dummy = layout.layer(gl, 4)
        for p in puesto.each():
            top.shapes(capa_dummy).insert(p.transformed(
                kdb.ICplxTrans(0.001 / layout.dbu)))

        despues = 100 * (real.area() + puesto.area()) / 1e6 / area_die
        ok = despues >= minimo
        if not ok:
            corto.append((name, regla, despues, minimo))
        print(f"    {name:7s} {regla:12s} {antes:6.2f}% {despues:7.2f}% "
              f"{minimo:4.0f}%   {'cumple' if ok else 'SIGUE CORTA'}"
              f"{'  (also over the macros)' if encima else ''}")

    GDS_OUT.parent.mkdir(parents=True, exist_ok=True)
    layout.write(str(GDS_OUT))
    print(f"\n  {GDS_OUT}")

    if corto:
        print(f"\n  {len(corto)} layer(s) short of the minimum:")
        for name, regla, d, m in corto:
            print(f"    {name} ({regla}): {d:.2f}% de {m:.0f}%")
        if not sobre_macros:
            print("  With --sobre-macros the fill also goes over the macros.")
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
