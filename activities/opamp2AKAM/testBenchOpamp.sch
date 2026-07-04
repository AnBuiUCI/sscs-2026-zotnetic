v {xschem version=3.4.7 file_version=1.2}
G {}
K {}
V {}
S {}
E {}
N 30 -160 70 -160 {lab=bias1}
N 30 -140 70 -140 {lab=bias2}
N 30 -80 70 -80 {lab=bias3}
N 30 -60 70 -60 {lab=bias4}
N -470 60 -410 60 {lab=bias1}
N -260 10 -260 60 {lab=bias2}
N -140 10 -140 60 {lab=bias3}
N -10 10 -10 60 {lab=bias4}
N -470 120 -410 120 {lab=GND}
N -260 120 -260 150 {lab=GND}
N -140 120 -140 150 {lab=GND}
N -10 120 -10 150 {lab=GND}
N -230 -120 -230 -90 {lab=GND}
N -320 -120 -320 -90 {lab=GND}
N -230 -220 -230 -180 {lab=VSS}
N -320 -220 -320 -180 {lab=VDD}
N 370 -160 400 -160 {lab=VDD}
N 370 -120 400 -120 {lab=VSS}
N 140 110 140 140 {lab=GND}
N 270 110 270 140 {lab=GND}
N 140 0 140 50 {lab=vinn}
N 270 0 270 50 {lab=vinp}
N 30 -120 80 -120 {lab=vinn}
N 20 -100 70 -100 {lab=vinp}
N 370 -140 400 -140 {lab=#net1}
N -410 10 -410 60 {lab=bias1}
N -410 120 -410 150 {lab=GND}
C {vsource.sym} -470 90 0 0 {name=V1 value=PAR_bias1 savecurrent=false}
C {vsource.sym} -260 90 0 0 {name=V2 value=PAR_bias2 savecurrent=false}
C {vsource.sym} -140 90 0 0 {name=V3 value=PAR_bias3 savecurrent=false}
C {vsource.sym} -10 90 0 0 {name=V4 value=PAR_bias4 savecurrent=false}
C {lab_pin.sym} 30 -160 0 0 {name=p1 sig_type=std_logic lab=bias1}
C {lab_pin.sym} 30 -140 0 0 {name=p2 sig_type=std_logic lab=bias2}
C {lab_pin.sym} 30 -80 0 0 {name=p3 sig_type=std_logic lab=bias3}
C {lab_pin.sym} 30 -60 0 0 {name=p4 sig_type=std_logic lab=bias4}
C {lab_pin.sym} -410 20 0 0 {name=p5 sig_type=std_logic lab=bias1}
C {lab_pin.sym} -260 20 0 0 {name=p6 sig_type=std_logic lab=bias2}
C {lab_pin.sym} -140 20 0 0 {name=p7 sig_type=std_logic lab=bias3}
C {lab_pin.sym} -10 20 0 0 {name=p8 sig_type=std_logic lab=bias4}
C {gnd.sym} -410 150 0 0 {name=l1 lab=GND}
C {gnd.sym} -260 150 0 0 {name=l2 lab=GND}
C {gnd.sym} -140 150 0 0 {name=l3 lab=GND}
C {gnd.sym} -10 150 0 0 {name=l4 lab=GND}
C {vsource.sym} -320 -150 0 0 {name=V5 value=5V savecurrent=false}
C {vsource.sym} -230 -150 0 0 {name=V6 value=0V savecurrent=false}
C {lab_pin.sym} 400 -160 2 0 {name=p9 sig_type=std_logic lab=VDD}
C {lab_pin.sym} 400 -120 2 0 {name=p10 sig_type=std_logic lab=VSS}
C {gnd.sym} -230 -90 0 0 {name=l5 lab=GND}
C {gnd.sym} -320 -90 0 0 {name=l6 lab=GND}
C {lab_pin.sym} -230 -210 2 0 {name=p11 sig_type=std_logic lab=VSS}
C {lab_pin.sym} -320 -210 2 0 {name=p12 sig_type=std_logic lab=VDD}
C {vsource.sym} 140 80 0 0 {name=V8 value=PAR_vinn savecurrent=false}
C {vsource.sym} 270 80 0 0 {name=V9 value=PAR_vinp savecurrent=false}
C {gnd.sym} 140 140 0 0 {name=l7 lab=GND}
C {gnd.sym} 270 140 0 0 {name=l8 lab=GND}
C {lab_pin.sym} 140 10 0 0 {name=p13 sig_type=std_logic lab=vinn}
C {lab_pin.sym} 270 10 0 0 {name=p14 sig_type=std_logic lab=vinp}
C {lab_pin.sym} 30 -120 0 0 {name=p15 sig_type=std_logic lab=vinn}
C {lab_pin.sym} 20 -100 0 0 {name=p16 sig_type=std_logic lab=vinp}
C {lab_pin.sym} 500 -140 2 0 {name=p17 sig_type=std_logic lab=VSS}
C {code_shown.sym} -570 -320 0 0 {name=MODELS only_toplevel=false value=".include /foss/pdks/gf180mcuD/libs.tech/ngspice/design.ngspice
.lib /foss/pdks/gf180mcuD/libs.tech/ngspice/sm141064.ngspice typical
.lib /foss/pdks/gf180mcuD/libs.tech/ngspice/smbb000149.ngspice typical"}
C {sscs-2026-zotnetic/activities/opamp2AKAM/opamp.sym} 220 -110 0 0 {name=x1}
