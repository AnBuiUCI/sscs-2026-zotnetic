#!/usr/bin/env python3
"""A source at a place: does the chip point at it?

    python3 analizar_fuente.py <simulation dir> <data dir>

Reuses everything from `analizar_caja.py` -- the column map, the gradient
reconstruction, the vote criterion and the paired (P, N) reading -- and only
replaces WHERE THE IDEAL READINGS COME FROM: a source sitting somewhere instead
of a uniform gradient.

THE TWO MODELS, and the pair is the whole point:

  simetrico  |B| depends on the DISTANCE only, so grad|B| AT A POINT points
             exactly at the source.
  dipolo     A real dipole with its axis along +z: |B| depends on the angle too
             and grad|B| does not point exactly at the source even at a point.

AND A THIRD ERROR, which is neither of those and turned out to be the biggest
one. The chip does not measure the gradient at a point: it takes a FINITE
DIFFERENCE over a box 1 mm across. With the source 3 mm away the field curves
sharply over that box, and the four-point estimate misses by 14 degrees with a
PERFECT chip and a perfectly symmetric field. That is geometry, not circuitry,
and it shrinks as the source gets further away.

So each row is reported three ways: what comes out, what a perfect chip would
give from the IDEAL readings, and the difference -- which is the only part the
circuit is responsible for. The two move in OPPOSITE directions with distance
(the geometry improves, the signal weakens against a fixed sensor offset), so
there is a best distance rather than "closer is better".
"""

from __future__ import annotations

import sys
from pathlib import Path

import numpy as np

sys.path.insert(0, str(Path(__file__).resolve().parent))
from analizar_caja import (SIGNO, PATRON, VECTORES, COL, THRESHOLD, VEXC,   # noqa: E402
                           NETLISTS, read_triads, ideal_votes, decide,
                           recover, angle_between, weights, pct, check_vectors)


def lee(sim: Path, idx: int):
    d = np.loadtxt(sim / f"s{idx:03d}.txt")
    if d.shape[1] < 2 * len(VECTORES):
        sys.exit(f"s{idx:03d}.txt: {d.shape[1]} columns, expected "
                 f"{2 * len(VECTORES)}")
    return d[:, 0], {n: d[:, COL[n]] for n in VECTORES}


def model(ang, dist, tilt, dipole, bcen, lxy=1000.0, lz=1000.0):
    """(direction to the source, ideal_read |B| at each vertex).

    The same expressions the bench evaluates, so the reference and the stimulus
    cannot drift apart: one is this and the other is the B-source block of
    test_FUENTE.sch.
    """
    r, tr = np.radians(ang), np.radians(tilt)
    u = np.stack([np.cos(r), np.sin(r) * np.sin(tr), np.sin(r) * np.cos(tr)])
    p = dist * u
    amp = bcen * dist ** 3
    b = []
    for (sx, sy, sz) in SIGNO:
        q = np.stack([sx * lxy / 2 - p[0], sy * lxy / 2 - p[1], sz * lz / 2 - p[2]])
        d = np.linalg.norm(q, axis=0)
        c = q[2] / d                       # dipole axis is +z
        b.append(amp / d ** 3 * (1 + dipole * (np.sqrt(1 + 3 * c ** 2) - 1)))
    return u, np.stack(b)


