v {xschem version=3.4.8RC file_version=1.3}
G {}
K {}
V {}
S {}
F {}
E {}
P 4 1 -640 110 {}
N -670 140 -460 140 {lab=vout}
N -570 140 -460 140 {lab=vout}
N -670 200 -460 200 {lab=vinp}
N -570 200 -460 200 {lab=vinp}
N -670 170 -600 170 {lab=VDD}
N -540 170 -460 170 {lab=VSS}
N -570 200 -570 220 {lab=vinp}
N -750 170 -710 170 {lab=VP}
N -420 170 -380 170 {lab=VN}
N -570 110 -570 140 {lab=vout}
N -1100 370 -1100 400 {lab=0}
N -1100 250 -1100 310 {lab=VSS}
N -1020 370 -1020 400 {lab=0}
N -1020 250 -1020 310 {lab=VDD}
N -940 370 -940 400 {lab=0}
N -940 250 -940 310 {lab=VP}
N -860 370 -860 400 {lab=0}
N -860 250 -860 310 {lab=VN}
N -330 370 -330 400 {lab=0}
N -330 250 -330 310 {lab=vinp}
N -230 370 -230 400 {lab=0}
N -230 250 -230 310 {lab=vout}
C {symbols/nfet_06v0.sym} -440 170 2 0 {name=M53
L=1u
W=8u
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
C {symbols/pfet_06v0.sym} -690 170 2 1 {name=M54
L=1.0u
W=2.0u
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
C {lab_pin.sym} -750 170 0 0 {name=p14 sig_type=std_logic lab=VP}
C {lab_pin.sym} -380 170 2 0 {name=p16 sig_type=std_logic lab=VN}
C {vsource.sym} -1100 340 0 0 {name=V2 value=0 savecurrent=false}
C {gnd.sym} -1100 400 0 0 {name=l1 lab=0}
C {lab_pin.sym} -1100 260 0 0 {name=p7 sig_type=std_logic lab=VSS}
C {vsource.sym} -1020 340 0 0 {name=Vdd value=5 savecurrent=false}
C {gnd.sym} -1020 400 0 0 {name=l2 lab=0}
C {lab_pin.sym} -1020 260 0 0 {name=p8 sig_type=std_logic lab=VDD}
C {vsource.sym} -940 340 0 0 {name=VGP value=4 savecurrent=false}
C {gnd.sym} -940 400 0 0 {name=l3 lab=0}
C {lab_pin.sym} -940 260 0 0 {name=p10 sig_type=std_logic lab=VP}
C {lab_pin.sym} -520 170 0 0 {name=p1 sig_type=std_logic lab=VSS}
C {code_shown.sym} -1340 60 0 0 {name=MODELS only_toplevel=false value=".include /foss/pdks/gf180mcuD/libs.tech/ngspice/design.ngspice
.lib /foss/pdks/gf180mcuD/libs.tech/ngspice/sm141064.ngspice typical"}
C {code_shown.sym} -800 270 0 0 {name=NGSPICE only_toplevel=false value="
.control
save all
op
dc VOUT 0.5 5 0.1
let vres = v(vout) - v(vinp)
let ires = -i(vout)
let resistance = vres / ires

print v(VP) v(VN)
plot ires vs vres
plot resistance vs vres

.endc"

}
C {lab_pin.sym} -610 170 2 0 {name=p3 sig_type=std_logic lab=VDD}
C {vsource.sym} -860 340 0 0 {name=VGN value=1 savecurrent=false}
C {gnd.sym} -860 400 0 0 {name=VGN1 lab=0}
C {lab_pin.sym} -860 260 0 0 {name=VGN2 sig_type=std_logic lab=VN}
C {lab_pin.sym} -570 120 2 0 {name=p2 sig_type=std_logic lab=vout}
C {lab_pin.sym} -570 220 2 0 {name=p4 sig_type=std_logic lab=vinp}
C {vsource.sym} -330 340 0 0 {name=VINP value=0.001 savecurrent=false}
C {gnd.sym} -330 400 0 0 {name=l4 lab=0}
C {lab_pin.sym} -330 260 0 0 {name=p9 sig_type=std_logic lab=vinp}
C {vsource.sym} -230 340 0 0 {name=VOUT value=1 savecurrent=false}
C {gnd.sym} -230 400 0 0 {name=VOUT1 lab=0}
C {lab_pin.sym} -230 260 0 0 {name=VOUT2 sig_type=std_logic lab=vout}
