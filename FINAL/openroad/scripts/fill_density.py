#!/usr/bin/env python3
"""Relleno de densidad para el GDS del top.

El DRC de firma no comprueba densidad salvo que se le pidan las reglas aparte
(`--density`), y cuando se le piden el top las incumple todas: son de MINIMO, o
sea que falta metal. Este paso lo anade **despues** de que OpenROAD haya
producido el GDS, sin tocar nada del flujo de arriba.

Tres cosas del PDK definen como funciona esto:

* **El deck suma el dummy.** `comp = comp_drawn + comp_dummy`, y lo mismo por
  capa. El dummy va en el **datatype 4** del mismo numero de capa.
* **El DRC y el LVS SI ven el dummy.** `layers_def.drc` hace
  `metal1 = metal1_drawn + metal1_dummy`, y `layers_definitions.lvs` lo mismo. Lo
  que se define como `get_polygons(34, 0)` es la capa *drawn*, no la fisica. O sea
  que el relleno **tiene que cumplir el DRC entero** y aparece en la extraccion
  como metal flotante. Por eso aqui solo se ponen cuadrados ENTEROS dentro de la
  zona despejada: recortarlos contra la zona libre crea cuellos y esquirlas, y de
  ahi salian 6214 violaciones de ancho, area y espaciado.
* **El PDK no trae generador de relleno.** Ni en `libs.tech/klayout` ni en
  `librelane`. De ahi este fichero.

`MT.3` no mide la capa `metaltop`: para el stack de 5 metales el deck hace
`top_metal = metal5`, asi que `MT.3` y `M5.4` miran lo mismo.

    python3 scripts/fill_density.py             # canales; mide y reporta
    python3 scripts/fill_density.py --sobre-macros   # ademas, encima de los macros
"""

from __future__ import annotations

import re
import sys
from pathlib import Path

import klayout.db as kdb

ROOT = Path(__file__).resolve().parent.parent
GDS_IN = ROOT / "out/GRADIENT_NAV.gds"
GDS_OUT = ROOT / "out/GRADIENT_NAV_filled.gds"
DEF = ROOT / "out/GRADIENT_NAV_routed.def"

#: (nombre, capa GDS, minimo en %, separacion al metal real, separacion entre
#: cuadrados de relleno, lado minimo del cuadrado, regla).
#:
#: Poly2 va con numeros muy distintos porque **magic si tiene reglas de relleno**
#: aunque no tenga de densidad, y KLayout no las comprueba: `DPF.1` pide 5.6 um de
#: ancho para el relleno de poly, `DPF.2a` 2.4 um entre formas de relleno y `DPF.5`
#: **5 um de separacion al poly de verdad**. Con cuadrados de 0.4 magic sacaba
#: 134 488 violaciones sobre un fichero que KLayout daba limpio.
#: El dummy va en el datatype 4 del mismo numero, que es lo que suman los decks.
#:
#: Metal5 va aparte: para el stack de 5 metales el deck hace `top_metal = metal5`,
#: asi que le aplican las reglas `MT.*` y no las `M5.*` — 0.36 de ancho minimo,
#: 0.46 de espaciado y 0.5625 um2 de area (un cuadrado de 0.75 justo). Se usa 0.80
#: de lado para no depender del redondeo.
CAPAS = [
    ("COMP",   22, 25.0, 0.40, 0.40, 1.00, "DCF.1b"),
    ("Poly2",  30, 14.0, 5.00, 2.40, 5.60, "PL.8 / DPF.1 / DPF.2a / DPF.5"),
    ("Metal1", 34, 30.0, 0.23, 0.23, 0.40, "M1.4"),
    ("Metal2", 36, 30.0, 0.28, 0.28, 0.40, "M2.4"),
    ("Metal3", 42, 30.0, 0.28, 0.28, 0.40, "M3.4"),
    ("Metal4", 46, 30.0, 0.28, 0.28, 0.40, "M4.4"),
    ("Metal5", 81, 30.0, 0.46, 0.46, 0.80, "M5.4 / MT.3 / MT.1"),
]

#: Marcadores del MIM. `MIMTM.1` pide 1.2 um de la placa a cualquier otro metal4,
#: y la regla no perdona por ser relleno.
CAP_MK = (117, 5)
MIM_CLEAR = 1.2

#: Cuanto se deja crecer el cuadrado buscando densidad, en multiplos de su lado
#: minimo. Va relativo y no absoluto porque los lados minimos son muy distintos
#: entre capas: 0.40 en metal y 5.60 en el relleno de poly por `DPF.1`. Con un
#: tope absoluto el bucle del poly no llegaba a ejecutarse ni una vez.
LADO_FACTOR = 3.0
PASO_HOLGURA = 0.05


def region(cell, layer_index, dbu: float) -> kdb.Region:
    """Todas las formas de una capa, planas y en rejilla de 1 nm."""
    out = kdb.Region()
    it = cell.begin_shapes_rec(layer_index)
    while not it.at_end():
        out.insert(it.shape().dpolygon.transformed(it.dtrans()).to_itype(1e-3))
        it.next()
    out.merge()
    return out


