#!/bin/bash
# Banco de gradiente: tres puentes magnetorresistivos contra CUATRO cadenas.
#
#   ./run_gradient.sh
#
# LAS CUATRO CADENAS. Las mismas dos, dos veces:
#
#   G1  esquematico, con el OPAM de 98 dB          alimentacion VDD1  salidas X1 Y1 Z1
#   G2  esquematico, con el OPAM_LIN de 40 dB      alimentacion VDD2  salidas X2 Y2 Z2
#   G3  rehecha con los bloques del layout v2      alimentacion VDD3  salidas X3 Y3 Z3
#   G4  idem, con el OPAM_LIN_flat del layout v2   alimentacion VDD4  salidas X4 Y4 Z4
#
# Las cuatro cuelgan de los MISMOS seis nodos de sensor y cada una lleva su
# propia fuente, para que el consumo se pueda comparar sin mezclarlo.
#
# QUE MIDE. Los tres campos van desfasados 120 grados entre si, asi que suman
# cero y el vector solo cambia de direccion. Barriendo el angulo de 0 a 360 cada
# eje deberia ganar un sector de 120 grados exactos; lo que se desvien esas tres
# fronteras es la cifra que sale de aqui.
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
# Son resistencias de comportamiento y no un barrido de resistencias porque `dc`
# admite dos fuentes anidadas como mucho, y aqui hay DOCE que se tienen que
# mover a la vez y de forma coherente.
#
# VEXC es fuente aparte aunque valga 5 V como el rail. Bajarla a 4.0 V lleva el
# modo comun a 2.0 V, que es donde run_opam_g100.sh midio ~107 V/V en vez de 61.
# Es cambiar un numero en el esquematico.
#
# Tarda un minuto y medio largo: las cadenas G3 y G4 son netlists extraidos con
# RC, y son 721 puntos por barrido y dos barridos.

set -euo pipefail

AQUI="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SIM="$AQUI/simulation/test_GRADIENT.sch"
DAT="$AQUI/datos"
mkdir -p "$SIM" "$DAT"

#  Los extraidos de la v2 hay que prepararlos antes: renombrar su subcircuito
#  -- los dos declaran el mismo nombre y no se pueden incluir juntos -- y
#  normalizar el orden de sus puertos. magic los emite en el orden en que los
#  encuentra en el layout, y ese orden cambia con el layout.
echo "==> preparando los extraidos de la v2"
/foss/designs/a_zonetic2026/XSCHEM/TEST/preparar_extraidos.sh \
    OPAM OPAM_LIN_flat COMP DECODER | grep pex_rc | sed 's/^/  /'

echo "==> netlist"
#  xschem devuelve a veces codigo 10 aunque escriba el netlist perfectamente, y
#  sin decir nada. Con `set -e` eso mataba el script a mitad, asi que no se mira
#  su codigo de salida: se comprueba que el fichero esta y es mas nuevo que el
#  esquematico, que es lo que de verdad importa.
rm -f "$SIM/test_GRADIENT.spice"
( cd "$AQUI" && xschem -n -s -q -o "$SIM" test_GRADIENT.sch ) || true
if [ ! -s "$SIM/test_GRADIENT.spice" ] || [ "$AQUI/test_GRADIENT.sch" -nt "$SIM/test_GRADIENT.spice" ]; then
    echo "  xschem no regenero $SIM/test_GRADIENT.spice" >&2; exit 1
fi

#  GUARDA 1: las dos cadenas esquematicas. Se conectan con etiquetas sueltas y
#  ahi es facilisimo dejarse una: el esquematico de partida tenia SYN atado a
#  S3N en las DOS cadenas -- el eje Y midiendo el sensor Z por su pata negativa
#  -- y las tres salidas de las dos cadenas al mismo nodo. Ninguna de las dos
#  cosas da error: simulan y devuelven numeros que no valen nada.
#
#  Solo el bloque de primer nivel: dentro de GRADIENT y de las celdas hay mas
#  instancias que tambien se llaman x2 y x3, y buscarlas en todo el fichero
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
echo "    G1 y G2 cableadas como toca, y con salidas separadas"

#  GUARDA 2: las dos cadenas rehechas a mano tienen que ser el MISMO circuito
#  que las esquematicas. Es la comprobacion central del banco: sin ella,
#  comparar G1 con G3 no demuestra nada.
python3 "$AQUI/comprobar_cadena.py" "$SIM/test_GRADIENT.spice" GRADIENT  3
python3 "$AQUI/comprobar_cadena.py" "$SIM/test_GRADIENT.spice" GRADIENT2 4

echo "==> simulando  (minuto y medio: G3 y G4 son extraidos con RC)"
( cd "$SIM" && ngspice -b test_GRADIENT.spice > ngspice.log 2>&1 ) || true
if grep -iqE "error|singular|no DC path" "$SIM/ngspice.log"; then
    echo "  ngspice se ha quejado:" >&2
    grep -iE "error|singular|no DC path" "$SIM/ngspice.log" | head -5 | sed 's/^/    /' >&2
    exit 1
fi

python3 "$AQUI/analizar.py" "$SIM" "$DAT"
