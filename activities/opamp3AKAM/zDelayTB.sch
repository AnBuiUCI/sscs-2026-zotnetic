v {xschem version=3.4.8RC file_version=1.3}
G {}
K {}
V {}
S {}
F {}
E {}
N 240 -130 240 140 {lab=output}
N 80 -240 80 -170 {lab=XZ}
N -80 140 -20 140 {lab=VDD}
N 240 30 350 30 {lab=output}
N -80 -130 50 -130 {lab=VSS}
N 80 -130 80 -110 {lab=VSS}
N 40 -110 80 -110 {lab=VSS}
N 40 -130 40 -110 {lab=VSS}
N 110 -130 240 -130 {lab=output}
N -80 10 50 10 {lab=VSS}
N 80 10 80 20 {lab=VSS}
N 40 20 80 20 {lab=VSS}
N 40 10 40 20 {lab=VSS}
N 110 10 230 10 {lab=output}
N 230 10 240 10 {lab=output}
N 80 -50 80 -30 {lab=YZ}
N 190 140 240 140 {lab=output}
N 40 140 130 140 {lab=#net1}
N 10 140 10 170 {lab=VDD}
N -40 170 10 170 {lab=VDD}
N -40 140 -40 170 {lab=VDD}
N 160 140 160 170 {lab=VDD}
N 10 170 160 170 {lab=VDD}
N 10 50 10 100 {lab=XZ}
N 160 80 160 100 {lab=YZ}
N -380 300 -380 330 {lab=0}
N -380 180 -380 240 {lab=VSS}
N -300 300 -300 330 {lab=0}
N -300 180 -300 240 {lab=VDD}
N -210 300 -210 330 {lab=0}
N -210 180 -210 240 {lab=XZ}
N -130 300 -130 330 {lab=0}
N -130 180 -130 240 {lab=YZ}
C {lab_pin.sym} -80 10 0 0 {name=p11 sig_type=std_logic lab=VSS}
C {symbols/pfet_06v0.sym} 160 120 1 0 {name=M4
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
C {symbols/pfet_06v0.sym} 10 120 1 0 {name=M5
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
C {symbols/nfet_06v0.sym} 80 -10 3 1 {name=M7
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
C {symbols/nfet_06v0.sym} 80 -150 3 1 {name=M1
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
C {vsource.sym} -380 270 0 0 {name=V1 value=0 savecurrent=false}
C {gnd.sym} -380 330 0 0 {name=l1 lab=0}
C {lab_pin.sym} -380 190 0 0 {name=p5 sig_type=std_logic lab=VSS}
C {vsource.sym} -300 270 0 0 {name=V2 value=5 savecurrent=false}
C {gnd.sym} -300 330 0 0 {name=l2 lab=0}
C {lab_pin.sym} -300 190 0 0 {name=p6 sig_type=std_logic lab=VDD}
C {vsource.sym} -210 270 0 0 {name=V3 value=0 savecurrent=false}
C {gnd.sym} -210 330 0 0 {name=l3 lab=0}
C {lab_pin.sym} -210 190 0 0 {name=p7 sig_type=std_logic lab=XZ}
C {vsource.sym} -130 270 0 0 {name=V4 value=PULSE(0,5,5n,0.1n,0.1n,10n,20n) savecurrent=false}
C {gnd.sym} -130 330 0 0 {name=l4 lab=0}
C {lab_pin.sym} -130 190 0 0 {name=p8 sig_type=std_logic lab=YZ}
C {lab_pin.sym} 10 90 0 0 {name=p1 sig_type=std_logic lab=XZ}
C {lab_pin.sym} 160 80 0 0 {name=p2 sig_type=std_logic lab=YZ}
C {lab_pin.sym} 80 -50 0 0 {name=p3 sig_type=std_logic lab=YZ}
C {lab_pin.sym} 80 -210 0 0 {name=p4 sig_type=std_logic lab=XZ}
C {lab_pin.sym} -80 -130 0 0 {name=p9 sig_type=std_logic lab=VSS}
C {lab_pin.sym} -80 140 0 0 {name=p12 sig_type=std_logic lab=VDD}
C {lab_pin.sym} 350 30 2 0 {name=p10 sig_type=std_logic lab=output}
C {code_shown.sym} -270 -270 0 0 {name=MODELS only_toplevel=false value=".include /foss/pdks/gf180mcuD/libs.tech/ngspice/design.ngspice
.lib /foss/pdks/gf180mcuD/libs.tech/ngspice/sm141064.ngspice typical"}
C {code_shown.sym} 480 -80 0 0 {name=NGSPICE 
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
