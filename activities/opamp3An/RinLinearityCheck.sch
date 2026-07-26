v {xschem version=3.4.8RC file_version=1.3}
G {}
K {}
V {}
S {}
F {}
E {}
P 4 1 320 -40 {}
N 290 -10 500 -10 {lab=VDD}
N 390 -10 500 -10 {lab=VDD}
N 290 50 500 50 {lab=VSS}
N 390 50 500 50 {lab=VSS}
N 290 20 360 20 {lab=VDD}
N 360 -10 360 20 {lab=VDD}
N 420 20 500 20 {lab=VSS}
N 420 20 420 50 {lab=VSS}
N 390 50 390 70 {lab=VSS}
N 210 20 250 20 {lab=VG}
N 540 20 580 20 {lab=VG}
N 390 -40 390 -10 {lab=VDD}
N -140 220 -140 250 {lab=0}
N -140 100 -140 160 {lab=VSS}
N -60 220 -60 250 {lab=0}
N -60 100 -60 160 {lab=VDD}
N 20 220 20 250 {lab=0}
N 20 100 20 160 {lab=VG}
C {symbols/nfet_06v0.sym} 520 20 2 0 {name=M53
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
C {symbols/pfet_06v0.sym} 270 20 2 1 {name=M54
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
C {lab_pin.sym} 210 20 0 0 {name=p14 sig_type=std_logic lab=VG}
C {lab_pin.sym} 580 20 2 0 {name=p16 sig_type=std_logic lab=VG}
C {vsource.sym} -140 190 0 0 {name=V2 value=0 savecurrent=false}
C {gnd.sym} -140 250 0 0 {name=l1 lab=0}
C {lab_pin.sym} -140 110 0 0 {name=p7 sig_type=std_logic lab=VSS}
C {vsource.sym} -60 190 0 0 {name=Vdd value=5 savecurrent=false}
C {gnd.sym} -60 250 0 0 {name=l2 lab=0}
C {lab_pin.sym} -60 110 0 0 {name=p8 sig_type=std_logic lab=VDD}
C {vsource.sym} 20 190 0 0 {name=VGATE value=2.5 savecurrent=false}
C {gnd.sym} 20 250 0 0 {name=l3 lab=0}
C {lab_pin.sym} 20 110 0 0 {name=p10 sig_type=std_logic lab=VG}
C {lab_pin.sym} 390 60 0 0 {name=p1 sig_type=std_logic lab=VSS}
C {code_shown.sym} -380 -90 0 0 {name=MODELS only_toplevel=false value=".include /foss/pdks/gf180mcuD/libs.tech/ngspice/design.ngspice
.lib /foss/pdks/gf180mcuD/libs.tech/ngspice/sm141064.ngspice typical"}
C {code_shown.sym} 160 120 0 0 {name=NGSPICE only_toplevel=false value="
.control
op
dc Vdd 0 5 0.1
let resistance = v(VDD)/i(V2)
print v(VG) resistance
plot resistance vs v(VDD)
plot i(Vdd) vs v(VDD)
end

.endc"
}
C {lab_pin.sym} 390 -30 0 0 {name=p3 sig_type=std_logic lab=VDD}
