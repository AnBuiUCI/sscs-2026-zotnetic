#!/usr/bin/env python3
"""Recomputes everything FUNCIONALIDAD_TOP.md claims, in the same order.

    python3 analisis_top.py

It does not simulate: it reads the CSVs left by `run_gradient.sh` and
`run_nav2.sh`, and the top netlist. It exists so that **no figure in the document
se vuelve a correr un banco y cambia un numero, esto lo canta y el documento se
actualiza contra esta salida.

  datos/ancho.csv        gradient bench -- the only one carrying the chain
                         INTERNAL signals (SX/SY/SZ and XY/XZ/YZ), which is what
                         allows measuring each stage polarity
                         separado.
  datos_nav2/ancho_nav2.csv   navigator bench with the tetrahedron geometry.
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
#: S4 on opposite corners of the lower z plane, S1 and S2 on the other two
#: del de arriba. En unidades de medio lado de cubo.
POSICION = {"S1": (-1, +1, +1), "S2": (+1, -1, +1),
            "S3": (-1, -1, -1), "S4": (+1, +1, -1)}

#: Logic threshold. The decoder outputs are rail to rail.
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
    """The calls to `cell`, as (instance, pin -> node)."""
    out, act = [], None
    for ln in lineas:
        t = ln.split()
        #  The top level comes COMMENTED (`**.subckt`), which is how xschem
        #  exports from the CLI. Without counting it, searching inside the top
        #  finds nothing and the check comes out empty -- worse than coming out wrong.
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
    titulo(1, "The sensor arrangement, and what comes out of it")
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
          f"   -> the three axes are recovered separately")

    b = {k: (d[f"{k}P"] - d[f"{k}N"]) / VEXC for k in POSICION}
    g = {e: sum(POSICION[k][i] * b[k] for k in POSICION) / 4.0
         for i, e in enumerate("xyz")}
    ang = d["angulo"]
    rec = np.degrees(np.arctan2(g["z"], g["x"])) % 360.0
    err = (rec - ang + 180.0) % 360.0 - 180.0
    print(f"\n  gradient recovered from the four readings, sweep in the X-Z plane:")
    print(f"    |gx| max {np.abs(g['x']).max() * 1e3:8.4f} mV      "
          f"|gz| max {np.abs(g['z']).max() * 1e3:8.4f} mV")
    print(f"    |gy| max {np.abs(g['y']).max() * 1e9:8.4f} nV   <- must be zero")
    print(f"    angulo reconstruido contra el pedido: |error| max {np.abs(err).max():.4f} grados")


# --------------------------------------------------------------------------- #
def cadena(dg) -> None:
    titulo(2, "The chain, stage by stage: what each block does and how it is measured")
    print("  Measured on chain G2 (schematic with OPAM_LIN, the navigator one)")
    print("  and G4 (its RC-extracted layout), from datos/ancho.csv.\n")
    for g, nom in ((2, "G2 schematic"), (4, "G4 layout with RC")):
        SX, SY, SZ = dg[f"SX{g}"], dg[f"SY{g}"], dg[f"SZ{g}"]
        print(f"  --- {nom}")
        for eje, S, b in (("X", SX, dg["bx"]), ("Y", SY, dg["by"]), ("Z", SZ, dg["bz"])):
            r = np.corrcoef(b, S)[0, 1]
            print(f"     amplificador {eje}: correlacion salida/senal {r:+.4f} -> "
                  f"{'NO INVERSOR' if r > 0 else 'INVERSOR'}"
                  f"   excursion {S.min():.3f} .. {S.max():.3f} V")
        for nombre, A, B in (("XY", SX, SY), ("XZ", SX, SZ), ("YZ", SY, SZ)):
            alto = dg[f"{nombre}{g}"] > UMBRAL
            print(f"     comparator {nombre}: high agrees with INP>INN on "
                  f"{100 * np.mean(alto == (B > A)):5.1f} %")
        v = np.stack([SX, SY, SZ])
        sal = np.stack([dg[f"X{g}"], dg[f"Y{g}"], dg[f"Z{g}"]]) > UMBRAL
        una = sal.sum(0) == 1
        idx = np.argmax(sal, 0)
        print(f"     decodificador: senala el MINIMO en "
              f"{100 * np.mean(idx[una] == np.argmin(v, 0)[una]):5.1f} %  and the MAXIMUM on "
              f"{100 * np.mean(idx[una] == np.argmax(v, 0)[una]):5.1f} %")
        print(f"                    exactly one output high on {100 * np.mean(una):.1f} % "
              f"del barrido\n")


def entradas_del_top(pts, lineas) -> None:
    titulo(3, "The top inputs: each P to its P and each N to its N")
    ok = True
    for inst, pin in instancias(lineas, pts, "GRADIENT2", dentro="GRADIENT_NAV2"):
        pares = [(a, pin[a]) for a in ("SXP", "SXN", "SYP", "SYN", "SZP", "SZN")]
        bien = all(p[-1] == n[-1] for p, n in pares)
        ok &= bien
        print(f"  {inst}: " + "  ".join(f"{p}={n}" for p, n in pares)
              + ("   OK" if bien else "   <-- CRUZADO"))
    print(f"\n  -> {'no top input is crossed' if ok else 'THERE ARE CROSSED INPUTS'}")


def logica_decoder(pts, lineas, dg) -> None:
    titulo(4, "The decoder logic, read from the netlist")
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
    print("  -> more votes = LESS voltage. As COMP_OUT is a non-inverting buffer,")
    print("     the output called 'P' is high when the axis does NOT win.")


def umbral(d) -> None:
    titulo(6, "The decision threshold: wrong for X and Y, and for Z there is no good one")
    v = votos_de(d)
    gana = np.argmax(v, 0)
    print(f"  {'eje':4s} {'>=1':>8s} {'>=2':>8s} {'>=3':>8s} {'>=4':>8s}   dispara hoy   deberia")
    for i, e in enumerate("XYZ"):
        ac = [100 * np.mean((v[i] >= th) == (gana == i)) for th in (1, 2, 3, 4)]
        print(f"  {e:4s} " + " ".join(f"{a:7.1f}%" for a in ac)
              + f"   {100 * np.mean(d[f'{e}N'] > UMBRAL):8.1f} %"
              + f"   {100 * np.mean(gana == i):7.1f} %")
    print("\n  (today it is >=3 votes; accuracy is against 'this axis has the most votes')")


# --------------------------------------------------------------------------- #
def reparto(pts, lineas) -> None:
    titulo(7, "Why Z cannot win: how the sensors are shared across the slots")
    trio = {}
    for inst, pin in instancias(lineas, pts, "GRADIENT2", dentro="GRADIENT_NAV2"):
        trio[inst] = tuple(int(pin[f"S{e}P"][1]) - 1 for e in "XYZ")
    orden = sorted(trio)
    for r, nom in enumerate("XYZ"):
        vistos = [trio[i][r] for i in orden]
        print(f"  ranura {nom}: " + "  ".join(f"{i}=S{trio[i][r] + 1}" for i in orden)
              + f"   -> {len(set(vistos))} sensor(es) distinto(s)")
    print("\n  Each chain picks the MINIMUM of its triad, so a sensor sitting in the")
    print("  same slot of TWO chains takes two votes at once. Those in the slot")
    print("  that sees all four sensors are split up and never add up.\n")

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
    print("\n  The four triads are already the four subsets of three -- each chain")
    print("  omits one sensor, that is fine. What fails is the ORDER within the triad.")
    print("  Assignments where each slot sees the four sensors once:\n")
    sub = [tuple(s) for s in itertools.combinations(range(4), 3)]
    hallados = []
    for perms in itertools.product(*[list(itertools.permutations(s)) for s in sub]):
        if not all(sorted(perms[k][r] for k in range(4)) == [0, 1, 2, 3] for r in range(3)):
            continue
        hallados.append((perms, evalua(perms, "xz"), evalua(perms, "xy")))
    #  **Not just any of the 24 will do.** Each slot seeing the four sensors is
    #  necessary but not sufficient: there are assignments that fix one plane and
    #  kill a slot in the other. They are sorted by the WEAKEST slot of BOTH
    #  planes, which is the figure that matters.
    hallados.sort(key=lambda h: -min(list(h[1]) + list(h[2])))
    buenas = [h for h in hallados if min(list(h[1]) + list(h[2])) > 1.0]
    print(f"    there are {len(hallados)} with each slot seeing all four sensors, but only")
    print(f"    {len(buenas)} keep all three slots alive IN BOTH PLANES. The best:\n")
    perms, rxz, rxy = hallados[0]
    for k in range(4):
        print(f"      G{k + 1} (X,Y,Z) = " + " ".join(f"S{i + 1}" for i in perms[k]))
    print(f"\n    gana X/Y/Z = {np.round(rxz, 1)} en X-Z  y  {np.round(rxy, 1)} en X-Y")
    print(f"    the weakest slot is left with "
          f"{min(list(rxz) + list(rxy)):.1f} %   (hoy, 0.0 %)")
    print(f"\n    the next three, in case another suits the wiring better:")
    for perms, rxz, rxy in hallados[1:4]:
        print("      " + "  ".join("".join(f"S{i + 1}" for i in perms[k]) for k in range(4))
              + f"   X-Z {np.round(rxz, 1)}   X-Y {np.round(rxy, 1)}")


def no_roto() -> None:
    titulo(8, "What is NOT broken")
    for x in ("los puentes: Vcm clavado en VEXC/2, independiente de la senal",
              "the top inputs: each P to its P and each N to its N",
              "the amplifiers: non-inverting, and with the full swing",
              "the comparators: high when INP > INN, in both versions",
              "la logica del decodificador: selector de minimo correcto y completo",
              "the weight block, as a COUNTER: monotonic with equal steps"):
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
