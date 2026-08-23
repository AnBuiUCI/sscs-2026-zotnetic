#!/bin/bash
# Caracteriza el COMP: continua, alterna y transitorio, esquematico contra layout.
#
#   ./run_comp.sh            # los tres bancos
#   ./run_comp.sh dc         # solo uno
#
# Los tres bancos llevan las dos ramas en paralelo -- x1 es el esquematico
# COMP_sc y Xextrc el layout extraido -- cada una con su propia alimentacion,
# para que el consumo se pueda comparar sin mezclarlos.
#
# Cosas que hay que tener en la cabeza:
#
#   * Las entradas son puertas: el par va/vb no tiene camino de continua a masa
#     por si solo. Sin la fuente de modo comun se lo acaba fijando el gmin de
#     ngspice y salen curvas con picos que no son del circuito.
#
#   * Se eligio Vcm = 2.5 V despues de barrerlo. A diferencia del OPAM, la
#     ganancia del COMP NO depende del modo comun: unos 22000 V/V de 1.5 a
#     3.5 V, porque su etapa de salida esta bien dimensionada y no se sale de
#     saturacion. Es justo lo que le falta al OPAMt.

set -euo pipefail

AQUI="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
QUE=${1:-todo}

banco() {   # banco <sufijo>
    local suf=$1
    local sim="$AQUI/simulation/test_comp_$suf.sch"
    mkdir -p "$sim"
    #  xschem devuelve a veces codigo 10 aunque escriba el netlist perfectamente,
    #  sin decir nada. Con `set -e` eso mataba el script a mitad. Asi que no se
    #  mira su codigo de salida: se comprueba que el fichero esta y es mas nuevo
    #  que el esquematico, que es lo que de verdad importa.
    ( cd "$AQUI" && xschem -n -s -q -o "$sim" "test_comp_$suf.sch" ) || true
    if [ ! -s "$sim/test_comp_$suf.spice" ] || [ "$AQUI/test_comp_$suf.sch" -nt "$sim/test_comp_$suf.spice" ]; then
        echo "  xschem no regenero $sim/test_comp_$suf.spice" >&2
        exit 1
    fi

    #  Guarda de cableado: al mover un bloque en xschem es facil dejarse atras
    #  su simbolo de masa y que el pin salga como #netN. No da error, simula, y
    #  devuelve numeros que no valen nada.
    if ! grep -qE "^x1 VDD \S+ \S+ \S+ GND COMP_sc" "$sim/test_comp_$suf.spice"; then
        echo "  CABLEADO ROTO en test_comp_$suf.sch -- x1 no tiene VDD y GND donde toca" >&2
        grep -E "^x1 " "$sim/test_comp_$suf.spice" | sed 's/^/    /' >&2
        exit 1
    fi

    ( cd "$sim" && ngspice -b "test_comp_$suf.spice" > ngspice.log 2>&1 ) || true
    grep -iE "error|singular|no DC path" "$sim/ngspice.log" | head -3 || true
}

#  Los extraidos de la v2 hay que prepararlos antes: renombrar su subcircuito y
#  normalizar el orden de sus puertos al de la v1. Sin lo segundo, las dos
#  instancias cableadas igual NO son el mismo circuito y no da ningun error.
"$AQUI/preparar_extraidos.sh" COMP > /dev/null || {
    echo "  ERROR: no se pudieron preparar los extraidos de la v2" >&2; exit 1; }

if [ "$QUE" = todo ] || [ "$QUE" = dc ]; then
    echo "==> continua"
    banco dc
    python3 - "$AQUI/simulation/test_comp_dc.sch" <<'PY'
