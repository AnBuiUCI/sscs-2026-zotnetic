#!/usr/bin/env python3
"""Reads what ngspice wrote, produces the tables and exports the named data.

    python3 analizar.py <carpeta_simulacion> <carpeta_datos>

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
    "X1", "Y1", "Z1", "X2", "Y2", "Z2", "X3", "Y3", "Z3", "X4", "Y4", "Z4",
    "SX1", "SY1", "SZ1", "SX2", "SY2", "SZ2",
    "SX3", "SY3", "SZ3", "SX4", "SY4", "SZ4",
    "XY1", "XZ1", "YZ1", "XY2", "XZ2", "YZ2",
    "XY3", "XZ3", "YZ3", "XY4", "XZ4", "YZ4",
    "S1P", "S1N", "S2P", "S2N", "S3P", "S3N",
    "P_EXC", "P_G1", "P_G2", "P_G3", "P_G4",
]
COL = {n: 2 * i + 1 for i, n in enumerate(VECTORES)}

CADENAS = [
    ("G1", "esquematico, OPAM 98 dB"),
    ("G2", "esquematico, OPAM_LIN"),
    ("G3", "layout v2 RC, OPAM"),
    ("G4", "layout v2 RC, OPAM_LIN_flat"),
]
BARRIDOS = [("ancho.txt", 0.02, "fondo de escala AMR, dR/R = 2 %"),
            ("fino.txt", 50e-6, "ventana fina, dR/R = 50 ppm")]

#: Logic threshold. The decoder outputs are rail to rail, so half
#: rail vale y no hace falta histeresis.
UMBRAL = 2.5


def tramos(cod, ang):
    """Contiguous runs with the same code, as (angle_start, angle_end, code)."""
    out, ini = [], 0
    for j in range(1, len(cod) + 1):
        if j == len(cod) or cod[j] != cod[ini]:
            out.append((ang[ini], ang[j - 1], cod[ini]))
            ini = j
    return out


def campo(ang, amp):
    """The field the stimulus imposed, recomputed here without looking at the sim."""
    return np.array([np.cos(np.radians(ang)),
                     np.cos(np.radians(ang - 120.0)),
                     np.cos(np.radians(ang + 120.0))]) * amp


def main() -> None:
    sim, dat = Path(sys.argv[1]), Path(sys.argv[2])
    resumen = {}

    for fich, amp, cuanto in BARRIDOS:
        d = np.loadtxt(sim / fich)
        ang = d[:, 0]
        v = lambda n: d[:, COL[n]]
        b = campo(ang, amp)
        menor, mayor = np.argmin(b, axis=0), np.argmax(b, axis=0)

        print(f"\n{'='*78}\n  {cuanto}   ({fich}, {len(ang)} puntos)\n{'='*78}")

        # ---------------------------------------------------------- el estimulo
        print("\n  el estimulo")
        for k, (p, n) in enumerate((("S1P", "S1N"), ("S2P", "S2N"), ("S3P", "S3N")), 1):
            cm, df = (v(p) + v(n)) / 2, v(p) - v(n)
            print(f"    puente {k}   Vcm {cm.min():.6f}..{cm.max():.6f} V"
                  f"    Vdiff {df.min()*1e3:+8.4f}..{df.max()*1e3:+8.4f} mV")
        print(f"    corriente de los tres puentes  {abs(v('P_EXC')).max()/5*1e6:6.3f} uA"
              f"   (esperado 15.000)")

        # ------------------------------------------------- las senales de dentro
        print("\n  intermediate signals   (swing along the sweep)")
        print(f"    {'cadena':32s} {'salida del amplificador':>26s}"
              f" {'salida del comparador':>24s}")
        for g, desc in CADENAS:
            sa = np.concatenate([v(f"S{e}{g[1]}") for e in "XYZ"])
            sc = np.concatenate([v(f"{p}{g[1]}") for p in ("XY", "XZ", "YZ")])
            print(f"    {g} {desc:29s} {sa.min():7.3f} .. {sa.max():6.3f} V"
                  f" {sc.min():9.3f} .. {sc.max():6.3f} V")

        # -------------------------------------------------- el mapa de sectores
        print("\n  el mapa de sectores")
        for g, desc in CADENAS:
            alto = np.array([v(f"{e}{g[1]}") > UMBRAL for e in "XYZ"])
            cod = ["".join("XYZ"[k] for k in range(3) if alto[k, j]) or "-"
                   for j in range(len(ang))]
            decidido = alto.sum(axis=0) == 1
            eje = np.where(decidido, alto.argmax(axis=0), -1)

            #  This decoder gives not the largest axis but the SMALLEST: it shows
            #  in its truth table (X = XY.XZ, i.e. SX below the other two) and is
            #  confirmed here by counting hits against both hypotheses.
            ac = {"EL MENOR": (eje[decidido] == menor[decidido]).mean() * 100,
                  "EL MAYOR": (eje[decidido] == mayor[decidido]).mean() * 100}
            criterio = max(ac, key=ac.get)
            ideal = menor if criterio == "EL MENOR" else mayor

            print(f"\n    {g}  {desc}")
            print(f"      saca {criterio}   acierto {ac[criterio]:5.1f} %"
                  f"   (la otra hipotesis {min(ac.values()):5.1f} %)")

            #  The sweep is a circle: the run starting at 0 and the one ending at
            #  360 are the same sector split by where the sweep starts.
            tr = tramos(cod, ang)
            if len(tr) > 1 and tr[0][2] == tr[-1][2]:
                a0, _, c = tr[-1]
                tr = [(a0 - 360.0, tr[0][1], c)] + tr[1:-1]
            for a0, a1, c in tr:
                marca = "" if len(c) == 1 else (
                    "   <<< sin decidir" if c == "-" else "   <<< AMBIGUO")
                print(f"      {a0:7.1f} .. {a1:6.1f} gr   {c:3s}"
                      f"   {a1-a0+0.5:5.1f} gr{marca}")

            #  Boundaries matched by CIRCULAR PROXIMITY and not by list order:
            #  both lists start where the sweep starts, not at the same sector,
            #  and matching them by index gave 120-degree errors
            #  con el mapa perfecto delante.
            #  Las fronteras ideales se saben de memoria y no se muestrean: tres
            #  cosenos a 120 grados se cruzan EXACTAMENTE en 0, 120 y 240 si lo
            #  que se decodifica es el menor, y en 60, 180 y 300 si es el mayor.
            #  Taking them from the argmin over the grid added half a step of bias.
            fr_id = np.array((0.0, 120.0, 240.0) if criterio == "EL MENOR"
                             else (60.0, 180.0, 300.0))
            fr_re = ang[np.where(np.diff(eje) != 0)[0]] + (ang[1] - ang[0]) / 2
            err = np.array([])
            if len(fr_re) and len(fr_id):
                dist = ((fr_re[:, None] - fr_id[None, :] + 180.0) % 360.0) - 180.0
                k = np.argmin(abs(dist), axis=1)
                err = dist[np.arange(len(fr_re)), k]
                print("      fronteras  " + "   ".join(
                    f"{r:6.2f} (ideal {fr_id[i]:6.2f}, error {e:+6.2f})"
                    for r, i, e in zip(fr_re, k, err)))
                print(f"      error de sector  maximo {abs(err).max():.2f} gr,"
                      f"  medio {abs(err).mean():.2f} gr")
            mal = (~decidido).sum()
            if mal:
                print(f"      {mal} de {len(ang)} puntos ({mal/len(ang)*100:.1f} %)"
                      " with not one active output")
            resumen[(fich, g)] = (ac[criterio], abs(err).max() if len(err) else float("nan"),
                                  abs(v(f"P_{g}")).max() * 1e3)

        # ----------------------------------------------- esquematico contra layout
        print("\n  schematic against layout, the comparison the bench asked for")
        print(f"    {'pareja':34s} {'acierto':>16s} {'error de sector':>18s} {'consumo':>16s}")
        for a, c, que in (("G1", "G3", "OPAM      "), ("G2", "G4", "OPAM_LIN  ")):
            pa, pc = resumen[(fich, a)], resumen[(fich, c)]
            print(f"    {que} {a} contra {c:18s} "
                  f"{pa[0]:6.1f} -> {pc[0]:5.1f} % "
                  f"{pa[1]:8.2f} -> {pc[1]:5.2f} gr "
                  f"{pa[2]:7.3f} -> {pc[2]:6.3f} mW")

        # ------------------------------------------------------ exportar el dato
        cab = ["angle_deg", "bx", "by", "bz"] + VECTORES
        tabla = np.column_stack([ang] + list(b) + [v(n) for n in VECTORES])
        salida = dat / fich.replace(".txt", ".csv")
        np.savetxt(salida, tabla, delimiter=",", header=",".join(cab),
                   comments="", fmt="%.6g")
        print(f"\n  datos -> {salida}   ({tabla.shape[0]} filas x {tabla.shape[1]} columnas)")


if __name__ == "__main__":
    main()
