#!/bin/bash
# Points the `gds/` links at whichever version of the blocks you want, and
# records which one is in place.
#
#   ./scripts/usar_version.sh v1     blocks from Layouts/
#   ./scripts/usar_version.sh v2     blocks from layouts_v2/
#
# The top flow reads the block layouts ONLY through these links
# (`build_collateral.py` opens them as `gds/<BLOCK>.gds`), so switching them is
# all it takes to build the top out of different cells. What is NOT optional is
# regenerating the collateral afterwards: the v2 blocks are a different size,
# and a stale LEF would describe a macro with the wrong dimensions -- the
# floorplan would close and the GDS would come out with overlapping macros.
#
# Hence `lef/.version`: the Makefile compares it against the requested version
# and refuses to go on if they disagree.

set -euo pipefail
AQUI=$(cd "$(dirname "$0")/.." && pwd)
V=${1:-v1}
case "$V" in
    v1) DIR=Layouts ;;
    v2) DIR=layouts_v2 ;;
    *)  echo "usage: $0 v1|v2" >&2; exit 2 ;;
esac

#  OPAM_LIN_flat is the linear amplifier, the one GRADIENT2 uses. It is on the
#  list even though the GRADIENT top does not instantiate it: a spare LEF
#  bothers nobody, and a missing one breaks the top that does use it.
#  DECODER_MAX, OPAM_SUMA and ESD_CDM only exist in v2 (the first two belong
#  to the GRADIENT_NAV3
#  top), so v1 does not link them and nothing is missed.
BLOQUES="COMP DECODER OPAM OPAM_LIN_flat WEIGHT_COMP"
[ "$V" = v2 ] && BLOQUES="$BLOQUES DECODER_MAX OPAM_SUMA ESD_CDM"
for B in $BLOQUES; do
    DST=../../$DIR/$B/${B}_flat_gf180.gds
    REAL=$AQUI/../$DIR/$B/${B}_flat_gf180.gds
    if [ ! -s "$REAL" ]; then
        echo "  ERROR: $REAL does not exist" >&2; exit 1
    fi
    ln -sfn "$DST" "$AQUI/gds/$B.gds"
    printf "  %-14s -> %s\n" "$B.gds" "$DST"
done
echo "$V" > "$AQUI/gds/.version"
