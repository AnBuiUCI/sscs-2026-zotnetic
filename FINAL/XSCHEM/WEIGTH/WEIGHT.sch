v {xschem version=3.4.8RC file_version=1.3}
G {}
K {}
V {}
S {}
F {}
E {}
N 1250 -410 1310 -410 {
lab=VDD}
N 1300 -280 1310 -280 {
lab=OUT}
N 1300 -280 1300 -250 {lab=OUT}
N 1250 -370 1250 -350 {lab=VDD}
N 1250 -280 1250 -260 {lab=OUT}
N 1180 -320 1210 -320 {lab=OUT}
N 1180 -280 1180 -230 {lab=OUT}
N 1180 -230 1210 -230 {lab=OUT}
N 1180 -280 1250 -280 {lab=OUT}
N 1250 -320 1270 -320 {lab=VDD}
N 1270 -370 1270 -320 {lab=VDD}
N 1250 -370 1270 -370 {lab=VDD}
N 980 -220 1040 -220 {
lab=VD}
N 1080 -190 1080 -180 {lab=#net1}
N 1080 -150 1120 -150 {lab=GND}
N 1080 -220 1110 -220 {lab=GND}
N 1080 -60 1120 -60 {lab=GND}
N 980 -150 1040 -150 {
lab=IN}
N 1110 -280 1180 -280 {lab=OUT}
N 1080 -280 1110 -280 {lab=OUT}
N 1080 -280 1080 -250 {lab=OUT}
N 740 -220 800 -220 {
lab=VC}
N 840 -190 840 -180 {lab=#net2}
N 840 -150 880 -150 {lab=GND}
N 840 -220 870 -220 {lab=GND}
N 840 -60 880 -60 {lab=GND}
N 740 -150 800 -150 {
lab=IN}
N 840 -280 870 -280 {lab=OUT}
N 840 -280 840 -250 {lab=OUT}
N 1180 -330 1180 -320 {lab=OUT}
N 1250 -200 1250 -190 {lab=#net3}
N 1250 -160 1290 -160 {lab=GND}
N 1250 -230 1280 -230 {lab=GND}
N 1250 -60 1290 -60 {lab=GND}
N 1180 -160 1210 -160 {lab=OUT}
N 1180 -230 1180 -160 {lab=OUT}
N 1250 -90 1290 -90 {lab=GND}
N 1180 -90 1210 -90 {lab=OUT}
N 1180 -160 1180 -90 {lab=OUT}
N 1250 -130 1250 -120 {lab=#net4}
N 1250 -290 1250 -280 {lab=OUT}
N 1250 -280 1300 -280 {
lab=OUT}
N 1180 -310 1180 -280 {lab=OUT}
N 1250 -410 1250 -370 {lab=VDD}
N 1180 -320 1180 -310 {lab=OUT}
N 320 -220 380 -220 {
lab=VA}
N 420 -190 420 -180 {lab=#net5}
N 420 -150 460 -150 {lab=GND}
N 420 -220 450 -220 {lab=GND}
N 420 -60 460 -60 {lab=GND}
N 320 -150 380 -150 {
lab=IN}
N 420 -280 450 -280 {lab=OUT}
N 420 -280 420 -250 {lab=OUT}
N 530 -220 590 -220 {
lab=VB}
N 630 -190 630 -180 {lab=#net6}
N 630 -150 670 -150 {lab=GND}
N 630 -220 660 -220 {lab=GND}
N 630 -60 670 -60 {lab=GND}
N 530 -150 590 -150 {
lab=IN}
N 630 -280 660 -280 {lab=OUT}
N 630 -280 630 -250 {lab=OUT}
N 870 -280 1080 -280 {lab=OUT}
N 660 -280 840 -280 {lab=OUT}
N 450 -280 630 -280 {lab=OUT}
N 630 -320 630 -310 {
lab=IN}
N 700 -370 720 -370 {lab=VDD}
N 610 -370 630 -370 {lab=IN}
N 670 -440 670 -410 {lab=IN}
N 580 -440 630 -440 {lab=IN}
N 580 -440 580 -410 {lab=IN}
N 630 -440 630 -370 {lab=IN}
N 670 -370 670 -350 {lab=VDD}
N 670 -350 720 -350 {lab=VDD}
N 720 -370 720 -350 {lab=VDD}
N 670 -440 680 -440 {lab=IN}
N 540 -370 550 -370 {lab=#net7}
N 510 -440 580 -440 {lab=IN}
N 440 -370 440 -330 {lab=GND}
N 440 -440 440 -410 {lab=IN}
N 440 -440 510 -440 {lab=IN}
N 470 -370 480 -370 {lab=#net8}
N 630 -370 640 -370 {lab=IN}
N 630 -370 630 -320 {
lab=IN}
N 630 -440 660 -440 {lab=IN}
N 660 -440 670 -440 {lab=IN}
N 580 -370 580 -330 {lab=GND}
N 470 -370 480 -370 {lab=#net8}
N 510 -370 510 -330 {lab=GND}
N 510 -440 510 -410 {lab=IN}
N 340 -370 340 -330 {lab=GND}
N 370 -370 370 -330 {lab=GND}
N 400 -370 410 -370 {lab=#net9}
N 400 -370 410 -370 {lab=#net9}
N 370 -440 370 -410 {lab=IN}
N 370 -440 440 -440 {lab=IN}
C {devices/lab_wire.sym} 1310 -410 2 0 {name=p20 sig_type=std_logic lab=VDD}
C {symbols/pfet_06v0.sym} 1230 -320 0 0 {name=M2
L=1u
W=2u
nf=1
m=6
ad="'int((nf+1)/2) * W/nf * 0.18u'"
pd="'2*int((nf+1)/2) * (W/nf + 0.18u)'"
as="'int((nf+2)/2) * W/nf * 0.18u'"
ps="'2*int((nf+2)/2) * (W/nf + 0.18u)'"
nrd="'0.18u / W'" nrs="'0.18u / W'"
sa=0 sb=0 sd=0
model=pfet_06v0
spiceprefix=X
}
C {symbols/nfet_06v0.sym} 1060 -220 0 0 {name=M3
L=1u
W=2.48u
nf=1
m=2
ad="'int((nf+1)/2) * W/nf * 0.18u'"
pd="'2*int((nf+1)/2) * (W/nf + 0.18u)'"
as="'int((nf+2)/2) * W/nf * 0.18u'"
ps="'2*int((nf+2)/2) * (W/nf + 0.18u)'"
nrd="'0.18u / W'" nrs="'0.18u / W'"
sa=0 sb=0 sd=0
model=nfet_06v0
spiceprefix=X
}
C {devices/lab_wire.sym} 1110 -220 2 0 {name=p3 sig_type=std_logic lab=GND}
C {devices/lab_wire.sym} 1120 -150 2 0 {name=p4 sig_type=std_logic lab=GND}
C {devices/lab_wire.sym} 1120 -60 2 0 {name=p6 sig_type=std_logic lab=GND}
C {devices/lab_wire.sym} 990 -150 3 0 {name=p8 sig_type=std_logic lab=IN
}
C {symbols/nfet_06v0.sym} 820 -220 0 0 {name=M5
L=1u
W=2.48u
nf=1
m=2
ad="'int((nf+1)/2) * W/nf * 0.18u'"
pd="'2*int((nf+1)/2) * (W/nf + 0.18u)'"
as="'int((nf+2)/2) * W/nf * 0.18u'"
ps="'2*int((nf+2)/2) * (W/nf + 0.18u)'"
nrd="'0.18u / W'" nrs="'0.18u / W'"
sa=0 sb=0 sd=0
model=nfet_06v0
spiceprefix=X
}
C {symbols/nfet_06v0.sym} 820 -150 0 0 {name=M6
L=1u
W=1.24u
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
C {devices/lab_wire.sym} 870 -220 2 0 {name=p9 sig_type=std_logic lab=GND}
C {devices/lab_wire.sym} 880 -150 2 0 {name=p10 sig_type=std_logic lab=GND}
C {devices/lab_wire.sym} 880 -60 2 0 {name=p11 sig_type=std_logic lab=GND}
C {devices/lab_wire.sym} 750 -150 3 0 {name=p12 sig_type=std_logic lab=IN
}
C {symbols/nfet_06v0.sym} 1230 -230 0 0 {name=M1
L=1u
W=2u
nf=1
m=2
ad="'int((nf+1)/2) * W/nf * 0.18u'"
pd="'2*int((nf+1)/2) * (W/nf + 0.18u)'"
as="'int((nf+2)/2) * W/nf * 0.18u'"
ps="'2*int((nf+2)/2) * (W/nf + 0.18u)'"
nrd="'0.18u / W'" nrs="'0.18u / W'"
sa=0 sb=0 sd=0
model=nfet_06v0
spiceprefix=X
}
C {symbols/nfet_06v0.sym} 1230 -160 0 0 {name=M7
L=1u
W=2u
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
C {devices/lab_wire.sym} 1280 -230 2 0 {name=p15 sig_type=std_logic lab=GND}
C {devices/lab_wire.sym} 1290 -160 2 0 {name=p16 sig_type=std_logic lab=GND}
C {devices/lab_wire.sym} 1290 -60 2 0 {name=p17 sig_type=std_logic lab=GND}
C {symbols/nfet_06v0.sym} 1230 -90 0 0 {name=M8
L=1u
W=2u
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
C {devices/lab_wire.sym} 1290 -90 2 0 {name=p18 sig_type=std_logic lab=GND}
C {symbols/nfet_06v0.sym} 400 -220 0 0 {name=M9
L=1u
W=2.48u
nf=1
m=2
ad="'int((nf+1)/2) * W/nf * 0.18u'"
pd="'2*int((nf+1)/2) * (W/nf + 0.18u)'"
as="'int((nf+2)/2) * W/nf * 0.18u'"
ps="'2*int((nf+2)/2) * (W/nf + 0.18u)'"
nrd="'0.18u / W'" nrs="'0.18u / W'"
sa=0 sb=0 sd=0
model=nfet_06v0
spiceprefix=X
}
C {symbols/nfet_06v0.sym} 400 -150 0 0 {name=M10
L=1u
W=1.24u
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
C {devices/lab_wire.sym} 450 -220 2 0 {name=p22 sig_type=std_logic lab=GND}
C {devices/lab_wire.sym} 460 -150 2 0 {name=p23 sig_type=std_logic lab=GND}
C {devices/lab_wire.sym} 460 -60 2 0 {name=p24 sig_type=std_logic lab=GND}
C {devices/lab_wire.sym} 330 -150 3 0 {name=p25 sig_type=std_logic lab=IN
}
C {symbols/nfet_06v0.sym} 610 -220 0 0 {name=M11
L=1u
W=2.48u
nf=1
m=2
ad="'int((nf+1)/2) * W/nf * 0.18u'"
pd="'2*int((nf+1)/2) * (W/nf + 0.18u)'"
as="'int((nf+2)/2) * W/nf * 0.18u'"
ps="'2*int((nf+2)/2) * (W/nf + 0.18u)'"
nrd="'0.18u / W'" nrs="'0.18u / W'"
sa=0 sb=0 sd=0
model=nfet_06v0
spiceprefix=X
}
C {symbols/nfet_06v0.sym} 610 -150 0 0 {name=M12
L=1u
W=1.24u
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
C {devices/lab_wire.sym} 660 -220 2 0 {name=p7 sig_type=std_logic lab=GND}
C {devices/lab_wire.sym} 670 -150 2 0 {name=p13 sig_type=std_logic lab=GND}
C {devices/lab_wire.sym} 670 -60 2 0 {name=p14 sig_type=std_logic lab=GND}
C {devices/lab_wire.sym} 540 -150 3 0 {name=p26 sig_type=std_logic lab=IN
}
C {iopin.sym} 960 -380 0 0 {name=p27 lab=VDD}
C {iopin.sym} 960 -340 0 0 {name=p28 lab=GND}
C {ipin.sym} 320 -220 0 0 {name=p29 lab=VA}
C {ipin.sym} 530 -220 0 0 {name=p1 lab=VB}
C {ipin.sym} 740 -220 0 0 {name=p2 lab=VC}
C {ipin.sym} 980 -220 0 0 {name=p5 lab=VD}
C {iopin.sym} 1310 -280 0 0 {name=p21 lab=OUT}
C {symbols/nfet_06v0.sym} 1060 -150 0 0 {name=M4
L=1u
W=1.24u
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
C {symbols/pfet_06v0.sym} 670 -390 1 0 {name=M13
L=1u
W=2u
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
C {symbols/nfet_06v0.sym} 440 -390 1 0 {name=M14
L=1u
W=0.7u
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
C {devices/lab_wire.sym} 440 -330 3 0 {name=p30 sig_type=std_logic lab=GND}
C {devices/lab_wire.sym} 720 -370 1 0 {name=p31 sig_type=std_logic lab=VDD}
C {devices/lab_wire.sym} 630 -310 3 0 {name=p32 sig_type=std_logic lab=IN
}
C {devices/lab_wire.sym} 580 -330 3 0 {name=p33 sig_type=std_logic lab=GND}
C {devices/lab_wire.sym} 510 -330 3 0 {name=p34 sig_type=std_logic lab=GND}
C {symbols/nfet_06v0.sym} 510 -390 1 0 {name=M15
L=1u
W=0.7u
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
C {symbols/nfet_06v0.sym} 580 -390 1 0 {name=M16
L=1u
W=0.7u
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
C {devices/lab_wire.sym} 340 -330 3 0 {name=p35 sig_type=std_logic lab=GND}
C {symbols/nfet_06v0.sym} 370 -390 1 0 {name=M17
L=1u
W=0.7u
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
C {devices/lab_wire.sym} 370 -330 3 0 {name=p36 sig_type=std_logic lab=GND}
C {ammeter.sym} 420 -90 0 0 {name=Vmeas savecurrent=true spice_ignore=0}
C {ammeter.sym} 630 -90 0 0 {name=Vmeas1 savecurrent=true spice_ignore=0}
C {ammeter.sym} 840 -90 0 0 {name=Vmeas2 savecurrent=true spice_ignore=0}
C {ammeter.sym} 1080 -90 0 0 {name=Vmeas3 savecurrent=true spice_ignore=0}
