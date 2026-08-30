#!/usr/bin/env python3
"""Does the navigator's answer agree with what the four corners of the box read?

    python3 analizar_caja.py <simulation dir> <data dir>

THREE LEVELS, ALL AGAINST GEOMETRY. The reference is never taken from the sensor
nodes: a perfect navigator placed in the TRUE gradient is. Taking it from the
readings puts the same offset on both sides of the comparison and the accuracy
comes out at 98.9 % even when the offset is three thousand times the signal --
the chip answers wrong and the reference answers wrong in the same way.

  (a) THE SENSORS. What each bridge delivers against what its corner should see.
      If this does not hold, nothing below means anything.
  (b) EACH CHAIN, one at a time. Chain k sees a triad of sensors -- one per
      differential leg -- and its right answer is the SMALLEST of that triad's
      ideal_read readings. Its answer is whichever of Xk, Yk, Zk is HIGH: measured on
      the sweep itself, exactly one of the three sits at 5 V and it agrees with
      the argmin on 97 % of the directions that are not a tie. Reading them the
      other way round gives 0 %, which is how this was checked rather than
      assumed.
      A direction where two of the triad read the SAME has no right answer at
      the chain level; those are taken out of the denominator and reported.
  (c) THE TOTAL OUTPUT, with the output and its negated twin as ONE decide.
      Per axis the pair is (P, N):
        * the pair is VALID only if N is the complement of P;
        * the chip's answer is the single axis whose P is high;
        * anything else -- no axis high, two axes high, an incoherent pair --
          is UNDECIDED, counted apart and NEVER as a hit.
      Six independent percentages, one per output, is what made the earlier
      reports read like loose measurements; this is one number per direction.

AND THE TWO TOPS. `xnav2` is the schematic with the decide redone (a
comparator against a reference built from two weight replicas) and `xnavt` is
the top exactly as it is in the GDS, still with the three COMP_OUT. Same four
sensors, same directions, same table.

THE WEIGHT. In this bench `ang` is the polar angle from +x and `tilt` the
azimuth, so sweeping both covers the sphere but visits the poles at +-x once per
tilt. Every average here is weighted by sin(ang), which is the solid-angle
element. Without it the answer is to a different question.
"""

from __future__ import annotations

import sys
from pathlib import Path

import numpy as np

#: The EXACT order of `VEC` in run_nav2_geo.sh. Touch one and you must touch
#: the other: `wrdata` writes no headers, so this list is the only thing that
#: says which column is which.
VECTORES = (["S1P", "S1N", "S2P", "S2N", "S3P", "S3N", "S4P", "S4N"]
            + [f"{e}{s}v" for e in "XYZ" for s in ("P", "", "N")]
            + [f"c{e}{k}" for e in "XYZ" for k in (1, 2, 3, 4)]
            + [f"{e}{s}t" for e in "XYZ" for s in ("P", "", "N")]
            + [f"t{e}{k}" for e in "XYZ" for k in (1, 2, 3, 4)]
            #  The comparator outputs of each chain, in the order VEC probes
            #  them: XY, XZ, YZ for chain 1, then chain 2, and so on.
            + [f"k{k}{c}" for k in (1, 2, 3, 4) for c in ("XY", "XZ", "YZ")])
COL = {n: 2 * i + 1 for i, n in enumerate(VECTORES)}

#: The two lists are written in two files and there is no way for one to warn
#: the other, so they are counted against each other here: `wrdata` writes no
#: headers, and a mismatch shifts every column silently.
def check_vectors(dat: Path):
    p = dat / "vectores.txt"
    if not p.exists():
        return                       # a run from before this check existed
    vec = [l for l in p.read_text().split() if l]
    if len(vec) != len(VECTORES):
        sys.exit(f"  the run probed {len(vec)} vectors and VECTORES here has "
                 f"{len(VECTORES)}: every column would be shifted.\n"
                 f"  run:  {' '.join(vec[:6])} ...\n"
                 f"  here: {' '.join(VECTORES[:6])} ...")

THRESHOLD = 2.5
VEXC = 5.0

