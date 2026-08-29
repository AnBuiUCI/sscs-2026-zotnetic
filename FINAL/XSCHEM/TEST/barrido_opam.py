#!/usr/bin/env python3
"""Sensitivity sweep of OPAM_LIN: how much gain the 1 kohm sheet costs, and
where the missing factor of three can be bought back.

Every variant is built from the SAME freshly netlisted schematic, they all run
in one deck side by side, and each has its own supply so the current draw is
comparable without bias.

    ./barrido_opam.py [netlist.spice]
"""
from __future__ import annotations

import os
import subprocess
import sys
from pathlib import Path

import numpy as np

import variantes_opam as V

AQUI = Path(__file__).resolve().parent
SIM = AQUI / "simulation" / "barrido_opam"
FUENTE = AQUI.parent / "OPAM/simulation/OPAM_LIN_flat.sch/OPAM_LIN_flat.spice"

#: Output range over which linearity is required, the same one the g100 bench
#: uses so the numbers can be put next to each other.
BAJO, ALTO = 1.0, 4.0

#: Common mode. NOT half rail: this cell's gain depends strongly on where OUT
#: rests -- ~99 V/V with OUT at 2.5 V and ~39 V/V at 3.0 V -- and 2.0 V is what
#: leaves it at 2.18 V, in the middle of the window. Same as run_opam_g100.sh.
VCM = 2.0

#  Each case is (name, model, scalings by group, L of the pair or None).
#  The first pass answered the first question -- width buys gain, current does
#  not -- and raised the next one: the INL goes from 0.16 % to 1.05 % on the way.
#  This pass asks WHERE that damage comes from, by moving one thing at a time.
#  El punto encontrado: par nfet x7.5 para la ganancia, cascodo x2 para la
#  corriente que la RFB pequena pide al nodo suma, y XM43 x2 para el techo de
#  la excursion. Falta reconstruir el offset y recortar el consumo.
#: THE DESIGN, now IN the schematic. What is listed here is the way BACK: the
#: netlist this bench reads is already the new cell, so the old one is rebuilt
#: by undoing the four changes. Keeping it means the comparison stays honest
#: run after run instead of being a number copied into a comment.
#:
#:   XM21  1.0u -> 7.5u    el par nfet es el que pone la transconductancia
#:   XM22  1.0u -> 8.5u    y su asimetria, el offset positivo (antes XM15/XM16)
#:   XM29  5u   -> 10u     el cascodo, que es donde se cura la INL: con la RFB
#:   XM30  5u   -> 10u       pequena el nodo suma pide el triple de corriente
#:   XM43  0.5u -> 1.0u    (m=4, o sea 2 -> 4 um) el techo de la excursion
#:   XM15  1.1u -> 0.55u   el par pfet ya no lleva transconductancia, asi que
#:   XM16  1.0u -> 0.5u      estrecharlo y estrechar los excitadores de la
#:   XM27  2.5u -> 2.0u      etapa AB devuelve los 0.24 mW que costaba lo de
#:   XM28  2.5u -> 2.0u      arriba, sin tocar la linealidad
#:   XM32  5u   -> 4.0u
#:   XM33  5u   -> 4.0u
#:   XC1   4x25 -> 8x25 um  el Miller: GBW va como Gm/Cc, y con Gm x3 y los
#:   XC3   4x25 -> 8x25 um    condensadores quietos se perdian 18 grados de
#:                            margen de fase. No cuestan silicio: van arriba.
#:
#: Y la RFB pasa de ppolyf_u_3k a ppolyf_u_1k SIN TOCAR EL DIBUJO: las mismas
#: cinco tiras de 1 x 76.45 um, 382 cuadros, que con la hoja de este shuttle
#: valen 382 kohm en vez de 1.147 Mohm.
COMO_ANTES = {"par_n": 1 / 7.5, "asim_n_i": 7.5 / 8.5,
              "cascodo": 0.5, "sal_up": 0.5,
              "par_p": 2.0, "asim_p": 1.1 / 1.0 / (0.55 / 0.5),
              "etapa2": 1.25, "miller": 0.5}

CASOS = [
    ("COMO_ANTES", "ppolyf_u_3k", COMO_ANTES, None),   # la celda que se sustituye
    ("SIN_TOCAR",  "ppolyf_u_1k", COMO_ANTES, None),   # esa misma con la hoja de 1k
    ("NUEVA",      "ppolyf_u_1k", {},         None),   # la del esquematico, tal cual
]


