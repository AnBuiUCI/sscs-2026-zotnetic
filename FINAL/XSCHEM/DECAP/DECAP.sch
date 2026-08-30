v {xschem version=3.4.8RC file_version=1.3}
G {}
K {}
V {}
S {}
F {}
E {}
N -60 0 -20 0 {lab=VDD}
N 20 -30 60 -30 {lab=VSS}
N 20 0 60 0 {lab=VSS}
N 20 30 60 30 {lab=VSS}
N 60 -30 60 30 {lab=VSS}
N -60 200 -20 200 {lab=VSS}
N 20 170 60 170 {lab=VDD}
N 20 200 60 200 {lab=VDD}
N 20 230 60 230 {lab=VDD}
N 60 170 60 230 {lab=VDD}
C {iopin.sym} -100 -80 0 0 {name=p1 lab=VDD}
C {iopin.sym} -100 280 0 0 {name=p2 lab=VSS}
C {lab_pin.sym} -60 0 0 0 {name=l1 sig_type=std_logic lab=VDD}
C {lab_pin.sym} 60 0 2 0 {name=l2 sig_type=std_logic lab=VSS}
C {lab_pin.sym} -60 200 0 0 {name=l3 sig_type=std_logic lab=VSS}
C {lab_pin.sym} 60 200 2 0 {name=l4 sig_type=std_logic lab=VDD}
C {symbols/nfet_06v0.sym} 0 0 0 0 {name=MN
L=2.0u
W=8.0u
nf=4
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
C {symbols/pfet_06v0.sym} 0 200 0 0 {name=MP
L=2.0u
W=8.0u
nf=4
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
