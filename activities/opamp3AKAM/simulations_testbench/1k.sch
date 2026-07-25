v {xschem version=3.4.8RC file_version=1.3}
G {}
K {}
V {}
S {}
F {}
E {}
N -70 -30 140 -30 {lab=PLUS}
N 30 -30 140 -30 {lab=PLUS}
N 30 -110 30 -30 {lab=PLUS}
N -70 30 140 30 {lab=NEG}
N 30 30 140 30 {lab=NEG}
N -160 0 -110 0 {lab=GATE_PMOS}
N 180 0 260 0 {lab=#net1}
N -70 0 0 0 {lab=PLUS}
N 0 -30 0 0 {lab=PLUS}
N 60 0 140 0 {lab=NEG}
N 60 0 60 30 {lab=NEG}
N 30 110 30 130 {lab=NEG}
N 30 30 30 50 {lab=NEG}
N 30 50 30 110 {lab=NEG}
C {symbols/nfet_06v0.sym} 160 0 2 0 {name=M2
L=1u
W=37.5u
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
C {symbols/pfet_06v0.sym} -90 0 2 1 {name=M8
L=1.0u
W=40.0u
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
C {opin.sym} 30 130 0 0 {name=p2 lab=NEG}
C {ipin.sym} 30 -110 0 0 {name=p4 lab=PLUS}
C {ipin.sym} -160 0 0 0 {name=p1 lab=GATE_PMOS}
C {ipin.sym} 260 0 2 0 {name=p3 lab=GATE_NMOS}
