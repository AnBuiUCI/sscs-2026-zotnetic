#!/usr/bin/env python3
"""Comprueba, net por net, que el GDS del top conecta lo que el DEF dice.

Dos preguntas, las dos invisibles para el DRC:

* **Abiertos.** El LVS del top con netgen daba ~110 nets de mas, todas fragmentos
  con nombre de pin de macro (`COMP_3.INN`, `OPAM_1.OUT`). Un abierto no viola
  ninguna regla: no lo ve ninguna de las dos herramientas de DRC, solo el LVS, y
  alli aparece mezclado con todo lo demas. Aqui se comprueba que TODOS los
  terminales de cada net del DEF caen en la misma net extraida.
* **Cortos.** El caso contrario y todavia mas escurridizo: dos formas de la misma
  capa que se solapan **se funden en un poligono**, asi que no hay violacion de
  espaciado que ver. Ni KLayout, ni magic, ni el informe del propio router dicen
  nada. Aqui se agrupan las nets del DEF por la net extraida: dos nets que caigan
  en la misma estan en corto. Asi salio el ultimo del top —`S2P`, `VDD` y `VSS`
  fundidas por un cable de Metal2 que cruzaba los pads de alimentacion de dos
  macros— en un segundo, en vez de las dos horas que tarda magic en extraer el
  top para que netgen lo cuente como un nodo de 2442 terminales.

Extrae la conectividad del GDS con KLayout: solo metales y vias, sin
dispositivos, que es lo que lo hace rapido.

    python3 scripts/check_connectivity.py [DEF]
"""

from __future__ import annotations

import re
import sys
from pathlib import Path

import klayout.db as kdb

from def_to_gds import lef_origin

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


def read_def_ports(path: Path):
    """net -> [(capa, x, y)] de los pines del propio top.

    Estos NO son terminales de macro y hay que mirarlos aparte. Se quedaron fuera
    de la comprobacion original y ahi se escondio el ultimo fallo del top: los
    puertos `VDD` y `VSS` estaban **flotando**. `place_pins` los deja en el borde
    del die como una senal mas, en un pad que no toca la malla de alimentacion, y
    el router no los cierra porque salta las nets POWER/GROUND. No lo ve el DRC
    —un abierto no viola ninguna regla— y aqui no se miraba: el LVS era el unico
    que lo cantaba, y disfrazado de fallo de emparejamiento de pines.
    """
    text = path.read_text()
    body = text[text.index("\nPINS "):text.index("END PINS")]
    units = float(re.search(r"UNITS DISTANCE MICRONS (\d+)", text).group(1))
    declarados = int(re.search(r"\nPINS (\d+)", text).group(1))
    out: dict[str, list] = {}
    for blk in body.split("\n    - ")[1:]:
        m = re.search(r"NET\s+(\S+)", blk)
        capa = re.search(r"LAYER\s+(\S+)\s*\(", blk)
        #  `FIXED` tambien, no solo `PLACED`: los dos de alimentacion los pone
        #  `place_pin` a mano y OpenROAD los escribe como FIXED. Mirando solo
        #  PLACED se saltaban en silencio los dos unicos que habia que vigilar.
        loc = re.search(r"(?:PLACED|FIXED|COVER)\s*\(\s*(-?\d+)\s+(-?\d+)\s*\)", blk)
        if not (m and capa and loc):
            continue
        out.setdefault(m.group(1), []).append(
            (capa.group(1), int(loc.group(1)) / units, int(loc.group(2)) / units))
    #  Que se hayan leido TODOS los que el DEF declara. Un puerto que la regex no
    #  entiende no da error: desaparece, y con el la comprobacion de que esta
    #  conectado. Asi se colaron `VDD` y `VSS`, que OpenROAD escribe como `FIXED`
    #  y no como `PLACED` por ponerlos `place_pin` a mano: 17 leidos de 19, y las
    #  55 nets salian «conectadas».
    leidos = sum(len(v) for v in out.values())
    if leidos != declarados:
        sys.exit(f"el DEF declara {declarados} pines y solo se han leido {leidos}"
                 f" — arregla read_def_ports antes de fiarte del resultado")
    return out


