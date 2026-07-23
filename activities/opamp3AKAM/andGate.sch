v {xschem version=3.4.8RC file_version=1.3}
G {}
K {}
V {}
S {}
F {}
E {}
N 10 -90 10 180 {lab=#net1}
N -150 -200 -150 -130 {lab=A}
N -310 180 -250 180 {lab=VSS}
N 10 70 120 70 {lab=#net1}
N 120 70 130 70 {lab=#net1}
N 130 70 140 70 {lab=#net1}
N 140 70 140 130 {lab=#net1}
N 140 -30 140 70 {lab=#net1}
N 180 -90 180 -60 {lab=VDD}
N 180 160 180 200 {lab=#net2}
N 180 0 180 100 {lab=output}
N 180 50 280 50 {lab=output}
N -310 -90 -180 -90 {lab=VDD}
N -150 -90 -150 -70 {lab=VDD}
N -190 -70 -150 -70 {lab=VDD}
N -190 -90 -190 -70 {lab=VDD}
N -120 -90 10 -90 {lab=#net1}
N -310 50 -180 50 {lab=VDD}
N -150 50 -150 60 {lab=VDD}
N -190 60 -150 60 {lab=VDD}
N -190 50 -190 60 {lab=VDD}
N -120 50 0 50 {lab=#net1}
N -0 50 10 50 {lab=#net1}
N -150 -10 -150 10 {lab=B}
N -40 180 10 180 {lab=#net1}
N -190 180 -100 180 {lab=#net3}
N -220 180 -220 210 {lab=VSS}
N -270 210 -220 210 {lab=VSS}
N -270 180 -270 210 {lab=VSS}
N -70 180 -70 210 {lab=VSS}
N -220 210 -70 210 {lab=VSS}
N 180 -30 210 -30 {lab=VDD}
N 210 -70 210 -30 {lab=VDD}
N 180 -70 210 -70 {lab=VDD}
N 180 130 210 130 {lab=#net2}
N 210 130 210 160 {lab=#net2}
N 210 160 210 170 {lab=#net2}
N 180 170 210 170 {lab=#net2}
N -220 90 -220 140 {lab=A}
N -70 120 -70 140 {lab=B}
C {symbols/pfet_06v0.sym} 160 -30 0 0 {name=M4
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
C {symbols/nfet_06v0.sym} 160 130 2 1 {name=M5
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
C {symbols/pfet_06v0.sym} -150 -110 1 0 {name=M2
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
C {symbols/pfet_06v0.sym} -150 30 1 0 {name=M1
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
C {symbols/nfet_06v0.sym} -220 160 3 1 {name=M3
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
C {symbols/nfet_06v0.sym} -70 160 3 1 {name=M6
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
C {ipin.sym} -310 -90 0 0 {name=p3 lab=VDD}
C {ipin.sym} -150 -10 0 0 {name=p2 lab=B}
C {ipin.sym} -150 -200 0 0 {name=p4 lab=A}
C {ipin.sym} -310 180 0 0 {name=p5 lab=VSS
}
C {opin.sym} 280 50 0 0 {name=p10 lab=output}
C {lab_pin.sym} -310 50 0 0 {name=p11 sig_type=std_logic lab=VDD}
C {lab_pin.sym} 180 -90 0 0 {name=p1 sig_type=std_logic lab=VDD}
C {lab_pin.sym} -220 90 0 0 {name=p7 sig_type=std_logic lab=A}
C {lab_pin.sym} -70 120 0 0 {name=p6 sig_type=std_logic lab=B}
C {lab_pin.sym} 180 200 0 0 {name=p8 sig_type=std_logic lab=VSS}
