v {xschem version=3.4.8RC file_version=1.3}
G {}
K {}
V {}
S {}
F {}
E {}
P 4 1 490 -350 {}
P 4 1 160 120 {}
N -30 -80 70 -80 {lab=#net1}
N -30 -60 70 -60 {lab=#net2}
N -30 -20 70 20 {lab=#net3}
N -30 -40 70 0 {lab=#net4}
N -30 0 -30 40 {lab=VSS}
N 370 -40 370 0 {lab=VSS}
N 370 -130 370 -80 {lab=VDD}
N -30 -150 -30 -100 {lab=VDD}
N 370 -60 460 -60 {lab=vout}
N -410 220 -410 250 {lab=0}
N -410 100 -410 160 {lab=VSS}
N -330 220 -330 250 {lab=0}
N -330 100 -330 160 {lab=VDD}
N -250 220 -250 250 {lab=0}
N -250 100 -250 160 {lab=VG}
N -140 210 -140 240 {lab=0}
N -140 90 -140 150 {lab=vinp}
N 460 -320 670 -320 {lab=vinp}
N 560 -320 670 -320 {lab=vinp}
N 460 -260 670 -260 {lab=#net5}
N 560 -260 670 -260 {lab=#net5}
N 460 -290 530 -290 {lab=vinp}
N 530 -320 530 -290 {lab=vinp}
N 590 -290 670 -290 {lab=#net5}
N 590 -290 590 -260 {lab=#net5}
N 560 -260 560 -240 {lab=#net5}
N 380 -290 420 -290 {lab=VG}
N 710 -290 750 -290 {lab=VG}
N 130 150 340 150 {lab=VSS}
N 230 150 340 150 {lab=VSS}
N 230 70 230 150 {lab=VSS}
N 130 210 340 210 {lab=#net6}
N 230 210 340 210 {lab=#net6}
N 130 180 200 180 {lab=VSS}
N 200 150 200 180 {lab=VSS}
N 260 180 340 180 {lab=#net6}
N 260 180 260 210 {lab=#net6}
N 230 210 230 230 {lab=#net6}
N 50 180 90 180 {lab=VG}
N 380 180 420 180 {lab=VG}
N -60 210 -60 240 {lab=0}
N -60 90 -60 150 {lab=vinn}
N 560 -350 560 -320 {lab=vinp}
N 560 -180 560 -150 {lab=vout}
N 230 290 230 330 {lab=vinn}
C {activities/opamp2AKAM/opamp.sym} 220 -30 0 0 {name=x1}
C {activities/opamp2AKAM/bias.sym} -180 -50 0 0 {name=x2}
C {lab_pin.sym} -30 30 0 0 {name=p2 sig_type=std_logic lab=VSS}
C {lab_pin.sym} 370 -10 0 0 {name=p3 sig_type=std_logic lab=VSS}
C {lab_pin.sym} 370 -120 0 0 {name=p5 sig_type=std_logic lab=VDD}
C {lab_pin.sym} -30 -140 0 0 {name=p6 sig_type=std_logic lab=VDD}
C {lab_pin.sym} 70 -20 0 0 {name=p7 sig_type=std_logic lab=vinp}
C {vsource.sym} -410 190 0 0 {name=V1 value=0 savecurrent=false}
C {gnd.sym} -410 250 0 0 {name=l1 lab=0}
C {lab_pin.sym} -410 110 0 0 {name=p1 sig_type=std_logic lab=VSS}
C {vsource.sym} -330 190 0 0 {name=V2 value=5 savecurrent=false}
C {gnd.sym} -330 250 0 0 {name=l2 lab=0}
C {lab_pin.sym} -330 110 0 0 {name=p4 sig_type=std_logic lab=VDD}
C {vsource.sym} -250 190 0 0 {name=VGATE value=2.5 savecurrent=false}
C {gnd.sym} -250 250 0 0 {name=l3 lab=0}
C {lab_pin.sym} -250 110 0 0 {name=p10 sig_type=std_logic lab=VG}
C {code_shown.sym} -460 -350 0 0 {name=MODELS only_toplevel=false 
value="
.include /foss/pdks/gf180mcuD/libs.tech/ngspice/design.ngspice
.lib /foss/pdks/gf180mcuD/libs.tech/ngspice/sm141064.ngspice typical
.lib /foss/pdks/gf180mcuD/libs.tech/ngspice/smbb000149.ngspice typical
.lib /foss/pdks/gf180mcuD/libs.tech/ngspice/sm141064.ngspice cap_mim
.lib /foss/pdks/gf180mcuD/libs.tech/ngspice/sm141064.ngspice mimcap_typical
"}
C {code_shown.sym} 540 -70 0 0 {name=NGSPICE 
only_toplevel=false 
value="
*.tran 1ms 100ms
.dc VINP 0 5 0.1
.save all
.control
run
display
plot v(vinn)
plot v(vinp)
plot v(vout)
plot v(vout) vs v(vinp)
let slope =deriv(v(vout))
meas dc minslope MIN slope
let gain = minslope
print gain
plot slope
let Rin = v(VSS)/i(Vin)
print Rin
let Rf = v(vinp)/i(Vfeedback)
print Ref
.endc
"}
C {vsource.sym} -140 180 0 0 {name=VINP value=1 savecurrent=false}
C {gnd.sym} -140 240 0 0 {name=l4 lab=0}
C {lab_pin.sym} -140 100 0 0 {name=p8 sig_type=std_logic lab=vinp}
C {symbols/nfet_06v0.sym} 690 -290 2 0 {name=M1
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
C {symbols/pfet_06v0.sym} 440 -290 2 1 {name=M2
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
C {lab_pin.sym} 560 -340 0 0 {name=p9 sig_type=std_logic lab=vinp}
C {lab_pin.sym} 560 -160 0 0 {name=p11 sig_type=std_logic lab=vout}
C {lab_pin.sym} 460 -60 2 0 {name=p12 sig_type=std_logic lab=vout}
C {lab_pin.sym} 380 -290 0 0 {name=p14 sig_type=std_logic lab=VG}
C {lab_pin.sym} 750 -290 2 0 {name=p16 sig_type=std_logic lab=VG}
C {symbols/nfet_06v0.sym} 360 180 2 0 {name=M3
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
C {symbols/pfet_06v0.sym} 110 180 2 1 {name=M4
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
C {lab_pin.sym} 230 70 0 0 {name=p17 sig_type=std_logic lab=VSS}
C {lab_pin.sym} 230 320 0 0 {name=p18 sig_type=std_logic lab=vinn}
C {lab_pin.sym} 50 180 0 0 {name=p19 sig_type=std_logic lab=VG}
C {lab_pin.sym} 420 180 2 0 {name=p20 sig_type=std_logic lab=VG}
C {lab_pin.sym} 70 -40 0 0 {name=p21 sig_type=std_logic lab=vinn}
C {vsource.sym} -60 180 0 0 {name=VINN value=0 savecurrent=false}
C {gnd.sym} -60 240 0 0 {name=VINN1 lab=0}
C {lab_pin.sym} -60 100 0 0 {name=VINN2 sig_type=std_logic lab=vinn}
C {vsource.sym} 560 -210 0 0 {name=Vfeedback value=0 savecurrent=false}
C {vsource.sym} 230 260 0 0 {name=Vin value=0 savecurrent=false}
