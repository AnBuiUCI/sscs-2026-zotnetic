"""Monta GRADIENT3 y el top GRADIENT_NAV3 a partir de la geometria de la caja.

El cableado de las cuatro cadenas NO se escribe a mano: sale de invertir la
matriz de posiciones de cada trio, que es la unica forma de que los signos sean
los que son y no los que uno cree recordar.
"""
import itertools
import sys

import numpy as np

sys.path.insert(0, "/foss/designs/a_zonetic2026/XSCHEM_v2")
from hacer_sch import Hoja
from hacer_sym import sym
from pathlib import Path

#  Los cuatro sensores en los vertices del tetraedro, dentro de un cubo de 1000
#  um de lado. Con Lz = Lxy la compensacion de caja vale 1, asi que no hacen
#  falta ni las resistencias de compensacion ni las patas de parametro.
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

    Las resistencias no pueden vivir en una celda propia: el generador saca el
    ancho de la celda de las filas de transistores, y una celda solo de
    resistencias nace con 1 um y no hay serpentin que quepa. Aqui caben porque el
    OPAM ya trae canal de serpentines y 85 um de celda, y ademas es mejor sitio
    -- el nodo de suma es de alta impedancia y no hay que sacarlo a ruteo global.
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
            #  el puente tiene 500 kohm de salida, asi que con 100 kohm la senal
            #  se atenua 10.5 veces y con 1 Mohm solo 1.5, pero 1 Mohm son 333 um
            #  de poly por resistencia. 500 kohm deja la atenuacion en 2.5 veces
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
            #  de alta impedancia, pero sobre todo es lo que le da a esa net
            #  presencia en la fila de transistores: sin ella el generador no le
            #  crea carril de metal2 ("trunk de 0.00 um en 0 tramos") y el
            #  terminal de la resistencia se queda sin donde aterrizar. Con W y L
            #  de 2 um son unos 6 fF, o sea 3 ns: invisible para un gradiente.
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
    #  Un amplificador por componente, con sus cuatro resistencias sumadoras
    #  dentro: promedia los dos sensores de cada lado y saca la componente.
    for i, e in enumerate("XYZ"):
        H.macro(OS, f"xa{e}", -600, -400 + 300 * i,
                {"VDD": "VDD", "VSS": "VSS", "OUT": f"S{e}",
                 "A1": f"S{e}P1", "A2": f"S{e}P2",
                 "B1": f"S{e}N1", "B2": f"S{e}N2"})
    #  Las tres parejas de componentes. Mismo orden de patas que GRADIENT2, donde
    #  estas tres redes salian sin nombre (#net1, #net2, #net3).
    for nom, a, b in (("XY", "X", "Y"), ("XZ", "X", "Z"), ("YZ", "Y", "Z")):
        H.macro(CO, f"xc{nom}", 0, {"XY": -400, "XZ": -100, "YZ": 200}[nom],
                {"VDD": "VDD", "VSS": "VSS", "INN": f"S{a}", "INP": f"S{b}",
                 "OUT": nom})
    #  Los DOS decodificadores cuelgan de los MISMOS tres comparadores: sacar el
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
        "* GRADIENT3 = una cadena completa: tres componentes y LOS DOS EXTREMOS.\n"
        "*\n"
        "* Cada componente del gradiente se forma promediando dos sensores en la\n"
        "* entrada del amplificador (las resistencias van dentro de OPAM_SUMA), se\n"
        "* comparan las tres dos a dos, y esas MISMAS tres comparaciones alimentan\n"
        "* dos decodificadores: el que senala un extremo y el que senala el otro.\n"
        "*\n"
        "* La diferencia con GRADIENT2 es doble. Una, que lo que se compara son\n"
        "* COMPONENTES DEL GRADIENTE y no lecturas crudas de sensor. Y dos, que hay\n"
        "* dos decodificadores en vez de uno, que es lo que permite dar el SENTIDO:\n"
        "* con un solo extremo, cuando el gradiente apunta hacia el lado contrario\n"
        "* la componente senalada vale casi cero y decide el ruido.\n"
        "*\n"
        "* QUE GRADIENTE. Cada sensor lee la MAGNITUD del campo, |B|, en su\n"
        "* posicion: un escalar. Los cuatro muestrean ese campo escalar y lo que se\n"
        "* reconstruye es grad|B|, que apunta hacia donde la magnitud CRECE, o sea\n"
        "* hacia la fuente.\n"
        "*\n"
        "* A y B son los dos extremos. Cual es el minimo y cual el maximo depende\n"
        "* del signo de la cadena analogica, asi que se fija MIDIENDO y no aqui.\n"
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
            #  De cada componente salen exactamente dos sensores con peso +-0.5.
            #  El signo se hace eligiendo que pata del puente entra por donde:
            #  peso positivo manda P al lado P, y negativo las cruza.
            usados = [(trio[j] + 1, Mi[r, j]) for j in range(3)
                      if abs(Mi[r, j]) > 1e-9]
            assert len(usados) == 2, usados
            for k, (s, w) in enumerate(usados, 1):
                p, n = ("P", "N") if w > 0 else ("N", "P")
                con[f"S{e}P{k}"] = f"S{s}{p}"
                con[f"S{e}N{k}"] = f"S{s}{n}"
        con.update({f"{e}{x}": f"{e}{x}{c}" for e in "XYZ" for x in "AB"})
        H.macro(G3, f"xg{c}", -600, -900 + 500 * c, con)
    #  Seis votaciones, una por salida. Cada WEIGHT suma las cuatro cadenas en un
    #  nodo analogico y el COMP_OUT lo pasa a digital: es el mismo par que ya usa
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
