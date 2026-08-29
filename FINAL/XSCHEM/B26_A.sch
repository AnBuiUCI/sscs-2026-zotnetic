v {xschem version=3.4.8RC file_version=1.3}
G {}
K {}
V {}
S {}
F {}
E {}
C {devices/code_shown.sym} -1400 -700 0 0 {name=NOTA only_toplevel=false
value="
* B26_A -- the padring user area: the block plus its secondary ESD.
*
* THIS IS NOT THE BLOCK. GRADIENT_NAV2 has NO secondary protection inside
* it any more; the eleven io_secondary_5p0 cells live HERE, one per
* analogue pin, out in the 1110 x 1110 um user area next to the pad they
* protect. That is where a secondary ESD belongs -- the shorter the path
* from pad to clamp to gate, the better it works -- and out here the area
* is free: the eleven take 71,027 um2 of the 1,047,158 that were empty,
* 6.8 percent, where inside the block they would have grown it by 35.
*
* So there are two schematics and two LVS references, each against its own
* GDS:
*
*   XSCHEM/GRADIENT_NAV2.sch -> out_v2_GRADIENT_NAV2/GRADIENT_NAV2_lvs.spice
*                               against GRADIENT_NAV2_decap.gds, no ESD
*   XSCHEM/B26_A.sch         -> out_integration/B26_A_lvs.spice
*                               against B26_A.gds, with the eleven cells
*
* WRITTEN BY HAND, from the symbols pin offsets. The 42 tie-off pins that
* program the six digital pads are NOT here: they are wires, not devices,
* and a SPICE port list cannot say that 43 names are one node. They live
* in verilog/B26_A.v, which integrate_padframe.py derives from this file.
"}
C {a_zonetic2026/XSCHEM/GRADIENT_NAV2.sym} 0 0 0 0 {name=x_core}
C {lab_pin.sym} 0 -130 1 0 {name=p_core_VDD sig_type=std_logic lab=VDD}
C {lab_pin.sym} 0 90 1 0 {name=p_core_VSS sig_type=std_logic lab=VSS}
C {lab_pin.sym} 150 -100 0 0 {name=p_core_XP sig_type=std_logic lab=XP_OUT}
C {lab_pin.sym} 150 -80 0 0 {name=p_core_X sig_type=std_logic lab=X_I}
C {lab_pin.sym} 150 -60 0 0 {name=p_core_XN sig_type=std_logic lab=XN_OUT}
C {lab_pin.sym} 150 -40 0 0 {name=p_core_YP sig_type=std_logic lab=YP_OUT}
C {lab_pin.sym} 150 -20 0 0 {name=p_core_Y sig_type=std_logic lab=Y_I}
C {lab_pin.sym} 150 0 0 0 {name=p_core_YN sig_type=std_logic lab=YN_OUT}
C {lab_pin.sym} 150 20 0 0 {name=p_core_ZP sig_type=std_logic lab=ZP_OUT}
C {lab_pin.sym} 150 40 0 0 {name=p_core_Z sig_type=std_logic lab=Z_I}
C {lab_pin.sym} 150 60 0 0 {name=p_core_ZN sig_type=std_logic lab=ZN_OUT}
C {lab_pin.sym} -150 -60 0 0 {name=p_core_S2P sig_type=std_logic lab=S2P_I}
C {lab_pin.sym} -150 -40 0 0 {name=p_core_S2N sig_type=std_logic lab=S2N_I}
C {lab_pin.sym} -150 40 0 0 {name=p_core_S4P sig_type=std_logic lab=S4P_I}
C {lab_pin.sym} -150 60 0 0 {name=p_core_S4N sig_type=std_logic lab=S4N_I}
C {lab_pin.sym} -150 0 0 0 {name=p_core_S3P sig_type=std_logic lab=S3P_I}
C {lab_pin.sym} -150 20 0 0 {name=p_core_S3N sig_type=std_logic lab=S3N_I}
C {lab_pin.sym} -150 -100 0 0 {name=p_core_S1P sig_type=std_logic lab=S1P_I}
C {lab_pin.sym} -150 -80 0 0 {name=p_core_S1N sig_type=std_logic lab=S1N_I}
C {a_zonetic2026/XSCHEM_v2/io_secondary_5p0.sym} -900 -700 0 0 {name=x_esd_S1P}
C {lab_pin.sym} -820 -860 0 0 {name=p_esd_S1P_VDD sig_type=std_logic lab=VDD}
C {lab_pin.sym} -900 -780 0 0 {name=p_esd_S1P_to_gate sig_type=std_logic lab=S1P_I}
C {lab_pin.sym} -700 -780 0 0 {name=p_esd_S1P_ASIG5V sig_type=std_logic lab=S1P}
C {lab_pin.sym} -820 -700 0 0 {name=p_esd_S1P_VSS sig_type=std_logic lab=VSS}
C {a_zonetic2026/XSCHEM_v2/io_secondary_5p0.sym} -900 -480 0 0 {name=x_esd_S1N}
C {lab_pin.sym} -820 -640 0 0 {name=p_esd_S1N_VDD sig_type=std_logic lab=VDD}
C {lab_pin.sym} -900 -560 0 0 {name=p_esd_S1N_to_gate sig_type=std_logic lab=S1N_I}
C {lab_pin.sym} -700 -560 0 0 {name=p_esd_S1N_ASIG5V sig_type=std_logic lab=S1N}
C {lab_pin.sym} -820 -480 0 0 {name=p_esd_S1N_VSS sig_type=std_logic lab=VSS}
C {a_zonetic2026/XSCHEM_v2/io_secondary_5p0.sym} -900 -260 0 0 {name=x_esd_S2P}
C {lab_pin.sym} -820 -420 0 0 {name=p_esd_S2P_VDD sig_type=std_logic lab=VDD}
C {lab_pin.sym} -900 -340 0 0 {name=p_esd_S2P_to_gate sig_type=std_logic lab=S2P_I}
C {lab_pin.sym} -700 -340 0 0 {name=p_esd_S2P_ASIG5V sig_type=std_logic lab=S2P}
C {lab_pin.sym} -820 -260 0 0 {name=p_esd_S2P_VSS sig_type=std_logic lab=VSS}
C {a_zonetic2026/XSCHEM_v2/io_secondary_5p0.sym} -900 -40 0 0 {name=x_esd_S2N}
C {lab_pin.sym} -820 -200 0 0 {name=p_esd_S2N_VDD sig_type=std_logic lab=VDD}
C {lab_pin.sym} -900 -120 0 0 {name=p_esd_S2N_to_gate sig_type=std_logic lab=S2N_I}
C {lab_pin.sym} -700 -120 0 0 {name=p_esd_S2N_ASIG5V sig_type=std_logic lab=S2N}
C {lab_pin.sym} -820 -40 0 0 {name=p_esd_S2N_VSS sig_type=std_logic lab=VSS}
C {a_zonetic2026/XSCHEM_v2/io_secondary_5p0.sym} -900 180 0 0 {name=x_esd_S3P}
C {lab_pin.sym} -820 20 0 0 {name=p_esd_S3P_VDD sig_type=std_logic lab=VDD}
C {lab_pin.sym} -900 100 0 0 {name=p_esd_S3P_to_gate sig_type=std_logic lab=S3P_I}
C {lab_pin.sym} -700 100 0 0 {name=p_esd_S3P_ASIG5V sig_type=std_logic lab=S3P}
C {lab_pin.sym} -820 180 0 0 {name=p_esd_S3P_VSS sig_type=std_logic lab=VSS}
C {a_zonetic2026/XSCHEM_v2/io_secondary_5p0.sym} -900 400 0 0 {name=x_esd_S3N}
C {lab_pin.sym} -820 240 0 0 {name=p_esd_S3N_VDD sig_type=std_logic lab=VDD}
C {lab_pin.sym} -900 320 0 0 {name=p_esd_S3N_to_gate sig_type=std_logic lab=S3N_I}
C {lab_pin.sym} -700 320 0 0 {name=p_esd_S3N_ASIG5V sig_type=std_logic lab=S3N}
C {lab_pin.sym} -820 400 0 0 {name=p_esd_S3N_VSS sig_type=std_logic lab=VSS}
C {a_zonetic2026/XSCHEM_v2/io_secondary_5p0.sym} -900 620 0 0 {name=x_esd_S4P}
C {lab_pin.sym} -820 460 0 0 {name=p_esd_S4P_VDD sig_type=std_logic lab=VDD}
C {lab_pin.sym} -900 540 0 0 {name=p_esd_S4P_to_gate sig_type=std_logic lab=S4P_I}
C {lab_pin.sym} -700 540 0 0 {name=p_esd_S4P_ASIG5V sig_type=std_logic lab=S4P}
C {lab_pin.sym} -820 620 0 0 {name=p_esd_S4P_VSS sig_type=std_logic lab=VSS}
C {a_zonetic2026/XSCHEM_v2/io_secondary_5p0.sym} -900 840 0 0 {name=x_esd_S4N}
C {lab_pin.sym} -820 680 0 0 {name=p_esd_S4N_VDD sig_type=std_logic lab=VDD}
C {lab_pin.sym} -900 760 0 0 {name=p_esd_S4N_to_gate sig_type=std_logic lab=S4N_I}
C {lab_pin.sym} -700 760 0 0 {name=p_esd_S4N_ASIG5V sig_type=std_logic lab=S4N}
C {lab_pin.sym} -820 840 0 0 {name=p_esd_S4N_VSS sig_type=std_logic lab=VSS}
C {a_zonetic2026/XSCHEM_v2/io_secondary_5p0.sym} -900 1060 0 0 {name=x_esd_X}
C {lab_pin.sym} -820 900 0 0 {name=p_esd_X_VDD sig_type=std_logic lab=VDD}
C {lab_pin.sym} -900 980 0 0 {name=p_esd_X_to_gate sig_type=std_logic lab=X_I}
C {lab_pin.sym} -700 980 0 0 {name=p_esd_X_ASIG5V sig_type=std_logic lab=X}
C {lab_pin.sym} -820 1060 0 0 {name=p_esd_X_VSS sig_type=std_logic lab=VSS}
C {a_zonetic2026/XSCHEM_v2/io_secondary_5p0.sym} -900 1280 0 0 {name=x_esd_Y}
C {lab_pin.sym} -820 1120 0 0 {name=p_esd_Y_VDD sig_type=std_logic lab=VDD}
C {lab_pin.sym} -900 1200 0 0 {name=p_esd_Y_to_gate sig_type=std_logic lab=Y_I}
C {lab_pin.sym} -700 1200 0 0 {name=p_esd_Y_ASIG5V sig_type=std_logic lab=Y}
C {lab_pin.sym} -820 1280 0 0 {name=p_esd_Y_VSS sig_type=std_logic lab=VSS}
C {a_zonetic2026/XSCHEM_v2/io_secondary_5p0.sym} -900 1500 0 0 {name=x_esd_Z}
C {lab_pin.sym} -820 1340 0 0 {name=p_esd_Z_VDD sig_type=std_logic lab=VDD}
C {lab_pin.sym} -900 1420 0 0 {name=p_esd_Z_to_gate sig_type=std_logic lab=Z_I}
C {lab_pin.sym} -700 1420 0 0 {name=p_esd_Z_ASIG5V sig_type=std_logic lab=Z}
C {lab_pin.sym} -820 1500 0 0 {name=p_esd_Z_VSS sig_type=std_logic lab=VSS}
C {devices/ipin.sym} -1600 -800 0 0 {name=port_S1P lab=S1P}
C {devices/ipin.sym} -1600 -780 0 0 {name=port_S1N lab=S1N}
C {devices/ipin.sym} -1600 -760 0 0 {name=port_S2P lab=S2P}
C {devices/ipin.sym} -1600 -740 0 0 {name=port_S2N lab=S2N}
C {devices/ipin.sym} -1600 -720 0 0 {name=port_S3P lab=S3P}
C {devices/ipin.sym} -1600 -700 0 0 {name=port_S3N lab=S3N}
C {devices/ipin.sym} -1600 -680 0 0 {name=port_S4P lab=S4P}
C {devices/ipin.sym} -1600 -660 0 0 {name=port_S4N lab=S4N}
C {devices/opin.sym} -1600 -640 0 0 {name=port_XP_OUT lab=XP_OUT}
C {devices/opin.sym} -1600 -620 0 0 {name=port_X lab=X}
C {devices/opin.sym} -1600 -600 0 0 {name=port_XN_OUT lab=XN_OUT}
C {devices/opin.sym} -1600 -580 0 0 {name=port_YP_OUT lab=YP_OUT}
C {devices/opin.sym} -1600 -560 0 0 {name=port_Y lab=Y}
C {devices/opin.sym} -1600 -540 0 0 {name=port_YN_OUT lab=YN_OUT}
C {devices/opin.sym} -1600 -520 0 0 {name=port_ZP_OUT lab=ZP_OUT}
C {devices/opin.sym} -1600 -500 0 0 {name=port_Z lab=Z}
C {devices/opin.sym} -1600 -480 0 0 {name=port_ZN_OUT lab=ZN_OUT}
C {devices/iopin.sym} -1600 -460 0 0 {name=port_VDD lab=VDD}
C {devices/iopin.sym} -1600 -440 0 0 {name=port_VSS lab=VSS}
C {devices/code_shown.sym} 700 700 0 0 {name=DESACOPLE only_toplevel=true value="
* Decoupling capacitors: NMOS and PMOS in inversion dropped into
* the gaps between macros. WRITTEN BY scripts/decap_fill.py -- do
* not edit by hand: it must be exactly what is in the GDS.
XMdecn0 VSS VDD VSS VSS nfet_06v0 L=2.0u W=1.0u nf=1 m=1
XMdecn1 VSS VDD VSS VSS nfet_06v0 L=2.0u W=1.0u nf=1 m=1
XMdecn2 VSS VDD VSS VSS nfet_06v0 L=2.0u W=1.0u nf=1 m=1
XMdecn3 VSS VDD VSS VSS nfet_06v0 L=2.0u W=1.0u nf=1 m=1
XMdecn4 VSS VDD VSS VSS nfet_06v0 L=2.0u W=1.0u nf=1 m=1
XMdecn5 VSS VDD VSS VSS nfet_06v0 L=2.0u W=1.0u nf=1 m=1
XMdecn6 VSS VDD VSS VSS nfet_06v0 L=2.0u W=1.0u nf=1 m=1
XMdecn7 VSS VDD VSS VSS nfet_06v0 L=2.0u W=1.0u nf=1 m=1
XMdecn8 VSS VDD VSS VSS nfet_06v0 L=2.0u W=1.0u nf=1 m=1
XMdecn9 VSS VDD VSS VSS nfet_06v0 L=2.0u W=1.0u nf=1 m=1
XMdecn10 VSS VDD VSS VSS nfet_06v0 L=2.0u W=1.0u nf=1 m=1
XMdecn11 VSS VDD VSS VSS nfet_06v0 L=2.0u W=1.0u nf=1 m=1
XMdecn12 VSS VDD VSS VSS nfet_06v0 L=2.0u W=1.0u nf=1 m=1
XMdecp13 VDD VSS VDD VDD pfet_06v0 L=2.0u W=1.0u nf=1 m=1
XMdecp14 VDD VSS VDD VDD pfet_06v0 L=2.0u W=1.0u nf=1 m=1
XMdecp15 VDD VSS VDD VDD pfet_06v0 L=2.0u W=1.0u nf=1 m=1
XMdecp16 VDD VSS VDD VDD pfet_06v0 L=2.0u W=1.0u nf=1 m=1
XMdecp17 VDD VSS VDD VDD pfet_06v0 L=2.0u W=1.0u nf=1 m=1
XMdecp18 VDD VSS VDD VDD pfet_06v0 L=2.0u W=1.0u nf=1 m=1
XMdecp19 VDD VSS VDD VDD pfet_06v0 L=2.0u W=1.0u nf=1 m=1
XMdecp20 VDD VSS VDD VDD pfet_06v0 L=2.0u W=1.0u nf=1 m=1
XMdecp21 VDD VSS VDD VDD pfet_06v0 L=2.0u W=1.0u nf=1 m=1
XMdecp22 VDD VSS VDD VDD pfet_06v0 L=2.0u W=1.0u nf=1 m=1
XMdecp23 VDD VSS VDD VDD pfet_06v0 L=2.0u W=1.0u nf=1 m=1
XMdecp24 VDD VSS VDD VDD pfet_06v0 L=2.0u W=1.0u nf=1 m=1
XMdecn25 VSS VDD VSS VSS nfet_06v0 L=2.0u W=18.0u nf=1 m=1
XMdecn26 VSS VDD VSS VSS nfet_06v0 L=2.0u W=18.0u nf=1 m=1
XMdecn27 VSS VDD VSS VSS nfet_06v0 L=2.0u W=18.0u nf=1 m=1
XMdecp28 VDD VSS VDD VDD pfet_06v0 L=2.0u W=18.0u nf=1 m=1
XMdecp29 VDD VSS VDD VDD pfet_06v0 L=2.0u W=18.0u nf=1 m=1
XMdecn30 VSS VDD VSS VSS nfet_06v0 L=2.0u W=18.0u nf=1 m=1
XMdecn31 VSS VDD VSS VSS nfet_06v0 L=2.0u W=18.0u nf=1 m=1
XMdecn32 VSS VDD VSS VSS nfet_06v0 L=2.0u W=18.0u nf=1 m=1
XMdecp33 VDD VSS VDD VDD pfet_06v0 L=2.0u W=18.0u nf=1 m=1
XMdecp34 VDD VSS VDD VDD pfet_06v0 L=2.0u W=18.0u nf=1 m=1
XMdecn35 VSS VDD VSS VSS nfet_06v0 L=2.0u W=18.0u nf=1 m=1
XMdecn36 VSS VDD VSS VSS nfet_06v0 L=2.0u W=18.0u nf=1 m=1
XMdecn37 VSS VDD VSS VSS nfet_06v0 L=2.0u W=18.0u nf=1 m=1
XMdecp38 VDD VSS VDD VDD pfet_06v0 L=2.0u W=18.0u nf=1 m=1
XMdecp39 VDD VSS VDD VDD pfet_06v0 L=2.0u W=18.0u nf=1 m=1
XMdecn40 VSS VDD VSS VSS nfet_06v0 L=2.0u W=18.0u nf=1 m=1
XMdecn41 VSS VDD VSS VSS nfet_06v0 L=2.0u W=18.0u nf=1 m=1
XMdecp42 VDD VSS VDD VDD pfet_06v0 L=2.0u W=18.0u nf=1 m=1
XMdecp43 VDD VSS VDD VDD pfet_06v0 L=2.0u W=18.0u nf=1 m=1
XMdecn44 VSS VDD VSS VSS nfet_06v0 L=2.0u W=18.0u nf=1 m=1
XMdecn45 VSS VDD VSS VSS nfet_06v0 L=2.0u W=18.0u nf=1 m=1
XMdecp46 VDD VSS VDD VDD pfet_06v0 L=2.0u W=18.0u nf=1 m=1
XMdecp47 VDD VSS VDD VDD pfet_06v0 L=2.0u W=18.0u nf=1 m=1
XMdecn48 VSS VDD VSS VSS nfet_06v0 L=2.0u W=18.0u nf=1 m=1
XMdecn49 VSS VDD VSS VSS nfet_06v0 L=2.0u W=18.0u nf=1 m=1
XMdecp50 VDD VSS VDD VDD pfet_06v0 L=2.0u W=18.0u nf=1 m=1
XMdecp51 VDD VSS VDD VDD pfet_06v0 L=2.0u W=18.0u nf=1 m=1
XMdecn52 VSS VDD VSS VSS nfet_06v0 L=2.0u W=18.0u nf=1 m=1
XMdecn53 VSS VDD VSS VSS nfet_06v0 L=2.0u W=18.0u nf=1 m=1
XMdecp54 VDD VSS VDD VDD pfet_06v0 L=2.0u W=18.0u nf=1 m=1
XMdecp55 VDD VSS VDD VDD pfet_06v0 L=2.0u W=18.0u nf=1 m=1
XMdecn56 VSS VDD VSS VSS nfet_06v0 L=2.0u W=18.0u nf=1 m=1
XMdecn57 VSS VDD VSS VSS nfet_06v0 L=2.0u W=18.0u nf=1 m=1
XMdecp58 VDD VSS VDD VDD pfet_06v0 L=2.0u W=18.0u nf=1 m=1
XMdecp59 VDD VSS VDD VDD pfet_06v0 L=2.0u W=18.0u nf=1 m=1
XMdecn60 VSS VDD VSS VSS nfet_06v0 L=2.0u W=18.0u nf=1 m=1
XMdecn61 VSS VDD VSS VSS nfet_06v0 L=2.0u W=18.0u nf=1 m=1
XMdecp62 VDD VSS VDD VDD pfet_06v0 L=2.0u W=18.0u nf=1 m=1
XMdecp63 VDD VSS VDD VDD pfet_06v0 L=2.0u W=18.0u nf=1 m=1
XMdecn64 VSS VDD VSS VSS nfet_06v0 L=2.0u W=18.0u nf=1 m=1
XMdecn65 VSS VDD VSS VSS nfet_06v0 L=2.0u W=18.0u nf=1 m=1
XMdecp66 VDD VSS VDD VDD pfet_06v0 L=2.0u W=18.0u nf=1 m=1
XMdecp67 VDD VSS VDD VDD pfet_06v0 L=2.0u W=18.0u nf=1 m=1
XMdecn68 VSS VDD VSS VSS nfet_06v0 L=2.0u W=18.0u nf=1 m=1
XMdecn69 VSS VDD VSS VSS nfet_06v0 L=2.0u W=18.0u nf=1 m=1
XMdecp70 VDD VSS VDD VDD pfet_06v0 L=2.0u W=18.0u nf=1 m=1
XMdecp71 VDD VSS VDD VDD pfet_06v0 L=2.0u W=18.0u nf=1 m=1
XMdecn72 VSS VDD VSS VSS nfet_06v0 L=2.0u W=18.0u nf=1 m=1
XMdecn73 VSS VDD VSS VSS nfet_06v0 L=2.0u W=18.0u nf=1 m=1
XMdecp74 VDD VSS VDD VDD pfet_06v0 L=2.0u W=18.0u nf=1 m=1
XMdecp75 VDD VSS VDD VDD pfet_06v0 L=2.0u W=18.0u nf=1 m=1
XMdecn76 VSS VDD VSS VSS nfet_06v0 L=2.0u W=9.75u nf=1 m=1
XMdecn77 VSS VDD VSS VSS nfet_06v0 L=2.0u W=9.75u nf=1 m=1
XMdecp78 VDD VSS VDD VDD pfet_06v0 L=2.0u W=9.75u nf=1 m=1
XMdecp79 VDD VSS VDD VDD pfet_06v0 L=2.0u W=9.75u nf=1 m=1
XMdecn80 VSS VDD VSS VSS nfet_06v0 L=2.0u W=9.75u nf=1 m=1
XMdecn81 VSS VDD VSS VSS nfet_06v0 L=2.0u W=9.75u nf=1 m=1
XMdecp82 VDD VSS VDD VDD pfet_06v0 L=2.0u W=9.75u nf=1 m=1
XMdecp83 VDD VSS VDD VDD pfet_06v0 L=2.0u W=9.75u nf=1 m=1
XMdecn84 VSS VDD VSS VSS nfet_06v0 L=2.0u W=9.75u nf=1 m=1
XMdecn85 VSS VDD VSS VSS nfet_06v0 L=2.0u W=9.75u nf=1 m=1
XMdecp86 VDD VSS VDD VDD pfet_06v0 L=2.0u W=9.75u nf=1 m=1
XMdecp87 VDD VSS VDD VDD pfet_06v0 L=2.0u W=9.75u nf=1 m=1
XMdecn88 VSS VDD VSS VSS nfet_06v0 L=2.0u W=9.75u nf=1 m=1
XMdecn89 VSS VDD VSS VSS nfet_06v0 L=2.0u W=9.75u nf=1 m=1
XMdecp90 VDD VSS VDD VDD pfet_06v0 L=2.0u W=9.75u nf=1 m=1
XMdecp91 VDD VSS VDD VDD pfet_06v0 L=2.0u W=9.75u nf=1 m=1
XMdecn92 VSS VDD VSS VSS nfet_06v0 L=2.0u W=9.75u nf=1 m=1
XMdecn93 VSS VDD VSS VSS nfet_06v0 L=2.0u W=9.75u nf=1 m=1
XMdecp94 VDD VSS VDD VDD pfet_06v0 L=2.0u W=9.75u nf=1 m=1
XMdecp95 VDD VSS VDD VDD pfet_06v0 L=2.0u W=9.75u nf=1 m=1
XMdecn96 VSS VDD VSS VSS nfet_06v0 L=2.0u W=9.75u nf=1 m=1
XMdecn97 VSS VDD VSS VSS nfet_06v0 L=2.0u W=9.75u nf=1 m=1
XMdecp98 VDD VSS VDD VDD pfet_06v0 L=2.0u W=9.75u nf=1 m=1
XMdecp99 VDD VSS VDD VDD pfet_06v0 L=2.0u W=9.75u nf=1 m=1
XMdecn100 VSS VDD VSS VSS nfet_06v0 L=2.0u W=9.75u nf=1 m=1
XMdecn101 VSS VDD VSS VSS nfet_06v0 L=2.0u W=9.75u nf=1 m=1
XMdecp102 VDD VSS VDD VDD pfet_06v0 L=2.0u W=9.75u nf=1 m=1
XMdecp103 VDD VSS VDD VDD pfet_06v0 L=2.0u W=9.75u nf=1 m=1
XMdecn104 VSS VDD VSS VSS nfet_06v0 L=2.0u W=9.75u nf=1 m=1
XMdecn105 VSS VDD VSS VSS nfet_06v0 L=2.0u W=9.75u nf=1 m=1
XMdecp106 VDD VSS VDD VDD pfet_06v0 L=2.0u W=9.75u nf=1 m=1
XMdecp107 VDD VSS VDD VDD pfet_06v0 L=2.0u W=9.75u nf=1 m=1
XMdecn108 VSS VDD VSS VSS nfet_06v0 L=2.0u W=9.75u nf=1 m=1
XMdecn109 VSS VDD VSS VSS nfet_06v0 L=2.0u W=9.75u nf=1 m=1
XMdecp110 VDD VSS VDD VDD pfet_06v0 L=2.0u W=9.75u nf=1 m=1
XMdecp111 VDD VSS VDD VDD pfet_06v0 L=2.0u W=9.75u nf=1 m=1
XMdecn112 VSS VDD VSS VSS nfet_06v0 L=2.0u W=9.75u nf=1 m=1
XMdecn113 VSS VDD VSS VSS nfet_06v0 L=2.0u W=9.75u nf=1 m=1
XMdecp114 VDD VSS VDD VDD pfet_06v0 L=2.0u W=9.75u nf=1 m=1
XMdecp115 VDD VSS VDD VDD pfet_06v0 L=2.0u W=9.75u nf=1 m=1
XMdecn116 VSS VDD VSS VSS nfet_06v0 L=2.0u W=9.75u nf=1 m=1
XMdecn117 VSS VDD VSS VSS nfet_06v0 L=2.0u W=9.75u nf=1 m=1
XMdecp118 VDD VSS VDD VDD pfet_06v0 L=2.0u W=9.75u nf=1 m=1
XMdecp119 VDD VSS VDD VDD pfet_06v0 L=2.0u W=9.75u nf=1 m=1
XMdecn120 VSS VDD VSS VSS nfet_06v0 L=2.0u W=9.75u nf=1 m=1
XMdecn121 VSS VDD VSS VSS nfet_06v0 L=2.0u W=9.75u nf=1 m=1
XMdecp122 VDD VSS VDD VDD pfet_06v0 L=2.0u W=9.75u nf=1 m=1
XMdecp123 VDD VSS VDD VDD pfet_06v0 L=2.0u W=9.75u nf=1 m=1
XMdecn124 VSS VDD VSS VSS nfet_06v0 L=2.0u W=18.0u nf=1 m=1
XMdecp125 VDD VSS VDD VDD pfet_06v0 L=2.0u W=18.0u nf=1 m=1
XMdecn126 VSS VDD VSS VSS nfet_06v0 L=2.0u W=18.0u nf=1 m=1
XMdecp127 VDD VSS VDD VDD pfet_06v0 L=2.0u W=18.0u nf=1 m=1
XMdecn128 VSS VDD VSS VSS nfet_06v0 L=2.0u W=18.0u nf=1 m=1
XMdecp129 VDD VSS VDD VDD pfet_06v0 L=2.0u W=18.0u nf=1 m=1
XMdecn130 VSS VDD VSS VSS nfet_06v0 L=2.0u W=9.75u nf=1 m=1
XMdecp131 VDD VSS VDD VDD pfet_06v0 L=2.0u W=9.75u nf=1 m=1
XMdecn132 VSS VDD VSS VSS nfet_06v0 L=2.0u W=9.75u nf=1 m=1
XMdecp133 VDD VSS VDD VDD pfet_06v0 L=2.0u W=9.75u nf=1 m=1
XMdecn134 VSS VDD VSS VSS nfet_06v0 L=2.0u W=9.75u nf=1 m=1
XMdecp135 VDD VSS VDD VDD pfet_06v0 L=2.0u W=9.75u nf=1 m=1
XMdecn136 VSS VDD VSS VSS nfet_06v0 L=2.0u W=9.75u nf=1 m=1
XMdecp137 VDD VSS VDD VDD pfet_06v0 L=2.0u W=9.75u nf=1 m=1
XMdecn138 VSS VDD VSS VSS nfet_06v0 L=2.0u W=1.0u nf=1 m=1
XMdecn139 VSS VDD VSS VSS nfet_06v0 L=2.0u W=1.0u nf=1 m=1
XMdecp140 VDD VSS VDD VDD pfet_06v0 L=2.0u W=1.0u nf=1 m=1
XMdecp141 VDD VSS VDD VDD pfet_06v0 L=2.0u W=1.0u nf=1 m=1
XMdecn142 VSS VDD VSS VSS nfet_06v0 L=2.0u W=1.0u nf=1 m=1
XMdecn143 VSS VDD VSS VSS nfet_06v0 L=2.0u W=1.0u nf=1 m=1
XMdecp144 VDD VSS VDD VDD pfet_06v0 L=2.0u W=1.0u nf=1 m=1
XMdecp145 VDD VSS VDD VDD pfet_06v0 L=2.0u W=1.0u nf=1 m=1
XMdecn146 VSS VDD VSS VSS nfet_06v0 L=2.0u W=1.0u nf=1 m=1
XMdecn147 VSS VDD VSS VSS nfet_06v0 L=2.0u W=1.0u nf=1 m=1
XMdecp148 VDD VSS VDD VDD pfet_06v0 L=2.0u W=1.0u nf=1 m=1
XMdecp149 VDD VSS VDD VDD pfet_06v0 L=2.0u W=1.0u nf=1 m=1
XMdecn150 VSS VDD VSS VSS nfet_06v0 L=2.0u W=1.0u nf=1 m=1
XMdecp151 VDD VSS VDD VDD pfet_06v0 L=2.0u W=1.0u nf=1 m=1
XMdecn152 VSS VDD VSS VSS nfet_06v0 L=2.0u W=1.0u nf=1 m=1
XMdecp153 VDD VSS VDD VDD pfet_06v0 L=2.0u W=1.0u nf=1 m=1
XMdecn154 VSS VDD VSS VSS nfet_06v0 L=2.0u W=1.0u nf=1 m=1
XMdecp155 VDD VSS VDD VDD pfet_06v0 L=2.0u W=1.0u nf=1 m=1
"}
C {devices/ipin.sym} -2000 -2000 0 0 {name=port_XP_IN lab=XP_IN}
C {devices/ipin.sym} -2000 -2040 0 0 {name=port_XN_IN lab=XN_IN}
C {devices/ipin.sym} -2000 -2080 0 0 {name=port_YP_IN lab=YP_IN}
C {devices/ipin.sym} -2000 -2120 0 0 {name=port_YN_IN lab=YN_IN}
C {devices/ipin.sym} -2000 -2160 0 0 {name=port_ZP_IN lab=ZP_IN}
C {devices/ipin.sym} -2000 -2200 0 0 {name=port_ZN_IN lab=ZN_IN}
