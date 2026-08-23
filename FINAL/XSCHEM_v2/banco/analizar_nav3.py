"""Measures whether the GRADIENT_NAV3 outputs give the SENSE of the gradient.

Run like this, from this directory:

    sed 's|nav3.inc|<ruta al netlist>|' banco_nav3.spice > /tmp/b.spice
    ngspice -b /tmp/b.spice
    python3 analizar_nav3.py salidas.raw

TWO THINGS YOU CANNOT GUESS AND NEED TO KNOW:

  * The decoders are ACTIVE LOW. There are always exactly two high outputs of
    every three, and the axis named is the one at zero. It comes from COMP_OUT
    being an inverter chain. Reading it the other way gives 0 % and makes it look
    like the block does not work.
  * Cual de los dos lados (A o B) es el maximo NO se razona, se mide: se mira
    cual acierta cuando el gradiente va en sentido positivo. Medido, es el B.
    And since the gradient is of the field MAGNITUDE, side B names the axis and
    sense in which |B| grows fastest: the direction TOWARDS THE SOURCE. Side A
    lado A apunta al contrario, alejandose.
"""
import sys

import numpy as np


def leer_raw(ruta):
    """Parsea un rawfile ASCII de ngspice -> {nombre: vector}."""
    lin = open(ruta).read().splitlines()
    iv = next(i for i, l in enumerate(lin) if l.startswith("Variables:"))
    il = next(i for i, l in enumerate(lin) if l.startswith("Values:"))
    nom = [l.split()[1] for l in lin[iv + 1:il]]
    n = len(nom)
    #  Each point is n+1 tokens: the index and the n values.
    crudo = [x for l in lin[il + 1:] for x in l.split()]
    filas, k = [], 0
    while k < len(crudo) and len(crudo) - k >= n + 1:
        filas.append([float(x) for x in crudo[k + 1:k + 1 + n]])
        k += n + 1
    d = np.array(filas)
    return {x: d[:, i] for i, x in enumerate(nom)}


def main(ruta="salidas.raw"):
    v = leer_raw(ruta)
    V = lambda q: v["v(" + q + ")"]
    g = np.stack([V("gx"), V("gy"), V("gz")], 1)
    N = len(g)
    A = (np.stack([V(e.lower() + "ap") for e in "XYZ"], 1) < 2.5).argmax(1)
    B = (np.stack([V(e.lower() + "bp") for e in "XYZ"], 1) < 2.5).argmax(1)
    dom = np.abs(g).argmax(1)
    sig = np.sign(g[np.arange(N), dom])

    pos = sig > 0
    aA, aB = (A[pos] == dom[pos]).mean(), (B[pos] == dom[pos]).mean()
    ep, en = (A, B) if aA > aB else (B, A)
    lado = "A" if aA > aB else "B"
    print(f"  El lado {lado} senala el extremo POSITIVO: {100*max(aA,aB):.1f} % "
          f"against {100*min(aA,aB):.1f} % for the other.\n")

    bien = np.where(pos, ep == dom, en == dom)
    enpar = (A == dom) | (B == dom)
    print(f"  SENTIDO bien identificado ..... {100*bien.mean():5.1f} %  ({bien.sum()}/{N})")
    print(f"  dominant axis among the two ... {100*enpar.mean():5.1f} %\n")
    print("      sentido    n    eje ok   sentido ok")
    for e, nm in enumerate("XYZ"):
        for s, sn in ((1, "+"), (-1, "-")):
            m = (dom == e) & (sig == s)
            if m.any():
                print(f"      {sn}{nm}      {m.sum():4d}    {100*enpar[m].mean():5.1f} %"
                      f"    {100*bien[m].mean():5.1f} %")
    #  Where it fails: right on the octant boundary the two components
    #  mayores casi empatan y ahi decide el offset del amplificador.
    o = np.sort(np.abs(g), 1)
    r = o[:, 2] / np.maximum(o[:, 1], 1e-9)
    print()
    for lo, hi, et in ((1.0, 1.1, "empate (<10 %)"), (1.1, 1.5, "1.1-1.5x"),
                       (1.5, 1e9, ">1.5x")):
        m = (r >= lo) & (r < hi)
        if m.any():
            print(f"      margen {et:16s} n={m.sum():4d}  sentido ok "
                  f"{100*bien[m].mean():5.1f} %")


if __name__ == "__main__":
    main(*sys.argv[1:])
