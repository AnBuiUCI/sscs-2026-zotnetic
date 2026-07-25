v {xschem version=3.4.8RC file_version=1.3}
G {}
K {}
V {}
S {}
F {}
E {}
N -440 290 -440 320 {lab=0}
N -440 170 -440 230 {lab=VSS}
N -360 290 -360 320 {lab=0}
N -360 170 -360 230 {lab=VDD}
N -270 290 -270 320 {lab=0}
N -270 170 -270 230 {lab=XY}
N -190 290 -190 320 {lab=0}
N -190 170 -190 230 {lab=YZ}
N -190 -90 -190 -60 {lab=VDD}
N -190 40 -190 90 {lab=VSS}
N -110 -10 -10 -10 {lab=#net1}
N -30 -30 -10 -30 {lab=VSS}
N -30 10 -10 10 {lab=VDD}
N 290 -50 320 -50 {lab=output}
N 320 -50 350 -50 {lab=output}
N 390 -110 390 -80 {lab=VDD}
N 390 -50 420 -50 {lab=VSS}
N 390 -20 390 20 {lab=VSS}
C {vsource.sym} -440 260 0 0 {name=V1 value=0 savecurrent=false}
C {gnd.sym} -440 320 0 0 {name=l1 lab=0}
C {lab_pin.sym} -440 180 0 0 {name=p5 sig_type=std_logic lab=VSS}
C {vsource.sym} -360 260 0 0 {name=V2 value=5 savecurrent=false}
C {gnd.sym} -360 320 0 0 {name=l2 lab=0}
C {lab_pin.sym} -360 180 0 0 {name=p6 sig_type=std_logic lab=VDD}
C {vsource.sym} -270 260 0 0 {name=V3 value=0 savecurrent=false}
C {gnd.sym} -270 320 0 0 {name=l3 lab=0}
C {lab_pin.sym} -270 180 0 0 {name=p7 sig_type=std_logic lab=XY}
C {vsource.sym} -190 260 0 0 {name=V4 value=PULSE(0,5,5n,0.1n,0.1n,10n,20n) savecurrent=false}
C {gnd.sym} -190 320 0 0 {name=l4 lab=0}
C {lab_pin.sym} -190 180 0 0 {name=p8 sig_type=std_logic lab=YZ}
C {code_shown.sym} -490 -240 0 0 {name=MODELS only_toplevel=false value=".include /foss/pdks/gf180mcuD/libs.tech/ngspice/design.ngspice
.lib /foss/pdks/gf180mcuD/libs.tech/ngspice/sm141064.ngspice typical"}
C {/foss/designs/sscs-2026-zotnetic/activities/opamp3AKAM/nor.sym} 140 -20 0 0 {name=x1}
C {/foss/designs/sscs-2026-zotnetic/activities/opamp3AKAM/invertor.sym} -210 0 0 0 {name=x2}
C {lab_pin.sym} -250 -10 0 0 {name=p1 sig_type=std_logic lab=YZ}
C {lab_pin.sym} -190 -90 2 0 {name=p2 sig_type=std_logic lab=VDD}
C {lab_pin.sym} -190 90 0 0 {name=p4 sig_type=std_logic lab=VSS}
C {lab_pin.sym} -10 -50 0 0 {name=p9 sig_type=std_logic lab=XY}
C {lab_pin.sym} -30 -30 0 0 {name=p10 sig_type=std_logic lab=VSS}
C {lab_pin.sym} -30 10 0 0 {name=p11 sig_type=std_logic lab=VDD}
C {code_shown.sym} 660 -90 0 0 {name=NGSPICE 
only_toplevel=false 
value="

.control
tran .01n 25n
meas tran tpdr TRIG v(YZ) VAL='5/2' RISE=1 TARG v(output) VAL='5/2' RISE=1
meas tran tpdf TRIG v(YZ) VAL='5/2' FALL=1 TARG v(output) VAL='5/2' FALL=1

let tpd=(tpdr+tpdf)/2
print tpdr tpdf tpd
plot v(YZ) v(output)

.endc
"}
C {symbols/nfet_06v0.sym} 370 -50 0 0 {name=M7
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
C {lab_pin.sym} 390 -110 2 0 {name=p3 sig_type=std_logic lab=VDD}
C {lab_pin.sym} 420 -50 2 0 {name=p15 sig_type=std_logic lab=VSS}
C {lab_pin.sym} 320 -50 3 0 {name=p14 sig_type=std_logic lab=output}
C {lab_pin.sym} 390 20 2 0 {name=p12 sig_type=std_logic lab=VSS}
