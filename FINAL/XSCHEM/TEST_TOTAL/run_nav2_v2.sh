#!/bin/bash
# Banco del navegador: cuatro puentes magnetorresistivos contra DOS navegadores.
#
#   ./run_nav2.sh
#
# THE TWO NAVIGATORS. Today's and the XSCHEM_v2 one, on the SAME sensors:
#
#   hoy   `XSCHEM/GRADIENT_NAV2.sch`         alimentacion VDDS  salidas X Y Z XP ...
#   v2    `XSCHEM_v2/GRADIENT_NAV2_V2.sch`   alimentacion VDDV  salidas Xv .. ZNv
#
# v2 carries the two fixes from the functional analysis: the sensor allocation
# across the X/Y/Z slots of the four chains, and the output decision made with a
# comparator against a reference taken from two replicas of the
# bloque de pesos. Ver XSCHEM_v2/README.md.
#
# Both hang off the SAME eight sensor nodes and each carries its own supply, so
# that current draw can be compared without mixing the two.
#
# QUE MIDE. Cuatro sensores a 0, 90, 180 y 270 grados y el campo girando de 0 a
# 360. Each of the four navigator chains reads THREE of the four
# sensores, en combinaciones distintas, y los tres pesos combinan sus salidas. La
# figure that comes out is **on what percentage of the sweep the nine schematic
# outputs agree with the layout ones**, and where they do not, how many degrees
# wide the disagreement is.
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
# It takes a few minutes: the rebuilt navigator is 31 blocks extracted with RC,
# and there are 721 points per sweep and two sweeps.

set -euo pipefail

AQUI="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SIM="$AQUI/simulation/test_NAV2_v2.sch"
DAT="$AQUI/datos_nav2_v2"
mkdir -p "$SIM" "$DAT"

#  The v2 extractions have to be prepared first: rename their subcircuit -- v1
#  and v2 declare the same name and cannot be included together -- and normalise
#  their port order. magic emits them in the order it
#  encuentra en el layout, y ese orden cambia con el layout.
echo "==> preparando los extraidos de la v2"
/foss/designs/a_zonetic2026/XSCHEM/TEST/preparar_extraidos.sh \
    OPAM_LIN_flat COMP DECODER WEIGHT_COMP | grep pex_rc | sed 's/^/  /'

echo "==> netlist"
#  xschem devuelve a veces codigo 10 aunque escriba el netlist perfectamente, y
#  without a word. With `set -e` that killed the script halfway, so its exit
#  code is not checked: instead we check the file is there and newer than the
#  schematic, which is what actually matters.
rm -f "$SIM/test_NAV2_v2.spice"
( cd "$AQUI" && xschem -n -s -q -o "$SIM" test_NAV2_v2.sch ) || true
if [ ! -s "$SIM/test_NAV2_v2.spice" ] || [ "$AQUI/test_NAV2_v2.sch" -nt "$SIM/test_NAV2_v2.spice" ]; then
    echo "  xschem no regenero $SIM/test_NAV2_v2.spice" >&2; exit 1
fi

#  GUARD: the two instances, wired to the same sensors and with separate
#  outputs. They connect with labels dropped on the symbol's pins and there it
#  es facilisimo correr una posicion; no daria ningun error, simularia.
for e in "xnav VDDS GND XP X XN YP Y YN ZP Z ZN S2P S2N S4P S4N S3P S3N S1P S1N GRADIENT_NAV2" \
         "xnav2 VDDV GND XPv Xv XNv YPv Yv YNv ZPv Zv ZNv S2P S2N S4P S4N S3P S3N S1P S1N GRADIENT_NAV2_V2"; do
    inst=${e%% *}
    real=$(grep -m1 "^$inst " "$SIM/test_NAV2_v2.spice" || true)
    if [ "$real" != "$e" ]; then
        echo "  CABLEADO ROTO en test_NAV2_v2.sch" >&2
        echo "    esperado: $e" >&2
        echo "    netlist : ${real:-<no aparece>}" >&2
        exit 1
    fi
done
echo "    the two instances, on the same sensors and with separate outputs"

echo "==> simulating  (a few minutes: the rebuild is 31 blocks extracted with RC)"
( cd "$SIM" && ngspice -b test_NAV2_v2.spice > ngspice.log 2>&1 ) || true
if grep -iqE "error|singular|no DC path" "$SIM/ngspice.log"; then
    echo "  ngspice se ha quejado:" >&2
    grep -iE "error|singular|no DC path" "$SIM/ngspice.log" | head -5 | sed 's/^/    /' >&2
    exit 1
fi

python3 "$AQUI/analizar_nav2_v2.py" "$SIM" "$DAT"
