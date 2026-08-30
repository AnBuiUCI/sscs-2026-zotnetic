v {xschem version=3.4.8RC file_version=1.3}
G {}
K {}
V {}
S {}
F {}
E {}
C {devices/code_shown.sym} -200 -200 0 0 {name=RED only_toplevel=false
value="
* io_secondary_5p0 -- THE ORGANISERS' SECONDARY ESD CELL, AS DRAWN.
*
* The layout is theirs and is adopted untouched: sscs-ose/sscs-chipathon-2026,
* commit aa834f5, resources/Integration/Chipathon2025_pads/magic/
* secondary_ESD.gds. It passes the sign-off DRC over 63 rule tables with 0
* violations and passes LVS against exactly what is written below. See
* layouts_v2/io_secondary_5p0/README_ORIGEN.txt.
*
* WHY THIS IS NOT A COPY OF THEIR SCHEMATIC. Their published .sch does not
* describe their own layout, and LVS compares geometry, not intent:
*
*   they declare        what is drawn, and what is here
*   ------------------  ------------------------------------------------------
*   m=4 on each diode   four explicit instances. KLayout's LVS does not expand
*                       a multiplier -- with m=4 it sees one device and four
*                       in the layout, and nothing matches.
*   ppolyf_u W=16u L=4u ppolyf_u W=40u L=10u. The RES_MK marker is 10 um across
*                       the current path by 40 um along the contact banks. Same
*                       0.25 squares and the same 87.5 ohm either way, but LVS
*                       compares W and L, not their ratio.
*
* And plain `ppolyf_u`, not `ppolyf_u_1k`: a RES_MK marker does not make a
* resistor high-sheet on its own. Measured on their cell -- the extraction says
* `ppolyf_u` at 350 ohm/sq, 87.5 ohm for 0.25 squares, over nwell.
*
* Report the discrepancy upstream. The drawing is the reference: it is what
* gets fabricated.
D1 to_gate VDD diode_pd2nw_06v0 A=100p P=40u
D2 to_gate VDD diode_pd2nw_06v0 A=100p P=40u
D3 to_gate VDD diode_pd2nw_06v0 A=100p P=40u
D4 to_gate VDD diode_pd2nw_06v0 A=100p P=40u
D5 VSS to_gate diode_nd2ps_06v0 A=100p P=40u
D6 VSS to_gate diode_nd2ps_06v0 A=100p P=40u
D7 VSS to_gate diode_nd2ps_06v0 A=100p P=40u
D8 VSS to_gate diode_nd2ps_06v0 A=100p P=40u
RR1 to_gate ASIG5V VDD ppolyf_u W=40e-6 L=10e-6
"}
C {devices/iopin.sym} 0 -300 0 0 {name=p1 lab=VDD}
C {devices/iopin.sym} 400 0 0 0 {name=p2 lab=to_gate}
C {devices/iopin.sym} -400 0 0 0 {name=p3 lab=ASIG5V}
C {devices/iopin.sym} 0 300 0 0 {name=p4 lab=VSS}
