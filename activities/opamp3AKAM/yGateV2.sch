v {xschem version=3.4.8RC file_version=1.3}
G {}
K {}
V {}
S {}
F {}
E {}
N -60 -10 -50 -10 {lab=B}
N -50 -10 -40 -10 {lab=B}
N -40 -10 -40 50 {lab=B}
N -40 -110 -40 -10 {lab=B}
N 0 -170 0 -140 {lab=VDD}
N 0 80 0 120 {lab=VSS}
N 0 -80 0 20 {lab=not_B}
N 0 -30 100 -30 {lab=not_B}
N 0 -110 30 -110 {lab=VDD}
N 30 -150 30 -110 {lab=VDD}
N 0 -150 30 -150 {lab=VDD}
N 0 50 30 50 {lab=VSS}
N 30 50 30 80 {lab=VSS}
N 30 80 30 90 {lab=VSS}
N 0 90 30 90 {lab=VSS}
N 560 -170 560 100 {lab=output}
N 400 -280 400 -210 {lab=A}
N 240 100 300 100 {lab=#net1}
N 560 -10 670 -10 {lab=output}
N 240 -170 370 -170 {lab=#net2}
N 400 -170 400 -150 {lab=#net2}
N 360 -150 400 -150 {lab=#net2}
N 360 -170 360 -150 {lab=#net2}
N 430 -170 560 -170 {lab=output}
N 240 -30 370 -30 {lab=VSS}
N 400 -30 400 -20 {lab=VSS}
N 360 -20 400 -20 {lab=VSS}
N 360 -30 360 -20 {lab=VSS}
N 430 -30 550 -30 {lab=output}
N 550 -30 560 -30 {lab=output}
N 400 -90 400 -70 {lab=not_B}
N 510 100 560 100 {lab=output}
N 360 100 450 100 {lab=#net3}
N 330 100 330 130 {lab=#net1}
N 280 130 330 130 {lab=#net1}
N 280 100 280 130 {lab=#net1}
N 480 100 480 130 {lab=#net1}
N 330 130 480 130 {lab=#net1}
N 330 10 330 60 {lab=A}
N 480 40 480 60 {lab=not_B}
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
C {ipin.sym} 0 -170 0 0 {name=p1 lab=VDD}
C {ipin.sym} 0 120 0 0 {name=p3 lab=VSS}
C {ipin.sym} 400 -280 0 0 {name=p6 lab=A}
C {opin.sym} 670 -10 0 0 {name=p7 lab=output}
C {lab_pin.sym} 240 -30 0 0 {name=p11 sig_type=std_logic lab=VSS}
C {lab_pin.sym} 330 10 0 0 {name=p8 sig_type=std_logic lab=A}
C {symbols/pfet_06v0.sym} 480 80 1 0 {name=M1
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
C {symbols/pfet_06v0.sym} 330 80 1 0 {name=M2
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
C {symbols/nfet_06v0.sym} 400 -50 3 1 {name=M7
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
C {symbols/nfet_06v0.sym} 400 -190 3 1 {name=M3
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
C {ipin.sym} -60 -10 0 0 {name=p5 lab=B}
C {lab_pin.sym} 100 -30 2 0 {name=p10 sig_type=std_logic lab=not_B}
C {lab_pin.sym} 480 40 2 0 {name=p9 sig_type=std_logic lab=not_B}
C {lab_pin.sym} 400 -90 2 0 {name=p2 sig_type=std_logic lab=not_B}
C {lab_pin.sym} 240 -170 0 0 {name=p4 sig_type=std_logic lab=VDD}
C {lab_pin.sym} 240 100 0 0 {name=p12 sig_type=std_logic lab=VDD}
