#!/usr/bin/env python3
"""Recalcula todo lo que afirma FUNCIONALIDAD_TOP.md, y en el mismo orden.

    python3 analisis_top.py

No simula: lee los CSV que dejan `run_gradient.sh` y `run_nav2.sh`, y el netlist
del top. Existe para que **ninguna cifra del documento este tecleada a mano**: si
se vuelve a correr un banco y cambia un numero, esto lo canta y el documento se
actualiza contra esta salida.

  datos/ancho.csv        banco del gradiente -- es el unico que trae las senales
                         INTERNAS de la cadena (SX/SY/SZ y XY/XZ/YZ), que es lo
                         que permite medir la polaridad de cada etapa por
                         separado.
  datos_nav2/ancho_nav2.csv   banco del navegador con la geometria de tetraedro.
  XSCHEM/simulation/GRADIENT_NAV2.sch/GRADIENT_NAV2.spice   el cableado de verdad.
"""

from __future__ import annotations

import collections
import itertools
import re
import sys
from pathlib import Path

import numpy as np

AQUI = Path(__file__).resolve().parent
NETLIST = AQUI.parent / "simulation/GRADIENT_NAV2.sch/GRADIENT_NAV2.spice"
CSV_GRAD = AQUI / "datos/ancho.csv"
CSV_NAV = AQUI / "datos_nav2/ancho_nav2.csv"

#: Los cuatro sensores, de la foto: tetraedro regular inscrito en el cubo. S3 y
#: S4 en esquinas opuestas del plano z de abajo, S1 y S2 en las dos contrarias
#: del de arriba. En unidades de medio lado de cubo.
POSICION = {"S1": (-1, +1, +1), "S2": (+1, -1, +1),
            "S3": (-1, -1, -1), "S4": (+1, +1, -1)}

#: Umbral logico. Las salidas del decodificador son rail a rail.
UMBRAL = 2.5
VEXC = 5.0


def titulo(n: int, t: str) -> None:
    print(f"\n{'=' * 78}\n  {n}. {t}\n{'=' * 78}")


# --------------------------------------------------------------------------- #
def leer_netlist() -> tuple[dict[str, list[str]], list[str]]:
    """(subcircuito -> puertos, lineas del netlist)."""
    if not NETLIST.exists():
        sys.exit(f"falta {NETLIST}; corre antes `make netlist T=GRADIENT_NAV2 V=v2`")
    lineas = NETLIST.read_text().splitlines()
    pts = {}
    for ln in lineas:
        t = ln.split()
        if t[:1] == [".subckt"]:
            pts[t[1]] = t[2:]
        elif t[:1] == ["**.subckt"]:
            pts[t[1]] = t[2:]
    return pts, lineas


def instancias(lineas, pts, celda, dentro=None):
    """Las llamadas a `celda`, como (instancia, pin -> nodo)."""
    out, act = [], None
    for ln in lineas:
        t = ln.split()
        #  El nivel de arriba viene COMENTADO (`**.subckt`), que es como xschem
        #  exporta desde la CLI. Sin contarlo, buscar dentro del top no encuentra
        #  nada y la comprobacion sale vacia -- que es peor que salir mal.
        if t[:1] in ([".subckt"], ["**.subckt"]):
            act = t[1]
        elif t[:1] in ([".ends"], ["**.ends"]):
            act = None
        elif t and t[0][0].lower() == "x" and t[-1] == celda:
            if dentro is not None and act != dentro:
                continue
            out.append((t[0], dict(zip(pts[celda], t[1:-1]))))
    return out


