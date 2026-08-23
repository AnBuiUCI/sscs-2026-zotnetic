#!/bin/bash
# Caracteriza el OPAM original contra las dos variantes de ganancia 100 V/V.
#
#   ./run_opam_g100.sh             # los tres bancos
#   ./run_opam_g100.sh dc          # solo continua
#   ./run_opam_g100.sh ac          # solo alterna
#   ./run_opam_g100.sh tran        # solo transitorio
#   ./run_opam_g100.sh dc --esquinas
#
# Los tres bancos llevan las tres celdas en paralelo, cada una con su propia
# fuente, para que el consumo se compare sin sesgo.
#
# Cosas que hay que tener en la cabeza al leer los numeros:
#
#   * Las entradas son puertas: el par va/vb no tiene camino de continua a masa
#     por si solo. Sin la fuente de modo comun el modo comun se lo acaba fijando
#     el gmin de ngspice y la transferencia sale con picos y desplomes a 0 V.
#
#   * La ganancia se mide como MAX de la pendiente, no como -MIN, y el ancho de
#     la transicion va como 5V/ganancia: 85 uV en el original de 95 dB y 50 mV
#     en las variantes. Por eso el banco de continua hace dos barridos.
#
#   * La ganancia de estas celdas depende mucho de donde quede OUT en reposo:
#     ~99 V/V con OUT a 2.5 V pero ~39 V/V con OUT a 3.0 V. La ventana donde
#     aguanta dentro del +-10% va de OUT 1.8 a 2.6 V.
#
#     Por eso los bancos polarizan el modo comun a 2.0 V y no a medio rail. Con
#     Vcm a 2.5 el offset del diodo dejaba OUT reposando en 2.73 V, o sea FUERA
#     de esa ventana, y el banco de alterna leia 61 V/V. Con Vcm a 2.0 el reposo
#     cae en 2.18 V, en el centro, y la ganancia en uso sube a unos 107 V/V.
#     No es un truco de medida: es donde hay que polarizar esta celda.

set -euo pipefail

AQUI="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
QUE=${1:-todo}
[ "$QUE" = "--esquinas" ] && QUE=todo
ESQUINAS=""
for a in "$@"; do [ "$a" = "--esquinas" ] && ESQUINAS=si; done

banco() {   # banco <sufijo> [esquina] [temperatura]
    local suf=$1 esq=${2:-typical} tmp=${3:-27}
    local sim="$AQUI/simulation/test_opam_g100_$suf.sch"
    mkdir -p "$sim"
    #  xschem devuelve a veces codigo 10 aunque escriba el netlist perfectamente,
    #  sin decir nada. Con `set -e` eso mataba el script a mitad. Asi que no se
    #  mira su codigo de salida: se comprueba que el fichero esta y es mas nuevo
    #  que el esquematico, que es lo que de verdad importa.
    ( cd "$AQUI" && xschem -n -s -q -o "$sim" "test_opam_g100_$suf.sch" ) || true
    if [ ! -s "$sim/test_opam_g100_$suf.spice" ] || [ "$AQUI/test_opam_g100_$suf.sch" -nt "$sim/test_opam_g100_$suf.spice" ]; then
        echo "  xschem no regenero $sim/test_opam_g100_$suf.spice" >&2
        exit 1
    fi
    sed -e "s|sm141064.ngspice typical|sm141064.ngspice $esq|" \
        -e "s|^\.save all|.temp $tmp\n.save all|" \
        "$sim/test_opam_g100_$suf.spice" > "$sim/corrida.spice"
    #  Guarda de cableado. Estos .sch se editan a mano en xschem y al mover un
    #  bloque es facil dejarse atras su simbolo de masa: el pin se queda colgando
    #  y sale como #netN en vez de GND. Eso no da ningun error -- la simulacion
    #  corre y devuelve numeros -- pero son basura. Paso una vez con xB, que dio
    #  0.000 mW y OUT clavado en 5 V.
    local malas
    malas=$(grep -E "^x[RABL] " "$sim/test_opam_g100_$suf.spice" | grep -vE " GND OPAM") || true
    if [ -n "$malas" ]; then
        echo "  CABLEADO ROTO en test_opam_g100_$suf.sch -- algun VSS no llega a GND:" >&2
        echo "$malas" | sed 's/^/    /' >&2
        exit 1
    fi

    ( cd "$sim" && ngspice -b corrida.spice > "ngspice.log" 2>&1 ) || true
    grep -iE "error|singular|no DC path" "$sim/ngspice.log" | head -3 || true
}

