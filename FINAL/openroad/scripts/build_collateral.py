#!/usr/bin/env python3
"""Build the OpenROAD collateral (LEF, Liberty, Verilog) for the analog macros.

A GDS is not enough for OpenROAD: to place a block as a hard macro it needs an
abstract LEF (outline, pins and obstructions), a Liberty view (even an empty
black box) and a Verilog declaration. This script produces all three from the
two sources that already exist in the project:

  * the layout   -> Layouts/<BLOCK>/<BLOCK>_flat_gf180.gds   (linked in gds/)
  * the netlist  -> XSCHEM/<DIR>/simulation/<BLOCK>.sch/<BLOCK>.spice

The LEF geometry comes from magic (`lef write`), which is the well-trodden path
and already gets the obstructions right, including the MIM plates up on Metal4
and Metal5. Two details are worth knowing:

  * magic only emits a LEF PIN for labels that are marked as *ports*, and labels
    read from a GDS arrive as plain text. `port makeall` promotes them, and
    without it the LEF comes out with zero pins and no error whatsoever.
  * magic has no netlist, so it cannot know pin directions. They are read here
    from the xschem netlist and patched into the LEF afterwards.

Run it from the openroad/ directory (or use the Makefile):

    python3 scripts/build_collateral.py
"""

from __future__ import annotations

import re
import shutil
import subprocess
import sys
from pathlib import Path

import klayout.db as kdb

ROOT = Path(__file__).resolve().parent.parent
PROJECT = ROOT.parent
MAGIC = "/foss/tools/bin/magic"
MAGICRC = "/foss/pdks/gf180mcuD/libs.tech/magic/gf180mcuD.magicrc"

# block -> netlist that declares its pins
BLOCKS = {
    "COMP": PROJECT / "XSCHEM/OPAM/simulation/COMP.sch/COMP.spice",
    "WEIGHT_COMP": PROJECT / "XSCHEM/WEIGTH/simulation/WEIGHT_COMP.sch/WEIGHT_COMP.spice",
    "OPAM": PROJECT / "XSCHEM/OPAM/simulation/OPAM.sch/OPAM.spice",
    "DECODER": PROJECT / "XSCHEM/DECODER/simulation/DECODER.sch/DECODER.spice",
}

#: Blocks whose layout does not exist yet. They are reported and skipped instead
#: of failing the run, so the rest of the collateral can still be rebuilt; every
#: other missing piece is an error, because a silently incomplete collateral is
#: how you end up floorplanning a chip that is missing a block.
PENDING = {"OPAM"}

POWER = {"VDD", "VCC", "VPWR"}
GROUND = {"VSS", "VGND", "GND"}


# --------------------------------------------------------------------------- #
#  pin directions
# --------------------------------------------------------------------------- #
def read_directions(netlist: Path, block: str) -> dict[str, str]:
    """Pin -> INPUT / OUTPUT / INOUT for the TOP cell, from the xschem netlist.

    xschem writes the pin types in two different formats depending on the export
    style, and both show up in this project:

        *.ipin INN            /  *.opin OUT   /  *.iopin VDD
        *.PININFO VDD:B VSS:B VA:I OUT:B

    The result is restricted to the ports of the top `.subckt`, and returned in
    that order. The file also contains the sub-circuits (bias, sub_diff...) with
    pin declarations of their own: scanning the whole file returned 14 pins for
    COMP instead of 5, mixing in internal nodes such as `bias1` or `vinp`.

    Power and ground are forced to INOUT whatever the schematic says.
    """
    text = netlist.read_text()

    # the top may be a real `.subckt` or the commented `**.subckt` of the other
    # export format
    m = re.search(rf"^\*{{0,2}}\.subckt\s+{re.escape(block)}\s+(.*)$", text, re.M | re.I)
    if not m:
        raise SystemExit(f"no .subckt {block} found in {netlist}")
    ports = m.group(1).split()

    seen: dict[str, str] = {}
    for kind, name in re.findall(r"^\*\.(ipin|opin|iopin)\s+(\S+)", text, re.M):
        seen.setdefault(name, {"ipin": "INPUT", "opin": "OUTPUT",
                               "iopin": "INOUT"}[kind])
    pin_info = re.search(r"^\*\.PININFO\s+(.*)$", text, re.M)
    if pin_info:
        for tok in pin_info.group(1).split():
            if ":" in tok:
                pin, d = tok.rsplit(":", 1)
                seen.setdefault(pin, {"I": "INPUT", "O": "OUTPUT"}.get(d, "INOUT"))

    out: dict[str, str] = {}
    for p in ports:
        out[p] = ("INOUT" if p.upper() in POWER | GROUND
                  else seen.get(p, "INOUT"))
    return out


