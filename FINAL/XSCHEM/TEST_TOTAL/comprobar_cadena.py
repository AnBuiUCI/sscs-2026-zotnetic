#!/usr/bin/env python3
"""Checks that a hand-rebuilt chain is the SAME as the schematic one.

    python3 comprobar_cadena.py <netlist> GRADIENT  3
    python3 comprobar_cadena.py <netlist> GRADIENT2 4

Why it is needed. Chains G3 and G4 are written by hand, instantiating the
blocks extracted from the v2 layout with SPICE connections. Comparing G1 with
G3 only means something if both are the same circuit, and there are two ways
for them not to be without any error going off:

  * **The port order does not match.** xschem emits them in the order of the
    symbol B lines and magic in the order it finds them in the layout:

        esquematico  .subckt OPAM            VDD INN OUT INP VSS
        extraido     .subckt OPAM_V2         VSS VDD OUT INP INN
        extraido     .subckt OPAM_LIN_flat_V2 VSS VDD INP OUT INN   <- OUT en medio

    Cablear las dos igual significa cosas distintas. La simulacion corre y
    devuelve numeros.

  * **Un nodo mal tecleado.** Un `SY3` donde iba `SZ3` no es un error de sintaxis:
    es otro circuito.

How it checks. It reads each subcircuit's declared ports from the netlist,
turns each instance into a pin -> node dictionary, and compares the two chains
como grafos:

  * EXTERNAL nodes are matched by role (S1P is the SXP of the rebuilt chain,
    VDD3 is its VDD, GND is its VSS, X3 is its X...),
  * INTERNAL nodes are not matched by name -- they are named differently on
    purpose -- but by which pins of which cells they touch,
  * and the cells are matched by family: OPAM and OPAM_V2 are both the
    amplificador, OPAM_LIN y OPAM_LIN_flat_V2 tambien.

If the two graphs do not come out equal, it prints which instance is extra or
devuelve 1.
"""

from __future__ import annotations

import sys
from collections import defaultdict
from pathlib import Path

#: Each cell to its family, so the schematic can be compared with the extraction.
FAMILIA = {
    "OPAM": "AMP", "OPAM_V2": "AMP",
    "OPAM_LIN": "AMP", "OPAM_LIN_flat_V2": "AMP",
    "COMP": "COMP", "COMP_V2": "COMP",
    "DECODER": "DEC", "DECODER_V2": "DEC",
}


def puertos(lineas: list[str], base: Path) -> dict[str, list[str]]:
    """Subcircuit name -> port list, exactly as the netlist declares them.

    It follows the `.include`s, because the extracted blocks' ports are NOT in
    the xschem netlist but in magic's file, and that order is exactly what must
    be read and not assumed.
    """
    out = {}
    for ln in lineas:
        t = ln.split()
        if not t:
            continue
        if t[0].lower() == ".subckt":
            out[t[1]] = t[2:]
        elif t[0].lower() == ".include" and len(t) > 1:
            inc = (base / t[1].strip('"')).resolve()
            if inc.is_file():
                out.update(puertos(inc.read_text().splitlines(), inc.parent))
    return out


def instancias(cuerpo: list[str], pts: dict[str, list[str]]) -> list[tuple[str, dict]]:
    """Instance lines -> (cell, pin -> node). Skips anything that is not a cell."""
    out = []
    for ln in cuerpo:
        t = ln.split()
        if not t or t[0][0].lower() != "x" or t[-1] not in FAMILIA:
            continue
        celda, nodos = t[-1], t[1:-1]
        p = pts[celda]
        if len(p) != len(nodos):
            sys.exit(f"  {t[0]}: {len(nodos)} nodos contra {len(p)} puertos de {celda}")
        out.append((celda, dict(zip(p, nodos))))
    return out


def grafo(insts: list[tuple[str, dict]], externos: dict[str, str]) -> list:
    """Each instance as (family, pins ordered with their canonical node).

    Internal nodes are labelled by what each one touches -- the set of
    (family, pin) pairs touching it -- and not by name, which is exactly what
    differs between the two chains.
    """
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
    netlist, subckt, suf = Path(sys.argv[1]), sys.argv[2], sys.argv[3]
    lineas = netlist.read_text().splitlines()
    pts = puertos(lineas, netlist.parent)

    #  --- the schematic chain: the body of its .subckt
    try:
        i = next(k for k, ln in enumerate(lineas)
                 if ln.split()[:2] == [".subckt", subckt])
    except StopIteration:
        print(f"  no encuentro .subckt {subckt} en {netlist}", file=sys.stderr)
        return 1
    j = next(k for k in range(i + 1, len(lineas)) if lineas[k].split()[:1] == [".ends"])
    esq = instancias(lineas[i + 1:j], pts)

    #  --- the rebuilt chain: the top-level instances hanging off VDD<suffix>
    tope = lineas[:next(k for k, ln in enumerate(lineas)
                        if ln.startswith("**** begin user architecture code"))] \
        + [ln for ln in lineas if ln.split()[:1] and ln.split()[0].upper().startswith("X")]
    rc = [(c, p) for c, p in instancias(tope, pts) if f"VDD{suf}" in p.values()]

    if not rc:
        print(f"  no hay ninguna instancia colgada de VDD{suf}", file=sys.stderr)
        return 1

    ext_esq = {n: n for n in ("SXN", "SXP", "SYN", "SYP", "SZN", "SZP",
                              "VDD", "VSS", "X", "Y", "Z")}
    ext_rc = {"S1N": "SXN", "S1P": "SXP", "S2N": "SYN", "S2P": "SYP",
              "S3N": "SZN", "S3P": "SZP", f"VDD{suf}": "VDD", "GND": "VSS",
              f"X{suf}": "X", f"Y{suf}": "Y", f"Z{suf}": "Z"}

    ga, gb = grafo(esq, ext_esq), grafo(rc, ext_rc)
    if ga == gb:
        print(f"    {subckt} y la cadena de VDD{suf}: mismo circuito"
              f"  ({len(esq)} celdas)")
        return 0

    print(f"  LA CADENA DE VDD{suf} NO ES {subckt}", file=sys.stderr)
    for etiq, falta in (("only in the schematic", [x for x in ga if x not in gb]),
                        ("solo en la rehecha   ", [x for x in gb if x not in ga])):
        for fam, pines in falta:
            print(f"    {etiq}: {fam} " +
                  " ".join(f"{p}={n}" for p, n in pines), file=sys.stderr)
    return 1


if __name__ == "__main__":
    sys.exit(main())
