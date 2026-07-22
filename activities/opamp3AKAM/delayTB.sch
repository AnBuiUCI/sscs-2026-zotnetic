v {xschem version=3.4.8RC file_version=1.3}
G {}
K {}
V {}
S {}
F {}
E {}
N -400 130 -400 160 {lab=0}
N -400 10 -400 70 {lab=VSS}
N -320 130 -320 160 {lab=0}
N -320 10 -320 70 {lab=VDD}
N 10 40 10 80 {lab=VSS}
N 10 80 10 90 {lab=VSS}
N 10 -90 10 -60 {lab=VDD}
N -230 130 -230 160 {lab=0}
N -230 10 -230 70 {lab=B}
N -150 130 -150 160 {lab=0}
N -150 10 -150 70 {lab=A}
C {/foss/designs/sscs-2026-zotnetic/activities/opamp3AKAM/andGate.sym} 30 10 0 0 {name=x1}
C {vsource.sym} -400 100 0 0 {name=V1 value=0 savecurrent=false}
C {gnd.sym} -400 160 0 0 {name=l1 lab=0}
C {lab_pin.sym} -400 20 0 0 {name=p2 sig_type=std_logic lab=VSS}
C {vsource.sym} -320 100 0 0 {name=V2 value=5 savecurrent=false}
C {gnd.sym} -320 160 0 0 {name=l2 lab=0}
C {lab_pin.sym} -320 20 0 0 {name=p4 sig_type=std_logic lab=VDD}
C {lab_pin.sym} 10 -90 0 0 {name=p1 sig_type=std_logic lab=VDD}
C {lab_pin.sym} 10 90 0 0 {name=p3 sig_type=std_logic lab=VSS}
C {vsource.sym} -230 100 0 0 {name=V3 value=5 savecurrent=false}
C {gnd.sym} -230 160 0 0 {name=l3 lab=0}
C {lab_pin.sym} -230 20 0 0 {name=p5 sig_type=std_logic lab=B}
C {vsource.sym} -150 100 0 0 {name=V4 value=PULSE(0,5,5n,0.1n,0.1n,10n,20n) savecurrent=false}
C {gnd.sym} -150 160 0 0 {name=l4 lab=0}
C {lab_pin.sym} -150 20 0 0 {name=p6 sig_type=std_logic lab=A}
C {lab_pin.sym} -30 10 0 0 {name=p7 sig_type=std_logic lab=B}
C {lab_pin.sym} -30 -30 0 0 {name=p8 sig_type=std_logic lab=A}
C {code_shown.sym} -480 -190 0 0 {name=MODELS only_toplevel=false value=".include /foss/pdks/gf180mcuD/libs.tech/ngspice/design.ngspice
.lib /foss/pdks/gf180mcuD/libs.tech/ngspice/sm141064.ngspice typical"}
C {code_shown.sym} 270 0 0 0 {name=NGSPICE 
only_toplevel=false 
value="

.control
tran .01n 20n
meas tran tpdr TRIG v(A) VAL='5/2' RISE=1 TARG v(output) VAL='5/2' RISE=1
meas tran tpdf TRIG v(A) VAL='5/2' FALL=1 TARG v(output) VAL='5/2' FALL=1

let tpd=(tpdr+tpdf)/2
print tpdr tpdf tpd
plot v(A) v(output)

.endc
"}
C {lab_pin.sym} 60 -10 2 0 {name=p9 sig_type=std_logic lab=output}
