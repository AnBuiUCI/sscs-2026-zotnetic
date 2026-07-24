v {xschem version=3.4.8RC file_version=1.3}
G {}
K {}
V {}
S {}
F {}
E {}
N -40 0 80 0 {lab=#net1}
N -120 -100 -120 -50 {lab=VDD}
N -120 -100 120 -100 {lab=VDD}
N 120 -100 120 -70 {lab=VDD}
N -120 50 -120 110 {lab=VSS}
N 120 30 120 90 {lab=VSS}
N -120 90 120 90 {lab=VSS}
N -590 240 -590 270 {lab=0}
N -590 120 -590 180 {lab=VSS}
N -510 240 -510 270 {lab=0}
N -510 120 -510 180 {lab=VDD}
N -420 240 -420 270 {lab=0}
N -420 120 -420 180 {lab=YZ}
N -340 240 -340 270 {lab=0}
N -340 120 -340 180 {lab=XY}
C {/foss/designs/sscs-2026-zotnetic/activities/opamp3AKAM/andGate.sym} 140 0 0 0 {name=x1}
C {/foss/designs/sscs-2026-zotnetic/activities/opamp3AKAM/invertor.sym} -140 10 0 0 {name=x2}
C {vsource.sym} -590 210 0 0 {name=V1 value=0 savecurrent=false}
C {gnd.sym} -590 270 0 0 {name=l1 lab=0}
C {lab_pin.sym} -590 130 0 0 {name=p5 sig_type=std_logic lab=VSS}
C {vsource.sym} -510 210 0 0 {name=V2 value=5 savecurrent=false}
C {gnd.sym} -510 270 0 0 {name=l2 lab=0}
C {lab_pin.sym} -510 130 0 0 {name=p6 sig_type=std_logic lab=VDD}
C {vsource.sym} -420 210 0 0 {name=V3 value=5 savecurrent=false}
C {gnd.sym} -420 270 0 0 {name=l3 lab=0}
C {lab_pin.sym} -420 130 0 0 {name=p7 sig_type=std_logic lab=YZ}
C {vsource.sym} -340 210 0 0 {name=V4 value=PULSE(0,5,5n,0.1n,0.1n,10n,20n) savecurrent=false}
C {gnd.sym} -340 270 0 0 {name=l4 lab=0}
C {lab_pin.sym} -340 130 0 0 {name=p8 sig_type=std_logic lab=XY}
C {code_shown.sym} -460 -250 0 0 {name=MODELS only_toplevel=false value=".include /foss/pdks/gf180mcuD/libs.tech/ngspice/design.ngspice
.lib /foss/pdks/gf180mcuD/libs.tech/ngspice/sm141064.ngspice typical"}
C {code_shown.sym} 290 -60 0 0 {name=NGSPICE 
only_toplevel=false 
value="

.control
tran .01n 25n
meas tran tpdr TRIG v(XY) VAL='5/2' RISE=1 TARG v(output) VAL='5/2' FALL=1
meas tran tpdf TRIG v(XY) VAL='5/2' FALL=1 TARG v(output) VAL='5/2' RISE=1

let tpd=(tpdr+tpdf)/2
print tpdr tpdf tpd
plot v(XY) v(output)

.endc
"}
C {lab_pin.sym} -120 110 0 0 {name=p9 sig_type=std_logic lab=VSS}
C {lab_pin.sym} -120 -100 0 0 {name=p11 sig_type=std_logic lab=VDD}
C {lab_pin.sym} 80 -40 0 0 {name=p12 sig_type=std_logic lab=YZ}
C {lab_pin.sym} -180 0 0 0 {name=p13 sig_type=std_logic lab=XY}
C {lab_pin.sym} 170 -20 2 0 {name=p1 sig_type=std_logic lab=output}
