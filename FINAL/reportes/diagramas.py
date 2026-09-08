#!/usr/bin/env python3
"""Internal block diagrams, drawn rather than captured.

    env -u PYTHONPATH /headless/.venvs/zotnetic/bin/python diagramas.py

WHY DRAW THEM. A schematic capture answers "what is connected to what"; it does
not answer "what does this block do", because the eye has to find the signal
path among the supplies, the taps and the labels. The report needs both, so
each block gets a diagram that shows ONLY the path, and its schematic next to
it for the detail.

Everything here is read off the schematics, not invented:

  GRADIENT_NAV2 = 4x GRADIENT2 -> 3x WEIGHT -> 3x COMP_OUT
  GRADIENT2     = 3x OPAM_LIN -> 3x COMP (pairwise XY, XZ, YZ) -> DECODER
  WEIGHT        = four binary-weighted branches summing on WE
  COMP_OUT      = 3x INV_1, output and its complement

Labels in English, like every figure in the deck.
"""

from __future__ import annotations

import sys
from pathlib import Path

import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
from matplotlib.patches import FancyArrowPatch, FancyBboxPatch

AQUI = Path(__file__).resolve().parent
FIG = AQUI / "figuras"

#: Zotnetic palette, the deck's own.
AZUL = "#16256B"
AZUL_CLARO = "#E8ECF7"
AMBAR = "#E08A1E"
AMBAR_CLARO = "#FCF0DC"
GRIS = "#8A93B5"
TINTA = "#1C2238"


def caja(ax, x, y, w, h, texto, sub="", color=AZUL, relleno=AZUL_CLARO,
         tam=9):
    ax.add_patch(FancyBboxPatch((x, y), w, h,
                                boxstyle="round,pad=0.008,rounding_size=0.018",
                                linewidth=1.6, edgecolor=color,
                                facecolor=relleno, zorder=2))
    ax.text(x + w / 2, y + h * (0.66 if sub else 0.5), texto,
            ha="center", va="center", fontsize=tam, fontweight="bold",
            color=color, zorder=3, family="monospace")
    if sub:
        ax.text(x + w / 2, y + h * 0.26, sub, ha="center", va="center",
                fontsize=tam - 2.0, color=TINTA, zorder=3)


def flecha(ax, x0, y0, x1, y1, etiqueta="", color=GRIS, arriba=True):
    ax.add_patch(FancyArrowPatch((x0, y0), (x1, y1), arrowstyle="-|>",
                                 mutation_scale=11, linewidth=1.2,
                                 color=color, zorder=1,
                                 shrinkA=0, shrinkB=0))
    if etiqueta:
        ax.text((x0 + x1) / 2, (y0 + y1) / 2 + (0.05 if arriba else -0.09),
                etiqueta, ha="center", va="bottom" if arriba else "top",
                fontsize=7.2, color=TINTA, family="monospace")


def lienzo(ancho, alto, titulo):
    fig, ax = plt.subplots(figsize=(ancho, alto))
    ax.set_xlim(0, 1)
    ax.set_ylim(0, 1)
    ax.axis("off")
    ax.set_title(titulo, fontsize=11, color=AZUL, fontweight="bold", pad=8)
    return fig, ax


def guarda(fig, nombre):
    FIG.mkdir(parents=True, exist_ok=True)
    fig.savefig(FIG / f"{nombre}.png", dpi=300, bbox_inches="tight",
                facecolor="white")
    plt.close(fig)
    print(f"  {nombre}.png")


def nav2():
    """The navigator: four sensing blocks, three weights, three output stages."""
    fig, ax = lienzo(10.5, 5.4,
                     "GRADIENT_NAV2 — 4 × GRADIENT2  →  3 × WEIGHT  →  3 × COMP_OUT")
    #  Four GRADIENT2, one per sensor triple. Each reads THREE of the four
    #  bridges, in a different combination -- that is what makes the four of
    #  them see different projections of the same field.
    BUS = 0.375
    trios = ["S1 S2 S3", "S1 S2 S4", "S3 S4 S1", "S3 S4 S2"]
    ys = []
    for i, t in enumerate(trios):
        y = 0.80 - i * 0.20
        ys.append(y + 0.055)
        ax.text(0.005, y + 0.055, t, ha="left", va="center", fontsize=7.5,
                color=TINTA, family="monospace")
        caja(ax, 0.10, y, 0.20, 0.11, "GRADIENT2", f"chain {i}", tam=8.5)
        flecha(ax, 0.072, y + 0.055, 0.098, y + 0.055)
        #  Into the bus, not into a WEIGHT: each chain sends X, Y and Z, and
        #  drawing all twelve wires turns the figure into a mesh.
        flecha(ax, 0.30, y + 0.055, BUS, y + 0.055, "X Y Z")
    #  The bus itself.
    ax.plot([BUS, BUS], [min(ys) - 0.02, max(ys) + 0.02], color=GRIS,
            lw=2.2, solid_capstyle="round", zorder=1)
    for j, e in enumerate("XYZ"):
        y = 0.68 - j * 0.20
        caja(ax, 0.44, y, 0.17, 0.11, "WEIGHT", f"{e} axis", AMBAR,
             AMBAR_CLARO, tam=8.5)
        caja(ax, 0.68, y, 0.18, 0.11, "COMP_OUT", f"{e} buffer", tam=8.5)
        flecha(ax, BUS, y + 0.055, 0.438, y + 0.055, "VA…VD")
        flecha(ax, 0.61, y + 0.055, 0.678, y + 0.055, "WE")
        for k, suf in enumerate(("P", "N")):
            yy = y + (0.078 if k == 0 else 0.032)
            flecha(ax, 0.86, yy, 0.935, yy)
            ax.text(0.945, yy, f"{e}{suf}", ha="left", va="center",
                    fontsize=7.4, color=TINTA, family="monospace")
    ax.text(0.5, 0.03,
            "every chain votes on every axis: the WEIGHT of one axis takes that "
            "axis's output from all four chains",
            ha="center", va="bottom", fontsize=7.8, color=TINTA, style="italic")
    guarda(fig, "diag_GRADIENT_NAV2")


