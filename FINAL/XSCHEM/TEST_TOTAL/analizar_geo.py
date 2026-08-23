#!/usr/bin/env python3
"""Resolucion e isotropia del navegador segun la caja de sensores.

    python3 analizar_geo.py <carpeta_simulacion> <carpeta_datos>

Reads the manifest left by `run_nav2_geo.sh` and the 84 sweep files, and produces
the PDF tables. `wrdata` writes no headers: the VECTORES order below is the only
way to know which column is which, and it has to stay in step with
la variable VEC del runner.
"""

from __future__ import annotations

import sys
from pathlib import Path

import numpy as np

#  `limites` lives in figuras_geo: the interpolation of the threshold crossing
#  must be THE SAME in the table and in the figure, or the PDF contradicts
#  mismo.
sys.path.insert(0, str(Path(__file__).resolve().parent))
import figuras_geo                                          # noqa: E402

#: Which sensors each chain reads, in (X, Y, Z) order. It is the XSCHEM_v2
#: wiring: each slot sees the four sensors once.
TRIO = {1: (0, 1, 2), 2: (3, 0, 1), 3: (2, 3, 0), 4: (1, 2, 3)}

VECTORES = ([f"S{k}{s}" for k in (1, 2, 3, 4) for s in "PN"]
            + [f"{e}{s}" for e in "XYZ" for s in ("P", "", "N")]
            + [f"c{e}{k}" for e in "XYZ" for k in (1, 2, 3, 4)]
            + [f"{e}{s}3" for e in "XYZ" for s in ("P", "N")])
COL = {n: 2 * i + 1 for i, n in enumerate(VECTORES)}
UMBRAL = 2.5
VEXC = 5.0
#: Where the bar is set for saying "it resolves from here".
ACIERTO_MIN = 95.0


def lee(sim: Path, idx: int):
    d = np.loadtxt(sim / f"s{idx:03d}.txt")
    if d.shape[1] < 2 * len(VECTORES):
        sys.exit(f"s{idx:03d}.txt: {d.shape[1]} columnas, esperaba {2 * len(VECTORES)}")
    return d[:, 0], {n: d[:, COL[n]] for n in VECTORES}


#: Los cuatro sensores, en unidades de (Lxy/2, Lxy/2, Lz/2).
SIGNO = [(-1, +1, +1), (+1, -1, +1), (-1, -1, -1), (+1, +1, -1)]


