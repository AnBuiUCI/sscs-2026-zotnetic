v {xschem version=3.4.8RC file_version=1.3}
G {}
K {}
V {}
S {}
F {}
E {}
N 230 -150 230 120 {lab=#net1}
N 70 -260 70 -190 {lab=XZ}
N -90 120 -30 120 {lab=VDD}
N -90 -150 40 -150 {lab=VSS}
N 70 -150 70 -130 {lab=VSS}
N 30 -130 70 -130 {lab=VSS}
N 30 -150 30 -130 {lab=VSS}
N 100 -150 230 -150 {lab=#net1}
N -90 -10 40 -10 {lab=VSS}
N 70 -10 70 0 {lab=VSS}
N 30 0 70 0 {lab=VSS}
N 30 -10 30 0 {lab=VSS}
N 100 -10 220 -10 {lab=#net1}
N 220 -10 230 -10 {lab=#net1}
N 70 -70 70 -50 {lab=YZ}
N 180 120 230 120 {lab=#net1}
N 30 120 120 120 {lab=#net2}
N 0 120 0 150 {lab=VDD}
N -50 150 0 150 {lab=VDD}
N -50 120 -50 150 {lab=VDD}
N 150 120 150 150 {lab=VDD}
N 0 150 150 150 {lab=VDD}
N 0 30 0 80 {lab=XZ}
N 150 60 150 80 {lab=YZ}
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
C {lab_pin.sym} 0 70 0 0 {name=p1 sig_type=std_logic lab=XZ}
C {lab_pin.sym} 150 60 0 0 {name=p2 sig_type=std_logic lab=YZ}
C {lab_pin.sym} 70 -70 0 0 {name=p3 sig_type=std_logic lab=YZ}
C {lab_pin.sym} 70 -230 0 0 {name=p4 sig_type=std_logic lab=XZ}
C {lab_pin.sym} -90 -150 0 0 {name=p9 sig_type=std_logic lab=VSS}
C {lab_pin.sym} -90 120 0 0 {name=p12 sig_type=std_logic lab=VDD}
C {iopin.sym} 250 -230 0 0 {name=p5 lab=VSS}
C {iopin.sym} 250 -200 0 0 {name=p6 lab=VDD}
C {ipin.sym} 300 -180 0 0 {name=p7 lab=XZ}
C {ipin.sym} 300 -160 0 0 {name=p8 lab=YZ}
C {opin.sym} 230 -20 0 0 {name=p10 lab=out}
