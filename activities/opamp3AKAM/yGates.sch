v {xschem version=3.4.8RC file_version=1.3}
G {}
K {}
V {}
S {}
F {}
E {}
N -90 -30 30 -30 {lab=#net1}
N -170 -130 -170 -80 {lab=VDD}
N -170 -130 70 -130 {lab=VDD}
N 70 -130 70 -100 {lab=VDD}
N -170 20 -170 80 {lab=VSS}
N 70 -0 70 60 {lab=VSS}
N -170 60 70 60 {lab=VSS}
C {/foss/designs/sscs-2026-zotnetic/activities/opamp3AKAM/andGate.sym} 90 -30 0 0 {name=x1}
C {/foss/designs/sscs-2026-zotnetic/activities/opamp3AKAM/invertor.sym} -190 -20 0 0 {name=x2}
C {ipin.sym} -170 -130 0 0 {name=p1 lab=VDD}
C {ipin.sym} -170 80 0 0 {name=p3 lab=VSS}
C {ipin.sym} 30 -70 0 0 {name=p4 lab=YZ}
C {ipin.sym} -230 -30 0 0 {name=p2 lab=XY}
C {opin.sym} 120 -50 0 0 {name=p10 lab=output}
