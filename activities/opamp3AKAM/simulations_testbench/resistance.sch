v {xschem version=3.4.8RC file_version=1.3}
G {}
K {}
V {}
S {}
F {}
E {}
P 4 1 10 0 {}
N -10 130 200 130 {lab=VDD}
N 90 130 200 130 {lab=VDD}
N 90 50 90 130 {lab=VDD}
N -10 190 200 190 {lab=#net1}
N 90 190 200 190 {lab=#net1}
N -100 160 -50 160 {lab=VG1}
N 240 160 320 160 {lab=VG2}
N -410 350 -410 380 {lab=0}
N -410 230 -410 290 {lab=VSS}
N -330 350 -330 380 {lab=0}
N -330 230 -330 290 {lab=VDD}
N -10 160 60 160 {lab=VDD}
N 60 130 60 160 {lab=VDD}
N 120 160 200 160 {lab=#net1}
N 120 160 120 190 {lab=#net1}
N -250 350 -250 380 {lab=0}
N -160 350 -160 380 {lab=0}
N -250 240 -250 290 {lab=VG1}
N -160 240 -160 290 {lab=VG2}
N 90 270 90 290 {lab=VSS}
N 90 190 90 210 {lab=#net1}
C {code_shown.sym} -280 -110 0 0 {name=MODELS only_toplevel=false value=".include /foss/pdks/gf180mcuD/libs.tech/ngspice/design.ngspice
.lib /foss/pdks/gf180mcuD/libs.tech/ngspice/sm141064.ngspice typical"}
C {symbols/nfet_06v0.sym} 220 160 2 0 {name=M2
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
C {symbols/pfet_06v0.sym} -30 160 2 1 {name=M8
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
C {lab_pin.sym} -100 160 0 0 {name=p10 sig_type=std_logic lab=VG1
}
C {lab_pin.sym} 320 160 2 0 {name=p1 sig_type=std_logic lab=VG2}
C {vsource.sym} -410 320 0 0 {name=V1 value=0 savecurrent=false}
C {gnd.sym} -410 380 0 0 {name=l1 lab=0}
C {lab_pin.sym} -410 240 0 0 {name=p2 sig_type=std_logic lab=VSS}
C {vsource.sym} -330 320 0 0 {name=V2 value=5 savecurrent=false}
C {gnd.sym} -330 380 0 0 {name=l2 lab=0}
C {lab_pin.sym} -330 240 0 0 {name=p4 sig_type=std_logic lab=VDD}
C {lab_pin.sym} 90 50 0 0 {name=p3 sig_type=std_logic lab=VDD}
C {lab_pin.sym} 90 290 0 0 {name=p5 sig_type=std_logic lab=VSS}
C {vsource.sym} -250 320 0 0 {name=V3 value=2.5 savecurrent=false}
C {vsource.sym} -160 320 0 0 {name=V4 value=2.5 savecurrent=false}
C {gnd.sym} -250 380 0 0 {name=l3 lab=0}
C {gnd.sym} -160 380 0 0 {name=l4 lab=0}
C {lab_pin.sym} -250 240 2 0 {name=p6 sig_type=std_logic lab=VG1
}
C {lab_pin.sym} -160 240 2 0 {name=p7 sig_type=std_logic lab=VG2

}
C {code_shown.sym} 450 110 0 0 {name=NGSPICE only_toplevel=false value="
.control
op
echo \\"VG1 VG2 Resistance\\" > /foss/designs/sscs-2026-zotnetic/activities/opamp3AKAM/simulations_results/resistance.txt
let b1 = 0
let b2 = 0

while b1 <= 5
    alter v3 $&b1
    while b2 <=5
	alter v4 $&b2
	let b3 = v(VDD)/i(Vmeas)
	echo \\"$&b1 $&b2 $&b3\\" >> /foss/designs/sscs-2026-zotnetic/activities/opamp3AKAM/simulations_results/resistance.txt
	let b2 = b2 +0.5
    end
    let b2 = 0
    let b1 = b1 +0.5
end

.endc"

}
C {vsource.sym} 90 240 0 0 {name=Vmeas value=0 savecurrent=false}