def _cabecera(cuerpo, l: list[str]) -> dict:
    """The subcircuit variants, shared by both benches."""
    rfb = {}
    for nom, modelo, esc, lp in CASOS:
        txt, r = V.variante(cuerpo, nom, modelo, escalas=esc or {"par": 1.0}, l_par=lp)
        rfb[nom] = r
        l.append(txt)
    return rfb


def deck_ac(fuente: Path, esquina: str = "typical", temp: float = 27.0,
            vdd: float = 5.0, nombre: str = "ac") -> tuple[str, dict]:
    """Open-loop response, for the phase margin.

    An .ac cannot just be launched on an amplifier whose inputs are gates: with
    no DC path they float, and with the offset the operating point lands
    saturated, where linearising means nothing. So each cell closes a unity
    loop through a HUGE inductor -- a short at DC, so it finds its own offset
    whatever it is -- with a huge capacitor holding the node. In AC the
    inductor opens and the capacitor shorts, and what is measured is the OPEN
    loop. Same trick the g100 bench uses.
    """
    l = _preludio(esquina, temp)
    rfb = _cabecera(V._lee(fuente), l)
    l += [f"Vin vin 0 DC {VCM} AC 1", ""]
    for i, (nom, *_ ) in enumerate(CASOS, 1):
        l.append(f"Vd{i} vdd{i} 0 DC {vdd}")
        l.append(f"Lfb{i} out{i} fb{i} 1G")
        l.append(f"Cfb{i} fb{i} 0 1")
        #  INN INP VDD VSS OUT -- INN is the one that takes the feedback
        l.append(f"X{i} fb{i} vin vdd{i} 0 out{i} {nom}")
    l.append("")
    salidas = " ".join(f"v(out{i})" for i in range(1, len(CASOS) + 1))
    l += [".control", "ac dec 100 1 1G", f"wrdata {nombre}.txt {salidas}",
          ".endc", ".end", ""]
    return "\n".join(l), rfb


def _preludio(esquina: str = "typical", temp: float = 27.0) -> list[str]:
    modelos = os.environ.get("180MCU_MODELS", "/foss/pdks/gf180mcuD/libs.tech/ngspice")
    l = [f'.include "{modelos}/design.ngspice"']
    for lib in (esquina, "cap_mim", "res_typical", "moscap_typical", "mimcap_typical"):
        l.append(f'.lib "{modelos}/sm141064.ngspice" {lib}')
    l += [f".temp {temp}", ""]
    return l


def deck(fuente: Path, esquina: str = "typical", temp: float = 27.0,
         vdd: float = 5.0, nombre: str = "dc") -> tuple[str, dict]:
    l = _preludio(esquina, temp)
    rfb = _cabecera(V._lee(fuente), l)

    #  V5 is the differential input and Vcm holds the pair up: the inputs are
    #  MOS gates and have no DC path of their own, so without Vcm ngspice's
    #  gmin sets the operating point and the transfer comes out as rubbish.
    l += [f"V5 va vb DC 0", f"Vcm vb 0 DC {VCM}", ""]
    for i, (nom, *_ ) in enumerate(CASOS, 1):
        l.append(f"Vd{i} vdd{i} 0 DC {vdd}")
        #  port order of the subcircuit: INN INP VDD VSS OUT
        l.append(f"X{i} vb va vdd{i} 0 out{i} {nom}")
    l.append("")

    salidas = " ".join(f"v(out{i})" for i in range(1, len(CASOS) + 1))
    potencia = " ".join(f"v(vdd{i})*i(vd{i})" for i in range(1, len(CASOS) + 1))
    l += [".control",
          #  Wide enough for the low-gain cases: at 34 V/V the transition is
          #  150 mV across, and the offset moves with the sizing.
          "dc V5 -0.6 0.4 100u",
          f"wrdata {nombre}.txt {salidas} {potencia}",
          ".endc",
          ".end", ""]
    return "\n".join(l), rfb


def mide(x: np.ndarray, v: np.ndarray) -> dict:
    """Gain, INL, offset and swing of one transfer curve."""
    s = np.gradient(v, x)
    #  Gain is the MAX of the slope, never -MIN: the minimum is the artefact
    #  cliff at the ends of the sweep, and reporting it was a bug in the
    #  original bench.
    gan = s.max()
    cruce = np.where(np.diff(np.sign(v - 2.5)))[0]
    off = x[cruce[0]] if len(cruce) else float("nan")
    util = (v >= BAJO) & (v <= ALTO)
    if util.sum() >= 20:
        m, b = np.polyfit(x[util], v[util], 1)
        inl = abs(v[util] - (m * x[util] + b)).max() / (ALTO - BAJO) * 100
        gan_util = m
    else:
        inl, gan_util = float("nan"), float("nan")
    return dict(gan=gan, gan_util=gan_util, inl=inl, off=off, n=int(util.sum()))