# --------------------------------------------------------------------------- #
#  LEF
# --------------------------------------------------------------------------- #
def write_lef(block: str, gds: Path, work: Path) -> Path:
    """Run magic to turn the GDS into an abstract LEF."""
    work.mkdir(parents=True, exist_ok=True)
    script = work / f"{block}_lef.tcl"
    script.write_text(
        f"gds read {gds}\n"
        f"load {block}\n"
        "select top cell\n"
        # Without this the LEF has no PIN at all, and magic does not complain.
        "port makeall\n"
        # NOT `-hide`. That mode collapses the obstructions into a few coarse
        # blocks, and one of them ended up covering the block's own Metal1 power
        # rail: pdngen reported `VSS on Metal1 is partially blocked (99.0%) by
        # obstructions on Metal2` and could not drop a single via into
        # WEIGHT_COMP. The detailed obstructions are bigger to read and leave the
        # rails reachable, which is the whole point of exporting them.
        f"lef write {block}\n"
        "quit -noprompt\n")
    subprocess.run([MAGIC, "-dnull", "-noconsole", "-rcfile", MAGICRC, script.name],
                   cwd=work, capture_output=True, text=True, timeout=600, check=False,
                   env={"PATH": "/usr/bin:/bin", "PDK_ROOT": "/foss/pdks", "HOME": "/tmp"})
    lef = work / f"{block}.lef"
    if not lef.exists():
        raise SystemExit(f"magic did not write {lef}")
    return lef


def patch_directions(lef_text: str, dirs: dict[str, str]) -> str:
    """Insert DIRECTION into every PIN; magic cannot know it."""
    out, current = [], None
    for line in lef_text.splitlines():
        out.append(line)
        m = re.match(r"\s*PIN\s+(\S+)\s*$", line)
        if m:
            current = m.group(1)
            d = dirs.get(current)
            if d:
                out.append(f"    DIRECTION {d} ;")
    return "\n".join(out) + "\n"


#: Que via conecta que par de metales. magic no escribe obstrucciones en las
#: capas de via, y sin ellas el router se cree con derecho a bajar una via en
#: cualquier punto del interior de un macro: 255 violaciones en el top, casi
#: todas DENTRO de los bloques (M1.3 de area minima, M1.2a, V1.x, y hasta
#: `MIMTM.10 MiM cap cannot overlap via3`). Una via solo puede existir donde los
#: DOS metales que une esten libres, asi que su obstruccion es la union de las
#: dos.
_VIA_BETWEEN = {"Via1": ("Metal1", "Metal2"), "Via2": ("Metal2", "Metal3"),
                "Via3": ("Metal3", "Metal4"), "Via4": ("Metal4", "Metal5")}

