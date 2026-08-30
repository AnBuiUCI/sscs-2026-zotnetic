#!/bin/bash
# Prepares the v2 extracted netlists so they can be instantiated ALONGSIDE the
# v1 ones in the same bench. It does TWO things, and both are needed:
#
# 1. RENAME the subcircuit. Both declare `.subckt <BLOCK>`, because the cell is
#    named the same in both versions on purpose: that is what lets them be
#    compared against the SAME reference netlist in LVS. Including both files in
#    one simulation redefines the subcircuit.
#
#    ONLY the `.subckt` and `.ends` lines are touched. A global `sed` on the
#    name would also touch internal nodes containing it (magic generates them
#    as `<BLOCK>_...`), and that would break the netlist silently.
#
# 2. NORMALISE THE PORT ORDER to v1. **magic emits the ports in the order it
#    finds them in the layout, and that order changes with the
#    layout.** Medido:
#
#      v1: .subckt OPAM_LIN_flat    VSS VDD INP OUT INN
#      v2: .subckt OPAM_LIN_flat_V2 VSS VDD INP INN OUT     <- OUT e INN al reves
#
#    With both instances wired the same, v2 had its output connected to the
#    negative input. No error at all: it simulates and gives numbers, only they
#    are not the circuit. It showed because the transfer came out flat over
#    mientras el esquematico hacia 0.01..4.97.
#
#    Reordering the `.subckt` line is legitimate and touches nothing else: the
#    body refers to nodes by NAME, so changing their position only changes which
#    of the caller's nodes each one pairs with.
#
#   ./preparar_extraidos.sh              all the blocks
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

        #  Check the rename actually happened: a `.subckt` that does not match
        #  would leave two definitions with the same name and ngspice would keep
        #  one of them without warning.
        if ! grep -qiE "^\.subckt[[:space:]]+${B}_V2\b" "$DST"; then
            echo "  ERROR: no se renombro el subcircuito en $DST" >&2
            FALLOS=$((FALLOS + 1)); continue
        fi
        #  ...and that BOTH declare the same set of ports. If magic has
        #  found one port more or fewer in one version, wiring them
        #  the same does not mean the same thing and it must be caught here, not by
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
[ "$FALLOS" -eq 0 ] || { echo "  $FALLOS file(s) not prepared" >&2; exit 1; }