def gradient2():
    """Gradient sensing: amplify three differences, compare them in pairs."""
    fig, ax = lienzo(10.5, 4.6,
                     "GRADIENT2 (gradient sensing) — 3 × OPAM_LIN  →  "
                     "3 × COMP  →  DECODER")
    for i, e in enumerate("XYZ"):
        y = 0.72 - i * 0.26
        ax.text(0.012, y + 0.055, f"S{e}P\nS{e}N", ha="left", va="center",
                fontsize=7.5, color=TINTA, family="monospace")
        caja(ax, 0.11, y, 0.19, 0.13, "OPAM_LIN", "40 dB", tam=8.5)
        flecha(ax, 0.062, y + 0.065, 0.108, y + 0.065)
        flecha(ax, 0.30, y + 0.065, 0.38, y + 0.065, f"S{e}")
    #  The three comparators do NOT compare an axis against a threshold: they
    #  compare the axes against EACH OTHER, in pairs. That is why there are
    #  three of them for three axes, and it is the part of the diagram that
    #  earns its place.
    for i, par in enumerate(("X vs Y", "X vs Z", "Y vs Z")):
        y = 0.72 - i * 0.26
        caja(ax, 0.40, y, 0.16, 0.13, "COMP", par, AMBAR, AMBAR_CLARO, tam=8.5)
        #  Onto the decoder's own left edge, at its own height: an arrow that
        #  stops short of the block it feeds reads as an unconnected net.
        flecha(ax, 0.56, y + 0.065, 0.658, 0.635 - i * 0.115,
               ("XY", "XZ", "YZ")[i])
    caja(ax, 0.66, 0.36, 0.17, 0.36, "DECODER", "which axis wins", tam=9)
    for i, e in enumerate("XYZ"):
        flecha(ax, 0.83, 0.635 - i * 0.115, 0.93, 0.635 - i * 0.115, e)
    ax.text(0.48, 0.045,
            "three axes, three PAIRWISE comparisons: the decoder needs to know "
            "the order, not the values",
            ha="center", va="bottom", fontsize=7.8, color=TINTA, style="italic")
    guarda(fig, "diag_GRADIENT2")


def weight():
    """The vote counter: four binary-weighted branches on one summing node."""
    fig, ax = lienzo(9.0, 4.2,
                     "WEIGHT — four EQUAL current branches summing on WE")
    for i, (n, p) in enumerate((("VA", "equal"), ("VB", "equal"),
                                ("VC", "equal"), ("VD", "equal"))):
        y = 0.76 - i * 0.19
        ax.text(0.03, y + 0.05, n, ha="left", va="center", fontsize=8.5,
                color=TINTA, family="monospace")
        caja(ax, 0.13, y, 0.24, 0.11, f"branch {p}",
             "nfet tail", AMBAR, AMBAR_CLARO, tam=8)
        flecha(ax, 0.10, y + 0.05, 0.128, y + 0.05)
        flecha(ax, 0.37, y + 0.05, 0.55, 0.47, "")
    caja(ax, 0.55, 0.40, 0.15, 0.15, "WE", "sum node", tam=9)
    flecha(ax, 0.70, 0.475, 0.80, 0.475, "OUT")
    ax.text(0.47, 0.05,
            "current mode: the branches are summed by joining wires, so the "
            "count costs no extra stage.\n"
            "WE depends on HOW MANY vote, not on which: the output flips at "
            "3 of 4. 17 nfet + 2 pfet, no sub-blocks.",
            ha="center", va="bottom", fontsize=7.8, color=TINTA, style="italic")
    guarda(fig, "diag_WEIGHT")


def comp_out():
    """The output stage: a buffer chain that also produces the complement."""
    fig, ax = lienzo(9.0, 2.9,
                     "COMP_OUT — 3 × INV_1: buffers the vote and gives its "
                     "complement")
    ax.text(0.02, 0.55, "IN\n(from WEIGHT)", ha="left", va="center",
            fontsize=8, color=TINTA, family="monospace")
    x = 0.17
    for i in range(3):
        caja(ax, x, 0.42, 0.15, 0.26, "INV_1", f"stage {i + 1}", tam=8.5)
        if i:
            flecha(ax, x - 0.05, 0.55, x - 0.008, 0.55)
        x += 0.20
    flecha(ax, 0.145, 0.55, 0.168, 0.55)
    for yy, nom in ((0.62, "OUT"), (0.48, "OUT_N")):
        flecha(ax, 0.72, yy, 0.84, yy)
        ax.text(0.85, yy, nom, ha="left", va="center", fontsize=7.8,
                color=TINTA, family="monospace")
    ax.text(0.48, 0.10,
            "the pair leaves the chip as XP/XN, YP/YN, ZP/ZN: rail-to-rail, "
            "so they take a digital pad",
            ha="center", va="bottom", fontsize=7.8, color=TINTA, style="italic")
    guarda(fig, "diag_COMP_OUT")


def main() -> int:
    nav2()
    gradient2()
    weight()
    comp_out()
    return 0


if __name__ == "__main__":
    sys.exit(main())
