v {xschem version=3.4.8RC file_version=1.3}
G {}
K {}
V {}
S {}
F {}
E {}
C {devices/code_shown.sym} 570 -700 0 0 {name=MODELS1 only_toplevel=true
format="tcleval( @value )"
value="
.include $::180MCU_MODELS/design.ngspice
.lib $::180MCU_MODELS/sm141064.ngspice typical
.lib $::180MCU_MODELS/sm141064.ngspice cap_mim
.lib $::180MCU_MODELS/sm141064.ngspice res_typical
.lib $::180MCU_MODELS/sm141064.ngspice moscap_typical
.lib $::180MCU_MODELS/sm141064.ngspice mimcap_typical
.lib $::180MCU_MODELS/sm141064.ngspice diode_typical
"}
C {devices/vsource.sym} 110 -520 0 0 {name=V1 value=5
}
C {devices/lab_wire.sym} 110 -550 0 0 {name=pV1a sig_type=std_logic lab=VEXC}
C {devices/gnd.sym} 110 -490 0 0 {name=lV1 lab=GND
value=5}
C {devices/gnd.sym} 190 -490 0 0 {name=lV2 lab=GND
value=5}
C {devices/vsource.sym} 270 -520 0 0 {name=V3 value=5
}
C {devices/lab_wire.sym} 270 -550 0 0 {name=pV3a sig_type=std_logic lab=VDDR}
C {devices/gnd.sym} 270 -490 0 0 {name=lV3 lab=GND
value=5}
C {devices/code_shown.sym} -700 -700 0 0 {name=ESTIMULO only_toplevel=true
value="
*
*
*
*
*
*
*
*
*
Voff  off  0 0
Vlxy  lxy  0 1000
Vlz   lz   0 1000
Vgmm  gmm  0 2000u
Vbg   bg   0 0
Vang  ang  0 0
Vtilt tilt 0 0

Bgx gx 0 v='cos(v(ang)*3.14159265358979/180)'
Bgy gy 0 v='sin(v(ang)*3.14159265358979/180)*sin(v(tilt)*3.14159265358979/180)'
Bgz gz 0 v='sin(v(ang)*3.14159265358979/180)*cos(v(tilt)*3.14159265358979/180)'

Bb1 b1 0 v='v(bg) +1.00*v(off) + v(gmm)*(-v(lxy)*v(gx) +v(lxy)*v(gy) +v(lz)*v(gz))/2000'
Bb2 b2 0 v='v(bg) -0.62*v(off) + v(gmm)*( v(lxy)*v(gx) -v(lxy)*v(gy) +v(lz)*v(gz))/2000'
Bb3 b3 0 v='v(bg) +0.31*v(off) + v(gmm)*(-v(lxy)*v(gx) -v(lxy)*v(gy) -v(lz)*v(gz))/2000'
Bb4 b4 0 v='v(bg) -0.85*v(off) + v(gmm)*( v(lxy)*v(gx) +v(lxy)*v(gy) -v(lz)*v(gz))/2000'

R1a VEXC S1P r='1meg*(1-v(b1))'
R1b S1P  GND r='1meg*(1+v(b1))'
R1c VEXC S1N r='1meg*(1+v(b1))'
R1d S1N  GND r='1meg*(1-v(b1))'
R2a VEXC S2P r='1meg*(1-v(b2))'
R2b S2P  GND r='1meg*(1+v(b2))'
R2c VEXC S2N r='1meg*(1+v(b2))'
R2d S2N  GND r='1meg*(1-v(b2))'
R3a VEXC S3P r='1meg*(1-v(b3))'
R3b S3P  GND r='1meg*(1+v(b3))'
R3c VEXC S3N r='1meg*(1+v(b3))'
R3d S3N  GND r='1meg*(1-v(b3))'
R4a VEXC S4P r='1meg*(1-v(b4))'
R4b S4P  GND r='1meg*(1+v(b4))'
R4c VEXC S4N r='1meg*(1+v(b4))'
R4d S4N  GND r='1meg*(1-v(b4))'
"}
C {a_zonetic2026/XSCHEM_v2/GRADIENT_NAV2_V2.sym} 0 400 0 0 {name=xnav2}
C {devices/lab_wire.sym} -150 300 0 0 {name=qS1P sig_type=std_logic lab=S1P}
C {devices/lab_wire.sym} -150 320 0 0 {name=qS1N sig_type=std_logic lab=S1N}
C {devices/lab_wire.sym} -150 340 0 0 {name=qS2P sig_type=std_logic lab=S2P}
C {devices/lab_wire.sym} -150 360 0 0 {name=qS2N sig_type=std_logic lab=S2N}
C {devices/lab_wire.sym} -150 400 0 0 {name=qS3P sig_type=std_logic lab=S3P}
C {devices/lab_wire.sym} -150 420 0 0 {name=qS3N sig_type=std_logic lab=S3N}
C {devices/lab_wire.sym} -150 440 0 0 {name=qS4P sig_type=std_logic lab=S4P}
C {devices/lab_wire.sym} -150 460 0 0 {name=qS4N sig_type=std_logic lab=S4N}
C {devices/lab_wire.sym} 150 300 2 0 {name=qXPv sig_type=std_logic lab=XPv}
C {devices/lab_wire.sym} 150 320 2 0 {name=qXv sig_type=std_logic lab=Xv}
C {devices/lab_wire.sym} 150 340 2 0 {name=qXNv sig_type=std_logic lab=XNv}
C {devices/lab_wire.sym} 150 360 2 0 {name=qYPv sig_type=std_logic lab=YPv}
C {devices/lab_wire.sym} 150 380 2 0 {name=qYv sig_type=std_logic lab=Yv}
C {devices/lab_wire.sym} 150 400 2 0 {name=qYNv sig_type=std_logic lab=YNv}
C {devices/lab_wire.sym} 150 420 2 0 {name=qZPv sig_type=std_logic lab=ZPv}
C {devices/lab_wire.sym} 150 440 2 0 {name=qZv sig_type=std_logic lab=Zv}
C {devices/lab_wire.sym} 150 460 2 0 {name=qZNv sig_type=std_logic lab=ZNv}
C {devices/lab_wire.sym} 0 270 1 0 {name=qVDD sig_type=std_logic lab=VDDV}
C {devices/gnd.sym} 0 490 0 0 {name=qVSS lab=GND
value=5}
C {devices/vsource.sym} 350 -520 0 0 {name=V4 value=5
}
C {devices/lab_wire.sym} 350 -550 0 0 {name=pV4a sig_type=std_logic lab=VDDV}
C {devices/gnd.sym} 350 -490 0 0 {name=lV4 lab=GND
value=5}
value=5}
}
value=5}

