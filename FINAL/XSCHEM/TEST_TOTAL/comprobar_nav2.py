#!/usr/bin/env python3
"""Comprueba que el navegador rehecho a mano es el MISMO que el del esquematico.

    python3 comprobar_nav2.py <netlist>

Es la comprobacion central del banco: comparar la salida del esquematico con la
del layout solo significa algo si los dos son el mismo circuito, y hay tres
formas de que no lo sean sin que salte ningun error.

  * **El orden de puertos no coincide.** xschem los emite en el orden de las
    lineas B del simbolo y magic en el orden en que los encuentra en el layout:

        esquematico  .subckt OPAM_LIN          VDD INN OUT INP VSS
        extraido     .subckt OPAM_LIN_flat_V2  VSS VDD INP OUT INN   <- OUT en medio
        extraido     .subckt WEIGHT_COMP_V2    VSS VDD VD WE VA VB OUT OUT_N VC

    Cablear los dos igual significa cosas distintas. La simulacion corre y
    devuelve numeros.

  * **El WEIGHT_COMP cruza dos de sus entradas.** Su propio netlist dice
    `x1 VDD VSS WE VA VB VC VD WEIGHT` contra `.subckt WEIGHT VDD GND OUT VA VC
    VB VD`, o sea que su VB va al pin VC del WEIGHT y su VC al VB. Escribirlo
    'en orden' pesa mal dos cadenas y tampoco da error.

  * **Un nodo mal tecleado.** Un `SY3r` donde iba `SZ3r` no es un error de
    sintaxis: es otro circuito.

Como lo comprueba. Aplana el `.subckt GRADIENT_NAV2` un nivel -- sus cuatro
GRADIENT2 se abren en amplificadores, comparadores y decodificadores, y cada
pareja WEIGHT + COMP_OUT se funde en el bloque que el layout tiene de verdad --
y compara ese grafo contra el de las instancias `_V2` escritas a mano:

  * los nodos EXTERNOS se emparejan por su papel (GND es VSS, VDDR es VDD, Xr es X),
  * los nodos INTERNOS no se emparejan por nombre -- se llaman distinto a
    proposito -- sino por a que pines de que celdas tocan,
  * y las celdas por familia: OPAM_LIN y OPAM_LIN_flat_V2 son las dos el
    amplificador.
"""

from __future__ import annotations

import sys
from collections import defaultdict
from pathlib import Path

#: Cada celda a su familia, para poder comparar el esquematico con el extraido.
FAMILIA = {
    "OPAM_LIN": "AMP", "OPAM_LIN_flat_V2": "AMP",
    "COMP": "COMP", "COMP_V2": "COMP",
    "DECODER": "DEC", "DECODER_V2": "DEC",
    "WEIGHT_COMP_V2": "WC",
}

#: Las dos celdas del esquematico que el layout trae fundidas en una.
FUSION = ("WEIGHT", "COMP_OUT")


def puertos(lineas: list[str], base: Path) -> dict[str, list[str]]:
    """Subcircuito -> lista de puertos, siguiendo los `.include`.

    Los puertos de los bloques extraidos NO estan en el netlist de xschem sino en
    el fichero de magic, y ese orden es justo lo que hay que leer y no suponer.
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
    """El top del esquematico, abierto un nivel y con los WEIGHT+COMP_OUT fundidos.

    Los nodos internos de cada instancia se prefijan con su nombre, que es lo que
    impide que las cuatro copias de GRADIENT2 compartan un nodo que no comparten.
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
        #  Un nivel mas: se abren sus instancias, con los nodos internos
        #  prefijados por el nombre de la instancia padre.
        for _, hcelda, hpines in llamadas(cuerpo(lineas, celda), pts):
            if hcelda not in FAMILIA:
                continue
            hojas.append((hcelda, {p: (pines[n] if n in pines else f"{inst}/{n}")
                                   for p, n in hpines.items()}))

    #  Y la fusion: cada WEIGHT con el COMP_OUT que cuelga de su salida.
    #  `WEIGHT_COMP` alimenta su VB al pin VC del WEIGHT y al reves; aqui se
    #  deshace ese cruce para poder comparar con el bloque del layout.
    for _, w in sueltos[FUSION[0]]:
        pareja = next((c for _, c in sueltos[FUSION[1]] if c["IN"] == w["OUT"]), None)
        if pareja is None:
            sys.exit(f"  hay un {FUSION[0]} sin su {FUSION[1]}: OUT={w['OUT']}")
        hojas.append(("WEIGHT_COMP_V2", {
            "VDD": w["VDD"], "VSS": pareja["VSS"],
            "VA": w["VA"], "VB": w["VC"], "VC": w["VB"], "VD": w["VD"],
            "WE": w["OUT"], "OUT": pareja["OUT"], "OUT_N": pareja["OUT_N"]}))
    return hojas


def grafo(insts, externos: dict[str, str]) -> list:
    """Cada instancia como (familia, pines ordenados con su nodo canonico)."""
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

    #  La rehecha: las instancias de primer nivel, o sea todo lo que esta fuera
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
        print("  no hay ni una instancia rehecha en el primer nivel", file=sys.stderr)
        return 1

    señal = ["S1P", "S1N", "S2P", "S2N", "S3P", "S3N", "S4P", "S4N"]
    salida = ["X", "Y", "Z", "XP", "XN", "YP", "YN", "ZP", "ZN"]
    ext_esq = {n: n for n in señal + salida + ["VDD", "VSS"]}
    ext_rc = {n: n for n in señal}
    ext_rc.update({f"{n}r": n for n in salida})
    ext_rc.update({"VDDR": "VDD", "GND": "VSS"})

    ga, gb = grafo(esq, ext_esq), grafo(rc, ext_rc)
    if ga == gb:
        print(f"    el navegador rehecho es el MISMO circuito que el esquematico"
              f"  ({len(esq)} celdas)")
        return 0

    print("  EL NAVEGADOR REHECHO NO ES GRADIENT_NAV2", file=sys.stderr)
    for etiq, falta in (("solo en el esquematico", [x for x in ga if x not in gb]),
                        ("solo en el rehecho    ", [x for x in gb if x not in ga])):
        for fam, pines in falta:
            print(f"    {etiq}: {fam} " +
                  " ".join(f"{p}={n}" for p, n in pines), file=sys.stderr)
    return 1


if __name__ == "__main__":
    sys.exit(main())
