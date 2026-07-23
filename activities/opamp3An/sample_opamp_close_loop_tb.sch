v {xschem version=3.4.8RC file_version=1.3}
G {}
K {}
V {}
S {}
F {}
E {}
N -120 -80 -20 -80 {lab=#net1}
N -120 -60 -20 -60 {lab=#net2}
N -120 -20 -20 20 {lab=#net3}
N -120 -40 -20 0 {lab=vin}
N -390 190 -390 220 {lab=0}
N -390 70 -390 130 {lab=VSS}
N -120 0 -120 40 {lab=VSS}
N 280 -40 280 -0 {lab=VSS}
N -310 190 -310 220 {lab=0}
N -310 70 -310 130 {lab=VDD}
N 280 -130 280 -80 {lab=VDD}
N -120 -150 -120 -100 {lab=VDD}
N 280 -60 370 -60 {lab=#net4}
N -70 -20 -20 -20 {lab=vin}
N 430 -60 500 -60 {lab=vin}
N 400 -90 400 -60 {lab=vin}
N 400 -90 440 -90 {lab=vin}
N 440 -90 440 -60 {lab=vin}
N -40 -40 -20 -40 {lab=#net5}
N -40 -40 -40 90 {lab=#net5}
N -40 150 -40 190 {lab=VSS}
N -40 120 -10 120 {lab=VSS}
N -10 120 -10 160 {lab=VSS}
N -40 160 -10 160 {lab=VSS}
N -230 190 -230 220 {lab=0}
N -230 70 -230 130 {lab=VG}
N -120 120 -80 120 {lab=VG}
N 400 -20 400 30 {lab=#net6}
C {activities/opamp2AKAM/opamp.sym} 130 -30 0 0 {name=x1}
C {activities/opamp2AKAM/bias.sym} -270 -50 0 0 {name=x2}
C {vsource.sym} -390 160 0 0 {name=V1 value=0 savecurrent=false}
C {gnd.sym} -390 220 0 0 {name=l1 lab=0}
C {lab_pin.sym} -390 80 0 0 {name=p1 sig_type=std_logic lab=VSS}
C {lab_pin.sym} -120 30 0 0 {name=p2 sig_type=std_logic lab=VSS}
C {lab_pin.sym} 280 -10 0 0 {name=p3 sig_type=std_logic lab=VSS}
C {vsource.sym} -310 160 0 0 {name=V2 value=5 savecurrent=false}
C {gnd.sym} -310 220 0 0 {name=l2 lab=0}
C {lab_pin.sym} -310 80 0 0 {name=p4 sig_type=std_logic lab=VDD}
C {lab_pin.sym} 280 -120 0 0 {name=p5 sig_type=std_logic lab=VDD}
C {lab_pin.sym} -120 -140 0 0 {name=p6 sig_type=std_logic lab=VDD}
C {symbols/nfet_06v0.sym} 400 -40 3 0 {name=M1
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
C {lab_pin.sym} -50 -20 0 0 {name=p7 sig_type=std_logic lab=vin}
C {lab_pin.sym} 490 -60 0 0 {name=p8 sig_type=std_logic lab=vin}
C {symbols/nfet_06v0.sym} -60 120 0 0 {name=M2
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
C {lab_pin.sym} -40 180 0 0 {name=p9 sig_type=std_logic lab=VSS}
C {code_shown.sym} -380 -200 0 0 {name=MODELS only_toplevel=false value=".include /foss/pdks/gf180mcuD/libs.tech/ngspice/design.ngspice
.lib /foss/pdks/gf180mcuD/libs.tech/ngspice/sm141064.ngspice typical"}
C {code_shown.sym} 60 80 0 0 {name=NGSPICE 
only_toplevel=false 
value="
*.tran 1ms 100ms
.dc VGATE 1 5 0.01
.save all
.control
run
display
plot v(vdd)
plot vdd#branch
plot v(vdd)/-(i(VDD))
.endc
"}
C {vsource.sym} -230 160 0 0 {name=VGATE value=1 savecurrent=false}
C {gnd.sym} -230 220 0 0 {name=l3 lab=0}
C {lab_pin.sym} -230 80 0 0 {name=p10 sig_type=std_logic lab=VG}
C {lab_pin.sym} -110 120 0 0 {name=p11 sig_type=std_logic lab=VG}
C {lab_pin.sym} 400 10 0 0 {name=p12 sig_type=std_logic lab=VG}