def place(rect, x, y, orient, size, origin=(0.0, 0.0)):
    """Rectangulo del LEF -> coordenadas absolutas, segun la orientacion.

    El `ORIGIN` va SUMADO, que es la convencion de OpenROAD: normaliza el master
    de modo que la esquina inferior izquierda de su caja caiga en (0, 0), y el
    punto del DEF es esa esquina. Aqui los bloques declaran `ORIGIN 1.26 0` y
    demas porque su geometria empieza en -1.26 —los taps de sustrato salen por la
    izquierda del origen—, asi que sin sumarlo se sondea 1.26 um a la izquierda
    del pin. Ver `def_to_gds.normalizar_origen`, que es donde se arregla el GDS.

    Y el espejo va DESPUES de normalizar, no antes: se refleja sobre la caja
    `[0, SIZE]`, que solo es la caja del macro una vez sumado el ORIGIN.
    """
    ox, oy = origin
    x0, y0, x1, y1 = rect[0] + ox, rect[1] + oy, rect[2] + ox, rect[3] + oy
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

    lefs, sizes, origenes = {}, {}, {}
    for p in (ROOT / "lef").glob("*.lef"):
        if p.name in ("vias.lef", "techlef_patched.tlef"):
            continue
        lefs[p.stem] = lef_pins(p)
        sizes[p.stem] = macro_size(p)
        origenes[p.stem] = lef_origin(p)

    #  `name` esta vacio en toda net que no lleve etiqueta, o sea en casi todas:
    #  usarlo como identidad metia dos nets distintas en el mismo saco. La que
    #  identifica de verdad es `expanded_name()`, que da `$1143`.
    abiertas = 0
    donde = {}                       # net extraida -> {nets del DEF que la tocan}
    puertos = read_def_ports(dpath)
    huerfanos = sorted(set(puertos) - set(nets))
    print(f"  {sum(len(v) for v in puertos.values())} puertos del top leidos del DEF"
          + (f"   OJO, sin net en el DEF: {huerfanos}" if huerfanos else ""))
    for net, pins in sorted(nets.items()):
        seen, missing = set(), []
        #  El pin del propio top va en la misma bolsa que los de macro: si cae en
        #  otra net extraida, el puerto esta flotando.
        for capa, px, py in puertos.get(net, []):
            n = l2n.probe_net(regions.get(capa, regions["Metal3"]),
                              kdb.DPoint(px, py))
            if not n:
                missing.append(f"PIN {net} ({capa})")
                continue
            seen.add(n.expanded_name())
            donde.setdefault(n.expanded_name(), set()).add(net)
        for iname, pin in pins:
            if iname not in inst:
                continue
            cell, x, y, orient = inst[iname]
            x, y = x / units, y / units
            for r in lefs.get(cell, {}).get(pin, []):
                a = place(r, x, y, orient, sizes[cell], origenes[cell])
                pt = kdb.DPoint((a[0] + a[2]) / 2, (a[1] + a[3]) / 2)
                n = l2n.probe_net(regions["Metal3"], pt)
                if not n:
                    missing.append(f"{iname}.{pin}")
                    continue
                seen.add(n.expanded_name())
                donde.setdefault(n.expanded_name(), set()).add(net)
        if len(seen) > 1 or missing:
            abiertas += 1
            print(f"  ABIERTA  {net:14s} {len(pins)} terminales -> {len(seen)} nets"
                  + (f", sin metal: {', '.join(missing)}" if missing else ""))

    cortos = sorted((v for v in donde.values() if len(v) > 1), key=len, reverse=True)
    for v in cortos:
        print(f"  CORTO    {len(v)} nets del DEF en la misma net extraida: "
              f"{', '.join(sorted(v))}")

    print(f"\n{len(nets) - abiertas}/{len(nets)} nets del DEF conectadas en el GDS"
          f"   |   {len(cortos)} corto(s)")
    return 1 if abiertas or cortos else 0


if __name__ == "__main__":
    sys.exit(main())