#: Cuanto se engorda la obstruccion de cada metal. Declararla con la geometria
#: exacta no basta: el router se cuela por huecos donde luego no puede cumplir el
#: espaciado, y salen violaciones DENTRO del macro. Se le da el margen de la
#: propia regla para que se mantenga a raya.
#:
#: Metal4 lleva ademas los 1.2 um de `MIMTM.1`: las placas de los MIM viven ahi y
#: la regla no pide no solaparlas, pide 1.2 um a cualquier otro metal4. Aun asi
#: quedan bandas libres de sobra (en COMP, 48 de sus 104 um), y hacen falta:
#: es por donde el router cruza un macro en vertical. Sin Metal4, todo el trafico
#: vertical tenia que pasar por los canales y el ruteo global no cerraba.
#: Media anchura del cable del router. Las nets de senal del top van con la regla
#: no estandar `ANCHO` (0.38, ver `route_top.tcl`), y el router mantiene el cable
#: FUERA de la obstruccion pero midiendo por su eje: creciendo la obstruccion solo
#: el espaciado, el borde del cable acababa a 0.24-0.27 um del metal del macro.
#: Las 15 violaciones que quedaban en el top eran todas eso — cable del router
#: contra metal de un macro, ninguna macro contra macro ni router contra router.
_MEDIO_CABLE = 0.19

_OBS_GROW = {"Metal1": 0.23, "Metal2": 0.30 + _MEDIO_CABLE,
             "Metal3": 0.30 + _MEDIO_CABLE,
             "Metal4": 0.30 + _MEDIO_CABLE + 1.2, "Metal5": 0.30}


def add_via_obstructions(lef_text: str, extra: dict[str, list] | None = None) -> str:
    """Reescribe el bloque OBS: engorda los metales y anade las capas de via.

    `extra` trae la geometria que `keep_top_access` quito de los pines. Va aqui y
    no a la basura: en COMP y OPAM esas formas de Metal4/Metal5 son **la placa del
    MIM**. Borrarlas del abstracto dejo la placa invisible, y las tiras de
    alimentacion del top se le pusieron al lado — 22 `MIMTM.1`, que pide 1.2 um.
    Como obstruccion, y con el margen de la regla, nadie se le acerca.
    """
    body = lef_text[lef_text.index("  OBS"):]
    by_layer: dict[str, kdb.Region] = {}
    for name, boxes in (extra or {}).items():
        for x0, y0, x1, y1 in boxes:
            by_layer.setdefault(name, kdb.Region()).insert(
                kdb.Box(round(x0 * 1000), round(y0 * 1000),
                        round(x1 * 1000), round(y1 * 1000)))
    layer = None
    for line in body.splitlines():
        m = re.match(r"\s*LAYER (\S+) ;", line)
        if m:
            layer = m.group(1)
            continue
        m = re.match(r"\s*RECT ([-\d.]+) ([-\d.]+) ([-\d.]+) ([-\d.]+) ;", line)
        if m and layer:
            x0, y0, x1, y1 = (float(v) for v in m.groups())
            by_layer.setdefault(layer, kdb.Region()).insert(
                kdb.Box(round(x0 * 1000), round(y0 * 1000),
                        round(x1 * 1000), round(y1 * 1000)))

    for name, grow in _OBS_GROW.items():
        if name in by_layer:
            by_layer[name] = by_layer[name].sized(round(grow * 1000)).merged()

    extra = []
    for via, (lo, hi) in _VIA_BETWEEN.items():
        r = kdb.Region()
        for name in (lo, hi):
            if name in by_layer:
                r += by_layer[name]
        r.merge()
        if r.is_empty():
            continue
        extra.append(f"      LAYER {via} ;")
        for poly in r.each():
            b = poly.bbox()
            extra.append(f"        RECT {b.left / 1000:.3f} {b.bottom / 1000:.3f} "
                         f"{b.right / 1000:.3f} {b.top / 1000:.3f} ;")

    #  Se reescribe el bloque OBS entero: las de metal van engordadas y las de
    #  via son nuevas, asi que no vale con anadir al final.
    for name in _OBS_GROW:
        if name not in by_layer:
            continue
        extra.append(f"      LAYER {name} ;")
        for poly in by_layer[name].each():
            b = poly.bbox()
            extra.append(f"        RECT {b.left / 1000:.3f} {b.bottom / 1000:.3f} "
                         f"{b.right / 1000:.3f} {b.top / 1000:.3f} ;")
    for name, region in by_layer.items():
        if name in _OBS_GROW or name in _VIA_BETWEEN:
            continue                       # Nwell y demas, tal cual venian
        extra.append(f"      LAYER {name} ;")
        for poly in region.each():
            b = poly.bbox()
            extra.append(f"        RECT {b.left / 1000:.3f} {b.bottom / 1000:.3f} "
                         f"{b.right / 1000:.3f} {b.top / 1000:.3f} ;")

    head = lef_text[:lef_text.index("  OBS")]
    return head + "  OBS\n" + "\n".join(extra) + "\n  END\n" + "END " + \
        re.search(r"MACRO (\S+)", lef_text).group(1) + "\n"