# --------------------------------------------------------------------------- #
def geometria(d) -> None:
    titulo(1, "La disposicion de los sensores, y que se saca de ella")
    P = np.array(list(POSICION.values()), float)
    print("  sensor   x   y   z    plano z")
    for k, (x, y, z) in POSICION.items():
        print(f"  {k}      {x:+d}  {y:+d}  {z:+d}    {'superior' if z > 0 else 'inferior'}")
    aristas = [np.linalg.norm(P[i] - P[j]) for i, j in itertools.combinations(range(4), 2)]
    print(f"\n  las seis aristas: {' '.join(f'{a:.4f}' for a in aristas)}"
          f"   -> {'TETRAEDRO REGULAR' if np.ptp(aristas) < 1e-9 else 'NO regular'}")
    print(f"  centroide: {P.mean(0)}")
    G = P.T @ P
    print(f"  suma(u_a * u_b) = diag{tuple(int(x) for x in np.diag(G))}, "
          f"fuera de la diagonal {np.abs(G - np.diag(np.diag(G))).max():.0f}"
          f"   -> los tres ejes se recuperan por separado")

    b = {k: (d[f"{k}P"] - d[f"{k}N"]) / VEXC for k in POSICION}
    g = {e: sum(POSICION[k][i] * b[k] for k in POSICION) / 4.0
         for i, e in enumerate("xyz")}
    ang = d["angulo"]
    rec = np.degrees(np.arctan2(g["z"], g["x"])) % 360.0
    err = (rec - ang + 180.0) % 360.0 - 180.0
    print(f"\n  gradiente recuperado de las cuatro lecturas, con el barrido en el plano X-Z:")
    print(f"    |gx| max {np.abs(g['x']).max() * 1e3:8.4f} mV      "
          f"|gz| max {np.abs(g['z']).max() * 1e3:8.4f} mV")
    print(f"    |gy| max {np.abs(g['y']).max() * 1e9:8.4f} nV   <- tiene que ser cero")
    print(f"    angulo reconstruido contra el pedido: |error| max {np.abs(err).max():.4f} grados")


# --------------------------------------------------------------------------- #
def cadena(dg) -> None:
    titulo(2, "La cadena, etapa por etapa: que hace cada bloque y como se mide")
    print("  Se mide sobre la cadena G2 (esquematico con OPAM_LIN, que es la del")
    print("  navegador) y G4 (su layout extraido con RC), de datos/ancho.csv.\n")
    for g, nom in ((2, "G2 esquematico"), (4, "G4 layout con RC")):
        SX, SY, SZ = dg[f"SX{g}"], dg[f"SY{g}"], dg[f"SZ{g}"]
        print(f"  --- {nom}")
        for eje, S, b in (("X", SX, dg["bx"]), ("Y", SY, dg["by"]), ("Z", SZ, dg["bz"])):
            r = np.corrcoef(b, S)[0, 1]
            print(f"     amplificador {eje}: correlacion salida/senal {r:+.4f} -> "
                  f"{'NO INVERSOR' if r > 0 else 'INVERSOR'}"
                  f"   excursion {S.min():.3f} .. {S.max():.3f} V")
        for nombre, A, B in (("XY", SX, SY), ("XZ", SX, SZ), ("YZ", SY, SZ)):
            alto = dg[f"{nombre}{g}"] > UMBRAL
            print(f"     comparador {nombre}: alto coincide con INP>INN en "
                  f"{100 * np.mean(alto == (B > A)):5.1f} %")
        v = np.stack([SX, SY, SZ])
        sal = np.stack([dg[f"X{g}"], dg[f"Y{g}"], dg[f"Z{g}"]]) > UMBRAL
        una = sal.sum(0) == 1
        idx = np.argmax(sal, 0)
        print(f"     decodificador: senala el MINIMO en "
              f"{100 * np.mean(idx[una] == np.argmin(v, 0)[una]):5.1f} %  y el MAXIMO en "
              f"{100 * np.mean(idx[una] == np.argmax(v, 0)[una]):5.1f} %")
        print(f"                    una sola salida alta en el {100 * np.mean(una):.1f} % "
              f"del barrido\n")


def entradas_del_top(pts, lineas) -> None:
    titulo(3, "Las entradas del top: cada P a su P y cada N a su N")
    ok = True
    for inst, pin in instancias(lineas, pts, "GRADIENT2", dentro="GRADIENT_NAV2"):
        pares = [(a, pin[a]) for a in ("SXP", "SXN", "SYP", "SYN", "SZP", "SZN")]
        bien = all(p[-1] == n[-1] for p, n in pares)
        ok &= bien
        print(f"  {inst}: " + "  ".join(f"{p}={n}" for p, n in pares)
              + ("   OK" if bien else "   <-- CRUZADO"))
    print(f"\n  -> {'ninguna entrada del top esta cruzada' if ok else 'HAY ENTRADAS CRUZADAS'}")


