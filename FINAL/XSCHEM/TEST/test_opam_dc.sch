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
C {devices/vsource.sym} -70 -120 0 0 {name=V5 value=5
}
C {devices/lab_wire.sym} -70 -150 0 0 {name=p13 sig_type=std_logic lab=va}
C {devices/lab_wire.sym} 150 20 0 0 {name=p8 sig_type=std_logic lab=VDD}
C {devices/lab_wire.sym} 260 90 2 0 {name=p9 sig_type=std_logic lab=OUT}
C {devices/gnd.sym} 150 160 0 0 {name=l6 lab=GND
value=5}
C {devices/code_shown.sym} -160 230 0 0 {name=DUT1 only_toplevel=true
format="tcleval( @value )"
value="
.include "../../../../Layouts/OPAM/mag/OPAM_pex_rc.spice"
Xextrc GND VDD1 OUT1 va vb OPAM
*Xextrc VSS VDD OUT INP INN OPAM

"}
C {devices/lab_wire.sym} 20 -140 0 0 {name=p1 sig_type=std_logic lab=vb}
C {devices/lab_wire.sym} 80 110 0 0 {name=p2 sig_type=std_logic lab=va}
C {devices/lab_wire.sym} 80 70 0 0 {name=p3 sig_type=std_logic lab=vb}
C {a_zonetic2026/XSCHEM/OPAM/OPAMt.sym} 190 90 0 0 {name=x1}
C {devices/code_shown.sym} 535 -25 0 0 {name=s2
only_toplevel=false
value="
*.tran 1m 1
.dc V5 2.45 2.55 50u
.save all
.control
run
display
let slope =deriv(v(OUT))
meas dc minslope MIN slope
let gain = -minslope
print gain
plot slope

let slope1 =deriv(v(OUT1))
meas dc minslope1 MIN slope1
let gain1 = -minslope1
print gain1
plot slope1
plot v(OUT) v(OUT1)
plot v(VDD)*i(v1) v(VDD1)*i(v2)
wrdata OUTPUT.txt v(OUT) v(OUT1)
wrdata SLOPE.txt slope slope1
wrdata POWER.txt v(VDD)*i(v1) v(VDD1)*i(v2)
.endc
"}
C {devices/vsource.sym} 180 -130 0 0 {name=V2 value=5
}
C {devices/gnd.sym} 180 -100 0 0 {name=l2 lab=GND
value=5}
C {devices/lab_wire.sym} 180 -160 0 0 {name=p4 sig_type=std_logic lab=VDD1}
C {devices/vsource.sym} 20 -110 0 0 {name=V3 value=2.5
}
C {devices/gnd.sym} 20 -80 0 0 {name=l3 lab=GND
value=5}
C {devices/gnd.sym} -70 -90 0 0 {name=l4 lab=GND
value=5}