def corre(nombre: str, texto: str) -> Path | None:
    """Writes a deck, deletes its output FIRST, runs it, returns the data file.

    Deleting first is the point: when ngspice dies the file from the previous
    run is still on disk and loadtxt reads it happily. The first time that
    happened the table came out with the previous run's numbers under the
    current run's case names, and nothing said a word.
    """
    SIM.mkdir(parents=True, exist_ok=True)
    (SIM / f"{nombre}.spice").write_text(texto)
    salida = SIM / f"{nombre}.txt"
    salida.unlink(missing_ok=True)
    r = subprocess.run(["ngspice", "-b", f"{nombre}.spice"], cwd=SIM,
                       capture_output=True, text=True)
    (SIM / f"{nombre}.log").write_text(r.stdout + r.stderr)
    for l in (r.stdout + r.stderr).splitlines():
        if any(k in l.lower() for k in ("error", "singular", "no dc path")):
            print("  ngspice:", l.strip(), file=sys.stderr)
    if not salida.is_file():
        print(f"  ngspice no escribio {salida}; mira {SIM/(nombre+'.log')}",
              file=sys.stderr)
        return None
    return salida


def _pm(d: np.ndarray, i: int) -> tuple[float, float, float]:
    """(DC gain in dB, 0 dB crossing in Hz, phase margin in degrees)."""
    f = d[:, 3 * i]
    mag = np.hypot(d[:, 3 * i + 1], d[:, 3 * i + 2])
    fase = np.degrees(np.unwrap(np.arctan2(d[:, 3 * i + 2], d[:, 3 * i + 1])))
    cruce = np.where(mag < 1.0)[0]
    if not len(cruce):
        return 20 * np.log10(mag[0]), float("nan"), float("nan")
    j = cruce[0]
    #  linear interpolation in log f on log |A|, so the crossing does not
    #  depend on how fine the sweep is
    l0, l1 = np.log10(mag[j - 1]), np.log10(mag[j])
    k = -l0 / (l1 - l0)
    f0 = 10 ** (np.log10(f[j - 1]) + k * (np.log10(f[j]) - np.log10(f[j - 1])))
    return 20 * np.log10(mag[0]), f0, 180.0 + fase[j - 1] + k * (fase[j] - fase[j - 1])


def alterna(fuente: Path) -> None:
    txt, _ = deck_ac(fuente)
    salida = corre("ac", txt)
    if salida is None:
        return
    d = np.loadtxt(salida)
    print(f"\n  {'caso':11s} {'gan DC':>9s} {'0 dB en':>11s} {'margen fase':>12s}")
    print("  " + "-" * 48)
    for i, (nom, *_ ) in enumerate(CASOS):
        gdc, f0, pm = _pm(d, i)
        if np.isfinite(pm):
            print(f"  {nom:11s} {gdc:8.1f}dB {f0/1e6:10.3f}M {pm:11.1f}gr")
        else:
            print(f"  {nom:11s} {gdc:8.1f}dB {'no cruza':>11s} {'--':>12s}")


def esquinas(fuente: Path) -> None:
    """The same measurement across process, temperature and supply.

    A cell that only meets its numbers at typical/27/5.0 has not been
    characterised, it has been sampled once.
    """
    print(f"\n  Esquinas de proceso, temperatura y alimentacion."
          f"  ganancia / INL / consumo / margen de fase\n")
    print(f"  {'esq':8s} {'T':>5s} {'VDD':>5s}", end="")
    for nom, *_ in CASOS:
        print(f" | {nom:>31s}", end="")
    print("\n  " + "-" * (20 + 34 * len(CASOS)))
    peor = {nom: dict(gan=[], inl=0.0, pot=0.0, pm=[]) for nom, *_ in CASOS}
    for esq in ("typical", "ff", "ss"):
        for temp in (-40, 27, 125):
            for vdd in (4.5, 5.0, 5.5):
                nombre = f"dc_{esq}_{temp}_{vdd}"
                txt, _ = deck(fuente, esq, temp, vdd, nombre)
                salida = corre(nombre, txt)
                nom_ac = f"ac_{esq}_{temp}_{vdd}"
                txt_ac, _ = deck_ac(fuente, esq, temp, vdd, nom_ac)
                sal_ac = corre(nom_ac, txt_ac)
                if salida is None or sal_ac is None:
                    continue
                d = np.loadtxt(salida)
                dac = np.loadtxt(sal_ac)
                x = d[:, 0]
                print(f"  {esq:8s} {temp:5d} {vdd:5.1f}", end="")
                for i, (nom, *_ ) in enumerate(CASOS):
                    v = d[:, 2 * i + 1]
                    m = mide(x, v)
                    pot = abs(d[:, 2 * (i + len(CASOS)) + 1]).max() * 1e3
                    inl = m["inl"] if np.isfinite(m["inl"]) else 0.0
                    peor[nom]["gan"].append(m["gan"])
                    peor[nom]["inl"] = max(peor[nom]["inl"], inl)
                    peor[nom]["pot"] = max(peor[nom]["pot"], pot)
                    _, _, pm = _pm(dac, i)
                    peor[nom]["pm"].append(pm)
                    print(f" | {m['gan']:7.1f} {inl:5.2f}% {pot:6.3f}mW {pm:5.1f}gr", end="")
                print()
    print("\n  Lo peor de cada uno en las 27 esquinas:")
    for nom, p_ in peor.items():
        g = np.array(p_["gan"])
        pm = np.array([v for v in p_["pm"] if np.isfinite(v)])
        print(f"    {nom:11s} ganancia {g.min():6.1f} .. {g.max():6.1f} V/V"
              f"   INL <= {p_['inl']:.2f} %   consumo <= {p_['pot']:.3f} mW"
              f"   margen de fase >= {pm.min():.1f} gr")


