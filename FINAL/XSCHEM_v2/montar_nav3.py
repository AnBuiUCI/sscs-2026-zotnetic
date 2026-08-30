"""Monta GRADIENT3 y el top GRADIENT_NAV3 a partir de la geometria de la caja.

The wiring of the four chains is NOT written by hand: it comes from inverting
each triad's position matrix, which is the only way for the signs to be what
they are and not what one thinks one remembers.
"""
import itertools
import sys

import numpy as np

sys.path.insert(0, "/foss/designs/a_zonetic2026/XSCHEM_v2")
from hacer_sch import Hoja
from hacer_sym import sym
from pathlib import Path

#  The four sensors at the tetrahedron vertices, inside a 1000 um cube. With
#  Lz = Lxy the box compensation is 1, so neither the compensation resistors nor
#  the parameter pins are needed.
SIG = [(-1, +1, +1), (+1, -1, +1), (-1, -1, -1), (+1, +1, -1)]
TRIOS = list(itertools.combinations(range(4), 3))

OS = "a_zonetic2026/XSCHEM_v2/OPAM_SUMA.sym"
NF = "symbols/nfet_06v0.sym"
RP = "symbols/ppolyf_u_3k.sym"
CO = "a_zonetic2026/XSCHEM/OPAM/COMP.sym"
DE = "a_zonetic2026/XSCHEM/DECODER/DECODER.sym"
DM = "a_zonetic2026/XSCHEM_v2/DECODER_MAX.sym"
G3 = "a_zonetic2026/XSCHEM_v2/GRADIENT3.sym"
WE = "a_zonetic2026/XSCHEM/WEIGTH/WEIGHT.sym"
CX = "a_zonetic2026/XSCHEM/WEIGTH/COMP_OUT.sym"

ENT3 = [f"S{e}{s}{k}" for e in "XYZ" for s in "PN" for k in (1, 2)]
SAL3 = [f"{e}{x}" for x in "AB" for e in "XYZ"]


def opam_suma():
    """El amplificador lineal con sus cuatro resistencias sumadoras dentro.

    The resistors cannot live in a cell of their own: the generator takes the
    cell width from the transistor rows, and a resistors-only cell is born 1 um
    wide with no serpentine that fits. They fit here because the OPAM already
    has a serpentine channel and 85 um of cell, and besides it is a better place
    -- the summing node is high impedance and need not go out to global routing.
    """
    H = Hoja()
    H.macro("a_zonetic2026/XSCHEM/OPAM/OPAM_LIN.sym", "xamp", 0, 0,
            {"VDD": "VDD", "VSS": "VSS", "INP": "NSP", "INN": "NSN",
             "OUT": "OUT"})
    y = -450
    for nodo, pre in (("NSP", "A"), ("NSN", "B")):
        for j in (1, 2):
            ent = f"{pre}{j}"
            #  La resistencia sumadora: 3 tramos de 55.56 um a 3 kohm/cuadro, o
            #  sea 500 kohm. Es el valor que equilibra atenuacion contra area:
            #  the bridge has 500 kohm of output, so with 100 kohm the signal is
            #  attenuated 10.5 times and with 1 Mohm only 1.5, but 1 Mohm is
            #  333 um of poly per resistor. 500 kohm leaves attenuation at 2.5
            #  por la mitad de area.
            H.lin.append(f"C {{{RP}}} -250 {y} 0 0 {{name=R{ent}\n"
                         "W=1e-6\nL=55.56e-6\nmodel=ppolyf_u_3k\n"
                         "spiceprefix=X\nm=1\ns=3\n"
                         'format="@spiceprefix@name @pinlist @model r_width=@W '
                         'r_length=@L m=@m s=@s"}')
            for dx, dy, lab in ((0, -30, ent), (0, 30, nodo), (-20, 0, "VSS")):
                H.n += 1
                H.lin.append(f"C {{devices/lab_pin.sym}} {-250+dx} {y+dy} 0 0 "
                             f"{{name=r{H.n} sig_type=std_logic lab={lab}}}")
            #  Y un condensador MOS en la entrada. Filtra el nodo de suma, que es
            #  high impedance, but above all it is what gives that net
            #  presence in the transistor row: without it the generator creates
            #  crea carril de metal2 ("trunk de 0.00 um en 0 tramos") y el
            #  the resistor terminal has nowhere to land. With W and L of 2 um
            #  it is about 6 fF, i.e. 3 ns: invisible to a gradient.
            H.macro(NF, f"xmc{ent}", -560, y,
                    {"G": ent, "D": "VSS", "S": "VSS", "B": "VSS"})
            H.lin[-5] = H.lin[-5].replace(
                "{name=xmc" + ent + "}",
                "{name=xmc" + ent + "\n" + "\n".join((
                    "L=2u", "W=2u", "nf=1", "m=1",
                    "ad=\"'int((nf+1)/2) * W/nf * 0.18u'\"",
                    "pd=\"'2*int((nf+1)/2) * (W/nf + 0.18u)'\"",
                    "as=\"'int((nf+2)/2) * W/nf * 0.18u'\"",
                    "ps=\"'2*int((nf+2)/2) * (W/nf + 0.18u)'\"",
                    "nrd=\"'0.18u / W'\"", "nrs=\"'0.18u / W'\"",
                    "sa=0", "sb=0", "sd=0",
                    "model=nfet_06v0", "spiceprefix=X", "")) + "}")
            y += 200
    for i, q in enumerate(("A1", "A2", "B1", "B2")):
        H.puerto("ipin", q, -800, -450 + 60 * i)
    H.puerto("opin", "OUT", 420, 0)
    H.puerto("iopin", "VDD", 420, 60)
    H.puerto("iopin", "VSS", 420, 120)
    H.escribir("OPAM_SUMA.sch")
    Path("OPAM_SUMA.sym").write_text(sym(
        "OPAM_SUMA", [(q, "in") for q in ("A1", "A2", "B1", "B2")],
        [("OUT", "out")], [("VDD", "inout")], [("VSS", "inout")]))


