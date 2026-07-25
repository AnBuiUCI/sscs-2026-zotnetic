v {xschem version=3.4.8RC file_version=1.3}
G {}
K {}
V {}
S {}
F {}
E {}
P 4 1 -250 200 {}
N -280 230 -70 230 {lab=VDD}
N -180 230 -70 230 {lab=VDD}
N -180 150 -180 230 {lab=VDD}
N -280 290 -70 290 {lab=#net1}
N -180 290 -70 290 {lab=#net1}
N -280 260 -210 260 {lab=VDD}
N -210 230 -210 260 {lab=VDD}
N -150 260 -70 260 {lab=#net1}
N -150 260 -150 290 {lab=#net1}
N -360 260 -320 260 {lab=VG}
N -30 260 10 260 {lab=VG}
N -550 470 -550 500 {lab=0}
N -550 350 -550 410 {lab=VSS}
N -470 470 -470 500 {lab=0}
N -470 350 -470 410 {lab=VDD}
N -390 470 -390 500 {lab=0}
N -390 360 -390 410 {lab=VG}
N -180 370 -180 390 {lab=VSS}
N -180 290 -180 310 {lab=#net1}
C {symbols/nfet_06v0.sym} -50 260 2 0 {name=M3
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
C {symbols/pfet_06v0.sym} -300 260 2 1 {name=M4
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
C {lab_pin.sym} -180 150 0 0 {name=p17 sig_type=std_logic lab=VDD}
C {lab_pin.sym} -360 260 0 0 {name=p19 sig_type=std_logic lab=VG}
C {lab_pin.sym} 10 260 2 0 {name=p20 sig_type=std_logic lab=VG}
C {code_shown.sym} 160 50 0 0 {name=NGSPICE only_toplevel=false value="
.control
op
dc VGATE 0 5 0.1
let resistance = v(VDD)/i(Vmeas)
print v(VG) resistance
end

.endc"

}
C {code_shown.sym} -590 10 0 0 {name=MODELS only_toplevel=false value=".include /foss/pdks/gf180mcuD/libs.tech/ngspice/design.ngspice
.lib /foss/pdks/gf180mcuD/libs.tech/ngspice/sm141064.ngspice typical"}
C {vsource.sym} -550 440 0 0 {name=V1 value=0 savecurrent=false}
C {gnd.sym} -550 500 0 0 {name=l1 lab=0}
C {lab_pin.sym} -550 360 0 0 {name=p2 sig_type=std_logic lab=VSS}
C {vsource.sym} -470 440 0 0 {name=V2 value=5 savecurrent=false}
C {gnd.sym} -470 500 0 0 {name=l2 lab=0}
C {lab_pin.sym} -470 360 0 0 {name=p4 sig_type=std_logic lab=VDD}
C {vsource.sym} -390 440 0 0 {name=VGATE value=2.5 savecurrent=false}
C {gnd.sym} -390 500 0 0 {name=l3 lab=0}
C {lab_pin.sym} -390 360 2 0 {name=p6 sig_type=std_logic lab=VG
}
C {lab_pin.sym} -180 390 0 0 {name=p5 sig_type=std_logic lab=VSS}
C {vsource.sym} -180 340 0 0 {name=Vmeas value=0 savecurrent=false}
