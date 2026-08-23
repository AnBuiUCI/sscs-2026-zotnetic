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
"}
C {devices/vsource.sym} 110 -520 0 0 {name=V1 value=5
}
C {devices/lab_wire.sym} 110 -550 0 0 {name=pV1a sig_type=std_logic lab=VEXC}
C {devices/gnd.sym} 110 -490 0 0 {name=lV1 lab=GND
value=5}
C {devices/vsource.sym} 190 -520 0 0 {name=V2 value=5
}
C {devices/lab_wire.sym} 190 -550 0 0 {name=pV2a sig_type=std_logic lab=VDDS}
C {devices/gnd.sym} 190 -490 0 0 {name=lV2 lab=GND
value=5}
C {devices/vsource.sym} 270 -520 0 0 {name=V3 value=5
}
C {devices/lab_wire.sym} 270 -550 0 0 {name=pV3a sig_type=std_logic lab=VDDR}
C {devices/gnd.sym} 270 -490 0 0 {name=lV3 lab=GND
value=5}
C {devices/code_shown.sym} -700 -700 0 0 {name=ESTIMULO only_toplevel=true
value="
* THE FOUR SENSORS IN SPACE, AND THE GRADIENT THEY MEASURE.
*
* They are not four axes in a plane: they are four POSITIONS. They sit at the
* un tetraedro regular inscrito en un cubo -- dos en esquinas opuestas del plano
* lower z plane and the other two on the opposite corners of the upper one:
*
*                S1 .--------. .              z ^   y
*                  /|       /| .                |  /
*             S2 .  |    . '  |                 | /
*                |  |  '      |                 +----> x
*                |  '---------|--. S4
*                | /          | /
*             S3 '------------'
*
*   sensor   cubo [0,1]      centrado en +-1     plano z
*     S1     (0, 1, 1)        (-1, +1, +1)        superior
*     S2     (1, 0, 1)        (+1, -1, +1)        superior
*     S3     (0, 0, 0)        (-1, -1, -1)        inferior
*     S4     (1, 1, 0)        (+1, +1, -1)        inferior
*
* All six edges are the same length (2*sqrt(2) in half cube sides), so it is a
* REGULAR tetrahedron and the centroid falls on the origin. That is what makes
* the arrangement useful: the four position vectors are mutually ORTHOGONAL
* componente a componente -- suma(u_a * u_b) sale diagonal, 4 en la traza y 0
* out -- so from the four readings the three components of the
* gradiente sin resolver ningun sistema:
*
*     gx = (-b1 +b2 -b3 +b4)/4
*     gy = (+b1 -b2 -b3 +b4)/4
*     gz = (+b1 +b2 -b3 -b4)/4
*
* THE STIMULUS. A field with a uniform gradient: what each sensor reads is the
* projection of ITS POSITION onto the gradient direction. Sweeping `ang` from
* 0 a 360 esa direccion da una vuelta entera dentro de un plano, y `tilt` elige
* cual:
*
*     tilt = 0   -> the gradient turns in the X-Z plane   (what we want to measure)
*     tilt = 90  -> gira en el plano X-Y
*
* The sqrt(2) normalisation is so that, turning within a plane
* coordenado, el maximo de b sea exactamente v(amp): asi `amp` sigue siendo dR/R
* end to end, as in the other benches, and the figures are comparable.
Vamp amp 0 0.02
Vang ang 0 0
Vtilt tilt 0 0

Bgx gx 0 v='cos(v(ang)*3.14159265358979/180)'
Bgy gy 0 v='sin(v(ang)*3.14159265358979/180)*sin(v(tilt)*3.14159265358979/180)'
Bgz gz 0 v='sin(v(ang)*3.14159265358979/180)*cos(v(tilt)*3.14159265358979/180)'

Bb1 b1 0 v='v(amp)*(-v(gx) +v(gy) +v(gz))/1.41421356237'
Bb2 b2 0 v='v(amp)*( v(gx) -v(gy) +v(gz))/1.41421356237'
Bb3 b3 0 v='v(amp)*(-v(gx) -v(gy) -v(gz))/1.41421356237'
Bb4 b4 0 v='v(amp)*( v(gx) +v(gy) -v(gz))/1.41421356237'

* THE FOUR BRIDGES, 1 Mohm per arm and all four arms moving at once:
*
*     VEXC --R(1-b)-- SkP --R(1+b)-- GND      V(SkP) = VEXC*(1+b)/2
*     VEXC --R(1+b)-- SkN --R(1-b)-- GND      V(SkN) = VEXC*(1-b)/2
*
* from which Vdiff = VEXC*b and **Vcm = VEXC/2 exactly, independent of b**. The
* second matters: if the common mode moved with the signal it would mix with
* these cells' common-mode sensitivity and there would be no way to separate the
* dos cosas al leer la curva.
*
* They go as behavioural resistors in a code block, not as swept symbols:
* `dc` takes two nested sources at most and here there are
* SIXTEEN resistors that must all move at once and consistently.
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
C {a_zonetic2026/XSCHEM/GRADIENT_NAV2.sym} 0 0 0 0 {name=xnav}
C {devices/lab_wire.sym} -150 -100 0 0 {name=pS1P sig_type=std_logic lab=S1P}
C {devices/lab_wire.sym} -150 -80 0 0 {name=pS1N sig_type=std_logic lab=S1N}
C {devices/lab_wire.sym} -150 -60 0 0 {name=pS2P sig_type=std_logic lab=S2P}
C {devices/lab_wire.sym} -150 -40 0 0 {name=pS2N sig_type=std_logic lab=S2N}
C {devices/lab_wire.sym} -150 0 0 0 {name=pS3P sig_type=std_logic lab=S3P}
C {devices/lab_wire.sym} -150 20 0 0 {name=pS3N sig_type=std_logic lab=S3N}
C {devices/lab_wire.sym} -150 40 0 0 {name=pS4P sig_type=std_logic lab=S4P}
C {devices/lab_wire.sym} -150 60 0 0 {name=pS4N sig_type=std_logic lab=S4N}
C {devices/lab_wire.sym} 150 -100 2 0 {name=pXP sig_type=std_logic lab=XP}
C {devices/lab_wire.sym} 150 -80 2 0 {name=pX sig_type=std_logic lab=X}
C {devices/lab_wire.sym} 150 -60 2 0 {name=pXN sig_type=std_logic lab=XN}
C {devices/lab_wire.sym} 150 -40 2 0 {name=pYP sig_type=std_logic lab=YP}
C {devices/lab_wire.sym} 150 -20 2 0 {name=pY sig_type=std_logic lab=Y}
C {devices/lab_wire.sym} 150 0 2 0 {name=pYN sig_type=std_logic lab=YN}
C {devices/lab_wire.sym} 150 20 2 0 {name=pZP sig_type=std_logic lab=ZP}
C {devices/lab_wire.sym} 150 40 2 0 {name=pZ sig_type=std_logic lab=Z}
C {devices/lab_wire.sym} 150 60 2 0 {name=pZN sig_type=std_logic lab=ZN}
C {devices/lab_wire.sym} 0 -130 1 0 {name=pVDD sig_type=std_logic lab=VDDS}
C {devices/gnd.sym} 0 90 0 0 {name=lVSS lab=GND
value=5}
C {devices/code_shown.sym} 900 -700 0 0 {name=RECONSTRUCCION only_toplevel=true
value="
* THE SAME NAVIGATOR, REBUILT FROM THE v2 LAYOUT BLOCKS EXTRACTED WITH RC.
*
* It hangs off the SAME eight sensor nodes as the schematic and carries its own
* supply (VDDR against VDDS), so current draw can be compared too. All
* sus nodos acaban en 'r'.
*
* The topology is copied LINE BY LINE from the top netlist, not from memory:
*
*   x1 S1N S1P VDD X1 S2N Y1 Z1 S2P VSS S3N S3P GRADIENT2
*   x2 S1N S1P VDD X2 S2N Y2 Z2 S2P VSS S4N S4P GRADIENT2
*   x3 S3N S3P VDD X3 S4N Y3 Z3 S4P VSS S1N S1P GRADIENT2
*   x4 S3N S3P VDD X4 S4N Y4 Z4 S4P VSS S2N S2P GRADIENT2
*   x5 VDD VSS X X1 X2 X3 X4 WEIGHT   +   x8 VDD XP X XN VSS COMP_OUT
*
* with .subckt GRADIENT2 SXN SXP VDD X SYN Y Z SYP VSS SZN SZP, i.e. each
* cadena k lee tres sensores en el orden (X, Y, Z) y saca Xk Yk Zk.
*
* CAREFUL WITH THE PORT ORDER. xschem emits them in the order of the symbol B
* lines and magic in the order it finds them in the layout, and they do NOT agree.
* Above each group is the real order, and the files are the _V2_ ones that
* produce TEST/preparar_extraidos.sh, que renombra el subcircuito y normaliza el
* order. Note that OPAM_LIN_flat has OUT in the middle and the others do not, and
* that WEIGHT_COMP has its own completely out of order.
*
* AND CAREFUL WITH THE WEIGHT. WEIGHT_COMP feeds its VB to the WEIGHT's VC pin
* reves -- se ve en su propio netlist, x1 VDD VSS WE VA VB VC VD WEIGHT contra
* .subckt WEIGHT VDD GND OUT VA VC VB VD -- so chains 2 and 3 are
* crossed relative to what one would write by hand. Wiring it 'in order' weighs
* dos cadenas y no da ningun error.
.include ../../../../layouts_v2/OPAM_LIN_flat/mag/OPAM_LIN_flat_V2_pex_rc.spice
.include ../../../../layouts_v2/COMP/mag/COMP_V2_pex_rc.spice
.include ../../../../layouts_v2/DECODER/mag/DECODER_V2_pex_rc.spice
.include ../../../../layouts_v2/WEIGHT_COMP/mag/WEIGHT_COMP_V2_pex_rc.spice

* .subckt OPAM_LIN_flat_V2  VSS VDD INP OUT INN
* .subckt COMP_V2           VSS VDD OUT INP INN
* .subckt DECODER_V2        VSS VDD YZ Z XY XZ Y X

* --- cadena 1: X=S1  Y=S2  Z=S3
XA11 GND VDDR S1P SX1r S1N OPAM_LIN_flat_V2
XA12 GND VDDR S2P SY1r S2N OPAM_LIN_flat_V2
XA13 GND VDDR S3P SZ1r S3N OPAM_LIN_flat_V2
XC11 GND VDDR XY1r SY1r SX1r COMP_V2
XC12 GND VDDR XZ1r SZ1r SX1r COMP_V2
XC13 GND VDDR YZ1r SZ1r SY1r COMP_V2
XD1  GND VDDR YZ1r Z1r XY1r XZ1r Y1r X1r DECODER_V2

* --- cadena 2: X=S1  Y=S2  Z=S4
XA21 GND VDDR S1P SX2r S1N OPAM_LIN_flat_V2
XA22 GND VDDR S2P SY2r S2N OPAM_LIN_flat_V2
XA23 GND VDDR S4P SZ2r S4N OPAM_LIN_flat_V2
XC21 GND VDDR XY2r SY2r SX2r COMP_V2
XC22 GND VDDR XZ2r SZ2r SX2r COMP_V2
XC23 GND VDDR YZ2r SZ2r SY2r COMP_V2
XD2  GND VDDR YZ2r Z2r XY2r XZ2r Y2r X2r DECODER_V2

* --- cadena 3: X=S3  Y=S4  Z=S1
XA31 GND VDDR S3P SX3r S3N OPAM_LIN_flat_V2
XA32 GND VDDR S4P SY3r S4N OPAM_LIN_flat_V2
XA33 GND VDDR S1P SZ3r S1N OPAM_LIN_flat_V2
XC31 GND VDDR XY3r SY3r SX3r COMP_V2
XC32 GND VDDR XZ3r SZ3r SX3r COMP_V2
XC33 GND VDDR YZ3r SZ3r SY3r COMP_V2
XD3  GND VDDR YZ3r Z3r XY3r XZ3r Y3r X3r DECODER_V2

* --- cadena 4: X=S3  Y=S4  Z=S2
XA41 GND VDDR S3P SX4r S3N OPAM_LIN_flat_V2
XA42 GND VDDR S4P SY4r S4N OPAM_LIN_flat_V2
XA43 GND VDDR S2P SZ4r S2N OPAM_LIN_flat_V2
XC41 GND VDDR XY4r SY4r SX4r COMP_V2
XC42 GND VDDR XZ4r SZ4r SX4r COMP_V2
XC43 GND VDDR YZ4r SZ4r SY4r COMP_V2
XD4  GND VDDR YZ4r Z4r XY4r XZ4r Y4r X4r DECODER_V2

* --- los tres pesos y sus comparadores de salida
* .subckt WEIGHT_COMP_V2 VSS VDD VD WE VA VB OUT OUT_N VC
XW1 GND VDDR X4r Xr X1r X2r XPr XNr X3r WEIGHT_COMP_V2
XW2 GND VDDR Y4r Yr Y1r Y2r YPr YNr Y3r WEIGHT_COMP_V2
XW3 GND VDDR Z4r Zr Z1r Z2r ZPr ZNr Z3r WEIGHT_COMP_V2
"}
C {devices/code_shown.sym} 520 -700 0 0 {name=s1
only_toplevel=false
value="
* CAREFUL: not one brace in this text. xschem counts them to find where the
* attribute block ends and a single one inside a comment cuts it in half,
* leaving the netlist with the template 'blabla' and raising no error.
*
* Signals inside the schematic come out by hierarchical name: xnav is the top
* instance and inside it x1..x4 are the four GRADIENT2.
.save all
.control
* Fondo de escala de una AMR tipica: dR/R = 2 %, o sea 100 mV diferenciales.
alter Vamp = 0.02
dc Vang 0 360 0.5
wrdata ancho.txt v(X) v(Y) v(Z) v(XP) v(XN) v(YP) v(YN) v(ZP) v(ZN) v(Xr) v(Yr) v(Zr) v(XPr) v(XNr) v(YPr) v(YNr) v(ZPr) v(ZNr) v(xnav.X1) v(xnav.X2) v(xnav.X3) v(xnav.X4) v(xnav.Y1) v(xnav.Y2) v(xnav.Y3) v(xnav.Y4) v(xnav.Z1) v(xnav.Z2) v(xnav.Z3) v(xnav.Z4) v(X1r) v(X2r) v(X3r) v(X4r) v(Y1r) v(Y2r) v(Y3r) v(Y4r) v(Z1r) v(Z2r) v(Z3r) v(Z4r) v(S1P) v(S1N) v(S2P) v(S2N) v(S3P) v(S3N) v(S4P) v(S4N) v(VEXC)*i(V1) v(VDDS)*i(V2) v(VDDR)*i(V3)
* Ventana fina: dR/R = 50 ppm, o sea 250 uV diferenciales.
alter Vamp = 50u
dc Vang 0 360 0.5
wrdata fino.txt v(X) v(Y) v(Z) v(XP) v(XN) v(YP) v(YN) v(ZP) v(ZN) v(Xr) v(Yr) v(Zr) v(XPr) v(XNr) v(YPr) v(YNr) v(ZPr) v(ZNr) v(xnav.X1) v(xnav.X2) v(xnav.X3) v(xnav.X4) v(xnav.Y1) v(xnav.Y2) v(xnav.Y3) v(xnav.Y4) v(xnav.Z1) v(xnav.Z2) v(xnav.Z3) v(xnav.Z4) v(X1r) v(X2r) v(X3r) v(X4r) v(Y1r) v(Y2r) v(Y3r) v(Y4r) v(Z1r) v(Z2r) v(Z3r) v(Z4r) v(S1P) v(S1N) v(S2P) v(S2N) v(S3P) v(S3N) v(S4P) v(S4N) v(VEXC)*i(V1) v(VDDS)*i(V2) v(VDDR)*i(V3)
.endc
"}
