#!/bin/bash
# Caracteriza el OPAM original contra las dos variantes de ganancia 100 V/V.
#
#   ./run_opam_g100.sh             # los tres bancos
#   ./run_opam_g100.sh dc          # solo continua
#   ./run_opam_g100.sh ac          # solo alterna
#   ./run_opam_g100.sh tran        # solo transitorio
#   ./run_opam_g100.sh dc --esquinas
#
# All three benches carry the three cells in parallel, each with its own supply,
# so that current draw is compared without bias.
#
# Things to keep in mind when reading the numbers:
#
#   * The inputs are gates: the va/vb pair has no DC path to ground on its own.
#     Without the common-mode source, ngspice's gmin ends up setting it and the
#     transfer comes out with spikes and collapses to 0 V.
#
#   * Gain is measured as the MAX of the slope, not as -MIN, and the
#     la transicion va como 5V/ganancia: 85 uV en el original de 95 dB y 50 mV
#     in the variants. That is why the DC bench does two sweeps.
#
#   * La ganancia de estas celdas depende mucho de donde quede OUT en reposo:
#     ~99 V/V with OUT at 2.5 V but ~39 V/V with OUT at 3.0 V. The window where
#     aguanta dentro del +-10% va de OUT 1.8 a 2.6 V.
#
#     That is why the benches bias the common mode at 2.0 V and not half rail.
#     Vcm a 2.5 el offset del diodo dejaba OUT reposando en 2.73 V, o sea FUERA
#     de esa ventana, y el banco de alterna leia 61 V/V. Con Vcm a 2.0 el reposo
#     cae en 2.18 V, en el centro, y la ganancia en uso sube a unos 107 V/V.
#     It is not a measurement trick: it is where this cell must be biased.

set -euo pipefail

AQUI="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WHAT=${1:-all}
[ "$WHAT" = "--esquinas" ] && WHAT=all
ESQUINAS=""
for a in "$@"; do [ "$a" = "--esquinas" ] && ESQUINAS=si; done

banco() {   # banco <sufijo> [esquina] [temperatura]
    local suf=$1 esq=${2:-typical} tmp=${3:-27}
    local sim="$AQUI/simulation/test_opam_g100_$suf.sch"
    mkdir -p "$sim"
    #  xschem devuelve a veces codigo 10 aunque escriba el netlist perfectamente,
    #  without a word. With `set -e` that killed the script halfway. So its
    #  exit code is not checked: instead we check the file is there and newer
    #  than the schematic, which is what actually matters.
    ( cd "$AQUI" && xschem -n -s -q -o "$sim" "test_opam_g100_$suf.sch" ) || true
    if [ ! -s "$sim/test_opam_g100_$suf.spice" ] || [ "$AQUI/test_opam_g100_$suf.sch" -nt "$sim/test_opam_g100_$suf.spice" ]; then
        echo "  xschem no regenero $sim/test_opam_g100_$suf.spice" >&2
        exit 1
    fi
    sed -e "s|sm141064.ngspice typical|sm141064.ngspice $esq|" \
        -e "s|^\.save all|.temp $tmp\n.save all|" \
        "$sim/test_opam_g100_$suf.spice" > "$sim/corrida.spice"
    #  Guarda de cableado. Estos .sch se editan a mano en xschem y al mover un
    #  block it is easy to leave its ground symbol behind: the pin dangles and
    #  comes out as #netN instead of GND. That raises no error -- the simulation
    #  runs and returns numbers -- but they are rubbish. It happened once with xB,
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
#  The v2 extractions must be prepared before simulating: rename their
#  subcircuit and NORMALISE THEIR PORT ORDER to v1. magic emits them in the
#  order it finds them in the layout, and that order changes with the layout:
#  without normalising it, the two instances wired the same are not the
#  mismo circuito y no salta ningun error.
"$AQUI/preparar_extraidos.sh" OPAM_LIN_flat > /dev/null || {
    echo "  ERROR: no se pudieron preparar los extraidos de la v2" >&2; exit 1; }

if [ "$WHAT" = all ] || [ "$WHAT" = dc ]; then
    echo "==> continua"
    banco dc
    python3 - "$AQUI/simulation/test_opam_g100_dc.sch" <<'PY'
import sys, pathlib
import numpy as np
sim = pathlib.Path(sys.argv[1])
an = np.loadtxt(sim / "ancho.txt")
fi = np.loadtxt(sim / "fino.txt")
x, xf = an[:, 0], fi[:, 0]

#: Output range over which linearity is required, agreed with the design.
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

    #  Linearity error: a straight line is fitted to the useful range by least
    #  squares and the maximum deviation is measured, in % of span. It is the
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
        fallos.append(f"{nom}: draws {p:.3f} mW, more than the original ({filas[0][3]:.3f})")
#  The linear cell is additionally held to what it was designed for
nom, pico, inl, p, baja, off = filas[3]
if not (inl < 1.0):
    fallos.append(f"{nom}: INL {inl:.2f}%, above the required 1%")
if not (off > 0):
    fallos.append(f"{nom}: offset {off*1e3:+.1f} mV, must be positive")
if fallos:
    print("\n  FALLA:")
    for f in fallos:
        print(f"    {f}")
    sys.exit(1)
print("\n  OPAM_LIN: INL below 1% between 1 and 4 V, positive offset, within the power budget")
PY
fi

# --------------------------------------------------------------------- ac
if [ "$WHAT" = all ] || [ "$WHAT" = ac ]; then
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
    #  vin drives INN, the inverting input, so the plateau sits at
    #  180 degrees. Phase margin is the phase left at the 0 dB crossing.
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
print("  linear, because the common mode is at 2.0 V. With Vcm at 2.5 it rested at 2.73 V,")
print("  outside it, and this same measurement gave 61 V/V instead of the ~107 now.")
PY
fi

# ------------------------------------------------------------------- tran
if [ "$WHAT" = all ] || [ "$WHAT" = tran ]; then
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
    echo "  The OPAMt column is only valid at typical/27: its transition is 85 uV and the offset"
    echo "  moves with the corner, so the fine +-1 mV window misses it."

    #  Each corner overwrites ancho.txt and fino.txt, so when the sweep ends
    #  que queda en disco es la ULTIMA esquina, no la nominal. Se rehace tipico
    #  at 27 degrees so that whoever reads those files later -- for instance
    #  doc/graficas.py -- no dibuje sin saberlo la esquina ss a 125 grados.
    banco dc typical 27 >/dev/null
    echo "  (datos de tipico/27 restaurados en simulation/)"
fi
