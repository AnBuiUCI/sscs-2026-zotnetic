#!/bin/bash
# Corre el testbench del DECODER de punta a punta y comprueba el resultado.
#
#   ./run_decoder.sh
#
# Tres pasos, en este orden:
#
#   1. Renombra el subckt del layout extraido a DECODER_LAY.
#
#      Esto no es cosmetico. El layout y el esquematico llaman DECODER a la misma
#      celda, y ngspice se queda con la PRIMERA definicion que lee y descarta la
#      segunda con un aviso facil de pasar por alto:
#
#          Warning: redefinition of .subckt decoder, ignored
#
#      Como el .include del pex va antes que el netlist de xschem, ganaba el
#      layout y la instancia x1 -- que deberia ser el esquematico -- acababa atada
#      al subckt extraido. Los ordenes de pines no tienen nada que ver entre si
#      (esquematico VDD XY XZ X Y YZ Z VSS contra layout VSS VDD YZ Z XY XZ Y X),
#      asi que su VSS caia en VDD y su VDD en la senal VXY. De ahi salia el v(X)
#      absurdo que no se parecia a v(test).
#
#      El renombrado se rehace en cada corrida a partir del pex de verdad, para
#      que la copia no se quede vieja cuando se reextraiga el layout.
#
#   2. Regenera el netlist desde el .sch. Nunca se edita el .spice a mano: xschem
#      lo reescribe entero y se perderia. El -o es imprescindible, porque el
#      netlist_dir del xschemrc global apunta a otro sitio.
#
#   3. Simula y comprueba.
#
# El test_weight.sch no sufre este problema porque alli el esquematico se llama
# WEIGHT / COMP_OUT y el layout WEIGHT_COMP: no hay choque de nombres.

set -euo pipefail

AQUI="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MAG="$AQUI/../../Layouts/DECODER/mag"
SIM="$AQUI/simulation/test_decoder.sch"

"$AQUI/preparar_extraidos.sh" DECODER > /dev/null || {
    echo "  ERROR: no se pudieron preparar los extraidos de la v2" >&2; exit 1; }

echo "==> 1/3  renombrando el subckt del layout a DECODER_LAY"
test -f "$MAG/DECODER_pex_rc.spice" || {
    echo "no esta $MAG/DECODER_pex_rc.spice -- reextrae el DECODER con magic" >&2
    exit 1
}
sed 's/^\.subckt DECODER /.subckt DECODER_LAY /' \
    "$MAG/DECODER_pex_rc.spice" > "$MAG/DECODER_pex_rc_LAY.spice"
grep -q "^\.subckt DECODER_LAY " "$MAG/DECODER_pex_rc_LAY.spice" || {
    echo "el renombrado no pego -- mira como se llama el .subckt del pex" >&2
    exit 1
}

echo "==> 2/3  regenerando el netlist desde test_decoder.sch"
mkdir -p "$SIM"
#  xschem devuelve a veces codigo 10 aunque escriba el netlist bien, y con
#  `set -e` eso mata el script. Se comprueba el fichero, no su codigo.
( cd "$AQUI" && xschem -n -s -q -o "$SIM" test_decoder.sch ) || true
[ -s "$SIM/test_decoder.spice" ] || { echo "xschem no regenero el netlist" >&2; exit 1; }

echo "==> 3/3  simulando"
#  ngspice -b vuelca el punto de operacion entero al terminal y ahoga cualquier
#  aviso util, asi que va todo al log y aqui solo se saca lo que importa. El
#  'plot' no funciona sin ventana: los avisos son inofensivos y se filtran.
( cd "$SIM" && ngspice -b test_decoder.spice > ngspice.log 2>&1 ) || true
grep -iE "error|singular|no DC path|redefinition" "$SIM/ngspice.log" || true
grep -q "^No. of Data Rows" "$SIM/ngspice.log" || {
    echo "la .tran no llego a terminar -- mira $SIM/ngspice.log" >&2
    exit 1
}

python3 - "$SIM" <<'PY'
import sys, pathlib
import numpy as np

sim = pathlib.Path(sys.argv[1])

def leer(nombre, cols):
    """wrdata escribe un par (tiempo, valor) por vector."""
    d = np.loadtxt(sim / nombre)
    return d[:, 0], {c: d[:, 2 * i + 1] for i, c in enumerate(cols)}