def huella_macros() -> kdb.Region:
    """La huella de los 31 macros, leida de la colocacion del DEF."""
    texto = DEF.read_text()
    unidades = float(re.search(r"UNITS DISTANCE MICRONS (\d+)", texto).group(1))
    tam = {}
    for lef in (ROOT / "lef").glob("*.lef"):
        if lef.name in ("vias.lef", "techlef_patched.tlef"):
            continue
        m = re.search(r"\s*SIZE ([\d.]+) BY ([\d.]+) ;", lef.read_text())
        if m:
            tam[lef.stem] = (float(m.group(1)), float(m.group(2)))
    out = kdb.Region()
    bloque = texto[texto.index("COMPONENTS"):texto.index("END COMPONENTS")]
    for m in re.finditer(r"-\s+(\S+)\s+(\S+)\s*\+\s+\S+\s+"
                         r"\(\s*(-?\d+)\s+(-?\d+)\s*\)\s+(\w+)", bloque):
        celda = m.group(2)
        if celda not in tam:
            continue
        x, y = int(m.group(3)) / unidades, int(m.group(4)) / unidades
        w, h = tam[celda]
        out.insert(kdb.DBox(x, y, x + w, y + h).to_itype(1e-3))
    out.merge()
    return out


def rejilla(zona: kdb.Region, lado: float, paso: float, die: kdb.DBox) -> kdb.Region:
    """Cuadrados de `lado` cada `paso`, **enteros** dentro de `zona`.

    Nada de recortar contra la zona: un cuadrado o cabe entero o no se pone. Asi
    el ancho minimo y el area minima se cumplen por construccion, que es lo que
    fallaba antes — recortando salian cuellos de 0.1 um y trozos por debajo del
    area minima, y el DRC cantaba miles de `M*.1` y `M*.3`.
    """
    cuadros = kdb.Region()
    y = die.bottom + paso / 2
    while y + lado <= die.top:
        x = die.left + paso / 2
        while x + lado <= die.right:
            cuadros.insert(kdb.DBox(x, y, x + lado, y + lado).to_itype(1e-3))
            x += paso
        y += paso
    return cuadros.inside(zona)


def main() -> int:
    sobre_macros = "--sobre-macros" in sys.argv
    if not GDS_IN.exists():
        sys.exit(f"no hay {GDS_IN} — corre antes `make top`")

    layout = kdb.Layout()
    layout.read(str(GDS_IN))
    top = layout.top_cell()
    die = top.dbbox()
    area_die = die.width() * die.height()

    macros = huella_macros()
    mim = region(top, layout.layer(*CAP_MK), layout.dbu)
    prohibido_mim = mim.sized(int(MIM_CLEAR * 1000))

    libre_total = kdb.Region(die.to_itype(1e-3)) - macros
    print(f"  die {die.width():.2f} x {die.height():.2f} = {area_die:,.0f} um2   "
          f"macros {macros.area()/1e6:,.0f}   libre {libre_total.area()/1e6:,.0f}")
    print(f"  relleno {'en canales Y sobre los macros' if sobre_macros else 'solo en canales'}\n")
    print(f"    {'capa':7s} {'regla':12s} {'antes':>7s} {'despues':>8s} {'pide':>5s}   estado")

    corto = []
    for nombre, gl, minimo, guarda, sep_relleno, lado_min, regla in CAPAS:
        idx = layout.layer(gl, 0)
        real = region(top, idx, layout.dbu)
        antes = 100 * real.area() / 1e6 / area_die

        #  Zona donde SI se puede poner relleno: el die menos la propia geometria
        #  engordada por su espaciado, menos los macros (salvo que se pidan), y
        #  siempre menos la guarda de los MIM.
        zona = kdb.Region(die.to_itype(1e-3)) - real.sized(int(guarda * 1000))
        if not sobre_macros:
            zona -= macros
        zona -= prohibido_mim
        zona.merge()

        #  Se sube el lado hasta cumplir. El paso va atado al lado, asi que un
        #  cuadrado mas grande es mas cobertura y la separacion entre vecinos se
        #  mantiene siempre en el espaciado de la capa.
        puesto = kdb.Region()
        lado = lado_min
        while lado <= lado_min * LADO_FACTOR + 1e-9:
            paso = lado + sep_relleno + PASO_HOLGURA
            puesto = rejilla(zona, lado, paso, die)
            if 100 * (real.area() + puesto.area()) / 1e6 / area_die >= minimo:
                break
            lado += 0.20

        capa_dummy = layout.layer(gl, 4)
        for p in puesto.each():
            top.shapes(capa_dummy).insert(p.transformed(
                kdb.ICplxTrans(0.001 / layout.dbu)))

        despues = 100 * (real.area() + puesto.area()) / 1e6 / area_die
        ok = despues >= minimo
        if not ok:
            corto.append((nombre, regla, despues, minimo))
        print(f"    {nombre:7s} {regla:12s} {antes:6.2f}% {despues:7.2f}% "
              f"{minimo:4.0f}%   {'cumple' if ok else 'SIGUE CORTA'}")

    GDS_OUT.parent.mkdir(parents=True, exist_ok=True)
    layout.write(str(GDS_OUT))
    print(f"\n  {GDS_OUT}")

    if corto:
        print(f"\n  {len(corto)} capa(s) sin llegar al minimo:")
        for nombre, regla, d, m in corto:
            print(f"    {nombre} ({regla}): {d:.2f}% de {m:.0f}%")
        if not sobre_macros:
            print("  Con --sobre-macros se rellena tambien encima de los macros.")
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
