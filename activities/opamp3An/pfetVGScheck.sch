v {xschem version=3.4.8RC file_version=1.3}
G {}
K {}
V {}
S {}
F {}
E {}
N -110 230 -110 260 {lab=0}
N -110 120 -110 170 {lab=VG}
N 160 100 200 100 {lab=VG}
N 50 290 50 320 {lab=0}
N 50 170 50 230 {lab=VSS}
N 130 290 130 320 {lab=0}
N 130 170 130 230 {lab=VDD}
N 240 100 300 100 {lab=VDD}
N 240 40 240 70 {lab=VDD}
N 240 130 240 170 {lab=VSS}
C {code_shown.sym} -90 -60 0 0 {name=MODELS only_toplevel=false value=".include /foss/pdks/gf180mcuD/libs.tech/ngspice/design.ngspice
.lib /foss/pdks/gf180mcuD/libs.tech/ngspice/sm141064.ngspice typical"}
C {symbols/pfet_06v0.sym} 220 100 2 1 {name=M2
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
C {vsource.sym} -110 200 0 0 {name=VGATE value=2.5 savecurrent=false}
C {gnd.sym} -110 260 0 0 {name=l3 lab=0}
C {lab_pin.sym} -110 120 2 0 {name=p6 sig_type=std_logic lab=VG
}
C {lab_pin.sym} 180 100 0 0 {name=p2 sig_type=std_logic lab=VG
}
C {vsource.sym} 50 260 0 0 {name=V1 value=0 savecurrent=false}
C {gnd.sym} 50 320 0 0 {name=l4 lab=0}
C {lab_pin.sym} 50 180 0 0 {name=p5 sig_type=std_logic lab=VSS}
C {vsource.sym} 130 260 0 0 {name=Vdd1 value=5 savecurrent=false}
C {gnd.sym} 130 320 0 0 {name=l5 lab=0}
C {lab_pin.sym} 130 180 0 0 {name=p3 sig_type=std_logic lab=VDD}
C {lab_pin.sym} 290 100 2 0 {name=p7 sig_type=std_logic lab=VDD}
C {lab_pin.sym} 240 60 2 0 {name=p8 sig_type=std_logic lab=VDD}
C {lab_pin.sym} 240 160 0 0 {name=p10 sig_type=std_logic lab=VSS}
C {code_shown.sym} 380 50 0 0 {name=NGSPICE only_toplevel=false value="
.control
op
dc VGATE 0 5 0.1
let resistance = v(VDD)/i(v1)
print v(VG) resistance
plot v(VDD)/i(v1)
plot i(v1) vs v(VG)

.endc"

}
