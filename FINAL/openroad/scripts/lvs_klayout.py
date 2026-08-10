#!/usr/bin/env python3
"""LVS con el deck de firma de KLayout, tambien sobre el top.

Los bloques ya lo pasan desde `build_block.py`; esto lo extiende al top, que
hasta ahora solo se comprobaba con netgen. Hace falta porque un **corto no viola
ninguna regla de DRC** —dos formas de nets distintas que se solapan simplemente
se funden en un poligono— y `check_connectivity.py` tampoco lo ve: el comprueba
que los terminales de cada net esten juntos, no que no haya de mas. El unico que
canta un corto con nombres y coordenadas es el LVS.

    python3 scripts/lvs_klayout.py [bloque ...]
"""

from __future__ import annotations

import subprocess
import sys
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
PROJECT = ROOT.parent
RUNNER = "/foss/pdks/gf180mcuD/libs.tech/klayout/tech/lvs/run_lvs.py"

TARGETS = {
    "GRADIENT_NAV": (ROOT / "out/GRADIENT_NAV.gds",
                     PROJECT / "XSCHEM/simulation/GRADIENT_NAV.sch/GRADIENT_NAV.spice"),
    "COMP": (ROOT / "gds/COMP.gds", PROJECT / "layouts/COMP/COMP_lvs.spice"),
    "OPAM": (ROOT / "gds/OPAM.gds", PROJECT / "layouts/OPAM/OPAM_lvs.spice"),
    "DECODER": (ROOT / "gds/DECODER.gds", PROJECT / "layouts/DECODER/DECODER_lvs.spice"),
    "WEIGHT_COMP": (ROOT / "gds/WEIGHT_COMP.gds",
                    PROJECT / "layouts/WEIGHT_COMP/WEIGHT_COMP_lvs.spice"),
}


def prepare(ref: Path, cell: str, work: Path) -> Path:
    """Deja la netlist de referencia en algo que el deck sepa leer.

    El netlist del top sale de xschem con dos cosas que el lector de KLayout no
    admite y que no son del circuito:

    * el `.subckt` de la celda de arriba viene COMENTADO (`**.subckt`), que es
      como xschem exporta desde la CLI;
    * hay fuentes de 0 V (`Vmeas net11 GND 0`) usadas como sonda de corriente.
      `Not a known element type: 'V'`, dice el deck. Una fuente de 0 V es
      electricamente un cable, asi que lo correcto no es tirarla: es **unir las
      dos nets**, que es lo que el layout tiene ahi. Se hace por ambito, dentro
      de cada `.subckt`, porque los nombres de net se repiten entre bloques.
    """
    work.mkdir(parents=True, exist_ok=True)

    #  Y APLANADA. El layout del top es una sola celda (ver
    #  `def_to_gds.py::flatten_all`), asi que la referencia tiene que serlo
    #  tambien: con la jerarquia puesta, el deck no emparejaba ni una de las 954
    #  nets ni uno de los 1707 dispositivos — la comparacion no llegaba a
    #  empezar. Es el mismo aplanado que `build_block.py` le hace a cada bloque.
    sys.path.insert(0, "/foss/designs/zotnetic_layout")
    from flatten_spice import flatten
    _, lvs_txt, _ = flatten(ref.read_text(), cell)
    src = lvs_txt.splitlines()

    #  Primera pasada: aliases de las fuentes de 0 V, por ambito.
    alias: dict[int, dict[str, str]] = {}
    scope, scopes = 0, []
    for line in src:
        low = line.lower()
        if low.startswith(".subckt") or low.startswith("**.subckt"):
            scope += 1
            scopes.append(scope)
        elif low.startswith(".ends") or low.startswith("**.ends"):
            if scopes:
                scopes.pop()
        elif line[:1] in "vV" and not line.startswith("*"):
            tok = line.split()
            if len(tok) >= 4 and tok[3] in ("0", "0.0", "dc", "DC"):
                cur = scopes[-1] if scopes else 0
                alias.setdefault(cur, {})[tok[1]] = tok[2]

    out, scope, scopes = [], 0, []
    for line in src:
        low = line.lower()
        if low.startswith("**.subckt") or low.startswith("**.ends"):
            line = line[2:]
            low = line.lower()
        if low.startswith(".subckt"):
            scope += 1
            scopes.append(scope)
        elif low.startswith(".ends"):
            out.append(line)
            if scopes:
                scopes.pop()
            continue
        elif line[:1] in "vViI" and not line.startswith("*"):
            continue                       # fuentes: ya estan en los aliases
        elif low.startswith((".save", ".control", ".endc", ".tran", ".op",
                            ".dc", ".ac", ".probe", ".meas", ".temp",
                            ".option", ".include", ".lib")):
            continue
        cur = scopes[-1] if scopes else 0
        for a, b in alias.get(cur, {}).items():
            line = re.sub(rf"(?<=[\s]){re.escape(a)}(?=[\s]|$)", b, line)
        out.append(line)

    dst = work / f"{cell}_klayout.spice"
    dst.write_text("\n".join(out) + "\n")
    return dst


def main() -> int:
    bad = 0
    for name in (sys.argv[1:] or ["GRADIENT_NAV"]):
        gds, ref = TARGETS[name]
        run = ROOT / "out" / f"lvs_klayout_{name}"
        subprocess.run(["rm", "-rf", str(run)], check=False)
        run.mkdir(parents=True, exist_ok=True)
        if name == "GRADIENT_NAV":
            ref = prepare(ref, name, ROOT / "work_lvs")
        r = subprocess.run(
            [sys.executable, RUNNER, f"--layout={gds.resolve()}",
             f"--netlist={ref}", "--variant=D", f"--topcell={name}",
             f"--run_dir={run}", "--run_mode=deep", "--thr=4",
             #  Sin esto el netlist extraido sale como `.SUBCKT GRADIENT_NAV` a
             #  secas, sin un solo pin, y el emparejamiento no tiene por donde
             #  empezar: salian 1815 nets y 3414 dispositivos, todos sin pareja.
             #  El deck solo llama a `make_top_level_pins` con este interruptor.
             "--top_lvl_pins",
             #  Descartan nets y objetos sueltos en LOS DOS lados: el layout
             #  arrastra metal que no va a ningun dispositivo (restos del PDN,
             #  plataformas de puerto) y la referencia trae nets de simulacion.
             "--purge", "--purge_nets", "--schematic_simplify",
             #  El sustrato de este diseno se llama VSS. Con el nombre por
             #  defecto del deck (`gf180mcu_gnd`) el nodo sale como `SUB`, sin
             #  correspondencia en la referencia.
             "--lvs_sub=VSS"],
            capture_output=True, text=True, timeout=21600, check=False)
        log = run / "run.log"
        log.write_text(r.stdout + r.stderr)
        ok = "Congratulations! Netlists match." in (r.stdout + r.stderr)
        print(f"  {name:14s} {'match' if ok else 'NO CUADRA'}   -> {log}")
        if not ok:
            bad += 1
    return 1 if bad else 0


if __name__ == "__main__":
    sys.exit(main())
