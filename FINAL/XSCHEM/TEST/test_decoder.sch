v {xschem version=3.4.8RC file_version=1.3}
G {}
K {}
V {}
S {}
F {}
E {}
N 50 60 50 80 {
lab=GND}
N 50 -60 50 0 {
lab=VXY}
N -90 70 -90 90 {
lab=GND}
N -90 -50 -90 10 {
lab=VXZ}
N -220 50 -220 70 {
lab=GND}
N -220 -70 -220 -10 {
lab=VYZ}
N 200 50 220 50 {lab=VYZ}
N 200 30 220 30 {lab=VXZ}
N 200 10 220 10 {lab=VXY}
N 310 90 310 100 {lab=GND}
N 390 50 410 50 {lab=Z}
N 390 30 410 30 {lab=Y}
N 390 10 410 10 {lab=X}
N 310 -30 310 -20 {lab=VDD}
C {devices/vsource.sym} 70 -140 0 0 {name=V1 value=5
}
C {devices/gnd.sym} 70 -110 0 0 {name=l1 lab=GND
value=5}
C {devices/lab_wire.sym} 70 -170 0 0 {name=p7 sig_type=std_logic lab=VDD}
C {devices/code_shown.sym} 475 -45 0 0 {name=s1
only_toplevel=false
value="
.tran 100u 1
.save all
.control
run
wrdata in.txt    v(VXY) v(VXZ) v(VYZ)
wrdata outX.txt  v(X) v(X1) v(X2)
wrdata outY.txt  v(Y) v(Y1) v(Y2)
wrdata outZ.txt  v(Z) v(Z1) v(Z2)
wrdata power.txt v(VDD)*i(v1) v(VDD1)*i(v2) v(VDD2)*i(v9)
plot v(VXY) v(VXZ) v(VYZ)
plot v(X) v(X1)
plot v(Y) v(Y1)
plot v(Z) v(Z1)
plot v(VDD)*i(v1) v(VDD1)*i(v2)
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
C {devices/lab_wire.sym} 310 -30 0 0 {name=p8 sig_type=std_logic lab=VDD}
C {devices/code_shown.sym} -230 130 0 0 {name=DUT1 only_toplevel=true
format="tcleval( @value )"
value="
.include "../../../../Layouts/DECODER/mag/DECODER_pex_rc_LAY.spice"
Xextrc GND VDD1 VYZ Z1 VXY VXZ Y1 X1 DECODER_LAY
.include "../../../../layouts_v2/DECODER/mag/DECODER_V2_pex_rc.spice"
Xextrc2 GND VDD2 VYZ Z2 VXY VXZ Y2 X2 DECODER_V2
*DECODER_LAY VSS VDD YZ Z XY XZ Y X

"}
C {devices/vsource.sym} 140 -140 0 0 {name=V2 value=5
}
C {devices/gnd.sym} 140 -110 0 0 {name=l2 lab=GND
value=5}
C {devices/lab_wire.sym} 140 -170 0 0 {name=p4 sig_type=std_logic lab=VDD1}
C {devices/vsource.sym} 220 -140 0 0 {name=V9 value=5
}
C {devices/gnd.sym} 220 -110 0 0 {name=l9 lab=GND
value=5}
C {devices/lab_wire.sym} 220 -170 0 0 {name=p4b sig_type=std_logic lab=VDD2}
C {a_zonetic2026/XSCHEM/DECODER/DECODER.sym} 370 50 0 0 {name=x1}
C {devices/lab_wire.sym} 410 30 2 0 {name=p11 sig_type=std_logic lab=Y}
C {devices/lab_wire.sym} 410 50 2 0 {name=p12 sig_type=std_logic lab=Z}
C {devices/vsource.sym} 50 30 0 0 {name=V6 value="pulse(0 5 0 1m 
+ 1m 0.5 1)"
}
C {devices/gnd.sym} 50 80 0 0 {name=l7 lab=GND
value=5}
C {devices/lab_wire.sym} 50 -40 0 0 {name=p13 sig_type=std_logic lab=VXY}
C {devices/gnd.sym} -90 90 0 0 {name=l8 lab=GND
value=5}
C {devices/lab_wire.sym} -90 -30 0 0 {name=p14 sig_type=std_logic lab=VXZ}
C {devices/gnd.sym} -220 70 0 0 {name=l9 lab=GND
value=5}
C {devices/lab_wire.sym} -220 -50 0 0 {name=p15 sig_type=std_logic lab=VYZ}
C {devices/vsource.sym} -90 40 0 0 {name=V7 value="pulse(0 5 0 1m 
+ 1m 0.25 0.5)"
}
C {devices/vsource.sym} -220 20 0 0 {name=V8 value="pulse(0 5 0 1m 
+ 1m 0.125 0.25)"
}
C {devices/lab_wire.sym} 200 10 0 0 {name=p1 sig_type=std_logic lab=VXY}
C {devices/lab_wire.sym} 200 30 0 0 {name=p2 sig_type=std_logic lab=VXZ}
C {devices/lab_wire.sym} 200 50 0 0 {name=p3 sig_type=std_logic lab=VYZ}
C {devices/lab_wire.sym} 410 10 2 0 {name=p5 sig_type=std_logic lab=X}
C {devices/gnd.sym} 310 100 0 0 {name=l5 lab=GND
value=5}
