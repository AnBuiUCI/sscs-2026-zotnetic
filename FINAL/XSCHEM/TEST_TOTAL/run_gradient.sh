#!/bin/bash
# Banco de gradiente: tres puentes magnetorresistivos contra CUATRO cadenas.
#
#   ./run_gradient.sh
#
# THE FOUR CHAINS. The same two, twice over:
#
#   G1  schematic, with the 98 dB OPAM             supply VDD1  outputs X1 Y1 Z1
#   G2  schematic, with the 40 dB OPAM_LIN         supply VDD2  outputs X2 Y2 Z2
#   G3  rebuilt from the v2 layout blocks          supply VDD3  outputs X3 Y3 Z3
#   G4  same, with the v2 layout OPAM_LIN_flat     supply VDD4  outputs X4 Y4 Z4
#
# All four hang off the SAME six sensor nodes and each carries its own supply,
# so that current draw can be compared without mixing them.
#
# WHAT IT MEASURES. The three fields are 120 degrees apart, so they sum to zero
# and the vector only changes direction. Sweeping the angle 0 to 360 each axis
# should win a sector of exactly 120 degrees; how far those three boundaries
# drift is the figure that comes out of here.
#
# HOW THE SENSOR IS MODELLED. Full bridge, the four 1 Mohm arms varying
# a la vez:
#
#     VEXC --R(1-b)-- SkP --R(1+b)-- GND      V(SkP) = VEXC*(1+b)/2
#     VEXC --R(1+b)-- SkN --R(1-b)-- GND      V(SkN) = VEXC*(1-b)/2
#
# from which Vdiff = VEXC*b and **Vcm = VEXC/2 exactly, independent of b**. The
# second matters: if the common mode moved with the signal it would mix with
# these cells' common-mode sensitivity and there would be no way to separate the
# dos cosas al leer la curva. `b` es literalmente dR/R.
#
# They are behavioural resistors and not a resistor sweep because `dc` takes two
# nested sources at most, and here there are TWELVE that have to
# mover a la vez y de forma coherente.
#
# VEXC is a separate source even though it is 5 V like the rail. Dropping it to
# 4.0 V puts the common mode at 2.0 V, where run_opam_g100.sh measured ~107 V/V
# Es cambiar un numero en el esquematico.
#
# It takes a good minute and a half: chains G3 and G4 are netlists extracted
# with RC, and there are 721 points per sweep and two sweeps.

set -euo pipefail

AQUI="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SIM="$AQUI/simulation/test_GRADIENT.sch"
DAT="$AQUI/datos"
mkdir -p "$SIM" "$DAT"

#  The v2 extractions have to be prepared first: rename their subcircuit -- both
#  declare the same name and cannot be included together -- and normalise
#  their port order. magic emits them in the order it
#  encuentra en el layout, y ese orden cambia con el layout.
echo "==> preparando los extraidos de la v2"
/foss/designs/a_zonetic2026/XSCHEM/TEST/preparar_extraidos.sh \
    OPAM OPAM_LIN_flat COMP DECODER | grep pex_rc | sed 's/^/  /'

echo "==> netlist"
#  xschem devuelve a veces codigo 10 aunque escriba el netlist perfectamente, y
#  without a word. With `set -e` that killed the script halfway, so its exit
#  code is not checked: instead we check the file is there and newer than the
#  schematic, which is what actually matters.
rm -f "$SIM/test_GRADIENT.spice"
( cd "$AQUI" && xschem -n -s -q -o "$SIM" test_GRADIENT.sch ) || true
if [ ! -s "$SIM/test_GRADIENT.spice" ] || [ "$AQUI/test_GRADIENT.sch" -nt "$SIM/test_GRADIENT.spice" ]; then
    echo "  xschem no regenero $SIM/test_GRADIENT.spice" >&2; exit 1
fi

#  GUARD 1: the two schematic chains. They connect with loose labels and there
#  it is dead easy to miss one: the starting schematic had SYN tied to S3N in
#  BOTH chains -- the Y axis reading sensor Z through its negative leg -- and
#  the three outputs of both chains on the same node. Neither of those raises
#  an error: they simulate and return numbers that are worth nothing.
#
#  Top-level block only: inside GRADIENT and the cells there are more instances
#  also called x2 and x3, and searching the whole file for them
#  seria buscar la palabra en el sitio equivocado.
sed -n '1,/^\*\*\*\* begin user architecture code/p' "$SIM/test_GRADIENT.spice" > "$SIM/.top"
for e in "x2 S1N S1P VDD1 X1 S2N Y1 Z1 S2P GND S3N S3P GRADIENT" \
         "x3 S1N S1P VDD2 X2 S2N Y2 Z2 S2P GND S3N S3P GRADIENT2"; do
    inst=${e%% *}
    real=$(grep -m1 "^$inst " "$SIM/.top" || true)
    if [ "$real" != "$e" ]; then
        echo "  CABLEADO ROTO en test_GRADIENT.sch" >&2
        echo "    esperado: $e" >&2
        echo "    netlist : ${real:-<no aparece>}" >&2
        exit 1
    fi
done
echo "    G1 and G2 wired as they should be, with separate outputs"

#  GUARD 2: the two hand-rebuilt chains have to be the SAME circuit as the
#  schematic ones. It is the bench's central check: without it, comparing G1
#  with G3 proves nothing.
python3 "$AQUI/comprobar_cadena.py" "$SIM/test_GRADIENT.spice" GRADIENT  3
python3 "$AQUI/comprobar_cadena.py" "$SIM/test_GRADIENT.spice" GRADIENT2 4

echo "==> simulating  (a minute and a half: G3 and G4 are RC extractions)"
( cd "$SIM" && ngspice -b test_GRADIENT.spice > ngspice.log 2>&1 ) || true
if grep -iqE "error|singular|no DC path" "$SIM/ngspice.log"; then
    echo "  ngspice se ha quejado:" >&2
    grep -iE "error|singular|no DC path" "$SIM/ngspice.log" | head -5 | sed 's/^/    /' >&2
    exit 1
fi

python3 "$AQUI/analizar.py" "$SIM" "$DAT"