t, ent = leer("in.txt", ["VXY", "VXZ", "VYZ"])
_, sx = leer("outX.txt", ["X", "X1", "X2"])
_, sy = leer("outY.txt", ["Y", "Y1", "Y2"])
_, sz = leer("outZ.txt", ["Z", "Z1", "Z2"])
_, pw = leer("power.txt", ["p_esq", "p_v1", "p_v2"])

fallos = []

#  Ya no hay compuerta de referencia en el banco: lo que se compara es el
#  esquematico contra el layout extraido, salida por salida.

#  2. Logica esperada del decodificado winner-take-all de tres comparadores
#     por pares.  Se muestrea en el centro de cada meseta de 125 ms, lejos de
#     los flancos, porque el extraido llega con retardo RC.
print(f"\n  {'t':>7} {'XY XZ YZ':>9}   {'X  X1':>7} {'Y  Y1':>7} {'Z  Z1':>7}   esperado")
for centro in np.arange(0.0625, 1.0, 0.125):
    k = int(np.argmin(abs(t - centro)))
    xy, xz, yz = (ent[n][k] > 2.5 for n in ("VXY", "VXZ", "VYZ"))
    esp = {"X": xy and xz, "Y": yz and not xy, "Z": not (xz or yz)}
    got = {"X": (sx["X"][k] > 2.5, sx["X1"][k] > 2.5),
           "Y": (sy["Y"][k] > 2.5, sy["Y1"][k] > 2.5),
           "Z": (sz["Z"][k] > 2.5, sz["Z1"][k] > 2.5)}
    marca = ""
    for n in "XYZ":
        for etiqueta, val in zip((n, n + "1"), got[n]):
            if val != esp[n]:
                fallos.append(f"t={t[k]:.4f}: {etiqueta}={int(val)}, esperado {int(esp[n])}")
                marca = "  <<<"
    print(f"  {t[k]:7.4f} {int(xy):3d}{int(xz):3d}{int(yz):3d}   "
          + " ".join(f"{int(a):2d}{int(b):3d}" for a, b in
                     (got['X'], got['Y'], got['Z']))
          + f"   X={int(esp['X'])} Y={int(esp['Y'])} Z={int(esp['Z'])}{marca}")

#  3. Si VDD1 no alimentase el bloque extraido, i(v2) seria exactamente cero.
pico = abs(pw["p_v1"]).max()
print(f"\n  consumo pico   esquematico {abs(pw['p_esq']).max()*1e3:.3f} mW"
      f"   layout {pico*1e3:.3f} mW")
if pico == 0:
    fallos.append("el consumo del layout es cero: VDD1 no esta alimentando el bloque")


#  Energia por transicion. El consumo de pico dice poco; lo que se suma para
#  estimar el consumo del chip es la energia, que sale de integrar la potencia
#  en el tiempo y repartirla entre las conmutaciones que ha habido.
ent = np.column_stack([ent[n] for n in ("VXY", "VXZ", "VYZ")])
cambios = int(np.sum(np.any(np.diff(ent > 2.5, axis=0), axis=1)))
for nom, p in (("esquematico", pw["p_esq"]), ("layout v1", pw["p_v1"]),
               ("layout v2", pw["p_v2"])):
    e = np.trapezoid(abs(p), t) if hasattr(np, "trapezoid") else np.trapz(abs(p), t)
    print(f"  energia {nom:12s} {e*1e9:8.2f} nJ en {t[-1]:.2f} s"
          f"   ->  {e/max(cambios,1)*1e9:7.2f} nJ por transicion  ({cambios} transiciones)")
print("  OJO: los flancos de entrada de este banco duran 1 ms, seis ordenes de")
print("  magnitud mas lentos que la realidad, asi que esta energia esta dominada por")
print("  la corriente de cruce durante el flanco y NO representa el coste de conmutar.")
print("  Para una cifra util haria falta rehacer el estimulo con flancos de ns.")

if fallos:
    print(f"\n  FALLA ({len(fallos)}):")
    for f in fallos[:20]:
        print(f"    {f}")
    sys.exit(1)
print("\n  todo cuadra: esquematico y layout dan la misma logica")
PY
