#!/usr/bin/env python3
"""Convierte las violaciones del deck de firma en obstrucciones para el router.

Las que quedan en el top no tienen ya causa comun: son sitios sueltos donde el
router deja el cable a centesimas del metal de un macro. Subir margenes globales
—el crecimiento de las obstrucciones, el espaciado del techlef— cerro las que si
tenian patron, pero de ahi para abajo solo baraja: cada tanda cambia de sitio sin
bajar de la decena.

Asi que se le dice al router exactamente donde no puede volver a poner metal.
Es un lazo dirigido por DRC, entero dentro de OpenROAD:

    ruteo -> GDS -> DRC de firma -> este script -> obstrucciones -> ruteo

El fichero es acumulativo a proposito: lo prohibido en una vuelta sigue estandolo
en la siguiente, que es lo que hace que el lazo converja en vez de oscilar.

    python3 scripts/drc_blockages.py        # anade lo de la ultima tanda de DRC
    python3 scripts/drc_blockages.py --reset   # empieza de cero
"""

from __future__ import annotations

import glob
import re
import sys
import xml.etree.ElementTree as ET
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
RUN = ROOT / "out" / "drc_GRADIENT_NAV"
OUT = ROOT / "out" / "drc_blockages.txt"

#: Margen alrededor del sitio marcado. El hueco que el deck mide es de decimas de
#: micra; con menos de esto el router vuelve a colarse por el mismo sitio con un
#: desplazamiento de una pista.
_HALO = 0.10

#: De que regla sale cada capa. Solo las de senal: la alimentacion la pone
#: `pdngen` y no la rutea el router.
_LAYER = {"M2": "Metal2", "M3": "Metal3", "M4": "Metal4"}


def boxes():
    for f in glob.glob(str(RUN / "*.lyrdb")):
        for item in ET.parse(f).getroot().iter("item"):
            cat = (item.findtext("category") or "").strip("'")
            layer = _LAYER.get(cat.split(".")[0])
            if layer is None:
                continue
            for v in item.iter("value"):
                n = [float(z) for z in re.findall(r"-?\d+\.?\d*", v.text or "")]
                if len(n) < 4:
                    continue
                xs, ys = n[0::2], n[1::2]
                yield (layer, min(xs) - _HALO, min(ys) - _HALO,
                       max(xs) + _HALO, max(ys) + _HALO)
                break


def main() -> int:
    if "--reset" in sys.argv:
        OUT.write_text("")
        print(f"{OUT} vaciado")
        return 0
    old = OUT.read_text().splitlines() if OUT.exists() else []
    seen = set(old)
    new = [f"{l} {a:.4f} {b:.4f} {c:.4f} {d:.4f}" for l, a, b, c, d in boxes()]
    add = [s for s in new if s not in seen]
    OUT.parent.mkdir(parents=True, exist_ok=True)
    OUT.write_text("\n".join(old + add) + ("\n" if old + add else ""))
    print(f"{OUT}: {len(add)} nuevas, {len(old) + len(add)} en total")
    return 0


if __name__ == "__main__":
    sys.exit(main())