#: The four sensors, in units of (Lxy/2, Lxy/2, Lz/2). Regular tetrahedron
#: inscribed in the box: S1 and S2 on opposite corners of the upper z plane,
#: S3 and S4 on the opposite two of the lower one.
SIGNO = [(-1, +1, +1), (+1, -1, +1), (-1, -1, -1), (+1, +1, -1)]
#: Which three sensors each chain reads, in (X, Y, Z) order -- READ FROM THE
#: NETLIST, never assumed. The two tops are NOT wired the same and a hard-coded
#: table scored one of them against the other's wiring: chains 2 and 4 came out
#: at 2.8 % and 0.9 % where 1 and 3 were at 85 %, which looks like a broken
#: chain and is really a permuted index.
#:
#:   GRADIENT_NAV2_V2  (1,2,3) (4,1,2) (3,4,1) (2,3,4)  -- the four rotations
#:   GRADIENT_NAV2     (1,2,3) (1,2,4) (3,4,1) (3,4,2)  -- two PAIRS that share
#:                                                         two of their three legs
#:
#: GRADIENT2's port order is SXN SXP VDD X SYN Y Z SYP VSS SZN SZP, so counting
#: the instance name as token 0 the POSITIVE leg of each axis is at 2, 8 and 11
#: and the X output at 4. (Reading 1, 7 and 10 picks up the negative legs and
#: gives nonsense like "chain 1 -> S1 S1 S3".)
NETLISTS = {
    "v": Path("/foss/designs/a_zonetic2026/XSCHEM_v2/simulation/"
              "GRADIENT_NAV2_V2.sch/GRADIENT_NAV2_V2.spice"),
    "t": Path("/foss/designs/a_zonetic2026/XSCHEM/simulation/"
              "GRADIENT_NAV2.sch/GRADIENT_NAV2.spice"),
}


def read_triads(path: Path):
    """{chain: (sensor of the X leg, of the Y leg, of the Z leg)}, 0-based."""
    trios = {}
    for line in path.read_text().splitlines():
        tok = line.split()
        if len(tok) < 12 or tok[-1] != "GRADIENT2":
            continue
        k = int(tok[4][1:])                     # the X output is X<k>
        trios[k] = tuple(int(tok[i][1]) - 1 for i in (2, 8, 11))
    if len(trios) != 4:
        sys.exit(f"{path.name}: found {len(trios)} GRADIENT2 chains, expected 4")
    return trios
#: The mismatch pattern the bench applies, from the ESTIMULO block of the .sch.
#: It is deliberately not symmetric.
PATRON = (+1.00, -0.62, +0.31, -0.85)


def lee(sim: Path, idx: int):
    d = np.loadtxt(sim / f"s{idx:03d}.txt")
    if d.shape[1] < 2 * len(VECTORES):
        sys.exit(f"s{idx:03d}.txt: {d.shape[1]} columns, expected "
                 f"{2 * len(VECTORES)}. The .control block and VECTORES have "
                 f"drifted apart.")
    return d[:, 0], {n: d[:, COL[n]] for n in VECTORES}


def ideal_read(ang, lxy, lz, tilt):
    """What each corner SHOULD read, and the true gradient, from geometry."""
    r, tr = np.radians(ang), np.radians(tilt)
    g = np.stack([np.cos(r), np.sin(r) * np.sin(tr), np.sin(r) * np.cos(tr)])
    b = np.stack([(s[0] * lxy * g[0] + s[1] * lxy * g[1] + s[2] * lz * g[2]) / 2000.0
                  for s in SIGNO])
    return g, b


def weights(ang):
    """Solid-angle weight of each sample. See the module docstring."""
    w = np.abs(np.sin(np.radians(ang)))
    return w / w.sum() if w.sum() else np.ones_like(w) / len(w)


def ideal_votes(b, TRIO):
    """Per direction: the vote of each chain, and the axis the four choose."""
    v = np.zeros((3, b.shape[1]), int)
    who = np.zeros((4, b.shape[1]), int)
    for k, tri in TRIO.items():
        m = np.stack([b[i] for i in tri])
        who[k - 1] = np.argmin(m, 0)
        v[who[k - 1], np.arange(b.shape[1])] += 1
    tie = (v.max(0)[None, :] == v).sum(0) > 1
    #  `v` itself goes out too: it is HOW MANY CHAINS should vote for each axis,
    #  which is exactly what the analogue counter encodes, so the two can be put
    #  side by side. The dominant axis alone cannot be compared with anything.
    return who, np.argmax(v, 0), tie, v