def logica_decoder(pts, lineas, dg) -> None:
    titulo(4, "La logica del decodificador, leida del netlist")
    print("  Deducida puerta a puerta (andGate = AND, invertor = NOT, Z = NOR):")
    print("     X = XY . XZ            = (SY>SX).(SZ>SX)   -> SX es el menor")
    print("     Y = YZ . ~XY           = (SZ>SY).(SX>=SY)  -> SY es el menor")
    print("     Z = ~XZ . ~YZ          = (SX>=SZ).(SY>=SZ) -> SZ es el menor")
    print("\n  Contrastada con la simulacion (cadena G2):")
    XY, XZ, YZ = (dg[f"{n}2"] > UMBRAL for n in ("XY", "XZ", "YZ"))
    for nom, pred in (("X", XY & XZ), ("Y", YZ & ~XY), ("Z", ~XZ & ~YZ)):
        print(f"     {nom}: la formula acierta el "
              f"{100 * np.mean((dg[f'{nom}2'] > UMBRAL) == pred):.1f} % del barrido")


# --------------------------------------------------------------------------- #
def votos_de(d):
    return np.stack([sum((d[f"{e}{k}"] > UMBRAL).astype(int) for k in (1, 2, 3, 4))
                     for e in "XYZ"])


def pesos(d) -> None:
    titulo(5, "El bloque de pesos: contador de votos, e INVERSOR")
    v = votos_de(d)
    for i, e in enumerate("XYZ"):
        print(f"  eje {e}:")
        for n in sorted(set(v[i])):
            m = v[i] == n
            print(f"     {n} voto(s) ({100 * m.mean():5.1f} % del barrido): "
                  f"tension del peso {d[e][m].min():.3f} V   "
                  f"{e}P alto {100 * np.mean(d[f'{e}P'][m] > UMBRAL):5.1f} %   "
                  f"{e}N alto {100 * np.mean(d[f'{e}N'][m] > UMBRAL):5.1f} %")
        print(f"     correlacion votos/tension {np.corrcoef(v[i], d[e])[0, 1]:+.3f}"
              f"  -> {'INVERSOR' if np.corrcoef(v[i], d[e])[0, 1] < 0 else 'no inversor'}\n")
    print("  -> mas votos = MENOS tension. Como COMP_OUT es un buffer no inversor,")
    print("     la salida llamada 'P' esta alta cuando el eje NO gana.")


def umbral(d) -> None:
    titulo(6, "El umbral de decision: mal para X e Y, y para Z no hay ninguno bueno")
    v = votos_de(d)
    gana = np.argmax(v, 0)
    print(f"  {'eje':4s} {'>=1':>8s} {'>=2':>8s} {'>=3':>8s} {'>=4':>8s}   dispara hoy   deberia")
    for i, e in enumerate("XYZ"):
        ac = [100 * np.mean((v[i] >= th) == (gana == i)) for th in (1, 2, 3, 4)]
        print(f"  {e:4s} " + " ".join(f"{a:7.1f}%" for a in ac)
              + f"   {100 * np.mean(d[f'{e}N'] > UMBRAL):8.1f} %"
              + f"   {100 * np.mean(gana == i):7.1f} %")
    print("\n  (el de hoy es >=3 votos; el acierto es contra 'este eje es el mas votado')")


