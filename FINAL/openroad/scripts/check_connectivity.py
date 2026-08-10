#!/usr/bin/env python3
"""Comprueba, net por net, que el GDS del top conecta lo que el DEF dice.

El LVS del top con netgen daba ~110 nets de mas, todas fragmentos con nombre de
pin de macro (`COMP_3.INN`, `OPAM_1.OUT`). Eso es un circuito ABIERTO, y un
abierto no viola ninguna regla de DRC: no lo ve ninguna de las dos herramientas
de DRC, solo el LVS, y alli aparece mezclado con todo lo demas.

Esto lo aisla: extrae la conectividad del GDS con KLayout —solo metales y vias,
sin dispositivos, que es rapido— y para cada net del DEF comprueba que TODOS sus
terminales caen en la misma net extraida.

    python3 scripts/check_connectivity.py [DEF]
"""

from __future__ import annotations

import re
import sys
from pathlib import Path

import klayout.db as kdb

ROOT = Path(__file__).resolve().parent.parent

#: (capa, via de abajo) de la pila de ruteo, de abajo a arriba.
STACK = [("Metal1", (34, 0)), ("Via1", (35, 0)), ("Metal2", (36, 0)),
         ("Via2", (38, 0)), ("Metal3", (42, 0)), ("Via3", (40, 0)),
         ("Metal4", (46, 0)), ("Via4", (41, 0)), ("Metal5", (81, 0))]

_ORIENT = {"N": (1, 1, 0), "S": (-1, -1, 1), "FN": (-1, 1, 0), "FS": (1, -1, 1)}


def lef_pins(path: Path) -> dict[str, list[tuple[float, float, float, float]]]:
    """Pin -> rectangulos de Metal3 declarados en el LEF."""
    out: dict[str, list] = {}
    pin = layer = None
    for line in path.read_text().splitlines():
        m = re.match(r"\s*PIN\s+(\S+)\s*$", line)
        if m:
            pin, layer = m.group(1), None
            continue
        if pin and re.match(rf"\s*END\s+{re.escape(pin)}\s*$", line):
            pin = None
            continue
        m = re.match(r"\s*LAYER\s+(\S+)\s*;", line)
        if m:
            layer = m.group(1)
            continue
        m = re.match(r"\s*RECT ([-\d.]+) ([-\d.]+) ([-\d.]+) ([-\d.]+) ;", line)
        if m and pin and layer == "Metal3":
            out.setdefault(pin, []).append(tuple(float(v) for v in m.groups()))
    return out


def read_def(path: Path):
    """(instancias, nets) del DEF: colocacion y lista de (inst, pin) por net."""
    text = path.read_text()
    comp = text[text.index("COMPONENTS "):text.index("END COMPONENTS")]
    inst = {}
    for m in re.finditer(r"-\s+(\S+)\s+(\S+)\s*\+\s+\S+\s+\(\s*(-?\d+)\s+(-?\d+)\s*\)\s+(\w+)",
                         comp):
        inst[m.group(1)] = (m.group(2), int(m.group(3)), int(m.group(4)), m.group(5))
    #  El DEF de este flujo va a 2000 unidades por micra, no a las 1000 de
    #  costumbre: hay que leerlo, no suponerlo.
    units = float(re.search(r"UNITS DISTANCE MICRONS (\d+)", text).group(1))
    body = text[text.index("\nNETS "):text.index("END NETS")]
    nets = {}
    for blk in body.split("\n    - ")[1:]:
        name = blk.split()[0]
        #  Solo la CABECERA de la net: a partir del primer `+` vienen las
        #  coordenadas del ruteo, y `( 50960 * )` tambien encaja con el patron de
        #  un par (instancia, pin).
        head = blk.split("+")[0]
        pins = [(a, b) for a, b in re.findall(r"\(\s*(\S+)\s+(\S+)\s*\)", head)
                if a != "PIN"]
        nets[name] = pins
    return inst, nets, units


def place(rect, x, y, orient, size):
    """Rectangulo del LEF -> coordenadas absolutas, segun la orientacion."""
    x0, y0, x1, y1 = rect
    w, h = size
    if orient in ("S", "FS"):
        y0, y1 = h - y1, h - y0
    if orient in ("FN", "S"):
        x0, x1 = w - x1, w - x0
    return (x + x0, y + y0, x + x1, y + y1)


def macro_size(path: Path) -> tuple[float, float]:
    m = re.search(r"\s*SIZE ([\d.]+) BY ([\d.]+) ;", path.read_text())
    return (float(m.group(1)), float(m.group(2)))


def main() -> int:
    dpath = Path(sys.argv[1]) if len(sys.argv) > 1 else ROOT / "out/GRADIENT_NAV_routed.def"
    gpath = ROOT / "out/GRADIENT_NAV.gds"
    inst, nets, units = read_def(dpath)

    ly = kdb.Layout()
    ly.read(str(gpath))
    top = ly.top_cell()
    l2n = kdb.LayoutToNetlist(kdb.RecursiveShapeIterator(ly, top, []))
    regions = {}
    for name, (gl, dt) in STACK:
        regions[name] = l2n.make_polygon_layer(ly.layer(gl, dt), name)
    for i in range(0, len(STACK) - 1, 2):
        metal, via, up = STACK[i][0], STACK[i + 1][0], STACK[i + 2][0]
        l2n.connect(regions[metal])
        l2n.connect(regions[metal], regions[via])
        l2n.connect(regions[via], regions[up])
    l2n.connect(regions["Metal5"])
    l2n.extract_netlist()

    lefs, sizes = {}, {}
    for p in (ROOT / "lef").glob("*.lef"):
        if p.name in ("vias.lef", "techlef_patched.tlef"):
            continue
        lefs[p.stem] = lef_pins(p)
        sizes[p.stem] = macro_size(p)

    bad = 0
    for net, pins in sorted(nets.items()):
        seen, missing = set(), []
        for iname, pin in pins:
            if iname not in inst:
                continue
            cell, x, y, orient = inst[iname]
            x, y = x / units, y / units
            for r in lefs.get(cell, {}).get(pin, []):
                a = place(r, x, y, orient, sizes[cell])
                pt = kdb.DPoint((a[0] + a[2]) / 2, (a[1] + a[3]) / 2)
                n = l2n.probe_net(regions["Metal3"], pt)
                seen.add(n.name if n else None) if n else missing.append(
                    f"{iname}.{pin}")
        if len(seen) > 1 or missing:
            bad += 1
            print(f"  {net:14s} {len(pins)} terminales -> {len(seen)} nets"
                  + (f", sin metal: {', '.join(missing)}" if missing else ""))
    print(f"\n{len(nets) - bad}/{len(nets)} nets del DEF conectadas en el GDS")
    return 1 if bad else 0


if __name__ == "__main__":
    sys.exit(main())
