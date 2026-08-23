#!/usr/bin/env python3
"""Sign-off DRC with KLayout, on the blocks and on the top.

The PDK deck (`libs.tech/klayout/tech/drc`) is the sign-off one: it decides.
OpenROAD's own router DRC (`out/route_drc.rpt`) checks fewer rules -- it knows
no `MIMTM.*` at all, for instance -- so settling for that one would be marking
por bueno a uno mismo.

    python3 scripts/drc_klayout.py [bloque ...]
"""

from __future__ import annotations

import collections
import glob
import subprocess
import os
import sys
import xml.etree.ElementTree as ET
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
PROJECT = ROOT.parent
RUNNER = "/foss/pdks/gf180mcuD/libs.tech/klayout/tech/drc/run_drc.py"

#: Output directory of the top, so v2 can be checked without stepping on v1's.
#: The Makefile sets it (`TOP_OUT`), same as in the OpenROAD scripts.
OUT = ROOT / os.environ.get("TOP_OUT", "out")

#: Which top cell gets checked. `GRADIENT_NAV` builds four GRADIENT blocks
#: (the 98 dB OPAM); `GRADIENT_NAV2` is the same schematic with GRADIENT2,
#: that is with OPAM_LIN_flat. The Makefile sets it with `T=`, like `TOP_OUT`.
TOP = os.environ.get("TOP_CELL", "GRADIENT_NAV")

TARGETS = {
    "COMP": ROOT / "gds/COMP.gds",
    "OPAM": ROOT / "gds/OPAM.gds",
    "DECODER": ROOT / "gds/DECODER.gds",
    "WEIGHT_COMP": ROOT / "gds/WEIGHT_COMP.gds",
    "OPAM_LIN_flat": ROOT / "gds/OPAM_LIN_flat.gds",
    "DECODER_MAX": ROOT / "gds/DECODER_MAX.gds",
    "OPAM_SUMA": ROOT / "gds/OPAM_SUMA.gds",
    TOP: OUT / f"{TOP}.gds",
    #  The same top with the decoupling capacitors dropped into the gaps
    #  (`scripts/decap_fill.py`). This is the intermediate step: the file that
    #  `fill_density.py` later fills comes from here.
    f"{TOP}_DECAP": OUT / f"{TOP}_decap.gds",
    #  The same top with the density fill (`scripts/fill_density.py`). This is
    #  the submission deliverable; the one above stays for the debug loop.
    f"{TOP}_FILLED": OUT / f"{TOP}_filled.gds",
}


#: The filled GDS keeps the cell name of the original.
TOPCELL = {f"{TOP}_FILLED": TOP, f"{TOP}_DECAP": TOP}


def counts(run_dir: Path) -> collections.Counter:
    c: collections.Counter = collections.Counter()
    for f in glob.glob(str(run_dir / "*.lyrdb")):
        try:
            root = ET.parse(f).getroot()
        except ET.ParseError:
            continue
        for item in root.iter("item"):
            cat = (item.findtext("category") or "").strip("'")
            if cat:
                c[cat] += 1
    return c


def main() -> int:
    #  DENSITY rules are a separate pass: the deck does not run them unless
    #  asked, so until now they had never been checked in this flow at all.
    #  magic is no alternative here -- its GF180 techfile carries not a single
    #  density rule, so this check only exists in KLayout.
    densidad = "--density" in sys.argv
    names = [a for a in sys.argv[1:] if not a.startswith("-")] or list(TARGETS)
    bad = 0
    for name in names:
        gds = TARGETS.get(name)
        if gds is None:
            sys.exit(f"unknown target {name}; I know {', '.join(TARGETS)}")
        if not gds.exists() or not gds.resolve().exists():
            print(f"  {name:14s} sin GDS todavia — saltado")
            continue
        run_dir = ROOT / "out" / (f"density_{name}" if densidad else f"drc_{name}")
        subprocess.run(["rm", "-rf", str(run_dir)], check=False)
        run_dir.mkdir(parents=True, exist_ok=True)
        subprocess.run(
            ["python3", RUNNER, f"--path={gds.resolve()}", "--variant=D",
             f"--topcell={TOPCELL.get(name, name)}", f"--run_dir={run_dir}", "--mp=4"]
            + (["--density_only"] if densidad else []),
            capture_output=True, text=True, timeout=14400, check=False,
            env={"PATH": "/foss/tools/klayout:/usr/bin:/bin",
                 "HOME": "/tmp", "PDK_ROOT": "/foss/pdks"})
        #  **If there is not one `.lyrdb`, the deck never ran.** Without this, a
        #  tool failure -- a `klayout` missing from PATH, an unreadable GDS --
        #  counted as zero violations and printed as "clean". Same mistake as
        #  the empty `net.name` in `check_connectivity`: the check does not
        #  fail, it lies.
        if not list(run_dir.glob("*.lyrdb")):
            print(f"  {name:14s} THE DECK DID NOT RUN -- no .lyrdb in {run_dir}")
            bad += 1
            continue
        c = counts(run_dir)
        if not c:
            print(f"  {name:14s} limpio")
            continue
        bad += 1
        total = sum(c.values())
        detail = "  ".join(f"{k} x{v}" for k, v in c.most_common(10))
        print(f"  {name:14s} {total} violaciones: {detail}")
    return 1 if bad else 0


if __name__ == "__main__":
    sys.exit(main())
