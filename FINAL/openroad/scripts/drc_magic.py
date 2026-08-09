#!/usr/bin/env python3
"""DRC con magic sobre los bloques y el top.

Es una **segunda opinión**, no un sustituto: el deck de KLayout
(`libs.tech/klayout/tech/drc`) y el de magic (la sección `drc` de
`gf180mcuD.tech`) no cubren exactamente las mismas reglas. Lo interesante de
correr los dos es justamente lo que sale en uno y no en el otro.

    python3 scripts/drc_magic.py [bloque ...]

Sin argumentos corre los cuatro bloques y el top. Devuelve un código distinto de
cero si algún GDS tiene violaciones, para que `make` se entere.
"""

from __future__ import annotations

import re
import shutil
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
PROJECT = ROOT.parent
MAGIC = "/foss/tools/bin/magic"
MAGICRC = "/foss/pdks/gf180mcuD/libs.tech/magic/gf180mcuD.magicrc"

TARGETS = {
    "COMP": ROOT / "gds/COMP.gds",
    "OPAM": ROOT / "gds/OPAM.gds",
    "DECODER": ROOT / "gds/DECODER.gds",
    "WEIGHT_COMP": ROOT / "gds/WEIGHT_COMP.gds",
    "GRADIENT_NAV": ROOT / "out/GRADIENT_NAV.gds",
}


def run(cell: str, gds: Path, work: Path) -> tuple[int, str]:
    work.mkdir(parents=True, exist_ok=True)
    script = work / f"{cell}_drc.tcl"
    script.write_text(
        # `-noconsole -dnull` para que no intente abrir ventana ninguna.
        f"gds read {gds}\n"
        f"load {cell}\n"
        "select top cell\n"
        # Euclidiano, como el deck de KLayout: con la métrica por defecto
        # (Manhattan) magic es más permisivo y los dos no serían comparables.
        "drc euclidean on\n"
        "drc check\n"
        "drc catchup\n"
        "set n [drc list count total]\n"
        'puts "MAGIC_DRC_COUNT $n"\n'
        "if {$n > 0} { puts [drc listall why] }\n"
        "quit -noprompt\n")
    r = subprocess.run(
        [MAGIC, "-dnull", "-noconsole", "-rcfile", MAGICRC, script.name],
        cwd=work, capture_output=True, text=True, timeout=7200, check=False,
        env={"PATH": "/usr/bin:/bin", "PDK_ROOT": "/foss/pdks", "HOME": "/tmp"})
    out = r.stdout + r.stderr
    m = re.search(r"MAGIC_DRC_COUNT (\d+)", out)
    if not m:
        # Sin la cuenta no se puede decir que esté limpio: se trata como fallo en
        # vez de dar por bueno un silencio.
        return -1, out
    return int(m.group(1)), out


def main() -> int:
    names = sys.argv[1:] or list(TARGETS)
    work = ROOT / "work_drc"
    bad = 0
    for name in names:
        gds = TARGETS.get(name)
        if gds is None:
            sys.exit(f"no sé qué es {name}; conozco {', '.join(TARGETS)}")
        if not gds.exists() or not gds.resolve().exists():
            print(f"  {name:14s} sin GDS todavía — saltado")
            continue
        n, out = run(name, gds.resolve(), work)
        rpt = ROOT / "out" / f"drc_magic_{name}.log"
        rpt.parent.mkdir(parents=True, exist_ok=True)
        rpt.write_text(out)
        if n < 0:
            print(f"  {name:14s} magic no dio la cuenta — ver {rpt}")
            bad += 1
        elif n:
            print(f"  {name:14s} {n} violaciones — ver {rpt}")
            bad += 1
        else:
            print(f"  {name:14s} limpio")
    shutil.rmtree(work, ignore_errors=True)
    return 1 if bad else 0


if __name__ == "__main__":
    sys.exit(main())
