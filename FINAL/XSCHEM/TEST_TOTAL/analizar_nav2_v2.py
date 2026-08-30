#!/usr/bin/env python3
"""Today's navigator against the XSCHEM_v2 one, on the same stimulus.

    python3 analizar_nav2_v2.py <carpeta_simulacion> <carpeta_datos>

`wrdata` writes no headers, so the VECTORES record below is the only way to
know which column is which. It has to be kept in step with the
bloque .control de test_NAV2_v2.sch.
"""

from __future__ import annotations

import sys
from pathlib import Path

import numpy as np

SAL = ["X", "Y", "Z", "XP", "XN", "YP", "YN", "ZP", "ZN"]
VECTORES = (SAL + [s + "v" for s in SAL]
            + [f"h_{e}{k}" for e in "XYZ" for k in (1, 2, 3, 4)]
            + [f"v_{e}{k}" for e in "XYZ" for k in (1, 2, 3, 4)]
            + [f"S{k}{s}" for k in (1, 2, 3, 4) for s in "PN"]
            + ["VREF", "P_EXC", "P_HOY", "P_V2"])
COL = {n: 2 * i + 1 for i, n in enumerate(VECTORES)}
BARRIDOS = [("ancho.txt", "fondo de escala AMR, dR/R = 2 %"),
            ("fino.txt", "ventana fina, dR/R = 50 ppm")]
UMBRAL = 2.5


def main() -> int:
    sim, dat = Path(sys.argv[1]), Path(sys.argv[2])
    dat.mkdir(parents=True, exist_ok=True)
    for fichero, titulo in BARRIDOS:
        p = sim / fichero
        if not p.exists():
            print(f"  falta {p}")
            continue
        d = np.loadtxt(p)
        if d.shape[1] < 2 * len(VECTORES):
            sys.exit(f"{fichero}: {d.shape[1]} columnas, esperaba {2 * len(VECTORES)}")
        ang = d[:, 0]
        v = {n: d[:, COL[n]] for n in VECTORES}
        print(f"\n{'=' * 78}\n  {titulo}   ({len(ang)} puntos)\n{'=' * 78}")

        #  Each version's votes come from ITS four chains: the sensor
        #  allocation is different, so they are not the same numbers.
        votos = {v_: np.stack([sum((v[f"{v_}_{e}{k}"] > UMBRAL).astype(int)
                                   for k in (1, 2, 3, 4)) for e in "XYZ"])
                 for v_ in ("h", "v")}
        print(f"  referencia del comparador de v2: {v['VREF'].min():.4f} .. "
              f"{v['VREF'].max():.4f} V   (los escalones a separar: 2.178 y 2.579)")
        print(f"  consumo: puentes {abs(v['P_EXC'].mean()) * 1e6:.1f} uW   "
              f"hoy {abs(v['P_HOY'].mean()) * 1e3:.3f} mW   "
              f"v2 {abs(v['P_V2'].mean()) * 1e3:.3f} mW")

        for i, e in enumerate("XYZ"):
            gh = np.argmax(votos["h"], 0) == i
            gv = np.argmax(votos["v"], 0) == i
            print(f"\n  --- eje {e}")
            for tag, sufijo, gana, vt in (("hoy", "", gh, votos["h"]),
                                          ("v2 ", "v", gv, votos["v"])):
                pos = v[f"{e}P{sufijo}"] > UMBRAL
                neg = v[f"{e}N{sufijo}"] > UMBRAL
                print(f"     {tag}: {e}P alto {100 * pos.mean():5.1f} %   "
                      f"{e}N alto {100 * neg.mean():5.1f} %   "
                      f"deberia ganar {100 * gana.mean():5.1f} %")
                print(f"          {e}P acierta 'este eje gana' en "
                      f"{100 * np.mean(pos == gana):5.1f} %   "
                      f"votos {vt[i].min()}..{vt[i].max()}")

        destino = dat / (fichero.replace(".txt", "") + "_nav2_v2.csv")
        with destino.open("w") as f:
            f.write("angulo," + ",".join(VECTORES) + "\n")
            for j in range(len(ang)):
                f.write(f"{ang[j]:.4f}," + ",".join(f"{v[n][j]:.6g}" for n in VECTORES) + "\n")
        print(f"\n  datos -> {destino}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
