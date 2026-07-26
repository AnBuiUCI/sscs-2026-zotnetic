v {xschem version=3.4.8RC file_version=1.3}
G {}
K {}
V {}
S {}
F {}
E {}
P 4 1 -460 140 {}
N -490 170 -280 170 {lab=VDD}
N -390 170 -280 170 {lab=VDD}
N -390 90 -390 170 {lab=VDD}
N -490 230 -280 230 {lab=#net1}
N -390 230 -280 230 {lab=#net1}
N -490 200 -420 200 {lab=VDD}
N -420 170 -420 200 {lab=VDD}
N -360 200 -280 200 {lab=#net1}
N -360 200 -360 230 {lab=#net1}
N -570 200 -530 200 {lab=VG}
N -240 200 -200 200 {lab=VG}
N -760 410 -760 440 {lab=0}
N -760 290 -760 350 {lab=VSS}
N -680 410 -680 440 {lab=0}
N -680 290 -680 350 {lab=VDD}
N -600 410 -600 440 {lab=0}
N -600 300 -600 350 {lab=VG}
N -390 310 -390 330 {lab=VSS}
N -390 230 -390 250 {lab=#net1}
C {symbols/nfet_06v0.sym} -260 200 2 0 {name=M3
L=3u
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
C {symbols/pfet_06v0.sym} -510 200 2 1 {name=M4
L=3.0u
W=1.35u
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
C {lab_pin.sym} -390 90 0 0 {name=p17 sig_type=std_logic lab=VDD}
C {lab_pin.sym} -570 200 0 0 {name=p19 sig_type=std_logic lab=VG}
C {lab_pin.sym} -200 200 2 0 {name=p20 sig_type=std_logic lab=VG}
C {code_shown.sym} -50 -10 0 0 {name=NGSPICE only_toplevel=false value="
.control
op
dc VGATE 0 5 0.1
let resistance = v(VDD)/i(Vmeas)
print v(VG) resistance
plot v(VDD)/i(Vmeas)
end

.endc"

}
C {code_shown.sym} -800 -50 0 0 {name=MODELS only_toplevel=false value=".include /foss/pdks/gf180mcuD/libs.tech/ngspice/design.ngspice
.lib /foss/pdks/gf180mcuD/libs.tech/ngspice/sm141064.ngspice typical"}
C {vsource.sym} -760 380 0 0 {name=V1 value=0 savecurrent=false}
C {gnd.sym} -760 440 0 0 {name=l1 lab=0}
C {lab_pin.sym} -760 300 0 0 {name=p2 sig_type=std_logic lab=VSS}
C {vsource.sym} -680 380 0 0 {name=V2 value=5 savecurrent=false}
C {gnd.sym} -680 440 0 0 {name=l2 lab=0}
C {lab_pin.sym} -680 300 0 0 {name=p4 sig_type=std_logic lab=VDD}
C {vsource.sym} -600 380 0 0 {name=VGATE value=2.5 savecurrent=false}
C {gnd.sym} -600 440 0 0 {name=l3 lab=0}
C {lab_pin.sym} -600 300 2 0 {name=p6 sig_type=std_logic lab=VG
}
C {lab_pin.sym} -390 330 0 0 {name=p5 sig_type=std_logic lab=VSS}
C {vsource.sym} -390 280 0 0 {name=Vmeas value=0 savecurrent=false}
