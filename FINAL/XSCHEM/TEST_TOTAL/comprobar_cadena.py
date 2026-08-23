#!/usr/bin/env python3
"""Comprueba que una cadena rehecha a mano es la MISMA que la del esquematico.

    python3 comprobar_cadena.py <netlist> GRADIENT  3
    python3 comprobar_cadena.py <netlist> GRADIENT2 4

Por que hace falta. Las cadenas G3 y G4 se escriben a mano, instanciando los
bloques extraidos del layout v2 con conexiones de SPICE. Comparar G1 con G3 solo
significa algo si las dos son el mismo circuito, y hay dos formas de que no lo
sean sin que salte ningun error:

  * **El orden de puertos no coincide.** xschem los emite en el orden de las
    lineas B del simbolo y magic en el orden en que los encuentra en el layout:

        esquematico  .subckt OPAM            VDD INN OUT INP VSS
        extraido     .subckt OPAM_V2         VSS VDD OUT INP INN
        extraido     .subckt OPAM_LIN_flat_V2 VSS VDD INP OUT INN   <- OUT en medio

    Cablear las dos igual significa cosas distintas. La simulacion corre y
    devuelve numeros.

  * **Un nodo mal tecleado.** Un `SY3` donde iba `SZ3` no es un error de sintaxis:
    es otro circuito.

Como lo comprueba. Lee del netlist los puertos declarados de cada subcircuito,
traduce cada instancia a un diccionario pin -> nodo, y compara las dos cadenas
como grafos:

  * los nodos EXTERNOS se emparejan por su papel (S1P es el SXP de la cadena
    rehecha, VDD3 es su VDD, GND es su VSS, X3 es su X...),
  * los nodos INTERNOS no se emparejan por nombre -- se llaman distinto a
    proposito -- sino por a que pines de que celdas tocan,
  * y las celdas se emparejan por familia: OPAM y OPAM_V2 son las dos el
    amplificador, OPAM_LIN y OPAM_LIN_flat_V2 tambien.

Si los dos grafos no salen iguales, imprime que instancia sobra o falta y
devuelve 1.
"""

from __future__ import annotations

import sys
from collections import defaultdict
from pathlib import Path

#: Cada celda a su familia, para poder comparar el esquematico con el extraido.
FAMILIA = {
    "OPAM": "AMP", "OPAM_V2": "AMP",
    "OPAM_LIN": "AMP", "OPAM_LIN_flat_V2": "AMP",
    "COMP": "COMP", "COMP_V2": "COMP",
    "DECODER": "DEC", "DECODER_V2": "DEC",
}


def puertos(lineas: list[str], base: Path) -> dict[str, list[str]]:
    """Nombre de subcircuito -> lista de puertos, tal y como los declara el netlist.

    Sigue los `.include`, porque los puertos de los bloques extraidos NO estan en
    el netlist de xschem sino en el fichero de magic, y ese orden es justo lo que
    hay que leer y no suponer.
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
    """Lineas de instancia -> (celda, pin -> nodo). Se salta lo que no sea una celda."""
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
    """Cada instancia como (familia, pines ordenados con su nodo canonico).

    Los nodos internos se etiquetan por a que toca cada uno -- el conjunto de
    pares (familia, pin) que lo tocan -- y no por su nombre, que es justo lo que
    difiere entre las dos cadenas.
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

    #  --- la cadena del esquematico: el cuerpo de su .subckt
    try:
        i = next(k for k, ln in enumerate(lineas)
                 if ln.split()[:2] == [".subckt", subckt])
    except StopIteration:
        print(f"  no encuentro .subckt {subckt} en {netlist}", file=sys.stderr)
        return 1
    j = next(k for k in range(i + 1, len(lineas)) if lineas[k].split()[:1] == [".ends"])
    esq = instancias(lineas[i + 1:j], pts)

    #  --- la cadena rehecha: las instancias del primer nivel que cuelgan de VDD<suf>
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
    for etiq, falta in (("solo en el esquematico", [x for x in ga if x not in gb]),
                        ("solo en la rehecha   ", [x for x in gb if x not in ga])):
        for fam, pines in falta:
            print(f"    {etiq}: {fam} " +
                  " ".join(f"{p}={n}" for p, n in pines), file=sys.stderr)
    return 1


if __name__ == "__main__":
    sys.exit(main())
