#!/bin/bash
# Runs the WEIGHT testbench and compares schematic against extracted layout.
#
#   ./run_weight.sh
#
# What is interesting in this bench are the BRANCH CURRENTS. In the schematic
# they are measured with the four 0 V sources Vmeas..Vmeas3 inside WEIGHT, in
# series with each branch tail. The extracted netlist has no such sources, but
# ngspice can give a transistor drain current if asked with
# `.save @m.<path>.m0[id]` BEFORE running -- device internal variables cannot be
# asked for afterwards, and the `.m0` is needed because the model
# del PDK es un subcircuito.
#
# Which extracted transistor is which branch is traced through the nodes: the
# four tails are the w=1.24u ones and each hangs off the intermediate node
# los dos transistores de entrada de esa rama.
#
#     rama   esquematico   nodo intermedio   cola en el layout
#     VA     Vmeas         a_5026_1208       X31
#     VB     Vmeas1        a_1038_1208       X16
#     VC     Vmeas2        a_n74_0           X23
#     VD     Vmeas3        a_n74_1208        X24

set -euo pipefail

AQUI="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SIM="$AQUI/simulation/test_weight.sch"

"$AQUI/preparar_extraidos.sh" WEIGHT_COMP > /dev/null || {
    echo "  ERROR: no se pudieron preparar los extraidos de la v2" >&2; exit 1; }

echo "==> regenerando el netlist"
mkdir -p "$SIM"
#  xschem sometimes returns code 10 even though it writes the netlist fine, and
#  with `set -e` that kills the script. The file is checked, not its code.
( cd "$AQUI" && xschem -n -s -q -o "$SIM" test_weight.sch ) || true
[ -s "$SIM/test_weight.spice" ] || { echo "xschem no regenero el netlist" >&2; exit 1; }

echo "==> simulando"
( cd "$SIM" && rm -f ./*.txt && ngspice -b test_weight.spice > ngspice.log 2>&1 ) || true
grep -iE "error|singular|not available|no such vector" "$SIM/ngspice.log" | head -5 || true

#  El fallo tipico de este banco no es un error, es el silencio: si un vector de
#  wrdata does not exist, ngspice aborts the command and writes NOTHING, silently.
for f in input.txt middle.txt out.txt power.txt current.txt; do
    [ -s "$SIM/$f" ] || { echo "  falta $SIM/$f -- algun vector de wrdata no existe" >&2; exit 1; }
done

python3 - "$SIM" <<'PY'
import sys, pathlib
import numpy as np

sim = pathlib.Path(sys.argv[1])


def leer(nombre, cols):
    """wrdata writes an (x, y) pair per vector: 2 columns each."""
    d = np.loadtxt(sim / nombre)
    return d[:, 0], {c: d[:, 2 * i + 1] for i, c in enumerate(cols)}


ramas = ["VA", "VB", "VC", "VD"]
t, cur = leer("current.txt", [f"esq_{r}" for r in ramas] + [f"lay_{r}" for r in ramas])
_, sal = leer("out.txt", ["OUT", "OUT1", "OUT2", "OUT_N", "OUT_N1", "OUT_N2"])
_, pot = leer("power.txt", ["p_esq", "p_v1", "p_v2"])
_, ent = leer("input.txt", ["VA", "VB", "VC", "VD"])

print(f"\n  {'rama':6s} {'pico esquematico':>18s} {'pico layout':>14s} {'diferencia':>12s}")
for r in ramas:
    a, b = abs(cur[f"esq_{r}"]).max(), abs(cur[f"lay_{r}"]).max()
    print(f"  {r:6s} {a*1e6:15.2f} uA {b*1e6:11.2f} uA {abs(a-b)/a*100:10.2f} %")

#  Cross-correlation of the four branches. If the diagonal does not come out at
#  1, the schematic and layout branches do not correspond one to one.
print(f"\n  correlacion esquematico (filas) contra layout (columnas):")
print("        " + "".join(f"{c:>9s}" for c in ramas))
cruce = []
for a in ramas:
    fila = [np.corrcoef(abs(cur[f"esq_{a}"]), abs(cur[f"lay_{b}"]))[0, 1] for b in ramas]
    print(f"  esq {a}" + "".join(f"{v:9.4f}" for v in fila))
    cruce.append(fila)
cruce = np.array(cruce)
emparejado = {ramas[i]: ramas[int(np.argmax(cruce[i]))] for i in range(4)}
malas = {k: v for k, v in emparejado.items() if k != v}
if malas:
    print(f"\n  CAREFUL: the branches do not correspond one to one -> {emparejado}")
    print("  Es el orden de pines de WEIGHT.sym: declara VA, VC, VB, VD mientras que")
    print("  WEIGHT.sch has them VA, VB, VC, VD, so wire VB lands on pin VC.")
    print("  Electrically it makes no difference -- the four legs are identical -- but")
    print("  the labels lie and the currents come out crossed when compared.")
else:
    print("\n  the four branches correspond one to one")


#  Energy per transition. Peak current says little; what adds up when estimating
#  the chip's consumption is energy, which comes from integrating power over
#  time and dividing it among the transitions that occurred.
estados = np.column_stack([ent[n] for n in ("VA", "VB", "VC", "VD")])
cambios = int(np.sum(np.any(np.diff(estados > 2.5, axis=0), axis=1)))
for nom, p in (("esquematico", pot["p_esq"]), ("layout v1", pot["p_v1"]),
               ("layout v2", pot["p_v2"])):
    e = np.trapezoid(abs(p), t) if hasattr(np, "trapezoid") else np.trapz(abs(p), t)
    print(f"  energia {nom:12s} {e*1e9:8.2f} nJ en {t[-1]:.2f} s"
          f"   ->  {e/max(cambios,1)*1e9:7.2f} nJ por transicion  ({cambios} transiciones)")
print("  CAREFUL: the input edges of this bench last 1 ms, six orders of")
print("  magnitude slower than reality, so this energy is dominated by")
print("  la corriente de cruce durante el flanco y NO representa el coste de conmutar.")
print("  For a useful figure the stimulus would need ns edges.")

print(f"\n  salida     esquematico {sal['OUT'].min():.2f}..{sal['OUT'].max():.2f} V"
      f"   layout {sal['OUT1'].min():.2f}..{sal['OUT1'].max():.2f} V")
print(f"  consumo    esquematico {abs(pot['p_esq']).max()*1e3:.3f} mW"
      f"   layout {abs(pot['p_v1']).max()*1e3:.3f} mW")
PY
