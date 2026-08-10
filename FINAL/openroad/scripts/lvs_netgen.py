#!/usr/bin/env python3
"""LVS con netgen sobre los bloques y el top.

Segunda opinión frente al LVS de KLayout, con dos motores independientes y dos
extracciones distintas: la de KLayout sale de su propio deck y la de aquí sale de
magic (`layouts/<B>/mag/<B>_extracted.spice`, que ya genera `build_block.py`).
Que los dos digan lo mismo vale bastante más que que lo diga uno.

    python3 scripts/lvs_netgen.py [bloque ...]

Sin argumentos corre los cuatro bloques. `GRADIENT_NAV` se pide aparte porque
antes hay que extraer el top con magic, que tarda.
"""

from __future__ import annotations

import re
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
PROJECT = ROOT.parent
LAYOUTS = PROJECT / "layouts"
NETGEN = "/foss/tools/bin/netgen"
SETUP = "/foss/pdks/gf180mcuD/libs.tech/netgen/gf180mcuD_setup.tcl"
MAGIC = "/foss/tools/bin/magic"
MAGICRC = "/foss/pdks/gf180mcuD/libs.tech/magic/gf180mcuD.magicrc"

BLOCKS = ("COMP", "OPAM", "DECODER", "WEIGHT_COMP")


def block_pair(name: str) -> tuple[Path, Path]:
    """(netlist del layout, netlist de referencia) de un bloque."""
    d = LAYOUTS / name
    return d / "mag" / f"{name}_extracted.spice", d / f"{name}_lvs.spice"


def extract_top(work: Path) -> Path:
    """Extrae el GDS del top con magic. Es lo más lento de todo esto."""
    work.mkdir(parents=True, exist_ok=True)
    (work / ".ext").mkdir(exist_ok=True)
    out = work / "GRADIENT_NAV_extracted.spice"
    script = work / "extract_top.tcl"
    script.write_text(
        f"gds read {ROOT / 'out/GRADIENT_NAV.gds'}\n"
        "load GRADIENT_NAV\n"
        # Aplanar ANTES de extraer, igual que hace build_block.py con cada
        # bloque. Sin esto la extraccion sale jerarquica y los nombres de net
        # llevan el camino de instancia (`Unnamed_976$1_0/w_...`): netgen veia 994
        # nets contra las 880 de la referencia, casi todas fragmentos de la misma.
        "flatten GRADIENT_NAV_f\n"
        "load GRADIENT_NAV_f\n"
        "cellname delete GRADIENT_NAV\n"
        "cellname rename GRADIENT_NAV_f GRADIENT_NAV\n"
        "select top cell\n"
        #  MISMA receta que `build_block.py` usa con cada bloque. La de antes
        #  llevaba `extract do local` y no llevaba `extract path`, y con ella el
        #  pozo n de cada macro salia como un nodo flotante (`w_1724_75756#`) en
        #  vez de VDD: 43 nets de pozo y 47 de activo de mas, que es casi todo el
        #  hueco de 986 contra 880. Extraido igual que los bloques, no.
        f"extract path {work / '.ext'}\n"
        "ext2spice lvs\n"
        "extract all\n"
        f"ext2spice -p {work / '.ext'} -o GRADIENT_NAV_extracted.spice\n"
        "quit -noprompt\n")
    subprocess.run(
        [MAGIC, "-dnull", "-noconsole", "-rcfile", MAGICRC, script.name],
        cwd=work, capture_output=True, text=True, timeout=14400, check=False,
        env={"PATH": "/usr/bin:/bin", "PDK_ROOT": "/foss/pdks", "HOME": "/tmp"})
    if not out.exists():
        sys.exit(f"magic no extrajo el top; no hay {out}")
    return out


#: Como llama magic al MIM al extraerlo, frente a como lo llama el esquematico.
#: Son el mismo dispositivo; los nombres no coinciden porque uno sale del
#: techfile de magic y el otro del simbolo de xschem.
_CAP_MODEL = ("cap_mim_2f0fF", "cap_mim_2f0_m4m5_noshield")


def as_subckt_calls(ref: Path, work: Path) -> Path:
    """Convierte los MOSFET `M...` de la referencia en llamadas `X...`.

    Los dos motores de LVS quieren convenios opuestos y no hay uno que valga para
    los dos. KLayout necesita `M` —un elemento que empieza por otra letra no es un
    MOSFET para SPICE, y con `X` leia cero transistores—. magic, en cambio,
    extrae `X0 ... pfet_06v0`, porque en el PDK esos modelos son subcircuitos, y
    netgen entonces compara una llamada a subcircuito contra un dispositivo y no
    empareja ni uno.

    Lo mismo con los condensadores MIM: la referencia los trae como elementos `C`
    con modelo `cap_mim_2f0fF` y magic los extrae como llamada a
    `cap_mim_2f0_m4m5_noshield`, asi que netgen comparaba un condensador de pines
    `top`/`bottom` contra un subcircuito de pines posicionales y no emparejaba
    ninguno de los dos.

    Asi que la referencia se traduce aqui, para netgen y solo para netgen. El
    `<B>_lvs.spice` de disco no se toca: es el que usa KLayout.
    """
    src = ref.read_text().splitlines()
    out, n = [], 0
    for line in src:
        # xschem comenta el `.subckt` de la celda de arriba cuando exporta desde
        # la CLI (`**.subckt GRADIENT_NAV ...`). netgen necesita verlo.
        if line.startswith("**.subckt ") or line.startswith("**.ends"):
            out.append(line[2:])
            n += 1
        elif re.match(r"^[Mm]\S*\s", line):
            out.append("X" + line)
            n += 1
        elif re.match(r"^[Cc]\S*\s", line) and _CAP_MODEL[0] in line:
            out.append("X" + line.replace(*_CAP_MODEL))
            n += 1
        else:
            out.append(line)
    if not n:
        return ref
    work.mkdir(parents=True, exist_ok=True)
    dst = work / (ref.stem + "_netgen.spice")
    dst.write_text("\n".join(out) + "\n")
    return dst


