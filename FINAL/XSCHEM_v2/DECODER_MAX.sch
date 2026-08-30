v {xschem version=3.4.8RC file_version=1.3}
G {}
K {}
V {}
S {}
F {}
E {}
N -210 -150 -190 -150 {lab=Z}
N -300 -100 -300 -90 {lab=VSS}
N -390 -130 -380 -130 {lab=YZ}
N -390 -160 -380 -160 {lab=XZ}
N -300 -200 -300 -190 {lab=VDD}
C {ipin.sym} -430 -260 0 0 {name=p1 lab=XY}
C {ipin.sym} -430 -240 0 0 {name=p2 lab=XZ}
C {ipin.sym} -430 -220 0 0 {name=p6 lab=YZ}
C {iopin.sym} 250 -140 0 0 {name=p3 lab=VDD}
C {iopin.sym} 250 -60 0 0 {name=p4 lab=VSS}
C {opin.sym} 430 -260 0 0 {name=p5 lab=X}
C {opin.sym} 430 -240 0 0 {name=p7 lab=Y}
C {opin.sym} 430 -220 0 0 {name=p8 lab=Z}
C {lab_pin.sym} -390 -160 0 0 {name=q1 sig_type=std_logic lab=XZ}
C {lab_pin.sym} -390 -130 0 0 {name=q2 sig_type=std_logic lab=YZ}
C {lab_pin.sym} -190 -150 2 0 {name=q3 sig_type=std_logic lab=Z}
C {lab_pin.sym} -70 -120 0 0 {name=q4 sig_type=std_logic lab=XY}
C {lab_pin.sym} -70 -90 0 0 {name=q5 sig_type=std_logic lab=YZ}
C {lab_pin.sym} 100 -110 2 0 {name=q6 sig_type=std_logic lab=Y}
C {lab_pin.sym} 180 -110 0 0 {name=q7 sig_type=std_logic lab=XY}
C {lab_pin.sym} 180 -90 0 0 {name=q8 sig_type=std_logic lab=XZ}
C {lab_pin.sym} 330 -100 2 0 {name=q9 sig_type=std_logic lab=X}
C {lab_pin.sym} -300 -200 0 0 {name=p12 sig_type=std_logic lab=VDD}
C {lab_pin.sym} -300 -90 0 0 {name=p13 sig_type=std_logic lab=VSS}
C {lab_pin.sym} 10 -150 0 0 {name=p14 sig_type=std_logic lab=VDD}
C {lab_pin.sym} 10 -60 0 0 {name=p15 sig_type=std_logic lab=VSS}
C {a_zonetic2026/XSCHEM/DECODER/xGates.sym} -230 -130 0 0 {name=x3}
C {a_zonetic2026/XSCHEM/DECODER/yGates.sym} 10 -100 0 0 {name=x2}
C {a_zonetic2026/XSCHEM/DECODER/Z.sym} 330 -90 0 0 {name=x1}
C {devices/code_shown.sym} -430 -80 0 0 {name=NOTA only_toplevel=false
value="
* THE MAXIMUM DECODER. The same three gates as today's DECODER, with the
* inputs permuted: no new cell is needed.
*
*   xGates  = AND(a,b)        -> Z = XZ . YZ
*   yGates  = AND(a,~b)       -> Y = XY . ~YZ
*   Z       = NOR(a,b)        -> X = ~XY . ~XZ
*
* With the gradient components at the input, this names which one is the MOST
* POSITIVA, o sea hacia que sentido apunta el gradiente. El DECODER de hoy
* names the most negative. Both come from the SAME three comparators, which is
* what makes the sense cost three gates and not a whole chain.
"}
