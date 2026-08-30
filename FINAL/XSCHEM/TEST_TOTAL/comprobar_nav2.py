#!/usr/bin/env python3
"""Checks that the hand-rebuilt navigator is the SAME as the schematic one.

    python3 comprobar_nav2.py <netlist>

It is the bench's central check: comparing the schematic output with the layout
one only means something if both are the same circuit, and there are three ways
for them not to be without any error going off.

  * **The port order does not match.** xschem emits them in the order of the
    symbol B lines and magic in the order it finds them in the layout:

        esquematico  .subckt OPAM_LIN          VDD INN OUT INP VSS
        extraido     .subckt OPAM_LIN_flat_V2  VSS VDD INP OUT INN   <- OUT en medio
        extraido     .subckt WEIGHT_COMP_V2    VSS VDD VD WE VA VB OUT OUT_N VC

    Cablear los dos igual significa cosas distintas. La simulacion corre y
    devuelve numeros.

  * **El WEIGHT_COMP cruza dos de sus entradas.** Su propio netlist dice
    `x1 VDD VSS WE VA VB VC VD WEIGHT` contra `.subckt WEIGHT VDD GND OUT VA VC
    VB VD`, so its VB goes to the WEIGHT's VC pin and its VC to VB. Writing it
    'en orden' pesa mal dos cadenas y tampoco da error.

  * **Un nodo mal tecleado.** Un `SY3r` donde iba `SZ3r` no es un error de
    sintaxis: es otro circuito.

How it checks. It flattens `.subckt GRADIENT_NAV2` one level -- its four
GRADIENT2 se abren en amplificadores, comparadores y decodificadores, y cada
WEIGHT + COMP_OUT pair is fused into the block the layout actually has --
y compara ese grafo contra el de las instancias `_V2` escritas a mano:

  * EXTERNAL nodes are matched by role (GND is VSS, VDDR is VDD, Xr is X),
  * INTERNAL nodes are not matched by name -- they are named differently on
    purpose -- but by which pins of which cells they touch,
  * and the cells by family: OPAM_LIN and OPAM_LIN_flat_V2 are both the
    amplificador.
"""

from __future__ import annotations

import sys
from collections import defaultdict
from pathlib import Path

#: Each cell to its family, so the schematic can be compared with the extraction.
FAMILIA = {
    "OPAM_LIN": "AMP", "OPAM_LIN_flat_V2": "AMP",
    "COMP": "COMP", "COMP_V2": "COMP",
    "DECODER": "DEC", "DECODER_V2": "DEC",
    "WEIGHT_COMP_V2": "WC",
}

#: The two schematic cells the layout carries fused into one.
FUSION = ("WEIGHT", "COMP_OUT")


def puertos(lineas: list[str], base: Path) -> dict[str, list[str]]:
    """Subcircuito -> lista de puertos, siguiendo los `.include`.

    The extracted blocks' ports are NOT in the xschem netlist but in magic's
    file, and that order is exactly what must be read and not assumed.
    """
    out: dict[str, list[str]] = {}
    for ln in lineas:
        t = ln.split()
        if not t:
            continue
        if t[0].lower() == ".subckt":
            out[t[1]] = t[2:]
        elif t[0].lower() == ".ends" or t[0].lower() == ".include" and len(t) > 1:
            if t[0].lower() == ".include":
                inc = (base / t[1].strip('"')).resolve()
                if inc.is_file():
                    out.update(puertos(inc.read_text().splitlines(), inc.parent))
    return out


def cuerpo(lineas: list[str], nombre: str) -> list[str]:
    """Las lineas de dentro de un `.subckt`."""
    i = next((k for k, ln in enumerate(lineas)
              if ln.split()[:2] == [".subckt", nombre]), None)
    if i is None:
        sys.exit(f"  no encuentro .subckt {nombre}")
    j = next(k for k in range(i + 1, len(lineas)) if lineas[k].split()[:1] == [".ends"])
    return lineas[i + 1:j]


def llamadas(lineas: list[str], pts: dict[str, list[str]]) -> list[tuple[str, str, dict]]:
    """Lineas de instancia -> (instancia, celda, pin -> nodo)."""
    out = []
    for ln in lineas:
        t = ln.split()
        if not t or t[0][0].lower() != "x" or t[-1] not in pts:
            continue
        celda, nodos = t[-1], t[1:-1]
        p = pts[celda]
        if len(p) != len(nodos):
            sys.exit(f"  {t[0]}: {len(nodos)} nodos contra {len(p)} puertos de {celda}")
        out.append((t[0], celda, dict(zip(p, nodos))))
    return out


