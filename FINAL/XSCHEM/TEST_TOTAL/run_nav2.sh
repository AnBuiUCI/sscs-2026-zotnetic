#!/bin/bash
# Banco del navegador: cuatro puentes magnetorresistivos contra DOS navegadores.
#
#   ./run_nav2.sh
#
# LOS DOS NAVEGADORES. El mismo circuito, por los dos caminos:
#
#   N_esq  el esquematico `GRADIENT_NAV2`             alimentacion VDDS  salidas X Y Z ...
#   N_lay  rehecho con los bloques del layout v2,     alimentacion VDDR  salidas Xr Yr Zr ...
#          extraidos CON PARASITOS RC
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
SIM="$AQUI/simulation/test_NAV2.sch"
DAT="$AQUI/datos_nav2"
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
rm -f "$SIM/test_NAV2.spice"
( cd "$AQUI" && xschem -n -s -q -o "$SIM" test_NAV2.sch ) || true
if [ ! -s "$SIM/test_NAV2.spice" ] || [ "$AQUI/test_NAV2.sch" -nt "$SIM/test_NAV2.spice" ]; then
    echo "  xschem no regenero $SIM/test_NAV2.spice" >&2; exit 1
fi

#  GUARDA 1: el esquematico esta cableado como toca. La instancia del top se
#  conecta con etiquetas sueltas puestas sobre las patas del simbolo, y ahi es
#  facilisimo dejarse una o correrla una posicion: no da error, simula.
esperado="xnav VDDS GND XP X XN YP Y YN ZP Z ZN S2P S2N S4P S4N S3P S3N S1P S1N GRADIENT_NAV2"
real=$(grep -m1 "^xnav " "$SIM/test_NAV2.spice" || true)
if [ "$real" != "$esperado" ]; then
    echo "  CABLEADO ROTO en test_NAV2.sch" >&2
    echo "    esperado: $esperado" >&2
    echo "    netlist : ${real:-<no aparece>}" >&2
    exit 1
fi
echo "    la instancia del esquematico, cableada como toca"

#  GUARDA 2: el navegador rehecho a mano tiene que ser el MISMO circuito que el
#  esquematico. Sin esto, comparar sus salidas no demuestra nada.
python3 "$AQUI/comprobar_nav2.py" "$SIM/test_NAV2.spice"

echo "==> simulando  (unos minutos: el rehecho son 31 bloques extraidos con RC)"
( cd "$SIM" && ngspice -b test_NAV2.spice > ngspice.log 2>&1 ) || true
if grep -iqE "error|singular|no DC path" "$SIM/ngspice.log"; then
    echo "  ngspice se ha quejado:" >&2
    grep -iE "error|singular|no DC path" "$SIM/ngspice.log" | head -5 | sed 's/^/    /' >&2
    exit 1
fi

python3 "$AQUI/analizar_nav2.py" "$SIM" "$DAT"
