v {xschem version=3.4.8RC file_version=1.3}
G {}
K {}
V {}
S {}
F {}
E {}
N -70 -30 10 -30 {lab=vg}
N -70 -30 -70 -10 {lab=vg}
N 50 -30 80 -30 {lab=#net1}
N 80 -30 80 10 {lab=#net1}
N 50 10 80 10 {lab=#net1}
N 50 -60 220 -60 {lab=vg}
N 50 -0 50 30 {lab=#net1}
C {symbols/nfet_06v0.sym} 30 -30 0 0 {name=M1
L=0.70u
W=0.30u
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
C {iopin.sym} -70 -10 0 0 {name=p1 lab=vg}
C {iopin.sym} 220 -60 0 0 {name=p2 lab=vdd}
C {iopin.sym} 50 30 0 0 {name=p3 lab=vss}