def aplanar(lineas, pts, top: str) -> list[tuple[str, dict]]:
    """The schematic top, opened one level and with WEIGHT+COMP_OUT fused.

    Each instance's internal nodes are prefixed with its name, which is what
    stops the four GRADIENT2 copies sharing a node they do not share.
    """
    hojas: list[tuple[str, dict]] = []
    sueltos: dict[str, list[tuple[str, dict]]] = {FUSION[0]: [], FUSION[1]: []}

    for inst, celda, pines in llamadas(cuerpo(lineas, top), pts):
        if celda in FUSION:
            sueltos[celda].append((inst, pines))
            continue
        if celda in FAMILIA:
            hojas.append((celda, pines))
            continue
        #  One more level: its instances are opened, with the internal nodes
        #  prefijados por el nombre de la instancia padre.
        for _, hcelda, hpines in llamadas(cuerpo(lineas, celda), pts):
            if hcelda not in FAMILIA:
                continue
            hojas.append((hcelda, {p: (pines[n] if n in pines else f"{inst}/{n}")
                                   for p, n in hpines.items()}))

    #  And the fusion: each WEIGHT with the COMP_OUT hanging off its output.
    #  `WEIGHT_COMP` feeds its VB to the WEIGHT's VC pin and vice versa; that
    #  cross is undone here so it can be compared with the layout block.
    for _, w in sueltos[FUSION[0]]:
        pareja = next((c for _, c in sueltos[FUSION[1]] if c["IN"] == w["OUT"]), None)
        if pareja is None:
            sys.exit(f"  a {FUSION[0]} without its {FUSION[1]}: OUT={w['OUT']}")
        hojas.append(("WEIGHT_COMP_V2", {
            "VDD": w["VDD"], "VSS": pareja["VSS"],
            "VA": w["VA"], "VB": w["VC"], "VC": w["VB"], "VD": w["VD"],
            "WE": w["OUT"], "OUT": pareja["OUT"], "OUT_N": pareja["OUT_N"]}))
    return hojas


def grafo(insts, externos: dict[str, str]) -> list:
    """Each instance as (family, pins ordered with their canonical node)."""
    toca = defaultdict(set)
    for celda, pines in insts:
        for pin, nodo in pines.items():
            toca[nodo].add((FAMILIA[celda], pin))

    def etiqueta(nodo: str) -> str:
        if nodo in externos:
            return externos[nodo]
        return "int:" + ",".join(sorted(f"{f}.{p}" for f, p in toca[nodo]))

    return sorted((FAMILIA[c], tuple(sorted((pin, etiqueta(n)) for pin, n in p.items())))
                  for c, p in insts)


def main() -> int:
    netlist = Path(sys.argv[1])
    lineas = netlist.read_text().splitlines()
    pts = puertos(lineas, netlist.parent)

    esq = aplanar(lineas, pts, "GRADIENT_NAV2")

    #  The rebuild: the top-level instances, i.e. everything outside
    #  de cualquier `.subckt`.
    fuera, dentro = [], False
    for ln in lineas:
        t = ln.split()
        if t[:1] == [".subckt"]:
            dentro = True
        elif t[:1] == [".ends"]:
            dentro = False
        elif not dentro:
            fuera.append(ln)
    rc = [(c, p) for _, c, p in llamadas(fuera, pts) if c in FAMILIA]

    if not rc:
        print("  not one rebuilt instance at the top level", file=sys.stderr)
        return 1

    señal = ["S1P", "S1N", "S2P", "S2N", "S3P", "S3N", "S4P", "S4N"]
    salida = ["X", "Y", "Z", "XP", "XN", "YP", "YN", "ZP", "ZN"]
    ext_esq = {n: n for n in señal + salida + ["VDD", "VSS"]}
    ext_rc = {n: n for n in señal}
    ext_rc.update({f"{n}r": n for n in salida})
    ext_rc.update({"VDDR": "VDD", "GND": "VSS"})

    ga, gb = grafo(esq, ext_esq), grafo(rc, ext_rc)
    if ga == gb:
        print(f"    the rebuilt navigator is the SAME circuit as the schematic"
              f"  ({len(esq)} celdas)")
        return 0

    print("  EL NAVEGADOR REHECHO NO ES GRADIENT_NAV2", file=sys.stderr)
    for etiq, falta in (("only in the schematic", [x for x in ga if x not in gb]),
                        ("solo en el rehecho    ", [x for x in gb if x not in ga])):
        for fam, pines in falta:
            print(f"    {etiq}: {fam} " +
                  " ".join(f"{p}={n}" for p, n in pines), file=sys.stderr)
    return 1


if __name__ == "__main__":
    sys.exit(main())
