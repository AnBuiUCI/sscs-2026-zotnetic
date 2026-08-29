Where this cell comes from
==========================

io_secondary_5p0_flat_gf180.gds is NOT ours. It is the secondary-ESD cell the
Chipathon organisers publish, adopted as drawn:

  repo    sscs-ose/sscs-chipathon-2026
  commit  aa834f5
  path    resources/Integration/Chipathon2025_pads/magic/secondary_ESD.gds
  cell    io_secondary_5p0,  75.65 x 85.35 um

Why theirs and not ours. It was measured, not assumed: their GDS passes the
KLayout sign-off DRC with 0 violations over 63 rule tables, and passes LVS
against io_secondary_5p0_lvs.spice with "Congratulations! Netlists match."
The rule agreed with the user was: run DRC and LVS on their GDS; if it passes,
use it as it is, and only redraw it if it does not.

What openroad/scripts/esd_jacket.py adds, and nothing else:

  * the cell shifted so its corner is (0, 0). Theirs starts at (-36, -24.15).
  * a copy of every port label on datatype 0. Theirs are on 34/10 and 36/10,
    and build_collateral indexes only datatype 0.
  * one Metal3 landing pad per port with its via stack, because
    build_collateral.keep_top_access requires a signal pin to reach Metal3
    before the router one level up can use it. Their ports stop at Metal2
    (ASIG5V, to_gate) and Metal1 (VDD, VSS).

Not one polygon of their devices is touched. Where each pad goes is measured:
the script takes the polygon the port's label sits on, subtracts every shape of
the other nets grown by the wide-metal spacing (M*.2b, 0.30 um), and lands the
pad in the largest clear square that is left.

Their published schematic does not match their own layout -- see the header of
io_secondary_5p0_lvs.spice. That is worth reporting upstream.

Our own hand-drawn secondary ESD, openroad/scripts/esd_layout.py and
XSCHEM_v2/ESD_CDM.sch, is kept but is NOT what gets fabricated.
