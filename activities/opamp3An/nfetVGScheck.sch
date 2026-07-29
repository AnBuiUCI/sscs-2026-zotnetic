v {xschem version=3.4.8RC file_version=1.3}
G {}
K {}
V {}
S {}
F {}
E {}
N -610 300 -610 330 {lab=0}
N -610 190 -610 240 {lab=VG}
N -270 170 -230 170 {lab=VG}
N -450 360 -450 390 {lab=0}
N -450 240 -450 300 {lab=VSS}
N -370 360 -370 390 {lab=0}
N -370 240 -370 300 {lab=VDD}
N -310 200 -310 250 {lab=VDD}
N -340 170 -310 170 {lab=VSS}
N -310 100 -310 140 {lab=VSS}
N -340 130 -340 170 {lab=VSS}
N -340 130 -310 130 {lab=VSS}
C {code_shown.sym} -590 10 0 0 {name=MODELS only_toplevel=false value=".include /foss/pdks/gf180mcuD/libs.tech/ngspice/design.ngspice
.lib /foss/pdks/gf180mcuD/libs.tech/ngspice/sm141064.ngspice typical"}
C {symbols/nfet_06v0.sym} -290 170 2 0 {name=M1
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
C {vsource.sym} -610 270 0 0 {name=VGATE value=2.5 savecurrent=false}
C {gnd.sym} -610 330 0 0 {name=l3 lab=0}
C {lab_pin.sym} -610 190 2 0 {name=p6 sig_type=std_logic lab=VG
}
C {lab_pin.sym} -250 170 2 0 {name=p1 sig_type=std_logic lab=VG
}
C {vsource.sym} -450 330 0 0 {name=V1 value=0 savecurrent=false}
C {gnd.sym} -450 390 0 0 {name=l4 lab=0}
C {lab_pin.sym} -450 250 0 0 {name=p5 sig_type=std_logic lab=VSS}
C {vsource.sym} -370 330 0 0 {name=Vdd1 value=.5 savecurrent=false}
C {gnd.sym} -370 390 0 0 {name=l5 lab=0}
C {lab_pin.sym} -370 250 0 0 {name=p3 sig_type=std_logic lab=VDD}
C {lab_pin.sym} -310 120 0 0 {name=p4 sig_type=std_logic lab=VSS}
C {lab_pin.sym} -310 230 2 0 {name=p9 sig_type=std_logic lab=VDD}
C {code_shown.sym} -180 120 0 0 {name=NGSPICE only_toplevel=false value="
.control
op
dc VGATE 0 5 0.1
let resistance = v(VDD)/i(v1)
print v(VG) resistance
plot v(VDD)/i(v1)
plot i(v1) vs v(VG)

.endc"

}
