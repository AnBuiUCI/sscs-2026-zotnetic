v {xschem version=3.4.8RC file_version=1.3}
G {}
K {}
V {}
S {}
F {}
E {}
N 80 110 90 110 {lab=va}
N 80 70 90 70 {lab=vb}
N 150 20 150 30 {lab=VDD}
N 250 90 260 90 {lab=OUT}
N 150 150 150 160 {lab=GND}
C {devices/vsource.sym} 110 -130 0 0 {name=V1 value=5
}
C {devices/gnd.sym} 110 -100 0 0 {name=l1 lab=GND
value=5}
C {devices/lab_wire.sym} 110 -160 0 0 {name=p7 sig_type=std_logic lab=VDD}
C {devices/code_shown.sym} 475 -45 0 0 {name=s1
only_toplevel=false
value="
*.tran 1m 1
.dc V5 -5m 5m 50u
.save all
.control
run
display
*wrdata OUT4.txt v(WE) v(OUT) v(OUT_N)
*wrdata CURR4.txt i(v.x1.Vmeas) i(v.x1.Vmeas1) i(v.x1.Vmeas2) i(v.x1.Vmeas3)
*plot i(v.x1.Vmeas) i(v.x1.Vmeas1) i(v.x1.Vmeas2) i(v.x1.Vmeas3)
plot v(OUT) v(OUT1)
plot v(OUT)
plot v(OUT1)
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
C {devices/vsource.sym} 40 -130 0 0 {name=V5 value=5
}
C {devices/lab_wire.sym} 40 -160 0 0 {name=p13 sig_type=std_logic lab=va}
C {devices/lab_wire.sym} 150 20 0 0 {name=p8 sig_type=std_logic lab=VDD}
C {devices/lab_wire.sym} 260 90 2 0 {name=p9 sig_type=std_logic lab=OUT}
C {devices/gnd.sym} 150 160 0 0 {name=l6 lab=GND
value=5}
C {devices/code_shown.sym} -160 230 0 0 {name=DUT1 only_toplevel=true
format="tcleval( @value )"
value="
.include "../../../../Layouts/COMP/mag/COMP_pex_rc.spice"
Xextrc GND VDD OUT1 va vb COMP
*Xextrc VSS VDD OUT IN+ IN- COMP

"}
C {devices/lab_wire.sym} 40 -100 0 0 {name=p1 sig_type=std_logic lab=vb}
C {devices/lab_wire.sym} 80 110 0 0 {name=p2 sig_type=std_logic lab=va}
C {devices/lab_wire.sym} 80 70 0 0 {name=p3 sig_type=std_logic lab=vb}
C {a_zonetic2026/XSCHEM/OPAM/COMP_sc.sym} 150 90 0 0 {name=x1}
