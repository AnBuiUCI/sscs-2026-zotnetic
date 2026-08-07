v {xschem version=3.4.8RC file_version=1.3}
G {}
K {}
V {}
S {}
F {}
E {}
N 230 -40 260 -40 {lab=#net1}
N 260 -40 260 100 {lab=#net1}
N 260 100 290 100 {lab=#net1}
N 230 120 290 120 {lab=#net2}
N 260 140 290 140 {lab=#net3}
N 260 140 260 280 {lab=#net3}
N 230 280 260 280 {lab=#net3}
N 460 100 480 100 {lab=X}
N 460 120 480 120 {lab=Y}
N 460 140 480 140 {lab=Z}
N 380 50 380 70 {lab=VDD}
N 380 180 380 200 {lab=VSS}
N -200 -60 -180 -60 {lab=SX-}
N -200 -20 -180 -20 {lab=SX+}
N -200 100 -180 100 {lab=SY-}
N -200 140 -180 140 {lab=SY+}
N -200 260 -180 260 {lab=SZ-}
N -200 300 -180 300 {lab=SZ+}
N -100 340 -100 350 {lab=VSS}
N -100 210 -100 220 {lab=VDD}
N 130 340 130 350 {lab=VSS}
N 130 210 130 220 {lab=VDD}
N -100 180 -100 190 {lab=VSS}
N -100 50 -100 60 {lab=VDD}
N 130 180 130 190 {lab=VSS}
N 130 50 130 60 {lab=VDD}
N 130 20 130 30 {lab=VSS}
N 130 -110 130 -100 {lab=VDD}
N -100 20 -100 30 {lab=VSS}
N -100 -110 -100 -100 {lab=VDD}
N -20 -40 0 -40 {lab=SX}
N 0 -60 0 -40 {lab=SX}
N -0 -60 70 -60 {lab=SX}
N -20 120 20 120 {lab=SY}
N 20 100 20 120 {lab=SY}
N 20 -20 20 100 {lab=SY}
N 20 -20 70 -20 {lab=SY}
N 50 140 70 140 {lab=SZ}
N -20 280 -0 280 {lab=SZ}
N 20 140 50 140 {lab=SZ}
N 20 140 20 300 {lab=SZ}
N -0 280 20 280 {lab=SZ}
N 20 300 70 300 {lab=SZ}
N 60 100 70 100 {lab=SX}
N 60 260 70 260 {lab=SY}
C {DESIGN/FINAL/OPAM/OPAM.sym} -80 -40 0 0 {name=x1}
C {DESIGN/FINAL/OPAM/OPAM.sym} -80 120 0 0 {name=x2}
C {DESIGN/FINAL/OPAM/OPAM.sym} -80 280 0 0 {name=x3}
C {DESIGN/FINAL/OPAM/COMP.sym} 130 -40 0 0 {name=x4}
C {DESIGN/FINAL/OPAM/COMP.sym} 130 120 0 0 {name=x5}
C {DESIGN/FINAL/OPAM/COMP.sym} 130 280 0 0 {name=x6}
C {DESIGN/FINAL/DECODER/DECODER.sym} 440 140 0 0 {name=x7}
C {ipin.sym} -200 -60 0 0 {name=p1 lab=SX-}
C {ipin.sym} -200 -20 0 0 {name=p2 lab=SX+
}
C {iopin.sym} 380 50 0 0 {name=p3 lab=VDD}
C {iopin.sym} 380 200 0 0 {name=p4 lab=VSS}
C {iopin.sym} 480 100 0 0 {name=p5 lab=X}
C {iopin.sym} 480 120 0 0 {name=p7 lab=Y}
C {iopin.sym} 480 140 0 0 {name=p8 lab=Z}
C {ipin.sym} -200 100 0 0 {name=p9 lab=SY-}
C {ipin.sym} -200 140 0 0 {name=p10 lab=SY+
}
C {ipin.sym} -200 260 0 0 {name=p11 lab=SZ-}
C {ipin.sym} -200 300 0 0 {name=p12 lab=SZ+
}
C {lab_pin.sym} -100 210 2 0 {name=p6 sig_type=std_logic lab=VDD}
C {lab_pin.sym} -100 350 2 0 {name=p13 sig_type=std_logic lab=VSS}
C {lab_pin.sym} 130 210 2 0 {name=p14 sig_type=std_logic lab=VDD}
C {lab_pin.sym} 130 350 2 0 {name=p15 sig_type=std_logic lab=VSS}
C {lab_pin.sym} -100 50 2 0 {name=p16 sig_type=std_logic lab=VDD}
C {lab_pin.sym} -100 190 2 0 {name=p17 sig_type=std_logic lab=VSS}
C {lab_pin.sym} 130 50 2 0 {name=p18 sig_type=std_logic lab=VDD}
C {lab_pin.sym} 130 190 2 0 {name=p19 sig_type=std_logic lab=VSS}
C {lab_pin.sym} 130 -110 2 0 {name=p20 sig_type=std_logic lab=VDD}
C {lab_pin.sym} 130 30 2 0 {name=p21 sig_type=std_logic lab=VSS}
C {lab_pin.sym} -100 -110 2 0 {name=p22 sig_type=std_logic lab=VDD}
C {lab_pin.sym} -100 30 2 0 {name=p23 sig_type=std_logic lab=VSS}
C {lab_pin.sym} 0 -60 0 0 {name=p24 sig_type=std_logic lab=SX}
C {lab_pin.sym} 20 90 0 0 {name=p25 sig_type=std_logic lab=SY}
C {lab_pin.sym} 20 240 0 0 {name=p26 sig_type=std_logic lab=SZ}
C {lab_pin.sym} 60 100 0 0 {name=p27 sig_type=std_logic lab=SX}
C {lab_pin.sym} 60 260 0 0 {name=p28 sig_type=std_logic lab=SY}