def decide(v, suf, invertir=False):
    """The chip's answer from the three (P, N) pairs. See level (c)."""
    P = np.stack([v[f"{e}P{suf}"] > THRESHOLD for e in "XYZ"])
    N = np.stack([v[f"{e}N{suf}"] > THRESHOLD for e in "XYZ"])
    if invertir:
        P, N = N, P
    par_ok = np.all(N == ~P, axis=0)          # every pair complementary
    uno = P.sum(0) == 1                       # exactly one axis claimed
    valido = par_ok & uno
    return np.where(valido, np.argmax(P, 0), -1), valido


def pct(mask, w):
    return 100.0 * float(np.sum(w[mask]))


def recover(b4):
    """The gradient recovered from the four readings, with no system to solve.

    The four position vectors are orthogonal component by component, so a signed
    sum is all it takes:  g_i = sum_k  SIGNO[k][i] * b_k / 4.  This is the check
    that the ARRANGEMENT does what is asked of it: out of four numbers come the
    three differences in x, y and z.
    """
    return np.stack([sum(SIGNO[k][i] * b4[k] for k in range(4)) / 4.0
                     for i in range(3)])


def angle_between(a, b):
    """Angle in degrees between two stacks of vectors, column by column."""
    na = a / np.maximum(np.linalg.norm(a, axis=0), 1e-30)
    nb = b / np.maximum(np.linalg.norm(b, axis=0), 1e-30)
    return np.degrees(np.arccos(np.clip((na * nb).sum(0), -1.0, 1.0)))


