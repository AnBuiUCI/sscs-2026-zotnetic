v {xschem version=3.4.8RC file_version=1.3}
G {}
K {}
V {}
S {}
F {}
E {}
N -150 110 -150 130 {lab=0}
N -80 110 -80 130 {lab=0}
N 0 110 0 130 {lab=0}
N -150 20 -150 50 {lab=vg}
N -80 20 -80 50 {lab=vdd}
N 0 20 0 50 {lab=vss}
C {NMOSresistor.sym} 20 -20 0 0 {}
C {vsource.sym} -150 80 0 0 {name=VGATE value=1 savecurrent=false}
C {vsource.sym} -80 80 0 0 {name=VDD value=5 savecurrent=false}
C {vsource.sym} 0 80 0 0 {name=VSS value=0 savecurrent=false}
C {gnd.sym} -150 130 0 0 {name=l1 lab=0}
C {gnd.sym} -80 130 0 0 {name=l2 lab=0}
C {gnd.sym} 0 130 0 0 {name=l3 lab=0}
C {lab_pin.sym} -150 20 0 0 {name=p1 sig_type=std_logic lab=vg}
C {lab_pin.sym} -80 20 0 0 {name=p2 sig_type=std_logic lab=vdd}
C {lab_pin.sym} 0 20 0 0 {name=p3 sig_type=std_logic lab=vss}
C {code_shown.sym} -380 -160 0 0 {name=MODELS only_toplevel=false value=".include /foss/pdks/gf180mcuD/libs.tech/ngspice/design.ngspice
.lib /foss/pdks/gf180mcuD/libs.tech/ngspice/sm141064.ngspice typical"}
C {code_shown.sym} 340 -130 0 0 {name=NGSPICE 
only_toplevel=false 
value="
*.tran 1ms 100ms
.dc VGATE 3 4 1m
.save all
.control
run
display
plot v(net1)
.endc
"}
