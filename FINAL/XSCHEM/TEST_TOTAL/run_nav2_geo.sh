#!/bin/bash
# How the navigator behaves depending on the BOX the sensors sit in.
#
#   ./run_nav2_geo.sh [paso_en_grados]      (por defecto 2)
#
# The box is (Lxy x Lxy x Lz) and the four sensors sit at the vertices of the
# inscribed tetrahedron. The six combinations under study are:
# Lxy de 1000, 2000 y 3000 um, y Lz de 500 y 1000.
#
# WHAT IS MEASURED, AND WHAT EACH THING MEANS:
#
#   1. RESOLUTION. For each box and each gradient level the direction is swept
#      360 degrees and we count on what fraction of directions the navigator
#      gets the right axis. From that curve comes one number: the smallest
#      gradient at which accuracy reaches 95 %. It captures both limits at
#      once -- from below the comparator offset, from above the saturation of
#      amplificador -- sin depender de ninguna definicion prestada.
#   2. The same in the X-Y plane, where Lz plays no part: it separates x-y
#      de la de z.
#   3. BACKGROUND. Earth's field is COMMON to all four sensors, so it cancels
#      in the comparison but NOT in the amplifier, which sees all of it.
#      It is swept to see at what level the measurement is lost.
#
# El gradiente va en dR/R POR MILIMETRO. Convertirlo a campo pide la sensibilidad
# of the AMR, which is not fixed; the conversion is explained in the document.
#
# It all fits in ONE ngspice invocation, with `alter` between sweeps: the
# netlist is 31 RC-extracted blocks and the cost is building it, not sweeping it.

set -euo pipefail
AQUI="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SIM="$AQUI/simulation/test_NAV2_geo.sch"
DAT="$AQUI/datos_geo"
#  Angular sweep step. 2 degrees is the compromise: it is 84 sweeps and what
#  matters is total time, but it still resolves the boundaries comfortably.
PASO=${1:-2}
MODO=${2:-completo}
export MODO
mkdir -p "$SIM" "$DAT"

echo "==> preparando los extraidos de la v2"
/foss/designs/a_zonetic2026/XSCHEM/TEST/preparar_extraidos.sh \
    OPAM_LIN_flat COMP DECODER WEIGHT_COMP | grep pex_rc | sed 's/^/  /'

echo "==> netlist"
rm -f "$SIM/test_NAV2_geo.spice"
( cd "$AQUI" && xschem -n -s -q -o "$SIM" test_NAV2_geo.sch ) || true
if [ ! -s "$SIM/test_NAV2_geo.spice" ] || [ "$AQUI/test_NAV2_geo.sch" -nt "$SIM/test_NAV2_geo.spice" ]; then
    echo "  xschem no regenero $SIM/test_NAV2_geo.spice" >&2; exit 1
fi
for e in "xnav2 VDDV GND XPv Xv XNv YPv Yv YNv ZPv Zv ZNv S2P S2N S4P S4N S3P S3N S1P S1N GRADIENT_NAV2_V2" \
         "xnav3 VDD3 GND XP3 XN3 YP3 YN3 ZP3 ZN3 S2P S2N S4P S4N S3P S3N S1P S1N lxy lz GRADIENT_NAV3"; do
    inst=${e%% *}
    real=$(grep -m1 "^$inst " "$SIM/test_NAV2_geo.spice" || true)
    if [ "$real" != "$e" ]; then
        echo "  CABLEADO ROTO en test_NAV2_geo.sch" >&2
        echo "    esperado: $e" >&2; echo "    netlist : ${real:-<no aparece>}" >&2; exit 1
    fi
done
echo "    the two instances, wired as they should be"

#  The control block is GENERATED here and does not live in the schematic: it is
#  84 sweeps with four parameters each, and writing them by hand in the .sch
#  would be one more place to get it wrong. The manifest says what is in each file.
python3 - "$SIM" "$DAT" "$PASO" "${MODO:-completo}" <<'PY'
import sys
from pathlib import Path
SIM, DAT, PASO, MODO = Path(sys.argv[1]), Path(sys.argv[2]), int(sys.argv[3]), sys.argv[4]
CAJAS = [(1000, 1000), (1000, 500), (2000, 1000), (2000, 500),
         (3000, 1000), (3000, 500)]
#  Doce niveles en escala logaritmica, de 200 ppm/mm a 40 000. El rango se
#  deliberately narrow after the first run: with 20 ppm/mm at the bottom points
#  were spent where nothing happens, and with only eight levels the floor and
#  techo caian en la misma casilla y no se podian separar.
NIVELES = [200e-6 * (200 ** (i / 11)) for i in range(12)]
FONDOS = [0.0, 500e-6, 1e-3, 2e-3, 5e-3, 10e-3]

