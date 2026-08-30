"""Builds parallel variants of OPAM_LIN_flat from ONE freshly netlisted source.

The point of this bench is a single question the algebra cannot answer: the
gain of a folded-cascode amplifier is Gm x RFB, and here Gm IS the input pair's
gm, so when the sheet drops from 3 kohm/sq to 1 kohm/sq the only place the lost
factor of three can come from is that gm. How gm responds to width depends on
the inversion level:

    strong inversion   gm ~ sqrt(W . I)   -> W x 9 buys x3 for free
    weak inversion     gm = I / (n.Vt)    -> W buys NOTHING, only current does

Rather than guess, every variant is simulated side by side, each on its own
supply, from the same netlist.

NOTE ON THE MIRRORS: XM31/XM35 and XM25/XM26 look like a place to put current
gain, but they are the differential-to-single-ended loads. Their ratio has to
stay 1:1 or the pair does not balance -- the mirror would push 3.I/2 into a
node the input device only drains I/2 from.
"""
from __future__ import annotations

import re
from pathlib import Path

#: The feedback resistor. Same drawn poly in every case -- 5 strips of
#: 1 x 76.45 um -- so the only thing that moves is the fab's implant.
HOJA = {"ppolyf_u_3k": 3000.0, "ppolyf_u_1k": 1000.0}

#: The input devices, and nothing else. M15/M16 are the pfet pair and M21/M22
#: the nfet one; the 1.1/1.0 asymmetry of the first is deliberate -- it is what
#: puts the +24 mV of offset on the positive side -- so scaling keeps the ratio.
PAR = ("XM15", "XM16", "XM21", "XM22")

#: The tail sources, source device AND cascode. The pfet pair hangs off two
#: parallel cascoded branches (M11->M12 and M13->M14, both landing on net11)
#: and the nfet pair off another two (M18->M17 and M20->M19, landing on net12).
#: The cascode is scaled with its source: it only passes the current, but left
#: at its old width its own vdsat climbs and eats the headroom the pair needs.
COLA_P = ("XM11", "XM12", "XM13", "XM14")     # net11, la cola del par pfet
COLA_N = ("XM17", "XM18", "XM19", "XM20")     # net12, la del par nfet
COLA = COLA_P + COLA_N


def _lee(spice: Path) -> list[str]:
    """The body of the subcircuit, with xschem's commented-out delimiters gone."""
    txt = spice.read_text().splitlines()
    ini = next(i for i, l in enumerate(txt) if l.startswith("**.subckt"))
    fin = next(i for i, l in enumerate(txt) if l.startswith("**.ends"))
    return txt[ini + 1:fin]


def _escala_w(linea: str, factor: float) -> str:
    """Multiplies the W= of one device line. The ad/as/pd/ps go with W already:
    they are written as expressions in W, so they follow on their own."""
    def rep(m):
        return f"W={float(m.group(1)) * factor}u"
    return re.sub(r"W=([0-9.]+)u", rep, linea, count=1)


#: The two input pairs on their own, so each can be moved without the other.
PAR_P = ("XM15", "XM16")            # pfet pair, 1.1u/1.0u -- the 1.1 is the offset
PAR_N = ("XM21", "XM22")            # nfet pair, 1u/1u

#: The output stage. XM43 is the pull-up (pfet W=0.5u with m=4, so 2 um of
#: width) and XM44 the pull-down (nfet 1u). The documented history of this cell
#: says they have to move TOGETHER: raising only XM43 lets the pfet win and OUT
#: sticks to VDD.
SALIDA = ("XM43", "XM44")
SAL_UP, SAL_DN = ("XM43",), ("XM44",)

#: What actually feeds the summing node G_OUT_P: XM33/XM28 are the class-AB
#: pair sitting across it and XM32/XM27 their drivers; XM29/XM30 are the
#: cascodes that carry the folded signal current up to it.
ETAPA2 = ("XM27", "XM28", "XM32", "XM33")
CASCODO = ("XM29", "XM30")