def gradient3():
    H = Hoja()
    #  One amplifier per component, with its four summing resistors inside: it
    #  averages the two sensors on each side and gives the component.
    for i, e in enumerate("XYZ"):
        H.macro(OS, f"xa{e}", -600, -400 + 300 * i,
                {"VDD": "VDD", "VSS": "VSS", "OUT": f"S{e}",
                 "A1": f"S{e}P1", "A2": f"S{e}P2",
                 "B1": f"S{e}N1", "B2": f"S{e}N2"})
    #  The three component pairs. Same pin order as GRADIENT2, where
    #  estas tres redes salian sin nombre (#net1, #net2, #net3).
    for nom, a, b in (("XY", "X", "Y"), ("XZ", "X", "Z"), ("YZ", "Y", "Z")):
        H.macro(CO, f"xc{nom}", 0, {"XY": -400, "XZ": -100, "YZ": 200}[nom],
                {"VDD": "VDD", "VSS": "VSS", "INN": f"S{a}", "INP": f"S{b}",
                 "OUT": nom})
    #  BOTH decoders hang off the SAME three comparators: getting the
    #  extremo contrario cuesta tres puertas, no otra cadena analogica.
    for s, nom, suf, y in ((DE, "xdA", "A", -300), (DM, "xdB", "B", 100)):
        H.macro(s, nom, 600, y,
                {"VDD": "VDD", "VSS": "VSS", "XY": "XY", "XZ": "XZ", "YZ": "YZ",
                 "X": f"X{suf}", "Y": f"Y{suf}", "Z": f"Z{suf}"})
    for i, p in enumerate(ENT3):
        H.puerto("ipin", p, -1200, -600 + 40 * i)
    for i, p in enumerate(SAL3):
        H.puerto("opin", p, 1200, -600 + 40 * i)
    H.puerto("iopin", "VDD", 1200, -100)
    H.puerto("iopin", "VSS", 1200, -60)
    H.texto(
        "* GRADIENT3 = a complete chain: three components and BOTH EXTREMES.\n"
        "*\n"
        "* Each gradient component is formed by averaging two sensors at the\n"
        "* amplifier input (the resistors live inside OPAM_SUMA), the three are\n"
        "* comparan las tres dos a dos, y esas MISMAS tres comparaciones alimentan\n"
        "* two decoders: the one naming one extreme and the one naming the other.\n"
        "*\n"
        "* The difference from GRADIENT2 is twofold. One, what is compared are\n"
        "* GRADIENT COMPONENTS and not raw sensor readings. And two, there are\n"
        "* two decoders instead of one, which is what allows giving the SENSE:\n"
        "* with a single extreme, when the gradient points the other way\n"
        "* la componente senalada vale casi cero y decide el ruido.\n"
        "*\n"
        "* WHICH GRADIENT. Each sensor reads the MAGNITUDE of the field, |B|, at\n"
        "* its position: a scalar. The four sample that scalar field and what is\n"
        "* reconstructed is grad|B|, which points where the magnitude GROWS, that\n"
        "* hacia la fuente.\n"
        "*\n"
        "* A and B are the two extremes. Which is the minimum and which the\n"
        "* maximum depends on the analogue chain sign, so it is fixed by MEASURING.\n"
        "* Medido: el lado B es el maximo, o sea el que apunta hacia la fuente.")
    H.escribir("GRADIENT3.sch")
    Path("GRADIENT3.sym").write_text(sym(
        "GRADIENT3", [(p, "in") for p in ENT3], [(p, "out") for p in SAL3],
        [("VDD", "inout")], [("VSS", "inout")]))