#: Numero de capa en el GDS de cada metal, para poder mirar lo que hay de verdad.
_GDS = {"Metal1": (34, 0), "Metal2": (36, 0), "Metal3": (42, 0),
        "Metal4": (46, 0), "Metal5": (81, 0)}


def _clip_to_real(rects: list[str], real) -> list[str]:
    """Sustituye cada RECT del pin por su interseccion con el metal real."""
    out = []
    for line in rects:
        m = re.match(r"\s*RECT ([-\d.]+) ([-\d.]+) ([-\d.]+) ([-\d.]+) ;", line)
        if not m:
            out.append(line)
            continue
        box = kdb.DBox(*(float(v) for v in m.groups()))
        got = real & kdb.Region(box.to_itype(1e-3))
        got.merge()
        pieces = []
        for poly in got.each():
            #  Ni `is_box()` ni la igualdad exacta de areas valen como criterio:
            #  el metal real llega al pin con las esquinas achaflanadas y sale un
            #  poligono de ocho vertices. Se acepta la caja del trozo cuando el
            #  trozo la llena casi entera; lo que se declara de mas son esos
            #  chaflanes, centesimas de micra y siempre DENTRO del rectangulo que
            #  magic ya declaraba.
            if poly.area() < 0.8 * poly.bbox().area():
                pieces = []            # forma rara: mejor dejar el RECT original
                break
            b = poly.bbox().to_dtype(1e-3)
            #  Nada por debajo del ancho minimo de metal3 (M3.1 = 0.28): una
            #  esquirla no es un sitio donde aterrizar.
            if min(b.width(), b.height()) >= 0.28:
                pieces.append(f"      RECT {b.left:.3f} {b.bottom:.3f} "
                              f"{b.right:.3f} {b.top:.3f} ;")
        out.extend(pieces or [line])
    return out


