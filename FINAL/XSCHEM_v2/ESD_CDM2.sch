v {xschem version=3.4.8RC file_version=1.3}
G {}
K {}
V {}
S {}
F {}
E {}
N -70 510 -10 510 {lab=VSS}
N -40 510 -40 530 {lab=VSS}
N -70 370 -0 370 {lab=VDD}
N -30 320 -30 370 {lab=VDD}
N -30 320 -20 320 {lab=VDD}
N -10 510 -0 510 {lab=VSS}
N 0 430 0 450 {lab=PAD}
N 0 440 40 440 {lab=PAD}
N -70 430 -70 450 {lab=PAD}
N -80 440 -70 440 {lab=PAD}
N -70 440 -0 440 {lab=PAD}
C {devices/lab_pin.sym} -220 480 0 0 {name=l1 sig_type=std_logic lab=CORE}
C {devices/lab_pin.sym} -220 420 0 0 {name=l2 sig_type=std_logic lab=PAD}
C {devices/lab_pin.sym} -240 450 0 0 {name=l3 sig_type=std_logic lab=VSS}
C {devices/ipin.sym} -80 440 0 0 {name=p1 lab=PAD}
C {devices/opin.sym} 40 440 0 0 {name=p2 lab=CORE}
C {devices/iopin.sym} -20 320 0 0 {name=p3 lab=VDD}
C {devices/iopin.sym} -40 530 0 0 {name=p4 lab=VSS}
C {symbols/diode_pd2nw_06v0.sym} 0 480 2 0 {name=D1
model=diode_pd2nw_06v0
r_w=10u
r_l=5u
m=1}
C {symbols/diode_nd2ps_06v0.sym} 0 400 2 0 {name=D2
model=diode_nd2ps_06v0
r_w=10u
r_l=5u
m=1}
C {symbols/diode_nd2ps_06v0.sym} -70 480 2 0 {name=D3
model=diode_nd2ps_06v0
r_w=10u
r_l=5u
m=1}
C {symbols/diode_pd2nw_06v0.sym} -70 400 2 0 {name=D4
model=diode_pd2nw_06v0
r_w=10u
r_l=5u
m=1}
C {symbols/ppolyf_u.sym} -220 450 0 0 {name=R1
W=1e-6
L=10e-6
model=ppolyf_u
spiceprefix=X
m=5}
