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
N 260 90 300 90 {lab=VDD}
N 260 110 300 110 {lab=out1}
N 260 130 300 130 {lab=out2}
N 260 150 300 150 {lab=out3}
N 260 170 300 170 {lab=out4}
N 260 190 300 190 {lab=gnd}
C {devices/vsource.sym} 110 -130 0 0 {name=V1 value=5
}
C {devices/gnd.sym} 110 -80 0 0 {name=l1 lab=GND
value=5}
C {devices/lab_wire.sym} 110 -200 0 0 {name=p7 sig_type=std_logic lab=VDD}
C {devices/code_shown.sym} -435 75 0 0 {name=s1
only_toplevel=false
value="
.tran 1ms 100ms
*.dc v3 -3.3 3.3 1m
.save all
.control
run
display
plot v(out1)
plot v(out2)
plot v(out3)
plot v(out4)
plot i(v.x1.v1)
.endc
"}
C {devices/code_shown.sym} 275 -205 0 0 {name=MODELS1 only_toplevel=true
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
C {DESIGN/AMPLIFIER/NEW/bias.sym} 110 140 0 0 {name=x1}
C {devices/lab_wire.sym} 300 90 2 0 {name=p2 sig_type=std_logic lab=VDD}
C {devices/lab_wire.sym} 300 110 2 0 {name=p6 sig_type=std_logic lab=out1}
C {devices/lab_wire.sym} 300 130 2 0 {name=p9 sig_type=std_logic lab=out2}
C {devices/lab_wire.sym} 300 150 2 0 {name=p11 sig_type=std_logic lab=out3}
C {devices/lab_wire.sym} 300 170 2 0 {name=p12 sig_type=std_logic lab=out4}
C {devices/lab_wire.sym} 300 190 2 0 {name=p13 sig_type=std_logic lab=gnd}