def keep_top_access(lef_text: str, dirs: dict[str, str], gds=None):
    """Deja en cada pin de senal solo el metal por el que el top puede entrar.

    Los bloques suben ahora sus puertos hasta Metal3 (ver
    `zotnetic_layout/coil_layout/power.py`). Si el LEF sigue anunciando ademas la
    forma de Metal1, el router del top se mete por ahi: baja una via1 hasta dentro
    del bloque y aterriza pegada al metal del vecino — `Cut Short` en el ruteo
    detallado, que es exactamente lo que la plataforma de Metal3 venia a evitar.

    Los pines de alimentacion no se tocan: sus rieles de Metal1 son lo que
    `pdngen` mira, y ademas recorren todo el ancho del bloque, sin vecino al que
    tocar.
    """
    #  SOLO Metal3. Dejar tambien Metal4/Metal5 parecia inofensivo —es la misma
    #  net— pero en COMP y OPAM esas formas son **la placa del MIM**: el router
    #  las tomaba como punto de acceso y tendia Metal4 a su lado, y `MIMTM.1` pide
    #  1.2 um a cualquier otro metal4 sin perdonar que sea la misma net. De ahi
    #  salian 60 de las 170 violaciones del top.
    keep = {"Metal3"}
    dropped: dict[str, list] = {}
    #  El pin se recorta contra el metal3 QUE HAY DE VERDAD en el GDS. `lef write`
    #  de magic da un rectangulo por puerto, y cuando los pads de un puerto no
    #  llegaron a unirse en barra (`add_signal_access` solo los une si el
    #  espaciado se lo permite) ese rectangulo es su CAJA ENVOLVENTE: declara como
    #  aterrizable un hueco donde no hay metal. El router aterrizaba ahi, a 0.14 um
    #  del pad de al lado — las `M3.2a` que quedaban en el top, y sobre todo un
    #  circuito ABIERTO que netgen veia como un fragmento de net por cada pin de
    #  macro (114 nets de mas en el top).
    real = None
    if gds is not None:
        ly = kdb.Layout()
        ly.read(str(gds))
        #  42/0 es Metal3 en GF180. 34/0 es Metal1: recortar contra el metal
        #  equivocado dejaba los pines en esquirlas de 0.34 um donde hay una barra
        #  entera de 2.3 x 0.4, y el DRC del top subia de 14 a 32.
        real = kdb.Region(ly.top_cell().begin_shapes_rec(ly.layer(*_GDS["Metal3"])))
        real.merge()
    out, pin, groups, in_port = [], None, None, False
    for line in lef_text.splitlines():
        m = re.match(r"\s*PIN\s+(\S+)\s*$", line)
        if m:
            pin = m.group(1)
            out.append(line)
            continue
        if pin and re.match(r"\s*END\s+" + re.escape(pin) + r"\s*$", line):
            pin = None
            out.append(line)
            continue
        power = pin and pin.upper() in POWER | GROUND
        if pin and not power and re.match(r"\s*PORT\s*$", line):
            in_port, groups = True, []
            out.append(line)
            continue
        if in_port:
            if re.match(r"\s*END\s*$", line):
                has3 = any(g[0] in keep for g in groups)
                for layer, rects in groups:
                    if has3 and layer not in keep:
                        # No se tira: pasa a ser obstruccion (ver add_via_obstructions)
                        for r in rects:
                            m2 = re.match(r"\s*RECT ([-\d.]+) ([-\d.]+) "
                                          r"([-\d.]+) ([-\d.]+) ;", r)
                            if m2:
                                dropped.setdefault(layer, []).append(
                                    tuple(float(v) for v in m2.groups()))
                        continue          # el top entra por arriba, no por aqui
                    out.append(f"      LAYER {layer} ;")
                    out.extend(_clip_to_real(rects, real)
                               if layer in keep and real is not None else rects)
                out.append(line)
                in_port, groups = False, None
                continue
            m = re.match(r"\s*LAYER\s+(\S+)\s*;", line)
            if m:
                groups.append((m.group(1), []))
            elif groups:
                groups[-1][1].append(line)
            continue
        out.append(line)
    return "\n".join(out) + "\n", dropped


def count_pins(lef_text: str) -> int:
    return len(re.findall(r"^\s*PIN\s+\S+\s*$", lef_text, re.M))


def macro_size(lef_text: str) -> tuple[float, float]:
    m = re.search(r"SIZE\s+([\d.]+)\s+BY\s+([\d.]+)", lef_text)
    return (float(m.group(1)), float(m.group(2))) if m else (0.0, 0.0)


