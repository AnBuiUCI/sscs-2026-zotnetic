#!/usr/bin/env python3
"""DRC de firma con KLayout, sobre los cuatro bloques y el top.

El deck del PDK (`libs.tech/klayout/tech/drc`) es el de firma: es el que decide.
El DRC del propio router de OpenROAD (`out/route_drc.rpt`) mira menos reglas —no
conoce ninguna `MIMTM.*`, por ejemplo—, asi que quedarse con aquel seria darse
por bueno a uno mismo.

    python3 scripts/drc_klayout.py [bloque ...]
"""

from __future__ import annotations

import collections
import glob
import subprocess
import sys
import xml.etree.ElementTree as ET
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
PROJECT = ROOT.parent
RUNNER = "/foss/pdks/gf180mcuD/libs.tech/klayout/tech/drc/run_drc.py"

TARGETS = {
    "COMP": ROOT / "gds/COMP.gds",
    "OPAM": ROOT / "gds/OPAM.gds",
    "DECODER": ROOT / "gds/DECODER.gds",
    "WEIGHT_COMP": ROOT / "gds/WEIGHT_COMP.gds",
    "GRADIENT_NAV": ROOT / "out/GRADIENT_NAV.gds",
    #  El mismo top con el relleno de densidad (`scripts/fill_density.py`). Es el
    #  entregable de submision; el de arriba se queda para el lazo de depuracion.
    "GRADIENT_NAV_FILLED": ROOT / "out/GRADIENT_NAV_filled.gds",
}


#: El GDS con relleno conserva el nombre de celda del original.
TOPCELL = {"GRADIENT_NAV_FILLED": "GRADIENT_NAV"}


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
    #  Las reglas de DENSIDAD van aparte: el deck no las corre salvo que se le
    #  pidan, asi que hasta ahora no se habian comprobado nunca en este flujo.
    #  magic no es alternativa aqui — su techfile de GF180 no trae ni una regla
    #  de densidad, asi que esta comprobacion solo existe en KLayout.
    densidad = "--density" in sys.argv
    names = [a for a in sys.argv[1:] if not a.startswith("-")] or list(TARGETS)
    bad = 0
    for name in names:
        gds = TARGETS.get(name)
        if gds is None:
            sys.exit(f"no se que es {name}; conozco {', '.join(TARGETS)}")
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