#: The INP side of each pair, on its own. The +24 mV of offset this cell is
#: supposed to have is not an accident: it is XM15 drawn at 1.1u against
#: XM16's 1.0u, deliberately, so the ramp falls on positive V5. When the nfet
#: pair takes over the transconductance that asymmetry stops mattering and the
#: offset has to be rebuilt on XM21 instead.
#: The INP side of each pair (`asim_*`) and the INN side (`asim_*_i`). Which
#: one to use is not obvious and was measured: on the nfet pair, growing the
#: INP device XM21 pushes the offset NEGATIVE, the opposite of what growing
#: XM15 does on the pfet one, so the positive ramp is rebuilt on XM22.
ASIM_P, ASIM_N = ("XM15",), ("XM21",)
ASIM_P_I, ASIM_N_I = ("XM16",), ("XM22",)

#: The Miller capacitors. Gain-bandwidth goes as Gm/Cc, so tripling Gm without
#: touching them makes the cell three times faster and eats the phase margin.
#: They cost NO silicon: a MIM sits on Metal4/Metal5, over everything else.
MILLER = ("XC1", "XC3")


#: Groups a scaling can name. `par` moves both pairs at once.
GRUPOS = {"par": PAR, "par_p": PAR_P, "par_n": PAR_N,
          "cola": COLA, "cola_p": COLA_P, "cola_n": COLA_N,
          "salida": SALIDA, "sal_up": SAL_UP, "sal_dn": SAL_DN,
          "etapa2": ETAPA2, "cascodo": CASCODO,
          "asim_p": ASIM_P, "asim_n": ASIM_N,
          "asim_p_i": ASIM_P_I, "asim_n_i": ASIM_N_I,
          "miller": MILLER}


def _escala_c(linea: str, factor: float) -> str:
    """Multiplies a MIM's width. Scaling the width and not the length keeps the
    shape sensible: 4 x 25 um becomes 12 x 25, not 4 x 75."""
    def rep(m):
        return f"c_width={float(m.group(1)) * factor}e-6"
    return re.sub(r"c_width=([0-9.]+)e-6", rep, linea, count=1)


def _escala_l(linea: str, largo: float) -> str:
    return re.sub(r"L=[0-9.]+u", f"L={largo}u", linea, count=1)


def variante(cuerpo: list[str], nombre: str, modelo: str,
             w_par: float = 1.0, w_cola: float = 1.0,
             escalas: dict[str, float] | None = None,
             l_par: float | None = None) -> tuple[str, float]:
    """One renamed subcircuit. Returns its text and the resulting RFB in ohm.

    `escalas` names groups from GRUPOS explicitly and overrides w_par/w_cola;
    `l_par` rewrites the input pair's channel length.
    """
    if escalas is None:
        escalas = {"par": w_par, "cola": w_cola}
    porDisp: dict[str, float] = {}
    for grupo, k in escalas.items():
        for d in GRUPOS[grupo]:
            porDisp[d] = porDisp.get(d, 1.0) * k

    fuera, rfb = [], 0.0
    for l in cuerpo:
        cual = l.split()[0] if l.split() else ""
        if cual in porDisp:
            l = _escala_c(l, porDisp[cual]) if cual in MILLER \
                else _escala_w(l, porDisp[cual])
        if l_par is not None and cual in PAR:
            l = _escala_l(l, l_par)
        if cual == "XRFB":
            l = re.sub(r"ppolyf_u_\dk", modelo, l)
            w = float(re.search(r"r_width=([0-9.e-]+)", l).group(1))
            lo = float(re.search(r"r_length=([0-9.e-]+)", l).group(1))
            s = int(re.search(r"s=(\d+)", l).group(1))
            rfb = s * lo / w * HOJA[modelo]
        fuera.append(l)
    cab = f".subckt {nombre} INN INP VDD VSS OUT"
    return "\n".join([cab, *fuera, ".ends", ""]), rfb
