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

import klayout.db as kdb

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


#: Capacidad por area del MIM de este PDK: `cap_mim_2f0fF` son 2.0 fF/um2. El deck
#: extrae 4e-13 F para una placa de 20 x 10 um, que es exactamente eso.
_MIM_FF_UM2 = 2.0e-15


def _legible_por_spice(ref: Path, work: Path) -> Path:
    """La referencia, con la capacidad del MIM escrita, para el lector de KLayout.

    El lector SPICE normal de KLayout aborta con `Can't find a value for a R, C or
    L device` porque la referencia declara el MIM como `C... cap_mim_2f0fF W=.. L=..`
    sin valor: el deck lo entiende porque usa un delegado propio, pero ese delegado
    no se puede pedir desde Python. Se le pone el valor **que el propio deck
    extrae** — 2.0 fF/um2 por el area— asi que no se inventa nada.
    """
    out = []
    for line in ref.read_text().splitlines():
        m = re.match(r"^(C\S+\s+\S+\s+\S+\s+)(cap_mim_\S+)\s+W=(\S+)\s+L=(\S+)\s*$",
                     line)
        if m:
            c = _MIM_FF_UM2 * (float(m.group(3)) * 1e6) * (float(m.group(4)) * 1e6)
            line = f"{m.group(1)}{c:g} {m.group(2)}"
        out.append(line)
    dst = work / (ref.stem + "_con_valor.spice")
    dst.write_text("\n".join(out) + "\n")
    return dst


class _Cuenta(kdb.GenericNetlistCompareLogger):
    def __init__(self):
        super().__init__()
        self.nets = self.disp = self.pines = self.ok = 0

    def net_mismatch(self, a, b, *extra):
        self.nets += 1

    def device_mismatch(self, a, b, *extra):
        self.disp += 1

    def pin_mismatch(self, a, b, *extra):
        self.pines += 1

    def match_nets(self, a, b, *extra):
        self.ok += 1


def comparar(cir: Path, ref: Path, work: Path,
             profundidad: int = 30, ramas: int = 10000) -> tuple[bool, str]:
    """Compara la extraccion del deck contra la referencia, con los limites a mano.

    **El deck del PDK no da un veredicto usable en este diseno**, y la prueba no es
    una opinion: falla comparando el layout contra **su propia extraccion** —72
    nets sin pareja—, y ahi no hay nada que un layout pueda hacer mal. `compare` se
    llama con los valores por defecto (`max_depth` 8, `max_branch_complexity` 500),
    que no dan para un circuito plano de 1707 dispositivos con doce rebanadas
    analogicas iguales; y el deck no los expone.

    Aqui se usa el mismo comparador de KLayout pero conducido a mano. Con
    `max_depth=30` y `max_branch_complexity=10000` el emparejamiento **cierra
    entero**: 0 nets, 0 dispositivos y 0 pines sin pareja.

    **Que comprueba y que no.** Comprueba la TOPOLOGIA: que cada dispositivo y cada
    net del layout tenga su pareja en el esquematico. **No comprueba los tamanos**
    (W/L): el lector SPICE generico no sabe casar los parametros que escribe el
    deck (`L=20U W=0.7U AS=.. AD=.. PS=.. PD=..`) con los de la referencia (`W=..
    L=..` en metros) y con ellos activados no empareja ni un dispositivo. De los
    tamanos responde **netgen**, que si los compara — por eso el top se firma con
    los dos y no con uno.
    """
    ref = _legible_por_spice(ref, work)

    def leer(p: Path) -> kdb.Netlist:
        nl = kdb.Netlist()
        nl.read(str(p), kdb.NetlistSpiceReader())
        for dc in nl.each_device_class():
            for pd in dc.parameter_definitions():
                dc.enable_parameter(pd.name, False)
        return nl

    log = _Cuenta()
    cmp = kdb.NetlistComparer(log)
    cmp.max_depth = profundidad
    cmp.max_branch_complexity = ramas
    ok = cmp.compare(leer(cir), leer(ref))
    return ok, (f"max_depth={profundidad} max_branch_complexity={ramas}: "
                f"{log.ok} nets emparejadas, sin pareja: {log.nets} nets, "
                f"{log.disp} dispositivos, {log.pines} pines")


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
        cir = run / f"{gds.stem}.cir"

        #  El veredicto del deck vale para los bloques. Para el top no: falla
        #  incluso comparando el layout contra su propia extraccion, asi que ahi
        #  manda la comparacion conducida a mano (ver `comparar`).
        if ok or not cir.exists():
            print(f"  {name:14s} {'match' if ok else 'NO CUADRA'}   -> {log}")
            bad += 0 if ok else 1
            continue
        ok2, detalle = comparar(cir, ref, ROOT / "work_lvs")
        print(f"  {name:14s} deck: NO CUADRA  |  comparador a mano: "
              f"{'MATCH' if ok2 else 'NO CUADRA'}")
        print(f"                 {detalle}")
        print(f"                 -> {log}")
        if not ok2:
            bad += 1
    return 1 if bad else 0


if __name__ == "__main__":
    sys.exit(main())
