#!/usr/bin/env python3
"""Netlist de referencia del top, listo para un LVS de fuera.

El chipathon corre su propio LVS leyendo `lvs_config.json` de la raiz del repo, y
ahi hay que decirle **contra que** compara el GDS. El netlist que exporta xschem
no vale tal cual: trae tres cosas que no son del circuito y que hacen que el
lector del deck no encuentre ni la celda.

* el `.subckt` de la celda de arriba viene **comentado** (`**.subckt GRADIENT_NAV
  ...`), que es como xschem exporta desde la CLI;
* fuentes de 0 V (`Vmeas net11 GND 0`) usadas como sonda de corriente:
  `Not a known element type: 'V'`. Una fuente de 0 V es electricamente un cable,
  asi que lo correcto no es tirarla sino **unir las dos nets**, que es lo que el
  layout tiene ahi;
* tarjetas de simulacion (`.save`, `.control`, `.tran`...).

Y ademas hay que aplanarlo: el layout del top es **una sola celda** (ver
`def_to_gds.py::flatten_all`), asi que la referencia tiene que serlo tambien.

Nada de esto se inventa aqui: es exactamente `lvs_klayout.prepare()`, que es el
parcheo con el que el LVS de KLayout ya compara este mismo top en local. Este
fichero solo lo deja escrito en un sitio estable y versionado para que el LVS de
fuera pueda apuntarle.

**Se regenera, no se edita.** El esquematico cambia y el netlist tiene que
cambiar con el; un netlist de referencia retocado a mano es una forma elegante de
hacer que el LVS mienta.

    python3 scripts/lvs_reference.py        # -> out/GRADIENT_NAV_lvs.spice
"""

from __future__ import annotations

import sys
from pathlib import Path

from lvs_klayout import ROOT, TARGETS, prepare

CELDA = "GRADIENT_NAV"
DESTINO = ROOT / "out" / f"{CELDA}_lvs.spice"


def main() -> int:
    _, ref = TARGETS[CELDA]
    if not ref.exists():
        sys.exit(f"no esta el netlist de xschem: {ref}\n"
                 f"  exportalo desde el esquematico antes de correr esto")

    limpio = prepare(ref, CELDA, ROOT / "work_lvs")
    DESTINO.parent.mkdir(parents=True, exist_ok=True)
    DESTINO.write_text(limpio.read_text())

    lineas = DESTINO.read_text().splitlines()
    cabecera = next((l for l in lineas if l.lower().startswith(".subckt")), "")
    if CELDA not in cabecera:
        sys.exit(f"el netlist generado no declara '.subckt {CELDA}' — "
                 f"algo cambio en xschem o en prepare()")
    dispositivos = sum(1 for l in lineas
                       if l[:1] in "MmXxCcRrDdQq" and not l.startswith("*"))
    print(f"  {DESTINO}")
    print(f"  {cabecera.split()[1]}: {len(cabecera.split()) - 2} puertos, "
          f"{dispositivos} dispositivos, {len(lineas)} lineas")
    print(f"  origen: {ref}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