def main() -> int:
    sim, dat = Path(sys.argv[1]), Path(sys.argv[2])
    check_vectors(dat)
    TRIOS = {s: read_triads(p) for s, p in NETLISTS.items()}
    for s, tr in TRIOS.items():
        print(f"  chain wiring of {NETLISTS[s].stem}: "
              + "  ".join(f"{k}->S{tr[k][0]+1}S{tr[k][1]+1}S{tr[k][2]+1}"
                          for k in sorted(tr)))
    dat.mkdir(parents=True, exist_ok=True)
    manifest = dat / "manifiesto.csv"
    if not manifest.exists():
        sys.exit(f"no manifest in {manifest}: run ./run_nav2_geo.sh 2 esfera first")

    rows = [l.split(",") for l in manifest.read_text().splitlines()[1:] if l.strip()]
    summary = {}
    primero = True

    for f in rows:
        idx, kind = int(f[0]), f[1]
        lxy, lz, gmm, bg, tilt, off = (float(f[2]), float(f[3]), float(f[4]),
                                       float(f[5]), float(f[6]), float(f[7]))
        p = sim / f"s{idx:03d}.txt"
        if not p.exists():
            print(f"  missing {p.name}")
            continue
        ang, v = lee(sim, idx)
        w = weights(ang)
        g, b = ideal_read(ang, lxy, lz, tilt)
        verdict = {s: ideal_votes(b, TRIOS[s]) for s in ("v", "t")}

        # --- (a) the sensors -------------------------------------------------
        if primero:
            primero = False
            vcm = np.concatenate([(v[f"S{k}P"] + v[f"S{k}N"]) / 2 for k in (1, 2, 3, 4)])
            err = []
            for k in (1, 2, 3, 4):
                measured = (v[f"S{k}P"] - v[f"S{k}N"]) / VEXC
                debido = bg + PATRON[k - 1] * off + gmm * b[k - 1]
                err.append(np.abs(measured - debido).max())
            print(f"\n{'=' * 78}\n  (a) THE SENSORS   box {lxy:.0f} x {lxy:.0f} x {lz:.0f} um, "
                  f"gradient {gmm * 1e6:.0f} ppm/mm, mismatch {off * 1e6:.0f} ppm\n{'=' * 78}")
            print(f"      common mode {vcm.min():.6f} .. {vcm.max():.6f} V   "
                  f"(it must not move)")
            print("      |measured - what its corner should read|, per sensor:  "
                  + "  ".join(f"S{k}={e * 1e6:.3f} ppm" for k, e in enumerate(err, 1)))

        # --- (a2) is the gradient right? -------------------------------------
        #  Recovered from what the BRIDGES deliver, not from the ideal_read readings:
        #  this is the measurement, offset and all.
        measured = np.stack([(v[f"S{k}P"] - v[f"S{k}N"]) / VEXC for k in (1, 2, 3, 4)])
        gr = recover(measured)
        miss = angle_between(gr, g)
        r_g = summary.setdefault(("grad", kind), {"med": [], "max": []})
        r_g["med"].append(float(np.sum(w * miss)))
        r_g["max"].append(float(miss.max()))

        #  Everything this direction produced, named, for the figures and the
        #  document. One file per sweep; the manifest says what each one is.
        who, dom, tie, _ = verdict["v"]
        exp = dat / "por_barrido"
        exp.mkdir(exist_ok=True)
        cols = {"ang": ang, "peso": w, "gx": g[0], "gy": g[1], "gz": g[2],
                "desv_grad": miss}
        for k in (1, 2, 3, 4):
            cols[f"b{k}_ideal"] = gmm * b[k - 1]
            cols[f"b{k}_medido"] = measured[k - 1]
            for s in ("v", "t"):
                cols[f"voto_ideal{k}_{s}"] = verdict[s][0][k - 1]
        for e in "XYZ":
            for k in (1, 2, 3, 4):
                cols[f"c{e}{k}"] = v[f"c{e}{k}"]
                cols[f"t{e}{k}"] = v[f"t{e}{k}"]
            for s in ("P", "", "N"):
                cols[f"{e}{s}v"] = v[f"{e}{s}v"]
                cols[f"{e}{s}t"] = v[f"{e}{s}t"]
        #  The direct output after the comparator, per chain. This block goes
        #  AFTER the loop above and not inside it: when it was inside, the `for s`
        #  loop that writes X/Y/Z ended up nested in the `for k` of the
        #  comparators and used the `e` LEAKING from the finished loop, so only
        #  the Z columns were exported -- four times over, and silently.
        for k in (1, 2, 3, 4):
            for c in ("XY", "XZ", "YZ"):
                cols[f"k{k}{c}"] = v[f"k{k}{c}"]
        for s in ("v", "t"):
            cols[f"dominante_ideal_{s}"] = verdict[s][1]
            cols[f"empate_{s}"] = verdict[s][2].astype(int)
            for j, e in enumerate("XYZ"):
                cols[f"votos_{e}_{s}"] = verdict[s][3][j]
        with (exp / f"s{idx:03d}.csv").open("w") as fh:
            fh.write(",".join(cols) + "\n")
            for i in range(len(ang)):
                fh.write(",".join(f"{cols[c][i]:.6g}" for c in cols) + "\n")

        # --- (b) each chain --------------------------------------------------
        for suf, prefix in (("v", "c"), ("t", "t")):
            TRIO = TRIOS[suf]
            who, dom, tie, _ = verdict[suf]
            ac_c = []
            for k in (1, 2, 3, 4):
                #  ONE-HOT, ACTIVE HIGH: the chain's answer is the axis at 5 V.
                alto = np.stack([v[f"{prefix}{e}{k}"] > THRESHOLD for e in "XYZ"])
                uno = alto.sum(0) == 1
                resp = np.where(uno, np.argmax(alto, 0), -1)
                #  A tie inside the triad has no right answer: out of the
                #  denominator, like the vote ties at the top level.
                m3 = np.sort(np.stack([b[i] for i in TRIO[k]]), axis=0)
                claro = (m3[1] - m3[0] > 1e-9) & (m3[2] - m3[1] > 1e-9)
                den_c = float(np.sum(w[claro])) or 1.0
                ac_c.append(pct(claro & uno & (resp == who[k - 1]), w) / den_c)
            # --- (c) the total, pair by pair ---------------------------------
            chip, valido = decide(v, suf)
            #  And the same reading with the pair SWAPPED. It is a diagnostic,
            #  not an alternative: if a top scores badly one way and well the
            #  other, its outputs carry the answer with the polarity inverted --
            #  a design fault worth naming, and a very different thing from the
            #  answer not being there at all.
            chip_i, valido_i = decide(v, suf, invertir=True)
            bueno = ~tie
            den = float(np.sum(w[bueno])) or 1.0
            hit = pct(bueno & valido & (chip == dom), w) / den
            undecided = pct(bueno & ~valido, w) / den
            #  clamped: rounding left a '-0.00 %' in the table
            wrong = max(0.0, 100.0 - hit - undecided)
            key = (kind, suf)
            r = summary.setdefault(key, {"ac": [], "in": [], "fa": [], "ch": [],
                                         "emp": [], "rng": [], "ac_inv": []})
            r["ac"].append(hit); r["in"].append(undecided); r["fa"].append(wrong)
            r.setdefault("ac_inv", []).append(
                pct(bueno & valido_i & (chip_i == dom), w) / den)
            r["ch"].append(ac_c); r["emp"].append(pct(tie, w))
            r["rng"].append([(v[f"{e}{suf}"].min(), v[f"{e}{suf}"].max()) for e in "XYZ"])

    # --- the tables ---------------------------------------------------------
    print(f"\n{'=' * 78}\n  (a2) IS THE GRADIENT RIGHT?   angle between the gradient"
          f" recovered from\n       the four bridges and the one asked for"
          f"\n{'=' * 78}")
    for key in sorted(k for k in summary if k[0] == "grad"):
        r = summary[key]
        print(f"  {key[1]:16s} mean {np.mean(r['med']):8.4f} deg   "
              f"worst {np.max(r['max']):8.4f} deg")

    NOMBRE = {"v": "NAV2_V2  (decide redone)", "t": "NAV2     (as in the GDS)"}
    for kind in sorted({t for t, s in summary if t != "grad"}):
        print(f"\n{'=' * 78}\n  {kind}   {len(summary[(kind, 'v')]['ac'])} sweeps over the sphere"
              f"\n{'=' * 78}")
        print(f"  {'version':28s} {'hit':>8s} {'undecided':>11s} {'miss':>8s}"
              f"   {'ideal_read ties':>11s}")
        for suf in ("v", "t"):
            r = summary[(kind, suf)]
            print(f"  {NOMBRE[suf]:28s} {np.mean(r['ac']):7.2f}% "
                  f"{np.mean(r['in']):10.2f}% {np.mean(r['fa']):7.2f}%   "
                  f"{np.mean(r['emp']):10.2f}%   "
                  f"(pair swapped: {np.mean(r['ac_inv']):.2f}%)")
        print(f"\n  the four chains, hit rate per chain (they share the decoders):")
        for suf in ("v", "t"):
            ch = np.mean(np.array(summary[(kind, suf)]["ch"]), axis=0)
            print(f"  {NOMBRE[suf]:28s} " + "  ".join(f"chain{k}={c:6.2f}%"
                                                     for k, c in enumerate(ch, 1)))
        print(f"\n  the analogue vote counter, where the decide threshold has to fall:")
        for suf in ("v", "t"):
            rng = np.array(summary[(kind, suf)]["rng"])
            print(f"  {NOMBRE[suf]:28s} " + "  ".join(
                f"{e}={rng[:, i, 0].min():.3f}..{rng[:, i, 1].max():.3f} V"
                for i, e in enumerate("XYZ")))

    dest = dat / "caja.csv"
    with dest.open("w") as fh:
        fh.write("kind,version,hit,indefinido,wrong,acierto_par_invertido\n")
        for kind, suf in sorted(k for k in summary if k[0] != "grad"):
            r = summary[(kind, suf)]
            fh.write(f"{kind},{suf},{np.mean(r['ac']):.4f},"
                     f"{np.mean(r['in']):.4f},{np.mean(r['fa']):.4f},"
                     f"{np.mean(r['ac_inv']):.4f}\n")
    print(f"\n  data -> {dest}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
