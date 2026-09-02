#!/bin/bash
# How the navigator behaves depending on the BOX the sensors sit in.
#
#   ./run_nav2_geo.sh [step_in_degrees] [mode]    (default 2, completo)
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
# It all fits in ONE ngspice invocation, with `alter` between sweeps: building
# the netlist costs more than sweeping it. Every block in it is the SCHEMATIC
# one -- see the note further down about why there is no RC here.

set -euo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SIM="$HERE/simulation/test_NAV2_geo.sch"
DAT="$HERE/datos_geo"
#  Angular sweep step. 2 degrees is the compromise: it is 84 sweeps and what
#  matters is total time, but it still resolves the boundaries comfortably.
STEP=${1:-2}
MODE=${2:-completo}
export MODE
mkdir -p "$SIM" "$DAT"

#  NO RC HERE, and it is worth saying why. `test_NAV2_geo.sch` includes no
#  extracted block: every subcircuit in the deck -- OPAM_LIN, COMP, DECODER,
#  WEIGHT, COMP_OUT -- is the SCHEMATIC one. This runner used to call
#  `preparar_extraidos.sh` and the files it left were never included by anybody,
#  which made it look like the layout was being measured when it was not.
#
#  It stays that way ON PURPOSE: what this bench measures is the DECISION, and
#  the fix to it lives in the schematic and is not in the extracted layout yet.
#  Including WEIGHT_COMP_V2_pex_rc.spice would simulate the OLD weight block.
#  The bench that does measure the layout with its parasitics is
#  `test_NAV2.sch`, which includes the four extracted blocks explicitly.

echo "==> netlist"
rm -f "$SIM/test_NAV2_geo.spice"
( cd "$HERE" && xschem -n -s -q -o "$SIM" test_NAV2_geo.sch ) || true
if [ ! -s "$SIM/test_NAV2_geo.spice" ] || [ "$HERE/test_NAV2_geo.sch" -nt "$SIM/test_NAV2_geo.spice" ]; then
    echo "  xschem no regenero $SIM/test_NAV2_geo.spice" >&2; exit 1
fi
#  The two tops hang off the SAME four bridges: `xnav2` is the schematic with the
#  decision redone (comparator against a reference of weight replicas) and
#  `xnavt` is the top exactly as it sits in the GDS, still with the three
#  COMP_OUT. Comparing them is the point of this bench, and it only means
#  anything at equal stimulus.
for e in "xnav2 VDDV GND XPv Xv XNv YPv Yv YNv ZPv Zv ZNv S2P S2N S4P S4N S3P S3N S1P S1N GRADIENT_NAV2_V2" \
         "xnavt VDDT GND XPt Xt XNt YPt Yt YNt ZPt Zt ZNt S2P S2N S4P S4N S3P S3N S1P S1N GRADIENT_NAV2"; do
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
python3 - "$SIM" "$DAT" "$STEP" "${MODE:-completo}" <<'PY'
import sys
from pathlib import Path
SIM, DAT, STEP, MODE = Path(sys.argv[1]), Path(sys.argv[2]), int(sys.argv[3]), sys.argv[4]
BOXES = [(1000, 1000), (1000, 500), (2000, 1000), (2000, 500),
         (3000, 1000), (3000, 500)]
#  Doce niveles en escala logaritmica, de 200 ppm/mm a 40 000. El rango se
#  deliberately narrow after the first run: with 20 ppm/mm at the bottom points
#  were spent where nothing happens, and with only eight levels the floor and
#  techo caian en la misma casilla y no se podian separar.
LEVELS = [200e-6 * (200 ** (i / 11)) for i in range(12)]
BACKGROUNDS = [0.0, 500e-6, 1e-3, 2e-3, 5e-3, 10e-3]

#  The order here IS the column order of the wrdata files, and `analizar_caja.py`
#  has the same list. Touch one and you must touch the other.
VEC = " ".join(["v(S1P)", "v(S1N)", "v(S2P)", "v(S2N)",
                "v(S3P)", "v(S3N)", "v(S4P)", "v(S4N)"]
               + [f"v({e}{s}v)" for e in "XYZ" for s in ("P", "", "N")]
               + [f"v(xnav2.{e}{k})" for e in "XYZ" for k in (1, 2, 3, 4)]
               + [f"v({e}{s}t)" for e in "XYZ" for s in ("P", "", "N")]
               + [f"v(xnavt.{e}{k})" for e in "XYZ" for k in (1, 2, 3, 4)]
               #  THE DIRECT OUTPUT AFTER THE COMPARATOR, which was missing and
               #  is the most informative signal between the amplifier and the
               #  decoder. Inside each GRADIENT2 they are net1 (SX against SY),
               #  net2 (SX against SZ) and net3 (SY against SZ) -- the very XY,
               #  XZ and YZ the DECODER consumes.
               + [f"v(xnavt.x{k}.net{j})" for k in (1, 2, 3, 4) for j in (1, 2, 3)])

#  The list is written out so `analizar_caja.py` can check its own VECTORES
#  against it EXACTLY. Counting `v(` in this file by hand does not work -- most
#  entries come out of comprehensions -- and `wrdata` writes no headers, so a
#  mismatch shifts every column with nothing to notice it.
(DAT / "vectores.txt").write_text("\n".join(VEC.split()) + "\n")