T {THE TOP AS IT IS IN THE GDS. Same four sensors as the other one, so the
comparison between the two output decisions is at equal stimulus: this one
still has the three COMP_OUT, whose inverter pair does not switch in the
range the Z weight output lives in. Its own supply, so its current can be
told apart. The decoupling block is only_toplevel and does not come in here;
the eleven ESD cells DO, which is what puts their series resistor and their
diode capacitance on the sensor inputs.} -600 1000 0 0 0.4 0.4 {}
C {a_zonetic2026/XSCHEM/GRADIENT_NAV2.sym} 0 1200 0 0 {name=xnavt}
C {devices/lab_wire.sym} -150 1100 0 0 {name=tIS1P sig_type=std_logic lab=S1P}
C {devices/lab_wire.sym} -150 1120 0 0 {name=tIS1N sig_type=std_logic lab=S1N}
C {devices/lab_wire.sym} -150 1140 0 0 {name=tIS2P sig_type=std_logic lab=S2P}
C {devices/lab_wire.sym} -150 1160 0 0 {name=tIS2N sig_type=std_logic lab=S2N}
C {devices/lab_wire.sym} -150 1200 0 0 {name=tIS3P sig_type=std_logic lab=S3P}
C {devices/lab_wire.sym} -150 1220 0 0 {name=tIS3N sig_type=std_logic lab=S3N}
C {devices/lab_wire.sym} -150 1240 0 0 {name=tIS4P sig_type=std_logic lab=S4P}
C {devices/lab_wire.sym} -150 1260 0 0 {name=tIS4N sig_type=std_logic lab=S4N}
C {devices/lab_wire.sym} 150 1100 2 0 {name=tOXP sig_type=std_logic lab=XPt}
C {devices/lab_wire.sym} 150 1120 2 0 {name=tOX sig_type=std_logic lab=Xt}
C {devices/lab_wire.sym} 150 1140 2 0 {name=tOXN sig_type=std_logic lab=XNt}
C {devices/lab_wire.sym} 150 1160 2 0 {name=tOYP sig_type=std_logic lab=YPt}
C {devices/lab_wire.sym} 150 1180 2 0 {name=tOY sig_type=std_logic lab=Yt}
C {devices/lab_wire.sym} 150 1200 2 0 {name=tOYN sig_type=std_logic lab=YNt}
C {devices/lab_wire.sym} 150 1220 2 0 {name=tOZP sig_type=std_logic lab=ZPt}
C {devices/lab_wire.sym} 150 1240 2 0 {name=tOZ sig_type=std_logic lab=Zt}
C {devices/lab_wire.sym} 150 1260 2 0 {name=tOZN sig_type=std_logic lab=ZNt}
C {devices/lab_wire.sym} 0 1070 1 0 {name=tVDD sig_type=std_logic lab=VDDT}
C {devices/gnd.sym} 0 1290 0 0 {name=tVSS lab=GND
value=5}
C {devices/vsource.sym} 510 -520 0 0 {name=V6 value=5
}
C {devices/lab_wire.sym} 510 -550 0 0 {name=pV6a sig_type=std_logic lab=VDDT}
C {devices/gnd.sym} 510 -490 0 0 {name=lV6 lab=GND
value=5}
