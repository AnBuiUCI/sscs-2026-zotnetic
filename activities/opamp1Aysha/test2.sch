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
N 210 -210 210 -150 {
lab=OUT}
N 210 -90 210 -70 {
lab=GND}
C {devices/vsource.sym} 110 -130 0 0 {name=V1 value=5
}
C {devices/gnd.sym} 110 -80 0 0 {name=l1 lab=GND
value=5}
C {devices/lab_wire.sym} 110 -200 0 0 {name=p7 sig_type=std_logic lab=VDD}
C {devices/code_shown.sym} 585 35 0 0 {name=s1
only_toplevel=false
value="
*.tran 10p 0.3u
.dc V2 0 5 0.001
.save all
.control
run
set wr_singlescale
set wr_vecnames
wrdata data.txt v(out) v(out1)
display
plot v(out) v(out1) v(out2)
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
C {devices/lab_wire.sym} 210 -200 0 0 {name=p5 sig_type=std_logic lab=OUT
}
C {devices/gnd.sym} 210 -70 0 0 {name=l2 lab=GND
value=5}
C {devices/code_shown.sym} 10 300 0 0 {name=DUT only_toplevel=true
format="tcleval( @value )"
value="
.include "./gf180mcu_fd_sc_mcu9t5v0.spice"
XDUT OUT OUT1 VDD VDD GND GND gf180mcu_fd_sc_mcu9t5v0__inv_1
XDUT1 OUT1 OUT2 VDD VDD GND GND gf180mcu_fd_sc_mcu9t5v0__inv_1
"}
C {devices/vsource.sym} 210 -120 0 0 {name=V2 value=5
}