VEC = " ".join(["v(S1P)", "v(S1N)", "v(S2P)", "v(S2N)",
                "v(S3P)", "v(S3N)", "v(S4P)", "v(S4N)"]
               + [f"v({e}{s}v)" for e in "XYZ" for s in ("P", "", "N")]
               + [f"v(xnav2.{e}{k})" for e in "XYZ" for k in (1, 2, 3, 4)]
               + [f"v({e}{s}3)" for e in "XYZ" for s in ("P", "N")])

filas, ctrl = [], [".control"]
def barrido(lxy, lz, gmm, bg, tilt, tipo, off=0.0):
    i = len(filas) + 1
    filas.append(f"{i},{tipo},{lxy},{lz},{gmm:.6e},{bg:.6e},{tilt},{off:.6e}")
    ctrl.extend([f"alter Vlxy = {lxy}", f"alter Vlz = {lz}",
                 f"alter Vgmm = {gmm:.6e}", f"alter Vbg = {bg:.6e}",
                 f"alter Voff = {off:.6e}", f"alter Vtilt = {tilt}",
                 f"dc Vang 0 360 {PASO}", f"wrdata s{i:03d}.txt {VEC}"])

#  1: no mismatch, only two reference boxes: we already know there is no floor
#  there, and what matters in this family is the saturation ceiling.
def cerrar():
    ctrl.append(".endc")
    (DAT / "manifiesto.csv").write_text(
        "idx,tipo,lxy_um,lz_um,gmm,bg,tilt_deg,off\n" + "\n".join(filas) + "\n")
    src = (SIM / "test_NAV2_geo.spice").read_text().splitlines()
    corte = max(i for i, l in enumerate(src) if l.strip().lower() == ".end")
    (SIM / "corrida.spice").write_text(
        "\n".join(src[:corte] + [".save all"] + ctrl + [".end"]) + "\n")
    print(f"    {len(filas)} barridos de {int(360 / PASO) + 1} puntos")


if MODO == "sentido":
    #  Short run: the six boxes at two gradient levels. Just enough to answer
    #  whether the outputs give the SENSE. The resolution study is already done
    #  with NAV2 and repeating it with NAV3 inside costs three hours.
    for lxy, lz in CAJAS:
        for g in (2223e-6, 9430e-6):
            barrido(lxy, lz, g, 0.0, 0, "sentido", 200e-6)
    cerrar()
    raise SystemExit(0)

for lxy, lz in ((1000, 1000), (3000, 1000)):
    for g in NIVELES:
        barrido(lxy, lz, g, 0.0, 0, "res_xz")
for lxy in (1000, 2000, 3000):              # 2: y en el X-Y, donde Lz no entra
    for g in NIVELES:
        barrido(lxy, 1000, g, 0.0, 90, "res_xy")
for lxy, lz in ((1000, 1000), (3000, 500)):  # 3: el campo de fondo
    for bg in FONDOS:
        barrido(lxy, lz, 2000e-6, bg, 0, "fondo")
#  4: THE REAL RESOLUTION. With sensor mismatch applied, which is what sets the
#  floor: without it, the comparison is exact however small the signal.
OFFSET = 200e-6
for lxy, lz in CAJAS:
    for g in NIVELES:
        barrido(lxy, lz, g, 0.0, 0, "res_off", OFFSET)
#  5: and how that floor moves with the mismatch itself, in two boxes.
for lxy, lz in ((1000, 1000), (3000, 1000)):
    for off in (50e-6, 200e-6):
        for g in NIVELES:
            barrido(lxy, lz, g, 0.0, 0, f"off{int(off * 1e6)}", off)
ctrl.append(".endc")

(DAT / "manifiesto.csv").write_text(
    "idx,tipo,lxy_um,lz_um,gmm,bg,tilt_deg,off\n" + "\n".join(filas) + "\n")
src = (SIM / "test_NAV2_geo.spice").read_text().splitlines()
corte = max(i for i, l in enumerate(src) if l.strip().lower() == ".end")
(SIM / "corrida.spice").write_text(
    "\n".join(src[:corte] + [".save all"] + ctrl + [".end"]) + "\n")
print(f"    {len(filas)} barridos de {int(360 / PASO) + 1} puntos "
      f"-> {SIM / 'corrida.spice'}")
PY

echo "==> simulating  (this is the long one: 84 sweeps over 31 RC blocks)"
( cd "$SIM" && ngspice -b corrida.spice > ngspice.log 2>&1 ) || true
if grep -iqE "error|singular|no DC path" "$SIM/ngspice.log"; then
    echo "  ngspice se ha quejado:" >&2
    grep -iE "error|singular|no DC path" "$SIM/ngspice.log" | head -5 | sed 's/^/    /' >&2
    exit 1
fi
python3 "$AQUI/analizar_geo.py" "$SIM" "$DAT"
