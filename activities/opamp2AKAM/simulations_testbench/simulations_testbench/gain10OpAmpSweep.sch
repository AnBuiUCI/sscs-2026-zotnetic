v {xschem version=3.4.8RC file_version=1.3}
G {}
K {}
V {}
S {}
F {}
E {}
N -310 110 -310 140 {lab=GND}
N -310 10 -310 50 {lab=vinn}
N -200 110 -200 140 {lab=GND}
N -200 10 -200 50 {lab=vinp}
N 260 120 260 150 {lab=GND}
N 260 20 260 60 {lab=vdd}
N 370 120 370 150 {lab=GND}
N 370 20 370 60 {lab=vss}
C {vsource.sym} -310 80 0 0 {name=V1 value=5V savecurrent=false}
C {gnd.sym} -310 140 0 0 {name=l6 lab=GND}
C {vsource.sym} -200 80 0 0 {name=V2 value=2.5V savecurrent=false}
C {gnd.sym} -200 140 0 0 {name=l5 lab=GND}
C {lab_pin.sym} -200 10 2 0 {name=p11 sig_type=std_logic lab=vinp}
C {lab_pin.sym} -310 10 2 0 {name=p1 sig_type=std_logic lab=vinn
}
C {lab_pin.sym} -100 -50 0 0 {name=p2 sig_type=std_logic lab=vinn
}
C {lab_pin.sym} -100 -30 0 0 {name=p3 sig_type=std_logic lab=vinp}
C {vsource.sym} 260 90 0 0 {name=V3 value=5V savecurrent=false}
C {gnd.sym} 260 150 0 0 {name=l1 lab=GND}
C {lab_pin.sym} 260 20 2 0 {name=p4 sig_type=std_logic lab=vdd}
C {vsource.sym} 370 90 0 0 {name=V4 value=0V savecurrent=false}
C {gnd.sym} 370 150 0 0 {name=l2 lab=GND}
C {lab_pin.sym} 370 20 2 0 {name=p5 sig_type=std_logic lab=vss}
C {lab_pin.sym} 200 -50 2 0 {name=p7 sig_type=std_logic lab=vdd
}
C {lab_pin.sym} 200 -10 2 0 {name=p6 sig_type=std_logic lab=vss}
C {code_shown.sym} -560 -220 0 0 {name=MODELS only_toplevel=false value=".include /foss/pdks/gf180mcuD/libs.tech/ngspice/design.ngspice
.lib /foss/pdks/gf180mcuD/libs.tech/ngspice/sm141064.ngspice typical
.lib /foss/pdks/gf180mcuD/libs.tech/ngspice/smbb000149.ngspice typical
.lib /foss/pdks/gf180mcuD/libs.tech/ngspice/sm141064.ngspice cap_mim
.lib /foss/pdks/gf180mcuD/libs.tech/ngspice/sm141064.ngspice mimcap_typical"}
C {code_shown.sym} 430 -410 0 0 {name=NGSPICE only_toplevel=false value="
*.tran 10p 0.3u
.dc V1 0 5 0.001
.save all
.control
run
let slope =deriv(v(net1))
meas dc minslope MIN slope
let gain = -minslope
print gain
plot slope

.endc"

}
C {/foss/designs/sscs-2026-zotnetic/activities/opamp2AKAM/simulations_testbench/simulations_testbench/gain10opAmp.sym} 50 -30 0 0 {name=x1}