rows, ctrl = [], [".control"]
def sweep(lxy, lz, gmm, bg, tilt, tipo, off=0.0):
    i = len(rows) + 1
    rows.append(f"{i},{tipo},{lxy},{lz},{gmm:.6e},{bg:.6e},{tilt},{off:.6e}")
    ctrl.extend([f"alter Vlxy = {lxy}", f"alter Vlz = {lz}",
                 f"alter Vgmm = {gmm:.6e}", f"alter Vbg = {bg:.6e}",
                 f"alter Voff = {off:.6e}", f"alter Vtilt = {tilt}",
                 f"dc Vang 0 360 {STEP}", f"wrdata s{i:03d}.txt {VEC}"])

#  1: no mismatch, only two reference boxes: we already know there is no floor
#  there, and what matters in this family is the saturation ceiling.
def close_deck():
    ctrl.append(".endc")
    (DAT / "manifiesto.csv").write_text(
        "idx,tipo,lxy_um,lz_um,gmm,bg,tilt_deg,off\n" + "\n".join(rows) + "\n")
    src = (SIM / "test_NAV2_geo.spice").read_text().splitlines()
    corte = max(i for i, l in enumerate(src) if l.strip().lower() == ".end")
    (SIM / "corrida.spice").write_text(
        "\n".join(src[:corte] + [".save all"] + ctrl + [".end"]) + "\n")
    print(f"    {len(rows)} sweeps of {int(360 / STEP) + 1} points")


if MODE == "esfera":
    #  THE BOX TEST. One box -- the 1000 um cube -- and the direction swept over
    #  the WHOLE SPHERE instead of one plane, because the question is whether the
    #  outputs agree with what the four corners read in EVERY direction and a
    #  single great circle does not answer that.
    #
    #  With this parameterisation `ang` is the polar angle from +x and `tilt` the
    #  azimuth, so sweeping tilt 0..180 and ang 0..360 covers the sphere twice
    #  over -- and NOT uniformly: the poles at +-x are visited by every value of
    #  tilt. `analizar_caja.py` weights each sample by sin(ang) for exactly that
    #  reason; without the weight the percentage is a different question's answer.
    for tilt in range(0, 181, 15):
        for g in (1000e-6, 2223e-6, 9430e-6):
            sweep(1000, 1000, g, 0.0, tilt, f"esfera_{g:.0e}", 200e-6)
    close_deck()
    raise SystemExit(0)

if MODE == "sentido":
    #  Short run: the six boxes at two gradient levels. Just enough to answer
    #  whether the outputs give the SENSE. The resolution study is already done
    #  with NAV2 and repeating it with NAV3 inside costs three hours.
    for lxy, lz in BOXES:
        for g in (2223e-6, 9430e-6):
            sweep(lxy, lz, g, 0.0, 0, "sentido", 200e-6)
    close_deck()
    raise SystemExit(0)

for lxy, lz in ((1000, 1000), (3000, 1000)):
    for g in LEVELS:
        sweep(lxy, lz, g, 0.0, 0, "res_xz")
for lxy in (1000, 2000, 3000):              # 2: y en el X-Y, donde Lz no entra
    for g in LEVELS:
        sweep(lxy, 1000, g, 0.0, 90, "res_xy")
for lxy, lz in ((1000, 1000), (3000, 500)):  # 3: el campo de fondo
    for bg in BACKGROUNDS:
        sweep(lxy, lz, 2000e-6, bg, 0, "fondo")
#  4: THE REAL RESOLUTION. With sensor mismatch applied, which is what sets the
#  floor: without it, the comparison is exact however small the signal.
OFFSET = 200e-6
for lxy, lz in BOXES:
    for g in LEVELS:
        sweep(lxy, lz, g, 0.0, 0, "res_off", OFFSET)
#  5: and how that floor moves with the mismatch itself, in two boxes.
for lxy, lz in ((1000, 1000), (3000, 1000)):
    for off in (50e-6, 200e-6):
        for g in LEVELS:
            sweep(lxy, lz, g, 0.0, 0, f"off{int(off * 1e6)}", off)
ctrl.append(".endc")

(DAT / "manifiesto.csv").write_text(
    "idx,tipo,lxy_um,lz_um,gmm,bg,tilt_deg,off\n" + "\n".join(rows) + "\n")
src = (SIM / "test_NAV2_geo.spice").read_text().splitlines()
corte = max(i for i, l in enumerate(src) if l.strip().lower() == ".end")
(SIM / "corrida.spice").write_text(
    "\n".join(src[:corte] + [".save all"] + ctrl + [".end"]) + "\n")
print(f"    {len(rows)} sweeps of {int(360 / STEP) + 1} points "
      f"-> {SIM / 'corrida.spice'}")
PY

echo "==> simulating  (this is the long one: 84 sweeps over 31 RC blocks)"
( cd "$SIM" && ngspice -b corrida.spice > ngspice.log 2>&1 ) || true
if grep -iqE "error|singular|no DC path" "$SIM/ngspice.log"; then
    echo "  ngspice se ha quejado:" >&2
    grep -iE "error|singular|no DC path" "$SIM/ngspice.log" | head -5 | sed 's/^/    /' >&2
    exit 1
fi
#  The sphere run has its own analysis: three levels of reading against
#  geometric truth, and the output paired with its negated twin as ONE decision.
if [ "$MODE" = esfera ]; then
    python3 "$HERE/analizar_caja.py" "$SIM" "$DAT"
else
    python3 "$HERE/analizar_geo.py" "$SIM" "$DAT"
fi
