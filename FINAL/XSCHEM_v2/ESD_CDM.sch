v {xschem version=3.4.8RC file_version=1.3}
G {}
K {}
V {}
S {}
F {}
E {}
C {devices/code_shown.sym} -200 -200 0 0 {name=RED only_toplevel=false
value="
* SECONDARY (CDM) ESD NETWORK -- one per analogue pin.
*
* The GF180MCU analogue pads carry HBM diodes ONLY. `gf180mcu_fd_io` section 4.5:
*
*   The analogue signal pads contain only HBM protection diodes. If they are
*   connected to input gates, the designer needs to include CDM protection
*   network near to these gates. [...] The perimeter of the CDM diode should be
*   larger than 25um. The CDM resistor should be larger than 50 ohm and should
*   be realized using appropriate poly resistor.
*
* So `secondary_esd: true` in info.yaml is about what WE put inside the block.
*
* WHY THESE TWO DIODE TYPES AND NOT FOUR. The first draft had a mirrored pair on
* each rail, but two of them cannot be built:
*
*   * `diode_nd2ps` has its ANODE IN THE P SUBSTRATE, and the substrate is VSS
*     everywhere on the die. An nd2ps with its anode on PAD would tie the signal
*     to the substrate.
*   * a `pd2nw` with its CATHODE on PAD leaves the n-well floating with the
*     signal, and hangs the whole well capacitance off the pin.
*
* What is left is the standard clamp, and it is doubled to keep four devices:
*
*   D1, D2  nd2ps  anode VSS (the substrate) -> cathode PAD : clamps below VSS
*   D3, D4  pd2nw  anode PAD -> cathode VDD (the n-well)    : clamps above VDD
*
* Each is 10 x 5 um, so pj = 2*(10+5) = 30 um against the 25 the PDK asks for,
* and there are two per direction: 60 um.
*
* R1..R5 are the series resistor: five 1 x 2 um bodies of high-sheet poly in
* PARALLEL, about 1.3 kohm. The floor the PDK sets is 50 ohm, so this is
* generous on purpose -- the pin drives a MOS gate, no DC flows, and the bridge
* outside is a 500 kohm Thevenin source, so a couple of kohm divide nothing,
* while more series resistance is less current into the gate during a CDM event.
*
* The model is `ppolyf_u_3k` and not the plain `ppolyf_u` of the first draft,
* because that is what the PDK can DRAW clean: measured on the PCells alone,
* `ppolyf_u_high_Rs_res` comes out with no violation of its own, while
* `ppolyf_res(ppolyf_u)` brings SB.4, PP.2 and PRES.7 with it. It is also the
* only resistor this project has ever taped out -- sixty of them in
* GRADIENT_NAV2.
*
* Five separate lines and not one with m=5: the layout draws five bodies and
* both LVS tools extract five devices, so the reference netlist says five.
D1 VSS PAD diode_nd2ps_06v0 AREA=50p PJ=30u
D2 VSS PAD diode_nd2ps_06v0 AREA=50p PJ=30u
D3 PAD VDD diode_pd2nw_06v0 AREA=50p PJ=30u
D4 PAD VDD diode_pd2nw_06v0 AREA=50p PJ=30u
XR1 CORE PAD VSS ppolyf_u_3k r_width=1e-6 r_length=2e-6 m=1 s=1
XR2 CORE PAD VSS ppolyf_u_3k r_width=1e-6 r_length=2e-6 m=1 s=1
XR3 CORE PAD VSS ppolyf_u_3k r_width=1e-6 r_length=2e-6 m=1 s=1
XR4 CORE PAD VSS ppolyf_u_3k r_width=1e-6 r_length=2e-6 m=1 s=1
XR5 CORE PAD VSS ppolyf_u_3k r_width=1e-6 r_length=2e-6 m=1 s=1
"}
C {devices/ipin.sym} -400 0 0 0 {name=p1 lab=PAD}
C {devices/opin.sym} 400 0 0 0 {name=p2 lab=CORE}
C {devices/iopin.sym} 0 -300 0 0 {name=p3 lab=VDD}
C {devices/iopin.sym} 0 300 0 0 {name=p4 lab=VSS}
