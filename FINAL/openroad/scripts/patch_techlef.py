#!/usr/bin/env python3
"""Copia del techlef con el recuadro de las vias cuadrado.

Las `VIARULE Via*_GEN_*` del PDK dan `ENCLOSURE 0.060 0.010`: alrededor de un
corte de 0.26 sale un pad de **0.38 x 0.28**. Eso trae dos problemas al ruteo del
top, y los dos son de geometria, no de conectividad:

  * suelto, el pad mide 0.1064 um2 y `Mn.3` pide 0.1444  -> `M3.3`;
  * contra un cable, la diferencia entre 0.38 y 0.28 deja un escalon de 0.05
    -> `M3.1`, y roces de centesimas en `M3.2a` / `M2.2a`.

Con 0.060 en los dos ejes el pad queda en 0.38 x 0.38 = 0.1444 clavado: cumple el
area por si solo y no hace escalon contra un cable de 0.38 (ver la regla no
estandar `ANCHO` en route_top.tcl). El minimo del PDK es 0.010 en el eje corto y
aqui se sube a 0.060: mas recuadro nunca incumple una regla de enclosure.

    python3 scripts/patch_techlef.py   ->  lef/techlef_patched.tlef
"""

from __future__ import annotations

import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
SRC = Path("/foss/pdks/gf180mcuD/libs.ref/gf180mcu_fd_sc_mcu9t5v0/techlef/"
           "gf180mcu_fd_sc_mcu9t5v0__nom.tlef")
DST = ROOT / "lef" / "techlef_patched.tlef"


#: Las capas cuyo pad se cuadra, con su lado minimo. Metal5 se deja: su area
#: minima es 0.5625 y ningun pad de via se le acerca, asi que agrandarlo solo
#: apretaria contra las placas de los MIM.
_SQUARE = {"Metal1": 0.19, "Metal2": 0.19, "Metal3": 0.19, "Metal4": 0.19}


#: Capas por las que el router tiende senal en el top (ver `route_top.tcl`).
_MARGEN = {"Metal2", "Metal3", "Metal4"}


def main() -> int:
    #  Ojo: una capa de RUTEO se declara `LAYER Metal3` (sin `;`) y una capa
    #  dentro de una VIARULE se declara ` LAYER Metal3 ;` (con `;`). Son dos
    #  cosas distintas y hacen falta las dos.
    out, in_rule, in_via, layer, rlayer, n = [], False, False, None, None, 0
    for line in SRC.read_text().splitlines():
        if re.match(r"\s*VIARULE (Via\d_GEN_\S+) GENERATE", line):
            in_rule = True
        elif re.match(r"\s*VIA (Via\d\S*)\s", line):
            in_via = True
        elif re.match(r"\s*END Via", line):
            in_rule = in_via = False
        m = re.match(r"\s*LAYER (\S+) ;", line)
        if m:
            layer = m.group(1)
        if in_rule:
            m = re.match(r"(\s*ENCLOSURE\s+)([\d.]+)\s+([\d.]+)\s*;", line)
            if m:
                a, b = float(m.group(2)), float(m.group(3))
                if a != b:
                    big = max(a, b)
                    line = f"{m.group(1)}{big:.3f} {big:.3f} ;"
                    n += 1
        elif in_via and layer in _SQUARE:
            # Los `VIA ... DEFAULT` fijos son los que el router usa de verdad; las
            # reglas GENERATE solo entran cuando no hay una fija que sirva.
            m = re.match(r"(\s*RECT\s+)([-\d.]+) ([-\d.]+) ([-\d.]+) ([-\d.]+)\s*;", line)
            if m:
                half = _SQUARE[layer]
                if abs(float(m.group(4)) - half) > 1e-9 or \
                   abs(float(m.group(5)) - half) > 1e-9:
                    line = (f"{m.group(1)}{-half:.3f} {-half:.3f} "
                            f"{half:.3f} {half:.3f} ;")
                    n += 1
        #  Un pelo de margen sobre el valor de firma en las capas por las que
        #  rutea el top. El deck de KLayout mide `Mn.2a` en euclidea, esquina con
        #  esquina; el router mide por proyeccion, asi que dejaba exactamente
        #  0.280 en ortogonal y en una esquina en diagonal el deck veia menos.
        #  Con 0.300 cualquier separacion euclidea es >= 0.300 > 0.280 y el
        #  problema desaparece por construccion. Cuesta un 7% de holgura de
        #  ruteo, que sobra.
        m = re.match(r"LAYER (\S+)\s*$", line)
        if m:
            rlayer = m.group(1)
        if rlayer in _MARGEN:
            m = re.match(r"(\s*SPACING\s+)0?\.280\s*;(.*)$", line)
            if m:
                line = f"{m.group(1)}0.300 ;{m.group(2)}"
                n += 1
        out.append(line)
    #  Y una seccion SPACING SAMENET, que el techlef del PDK no trae.
    #
    #  Sin ella el router da por buenas dos formas de la MISMA net separadas por
    #  centesimas: para el estan conectadas por otro sitio, asi que no hay nada
    #  que comprobar. El deck de firma no opina lo mismo — `Mn.2a` mide la
    #  separacion entre poligonos disjuntos, sean de la net que sean —, y de ahi
    #  salian las ultimas `M3.2a`/`M2.2a` del top, todas de 0.03 a 0.14 um entre
    #  un cable y el pad del puerto en el que ese mismo cable acaba.
    same = ["", "SPACING"]
    for layer, val in (("Metal1", 0.23), ("Metal2", 0.28), ("Metal3", 0.28),
                       ("Metal4", 0.28), ("Metal5", 0.30)):
        same.append(f"  SAMENET {layer} {layer} {val:.3f} ;")
    same += ["END SPACING", ""]
    tail = out.index("END LIBRARY") if "END LIBRARY" in out else len(out)
    out = out[:tail] + same + out[tail:]

    DST.parent.mkdir(parents=True, exist_ok=True)
    DST.write_text("\n".join(out) + "\n")
    print(f"{DST}\n  {n} recuadros de via hechos cuadrados")
    return 0


if __name__ == "__main__":
    sys.exit(main())
