#!/usr/bin/env python3
"""dR/R to teslas: the one conversion, in one place, with its assumption stated.

Every bench in this project drives the bridges in **dR/R** -- the fractional
resistance change of one arm -- because that is what the circuit actually sees
and it keeps the electrical result independent of which sensor gets bolted on.
That is the right choice for designing the chip and the wrong one for talking
about it, because nobody has an intuition for 44 ppm.

Turning dR/R into teslas needs ONE number that is NOT a property of this chip:
the sensitivity of the magnetoresistive bridge in front of it. So it is a
parameter here, not a constant, and the reference part is named.

    Vdiff / VEXC = dR/R = S * B

`S` is the bridge sensitivity in (ΔR/R) per tesla. Taken from an AMR part in
the class this design assumes, the Honeywell HMC1001: **3.2 mV/V/Oe**. In SI,
1 Oe of H is 100 µT of B in air, so

    S = 3.2e-3 per Oe = 3.2e-3 per 100 µT = 32 ppm per µT = 32 (ΔR/R) / T

and the inverse, which is the number worth remembering:

    1 ppm of dR/R  =  31.25 nT

Two checks that the scaling is sane, both of which it passes:

  * full scale. The benches call dR/R = 2 % "what a typical AMR gives". That
    maps to 625 µT, and AMR bridges saturate somewhere around 0.5 to 1 mT.
  * the earth. 50 µT maps to 1600 ppm, comfortably inside the chip's range and
    well above its noise floor -- which is why the earth's field has to be
    treated as a background to reject, not as noise to ignore.

CHANGE THE SENSOR AND EVERY FIELD NUMBER IN THE REPORT MOVES. The dR/R numbers
do not: they are the chip. Anything printed in teslas carries this assumption
with it, and the figures say so on their axis.
"""

from __future__ import annotations

#: Bridge sensitivity, (ΔR/R) per tesla. HMC1001-class AMR, 3.2 mV/V/Oe.
S_POR_TESLA = 32.0
#: Same thing the way it gets used: ppm of dR/R per microtesla.
PPM_POR_UT = S_POR_TESLA
#: And its inverse, nanotesla per ppm.
NT_POR_PPM = 1e9 / (S_POR_TESLA * 1e6)

SENSOR = "AMR bridge at 3.2 mV/V/Oe (HMC1001 class)"
#: For axis labels, so the assumption travels with the number.
NOTA = f"dR/R → B assumes {SENSOR}: 1 ppm = {NT_POR_PPM:.1f} nT"


def a_tesla(drr: float) -> float:
    """dR/R (as a fraction, so 0.02 is 2 %) to teslas."""
    return drr / S_POR_TESLA


def a_ut(drr):
    """dR/R to microteslas. Works on numpy arrays too."""
    return drr / S_POR_TESLA * 1e6


def de_ut(ut):
    """Microteslas back to dR/R."""
    return ut * S_POR_TESLA / 1e6


#: The landmarks of this design, in both units. Kept here so no figure invents
#: its own conversion of a number that already has one.
HITOS = [
    ("noise floor, amplifier input-referred", 44.4e-6),
    ("smallest field the chain decides on", 50e-6),
    ("earth's field", de_ut(50.0)),
    ("sensing block still right in all octants", 0.0140),
    ("full scale a typical AMR gives", 0.0200),
]


if __name__ == "__main__":
    print(f"  {SENSOR}")
    print(f"  S = {S_POR_TESLA:.0f} (dR/R)/T   ·   1 ppm = {NT_POR_PPM:.2f} nT"
          f"   ·   1 uT = {PPM_POR_UT:.0f} ppm\n")
    print(f"  {'':44} {'dR/R':>12} {'campo':>14}")
    for nombre, drr in HITOS:
        ut = a_ut(drr)
        u = f"{ut:.2f} µT" if ut < 1000 else f"{ut / 1000:.3f} mT"
        print(f"  {nombre:44} {drr * 1e6:9.1f} ppm {u:>14}")