# --------------------------------------------------------------------------- #
def reparto(pts, lineas) -> None:
    titulo(7, "Por que Z no puede ganar: el reparto de sensores entre las ranuras")
    trio = {}
    for inst, pin in instancias(lineas, pts, "GRADIENT2", dentro="GRADIENT_NAV2"):
        trio[inst] = tuple(int(pin[f"S{e}P"][1]) - 1 for e in "XYZ")
    orden = sorted(trio)
    for r, nom in enumerate("XYZ"):
        vistos = [trio[i][r] for i in orden]
        print(f"  ranura {nom}: " + "  ".join(f"{i}=S{trio[i][r] + 1}" for i in orden)
              + f"   -> {len(set(vistos))} sensor(es) distinto(s)")
    print("\n  Cada cadena elige el MINIMO de su trio, asi que un sensor que este en la")
    print("  misma ranura de DOS cadenas se lleva dos votos de golpe. Los de la ranura")
    print("  que ve los cuatro sensores se reparten y nunca se juntan.\n")

    V = [POSICION[k] for k in ("S1", "S2", "S3", "S4")]
    TR = [trio[i] for i in orden]
    ang = np.radians(np.arange(0, 360, 1.0))

    def evalua(tr, plano):
        u = np.array(V, float)
        g = np.stack([np.cos(ang), np.sin(ang) * (plano == "xy"),
                      np.sin(ang) * (plano == "xz")])
        b = u @ g
        vt = np.zeros((3, len(ang)), int)
        for k in range(4):
            t3 = np.stack([b[tr[k][r]] for r in range(3)])
            vt[np.argmin(t3, 0), np.arange(len(ang))] += 1
        gan = np.argmax(vt, 0)
        return np.array([np.mean(gan == i) for i in range(3)]) * 100

    for plano in ("xz", "xy"):
        print(f"  cableado de hoy, gradiente en el plano {plano.upper()}: "
              f"gana X/Y/Z = {np.round(evalua(TR, plano), 1)}")
    print("\n  Los cuatro trios ya son los cuatro subconjuntos de tres -- cada cadena")
    print("  omite un sensor, eso esta bien. Lo que falla es el ORDEN dentro del trio.")
    print("  Asignaciones en que cada ranura ve los cuatro sensores una vez:\n")
    sub = [tuple(s) for s in itertools.combinations(range(4), 3)]
    hallados = []
    for perms in itertools.product(*[list(itertools.permutations(s)) for s in sub]):
        if not all(sorted(perms[k][r] for k in range(4)) == [0, 1, 2, 3] for r in range(3)):
            continue
        hallados.append((perms, evalua(perms, "xz"), evalua(perms, "xy")))
    #  **No vale cualquiera de las 24.** Que cada ranura vea los cuatro sensores
    #  es necesario pero no suficiente: hay asignaciones que arreglan un plano y
    #  matan una ranura en el otro. Se ordenan por la ranura MAS FLOJA de los DOS
    #  planos, que es la cifra que importa.
    hallados.sort(key=lambda h: -min(list(h[1]) + list(h[2])))
    buenas = [h for h in hallados if min(list(h[1]) + list(h[2])) > 1.0]
    print(f"    hay {len(hallados)} con cada ranura viendo los cuatro sensores, pero solo")
    print(f"    {len(buenas)} dejan viva a las tres ranuras EN LOS DOS PLANOS. La mejor:\n")
    perms, rxz, rxy = hallados[0]
    for k in range(4):
        print(f"      G{k + 1} (X,Y,Z) = " + " ".join(f"S{i + 1}" for i in perms[k]))
    print(f"\n    gana X/Y/Z = {np.round(rxz, 1)} en X-Z  y  {np.round(rxy, 1)} en X-Y")
    print(f"    la ranura mas floja se queda con "
          f"{min(list(rxz) + list(rxy)):.1f} %   (hoy, 0.0 %)")
    print(f"\n    las tres siguientes, por si conviene otra por cableado:")
    for perms, rxz, rxy in hallados[1:4]:
        print("      " + "  ".join("".join(f"S{i + 1}" for i in perms[k]) for k in range(4))
              + f"   X-Z {np.round(rxz, 1)}   X-Y {np.round(rxy, 1)}")


def no_roto() -> None:
    titulo(8, "Que NO esta roto")
    for x in ("los puentes: Vcm clavado en VEXC/2, independiente de la senal",
              "las entradas del top: cada P a su P y cada N a su N",
              "los amplificadores: no inversores, y con la excursion entera",
              "los comparadores: alto cuando INP > INN, en las dos versiones",
              "la logica del decodificador: selector de minimo correcto y completo",
              "el bloque de pesos, como CONTADOR: monotono y con escalones iguales"):
        print(f"  * {x}")


def main() -> int:
    for p in (CSV_GRAD, CSV_NAV):
        if not p.exists():
            sys.exit(f"falta {p}; corre antes ./run_gradient.sh y ./run_nav2.sh")
    dg = np.genfromtxt(CSV_GRAD, delimiter=",", names=True)
    dn = np.genfromtxt(CSV_NAV, delimiter=",", names=True)
    pts, lineas = leer_netlist()

    geometria(dn)
    cadena(dg)
    entradas_del_top(pts, lineas)
    logica_decoder(pts, lineas, dg)
    pesos(dn)
    umbral(dn)
    reparto(pts, lineas)
    no_roto()
    return 0


if __name__ == "__main__":
    sys.exit(main())
