v {xschem version=3.4.8RC file_version=1.3}
G {}
K {}
V {}
S {}
F {}
E {}
N 110 -100 110 -80 {
lab=GND}
N 110 -220 110 -160 {
lab=VDD}
N 170 -220 170 -160 {
lab=IN}
N 170 -100 170 -80 {
lab=GND}
N 40 -100 40 -80 {
lab=GND}
N 40 -220 40 -160 {
lab=va}
N 390 60 420 60 {lab=OUT}
N 160 70 180 70 {lab=WE}
N -50 50 -20 50 {lab=va}
N -50 70 -20 70 {lab=va}
N -50 90 -20 90 {lab=va}
N -50 110 -20 110 {lab=va}
N 390 80 420 80 {lab=OUT_N}
N 170 70 170 100 {lab=WE}
C {devices/vsource.sym} 110 -130 0 0 {name=V1 value=5
}
C {devices/gnd.sym} 110 -80 0 0 {name=l1 lab=GND
value=5}
C {devices/lab_wire.sym} 110 -200 0 0 {name=p7 sig_type=std_logic lab=VDD}
C {devices/code_shown.sym} 475 -45 0 0 {name=s1
only_toplevel=false
value="
.tran 1m 1
*.dc V2 0 5 0.01
.save all
.control
run
display
wrdata OUT4.txt v(WE) v(OUT) v(OUT_N)
wrdata CURR4.txt i(v.x1.Vmeas) i(v.x1.Vmeas1) i(v.x1.Vmeas2) i(v.x1.Vmeas3)
plot i(v.x1.Vmeas) i(v.x1.Vmeas1) i(v.x1.Vmeas2) i(v.x1.Vmeas3)
*plot v(WE)
plot v(WE) v(OUT) v(OUT_N)
plot v(WE2) v(OUT2) v(OUT_N2)
*plot i(v.x1.v4)
.endc
"}
C {devices/code_shown.sym} 335 -225 0 0 {name=MODELS1 only_toplevel=true
format="tcleval( @value )"
value="
.include $::180MCU_MODELS/design.ngspice
.lib $::180MCU_MODELS/sm141064.ngspice typical
.lib $::180MCU_MODELS/sm141064.ngspice cap_mim
.lib $::180MCU_MODELS/sm141064.ngspice res_typical
.lib $::180MCU_MODELS/sm141064.ngspice moscap_typical
.lib $::180MCU_MODELS/sm141064.ngspice mimcap_typical
* .lib $::180MCU_MODELS/sm141064.ngspice res_statistical
"}
C {devices/lab_wire.sym} 170 -210 0 0 {name=p5 sig_type=std_logic lab=IN
}
C {devices/gnd.sym} 170 -80 0 0 {name=l2 lab=GND
value=5}
C {devices/vsource.sym} 170 -130 0 0 {name=V2 value=5
}
C {devices/vsource.sym} 40 -130 0 0 {name=V5 value=5
}
C {devices/gnd.sym} 40 -80 0 0 {name=l3 lab=GND
value=5}
C {devices/lab_wire.sym} 40 -200 0 0 {name=p13 sig_type=std_logic lab=va}
C {devices/lab_wire.sym} 70 20 0 0 {name=p8 sig_type=std_logic lab=VDD}
C {devices/lab_wire.sym} 420 60 2 0 {name=p9 sig_type=std_logic lab=OUT}
C {a_zonetic2026/XSCHEM/WEIGTH/WEIGHT.sym} 130 90 0 0 {name=x1}
C {a_zonetic2026/XSCHEM/WEIGTH/comp._out.sym} 330 90 0 0 {name=x2}
C {devices/lab_wire.sym} 230 30 0 0 {name=p4 sig_type=std_logic lab=VDD}
C {devices/gnd.sym} 70 140 0 0 {name=l6 lab=GND
value=5}
C {devices/gnd.sym} 230 110 0 0 {name=l7 lab=GND
value=5}
C {devices/lab_wire.sym} 420 80 2 0 {name=p17 sig_type=std_logic lab=OUT_N}
C {devices/lab_wire.sym} 170 100 2 0 {name=p1 sig_type=std_logic lab=WE}
C {devices/lab_wire.sym} -50 50 0 0 {name=p3 sig_type=std_logic lab=va}
C {devices/lab_wire.sym} -50 70 0 0 {name=p6 sig_type=std_logic lab=va}
C {devices/lab_wire.sym} -50 90 0 0 {name=p2 sig_type=std_logic lab=va}
C {devices/lab_wire.sym} -50 110 0 0 {name=p10 sig_type=std_logic lab=va}
C {devices/code_shown.sym} -30 250 0 0 {name=DUT1 only_toplevel=true
format="tcleval( @value )"
value="
.include "../../../../Layouts/WEIGHT_COMP/mag/WEIGHT_COMP_pex_rc.spice"
Xextrc GND VDD WE2 OUT2 OUT_N2 va va va va WEIGHT_COMP


"}
