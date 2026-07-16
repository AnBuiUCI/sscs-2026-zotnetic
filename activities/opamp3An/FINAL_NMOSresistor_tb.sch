v {xschem version=3.4.8RC file_version=1.3}
G {}
K {}
V {}
S {}
F {}
E {}
N 310 20 390 20 {lab=vg}
N 310 20 310 40 {lab=vg}
N 460 20 460 60 {lab=vss}
N 430 60 460 60 {lab=vss}
N 430 -10 600 -10 {lab=vdd}
N 430 50 430 80 {lab=vss}
N 310 20 390 20 {lab=vg}
N 310 20 310 40 {lab=vg}
N 460 20 460 60 {lab=vss}
N 430 60 460 60 {lab=vss}
N 430 -10 600 -10 {lab=vdd}
N 430 50 430 80 {lab=vss}
N 190 -80 190 -60 {lab=0}
N 260 -80 260 -60 {lab=0}
N 340 -80 340 -60 {lab=0}
N 190 -170 190 -140 {lab=vg}
N 260 -170 260 -140 {lab=vdd}
N 340 -170 340 -140 {lab=vss}
N 430 20 460 20 {lab=vss}
C {vsource.sym} 190 -110 0 0 {name=VGATE value=0 savecurrent=false}
C {vsource.sym} 260 -110 0 0 {name=VDD value=5 savecurrent=false}
C {vsource.sym} 340 -110 0 0 {name=VSS value=0 savecurrent=false}
C {gnd.sym} 190 -60 0 0 {name=l1 lab=0}
C {gnd.sym} 260 -60 0 0 {name=l2 lab=0}
C {gnd.sym} 340 -60 0 0 {name=l3 lab=0}
C {lab_pin.sym} 190 -170 0 0 {name=p7 sig_type=std_logic lab=vg}
C {lab_pin.sym} 260 -170 0 0 {name=p8 sig_type=std_logic lab=vdd}
C {lab_pin.sym} 340 -170 0 0 {name=p9 sig_type=std_logic lab=vss}
C {code_shown.sym} -140 -250 0 0 {name=MODELS only_toplevel=false value=".include /foss/pdks/gf180mcuD/libs.tech/ngspice/design.ngspice
.lib /foss/pdks/gf180mcuD/libs.tech/ngspice/sm141064.ngspice typical"}
C {code_shown.sym} 650 -290 0 0 {name=NGSPICE 
only_toplevel=false 
value="
*.tran 1ms 100ms
.dc VGATE 2 5 0.01
.save all
.control
run
display
plot v(vdd)
plot vdd#branch
plot v(vdd)/-(i(VDD))
.endc
"}
C {lab_pin.sym} 310 40 0 0 {name=p1 sig_type=std_logic lab=vg}
C {lab_pin.sym} 600 -10 0 0 {name=p2 sig_type=std_logic lab=vdd}
C {lab_pin.sym} 430 80 0 0 {name=p3 sig_type=std_logic lab=vss}
C {symbols/nfet_06v0.sym} 410 20 0 0 {name=M1
L=0.70u
W=0.30u
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