def align_ports(layout: Path, ref: Path, cell: str, work: Path) -> Path:
    """Reordena los puertos del `.subckt` extraído para que sigan al de referencia.

    magic los lista en el orden en que encuentra las etiquetas y el esquemático en
    el suyo, y netgen empareja los pines del top **por posición**: con la misma
    conectividad exacta (18 dispositivos y 86 nets a cada lado en DECODER)
    terminaba en `Top level cell failed pin matching` sólo por eso, y encima
    avisando de que las simetrías del bloque le impedían deshacer el empate.

    Reordenar la lista de puertos de la celda de arriba no puede cambiar nada:
    nadie la instancia, así que ese orden no es más que su interfaz.
    """
    def ports(path: Path) -> list[str]:
        for line in path.read_text().splitlines():
            if line.lower().startswith(".subckt ") and line.split()[1] == cell:
                return line.split()[2:]
        sys.exit(f"no encuentro '.subckt {cell}' en {path}")

    want, have = ports(ref), ports(layout)
    if set(want) != set(have):
        # Que falte o sobre un puerto NO se arregla reordenando: es una
        # diferencia real y el LVS tiene que verla.
        return layout
    if want == have:
        return layout

    work.mkdir(parents=True, exist_ok=True)
    out = work / f"{cell}_extracted_ordered.spice"
    lines = []
    for line in layout.read_text().splitlines():
        if line.lower().startswith(".subckt ") and line.split()[1] == cell:
            line = ".subckt " + cell + " " + " ".join(want)
        lines.append(line)
    out.write_text("\n".join(lines) + "\n")
    return out


def setup_with_cap_permute(work: Path) -> Path:
    """El setup del PDK mas los dos terminales del MIM declarados permutables.

    Los dos MIM de COMP y de OPAM son identicos y comparten un terminal en `OUT`:
    topologicamente son intercambiables salvo por el orden de sus dos pines, y
    netgen no sabe deshacer ese empate — lo dice el, `Port matching may fail to
    disambiguate symmetries`. Con 52 dispositivos y 37 nets iguales a cada lado,
    lo unico que quedaba era eso.

    Permutar los dos terminales de un condensador de dos patas es lo que hace el
    LVS de KLayout, que da `Netlists match` sobre estas mismas netlists.
    """
    work.mkdir(parents=True, exist_ok=True)
    dst = work / "setup_con_permute.tcl"
    dst.write_text(f'source {SETUP}\n'
                   'permute "-circuit1 cap_mim_2f0_m4m5_noshield" 1 2\n'
                   'permute "-circuit2 cap_mim_2f0_m4m5_noshield" 1 2\n')
    return dst


def compare(layout: Path, ref: Path, cell: str, report: Path,
            setup: Path) -> tuple[bool, str]:
    cmd = (f'lvs "{layout} {cell}" "{ref} {cell}" {setup} {report} '
           f'-json -blackbox\n')
    r = subprocess.run([NETGEN, "-batch", "source", "/dev/stdin"],
                       input=cmd, capture_output=True, text=True,
                       timeout=7200, check=False)
    out = r.stdout + r.stderr
    text = report.read_text() if report.exists() else out
    ok = "Circuits match uniquely" in text or "Circuits match uniquely" in out
    return ok, out


def main() -> int:
    names = sys.argv[1:] or list(BLOCKS)
    outdir = ROOT / "out"
    outdir.mkdir(parents=True, exist_ok=True)
    bad = 0
    for name in names:
        if name == "GRADIENT_NAV":
            layout = extract_top(ROOT / "work_lvs")
            ref = PROJECT / ("XSCHEM/simulation/GRADIENT_NAV.sch/"
                             "GRADIENT_NAV.spice")
        else:
            layout, ref = block_pair(name)
        for p in (layout, ref):
            if not p.exists():
                print(f"  {name:14s} falta {p}")
                bad += 1
                break
        else:
            work = ROOT / "work_lvs"
            ref = as_subckt_calls(ref, work)
            layout = align_ports(layout, ref, name, work)
            report = outdir / f"lvs_netgen_{name}.rpt"
            ok, log = compare(layout, ref, name, report,
                              setup_with_cap_permute(work))
            (outdir / f"lvs_netgen_{name}.log").write_text(log)
            print(f"  {name:14s} {'Circuits match uniquely' if ok else 'NO CUADRA'}"
                  f"   -> {report.name}")
            if not ok:
                bad += 1
    return 1 if bad else 0


if __name__ == "__main__":
    sys.exit(main())
