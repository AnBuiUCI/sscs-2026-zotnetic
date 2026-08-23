#!/bin/bash
# Banco del navegador: cuatro puentes magnetorresistivos contra DOS navegadores.
#
#   ./run_nav2.sh
#
# LOS DOS NAVEGADORES. El de hoy y el de XSCHEM_v2, sobre los MISMOS sensores:
#
#   hoy   `XSCHEM/GRADIENT_NAV2.sch`         alimentacion VDDS  salidas X Y Z XP ...
#   v2    `XSCHEM_v2/GRADIENT_NAV2_V2.sch`   alimentacion VDDV  salidas Xv .. ZNv
#
# El v2 lleva los dos arreglos del analisis funcional: el reparto de sensores
# entre las ranuras X/Y/Z de las cuatro cadenas, y la decision de salida hecha
# con un comparador contra una referencia sacada de dos replicas del propio
# bloque de pesos. Ver XSCHEM_v2/README.md.
#
# Los dos cuelgan de los MISMOS ocho nodos de sensor y cada uno lleva su propia
# fuente, para que el consumo se pueda comparar sin mezclarlo.
#
# QUE MIDE. Cuatro sensores a 0, 90, 180 y 270 grados y el campo girando de 0 a
# 360. Cada una de las cuatro cadenas del navegador lee TRES de los cuatro
# sensores, en combinaciones distintas, y los tres pesos combinan sus salidas. La
# cifra que sale de aqui es **en que porcentaje del barrido coinciden las nueve
# salidas del esquematico con las del layout**, y donde no coinciden, cuantos
# grados de ancho tiene el desacuerdo.
#
# COMO SE MODELA EL SENSOR. Puente completo, las cuatro ramas de 1 Mohm variando
# a la vez:
#
#     VEXC --R(1-b)-- SkP --R(1+b)-- GND      V(SkP) = VEXC*(1+b)/2
#     VEXC --R(1+b)-- SkN --R(1-b)-- GND      V(SkN) = VEXC*(1-b)/2
#
# de donde Vdiff = VEXC*b y **Vcm = VEXC/2 exacto, independiente de b**. Lo
# segundo hace falta: si el modo comun se moviera con la senal se mezclaria con
# la sensibilidad al modo comun de estas celdas y no habria forma de separar las
# dos cosas al leer la curva. `b` es literalmente dR/R.
#
# Tarda unos minutos: el navegador rehecho son 31 bloques extraidos con RC, y
# son 721 puntos por barrido y dos barridos.

set -euo pipefail

AQUI="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SIM="$AQUI/simulation/test_NAV2_v2.sch"
DAT="$AQUI/datos_nav2_v2"
mkdir -p "$SIM" "$DAT"

#  Los extraidos de la v2 hay que prepararlos antes: renombrar su subcircuito
#  -- la v1 y la v2 declaran el mismo nombre y no se pueden incluir juntas -- y
#  normalizar el orden de sus puertos. magic los emite en el orden en que los
#  encuentra en el layout, y ese orden cambia con el layout.
echo "==> preparando los extraidos de la v2"
/foss/designs/a_zonetic2026/XSCHEM/TEST/preparar_extraidos.sh \
    OPAM_LIN_flat COMP DECODER WEIGHT_COMP | grep pex_rc | sed 's/^/  /'

echo "==> netlist"
#  xschem devuelve a veces codigo 10 aunque escriba el netlist perfectamente, y
#  sin decir nada. Con `set -e` eso mataba el script a mitad, asi que no se mira
#  su codigo de salida: se comprueba que el fichero esta y es mas nuevo que el
#  esquematico, que es lo que de verdad importa.
rm -f "$SIM/test_NAV2_v2.spice"
( cd "$AQUI" && xschem -n -s -q -o "$SIM" test_NAV2_v2.sch ) || true
if [ ! -s "$SIM/test_NAV2_v2.spice" ] || [ "$AQUI/test_NAV2_v2.sch" -nt "$SIM/test_NAV2_v2.spice" ]; then
    echo "  xschem no regenero $SIM/test_NAV2_v2.spice" >&2; exit 1
fi

#  GUARDA: las dos instancias, cableadas a los mismos sensores y con salidas
#  separadas. Se conectan con etiquetas puestas sobre las patas del simbolo y ahi
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
echo "    las dos instancias, sobre los mismos sensores y con salidas separadas"

echo "==> simulando  (unos minutos: el rehecho son 31 bloques extraidos con RC)"
( cd "$SIM" && ngspice -b test_NAV2_v2.spice > ngspice.log 2>&1 ) || true
if grep -iqE "error|singular|no DC path" "$SIM/ngspice.log"; then
    echo "  ngspice se ha quejado:" >&2
    grep -iE "error|singular|no DC path" "$SIM/ngspice.log" | head -5 | sed 's/^/    /' >&2
    exit 1
fi

python3 "$AQUI/analizar_nav2_v2.py" "$SIM" "$DAT"
