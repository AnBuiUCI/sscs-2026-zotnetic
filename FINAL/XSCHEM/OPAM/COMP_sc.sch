v {xschem version=3.4.8RC file_version=1.3}
G {}
K {}
V {}
S {}
F {}
E {}
N 30 -240 80 -240 {lab=VDD}
N 80 -280 80 -240 {lab=VDD}
N 80 -280 450 -280 {lab=VDD}
N 450 -280 450 -240 {lab=VDD}
N 450 -200 450 -110 {lab=VSS}
N 30 -110 450 -110 {lab=VSS}
N 30 -140 30 -110 {lab=VSS}
N 30 -160 150 -160 {lab=#net1}
N 30 -180 150 -180 {lab=#net2}
N 30 -200 150 -200 {lab=#net3}
N 30 -220 150 -220 {lab=#net4}
C {ipin.sym} 150 -240 0 0 {name=p1 lab=IN-}
C {ipin.sym} 150 -140 0 0 {name=p2 lab=IN+}
C {iopin.sym} 450 -240 0 0 {name=p3 lab=VDD}
C {iopin.sym} 450 -200 0 0 {name=p4 lab=VSS}
C {iopin.sym} 450 -220 0 0 {name=p5 lab=OUT}
C {DESIGN/FINAL/OPAM/bias.sym} -120 -190 0 0 {name=x1}
C {DESIGN/FINAL/OPAM/sub_diff.sym} 300 -190 0 0 {name=x2}
