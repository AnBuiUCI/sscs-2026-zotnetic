#!/bin/bash
# COMP_OUT inverter trip point: against the PMOS size, and against
# VDD y temperatura una vez elegido.
#
#   ./medir_disparo.sh    -> datos_top/disparo_w.csv y datos_top/disparo_vdd.csv
#
# It is what decides whether the output decision can be made with a skewed
# inverter or needs a comparator with a reference. The steps to be separated
# are those of the weight block: 2.178 V (2 votes) and 2.579 V (1 vote).
set -euo pipefail
AQUI="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DAT="$AQUI/datos_top"; TMP=$(mktemp -d); mkdir -p "$DAT"
MOD=/foss/pdks/gf180mcuD/libs.tech/ngspice

deck () {   # $1=W del PMOS  $2=VDD  $3=temp  $4=salida
cat > "$TMP/d.spice" <<SP
.include $MOD/design.ngspice
.lib $MOD/sm141064.ngspice typical
.option temp=$3
VDD vdd 0 $2
VIN in 0 0
XM3 out in vdd vdd pfet_05v0 L=0.5u W=$1u nf=1 m=1
XM4 out in 0 0 nfet_05v0 L=0.6u W=1.32u nf=1 m=1
.control
dc VIN 0 $2 0.005
wrdata $4 v(out)
.endc
.end
SP
( cd "$TMP" && ngspice -b d.spice > /dev/null 2>&1 ) || true
}

echo "==> trip point against PMOS width (VDD 5 V, 27 C)"
: > "$DAT/disparo_w.csv"; echo "wp_um,vdd,temp_c,trip_v" >> "$DAT/disparo_w.csv"
for w in 1.83 2.5 3.0 3.5 4.5 6.0 8.0 11.0; do
    deck "$w" 5.0 27 "s.txt"
    python3 - "$TMP/s.txt" "$w" 5.0 27 "$DAT/disparo_w.csv" <<'PY'
import sys, numpy as np
d=np.loadtxt(sys.argv[1]); vin,o=d[:,0],d[:,1]
trip=vin[np.argmin(np.abs(o-float(sys.argv[3])/2))]
open(sys.argv[5],"a").write(f"{sys.argv[2]},{sys.argv[3]},{sys.argv[4]},{trip:.4f}\n")
PY
done

echo "==> and against VDD and temperature, with the PMOS chosen (3.0 um)"
: > "$DAT/disparo_vdd.csv"; echo "wp_um,vdd,temp_c,trip_v" >> "$DAT/disparo_vdd.csv"
for t in -40 27 125; do for v in 4.5 4.75 5.0 5.25 5.5; do
    deck 3.0 "$v" "$t" "s.txt"
    python3 - "$TMP/s.txt" 3.0 "$v" "$t" "$DAT/disparo_vdd.csv" <<'PY'
import sys, numpy as np
d=np.loadtxt(sys.argv[1]); vin,o=d[:,0],d[:,1]
trip=vin[np.argmin(np.abs(o-float(sys.argv[3])/2))]
open(sys.argv[5],"a").write(f"{sys.argv[2]},{sys.argv[3]},{sys.argv[4]},{trip:.4f}\n")
PY
done; done
rm -rf "$TMP"
echo "   -> $DAT/disparo_w.csv  y  $DAT/disparo_vdd.csv"
