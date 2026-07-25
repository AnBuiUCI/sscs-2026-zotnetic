v {xschem version=3.4.8RC file_version=1.3}
G {}
K {}
V {}
S {}
F {}
E {}
P 4 1 -140 190 {}
N -170 220 40 220 {lab=VDD}
N -70 220 40 220 {lab=VDD}
N -70 140 -70 220 {lab=VDD}
N -170 280 40 280 {lab=#net1}
N -70 280 40 280 {lab=#net1}
N -170 250 -100 250 {lab=VDD}
N -100 220 -100 250 {lab=VDD}
N -40 250 40 250 {lab=#net1}
N -40 250 -40 280 {lab=#net1}
N -250 250 -210 250 {lab=VG}
N 80 250 120 250 {lab=VG}
N -440 460 -440 490 {lab=0}
N -440 340 -440 400 {lab=VSS}
N -360 460 -360 490 {lab=0}
N -360 340 -360 400 {lab=VDD}
N -280 460 -280 490 {lab=0}
N -280 350 -280 400 {lab=VG}
N -70 360 -70 380 {lab=VSS}
N -70 280 -70 300 {lab=#net1}
C {symbols/nfet_06v0.sym} 60 250 2 0 {name=M3
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
C {symbols/pfet_06v0.sym} -190 250 2 1 {name=M4
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
C {lab_pin.sym} -70 140 0 0 {name=p17 sig_type=std_logic lab=VDD}
C {lab_pin.sym} -250 250 0 0 {name=p19 sig_type=std_logic lab=VG}
C {lab_pin.sym} 120 250 2 0 {name=p20 sig_type=std_logic lab=VG}
C {code_shown.sym} 270 40 0 0 {name=NGSPICE only_toplevel=false value="
.control
op
dc VGATE 0 5 0.1
let resistance = v(VDD)/i(Vmeas)
print v(VG) resistance
end

.endc"

}
C {code_shown.sym} -480 0 0 0 {name=MODELS only_toplevel=false value=".include /foss/pdks/gf180mcuD/libs.tech/ngspice/design.ngspice
.lib /foss/pdks/gf180mcuD/libs.tech/ngspice/sm141064.ngspice typical"}
C {vsource.sym} -440 430 0 0 {name=V1 value=0 savecurrent=false}
C {gnd.sym} -440 490 0 0 {name=l1 lab=0}
C {lab_pin.sym} -440 350 0 0 {name=p2 sig_type=std_logic lab=VSS}
C {vsource.sym} -360 430 0 0 {name=V2 value=5 savecurrent=false}
C {gnd.sym} -360 490 0 0 {name=l2 lab=0}
C {lab_pin.sym} -360 350 0 0 {name=p4 sig_type=std_logic lab=VDD}
C {vsource.sym} -280 430 0 0 {name=VGATE value=2.5 savecurrent=false}
C {gnd.sym} -280 490 0 0 {name=l3 lab=0}
C {lab_pin.sym} -280 350 2 0 {name=p6 sig_type=std_logic lab=VG
}
C {lab_pin.sym} -70 380 0 0 {name=p5 sig_type=std_logic lab=VSS}
C {vsource.sym} -70 330 0 0 {name=Vmeas value=0 savecurrent=false}
