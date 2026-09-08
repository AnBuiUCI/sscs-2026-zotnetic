#!/usr/bin/env python3
"""Reads what ngspice wrote, produces the tables and exports the named data.

    python3 analizar_nav2.py <carpeta_simulacion> <carpeta_datos>

`wrdata` writes no headers: it stores an (x, y) pair per vector, so the file
has twice as many columns as vectors and the only way to know which column is
which is the VECTORES record below. It is the source of truth and has to be
kept in step with the .control block of the .sch.
"""

from __future__ import annotations

import sys
from pathlib import Path

import numpy as np

#: The EXACT order of the .sch `wrdata`. Touch one and you must touch the other.
VECTORES = [
    "X", "Y", "Z", "XP", "XN", "YP", "YN", "ZP", "ZN",
    "Xr", "Yr", "Zr", "XPr", "XNr", "YPr", "YNr", "ZPr", "ZNr",
    "X1", "X2", "X3", "X4", "Y1", "Y2", "Y3", "Y4", "Z1", "Z2", "Z3", "Z4",
    "X1r", "X2r", "X3r", "X4r", "Y1r", "Y2r", "Y3r", "Y4r",
    "Z1r", "Z2r", "Z3r", "Z4r",
    "S1P", "S1N", "S2P", "S2N", "S3P", "S3N", "S4P", "S4N",
    "P_EXC", "P_ESQ", "P_LAY",
]
COL = {n: 2 * i + 1 for i, n in enumerate(VECTORES)}

BARRIDOS = [("ancho.txt", 0.02, "fondo de escala AMR, dR/R = 2 %"),
            ("fino.txt", 50e-6, "ventana fina, dR/R = 50 ppm")]

#: The navigator outputs, each with its layout counterpart.
#:
#: **X, Y and Z are ANALOGUE**, not logic. They are the output of the three
#: weight blocks averaging the four chains: measured, they move over
#: 2.18 .. 3.04 V, not rail to rail. Thresholding them would invent bits that
#: are not there, so they are compared as voltages.
ANALOGICAS = ["X", "Y", "Z"]
#: These ones are logic: they come out of `COMP_OUT`'s inverter pair.
LOGICAS = ["XP", "XN", "YP", "YN", "ZP", "ZN"]
#: And the twelve intermediate ones, each chain's output before the weights.
CADENAS = [f"{e}{k}" for e in "XYZ" for k in (1, 2, 3, 4)]

#: The four sensors in space, centred on +-1 (see the ESTIMULO block
#: del .sch). Tetraedro regular inscrito en el cubo: S3 y S4 en esquinas opuestas
#: of the lower z plane, S1 and S2 on the opposite two of the upper one.
POSICION = {"S1": (-1, +1, +1), "S2": (+1, -1, +1),
            "S3": (-1, -1, -1), "S4": (+1, +1, -1)}

#: Logic threshold. The decoder and weight outputs are rail to rail, so half a
#: rail will do and no hysteresis is needed.
UMBRAL = 2.5


def leer(path: Path) -> np.ndarray:
    d = np.loadtxt(path)
    if d.shape[1] < 2 * len(VECTORES):
        sys.exit(f"{path.name}: {d.shape[1]} columnas, esperaba {2 * len(VECTORES)}. "
                 f"El .control y VECTORES se han separado.")
    return d


def tramos(bits, ang):
    """Contiguous runs with the same value, as (angle_start, angle_end, value)."""
    out, ini = [], 0
    for j in range(1, len(bits) + 1):
        if j == len(bits) or bits[j] != bits[ini]:
            out.append((ang[ini], ang[j - 1], bits[ini]))
            ini = j
    return out


