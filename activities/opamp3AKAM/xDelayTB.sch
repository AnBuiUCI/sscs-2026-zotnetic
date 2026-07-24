v {xschem version=3.4.8RC file_version=1.3}
G {}
K {}
V {}
S {}
F {}
E {}
N -680 210 -680 240 {lab=0}
N -680 90 -680 150 {lab=VSS}
N -600 210 -600 240 {lab=0}
N -600 90 -600 150 {lab=VDD}
N -510 210 -510 240 {lab=0}
N -510 90 -510 150 {lab=XY}
N -430 210 -430 240 {lab=0}
N -430 90 -430 150 {lab=XZ}
N -240 -30 -240 0 {lab=VDD}
N -240 100 -240 160 {lab=VSS}
C {vsource.sym} -680 180 0 0 {name=V1 value=0 savecurrent=false}
C {gnd.sym} -680 240 0 0 {name=l1 lab=0}
C {lab_pin.sym} -680 100 0 0 {name=p2 sig_type=std_logic lab=VSS}
C {vsource.sym} -600 180 0 0 {name=V2 value=5 savecurrent=false}
C {gnd.sym} -600 240 0 0 {name=l2 lab=0}
C {lab_pin.sym} -600 100 0 0 {name=p4 sig_type=std_logic lab=VDD}
C {vsource.sym} -510 180 0 0 {name=V3 value=5 savecurrent=false}
C {gnd.sym} -510 240 0 0 {name=l3 lab=0}
C {lab_pin.sym} -510 100 0 0 {name=p5 sig_type=std_logic lab=XY}
C {vsource.sym} -430 180 0 0 {name=V4 value=PULSE(0,5,5n,0.1n,0.1n,10n,20n) savecurrent=false}
C {gnd.sym} -430 240 0 0 {name=l4 lab=0}
C {lab_pin.sym} -430 100 0 0 {name=p6 sig_type=std_logic lab=XZ}
C {code_shown.sym} -760 -110 0 0 {name=MODELS only_toplevel=false value=".include /foss/pdks/gf180mcuD/libs.tech/ngspice/design.ngspice
.lib /foss/pdks/gf180mcuD/libs.tech/ngspice/sm141064.ngspice typical"}
C {code_shown.sym} -10 80 0 0 {name=NGSPICE 
only_toplevel=false 
value="

.control
tran .01n 20n
meas tran tpdr TRIG v(XZ) VAL='5/2' RISE=1 TARG v(output) VAL='5/2' RISE=1
meas tran tpdf TRIG v(XZ) VAL='5/2' FALL=1 TARG v(output) VAL='5/2' FALL=1

let tpd=(tpdr+tpdf)/2
print tpdr tpdf tpd
plot v(XZ) v(output)

.endc
"}
C {/foss/designs/sscs-2026-zotnetic/activities/opamp3AKAM/andGate.sym} -220 70 0 0 {name=x1}
C {lab_pin.sym} -280 30 0 0 {name=p1 sig_type=std_logic lab=XY}
C {lab_pin.sym} -280 70 0 0 {name=p3 sig_type=std_logic lab=XZ}
C {lab_pin.sym} -240 -30 0 0 {name=p7 sig_type=std_logic lab=VDD}
C {lab_pin.sym} -240 160 0 0 {name=p8 sig_type=std_logic lab=VSS}
C {lab_pin.sym} -190 50 2 0 {name=p9 sig_type=std_logic lab=output}
