#!/usr/bin/env python3
"""Turn an OpenROAD DEF into a GDS, with the real layout inside every macro.

**This OpenROAD build has no `write_gds`** — the list of `write_*` commands ends
at `write_verilog` — so the stream-out is done with KLayout, which reads DEF and
can substitute each macro's abstract by the GDS it was abstracted from.

That substitution is the whole point. Without it the macros come out as their LEF
outlines: a chip-shaped box with pins and no transistors, which looks right in a
screenshot and is worthless.

    python3 scripts/def_to_gds.py [out/GRADIENT_NAV.def [out/GRADIENT_NAV.gds]]
"""

from __future__ import annotations

import sys
from pathlib import Path

import klayout.db as kdb

ROOT = Path(__file__).resolve().parent.parent
PDK = Path("/foss/pdks/gf180mcuD")
SC_LIB = "gf180mcu_fd_sc_mcu9t5v0"
SC_REF = PDK / "libs.ref" / SC_LIB
MAP = PDK / "libs.tech/klayout/tech/gf180mcu.map"


def def_dbu(path: Path) -> float:
    """Database unit of a DEF, in um, from its `UNITS DISTANCE MICRONS` line."""
    for line in path.read_text().splitlines():
        if line.startswith("UNITS DISTANCE MICRONS"):
            return 1.0 / float(line.split()[3])
        if line.startswith("COMPONENTS"):
            break
    return 0.001


def flatten_all(layout, top) -> None:
    """Aplana el top entero antes de escribir el GDS.

    magic evalua los booleanos con que lee un GDS **celda a celda**: una forma
    solo existe para el si todas las capas que la definen aparecen juntas en la
    MISMA celda. Ya lo pagamos con las vias de los condensadores MIM (ver
    `coil_layout/caps.py::flat_add`), y aqui vuelve, mas fino: al sustituir los
    macros, el lector de DEF de KLayout reconstruye la jerarquia interna del
    bloque de otra manera, y el tap del pozo —`COMP and NPLUS and NWELL`— deja de
    verse. El resultado era que **el pozo n de cada macro salia flotante** en vez
    de VDD: 43 nets de pozo y 47 de activo de mas en el LVS del top, casi todo el
    hueco de 986 nets contra las 880 de la referencia. Leyendo el mismo bloque de
    su propio GDS el pozo si queda atado, asi que no es el layout: es la
    jerarquia con la que le llega a magic.

    KLayout, gdsfactory y el DRC de firma dan igual el mismo resultado con o sin
    esto —su extraccion no depende de la jerarquia—, y `check_connectivity.py`
    daba ya las 55 nets conectadas antes de aplanar. Lo que se gana es que magic
    y netgen vean lo mismo que ellos.
    """
    #  Las etiquetas del top ANTES de aplanar son las de los pines del DEF, y son
    #  las unicas que deben sobrevivir. Cada macro trae ademas las suyas
    #  (`OUT`, `INN`, `Z`, `VDD`...), que aplanadas caen todas en la misma celda:
    #  doce `OUT`, doce `INN`, cuatro `Z`. magic da por UNIDO todo lo que comparte
    #  nombre de etiqueta, asi que la net `Z` salia con 1501 pines y el chip se
    #  quedaba en 848 nets contra las 880 de la referencia. Dentro de su bloque
    #  esas etiquetas son correctas —cada una en su celda—; al aplanar dejan de
    #  serlo.
    keep = {li: [s.text.dup() for s in top.shapes(li).each() if s.is_text()]
            for li in layout.layer_indexes()}
    top.flatten(-1, True)
    #  Sin esto las celdas de los macros se quedan huerfanas y el GDS pasa a
    #  tener varias celdas de arriba, que rompe todo lo que venga detras.
    layout.cleanup()
    for li in layout.layer_indexes():
        dead = [s for s in top.shapes(li).each() if s.is_text()]
        for s in dead:
            top.shapes(li).erase(s)
        for txt in keep.get(li, []):
            top.shapes(li).insert(txt)


def main() -> int:
    # Por defecto el DEF **ruteado**: el del floorplan no lleva las nets de senal,
    # y un GDS sin ellas parece completo y no lo esta.
    default = ROOT / "out/GRADIENT_NAV_routed.def"
    if not default.exists():
        default = ROOT / "out/GRADIENT_NAV.def"
    def_path = Path(sys.argv[1]) if len(sys.argv) > 1 else default
    gds_path = (Path(sys.argv[2]) if len(sys.argv) > 2
                else ROOT / "out/GRADIENT_NAV.gds")
    if not def_path.exists():
        sys.exit(f"no DEF at {def_path} — run the floorplan first")

    # `vias.lef` no es un macro: son definiciones de via para el router.
    macro_lefs = sorted(p for p in (ROOT / "lef").glob("*.lef")
                        if p.name not in ("vias.lef", "techlef_patched.tlef"))
    macro_gds = [ROOT / "gds" / f"{p.stem}.gds" for p in macro_lefs]
    missing = [p for p in macro_gds if not p.resolve().exists()]
    if missing:
        sys.exit("missing macro GDS: " + ", ".join(str(p) for p in missing))

    opts = kdb.LoadLayoutOptions()
    cfg = opts.lefdef_config
    cfg.map_file = str(MAP)
    cfg.lef_files = [
        str(ROOT / "lef/techlef_patched.tlef"),
        str(SC_REF / f"lef/{SC_LIB}.lef"),
        str(ROOT / "lef/vias.lef"),
        *[str(p) for p in macro_lefs],
    ]
    # 2 = never draw the LEF abstract for a MACRO, always take the geometry from
    # the substitution layouts below. Mode 1 does the opposite and is the default
    # trap: it reads the GDS files, ignores them, and writes outlines.
    cfg.macro_resolution_mode = 2
    cfg.macro_layout_files = [str(p) for p in macro_gds]
    # Match the DEF's own precision. Left at the 1 nm default, KLayout warns and
    # rounds every coordinate of a DEF written at 0.5 nm.
    cfg.dbu = def_dbu(def_path)

    layout = kdb.Layout()
    layout.read(str(def_path), opts)

    top = layout.top_cell()

    #  La comprobacion de que la sustitucion de macros se hizo va ANTES de
    #  aplanar; despues ya no hay celda de macro que contar.
    box = top.dbbox()
    print(f"{gds_path}")
    print(f"  top cell   {top.name}   {box.width():.2f} x {box.height():.2f} um")
    ok = True
    for p in macro_gds:
        name = p.stem
        cell = layout.cell(name)
        if cell is None:
            print(f"  {name:14s} NOT INSTANTIATED")
            ok = False
            continue
        # A macro that came in as its LEF abstract has a handful of shapes; the
        # real thing has thousands. Counting is the cheapest way to be sure the
        # substitution actually happened.
        n = sum(cell.shapes(i).size() for i in layout.layer_indexes())
        print(f"  {name:14s} {cell.child_instances():5d} sub-cells, {n:6d} shapes")

    flatten_all(layout, top)
    gds_path.parent.mkdir(parents=True, exist_ok=True)
    layout.write(str(gds_path))
    print(f"  aplanado   {layout.cells()} celda(s), "
          f"{sum(top.shapes(i).size() for i in layout.layer_indexes())} formas")
    return 0 if ok else 1


if __name__ == "__main__":
    sys.exit(main())
