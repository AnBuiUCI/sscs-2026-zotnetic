#!/usr/bin/env python3
"""Lee lo que escribio ngspice, saca las tablas y exporta los datos con nombres.

    python3 analizar.py <carpeta_simulacion> <carpeta_datos>

`wrdata` no escribe cabeceras: guarda un par (x, y) por vector, asi que el
fichero tiene el doble de columnas que vectores y la unica forma de saber que
columna es que es el registro VECTORES de aqui abajo. Es la fuente de verdad y
hay que mantenerlo a la par que el bloque .control del .sch.
"""

from __future__ import annotations

import sys
from pathlib import Path

import numpy as np

#: El orden EXACTO de los `wrdata` del .sch. Si se toca uno hay que tocar el otro.
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

#: Umbral logico. Las salidas del decodificador son rail a rail, asi que medio
#: rail vale y no hace falta histeresis.
UMBRAL = 2.5


def tramos(cod, ang):
    """Trozos contiguos con el mismo codigo, como (angulo_ini, angulo_fin, codigo)."""
    out, ini = [], 0
    for j in range(1, len(cod) + 1):
        if j == len(cod) or cod[j] != cod[ini]:
            out.append((ang[ini], ang[j - 1], cod[ini]))
            ini = j
    return out


def campo(ang, amp):
    """El campo que impuso el estimulo, recalculado aqui sin mirar la simulacion."""
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
        print("\n  senales intermedias   (excursion a lo largo del barrido)")
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

            #  Este decodificador no saca el eje mayor sino el MENOR: se ve en su
            #  tabla de verdad (X = XY.XZ, o sea SX por debajo de las otras dos) y
            #  se confirma aqui contando aciertos contra las dos hipotesis.
            ac = {"EL MENOR": (eje[decidido] == menor[decidido]).mean() * 100,
                  "EL MAYOR": (eje[decidido] == mayor[decidido]).mean() * 100}
            criterio = max(ac, key=ac.get)
            ideal = menor if criterio == "EL MENOR" else mayor

            print(f"\n    {g}  {desc}")
            print(f"      saca {criterio}   acierto {ac[criterio]:5.1f} %"
                  f"   (la otra hipotesis {min(ac.values()):5.1f} %)")

            #  El barrido es un circulo: el tramo que empieza en 0 y el que acaba
            #  en 360 son el mismo sector partido por donde arranca el barrido.
            tr = tramos(cod, ang)
            if len(tr) > 1 and tr[0][2] == tr[-1][2]:
                a0, _, c = tr[-1]
                tr = [(a0 - 360.0, tr[0][1], c)] + tr[1:-1]
            for a0, a1, c in tr:
                marca = "" if len(c) == 1 else (
                    "   <<< sin decidir" if c == "-" else "   <<< AMBIGUO")
                print(f"      {a0:7.1f} .. {a1:6.1f} gr   {c:3s}"
                      f"   {a1-a0+0.5:5.1f} gr{marca}")

            #  Fronteras emparejadas por CERCANIA CIRCULAR y no por orden en la
            #  lista: las dos listas empiezan donde arranca el barrido, no en el
            #  mismo sector, y emparejarlas por indice daba errores de 120 grados
            #  con el mapa perfecto delante.
            #  Las fronteras ideales se saben de memoria y no se muestrean: tres
            #  cosenos a 120 grados se cruzan EXACTAMENTE en 0, 120 y 240 si lo
            #  que se decodifica es el menor, y en 60, 180 y 300 si es el mayor.
            #  Sacarlas del argmin sobre la rejilla metia medio paso de sesgo.
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
                      " sin una sola salida activa")
            resumen[(fich, g)] = (ac[criterio], abs(err).max() if len(err) else float("nan"),
                                  abs(v(f"P_{g}")).max() * 1e3)

        # ----------------------------------------------- esquematico contra layout
        print("\n  esquematico contra layout, la comparacion que pedia el banco")
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
