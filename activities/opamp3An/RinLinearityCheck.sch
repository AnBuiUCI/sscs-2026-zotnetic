v {xschem version=3.4.8RC file_version=1.3}
G {}
K {}
V {}
S {}
F {}
E {}
P 4 1 110 -20 {}
N 80 10 290 10 {lab=vinn}
N 180 10 290 10 {lab=vinn}
N 80 70 290 70 {lab=VSS}
N 180 70 290 70 {lab=VSS}
N 80 40 150 40 {lab=VDD}
N 210 40 290 40 {lab=VSS}
N 180 70 180 90 {lab=VSS}
N 0 40 40 40 {lab=VP}
N 330 40 370 40 {lab=VN}
N 180 -20 180 10 {lab=vinn}
N -350 240 -350 270 {lab=0}
N -350 120 -350 180 {lab=VSS}
N -270 240 -270 270 {lab=0}
N -270 120 -270 180 {lab=VDD}
N -190 240 -190 270 {lab=0}
N -190 120 -190 180 {lab=VP}
N -110 240 -110 270 {lab=0}
N -110 120 -110 180 {lab=VN}
N 420 240 420 270 {lab=0}
N 420 120 420 180 {lab=vinn}
C {code_shown.sym} -380 -90 0 0 {name=MODELS only_toplevel=false value=".include /foss/pdks/gf180mcuD/libs.tech/ngspice/design.ngspice
.lib /foss/pdks/gf180mcuD/libs.tech/ngspice/sm141064.ngspice typical"}
C {symbols/nfet_06v0.sym} 310 40 2 0 {name=M1
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
C {symbols/pfet_06v0.sym} 60 40 2 1 {name=M2
L=1.0u
W=20.0u
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
C {lab_pin.sym} 0 40 0 0 {name=p2 sig_type=std_logic lab=VP}
C {lab_pin.sym} 370 40 2 0 {name=p4 sig_type=std_logic lab=VN}
C {vsource.sym} -350 210 0 0 {name=V1 value=0 savecurrent=false}
C {gnd.sym} -350 270 0 0 {name=l4 lab=0}
C {lab_pin.sym} -350 130 0 0 {name=p5 sig_type=std_logic lab=VSS}
C {vsource.sym} -270 210 0 0 {name=Vdd1 value=5 savecurrent=false}
C {gnd.sym} -270 270 0 0 {name=l5 lab=0}
C {lab_pin.sym} -270 130 0 0 {name=p6 sig_type=std_logic lab=VDD}
C {vsource.sym} -190 210 0 0 {name=VGP value=4 savecurrent=false}
C {gnd.sym} -190 270 0 0 {name=l6 lab=0}
C {lab_pin.sym} -190 130 0 0 {name=p9 sig_type=std_logic lab=VP}
C {lab_pin.sym} 230 40 0 0 {name=p11 sig_type=std_logic lab=VSS}
C {code_shown.sym} -50 140 0 0 {name=NGSPICE1 only_toplevel=false value="
.control
save all
op
dc VINN 0.1 2 0.1
let vres = v(vinn) - v(VSS)
let ires = -i(vinn)
let resistance = vres / ires

print v(VP) v(VN)
plot ires vs vres
plot resistance vs vres

.endc"

}
C {lab_pin.sym} 140 40 2 0 {name=p12 sig_type=std_logic lab=VDD}
C {vsource.sym} -110 210 0 0 {name=VGN value=1 savecurrent=false}
C {gnd.sym} -110 270 0 0 {name=VGN1 lab=0}
C {lab_pin.sym} -110 130 0 0 {name=VGN2 sig_type=std_logic lab=VN}
C {vsource.sym} 420 210 0 0 {name=VINN value=0.001 savecurrent=false}
C {gnd.sym} 420 270 0 0 {name=l7 lab=0}
C {lab_pin.sym} 420 130 0 0 {name=p17 sig_type=std_logic lab=vinn}
C {lab_pin.sym} 180 90 0 0 {name=p15 sig_type=std_logic lab=VSS}
C {lab_pin.sym} 180 -10 0 0 {name=p13 sig_type=std_logic lab=vinn}
