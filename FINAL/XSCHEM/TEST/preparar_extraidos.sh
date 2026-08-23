#!/bin/bash
# Deja listos los netlists extraidos de la v2 para poder instanciarlos AL LADO de
# los de la v1 en el mismo banco. Hace DOS cosas, y las dos hacen falta:
#
# 1. RENOMBRAR el subcircuito. Los dos declaran `.subckt <BLOQUE>`, porque la
#    celda se llama igual en las dos versiones a proposito: es lo que permite
#    compararlas contra la MISMA netlist de referencia en el LVS. Incluir los dos
#    ficheros en una misma simulacion redefine el subcircuito.
#
#    Se tocan SOLO las lineas `.subckt` y `.ends`. Un `sed` global sobre el
#    nombre tocaria tambien nodos internos que lo contengan (magic los genera
#    como `<BLOQUE>_...`), y eso si romperia la netlist en silencio.
#
# 2. NORMALIZAR EL ORDEN DE LOS PUERTOS al de la v1. **magic emite los puertos en
#    el orden en que los encuentra en el layout, y ese orden cambia con el
#    layout.** Medido:
#
#      v1: .subckt OPAM_LIN_flat    VSS VDD INP OUT INN
#      v2: .subckt OPAM_LIN_flat_V2 VSS VDD INP INN OUT     <- OUT e INN al reves
#
#    Con las dos instancias cableadas igual, la v2 tenia la salida conectada a la
#    entrada negativa. No da ningun error: simula y da numeros, solo que no son
#    los del circuito. Se vio porque la transferencia salia plana en 0.0..0.7 V
#    mientras el esquematico hacia 0.01..4.97.
#
#    Reordenar la linea `.subckt` es legitimo y no toca nada mas: el cuerpo se
#    refiere a los nodos por NOMBRE, asi que cambiar su posicion solo cambia con
#    que nodo del llamante se empareja cada uno.
#
#   ./preparar_extraidos.sh              todos los bloques
#   ./preparar_extraidos.sh COMP         uno solo

set -uo pipefail
V1=/foss/designs/a_zonetic2026/layouts
V2=/foss/designs/a_zonetic2026/layouts_v2
BLOQUES=${*:-"WEIGHT_COMP DECODER COMP OPAM OPAM_LIN_flat"}
FALLOS=0

for B in $BLOQUES; do
    for SUF in pex_rc pex_c extracted; do
        SRC=$V2/$B/mag/${B}_${SUF}.spice
        REF=$V1/$B/mag/${B}_${SUF}.spice
        DST=$V2/$B/mag/${B}_V2_${SUF}.spice
        [ -s "$SRC" ] || continue
        ORDEN=$(grep -m1 -iE "^\.subckt[[:space:]]+$B\b" "$REF" 2>/dev/null \
                | cut -d" " -f3-)
        if [ -z "$ORDEN" ]; then
            echo "  ERROR: no encuentro el orden de puertos de la v1 en $REF" >&2
            FALLOS=$((FALLOS + 1)); continue
        fi
        awk -v b="$B" -v orden="$ORDEN" '''
            BEGIN { IGNORECASE = 1 }
            $1 == ".subckt" && $2 == b { print ".subckt " b "_V2 " orden; next }
            $1 == ".ends"   && $2 == b { print ".ends " b "_V2"; next }
            { print }
        ''' "$SRC" > "$DST"

        #  Comprobar que el renombrado ha ocurrido: un `.subckt` que no case
        #  dejaria dos definiciones con el mismo nombre y ngspice se quedaria con
        #  una de las dos sin avisar de nada.
        if ! grep -qiE "^\.subckt[[:space:]]+${B}_V2\b" "$DST"; then
            echo "  ERROR: no se renombro el subcircuito en $DST" >&2
            FALLOS=$((FALLOS + 1)); continue
        fi
        #  ...y que los DOS declaran el mismo juego de puertos. Si magic ha
        #  descubierto un puerto de mas o de menos en una version, cablearlas
        #  igual no significa lo mismo y hay que enterarse aqui, no mirando una
        #  curva rara tres pasos despues.
        A=$(grep -m1 -iE "^\.subckt[[:space:]]+$B\b" "$REF" | cut -d" " -f3- | tr " " "\n" | sort | tr "\n" " ")
        C=$(grep -m1 -iE "^\.subckt[[:space:]]+${B}_V2\b" "$DST" | cut -d" " -f3- | tr " " "\n" | sort | tr "\n" " ")
        if [ "$A" != "$C" ]; then
            echo "  ERROR: $B tiene puertos distintos en v1 y v2" >&2
            echo "     v1: $A" >&2
            echo "     v2: $C" >&2
            FALLOS=$((FALLOS + 1)); continue
        fi
        printf "  %-16s %-10s -> %s   (%s)\n" "$B" "$SUF" "$(basename "$DST")" "$ORDEN"
    done
done
[ "$FALLOS" -eq 0 ] || { echo "  $FALLOS fichero(s) sin preparar" >&2; exit 1; }
