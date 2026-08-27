#!/usr/bin/env python3
"""Where does the vote counter's step fall against the buffer's trip point?

    python3 analizar_umbral.py <simulation dir>

The question is one number: with the levels as they are, is there a VOTE COUNT
at which the buffer flips, and does that count stay the same over VDD and
temperature? Anything else -- how pretty the steps look, how big the swing is --
does not matter to the decide the chip has to make.
"""

from __future__ import annotations

import sys
from pathlib import Path

import numpy as np

THRESHOLD = 2.5     # only used to read OUT as a logic level; OUT is rail to rail


def main() -> int:
    sim = Path(sys.argv[1])
    rows = [l.split(",") for l in (sim / "manifiesto.csv").read_text().splitlines()[1:]
             if l.strip()]
    #  (temp, votes) -> list of (vdd, we, out)
    data: dict[tuple[int, int], list] = {}
    for f in rows:
        idx, temp, votes = int(f[0]), int(f[1]), int(f[2])
        p = sim / f"u{idx:03d}.txt"
        if not p.exists():
            print(f"  falta {p.name}")
            continue
        d = np.loadtxt(p)
        #  wrdata writes an (x, y) pair per vector: vdd, we, vdd, out, vdd, out_n
        data.setdefault((temp, votes), []).append((d[:, 0], d[:, 1], d[:, 3]))

    temps = sorted({t for t, _ in data})
    print(f"\n{'=' * 76}\n  THE ANALOGUE LEVEL, per vote count and supply\n{'=' * 76}")
    print(f"  {'temp':>5s} {'VDD':>6s} " + " ".join(f"{v} votes" for v in range(5)))
    for temp in temps:
        for vdd_i, vdd in ((0, 4.5), (10, 5.0), (20, 5.5)):
            fila = []
            for v in range(5):
                xs = data.get((temp, v))
                if not xs:
                    fila.append("     -  ")
                    continue
                #  every combination with the same vote count must give the same
                #  level; the spread says whether the branches really are equal
                fila.append(f"{np.mean([w[vdd_i] for _, w, _ in xs]):7.3f} ")
            print(f"  {temp:4d}C {vdd:5.2f}V " + " ".join(fila))

    print(f"\n{'=' * 76}\n  WHERE THE BUFFER FLIPS\n{'=' * 76}")
    print(f"  {'temp':>5s} {'VDD':>6s}  {'OUT per vote count 0..4':>26s}   verdict")
    bad = []
    for temp in temps:
        for vdd_i, vdd in ((0, 4.5), (5, 4.75), (10, 5.0), (15, 5.25), (20, 5.5)):
            bits = []
            for v in range(5):
                xs = data.get((temp, v))
                bits.append(-1 if not xs else
                            int(np.mean([o[vdd_i] for _, _, o in xs]) > THRESHOLD))
            #  Where does it change, reading 0..4 votes left to right?
            cambios = [v for v in range(1, 5)
                       if bits[v] != bits[v - 1] and -1 not in (bits[v], bits[v - 1])]
            if len(cambios) == 1:
                ver = f"flips at {cambios[0]} votes"
                if cambios[0] != 2:
                    bad.append((temp, vdd, cambios[0]))
            elif not cambios:
                ver = "NEVER FLIPS"
                bad.append((temp, vdd, None))
            else:
                ver = f"flips {len(cambios)} times: {cambios}"
                bad.append((temp, vdd, cambios))
            print(f"  {temp:4d}C {vdd:5.2f}V  " + " ".join(str(b) for b in bits).rjust(26)
                  + f"   {ver}")

    print()
    if bad:
        print(f"  NO GOOD: at {len(bad)} of the {len(temps) * 5} corners the "
              f"buffer does not flip between 1 and 2 votes.")
        print("  It has to flip at 2 EVERYWHERE for the decision to be 'this axis")
        print("  wins from two votes on'. If it fails at one corner, it fails in")
        print("  the chip.")
        return 1
    print("  GOOD: the buffer flips between 1 and 2 votes at EVERY corner of the")
    print("  VDD and temperature box swept.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