def main() -> int:
    args = [a for a in sys.argv[1:] if not a.startswith("--")]
    fuente = Path(args[0]) if args else FUENTE
    if not fuente.is_file():
        print(f"  no esta el netlist: {fuente}", file=sys.stderr)
        return 1
    txt, rfb = deck(fuente)
    salida = corre("dc", txt)
    if salida is None:
        return 1

    d = np.loadtxt(salida)
    esperadas = 2 * 2 * len(CASOS)
    if d.shape[1] != esperadas:
        print(f"  {salida} tiene {d.shape[1]} columnas y se esperaban "
              f"{esperadas}: no es de esta corrida", file=sys.stderr)
        return 1
    x = d[:, 0]
    n = len(CASOS)

    print(f"\n  Vcm = {VCM} V, VDD = 5 V, tipico a 27 C.  El dibujo del poly NO cambia:")
    print(f"  siempre 5 tiras de 1 x 76.45 um. Lo unico que se mueve es el implante.\n")
    print(f"  {'caso':11s} {'RFB':>7s} {'que se mueve':>22s}"
          f" {'ganancia':>9s} {'INL':>7s} {'offset':>8s} {'consumo':>9s}")
    print("  " + "-" * 80)

    for i, (nom, modelo, esc, lp) in enumerate(CASOS):
        v = d[:, 2 * i + 1]
        m = mide(x, v)
        pot = abs(d[:, 2 * (i + n) + 1]).max() * 1e3
        inl = f"{m['inl']:.2f} %" if np.isfinite(m["inl"]) else "  --  "
        que = " ".join(f"{k}x{v_:g}" for k, v_ in (esc or {}).items())
        if lp is not None:
            que = (que + f" L={lp}u").strip()
        print(f"  {nom:11s} {rfb[nom]/1e3:6.0f}k {que or '-':>22s}"
              f" {m['gan']:8.1f} {inl:>7s} {m['off']*1e3:7.1f}m {pot:8.3f}mW")

    print("\n  Objetivo: ganancia 100 +-10 %, INL <= 0.5 %, consumo <= 2.6 mW.")
    alterna(fuente)

    #  DONDE esta el error, no solo cuanto vale. Un error concentrado en un
    #  extremo es falta de excursion; uno simetrico en forma de S es la
    #  curvatura del propio par diferencial. Los dos se arreglan distinto.
    print(f"\n  Residuo contra la recta, en mV, por nivel de OUT:")
    print(f"  {'caso':11s}" + "".join(f"{v:8.1f}V" for v in (1.0,1.5,2.0,2.5,3.0,3.5,4.0)))
    print("  " + "-" * 76)
    for i, (nom, *_ ) in enumerate(CASOS):
        v = d[:, 2 * i + 1]
        util = (v >= BAJO) & (v <= ALTO)
        m, b = np.polyfit(x[util], v[util], 1)
        res = v - (m * x + b)
        fila = ""
        for nivel in (1.0, 1.5, 2.0, 2.5, 3.0, 3.5, 4.0):
            j = int(np.argmin(abs(v - nivel)))
            fila += f"{res[j]*1e3:9.1f}"
        print(f"  {nom:11s}{fila}")

    if "--esquinas" in sys.argv:
        esquinas(fuente)
    return 0


if __name__ == "__main__":
    sys.exit(main())
