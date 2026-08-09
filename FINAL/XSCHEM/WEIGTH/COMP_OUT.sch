v {xschem version=3.4.8RC file_version=1.3}
G {}
K {}
V {}
S {}
F {}
E {}
N -200 -80 -180 -80 {lab=IN}
N -140 -130 20 -130 {lab=VDD}
N 20 -130 180 -130 {lab=VDD}
N 180 -130 210 -130 {lab=VDD}
N 180 -30 210 -30 {lab=VSS}
N 20 -30 180 -30 {lab=VSS}
N -140 -30 20 -30 {lab=VSS}
N -40 -80 -20 -80 {lab=#net1}
N 120 -80 140 -80 {lab=OUT}
N 120 -110 130 -110 {lab=OUT}
N 130 -110 130 -80 {lab=OUT}
N 280 -80 290 -80 {lab=OUT}
C {a_zonetic2026/XSCHEM/WEIGTH/INV_1.sym} -80 -80 0 0 {name=x1}
C {a_zonetic2026/XSCHEM/WEIGTH/INV_1.sym} 80 -80 0 0 {name=x2}
C {a_zonetic2026/XSCHEM/WEIGTH/INV_1.sym} 240 -80 0 0 {name=x3}
C {ipin.sym} -200 -80 0 0 {name=p1 lab=IN}
C {iopin.sym} 210 -130 0 0 {name=p2 lab=VDD}
C {opin.sym} 120 -110 2 0 {name=p3 lab=OUT}
C {iopin.sym} 210 -30 0 0 {name=p4 lab=VSS}
C {opin.sym} 290 -80 0 0 {name=p5 lab=OUT_N}
