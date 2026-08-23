#!/bin/bash
# Corre el testbench del WEIGHT y compara esquematico contra layout extraido.
#
#   ./run_weight.sh
#
# Lo interesante de este banco son las CORRIENTES DE RAMA. En el esquematico se
# miden con las cuatro fuentes de 0 V Vmeas..Vmeas3 que hay dentro de WEIGHT, en
# serie con la cola de cada rama. El netlist extraido no tiene esas fuentes,
# pero ngspice sabe dar la corriente de drenador de un transistor si se le pide
# con `.save @m.<ruta>.m0[id]` ANTES de correr -- las variables internas de
# dispositivo no se pueden pedir despues, y el `.m0` hace falta porque el modelo
# del PDK es un subcircuito.
#
# Que transistor del extraido es cada rama se traza por los nodos: las cuatro
# colas son las de w=1.24u y cada una cuelga del nodo intermedio al que llegan
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
#  xschem devuelve a veces codigo 10 aunque escriba el netlist bien, y con
#  `set -e` eso mata el script. Se comprueba el fichero, no su codigo.
( cd "$AQUI" && xschem -n -s -q -o "$SIM" test_weight.sch ) || true
[ -s "$SIM/test_weight.spice" ] || { echo "xschem no regenero el netlist" >&2; exit 1; }

echo "==> simulando"
( cd "$SIM" && rm -f ./*.txt && ngspice -b test_weight.spice > ngspice.log 2>&1 ) || true
grep -iE "error|singular|not available|no such vector" "$SIM/ngspice.log" | head -5 || true

#  El fallo tipico de este banco no es un error, es el silencio: si un vector de
#  wrdata no existe, ngspice aborta la orden y no escribe NADA, sin avisar.
for f in input.txt middle.txt out.txt power.txt current.txt; do
    [ -s "$SIM/$f" ] || { echo "  falta $SIM/$f -- algun vector de wrdata no existe" >&2; exit 1; }
done

python3 - "$SIM" <<'PY'
import sys, pathlib
import numpy as np

sim = pathlib.Path(sys.argv[1])


def leer(nombre, cols):
    """wrdata escribe un par (x, y) por vector: 2 columnas cada uno."""
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

#  Correlacion cruzada de las cuatro ramas. Si la diagonal no sale a 1 es que
#  las ramas del esquematico y las del layout no se corresponden una a una.
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
    print(f"\n  OJO: las ramas no se corresponden una a una -> {emparejado}")
    print("  Es el orden de pines de WEIGHT.sym: declara VA, VC, VB, VD mientras que")
    print("  WEIGHT.sch los tiene VA, VB, VC, VD, asi que el cable VB cae en el pin VC.")
    print("  Electricamente da igual -- las cuatro patas son identicas -- pero las")
    print("  etiquetas mienten y las corrientes salen cruzadas al compararlas.")
else:
    print("\n  las cuatro ramas se corresponden una a una")


#  Energia por transicion. El consumo de pico dice poco; lo que se suma para
#  estimar el consumo del chip es la energia, que sale de integrar la potencia
#  en el tiempo y repartirla entre las conmutaciones que ha habido.
estados = np.column_stack([ent[n] for n in ("VA", "VB", "VC", "VD")])
cambios = int(np.sum(np.any(np.diff(estados > 2.5, axis=0), axis=1)))
for nom, p in (("esquematico", pot["p_esq"]), ("layout v1", pot["p_v1"]),
               ("layout v2", pot["p_v2"])):
    e = np.trapezoid(abs(p), t) if hasattr(np, "trapezoid") else np.trapz(abs(p), t)
    print(f"  energia {nom:12s} {e*1e9:8.2f} nJ en {t[-1]:.2f} s"
          f"   ->  {e/max(cambios,1)*1e9:7.2f} nJ por transicion  ({cambios} transiciones)")
print("  OJO: los flancos de entrada de este banco duran 1 ms, seis ordenes de")
print("  magnitud mas lentos que la realidad, asi que esta energia esta dominada por")
print("  la corriente de cruce durante el flanco y NO representa el coste de conmutar.")
print("  Para una cifra util haria falta rehacer el estimulo con flancos de ns.")

print(f"\n  salida     esquematico {sal['OUT'].min():.2f}..{sal['OUT'].max():.2f} V"
      f"   layout {sal['OUT1'].min():.2f}..{sal['OUT1'].max():.2f} V")
print(f"  consumo    esquematico {abs(pot['p_esq']).max()*1e3:.3f} mW"
      f"   layout {abs(pot['p_v1']).max()*1e3:.3f} mW")
PY