def main() -> int:
    sim, dat = Path(sys.argv[1]), Path(sys.argv[2])
    dat.mkdir(parents=True, exist_ok=True)

    for fichero, amp, titulo in BARRIDOS:
        p = sim / fichero
        if not p.exists():
            print(f"  falta {p}"); continue
        d = leer(p)
        ang = d[:, 0]
        v = {n: d[:, COL[n]] for n in VECTORES}

        print(f"\n{'=' * 74}\n  {titulo}   ({len(ang)} puntos de {ang[0]:.0f} a {ang[-1]:.0f} grados)\n{'=' * 74}")

        #  --- la geometria: se recupera el gradiente de las cuatro lecturas ----
        #  The four position vectors are orthogonal component by component, so
        #  the gradient comes from a signed sum with no
        #  resolver ningun sistema. Es la comprobacion de que la disposicion de
        #  the sensors does what is asked of it: from four numbers come the three
        #  diferencias en x, y, z.
        b = {k: (v[f"{k}P"] - v[f"{k}N"]) / 5.0 for k in POSICION}
        g = {eje: sum(POSICION[k][i] * b[k] for k in POSICION) / 4.0
             for i, eje in enumerate("xyz")}
        #  Y el angulo reconstruido contra el que se pidio. En el plano X-Z el
        #  gradient goes (cos, 0, sin), so atan2(gz, gx) must return
        #  el barrido.
        rec = np.degrees(np.arctan2(g["z"], g["x"])) % 360.0
        err = (rec - ang + 180.0) % 360.0 - 180.0
        print(f"  geometria  gradiente recuperado de las cuatro lecturas:")
        print(f"             |gx| max {np.abs(g['x']).max() * 1000:.4f} mV/lado   "
              f"|gy| max {np.abs(g['y']).max() * 1e6:.4f} uV/lado   "
              f"|gz| max {np.abs(g['z']).max() * 1000:.4f} mV/lado")
        print(f"             angulo reconstruido contra el barrido: "
              f"error |max| {np.abs(err).max():.4f} grados, rms {np.sqrt(np.mean(err ** 2)):.4f}")

        #  --- the stimulus, before anything else -------------------------------
        #  If the common mode moves, the bridge model is wrong and everything
        #  lo demas sobra.
        vcm = np.concatenate([(v[f"S{k}P"] + v[f"S{k}N"]) / 2 for k in (1, 2, 3, 4)])
        dif = [np.ptp(v[f"S{k}P"] - v[f"S{k}N"]) / 2 for k in (1, 2, 3, 4)]
        print(f"  sensores   Vcm {vcm.min():.6f} .. {vcm.max():.6f} V   "
              f"(must be constant)")
        print(f"             Vdiff maximo por sensor  " +
              "  ".join(f"S{k}={x * 1000:+.4f} mV" for k, x in enumerate(dif, 1)))
        #  In absolute value: `i(V)` is the current ENTERING the positive
        #  positivo, o sea negativa cuando la fuente entrega.
        print(f"  consumo    puentes {abs(v['P_EXC'].mean()) * 1e6:8.1f} uW   "
              f"esquematico {abs(v['P_ESQ'].mean()) * 1e3:8.3f} mW   "
              f"layout RC {abs(v['P_LAY'].mean()) * 1e3:8.3f} mW")

        #  --- what the bench measures: do the two versions agree? -------------
        paso = ang[1] - ang[0]
        print(f"\n  the three weight outputs, compared as VOLTAGES:")
        print(f"  {'salida':7s} {'rango esquematico':>20s} {'rango layout RC':>18s} "
              f"{'|dif| max':>10s} {'rms':>8s} {'grados de canto':>16s}")
        for n in ANALOGICAS:
            e = v[n] - v[n + "r"]
            #  The weight output is a staircase: it averages four logic levels.
            #  Where the two versions agree the difference is millivolts; where
            #  one has already stepped and the other has not, it is the whole
            #  step. That is why the maximum alone would mislead: what really
            #  measures the difference between schematic and layout is
            #  CUANTOS GRADOS del barrido caen en ese canto.
            canto = np.sum(np.abs(e) > 0.1) * (ang[1] - ang[0])
            print(f"  {n:7s} {v[n].min():8.4f}..{v[n].max():<8.4f} "
                  f"{v[n + 'r'].min():8.4f}..{v[n + 'r'].max():<8.4f} "
                  f"{np.abs(e).max() * 1000:7.1f} mV {np.sqrt(np.mean(e ** 2)) * 1000:5.1f} mV "
                  f"{canto:13.2f} de 360")

        print(f"\n  las seis salidas logicas:")
        print(f"  {'salida':7s} {'acuerdo':>9s}   {'grados en desacuerdo':>21s}   sectores a 1 (esquematico)")
        for n in LOGICAS:
            a = v[n] > UMBRAL
            b = v[n + "r"] > UMBRAL
            igual = 100.0 * np.mean(a == b)
            grados = np.sum(a != b) * paso
            secs = [f"{i:.2f}-{f:.2f}" for i, f, val in tramos(a, ang) if val]
            print(f"  {n:7s} {igual:8.2f}%   {grados:19.2f}   "
                  + (" ".join(secs[:4]) + (" ..." if len(secs) > 4 else "")
                     if secs else "(siempre a 0)"))
        clavadas = [n for n in LOGICAS if np.ptp(v[n]) < 0.5]
        if clavadas:
            #  A logic output that does not move over the WHOLE sweep is not a
            #  acuerdo: es que no lleva informacion. Pasa igual en el
            #  schematic and in the layout, so no LVS and no DRC can see it --
            #  only this can.
            ejes = sorted({n[0] for n in clavadas})
            print(f"    CLAVADAS EN TODO EL BARRIDO: {' '.join(clavadas)}."
                  f"  No es del banco: el par de inversores de COMP_OUT no")
            for e in ejes:
                print(f"    switches in the range where the weight output lives "
                      f"{e} ({v[e].min():.3f} .. {v[e].max():.3f} V).")

        #  --- and the twelve chain outputs, before the weights ----------------
        peor = min(((100.0 * np.mean((v[n] > UMBRAL) == (v[n + "r"] > UMBRAL)), n)
                    for n in CADENAS))
        acu = [100.0 * np.mean((v[n] > UMBRAL) == (v[n + "r"] > UMBRAL)) for n in CADENAS]
        print(f"\n  the 12 chain outputs (before the weights): "
              f"acuerdo medio {np.mean(acu):.2f} %, peor {peor[0]:.2f} % en {peor[1]}")

        #  --- exportar con nombres --------------------------------------------
        destino = dat / (fichero.replace(".txt", "") + "_nav2.csv")
        with destino.open("w") as f:
            f.write("angulo," + ",".join(VECTORES) + "\n")
            for i in range(len(ang)):
                f.write(f"{ang[i]:.4f}," +
                        ",".join(f"{v[n][i]:.6g}" for n in VECTORES) + "\n")
        print(f"\n  datos -> {destino}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
