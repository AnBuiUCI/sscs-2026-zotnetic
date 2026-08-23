#!/usr/bin/env python3
"""Lee lo que escribio ngspice, saca las tablas y exporta los datos con nombres.

    python3 analizar_nav2.py <carpeta_simulacion> <carpeta_datos>

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

#: Las salidas del navegador, cada una con su pareja del layout.
#:
#: **X, Y y Z son ANALOGICAS**, no logicas. Son la salida de los tres bloques de
#: peso, que promedian las cuatro cadenas: medido, se mueven en 2.18 .. 3.04 V,
#: no de rail a rail. Compararlas con un umbral seria inventarse bits que no hay,
#: asi que se comparan como tensiones.
ANALOGICAS = ["X", "Y", "Z"]
#: Estas si son logicas: salen del par de inversores de `COMP_OUT`.
LOGICAS = ["XP", "XN", "YP", "YN", "ZP", "ZN"]
#: Y las doce intermedias, la salida de cada cadena antes de los pesos.
CADENAS = [f"{e}{k}" for e in "XYZ" for k in (1, 2, 3, 4)]

#: Los cuatro sensores en el espacio, centrados en +-1 (ver el bloque ESTIMULO
#: del .sch). Tetraedro regular inscrito en el cubo: S3 y S4 en esquinas opuestas
#: del plano z de abajo, S1 y S2 en las dos contrarias del de arriba.
POSICION = {"S1": (-1, +1, +1), "S2": (+1, -1, +1),
            "S3": (-1, -1, -1), "S4": (+1, +1, -1)}

#: Umbral logico. Las salidas del decodificador y de los pesos son rail a rail,
#: asi que medio rail vale y no hace falta histeresis.
UMBRAL = 2.5


def leer(path: Path) -> np.ndarray:
    d = np.loadtxt(path)
    if d.shape[1] < 2 * len(VECTORES):
        sys.exit(f"{path.name}: {d.shape[1]} columnas, esperaba {2 * len(VECTORES)}. "
                 f"El .control y VECTORES se han separado.")
    return d


def tramos(bits, ang):
    """Trozos contiguos con el mismo valor, como (angulo_ini, angulo_fin, valor)."""
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
        #  Los cuatro vectores de posicion son ortogonales componente a
        #  componente, asi que el gradiente sale de una suma con signos y sin
        #  resolver ningun sistema. Es la comprobacion de que la disposicion de
        #  los sensores hace lo que se le pide: de cuatro numeros salen las tres
        #  diferencias en x, y, z.
        b = {k: (v[f"{k}P"] - v[f"{k}N"]) / 5.0 for k in POSICION}
        g = {eje: sum(POSICION[k][i] * b[k] for k in POSICION) / 4.0
             for i, eje in enumerate("xyz")}
        #  Y el angulo reconstruido contra el que se pidio. En el plano X-Z el
        #  gradiente va (cos, 0, sen), asi que atan2(gz, gx) tiene que devolver
        #  el barrido.
        rec = np.degrees(np.arctan2(g["z"], g["x"])) % 360.0
        err = (rec - ang + 180.0) % 360.0 - 180.0
        print(f"  geometria  gradiente recuperado de las cuatro lecturas:")
        print(f"             |gx| max {np.abs(g['x']).max() * 1000:.4f} mV/lado   "
              f"|gy| max {np.abs(g['y']).max() * 1e6:.4f} uV/lado   "
              f"|gz| max {np.abs(g['z']).max() * 1000:.4f} mV/lado")
        print(f"             angulo reconstruido contra el barrido: "
              f"error |max| {np.abs(err).max():.4f} grados, rms {np.sqrt(np.mean(err ** 2)):.4f}")

        #  --- el estimulo, antes que nada -------------------------------------
        #  Si el modo comun se mueve, el modelo de puente esta mal puesto y todo
        #  lo demas sobra.
        vcm = np.concatenate([(v[f"S{k}P"] + v[f"S{k}N"]) / 2 for k in (1, 2, 3, 4)])
        dif = [np.ptp(v[f"S{k}P"] - v[f"S{k}N"]) / 2 for k in (1, 2, 3, 4)]
        print(f"  sensores   Vcm {vcm.min():.6f} .. {vcm.max():.6f} V   "
              f"(tiene que ser constante)")
        print(f"             Vdiff maximo por sensor  " +
              "  ".join(f"S{k}={x * 1000:+.4f} mV" for k, x in enumerate(dif, 1)))
        #  En valor absoluto: `i(V)` es la corriente que ENTRA por el borne
        #  positivo, o sea negativa cuando la fuente entrega.
        print(f"  consumo    puentes {abs(v['P_EXC'].mean()) * 1e6:8.1f} uW   "
              f"esquematico {abs(v['P_ESQ'].mean()) * 1e3:8.3f} mW   "
              f"layout RC {abs(v['P_LAY'].mean()) * 1e3:8.3f} mW")

        #  --- lo que mide el banco: coinciden las dos versiones? --------------
        paso = ang[1] - ang[0]
        print(f"\n  las tres salidas de peso, comparadas como TENSIONES:")
        print(f"  {'salida':7s} {'rango esquematico':>20s} {'rango layout RC':>18s} "
              f"{'|dif| max':>10s} {'rms':>8s} {'grados de canto':>16s}")
        for n in ANALOGICAS:
            e = v[n] - v[n + "r"]
            #  La salida del peso es una escalera: promedia cuatro niveles
            #  logicos. Donde las dos versiones coinciden la diferencia es de
            #  milivoltios; donde una ya ha dado el escalon y la otra no, es el
            #  escalon entero. Por eso el maximo por si solo enganaria: lo que
            #  mide de verdad la diferencia entre esquematico y layout es
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
            #  Una salida logica que no se mueve en TODO el barrido no es un
            #  acuerdo: es que no lleva informacion. Pasa igual en el
            #  esquematico y en el layout, asi que ningun LVS ni ningun DRC lo
            #  puede ver -- solo esto.
            ejes = sorted({n[0] for n in clavadas})
            print(f"    CLAVADAS EN TODO EL BARRIDO: {' '.join(clavadas)}."
                  f"  No es del banco: el par de inversores de COMP_OUT no")
            for e in ejes:
                print(f"    conmuta en el rango en que vive la salida del peso "
                      f"{e} ({v[e].min():.3f} .. {v[e].max():.3f} V).")

        #  --- y las doce salidas de cadena, antes de los pesos -----------------
        peor = min(((100.0 * np.mean((v[n] > UMBRAL) == (v[n + "r"] > UMBRAL)), n)
                    for n in CADENAS))
        acu = [100.0 * np.mean((v[n] > UMBRAL) == (v[n + "r"] > UMBRAL)) for n in CADENAS]
        print(f"\n  las 12 salidas de cadena (antes de los pesos): "
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
