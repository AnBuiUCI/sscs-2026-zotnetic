v {xschem version=3.4.8RC file_version=1.3}
G {}
K {}
V {}
S {}
F {}
E {}
N -440 -90 -360 -90 {lab=vg}
N -440 -90 -440 -70 {lab=vg}
N -290 -90 -290 -50 {lab=vss}
N -320 -50 -290 -50 {lab=vss}
N -320 -120 -150 -120 {lab=vdd}
N -320 -60 -320 -30 {lab=vss}
N -440 -90 -360 -90 {lab=vg}
N -440 -90 -440 -70 {lab=vg}
N -290 -90 -290 -50 {lab=vss}
N -320 -50 -290 -50 {lab=vss}
N -320 -120 -150 -120 {lab=vdd}
N -320 -60 -320 -30 {lab=vss}
N -560 -190 -560 -170 {lab=0}
N -490 -190 -490 -170 {lab=0}
N -410 -190 -410 -170 {lab=0}
N -560 -280 -560 -250 {lab=vg}
N -490 -280 -490 -250 {lab=vdd}
N -410 -280 -410 -250 {lab=vss}
N -320 -90 -290 -90 {lab=vss}
C {vsource.sym} -560 -220 0 0 {name=VGATE value=3 savecurrent=false}
C {vsource.sym} -490 -220 0 0 {name=VDD value=5 savecurrent=false}
C {vsource.sym} -410 -220 0 0 {name=VSS value=0 savecurrent=false}
C {gnd.sym} -560 -170 0 0 {name=l1 lab=0}
C {gnd.sym} -490 -170 0 0 {name=l2 lab=0}
C {gnd.sym} -410 -170 0 0 {name=l3 lab=0}
C {lab_pin.sym} -560 -280 0 0 {name=p7 sig_type=std_logic lab=vg}
C {lab_pin.sym} -490 -280 0 0 {name=p8 sig_type=std_logic lab=vdd}
C {lab_pin.sym} -410 -280 0 0 {name=p9 sig_type=std_logic lab=vss}
C {code_shown.sym} -890 -360 0 0 {name=MODELS only_toplevel=false value=".include /foss/pdks/gf180mcuD/libs.tech/ngspice/design.ngspice
.lib /foss/pdks/gf180mcuD/libs.tech/ngspice/sm141064.ngspice typical"}
C {code_shown.sym} -100 -400 0 0 {name=NGSPICE 
only_toplevel=false 
value="
*.tran 1ms 100ms
.dc VDD 1 5 0.01
.save all
.control
run
display
plot v(vdd)
plot vdd#branch
plot v(vdd)/-(i(VDD))
.endc
"}
C {lab_pin.sym} -440 -70 0 0 {name=p1 sig_type=std_logic lab=vg}
C {lab_pin.sym} -150 -120 0 0 {name=p2 sig_type=std_logic lab=vdd}
C {lab_pin.sym} -320 -30 0 0 {name=p3 sig_type=std_logic lab=vss}
C {symbols/nfet_06v0.sym} -340 -90 0 0 {name=M1
L=1u
W=2u
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