def main() -> int:
    sim, dat = Path(sys.argv[1]), Path(sys.argv[2])
    check_vectors(dat)
    TRIOS = {s: read_triads(p) for s, p in NETLISTS.items()}
    rows = [l.split(",") for l in (dat / "manifiesto.csv").read_text().splitlines()[1:]
             if l.strip()]

    res: dict = {}
    for f in rows:
        idx, kind = int(f[0]), f[1]
        dist, tilt, dipole, bcen, off = (float(f[2]), float(f[3]), float(f[4]),
                                     float(f[5]), float(f[6]))
        p = sim / f"s{idx:03d}.txt"
        if not p.exists():
            print(f"  falta {p.name}")
            continue
        ang, v = lee(sim, idx)
        w = weights(ang)
        u, b = model(ang, dist, tilt, dipole, bcen)

        #  DOES IT POINT AT IT? The gradient out of the four bridges against the
        #  direction to the source. This is the headline.
        measured = np.stack([(v[f"S{k}P"] - v[f"S{k}N"]) / VEXC for k in (1, 2, 3, 4)])
        miss = angle_between(recover(measured), u)
        #  And the same for a PERFECT chip, from the ideal_read readings: with the
        #  symmetric model this is zero by construction, and with the dipole it
        #  is the error the PHYSICS puts in whatever the circuit does.
        miss_ideal = angle_between(recover(b), u)

        for suf in ("v", "t"):
            who, dom, tie, _ = ideal_votes(b, TRIOS[suf])
            chip, valido = decide(v, suf)
            bueno = ~tie
            den = float(np.sum(w[bueno])) or 1.0
            r = res.setdefault((kind, dist, suf),
                               {"ac": [], "in": [], "ang": [], "ang_id": [],
                                "emp": []})
            r["ac"].append(pct(bueno & valido & (chip == dom), w) / den)
            r["in"].append(pct(bueno & ~valido, w) / den)
            r["ang"].append(float(np.sum(w * miss)))
            r["ang_id"].append(float(np.sum(w * miss_ideal)))
            r["emp"].append(pct(tie, w))

        exp = dat / "por_barrido"
        exp.mkdir(exist_ok=True)
        cols = {"ang": ang, "peso": w, "ux": u[0], "uy": u[1], "uz": u[2],
                "miss": miss, "miss_ideal": miss_ideal}
        for k in (1, 2, 3, 4):
            cols[f"b{k}_ideal"] = b[k - 1]
            cols[f"b{k}_medido"] = measured[k - 1]
        for e in "XYZ":
            for s in ("P", "", "N"):
                cols[f"{e}{s}v"] = v[f"{e}{s}v"]
                cols[f"{e}{s}t"] = v[f"{e}{s}t"]
        for k in (1, 2, 3, 4):
            for c in ("XY", "XZ", "YZ"):
                cols[f"k{k}{c}"] = v[f"k{k}{c}"]
        for s in ("v", "t"):
            cols[f"dominante_ideal_{s}"] = ideal_votes(b, TRIOS[s])[1]
            for j, e in enumerate("XYZ"):
                cols[f"votos_{e}_{s}"] = ideal_votes(b, TRIOS[s])[3][j]
        with (exp / f"s{idx:03d}.csv").open("w") as fh:
            fh.write(",".join(cols) + "\n")
            for i in range(len(ang)):
                fh.write(",".join(f"{cols[c][i]:.6g}" for c in cols) + "\n")

    NOM = {"v": "NAV2_V2", "t": "NAV2 (top)"}
    print(f"\n{'=' * 84}\n  DOES IT POINT AT THE SOURCE?   angle between the gradient"
          f" recovered from the\n  four bridges and the direction to the source"
          f"\n{'=' * 84}")
    print(f"  {'model':10s} {'distance':>9s}  {'chip':>10s}  {'perfect chip':>13s}"
          f"  {'what the chip adds':>19s}")
    for (kind, dist, suf) in sorted(k for k in res if k[2] == "t"):
        r = res[(kind, dist, suf)]
        a, ai = np.mean(r["ang"]), np.mean(r["ang_id"])
        print(f"  {kind:10s} {dist:8.0f}um  {a:9.3f}d  {ai:12.3f}d  {a - ai:18.3f}d")
    print("\n  'perfect chip' is the same reconstruction from the IDEAL readings,")
    print("  so it is what GEOMETRY AND PHYSICS put in and no circuit can remove:")
    print("  the four sensors take a finite difference over a 1 mm box, and over")
    print("  that box the field of a source 3 mm away is far from linear. It gets")
    print("  better as the source moves away. The last column, what the chip adds,")
    print("  gets WORSE as it moves away, because the signal weakens while the")
    print("  200 ppm of sensor offset stays. The two cross: there is a best")
    print("  distance, not a monotonic 'closer is better'.")

    print(f"\n{'=' * 84}\n  AND THE DECISION\n{'=' * 84}")
    print(f"  {'model':10s} {'distance':>9s}  {'version':11s} {'hit':>8s} "
          f"{'undecided':>11s}  {'ideal_read ties':>11s}")
    for (kind, dist, suf) in sorted(res):
        r = res[(kind, dist, suf)]
        print(f"  {kind:10s} {dist:8.0f}um  {NOM[suf]:11s} {np.mean(r['ac']):7.2f}% "
              f"{np.mean(r['in']):10.2f}%  {np.mean(r['emp']):10.2f}%")

    dest = dat / "fuente.csv"
    with dest.open("w") as fh:
        fh.write("model,distancia_um,version,grados_chip,grados_ideal,"
                 "hit,indefinido,empates\n")
        for (kind, dist, suf) in sorted(res):
            r = res[(kind, dist, suf)]
            fh.write(f"{kind},{dist:.0f},{suf},{np.mean(r['ang']):.4f},"
                     f"{np.mean(r['ang_id']):.4f},{np.mean(r['ac']):.4f},"
                     f"{np.mean(r['in']):.4f},{np.mean(r['emp']):.4f}\n")
    print(f"\n  data -> {dest}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
