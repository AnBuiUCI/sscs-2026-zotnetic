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
* A SOURCE AT A PLACE, and does the chip point at it?
*
* Everything measured so far imposed a UNIFORM gradient in a direction. Here
* there is a source sitting somewhere and each sensor reads the MAGNITUDE of
* its field at its own vertex. That is the question the chip exists to answer.
*
* The source goes in spherical coordinates about the centre of the box, reusing
* the two angles the other bench already has plus the distance `rad`:
*
*     p = rad * (cos(ang), sin(ang) sin(tilt), sin(ang) cos(tilt))
*
* and `dip` picks the model, which is the point of the whole thing:
*
*   dip = 0  SYMMETRIC: |B| depends on the DISTANCE only, so grad|B| points
*            EXACTLY at the source and whatever error comes out is the chip.
*   dip = 1  A REAL DIPOLE, axis along +z: |B| depends on the angle too, so
*            grad|B| does NOT point exactly at the source even with a perfect
*            chip. The difference between the two separates the error of the
*            circuit from the error of the physics.
*
* `bcen` is |B| at the centre of the box in dR/R, and the amplitude is scaled
* so that it comes out that way whatever the distance: amp = bcen * rad^3.
* The sensor mismatch keeps the same fixed, deliberately asymmetric pattern.
Voff  off  0 0
Vlxy  lxy  0 1000
Vlz   lz   0 1000
Vrad  rad  0 3000
Vbcen bcen 0 5m
Vdip  dip  0 0
Vang  ang  0 0
Vtilt tilt 0 0

Bux ux 0 v='cos(v(ang)*3.14159265358979/180)'
Buy uy 0 v='sin(v(ang)*3.14159265358979/180)*sin(v(tilt)*3.14159265358979/180)'
Buz uz 0 v='sin(v(ang)*3.14159265358979/180)*cos(v(tilt)*3.14159265358979/180)'
Bpx px 0 v='v(rad)*v(ux)'
Bpy py 0 v='v(rad)*v(uy)'
Bpz pz 0 v='v(rad)*v(uz)'
Bamp amp 0 v='v(bcen)*v(rad)*v(rad)*v(rad)'

* sensor 1 at (-1Lxy/2, +1Lxy/2, +1Lz/2)
B1x q1x 0 v='-1*v(lxy)/2 - v(px)'
B1y q1y 0 v='1*v(lxy)/2 - v(py)'
B1z q1z 0 v='1*v(lz)/2  - v(pz)'
B1d q1d 0 v='sqrt(v(q1x)*v(q1x)+v(q1y)*v(q1y)+v(q1z)*v(q1z))'
B1c q1c 0 v='v(q1z)/v(q1d)'
Bb1 b1 0 v='+1.00*v(off) + v(amp)/(v(q1d)*v(q1d)*v(q1d)) * (1 + v(dip)*(sqrt(1+3*v(q1c)*v(q1c))-1))'

* sensor 2 at (+1Lxy/2, -1Lxy/2, +1Lz/2)
B2x q2x 0 v='1*v(lxy)/2 - v(px)'
B2y q2y 0 v='-1*v(lxy)/2 - v(py)'
B2z q2z 0 v='1*v(lz)/2  - v(pz)'
B2d q2d 0 v='sqrt(v(q2x)*v(q2x)+v(q2y)*v(q2y)+v(q2z)*v(q2z))'
B2c q2c 0 v='v(q2z)/v(q2d)'
Bb2 b2 0 v='-0.62*v(off) + v(amp)/(v(q2d)*v(q2d)*v(q2d)) * (1 + v(dip)*(sqrt(1+3*v(q2c)*v(q2c))-1))'

* sensor 3 at (-1Lxy/2, -1Lxy/2, -1Lz/2)
B3x q3x 0 v='-1*v(lxy)/2 - v(px)'
B3y q3y 0 v='-1*v(lxy)/2 - v(py)'
B3z q3z 0 v='-1*v(lz)/2  - v(pz)'
B3d q3d 0 v='sqrt(v(q3x)*v(q3x)+v(q3y)*v(q3y)+v(q3z)*v(q3z))'
B3c q3c 0 v='v(q3z)/v(q3d)'
Bb3 b3 0 v='+0.31*v(off) + v(amp)/(v(q3d)*v(q3d)*v(q3d)) * (1 + v(dip)*(sqrt(1+3*v(q3c)*v(q3c))-1))'

* sensor 4 at (+1Lxy/2, +1Lxy/2, -1Lz/2)
B4x q4x 0 v='1*v(lxy)/2 - v(px)'
B4y q4y 0 v='1*v(lxy)/2 - v(py)'
B4z q4z 0 v='-1*v(lz)/2  - v(pz)'
B4d q4d 0 v='sqrt(v(q4x)*v(q4x)+v(q4y)*v(q4y)+v(q4z)*v(q4z))'
B4c q4c 0 v='v(q4z)/v(q4d)'
Bb4 b4 0 v='-0.85*v(off) + v(amp)/(v(q4d)*v(q4d)*v(q4d)) * (1 + v(dip)*(sqrt(1+3*v(q4c)*v(q4c))-1))'

* The four bridges, 1 Mohm per arm and all four arms moving at once, so Vcm
* is VEXC/2 exactly and independent of b.
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
