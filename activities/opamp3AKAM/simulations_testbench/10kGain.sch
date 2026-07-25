v {xschem version=3.4.8RC file_version=1.3}
G {}
K {}
V {}
S {}
F {}
E {}
N 80 -30 100 -30 {lab=#net1}
N 100 -50 100 -30 {lab=#net1}
N 100 -50 140 -50 {lab=#net1}
N 80 -10 100 -10 {lab=#net2}
N 100 -10 110 -10 {lab=#net2}
N 110 -30 110 -10 {lab=#net2}
N 110 -30 140 -30 {lab=#net2}
N 80 10 110 10 {lab=#net3}
N 110 10 110 30 {lab=#net3}
N 110 30 140 30 {lab=#net3}
N 80 30 100 30 {lab=#net4}
N 100 30 100 50 {lab=#net4}
N -600 260 -600 290 {lab=0}
N -600 140 -600 200 {lab=VSS}
N -520 260 -520 290 {lab=0}
N -520 140 -520 200 {lab=VDD}
N -430 260 -430 290 {lab=0}
N -430 140 -430 200 {lab=VINN}
N -570 490 -570 520 {lab=0}
N -570 370 -570 430 {lab=VINP1}
N 80 -80 80 -50 {lab=VDD}
N 80 50 80 90 {lab=VSS}
N 140 30 180 30 {lab=#net3}
N 130 50 180 50 {lab=#net4}
N 140 -30 180 -30 {lab=#net2}
N 140 -50 180 -50 {lab=#net1}
N 100 50 130 50 {lab=#net4}
N 480 -80 480 -50 {lab=VDD}
N 480 -10 480 30 {lab=VSS}
N 260 260 290 260 {lab=VINN}
N 270 220 270 260 {lab=VINN}
N 270 200 270 220 {lab=VINN}
N 30 260 40 260 {lab=VSS}
N 150 310 150 340 {lab=VINP2}
N 400 310 400 340 {lab=VINP4}
N 400 190 400 210 {lab=VINP3}
N 150 190 150 210 {lab=VINP1}
N -240 260 -240 290 {lab=0}
N -240 140 -240 200 {lab=INPUT}
N -340 490 -340 520 {lab=0}
N -340 370 -340 430 {lab=VINP3}
N -440 480 -440 510 {lab=0}
N -440 360 -440 420 {lab=VINP2}
N -240 480 -240 510 {lab=0}
N -240 360 -240 420 {lab=VINP4}
C {/foss/designs/sscs-2026-zotnetic/activities/opamp2AKAM/bias.sym} -70 0 0 0 {name=x1}
C {/foss/designs/sscs-2026-zotnetic/activities/opamp2AKAM/opamp.sym} 330 0 0 0 {name=x2}
C {vsource.sym} -600 230 0 0 {name=V1 value=0 savecurrent=false}
C {gnd.sym} -600 290 0 0 {name=l1 lab=0}
C {lab_pin.sym} -600 150 0 0 {name=p5 sig_type=std_logic lab=VSS}
C {vsource.sym} -520 230 0 0 {name=V2 value=5 savecurrent=false}
C {gnd.sym} -520 290 0 0 {name=l2 lab=0}
C {lab_pin.sym} -520 150 0 0 {name=p6 sig_type=std_logic lab=VDD}
C {vsource.sym} -430 230 0 0 {name=V3 value=0 savecurrent=false}
C {gnd.sym} -430 290 0 0 {name=l3 lab=0}
C {lab_pin.sym} -430 150 0 0 {name=p7 sig_type=std_logic lab=VINN}
C {vsource.sym} -570 460 0 0 {name=V4 value=4.5 savecurrent=false}
C {gnd.sym} -570 520 0 0 {name=l4 lab=0}
C {lab_pin.sym} -570 380 0 0 {name=p8 sig_type=std_logic lab=VINP1}
C {lab_pin.sym} 80 -80 0 0 {name=p1 sig_type=std_logic lab=VDD}
C {lab_pin.sym} 80 90 0 0 {name=p2 sig_type=std_logic lab=VSS}
C {lab_pin.sym} 180 -10 0 0 {name=p4 sig_type=std_logic lab=VINN}
C {lab_pin.sym} 480 -80 2 0 {name=p9 sig_type=std_logic lab=VDD}
C {lab_pin.sym} 480 30 2 0 {name=p10 sig_type=std_logic lab=VSS}
C {lab_pin.sym} 480 -30 2 0 {name=p14 sig_type=std_logic lab=output}
C {lab_pin.sym} 270 200 0 0 {name=p11 sig_type=std_logic lab=VINN}
C {lab_pin.sym} 30 260 0 0 {name=p12 sig_type=std_logic lab=VSS}
C {lab_pin.sym} 510 260 2 0 {name=p13 sig_type=std_logic lab=output}
C {vsource.sym} -240 230 0 0 {name=V5 value=2.5 savecurrent=false}
C {gnd.sym} -240 290 0 0 {name=l5 lab=0}
C {lab_pin.sym} -240 150 0 0 {name=p19 sig_type=std_logic lab=INPUT}
C {lab_pin.sym} 180 10 0 0 {name=p20 sig_type=std_logic lab=INPUT}
C {code_shown.sym} 630 -50 0 0 {name=NGSPICE 
only_toplevel=false 
value="

.control
dc V5 0 5 0.001
plot v(output) vs v(INPUT)
.endc
"}
C {code_shown.sym} -610 -230 0 0 {name=MODELS only_toplevel=false value=".include /foss/pdks/gf180mcuD/libs.tech/ngspice/design.ngspice
.lib /foss/pdks/gf180mcuD/libs.tech/ngspice/sm141064.ngspice typical
.lib /foss/pdks/gf180mcuD/libs.tech/ngspice/smbb000149.ngspice typical
.lib /foss/pdks/gf180mcuD/libs.tech/ngspice/sm141064.ngspice cap_mim
.lib /foss/pdks/gf180mcuD/libs.tech/ngspice/sm141064.ngspice mimcap_typical"}
C {/foss/designs/sscs-2026-zotnetic/activities/opamp3AKAM/simulations_testbench/9k.sym} 420 260 2 0 {name=x5}
C {/foss/designs/sscs-2026-zotnetic/activities/opamp3AKAM/simulations_testbench/1k.sym} 190 260 2 0 {name=x3}
C {vsource.sym} -340 460 0 0 {name=V6 value=4.5 savecurrent=false}
C {gnd.sym} -340 520 0 0 {name=l6 lab=0}
C {lab_pin.sym} -340 380 0 0 {name=p3 sig_type=std_logic lab=VINP3}
C {vsource.sym} -440 450 0 0 {name=V7 value=4.5 savecurrent=false}
C {gnd.sym} -440 510 0 0 {name=l7 lab=0}
C {lab_pin.sym} -440 370 0 0 {name=p21 sig_type=std_logic lab=VINP2}
C {vsource.sym} -240 450 0 0 {name=V8 value=4.5 savecurrent=false}
C {gnd.sym} -240 510 0 0 {name=l8 lab=0}
C {lab_pin.sym} -240 370 0 0 {name=p22 sig_type=std_logic lab=VINP4}
C {lab_pin.sym} 150 190 0 0 {name=p23 sig_type=std_logic lab=VINP1}
C {lab_pin.sym} 400 190 0 0 {name=p24 sig_type=std_logic lab=VINP3}
C {lab_pin.sym} 150 340 0 0 {name=p25 sig_type=std_logic lab=VINP2}
C {lab_pin.sym} 400 340 0 0 {name=p26 sig_type=std_logic lab=VINP4}