# --------------------------------------------------------------------- dc
#  Los extraidos de la v2 hay que prepararlos antes de simular: renombrar su
#  subcircuito y NORMALIZAR EL ORDEN DE SUS PUERTOS al de la v1. magic los
#  emite en el orden en que los encuentra en el layout, y ese orden cambia con
#  el layout: sin normalizarlo, las dos instancias cableadas igual no son el
#  mismo circuito y no salta ningun error.
"$AQUI/preparar_extraidos.sh" OPAM_LIN_flat > /dev/null || {
    echo "  ERROR: no se pudieron preparar los extraidos de la v2" >&2; exit 1; }

if [ "$QUE" = todo ] || [ "$QUE" = dc ]; then
    echo "==> continua"
    banco dc
    python3 - "$AQUI/simulation/test_opam_g100_dc.sch" <<'PY'
import sys, pathlib
import numpy as np
sim = pathlib.Path(sys.argv[1])
an = np.loadtxt(sim / "ancho.txt")
fi = np.loadtxt(sim / "fino.txt")
x, xf = an[:, 0], fi[:, 0]

#: Tramo de salida sobre el que se exige linealidad, acordado con el diseno.
BAJO, ALTO = 1.0, 4.0

CELDAS = [("OPAMt (original)", 0), ("OPAM_G100A", 1), ("OPAM_G100B", 2),
          ("OPAM_LIN", 3), ("OPAM_LIN lay v1", 4), ("OPAM_LIN lay v2", 5)]

print(f"\n  {'celda':16s} {'pico':>9s} {'gan 1-4V':>9s} {'INL':>7s} {'consumo':>9s}"
      f" {'excursion':>14s} {'offset':>9s} {'mono':>6s}")
filas = []
for i, (nom, col) in enumerate(CELDAS):
    #  La referencia se mide en el barrido fino: su transicion mide 85 uV y el
    #  barrido ancho se la salta entera.
    d, xx = (fi, xf) if i == 0 else (an, x)
    v = d[:, 2 * col + 1]
    s = np.gradient(v, xx)
    cruce = np.where(np.diff(np.sign(v - 2.5)))[0]
    off = xx[cruce[0]] if len(cruce) else float("nan")
    p = abs(an[:, 2 * (col + 6) + 1]).max() * 1e3
    baja = int(np.sum(np.diff(v) < -1e-3))

    #  Error de linealidad: se ajusta una recta al tramo util por minimos
    #  cuadrados y se mide la maxima desviacion, en % del span. Es la cifra que
    #  distingue un amplificador de un comparador.
    util = (v >= BAJO) & (v <= ALTO)
    if util.sum() >= 20:
        m, b = np.polyfit(xx[util], v[util], 1)
        inl = abs(v[util] - (m * xx[util] + b)).max() / (ALTO - BAJO) * 100
        gan14, sinl = f"{m:9.1f}", f"{inl:6.2f}%"
    else:
        inl, gan14, sinl = float("nan"), "        -", "      -"
    filas.append((nom, s.max(), inl, p, baja, off))
    print(f"  {nom:16s} {s.max():9.1f} {gan14} {sinl} {p:7.3f} mW "
          f"{v.min():6.2f}..{v.max():5.2f} V {off*1e3:+7.1f}mV "
          f"{'si' if baja == 0 else 'NO':>6s}")

print("\n  pico   = maxima pendiente de la transferencia")
print("  gan 1-4V = pendiente de la recta ajustada al tramo OUT 1..4 V")
print("  INL    = maxima desviacion respecto a esa recta, en % de los 3 V")

fallos = []
for nom, pico, inl, p, baja, off in filas[1:]:
    if baja:
        fallos.append(f"{nom}: la transferencia baja en {baja} puntos")
    if p > filas[0][3]:
        fallos.append(f"{nom}: consume {p:.3f} mW, mas que el original ({filas[0][3]:.3f})")
#  A la celda lineal se le exige ademas lo que se diseno para ella
nom, pico, inl, p, baja, off = filas[3]
if not (inl < 1.0):
    fallos.append(f"{nom}: INL {inl:.2f}%, por encima del 1% exigido")
if not (off > 0):
    fallos.append(f"{nom}: offset {off*1e3:+.1f} mV, tiene que ser positivo")
if fallos:
    print("\n  FALLA:")
    for f in fallos:
        print(f"    {f}")
    sys.exit(1)
print("\n  OPAM_LIN: INL por debajo del 1% entre 1 y 4 V, offset positivo, sin pasarse de consumo")
PY
fi

# --------------------------------------------------------------------- ac
if [ "$QUE" = todo ] || [ "$QUE" = ac ]; then
    echo
    echo "==> alterna"
    banco ac
    python3 - "$AQUI/simulation/test_opam_g100_ac.sch" <<'PY'
