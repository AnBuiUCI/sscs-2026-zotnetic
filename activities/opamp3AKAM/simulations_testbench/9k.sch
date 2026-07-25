v {xschem version=3.4.8RC file_version=1.3}
G {}
K {}
V {}
S {}
F {}
E {}
N -80 -50 130 -50 {lab=PLUS}
N 20 -50 130 -50 {lab=PLUS}
N 20 -130 20 -50 {lab=PLUS}
N -80 10 130 10 {lab=NEG}
N 20 10 130 10 {lab=NEG}
N -170 -20 -120 -20 {lab=GATE_PMOS}
N 170 -20 250 -20 {lab=GATE_NMOS}
N -80 -20 -10 -20 {lab=PLUS}
N -10 -50 -10 -20 {lab=PLUS}
N 50 -20 130 -20 {lab=NEG}
N 50 -20 50 10 {lab=NEG}
N 20 90 20 110 {lab=NEG}
N 20 10 20 30 {lab=NEG}
N 20 30 20 90 {lab=NEG}
C {symbols/nfet_06v0.sym} 150 -20 2 0 {name=M2
L=1u
W=4.275u
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
C {symbols/pfet_06v0.sym} -100 -20 2 1 {name=M8
L=1.0u
W=4.0u
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
C {opin.sym} 20 110 0 0 {name=p2 lab=NEG}
C {ipin.sym} 20 -130 0 0 {name=p4 lab=PLUS}
C {ipin.sym} -170 -20 0 0 {name=p1 lab=GATE_PMOS}
C {ipin.sym} 250 -20 2 0 {name=p3 lab=GATE_NMOS}
