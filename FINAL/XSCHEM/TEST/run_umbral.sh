#!/bin/bash
# Does the vote counter's step land where the buffer trips, over VDD and temperature?
#
#   ./run_umbral.sh
#
# THIS IS THE GATE OF THE WHOLE CHANGE. `WEIGHT` is a current-mode vote counter
# and `COMP_OUT` is a pair of inverters behind it. The decision the chip has to
# make is "this axis wins from TWO votes on", and today the buffer trips between
# 2 and 3. Adding a fifth branch to WEIGHT that is always on shifts every level
# down by exactly one vote, which puts the trip between 1 and 2 -- IF the two
# track each other over supply and temperature.
#
# They may well not. The inverter's trip point is a RATIO DIVIDER and follows
# VDD; the weight levels come out of a diode stack and current mirrors, so they
# go more like "VDD minus a few Vgs". That mismatch is exactly what sank the
# idea of skewing the inverter, and it is measured here rather than argued.
#
# What comes out: for each of the 16 input combinations, the analogue level and
# what the buffer makes of it, swept over VDD 4.5..5.5 V at three temperatures.

set -euo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CELL=${1:-WEIGHT_COMP}
FUENTE="$HERE/../WEIGTH/$CELL.sch"
SIM="$HERE/simulation/umbral_$CELL"
mkdir -p "$SIM"

echo "==> netlist of $CELL (always regenerated)"
rm -rf "$HERE/../WEIGTH/simulation/$CELL.sch"
( cd "$HERE/../WEIGTH" && xschem -n -s -q -o "simulation/$CELL.sch" "$CELL.sch" ) >/dev/null 2>&1 || true
NET="$HERE/../WEIGTH/simulation/$CELL.sch/$CELL.spice"
test -s "$NET" || { echo "  xschem did not regenerate $NET" >&2; exit 1; }
#  The commented top-level `.subckt` xschem writes from the CLI has to be
#  uncommented before anything can instantiate it.
sed 's/^\*\*\.subckt/.subckt/; s/^\*\*\.ends/.ends/' "$NET" > "$SIM/$CELL.inc"
grep -q "^\.subckt $CELL " "$SIM/$CELL.inc" || { echo "  no .subckt $CELL in it" >&2; exit 1; }

python3 - "$SIM" "$CELL" <<'PY'
import sys
from pathlib import Path
SIM, CELL = Path(sys.argv[1]), sys.argv[2]

#  The four vote inputs are LOGIC and swing to the rail, so a '1' has to follow
#  VDD as the sweep moves it. A fixed 5 V source would be measuring a different
#  circuit at every point of the sweep.
ctrl = [".control", "set filetype=ascii"]
rows = []
for temp in (0, 27, 85):
    ctrl.append(f"set temp = {temp}")
    for n in range(16):
        bits = [(n >> i) & 1 for i in range(4)]
        for i, b in enumerate(bits):
            ctrl.append(f"alter Vsel{i} = {b}")
        idx = len(rows) + 1
        rows.append(f"{idx},{temp},{sum(bits)}," + "".join(str(b) for b in bits))
        ctrl.append(f"dc Vdd 4.5 5.5 0.05")
        ctrl.append(f"wrdata u{idx:03d}.txt v(we) v(out) v(out_n)")
ctrl.append(".endc")

deck = [f"* threshold of {CELL}: does the step land where the buffer trips?",
        ".include $::180MCU_MODELS/design.ngspice".replace("$::180MCU_MODELS",
            "/foss/pdks/gf180mcuD/libs.tech/ngspice"),
        ".lib /foss/pdks/gf180mcuD/libs.tech/ngspice/sm141064.ngspice typical",
        f'.include "{SIM / (CELL + ".inc")}"',
        "Vdd VDD 0 5", "Vss VSS 0 0"]
for i in range(4):
    deck.append(f"Vsel{i} sel{i} 0 0")
    deck.append(f"B{i} v{'abcd'[i]} 0 v='v(sel{i}) * v(VDD)'")
deck.append(f"x1 VDD VSS va vb vc vd we out out_n {CELL}")
deck += [".save all"] + ctrl + [".end"]
(SIM / "corrida.spice").write_text("\n".join(deck) + "\n")
(SIM / "manifiesto.csv").write_text("idx,temp,votos,bits\n" + "\n".join(rows) + "\n")
print(f"    {len(rows)} input combinations x 21 points of VDD")
PY

echo "==> simulating"
( cd "$SIM" && ngspice -b corrida.spice > ngspice.log 2>&1 ) || true
if grep -iqE "^Error|singular|no DC path" "$SIM/ngspice.log"; then
    echo "  ngspice complained:" >&2
    grep -iE "^Error|singular|no DC path" "$SIM/ngspice.log" | head -5 | sed 's/^/    /' >&2
    exit 1
fi
python3 "$HERE/analizar_umbral.py" "$SIM"
