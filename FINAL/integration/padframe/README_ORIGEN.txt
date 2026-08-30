Where these three files come from
=================================

Attached by d-m-bailey to issue #58 of sscs-ose/sscs-chipathon-2026 on
2026-08-27 ("Updated def files"), as B26.def.tgz. This one was generated from
the info.yaml in this repo -- VSS first, VDD last, the six comparator outputs
declared bidirectional -- and it has been checked pin by pin against it.

  B26_A.def            the user area: 1110 x 1110 um (222000 dbu at 200/um)
                       with 73 PINS on its west and north edges, and NO
                       COMPONENTS. It is an empty template for us to fill.
  B26_A_pad_map.yaml   which pad cell and which slot each of the 19 signals got.
  B26_A_interface.yaml maps every DEF pin to the terminal of the pad cell, with
                       the direction seen FROM OUR BLOCK.

WHY 73 PINS AND NOT 19. The eleven analogue signals and the two supplies are one
pin each. Each of the six `bidirectional` ones is a gf180mcu_fd_io__bi_t, and
that pad brings its whole control interface into the user area:

    <sig>_OUT   -> cell terminal A      the data WE drive into the pad
    <sig>_IN    -> cell terminal Y      what the pad receives; unused here
    <sig>_OE _IE _PU _PD _CS _SL _PDRV0 _PDRV1   the programming pins

Careful with the names: `_OUT` is the pad's terminal A, i.e. its data INPUT.
It is the opposite of what the name suggests.

The padring ties NONE of them: B26_A_padring.v leaves W16_OE, W16_CS and the
rest as loose nets that come into our area. They are ours to drive, and for six
permanent outputs the PDK truth table (gf180mcu_fd_io section 4.2) gives:

    OE = 1        output always enabled; with OE=1, PU and PD are don't care
    IE = 0        receiver off
    PU = PD = 0   no pull resistor
    PDRV0 = PDRV1 = 0    lowest drive, 4 mA, plenty for a test point
    SL = 0        slow slew, less noise injected into an analogue chip
    CS = 0        plain CMOS input (moot with IE=0)
