v {xschem version=3.4.8RC file_version=1.3}
G {}
K {}
V {}
S {}
F {}
E {}
N 170 -140 170 130 {lab=output}
N 10 -250 10 -180 {lab=A}
N -150 130 -90 130 {lab=VDD}
N 170 20 280 20 {lab=output}
N -150 -140 -20 -140 {lab=VSS}
N 10 -140 10 -120 {lab=VSS}
N -30 -120 10 -120 {lab=VSS}
N -30 -140 -30 -120 {lab=VSS}
N 40 -140 170 -140 {lab=output}
N -150 0 -20 0 {lab=VSS}
N 10 0 10 10 {lab=VSS}
N -30 10 10 10 {lab=VSS}
N -30 0 -30 10 {lab=VSS}
N 40 0 160 0 {lab=output}
N 160 0 170 0 {lab=output}
N 10 -60 10 -40 {lab=B}
N 120 130 170 130 {lab=output}
N -30 130 60 130 {lab=#net1}
N -60 130 -60 160 {lab=VDD}
N -110 160 -60 160 {lab=VDD}
N -110 130 -110 160 {lab=VDD}
N 90 130 90 160 {lab=VDD}
N -60 160 90 160 {lab=VDD}
N -60 40 -60 90 {lab=A}
N 90 70 90 90 {lab=B}
C {ipin.sym} -150 -140 0 0 {name=p3 lab=VSS}
C {ipin.sym} 10 -60 0 0 {name=p2 lab=B}
C {ipin.sym} 10 -250 0 0 {name=p4 lab=A}
C {opin.sym} 280 20 0 0 {name=p10 lab=output}
C {lab_pin.sym} -150 0 0 0 {name=p11 sig_type=std_logic lab=VSS}
C {lab_pin.sym} -60 40 0 0 {name=p7 sig_type=std_logic lab=A}
C {lab_pin.sym} 90 70 0 0 {name=p6 sig_type=std_logic lab=B}
C {ipin.sym} -150 130 0 0 {name=p1 lab=VDD}
C {symbols/pfet_06v0.sym} 90 110 1 0 {name=M4
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
C {symbols/pfet_06v0.sym} -60 110 1 0 {name=M5
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
C {symbols/nfet_06v0.sym} 10 -20 3 1 {name=M7
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
C {symbols/nfet_06v0.sym} 10 -160 3 1 {name=M1
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
