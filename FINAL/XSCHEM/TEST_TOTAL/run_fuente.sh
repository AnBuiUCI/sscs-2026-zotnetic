#!/bin/bash
# A source at a place: does the chip point at it?
#
#   ./run_fuente.sh [step_in_degrees]      (default 5)
#
# Everything measured so far imposed a UNIFORM gradient in a direction. Here the
# field comes from a SOURCE sitting somewhere and each sensor reads the magnitude
# at its own vertex, which is the question the chip exists to answer.
#
# TWO MODELS, and the pair is the point:
#
#   dip = 0   SYMMETRIC. |B| depends on the distance only, so grad|B| points
#             EXACTLY at the source. Whatever error comes out is the chip's.
#   dip = 1   A REAL DIPOLE, axis along +z. |B| depends on the angle too and
#             grad|B| does NOT point exactly at the source, not even with a
#             perfect chip. The difference between the two numbers separates the
#             error of the circuit from the error of the physics -- which is
#             what you need before believing anything measured with a magnet.
#
# The source goes round the box (`ang` swept) at three distances and seven
# azimuths, with both models: 42 sweeps.

set -euo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SIM="$HERE/simulation/test_FUENTE.sch"
DAT="$HERE/datos_fuente"
STEP=${1:-5}
mkdir -p "$SIM" "$DAT"

#  Schematic level, like the box bench. See the note in run_nav2_geo.sh: the
#  extracted WEIGHT_COMP is the OLD weight block, from before the fifth branch.

echo "==> netlist"
rm -f "$SIM/test_FUENTE.spice"
( cd "$HERE" && xschem -n -s -q -o "$SIM" test_FUENTE.sch ) >/dev/null 2>&1 || true
test -s "$SIM/test_FUENTE.spice" || { echo "  xschem did not regenerate the netlist" >&2; exit 1; }
for e in "xnav2 VDDV GND XPv Xv XNv YPv Yv YNv ZPv Zv ZNv S2P S2N S4P S4N S3P S3N S1P S1N GRADIENT_NAV2_V2" \
         "xnavt VDDT GND XPt Xt XNt YPt Yt YNt ZPt Zt ZNt S2P S2N S4P S4N S3P S3N S1P S1N GRADIENT_NAV2"; do
    inst=${e%% *}
    real=$(grep -m1 "^$inst " "$SIM/test_FUENTE.spice" || true)
    if [ "$real" != "$e" ]; then
        echo "  WIRING BROKEN in test_FUENTE.sch" >&2
        echo "    expected: $e" >&2; echo "    netlist : ${real:-<not present>}" >&2; exit 1
    fi
done
echo "    the two instances, wired as they should be"

python3 - "$SIM" "$DAT" "$STEP" <<'PY'
import sys
from pathlib import Path
SIM, DAT, STEP = Path(sys.argv[1]), Path(sys.argv[2]), int(sys.argv[3])

VEC = " ".join(["v(S1P)", "v(S1N)", "v(S2P)", "v(S2N)",
                "v(S3P)", "v(S3N)", "v(S4P)", "v(S4N)"]
               + [f"v({e}{s}v)" for e in "XYZ" for s in ("P", "", "N")]
               + [f"v(xnav2.{e}{k})" for e in "XYZ" for k in (1, 2, 3, 4)]
               + [f"v({e}{s}t)" for e in "XYZ" for s in ("P", "", "N")]
               + [f"v(xnavt.{e}{k})" for e in "XYZ" for k in (1, 2, 3, 4)]
               + [f"v(xnavt.x{k}.net{j})" for k in (1, 2, 3, 4) for j in (1, 2, 3)])
(DAT / "vectores.txt").write_text("\n".join(VEC.split()) + "\n")

rows, ctrl = [], [".control"]
for dip in (0, 1):
    for rad in (3000, 6000, 12000):
        for tilt in range(0, 181, 30):
            i = len(rows) + 1
            rows.append(f"{i},{'dipolo' if dip else 'simetrico'},"
                         f"{rad},{tilt},{dip},5e-3,200e-6")
            ctrl += [f"alter Vdip = {dip}", f"alter Vrad = {rad}",
                     f"alter Vtilt = {tilt}", "alter Voff = 200e-6",
                     f"dc Vang 0 360 {STEP}", f"wrdata s{i:03d}.txt {VEC}"]
ctrl.append(".endc")
(DAT / "manifiesto.csv").write_text(
    "idx,tipo,rad_um,tilt_deg,dip,bcen,off\n" + "\n".join(rows) + "\n")
src = (SIM / "test_FUENTE.spice").read_text().splitlines()
corte = max(i for i, l in enumerate(src) if l.strip().lower() == ".end")
(SIM / "corrida.spice").write_text(
    "\n".join(src[:corte] + [".save all"] + ctrl + [".end"]) + "\n")
print(f"    {len(rows)} sweeps of {int(360 / STEP) + 1} points")
PY

echo "==> simulating"
( cd "$SIM" && ngspice -b corrida.spice > ngspice.log 2>&1 ) || true
if grep -iqE "^Error|singular|no DC path" "$SIM/ngspice.log"; then
    echo "  ngspice complained:" >&2
    grep -iE "^Error|singular|no DC path" "$SIM/ngspice.log" | head -5 | sed 's/^/    /' >&2
    exit 1
fi
python3 "$HERE/analizar_fuente.py" "$SIM" "$DAT"
