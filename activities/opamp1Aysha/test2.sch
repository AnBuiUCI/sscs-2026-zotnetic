v {xschem version=3.4.8RC file_version=1.3}
G {}
K {}
V {}
S {}
F {}
E {}
N 110 -100 110 -80 {
lab=GND}
N 110 -220 110 -160 {
lab=VDD}
N 210 -230 210 -170 {
lab=VP}
N 210 -90 210 -70 {
lab=GND}
N 290 -220 290 -160 {lab=VN}
N 370 -220 370 -160 {lab=BIAS_DIFF}
N 370 -100 370 -50 {lab=GND}
N 450 -220 450 -160 {lab=BIAS_CS}
N 450 -100 450 -50 {lab=GND}
N 290 -100 290 -60 {lab=GND}
N 210 -170 210 -150 {lab=VP}
N 540 -220 540 -150 {lab=OUT}
N 540 -90 540 -70 {lab=0}
C {devices/vsource.sym} 110 -130 0 0 {name=V1 value=5
}
C {devices/gnd.sym} 110 -80 0 0 {name=l1 lab=GND
value=5}
C {devices/lab_wire.sym} 110 -200 0 0 {name=p7 sig_type=std_logic lab=VDD}
C {devices/code_shown.sym} 575 15 0 0 {name=s1
only_toplevel=false
value="
*.tran 10p 0.3u
.dc V2 0 5 0.001
.save all
.control
run
display
plot v(VP) v(VN) v(OUT)
.endc
"}
C {devices/code_shown.sym} 675 -215 0 0 {name=MODELS1 only_toplevel=false
value="
.include /foss/pdks/gf180mcuD/libs.tech/ngspice/design.ngspice
.lib /foss/pdks/gf180mcuD/libs.tech/ngspice/sm141064.ngspice typical
.lib /foss/pdks/gf180mcuD/libs.tech/ngspice/smbb000149.ngspice typical
.lib /foss/pdks/gf180mcuD/libs.tech/ngspice/sm141064.ngspice cap_mim
.lib /foss/pdks/gf180mcuD/libs.tech/ngspice/sm141064.ngspice mimcap_typical
.options scale=1u
"}
C {devices/lab_wire.sym} 210 -200 0 0 {name=p5 sig_type=std_logic lab=VP
}
C {devices/gnd.sym} 210 -70 0 0 {name=l2 lab=GND
value=5}
C {devices/code_shown.sym} 10 300 0 0 {name=DUT only_toplevel=true
format="tcleval( @value )"
value="
.include "/foss/designs/sscs-2026-zotnetic/designs/notebooks/opamp.spice"
XOPAMP VDD GND BIAS_DIFF VP VN BIAS_CS OUT OPAMP_TWO_STAGE"}
C {devices/vsource.sym} 210 -120 0 0 {name=V2 value=2.5
}
C {devices/vsource.sym} 290 -130 0 0 {name=V3 value=2.5
}
C {devices/vsource.sym} 370 -130 0 0 {name=V4 value=1.2
}
C {devices/vsource.sym} 450 -130 0 0 {name=V5 value=1.2
}
C {devices/gnd.sym} 290 -60 0 0 {name=l3 lab=GND
value=5}
C {devices/gnd.sym} 370 -50 0 0 {name=l4 lab=GND
value=5}
C {devices/gnd.sym} 450 -50 0 0 {name=l5 lab=GND
value=5}
C {devices/lab_wire.sym} 290 -210 0 0 {name=p1 sig_type=std_logic lab=VN
}
C {devices/lab_wire.sym} 370 -200 0 0 {name=p2 sig_type=std_logic lab=BIAS_DIFF
}
C {devices/lab_wire.sym} 450 -200 0 0 {name=p3 sig_type=std_logic lab=BIAS_CS
}
C {devices/lab_wire.sym} 540 -200 0 0 {name=p4 sig_type=std_logic lab=OUT
}
C {res.sym} 540 -120 0 0 {name=R1
value=1 Meg
footprint=1206
device=resistor
m=1}
C {gnd.sym} 540 -70 0 0 {name=l6 lab=0}