import sys, pathlib
import numpy as np
sim = pathlib.Path(sys.argv[1])
d = np.loadtxt(sim / "ac.txt")
f = d[:, 0]
print(f"\n  {'celda':16s} {'ganancia cc':>12s} {'GBW':>12s} {'margen fase':>12s}")
for i, nom in enumerate(["OPAMt (original)", "OPAM_G100A", "OPAM_G100B",
                         "OPAM_LIN", "OPAM_LIN lay v1", "OPAM_LIN lay v2"]):
    g = d[:, 3 * i + 1] + 1j * d[:, 3 * i + 2]
    mdb = 20 * np.log10(abs(g))
    #  vin ataca a INN, que es la entrada inversora, asi que la meseta esta en
    #  180 grados. El margen de fase es la fase que queda al cruzar 0 dB.
    fase = np.degrees(np.unwrap(np.angle(g)))
    fase -= round((fase[0] - 180) / 360) * 360
    cero = np.where(np.diff(np.sign(mdb)))[0]
    if len(cero):
        k = cero[0]
        gbw, pm = f[k], fase[k]
    else:
        gbw, pm = float("nan"), float("nan")
    print(f"  {nom:16s} {mdb.max():9.1f} dB {gbw:10.3e} Hz {pm:9.1f} gr"
          f"{'   <<< INESTABLE' if pm < 45 else ''}")
print("\n  El lazo unitario deja OUT reposando cerca de 2.2 V, dentro de la ventana")
print("  lineal, porque el modo comun esta en 2.0 V. Con Vcm a 2.5 reposaba en 2.73 V,")
print("  fuera de ella, y esta misma medida daba 61 V/V en vez de los ~107 de ahora.")
PY
fi

# ------------------------------------------------------------------- tran
if [ "$QUE" = todo ] || [ "$QUE" = tran ]; then
    echo
    echo "==> transitorio (los cuatro en seguidor)"
    banco tran
    python3 - "$AQUI/simulation/test_opam_g100_tran.sch" <<'PY'
import sys, pathlib
import numpy as np
sim = pathlib.Path(sys.argv[1])
d = np.loadtxt(sim / "tran.txt")
t = d[:, 0]
print(f"\n  {'celda':16s} {'slew subida':>12s} {'slew bajada':>12s} {'rizado en reposo':>18s}")
for i, nom in enumerate(["OPAMt (original)", "OPAM_G100A", "OPAM_G100B",
                         "OPAM_LIN", "OPAM_LIN lay v1", "OPAM_LIN lay v2"]):
    v = d[:, 2 * (i + 1) + 1]
    dv = np.gradient(v, t)
    #  Rizado con la entrada quieta: si no es cero, el seguidor oscila.
    quieto = v[(t >= 18e-6) & (t <= 20e-6)]
    riz = quieto.max() - quieto.min()
    print(f"  {nom:16s} {dv.max()/1e6:9.1f} V/us {dv.min()/1e6:9.1f} V/us "
          f"{riz:14.3f} V{'   <<< OSCILA' if riz > 0.05 else ''}")
PY
fi

# --------------------------------------------------------------- esquinas
if [ -n "$ESQUINAS" ]; then
    echo
    echo "==> esquinas de proceso y temperatura (pico de ganancia, banco de continua)"
    printf "  %-8s %6s %12s %12s %12s\n" esquina T OPAMt G100A G100B
    for esq in typical ff ss; do
        for tmp in -40 27 125; do
            banco dc "$esq" "$tmp" >/dev/null
            python3 - "$AQUI/simulation/test_opam_g100_dc.sch" "$esq" "$tmp" <<'PY'
import sys, pathlib
import numpy as np
sim = pathlib.Path(sys.argv[1])
an, fi = np.loadtxt(sim / "ancho.txt"), np.loadtxt(sim / "fino.txt")
g = lambda d, c: np.gradient(d[:, 2 * c + 1], d[:, 0]).max()
print(f"  {sys.argv[2]:<8s} {sys.argv[3]:>6s} {g(fi,0):12.1f} {g(an,1):12.1f} {g(an,2):12.1f}")
PY
        done
    done
    echo
    echo "  La columna OPAMt solo vale en tipico/27: su transicion mide 85 uV y el offset"
    echo "  se mueve con la esquina, asi que la ventana fina de +-1 mV se la salta."

    #  Cada esquina pisa ancho.txt y fino.txt, asi que al acabar el barrido lo
    #  que queda en disco es la ULTIMA esquina, no la nominal. Se rehace tipico
    #  a 27 grados para que quien lea esos ficheros despues -- por ejemplo
    #  doc/graficas.py -- no dibuje sin saberlo la esquina ss a 125 grados.
    banco dc typical 27 >/dev/null
    echo "  (datos de tipico/27 restaurados en simulation/)"
fi