import sys, pathlib
import numpy as np
sim = pathlib.Path(sys.argv[1])
an, fi = np.loadtxt(sim / "ancho.txt"), np.loadtxt(sim / "fino.txt")
print(f"\n  {'rama':14s} {'ganancia':>10s} {'dB':>7s} {'offset':>10s} {'excursion':>15s} {'consumo':>10s}")
for i, nom in enumerate(["esquematico", "layout v1", "layout v2"]):
    #  La ganancia se mide en la ventana fina: la transicion mide 227 uV y la
    #  ancha se la salta entera.
    v, x = fi[:, 2 * i + 1], fi[:, 0]
    g = np.gradient(v, x).max()
    va, xa = an[:, 2 * i + 1], an[:, 0]
    cr = np.where(np.diff(np.sign(v - 2.5)))[0]
    off = x[cr[0]] * 1e3 if len(cr) else float("nan")
    p = abs(an[:, 2 * (i + 3) + 1]).max() * 1e3
    print(f"  {nom:14s} {g:10.0f} {20*np.log10(g):6.1f} {off:+9.3f}mV "
          f"{va.min():6.2f}..{va.max():5.2f} V {p:8.3f} mW")
PY
fi

if [ "$QUE" = todo ] || [ "$QUE" = ac ]; then
    echo
    echo "==> alterna"
    banco ac
    python3 - "$AQUI/simulation/test_comp_ac.sch" <<'PY'
import sys, pathlib
import numpy as np
sim = pathlib.Path(sys.argv[1])
d = np.loadtxt(sim / "ac.txt")
f = d[:, 0]
print(f"\n  {'rama':14s} {'ganancia cc':>12s} {'GBW':>12s} {'margen fase':>12s} {'margen gan':>12s}")
for i, nom in enumerate(["esquematico", "layout v1", "layout v2"]):
    g = d[:, 3 * i + 1] + 1j * d[:, 3 * i + 2]
    mdb = 20 * np.log10(abs(g))
    #  vin ataca a INN, la entrada inversora, asi que la meseta esta en 180 gr.
    fase = np.degrees(np.unwrap(np.angle(g)))
    fase -= round((fase[0] - 180) / 360) * 360
    k0 = np.where(np.diff(np.sign(mdb)))[0]
    kf = np.where(np.diff(np.sign(fase)))[0]
    gbw = f[k0[0]] if len(k0) else float("nan")
    pm = fase[k0[0]] if len(k0) else float("nan")
    #  Margen de ganancia: cuanta ganancia queda cuando la fase llega a 0 gr.
    #  Si es negativo hay realimentacion positiva con ganancia, o sea oscila.
    gm = -mdb[kf[0]] if len(kf) else float("nan")
    print(f"  {nom:14s} {mdb.max():9.1f} dB {gbw:10.3e} Hz {pm:9.1f} gr {gm:9.1f} dB"
          + ("   <<< INESTABLE" if pm < 45 else ""))
PY
fi

if [ "$QUE" = todo ] || [ "$QUE" = tran ]; then
    echo
    echo "==> transitorio de comparador"
    banco tran
    python3 - "$AQUI/simulation/test_comp_tran.sch" <<'PY'
import sys, pathlib
import numpy as np
sim = pathlib.Path(sys.argv[1])
d = np.loadtxt(sim / "tran.txt")
t, vin = d[:, 0], d[:, 1]


def cruce(x, y, nivel):
    """Instante en que y cruza el nivel, interpolando entre muestras."""
    k = np.where(np.diff(np.sign(y - nivel)))[0]
    if not len(k):
        return None
    i = k[0]
    if y[i + 1] == y[i]:
        return x[i]
    return x[i] + (nivel - y[i]) * (x[i + 1] - x[i]) / (y[i + 1] - y[i])


tin = cruce(t, vin, 0.0)          # cuando la entrada cruza el umbral
print(f"\n  {'rama':14s} {'retardo':>11s} {'subida 10-90':>14s} {'excursion':>15s}")
for i, nom in enumerate(["esquematico", "layout v1", "layout v2"]):
    v = d[:, 2 * (i + 1) + 1]
    tout = cruce(t, v, 2.5)
    lo, hi = v.min(), v.max()
    t10, t90 = cruce(t, v, lo + 0.1 * (hi - lo)), cruce(t, v, lo + 0.9 * (hi - lo))
    ret = (tout - tin) * 1e9 if (tout and tin) else float("nan")
    sub = (t90 - t10) * 1e9 if (t10 and t90) else float("nan")
    print(f"  {nom:14s} {ret:9.2f} ns {sub:12.2f} ns {lo:6.2f}..{hi:5.2f} V")
print("\n  retardo = del cruce de la entrada por el umbral al cruce de OUT por medio rail")
PY
fi
