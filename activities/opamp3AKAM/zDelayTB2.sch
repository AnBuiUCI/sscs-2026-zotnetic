v {xschem version=3.4.8RC file_version=1.3}
G {}
K {}
V {}
S {}
F {}
E {}
N 230 -150 230 120 {lab=output}
N 70 -260 70 -190 {lab=XZ}
N -90 120 -30 120 {lab=VDD}
N 230 10 340 10 {lab=output}
N -90 -150 40 -150 {lab=VSS}
N 70 -150 70 -130 {lab=VSS}
N 30 -130 70 -130 {lab=VSS}
N 30 -150 30 -130 {lab=VSS}
N 100 -150 230 -150 {lab=output}
N -90 -10 40 -10 {lab=VSS}
N 70 -10 70 0 {lab=VSS}
N 30 0 70 0 {lab=VSS}
N 30 -10 30 0 {lab=VSS}
N 100 -10 220 -10 {lab=output}
N 220 -10 230 -10 {lab=output}
N 70 -70 70 -50 {lab=YZ}
N 180 120 230 120 {lab=output}
N 30 120 120 120 {lab=#net1}
N 0 120 0 150 {lab=VDD}
N -50 150 0 150 {lab=VDD}
N -50 120 -50 150 {lab=VDD}
N 150 120 150 150 {lab=VDD}
N 0 150 150 150 {lab=VDD}
N 0 30 0 80 {lab=XZ}
N 150 60 150 80 {lab=YZ}
N -390 280 -390 310 {lab=0}
N -390 160 -390 220 {lab=VSS}
N -310 280 -310 310 {lab=0}
N -310 160 -310 220 {lab=VDD}
N -220 280 -220 310 {lab=0}
N -220 160 -220 220 {lab=XZ}
N -140 280 -140 310 {lab=0}
N -140 160 -140 220 {lab=YZ}
N 330 10 360 10 {lab=output}
N 400 -50 400 -20 {lab=VDD}
N 400 10 430 10 {lab=VSS}
N 400 40 400 80 {lab=VSS}
N 400 80 400 130 {lab=VSS}
N 400 60 430 60 {lab=VSS}
N 430 10 430 60 {lab=VSS}
C {lab_pin.sym} -90 -10 0 0 {name=p11 sig_type=std_logic lab=VSS}
C {symbols/pfet_06v0.sym} 150 100 1 0 {name=M4
L=1.0u
W=3.0u
nf=1
m=1
ad="'int((nf+1)/2) * W/nf * 0.18u'"
pd="'2*int((nf+1)/2) * (W/nf + 0.18u)'"
as="'int((nf+2)/2) * W/nf * 0.18u'"
ps="'2*int((nf+2)/2) * (W/nf + 0.18u)'"
nrd="'0.18u / W'" nrs="'0.18u / W'"
sa=0 sb=0 sd=0
model=pfet_06v0
spiceprefix=X
}
C {symbols/pfet_06v0.sym} 0 100 1 0 {name=M5
L=1.0u
W=3.0u
nf=1
m=1
ad="'int((nf+1)/2) * W/nf * 0.18u'"
pd="'2*int((nf+1)/2) * (W/nf + 0.18u)'"
as="'int((nf+2)/2) * W/nf * 0.18u'"
ps="'2*int((nf+2)/2) * (W/nf + 0.18u)'"
nrd="'0.18u / W'" nrs="'0.18u / W'"
sa=0 sb=0 sd=0
model=pfet_06v0
spiceprefix=X
}
C {symbols/nfet_06v0.sym} 70 -30 3 1 {name=M7
L=1u
W=1u
nf=1
m=1
ad="'int((nf+1)/2) * W/nf * 0.18u'"
pd="'2*int((nf+1)/2) * (W/nf + 0.18u)'"
as="'int((nf+2)/2) * W/nf * 0.18u'"
ps="'2*int((nf+2)/2) * (W/nf + 0.18u)'"
nrd="'0.18u / W'" nrs="'0.18u / W'"
sa=0 sb=0 sd=0
model=nfet_06v0
spiceprefix=X
}
C {symbols/nfet_06v0.sym} 70 -170 3 1 {name=M1
L=1u
W=1u
nf=1
m=1
ad="'int((nf+1)/2) * W/nf * 0.18u'"
pd="'2*int((nf+1)/2) * (W/nf + 0.18u)'"
as="'int((nf+2)/2) * W/nf * 0.18u'"
ps="'2*int((nf+2)/2) * (W/nf + 0.18u)'"
nrd="'0.18u / W'" nrs="'0.18u / W'"
sa=0 sb=0 sd=0
model=nfet_06v0
spiceprefix=X
}
C {vsource.sym} -390 250 0 0 {name=V1 value=0 savecurrent=false}
C {gnd.sym} -390 310 0 0 {name=l1 lab=0}
C {lab_pin.sym} -390 170 0 0 {name=p5 sig_type=std_logic lab=VSS}
C {vsource.sym} -310 250 0 0 {name=V2 value=5 savecurrent=false}
C {gnd.sym} -310 310 0 0 {name=l2 lab=0}
C {lab_pin.sym} -310 170 0 0 {name=p6 sig_type=std_logic lab=VDD}
C {vsource.sym} -220 250 0 0 {name=V3 value=0 savecurrent=false}
C {gnd.sym} -220 310 0 0 {name=l3 lab=0}
C {lab_pin.sym} -220 170 0 0 {name=p7 sig_type=std_logic lab=XZ}
C {vsource.sym} -140 250 0 0 {name=V4 value=PULSE(0,5,5n,0.1n,0.1n,10n,20n) savecurrent=false}
C {gnd.sym} -140 310 0 0 {name=l4 lab=0}
C {lab_pin.sym} -140 170 0 0 {name=p8 sig_type=std_logic lab=YZ}
C {lab_pin.sym} 0 70 0 0 {name=p1 sig_type=std_logic lab=XZ}
C {lab_pin.sym} 150 60 0 0 {name=p2 sig_type=std_logic lab=YZ}
C {lab_pin.sym} 70 -70 0 0 {name=p3 sig_type=std_logic lab=YZ}
C {lab_pin.sym} 70 -230 0 0 {name=p4 sig_type=std_logic lab=XZ}
C {lab_pin.sym} -90 -150 0 0 {name=p9 sig_type=std_logic lab=VSS}
C {lab_pin.sym} -90 120 0 0 {name=p12 sig_type=std_logic lab=VDD}
C {code_shown.sym} -280 -290 0 0 {name=MODELS only_toplevel=false value=".include /foss/pdks/gf180mcuD/libs.tech/ngspice/design.ngspice
.lib /foss/pdks/gf180mcuD/libs.tech/ngspice/sm141064.ngspice typical"}
C {code_shown.sym} 620 -130 0 0 {name=NGSPICE 
only_toplevel=false 
value="

.control
tran .01n 25n
meas tran tpdr TRIG v(YZ) VAL='5/2' RISE=1 TARG v(output) VAL='5/2' FALL=1
meas tran tpdf TRIG v(YZ) VAL='5/2' FALL=1 TARG v(output) VAL='5/2' RISE=1

let tpd=(tpdr+tpdf)/2
print tpdr tpdf tpd
plot v(YZ) v(output)

.endc
"}
C {symbols/nfet_06v0.sym} 380 10 0 0 {name=M2
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
C {lab_pin.sym} 400 -50 2 0 {name=p10 sig_type=std_logic lab=VDD}
C {lab_pin.sym} 290 10 3 0 {name=p14 sig_type=std_logic lab=output}
C {lab_pin.sym} 400 100 2 0 {name=p13 sig_type=std_logic lab=VSS}