def veredicto(ang, v, lxy, lz, tilt):
    """(acierto en %, empates en %, respuesta ideal, respuesta del chip).

    **La respuesta ideal se calcula de la GEOMETRIA, no de las lecturas.** Es la
    correction that makes the measurement mean something: taking it from the
    nodos de sensor, el desajuste entra en los dos lados de la comparacion y el
    accuracy comes out at 98.9 % even when the offset is three thousand times
    senal -- el chip contesta mal, pero la referencia contesta igual de mal.
    Here the reference is what a perfect navigator placed in the
    gradiente de verdad.
    """
    r = np.radians(ang)
    tr = np.radians(tilt)
    gx, gy, gz = np.cos(r), np.sin(r) * np.sin(tr), np.sin(r) * np.cos(tr)
    b = [(s[0] * lxy * gx + s[1] * lxy * gy + s[2] * lz * gz) / 2000.0
         for s in SIGNO]
    votos = np.zeros((3, len(ang)), int)
    for k, tri in TRIO.items():
        m = np.stack([b[i] for i in tri])
        votos[np.argmin(m, 0), np.arange(len(ang))] += 1
    #  A tie has no correct answer: it is taken out of the denominator and
    #  reported separately, instead of counting as a hit or a miss.
    empate = (votos.max(0)[None, :] == votos).sum(0) > 1
    ideal = np.argmax(votos, 0)
    alto = np.stack([v[f"{e}P"] > UMBRAL for e in "XYZ"])
    una = alto.sum(0) == 1
    chip = np.where(una, np.argmax(alto, 0), -1)
    bueno = ~empate
    ac = 100.0 * np.mean(chip[bueno] == ideal[bueno]) if bueno.any() else 0.0

    #  And NAV3, which compares COMPONENTS and gives the SIX SENSES. Measured
    #  el gradiente de verdad, no contra las lecturas.
    g3 = np.stack([gx, gy, gz])
    neg = np.stack([v[f"{e}N3"] > UMBRAL for e in "XYZ"])
    pos = np.stack([v[f"{e}P3"] > UMBRAL for e in "XYZ"])
    una_n, una_p = neg.sum(0) == 1, pos.sum(0) == 1
    cn = np.where(una_n, np.argmax(neg, 0), -1)
    cp = np.where(una_p, np.argmax(pos, 0), -1)
    #  The true dominant axis, with its sign: six states.
    dom = np.argmax(np.abs(g3), 0)
    sig = np.sign(g3[dom, np.arange(len(ang))])
    #  What the chip can say with its six pins: the dominant axis has to be one
    #  of the two candidates (that of the most negative component and that of the
    #  most positive). Resolving WHICH of the two needs one more comparison.
    entre = (cn == dom) | (cp == dom)
    acierta_min = 100.0 * np.mean(cn == np.argmin(g3, 0))
    acierta_max = 100.0 * np.mean(cp == np.argmax(g3, 0))
    #  Y el sentido, si se anade esa comparacion final:
    mn = -g3[np.clip(cn, 0, 2), np.arange(len(ang))]
    mx = g3[np.clip(cp, 0, 2), np.arange(len(ang))]
    elige = np.where(mx >= mn, cp, cn)
    signo_ok = np.where(mx >= mn, 1.0, -1.0)
    sentido = 100.0 * np.mean((elige == dom) & (signo_ok == sig))
    return (ac, 100.0 * np.mean(empate), ideal, chip,
            dict(min=acierta_min, max=acierta_max,
                 entre=100.0 * np.mean(entre), sentido=sentido))