# --------------------------------------------------------------------------- #
#  Liberty
# --------------------------------------------------------------------------- #
def write_lib(block: str, dirs: dict[str, str], path: Path) -> None:
    """Minimal black-box Liberty view.

    OpenROAD refuses to link a design whose macros have no Liberty, even when it
    only has to place them. These blocks are analog and have no timing arcs, so
    the cell carries its pins and nothing else: no arcs are better than made-up
    ones, which would silently feed wrong numbers into the timer.
    """
    lines = [
        f'library ({block}) {{',
        '  comment                        : "Black-box view of an analog macro. '
        'No timing arcs on purpose.";',
        '  delay_model                    : table_lookup;',
        '  time_unit                      : "1ns";',
        '  voltage_unit                   : "1V";',
        '  current_unit                   : "1mA";',
        '  capacitive_load_unit (1, pf);',
        '  pulling_resistance_unit        : "1kohm";',
        '  leakage_power_unit             : "1nW";',
        '  nom_voltage                    : 5.0;',
        '  nom_temperature                : 25.0;',
        '  nom_process                    : 1.0;',
        '',
        f'  cell ({block}) {{',
        '    is_macro_cell : true;',
        '    dont_touch    : true;',
        '    dont_use      : true;',
        '    interface_timing : true;',
    ]
    for pin, d in dirs.items():
        up = pin.upper()
        if up in POWER:
            lines += [f'    pg_pin ({pin}) {{',
                      f'      voltage_name : "{pin}";',
                      '      pg_type      : primary_power;',
                      '    }']
        elif up in GROUND:
            lines += [f'    pg_pin ({pin}) {{',
                      f'      voltage_name : "{pin}";',
                      '      pg_type      : primary_ground;',
                      '    }']
        else:
            lines += [f'    pin ({pin}) {{',
                      f'      direction   : {d.lower()};',
                      '      capacitance : 0.01;',
                      '    }']
    lines += ['  }', '}', '']
    path.write_text("\n".join(lines))


# --------------------------------------------------------------------------- #
#  Verilog
# --------------------------------------------------------------------------- #
def write_verilog(block: str, dirs: dict[str, str], path: Path) -> None:
    """Black-box module declaration for synthesis and for link_design."""
    ports = list(dirs)
    body = [f"// Black-box declaration of the {block} analog macro.",
            "// The layout is the real implementation; this only gives the tools",
            "// an interface to bind against.",
            "",
            "(* blackbox *)",
            f"module {block} (",
            "    " + ",\n    ".join(ports),
            ");"]
    for pin, d in dirs.items():
        body.append(f"  {d.lower():6} {pin};")
    body += ["endmodule", ""]
    path.write_text("\n".join(body))


# --------------------------------------------------------------------------- #
def main() -> None:
    work = ROOT / "work"
    ok = True
    for block, netlist in BLOCKS.items():
        gds = ROOT / "gds" / f"{block}.gds"
        if not gds.exists() or not gds.resolve().exists():
            if block in PENDING:
                print(f"  {block:12} no layout yet — skipped")
                continue
            print(f"  {block}: missing {gds}")
            ok = False
            continue
        if not netlist.exists():
            print(f"  {block}: missing netlist {netlist}")
            ok = False
            continue

        dirs = read_directions(netlist, block)
        raw = write_lef(block, gds.resolve(), work)
        # Primero se recortan los pines, y lo que se quita de ellos entra como
        # obstruccion: el orden inverso perderia la placa del MIM.
        text, dropped = keep_top_access(
            patch_directions(raw.read_text(), dirs), dirs, gds.resolve())
        text = add_via_obstructions(text, dropped)

        lef_path = ROOT / "lef" / f"{block}.lef"
        lef_path.write_text(text)
        write_lib(block, dirs, ROOT / "lib" / f"{block}.lib")
        write_verilog(block, dirs, ROOT / "verilog" / f"{block}.v")

        n_lef, n_net = count_pins(text), len(dirs)
        w, h = macro_size(text)
        flag = "OK " if n_lef == n_net else "PIN COUNT MISMATCH"
        if n_lef != n_net:
            ok = False
        print(f"  {block:12} {w:8.2f} x {h:6.2f} um   "
              f"{n_lef} LEF pins / {n_net} netlist pins   {flag}")
        short = {"INPUT": "in", "OUTPUT": "out", "INOUT": "inout"}
        print("               "
              + ", ".join(f"{p}:{short[d]}" for p, d in dirs.items()))

    shutil.rmtree(work, ignore_errors=True)
    if not ok:
        sys.exit("collateral is incomplete")


if __name__ == "__main__":
    main()
