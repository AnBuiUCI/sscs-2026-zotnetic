Where these two files come from
===============================

Attached by d-m-bailey to issue #58 of sscs-ose/sscs-chipathon-2026 on
2026-08-23, as B26.def.tgz, with the note "Updated def files to remove default
vss pad". They are the padring the organisers generated for our slot, built
from the info.yaml we had submitted at the time.

  B26_A.def           the user area: 1110 x 1110 um (222000 dbu at 200/um),
                      with the 19 pins on its west and north edges.
  B26_A_pad_map.yaml  which pad cell and which slot each pin got.

CAREFUL: these were generated with VSS in third place and VDD in fourth. The
info.yaml in this repo now puts VSS first and VDD last, as
resources/info.yaml of the chipathon repo requires, so THE SLOT ASSIGNMENT IN
THESE TWO FILES IS STALE. openroad/scripts/padframe_def.py takes only the pad
SHAPES from them and re-assigns the names from info.yaml; the organisers still
have to regenerate the padring itself.