def top():
    H = Hoja()
    for c, trio in enumerate(TRIOS, 1):
        Mi = np.linalg.inv(np.array([SIG[i] for i in trio], float))
        con = {"VDD": "VDD", "VSS": "VSS"}
        for r, e in enumerate("XYZ"):
            #  Each component takes exactly two sensors with weight +-0.5.
            #  The sign is made by choosing which bridge leg enters where:
            #  positive weight sends P to the P side, negative crosses them.
            usados = [(trio[j] + 1, Mi[r, j]) for j in range(3)
                      if abs(Mi[r, j]) > 1e-9]
            assert len(usados) == 2, usados
            for k, (s, w) in enumerate(usados, 1):
                p, n = ("P", "N") if w > 0 else ("N", "P")
                con[f"S{e}P{k}"] = f"S{s}{p}"
                con[f"S{e}N{k}"] = f"S{s}{n}"
        con.update({f"{e}{x}": f"{e}{x}{c}" for e in "XYZ" for x in "AB"})
        H.macro(G3, f"xg{c}", -600, -900 + 500 * c, con)
    #  Six votes, one per output. Each WEIGHT sums the four chains into an
    #  analogue node and the COMP_OUT turns it digital: the same pair already used
    #  el top de hoy, y la herramienta lo funde en el macro WEIGHT_COMP.
    for i, s in enumerate(SAL3):
        H.macro(WE, f"xw{s}", 600, -900 + 200 * i,
                {"VDD": "VDD", "GND": "VSS", "OUT": f"V{s}",
                 **{v: f"{s}{c}" for v, c in zip(("VA", "VB", "VC", "VD"),
                                                 (1, 2, 3, 4))}})
        H.macro(CX, f"xo{s}", 1200, -900 + 200 * i,
                {"VDD": "VDD", "VSS": "VSS", "IN": f"V{s}",
                 "OUT": f"{s}P", "OUT_N": f"{s}N"})
    for i, s in enumerate([f"S{k}{p}" for k in (1, 2, 3, 4) for p in "PN"]):
        H.puerto("ipin", s, -1600, -1000 + 40 * i)
    for i, s in enumerate([f"{o}{p}" for o in SAL3 for p in "PN"]):
        H.puerto("opin", s, 1800, -1000 + 40 * i)
    H.puerto("iopin", "VDD", 1800, 200)
    H.puerto("iopin", "VSS", 1800, 240)
    H.escribir("GRADIENT_NAV3.sch")


if __name__ == "__main__":
    opam_suma()
    gradient3()
    top()
    print("GRADIENT3 y GRADIENT_NAV3 montados")
