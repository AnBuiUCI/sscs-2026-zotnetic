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
C {lab_pin.sym} 150 -100 0 0 {name=p_core_XP sig_type=std_logic lab=XP}
C {lab_pin.sym} 150 -80 0 0 {name=p_core_X sig_type=std_logic lab=X_I}
C {lab_pin.sym} 150 -60 0 0 {name=p_core_XN sig_type=std_logic lab=XN}
C {lab_pin.sym} 150 -40 0 0 {name=p_core_YP sig_type=std_logic lab=YP}
C {lab_pin.sym} 150 -20 0 0 {name=p_core_Y sig_type=std_logic lab=Y_I}
C {lab_pin.sym} 150 0 0 0 {name=p_core_YN sig_type=std_logic lab=YN}
C {lab_pin.sym} 150 20 0 0 {name=p_core_ZP sig_type=std_logic lab=ZP}
C {lab_pin.sym} 150 40 0 0 {name=p_core_Z sig_type=std_logic lab=Z_I}
C {lab_pin.sym} 150 60 0 0 {name=p_core_ZN sig_type=std_logic lab=ZN}
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
C {devices/opin.sym} -1600 -640 0 0 {name=port_XP lab=XP}
C {devices/opin.sym} -1600 -620 0 0 {name=port_X lab=X}
C {devices/opin.sym} -1600 -600 0 0 {name=port_XN lab=XN}
C {devices/opin.sym} -1600 -580 0 0 {name=port_YP lab=YP}
C {devices/opin.sym} -1600 -560 0 0 {name=port_Y lab=Y}
C {devices/opin.sym} -1600 -540 0 0 {name=port_YN lab=YN}
C {devices/opin.sym} -1600 -520 0 0 {name=port_ZP lab=ZP}
C {devices/opin.sym} -1600 -500 0 0 {name=port_Z lab=Z}
C {devices/opin.sym} -1600 -480 0 0 {name=port_ZN lab=ZN}
C {devices/iopin.sym} -1600 -460 0 0 {name=port_VDD lab=VDD}
C {devices/iopin.sym} -1600 -440 0 0 {name=port_VSS lab=VSS}