def main() -> int:
    sim, dat = Path(sys.argv[1]), Path(sys.argv[2])
    man = np.genfromtxt(dat / "manifiesto.csv", delimiter=",", names=True,
                        dtype=None, encoding="utf-8")
    filas = []
    for r in man:
        ang, v = lee(sim, int(r["idx"]))
        ac, emp, ideal, chip, s3 = veredicto(
            ang, v, float(r["lxy_um"]), float(r["lz_um"]), float(r["tilt_deg"]))
        filas.append(dict(idx=int(r["idx"]), tipo=str(r["tipo"]),
                          lxy=int(r["lxy_um"]), lz=int(r["lz_um"]),
                          gmm=float(r["gmm"]), bg=float(r["bg"]),
                          tilt=int(r["tilt_deg"]), off=float(r["off"]),
                          acierto=ac, empate=emp, **{f"s3_{k}": x
                                                     for k, x in s3.items()}))

    # ---------------------------------------------------------- 1. resolucion
    niveles = sorted({f["gmm"] for f in filas if f["tipo"] == "res_xz"})
    if niveles:
        print(f"\n{'=' * 78}\n  RESOLUCION: acierto (%) contra el nivel de gradiente\n{'=' * 78}")
    umbral_de = {}
    if niveles:
        print("  caja (um)  " + " ".join(f"{g * 1e6:7.0f}" for g in niveles) + "   ppm/mm")
    for tipo, etiqueta in (() if not niveles else
                           (("res_xz", "plano X-Z"), ("res_xy", "plano X-Y"))):
        print(f"  --- {etiqueta}")
        cajas = sorted({(f["lxy"], f["lz"]) for f in filas if f["tipo"] == tipo})
        for lxy, lz in cajas:
            ac = [next(f["acierto"] for f in filas if f["tipo"] == tipo
                       and f["lxy"] == lxy and f["lz"] == lz and f["gmm"] == g)
                  for g in niveles]
            #  The smallest resolvable: the first level reaching the bar that it
            #  never drops below again. Log-interpolated between the two neighbours.
            g95 = None
            for i in range(len(niveles)):
                if ac[i] >= ACIERTO_MIN:
                    if i == 0:
                        g95 = niveles[0]
                    else:
                        f0, f1 = ac[i - 1], ac[i]
                        t = (ACIERTO_MIN - f0) / (f1 - f0) if f1 != f0 else 1.0
                        g95 = np.exp(np.log(niveles[i - 1])
                                     + t * (np.log(niveles[i]) - np.log(niveles[i - 1])))
                    break
            umbral_de[(tipo, lxy, lz)] = g95
            eti = f"{lxy}x{lz}" if tipo == "res_xz" else f"{lxy}"
            print(f"  {eti:>9s}  " + " ".join(f"{a:6.1f} " for a in ac)
                  + (f"   -> {g95 * 1e6:6.1f} ppm/mm al {ACIERTO_MIN:.0f} %"
                     if g95 else "   -> no llega al liston"))

    ref = umbral_de.get(("res_xy", 1000, 1000))
    if ref:
        print(f"\n  What should come out if GEOMETRY rules: the minimum goes as 1/L.")
    if ref:
        for lxy in (1000, 2000, 3000):
            g = umbral_de.get(("res_xy", lxy, 1000))
            if g:
                print(f"     X-Y, L = {lxy:4d} um:  medido {g * 1e6:6.1f} ppm/mm   "
                      f"1/L desde el de 1000 um: {ref * 1e6 * 1000 / lxy:6.1f}   "
                      f"razon {g / (ref * 1000 / lxy):.2f}")

    # ------------------------------------------- 1b. los dos limites de verdad
    print(f"\n{'=' * 78}\n  THE TWO LIMITS: without mismatch there is only a ceiling; with it, a floor appears"
          f"\n{'=' * 78}")
    print(f"  {'box':>10s} {'no mismatch':>28s} {'with 200 ppm mismatch':>34s}")
    print(f"  {'':>10s} {'suelo':>13s} {'techo':>14s} {'suelo':>16s} {'techo':>17s}"
          f" {'rango':>8s}   ppm/mm")
    for lxy, lz in sorted({(f["lxy"], f["lz"]) for f in filas if f["tipo"] == "res_xz"}):
        col = []
        for tipo in ("res_xz", "res_off"):
            sel = sorted([f for f in filas if f["tipo"] == tipo
                          and f["lxy"] == lxy and f["lz"] == lz],
                         key=lambda f: f["gmm"])
            if not sel:
                col += ["-", "-"]; continue
            lo, hi = figuras_geo.limites([f["gmm"] for f in sel],
                                         [f["acierto"] for f in sel])
            col.append(f"{lo * 1e6:.0f}" if lo else "never")
            col.append(f"{hi * 1e6:.0f}" if hi else "nunca")
        rango = ""
        try:
            rango = f"{float(col[3]) / float(col[2]):5.1f}x"
        except ValueError:
            rango = "    -"
        print(f"  {lxy:5d}x{lz:<4d} {col[0]:>13s} {col[1]:>14s} "
              f"{col[2]:>16s} {col[3]:>17s} {rango:>8s}")

    # ------------------------------------------- 1b bis. el SENTIDO
    sent = [f for f in filas if f["tipo"] == "sentido"]
    if sent:
        print(f"\n{'=' * 78}\n  THE SENSE OF THE GRADIENT: what the six outputs can give"
              f"\n{'=' * 78}")
        print(f"  {'caja':>10s} {'gradiente':>11s} {'hoy (3 sal.)':>13s} "
              f"{'N right':>10s} {'P right':>10s} {'axis among 2':>16s} "
              f"{'SENTIDO':>9s}")
        for f in sorted(sent, key=lambda f: (f["lxy"], f["lz"], f["gmm"])):
            print(f"  {f['lxy']:5d}x{f['lz']:<4d} {f['gmm'] * 1e6:8.0f} ppm "
                  f"{f['acierto']:11.1f} % {f['s3_min']:8.1f} % {f['s3_max']:8.1f} % "
                  f"{f['s3_entre']:14.1f} % {f['s3_sentido']:7.1f} %")

    # ------------------------------------------- 1c. la arquitectura v3
    print(f"\n{'=' * 78}\n  ARQUITECTURA: comparar LECTURAS (hoy) contra comparar COMPONENTES (v3)"
          f"\n{'=' * 78}")
    print(f"  {'caja':>10s} {'gradiente':>12s} {'hoy':>9s}")
    for lxy, lz in sorted({(f["lxy"], f["lz"]) for f in filas if f["tipo"] == "res_off"}):
        sel = sorted([f for f in filas if f["tipo"] == "res_off"
                      and f["lxy"] == lxy and f["lz"] == lz], key=lambda f: f["gmm"])
        mejor = max(sel, key=lambda f: f["acierto"])
        print(f"  {lxy:5d}x{lz:<4d} {mejor['gmm'] * 1e6:9.0f} ppm/mm "
              f"{mejor['acierto']:7.1f} %")

    # ---------------------------------------------------------- 2. isotropia
    if niveles:
      print(f"\n{'=' * 78}\n  ISOTROPY: where the boundaries fall, and who wins\n{'=' * 78}")
      print(f"  {'caja':>10s} {'Lxy/Lz':>7s} {'frontera atan(Lxy/Lz)':>22s} "
            f"{'medida':>9s}   gana X / Y / Z  (% del barrido)")
      medio = niveles[len(niveles) // 2]
      for lxy, lz in sorted({(f["lxy"], f["lz"]) for f in filas if f["tipo"] == "res_xz"}):
        idx = next(f["idx"] for f in filas if f["tipo"] == "res_xz"
                   and f["lxy"] == lxy and f["lz"] == lz and f["gmm"] == medio)
        ang, v = lee(sim, idx)
        _, _, ideal, chip, _ = veredicto(ang, v, lxy, lz, 0.0)
        pred = np.degrees(np.arctan(lxy / lz))
        #  La frontera medida: el primer cambio de ganador ideal despues de 0.
        cam = ang[1:][np.diff(ideal) != 0]
        cerca = cam[np.argmin(np.abs(cam - pred))] if len(cam) else float("nan")
        rep = " ".join(f"{100 * np.mean(chip == i):5.1f}" for i in range(3))
        print(f"  {lxy:5d}x{lz:<4d} {lxy / lz:7.2f} {pred:19.2f} deg "
              f"{cerca:8.2f}    {rep}")  # noqa: E128

    # ---------------------------------------------------------- 3. fondo
    print(f"\n{'=' * 78}\n  BACKGROUND FIELD: common to all four, but the amplifier sees it\n{'=' * 78}")
    fondos = sorted({f["bg"] for f in filas if f["tipo"] == "fondo"})
    if not fondos:
        fondos = []
    print("  box (um)  " if fondos else "  (no background sweep in this run)" + " ".join(f"{b * 1e6:7.0f}" for b in fondos) + "   ppm of dR/R")
    for lxy, lz in sorted({(f["lxy"], f["lz"]) for f in filas if f["tipo"] == "fondo"}):
        ac = [next(f["acierto"] for f in filas if f["tipo"] == "fondo"
                   and f["lxy"] == lxy and f["lz"] == lz and f["bg"] == b) for b in fondos]
        print(f"  {lxy:5d}x{lz:<4d} " + " ".join(f"{a:6.1f} " for a in ac))

    destino = dat / "resumen.csv"
    with destino.open("w") as f:
        f.write("idx,tipo,lxy_um,lz_um,gmm,bg,tilt_deg,off,acierto_pct,"
                "s3_min_pct,s3_max_pct,s3_entre_pct,s3_sentido_pct,empate_pct\n")
        for r in filas:
            f.write(f"{r['idx']},{r['tipo']},{r['lxy']},{r['lz']},{r['gmm']:.6e},"
                    f"{r['bg']:.6e},{r['tilt']},{r['off']:.6e},"
                    f"{r['acierto']:.3f},{r['s3_min']:.3f},{r['s3_max']:.3f},"
                    f"{r['s3_entre']:.3f},{r['s3_sentido']:.3f},{r['empate']:.3f}\n")
    print(f"\n  resumen -> {destino}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
