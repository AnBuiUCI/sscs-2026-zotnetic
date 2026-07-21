v {xschem version=3.4.8RC file_version=1.3}
G {}
K {}
V {}
S {}
F {}
E {}
N -60 -10 -50 -10 {lab=In}
N -50 -10 -40 -10 {lab=In}
N -40 -10 -40 50 {lab=In}
N -40 -110 -40 -10 {lab=In}
N 0 -170 0 -140 {lab=VDD}
N 0 80 0 120 {lab=xxx}
N 0 -80 0 20 {lab=output}
N 0 -30 100 -30 {lab=output}
N 0 -110 30 -110 {lab=VDD}
N 30 -150 30 -110 {lab=VDD}
N 0 -150 30 -150 {lab=VDD}
N 0 50 30 50 {lab=xxx}
N 30 50 30 80 {lab=xxx}
N 30 80 30 90 {lab=xxx}
N 0 90 30 90 {lab=xxx}
C {symbols/pfet_06v0.sym} -20 -110 0 0 {name=M4
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
C {symbols/nfet_06v0.sym} -20 50 2 1 {name=M5
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
C {opin.sym} 100 -30 0 0 {name=p10 lab=output}
C {ipin.sym} -60 -10 0 0 {name=p2 lab=In}
C {ipin.sym} 0 -170 0 0 {name=p1 lab=VDD}
C {ipin.sym} 0 120 0 0 {name=p3 lab=VSS}
