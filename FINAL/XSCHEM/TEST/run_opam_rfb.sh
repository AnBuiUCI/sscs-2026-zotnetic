#!/bin/bash
# Caracteriza OPAM_LIN con la hoja HRES de 1 kohm que da este shuttle.
#
#   ./run_opam_rfb.sh              # continua, alterna y forma del error
#   ./run_opam_rfb.sh --esquinas   # ademas, 27 esquinas de proceso, T y VDD
#
# Que pregunta este banco y por que existe
# ----------------------------------------
# El README de integracion fija `ppolyf_u_1k`. En el deck de LVS del PDK los
# tres valores de hoja son un INTERRUPTOR, no un dibujo -- `case POLY_RES when
# '1k'` sobre el mismo RES_MK sobre el mismo poly -- asi que cambiar de 3k a 1k
# NO MUEVE UN SOLO POLIGONO. Lo que cambia es el valor: los mismos 382 cuadros
# pasan de 1.147 Mohm a 382 kohm, y con ellos la ganancia de 103 a 33 V/V,
# porque la ganancia de esta etapa es Gm x RFB.
#
# Alargar la resistencia por tres serian 15 tiras en vez de 5, +22.5 um de
# canal y una celda un 47 % mayor, por doce instancias. Asi que el x3 se compra
# en los transistores, y este banco es donde se decidio cuales.
#
# Como se lee la tabla
# --------------------
#   COMO_ANTES   la celda que se sustituye, reconstruida deshaciendo los
#                cambios sobre el netlist nuevo. Si no da 103.4 V/V y 0.12 %
#                de INL, algo se ha movido y el resto de la tabla no vale.
#   SIN_TOCAR    esa misma celda con la hoja de 1k y nada mas: 33.3 V/V.
#                Es el problema, medido.
#   NUEVA        lo que hay en el esquematico.
#
# El netlist SE REGENERA SIEMPRE desde el .sch, nunca se lee el que ya esta en
# disco: si alguien toca el esquematico y no se regenera, la tabla mide la
# version anterior sin decir nada.

set -euo pipefail

AQUI="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCH="$AQUI/../OPAM"
SALIDA="$SCH/simulation/OPAM_LIN_flat.sch"

echo "==> regenerando el netlist desde OPAM_LIN_flat.sch"
mkdir -p "$SALIDA"
#  xschem devuelve a veces codigo 10 aunque escriba el netlist perfectamente y
#  sin decir nada. Con `set -e` eso mata el guion a medias, asi que no se mira
#  su codigo: se mira que el fichero este y sea mas nuevo que el esquematico,
#  que es lo que de verdad importa.
( cd "$SCH" && xschem -n -s -q -o "$SALIDA" OPAM_LIN_flat.sch ) >/dev/null 2>&1 || true
if [ ! -s "$SALIDA/OPAM_LIN_flat.spice" ] || \
   [ "$SCH/OPAM_LIN_flat.sch" -nt "$SALIDA/OPAM_LIN_flat.spice" ]; then
    echo "  xschem no regenero $SALIDA/OPAM_LIN_flat.spice" >&2
    exit 1
fi

#  Guarda: el gemelo jerarquico y el plano tienen que describir lo mismo. Se
#  editan por separado y es facil cambiar uno y olvidar el otro; entonces el
#  banco mide una celda y el layout se construye con la otra, y nada avisa.
for d in M21 M22 M29 M30 M43; do
    a=$(grep -A6 "{name=$d\$" "$SCH/OPAM_LIN_flat.sch"  | grep -m1 '^W=')
    b=$(grep -A6 "{name=$d\$" "$SCH/sub_diff_2_LIN.sch" | grep -m1 '^W=')
    if [ "$a" != "$b" ]; then
        echo "  $d NO COINCIDE: OPAM_LIN_flat.sch $a, sub_diff_2_LIN.sch $b" >&2
        exit 1
    fi
done
a=$(grep -c ppolyf_u_1k "$SCH/OPAM_LIN_flat.sch")
b=$(grep -c ppolyf_u_1k "$SCH/sub_diff_2_LIN.sch")
[ "$a" = "$b" ] || { echo "  la RFB no lleva el mismo modelo en los dos .sch" >&2; exit 1; }
echo "    los dos esquematicos coinciden en M21 M22 M29 M30 M43 y en la RFB"

exec python3 "$AQUI/barrido_opam.py" "$@"
