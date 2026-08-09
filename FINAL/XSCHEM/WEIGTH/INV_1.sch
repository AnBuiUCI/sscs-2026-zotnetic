v {xschem version=3.4.8RC file_version=1.3}
G {}
K {}
V {}
S {}
F {}
E {}
N -600 60 -600 80 {lab=VSS}
N -600 80 -590 80 {lab=VSS}
N -600 60 -580 60 {lab=VSS}
N -580 30 -580 60 {lab=VSS}
N -600 30 -580 30 {lab=VSS}
N -600 -30 -600 -0 {lab=OUT}
N -600 -10 -590 -10 {lab=OUT}
N -660 -60 -640 -60 {lab=IN}
N -660 -60 -660 30 {lab=IN}
N -660 30 -640 30 {lab=IN}
N -600 -120 -600 -90 {lab=VDD}
N -600 -60 -580 -60 {lab=VDD}
N -580 -100 -580 -60 {lab=VDD}
N -600 -100 -580 -100 {lab=VDD}
C {ipin.sym} -660 -20 0 0 {name=p1 lab=IN}
C {iopin.sym} -600 -120 0 0 {name=p2 lab=VDD}
C {opin.sym} -590 -10 0 0 {name=p3 lab=OUT}
C {iopin.sym} -590 80 0 0 {name=p4 lab=VSS}
C {symbols/pfet_05v0.sym} -620 -60 0 0 {name=M3
L=0.5u
W=1.83u
nf=1
m=1
ad="'int((nf+1)/2) * W/nf * 0.18u'"
pd="'2*int((nf+1)/2) * (W/nf + 0.18u)'"
as="'int((nf+2)/2) * W/nf * 0.18u'"
ps="'2*int((nf+2)/2) * (W/nf + 0.18u)'"
nrd="'0.18u / W'" nrs="'0.18u / W'"
sa=0 sb=0 sd=0
model=pfet_05v0
spiceprefix=X
}
C {symbols/nfet_05v0.sym} -620 30 0 0 {name=M4
L=0.6u
W=1.32u
nf=1
m=1
ad="'int((nf+1)/2) * W/nf * 0.18u'"
pd="'2*int((nf+1)/2) * (W/nf + 0.18u)'"
as="'int((nf+2)/2) * W/nf * 0.18u'"
ps="'2*int((nf+2)/2) * (W/nf + 0.18u)'"
nrd="'0.18u / W'" nrs="'0.18u / W'"
sa=0 sb=0 sd=0
model=nfet_05v0
spiceprefix=X
}
