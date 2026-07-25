v {xschem version=3.4.8RC file_version=1.3}
G {}
K {}
V {}
S {}
F {}
E {}
N -490 70 -490 100 {lab=0}
N -490 -50 -490 10 {lab=VSS}
N -410 70 -410 100 {lab=0}
N -410 -50 -410 10 {lab=VDD}
N -320 70 -320 100 {lab=0}
N -320 -50 -320 10 {lab=XY}
N -240 70 -240 100 {lab=0}
N -240 -50 -240 10 {lab=XZ}
N -50 -170 -50 -140 {lab=VDD}
N -50 -40 -50 20 {lab=VSS}
N 160 -150 160 -120 {lab=VDD}
N 160 -90 190 -90 {lab=VSS}
N 160 -60 160 -20 {lab=VSS}
N -0 -90 120 -90 {lab=output}
C {vsource.sym} -490 40 0 0 {name=V1 value=0 savecurrent=false}
C {gnd.sym} -490 100 0 0 {name=l1 lab=0}
C {lab_pin.sym} -490 -40 0 0 {name=p2 sig_type=std_logic lab=VSS}
C {vsource.sym} -410 40 0 0 {name=V2 value=5 savecurrent=false}
C {gnd.sym} -410 100 0 0 {name=l2 lab=0}
C {lab_pin.sym} -410 -40 0 0 {name=p4 sig_type=std_logic lab=VDD}
C {vsource.sym} -320 40 0 0 {name=V3 value=5 savecurrent=false}
C {gnd.sym} -320 100 0 0 {name=l3 lab=0}
C {lab_pin.sym} -320 -40 0 0 {name=p5 sig_type=std_logic lab=XY}
C {vsource.sym} -240 40 0 0 {name=V4 value=PULSE(0,5,5n,0.1n,0.1n,10n,20n) savecurrent=false}
C {gnd.sym} -240 100 0 0 {name=l4 lab=0}
C {lab_pin.sym} -240 -40 0 0 {name=p6 sig_type=std_logic lab=XZ}
C {code_shown.sym} -570 -250 0 0 {name=MODELS only_toplevel=false value=".include /foss/pdks/gf180mcuD/libs.tech/ngspice/design.ngspice
.lib /foss/pdks/gf180mcuD/libs.tech/ngspice/sm141064.ngspice typical"}
C {code_shown.sym} 440 -90 0 0 {name=NGSPICE 
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
C {/foss/designs/sscs-2026-zotnetic/activities/opamp3AKAM/andGate.sym} -30 -70 0 0 {name=x1}
C {lab_pin.sym} -90 -110 0 0 {name=p1 sig_type=std_logic lab=XY}
C {lab_pin.sym} -90 -70 0 0 {name=p3 sig_type=std_logic lab=XZ}
C {lab_pin.sym} -50 -170 0 0 {name=p7 sig_type=std_logic lab=VDD}
C {lab_pin.sym} -50 20 0 0 {name=p8 sig_type=std_logic lab=VSS}
C {lab_pin.sym} 60 -90 3 0 {name=p9 sig_type=std_logic lab=output}
C {symbols/nfet_06v0.sym} 140 -90 0 0 {name=M7
L=1u
W=2.48u
nf=1
m=2
ad="'int((nf+1)/2) * W/nf * 0.18u'"
pd="'2*int((nf+1)/2) * (W/nf + 0.18u)'"
as="'int((nf+2)/2) * W/nf * 0.18u'"
ps="'2*int((nf+2)/2) * (W/nf + 0.18u)'"
nrd="'0.18u / W'" nrs="'0.18u / W'"
sa=0 sb=0 sd=0
model=nfet_06v0
spiceprefix=X
}
C {lab_pin.sym} 160 -150 2 0 {name=p10 sig_type=std_logic lab=VDD}
C {lab_pin.sym} 190 -90 2 0 {name=p15 sig_type=std_logic lab=VSS}
C {lab_pin.sym} 160 -20 2 0 {name=p12 sig_type=std_logic lab=VSS}
