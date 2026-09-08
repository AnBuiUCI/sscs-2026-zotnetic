v {xschem version=3.4.8RC file_version=1.3}
G {}
K {}
V {}
S {}
F {}
E {}
N -250 -380 -190 -380 {lab=GND}
N -250 -460 -250 -440 {lab=S2P}
N -190 -460 -190 -440 {lab=S2N}
N -250 -520 -190 -520 {lab=VEXC}
N -120 -380 -60 -380 {lab=GND}
N -120 -460 -120 -440 {lab=S3P}
N -60 -460 -60 -440 {lab=S3N}
N -120 -520 -60 -520 {lab=VEXC}
N -400 -380 -340 -380 {lab=GND}
N -400 -460 -400 -440 {lab=S1P}
N -340 -460 -340 -440 {lab=S1N}
N -400 -520 -340 -520 {lab=VEXC}
C {devices/code.sym} 570 -600 0 0 {name=MODELS1 only_toplevel=true
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
C {devices/lab_wire.sym} 190 -550 0 0 {name=pV2a sig_type=std_logic lab=VDD1}
C {devices/gnd.sym} 190 -490 0 0 {name=lV2 lab=GND
value=5}
C {devices/vsource.sym} 270 -520 0 0 {name=V6 value=5
}
C {devices/lab_wire.sym} 270 -550 0 0 {name=pV6a sig_type=std_logic lab=VDD2}
C {devices/gnd.sym} 270 -490 0 0 {name=lV6 lab=GND
value=5}
C {devices/code.sym} -340 -1040 0 0 {name=ESTIMULO only_toplevel=true
value="
* THE FIELD. Three components 120 degrees apart, which is what makes them sum
* to zero: the vector only changes DIRECTION, not magnitude. Sweeping
* Vang from 0 to 360 covers the whole circle, and if the chain is right each
* eje deberia ganar exactamente 120 grados: X de -60 a 60, Y de 60 a 180 y Z de
* 180 to 300. How far those three boundaries drift is the figure of the bench.
*
* v(amp) IS dR/R, with no conversion factors in between: each bridge arm is
* 1meg*(1 +- v(bx)), so the amplifier sees VEXC*v(bx) of differential signal
* and the common mode stays pinned at VEXC/2 whatever happens to
* la senal. Eso segundo no es un adorno: si el modo comun se moviera con la
* signal it would mix with these cells' common-mode sensitivity and there
* would be no way to separate the two when reading the curve.
*
* Va con fuentes B y resistencias de comportamiento, y no barriendo
* resistors, because dc takes two nested sources at most and here there are
* TWELVE resistors that must all move at once and consistently.
*
* AND A SECOND MODE, for the octant cases. The rotation above pins the three
* readings to bx+by+bz = 0, so patterns like (+,+,+) are unreachable by
* construction and this bench can only ever see three of the eight sign
* combinations. With v(sel) = 1 each reading becomes v(amp) times its own
* coefficient cx/cy/cz, so the SIGNS of those three coefficients pick the
* octant and their MAGNITUDES pick the ordering, while sweeping Vamp still
* sweeps the field inside that octant.
*
* The decoder puts out the SMALLEST axis (X = XY*XZ), so the expected answer
* at every point is argmin(cx, cy, cz) -- a truth table checkable entry by
* entry. Coefficients are given distinct magnitudes on purpose: three equal
* ones are a three-way tie with no right answer.
*
* v(sel) = 0 leaves the rotation exactly as it was: nothing above changes.
Vamp amp 0 0.02
Vang ang 0 0
Vsel sel 0 0
Vcx cx 0 1
Vcy cy 0 0
Vcz cz 0 0
Bbx bx 0 v='v(sel) > 0.5 ? v(amp)*v(cx) : v(amp)*cos( v(ang)       *3.14159265358979/180)'
Bby by 0 v='v(sel) > 0.5 ? v(amp)*v(cy) : v(amp)*cos((v(ang)-120.0)*3.14159265358979/180)'
Bbz bz 0 v='v(sel) > 0.5 ? v(amp)*v(cz) : v(amp)*cos((v(ang)+120.0)*3.14159265358979/180)'
"}
C {devices/code.sym} 900 -1010 0 0 {name=RECONSTRUCCION only_toplevel=true
value="
* THE SAME TWO CHAINS, REBUILT FROM THE v2 LAYOUT BLOCKS.
* They hang off the SAME six sensor nodes as the schematic ones and each
* carries its own supply, so current draw can be compared too.
*
* La topologia es la de COMBINATION/GRADIENT.sch, copiada nodo a nodo:
*
*     amp X: S1N->INN  S1P->INP  -> SX        COMP XY: INN=SX INP=SY -> XY
*     amp Y: S2N->INN  S2P->INP  -> SY        COMP XZ: INN=SX INP=SZ -> XZ
*     amp Z: S3N->INN  S3P->INP  -> SZ        COMP YZ: INN=SY INP=SZ -> YZ
*                                             DECODER: XY XZ YZ -> X Y Z
*
* CAREFUL WITH THE PORT ORDER. xschem emits them in the order of the symbol B
* lines and magic in the order it finds them in the layout, and they do NOT agree:
* el esquematico declara OPAM VDD INN OUT INP VSS y el extraido OPAM VSS VDD OUT
* INP INN. Cablear las dos igual significa cosas distintas y no da ningun error.
* That is why the real order is written above each group, and why the files are
* the _V2_ ones produced by TEST/preparar_extraidos.sh: it renames the subcircuit
* -- both declare the same name and cannot be included together -- and normalises
* the order. Note that OPAM_LIN_flat has OUT in the middle and the others do not.
.include ../../../../layouts_v2/OPAM/mag/OPAM_V2_pex_rc.spice
.include ../../../../layouts_v2/OPAM_LIN_flat/mag/OPAM_LIN_flat_V2_pex_rc.spice
.include ../../../../layouts_v2/COMP/mag/COMP_V2_pex_rc.spice
.include ../../../../layouts_v2/DECODER/mag/DECODER_V2_pex_rc.spice

* --- G3: the G1 chain, with the v2 layout OPAM
* .subckt OPAM_V2     VSS VDD OUT INP INN
XA31 GND VDD3 SX3 S1P S1N OPAM_V2
XA32 GND VDD3 SY3 S2P S2N OPAM_V2
XA33 GND VDD3 SZ3 S3P S3N OPAM_V2
* .subckt COMP_V2     VSS VDD OUT INP INN
XC31 GND VDD3 XY3 SY3 SX3 COMP_V2
XC32 GND VDD3 XZ3 SZ3 SX3 COMP_V2
XC33 GND VDD3 YZ3 SZ3 SY3 COMP_V2
* .subckt DECODER_V2  VSS VDD YZ Z XY XZ Y X
XD3  GND VDD3 YZ3 Z3 XY3 XZ3 Y3 X3 DECODER_V2

* --- G4: the G2 chain, with the v2 layout OPAM_LIN_flat
* .subckt OPAM_LIN_flat_V2  VSS VDD INP OUT INN
XA41 GND VDD4 S1P SX4 S1N OPAM_LIN_flat_V2
XA42 GND VDD4 S2P SY4 S2N OPAM_LIN_flat_V2
XA43 GND VDD4 S3P SZ4 S3N OPAM_LIN_flat_V2
* .subckt COMP_V2     VSS VDD OUT INP INN
XC41 GND VDD4 XY4 SY4 SX4 COMP_V2
XC42 GND VDD4 XZ4 SZ4 SX4 COMP_V2
XC43 GND VDD4 YZ4 SZ4 SY4 COMP_V2
* .subckt DECODER_V2  VSS VDD YZ Z XY XZ Y X
XD4  GND VDD4 YZ4 Z4 XY4 XZ4 Y4 X4 DECODER_V2
"}
C {devices/code.sym} 520 -1010 0 0 {name=s1
only_toplevel=false
value="
* CAREFUL: not one brace in this text. xschem counts them to find where the
* attribute block ends and a single one inside a comment cuts it in half,
* leaving the netlist with the template 'blabla' and raising no error.
*
* This bench does NOT need a common-mode source, unlike test_comp_* and
* test_opam_*: there the input pair were two gates with no DC path to
* ground, and here the bridge itself provides it.
*
* The intermediate signals of the schematic chains come out by hierarchical
* name, v(x2.SX) and company. In the hand-rebuilt ones the nodes are
* primer nivel y se llaman SX3, XY3 y asi.
.save all
.control
* Fondo de escala de una AMR tipica: dR/R = 2 %, o sea 100 mV diferenciales.
alter Vamp = 0.02
dc Vang 0 360 0.5
wrdata ancho.txt v(X1) v(Y1) v(Z1) v(X2) v(Y2) v(Z2) v(X3) v(Y3) v(Z3) v(X4) v(Y4) v(Z4) v(x2.SX) v(x2.SY) v(x2.SZ) v(x3.SX) v(x3.SY) v(x3.SZ) v(SX3) v(SY3) v(SZ3) v(SX4) v(SY4) v(SZ4) v(x2.net1) v(x2.net2) v(x2.net3) v(x3.net1) v(x3.net2) v(x3.net3) v(XY3) v(XZ3) v(YZ3) v(XY4) v(XZ4) v(YZ4) v(S1P) v(S1N) v(S2P) v(S2N) v(S3P) v(S3N) v(VEXC)*i(V1) v(VDD1)*i(V2) v(VDD2)*i(V6) v(VDD3)*i(V3) v(VDD4)*i(V4)
* Ventana fina: dR/R = 50 ppm, o sea 250 uV diferenciales.
alter Vamp = 50u
dc Vang 0 360 0.5
wrdata fino.txt v(X1) v(Y1) v(Z1) v(X2) v(Y2) v(Z2) v(X3) v(Y3) v(Z3) v(X4) v(Y4) v(Z4) v(x2.SX) v(x2.SY) v(x2.SZ) v(x3.SX) v(x3.SY) v(x3.SZ) v(SX3) v(SY3) v(SZ3) v(SX4) v(SY4) v(SZ4) v(x2.net1) v(x2.net2) v(x2.net3) v(x3.net1) v(x3.net2) v(x3.net3) v(XY3) v(XZ3) v(YZ3) v(XY4) v(XZ4) v(YZ4) v(S1P) v(S1N) v(S2P) v(S2N) v(S3P) v(S3N) v(VEXC)*i(V1) v(VDD1)*i(V2) v(VDD2)*i(V6) v(VDD3)*i(V3) v(VDD4)*i(V4)
* --------------------------------------------------------------------------
* FIELD SWEEP. Everything above turns the field and keeps its size; these two
* do the opposite -- hold the direction and sweep the MAGNITUDE, which is the
* axis a real magnet moves along as you walk towards it.
*
* The angle is parked at 60 deg, the middle of a sector: on a boundary the
* decision is meant to be undefined and the sweep would only measure noise.
*
* AND THE SWEEP DOES NOT START AT ZERO. With Vamp = 0 the three bridges are
* identical, so the three amplifiers sit at the same output and all three
* comparators land exactly on their trip point: the operating point is not
* unique and ngspice spends the sweep in gmin stepping. Starting one step in
* costs nothing and the solution is definite everywhere.
*
* Only the linear-amplifier chain, G2 (schematic) and G4 (layout), and their
* own new files so ancho.txt and fino.txt keep the column order analizar.py
* reads.
alter Vang = 60
dc Vamp 20u 0.02 20u
wrdata campo.txt v(S1P) v(S1N) v(S2P) v(S2N) v(S3P) v(S3N)
+ v(x3.SX) v(x3.SY) v(x3.SZ) v(x3.net1) v(x3.net2) v(x3.net3)
+ v(X2) v(Y2) v(Z2)
+ v(SX4) v(SY4) v(SZ4) v(XY4) v(XZ4) v(YZ4)
+ v(X4) v(Y4) v(Z4)
+ v(VDD2)*i(V6) v(VDD4)*i(V4)
* And the low end on its own scale, where the offsets and the noise live.
dc Vamp 1u 1m 1u
wrdata campo_fino.txt v(S1P) v(S1N) v(S2P) v(S2N) v(S3P) v(S3N)
+ v(x3.SX) v(x3.SY) v(x3.SZ) v(x3.net1) v(x3.net2) v(x3.net3)
+ v(X2) v(Y2) v(Z2)
+ v(SX4) v(SY4) v(SZ4) v(XY4) v(XZ4) v(YZ4)
+ v(X4) v(Y4) v(Z4)
+ v(VDD2)*i(V6) v(VDD4)*i(V4)
* --------------------------------------------------------------------------
* OCTANT CASES. Eight sign patterns times three magnitude orderings, so
* every axis gets to be the smallest, the middle one and the largest in
* each octant: 24 cases. The coefficients are written into the file as
* its first three vectors, so each file says which case it is and no
* separate manifest can drift out of step with it.
alter Vsel = 1
* case 01: c = (+1.0, +0.6, +0.3)  ->  expected Z
alter Vcx = 1.0
alter Vcy = 0.6
alter Vcz = 0.3
dc Vamp 200u 0.02 200u
wrdata oct_01.txt v(cx) v(cy) v(cz) v(S1P) v(S1N) v(S2P) v(S2N) v(S3P) v(S3N)
+ v(x3.SX) v(x3.SY) v(x3.SZ) v(x3.net1) v(x3.net2) v(x3.net3)
+ v(X2) v(Y2) v(Z2)
+ v(SX4) v(SY4) v(SZ4) v(XY4) v(XZ4) v(YZ4)
+ v(X4) v(Y4) v(Z4)
* case 02: c = (+0.3, +1.0, +0.6)  ->  expected X
alter Vcx = 0.3
alter Vcy = 1.0
alter Vcz = 0.6
dc Vamp 200u 0.02 200u
wrdata oct_02.txt v(cx) v(cy) v(cz) v(S1P) v(S1N) v(S2P) v(S2N) v(S3P) v(S3N)
+ v(x3.SX) v(x3.SY) v(x3.SZ) v(x3.net1) v(x3.net2) v(x3.net3)
+ v(X2) v(Y2) v(Z2)
+ v(SX4) v(SY4) v(SZ4) v(XY4) v(XZ4) v(YZ4)
+ v(X4) v(Y4) v(Z4)
* case 03: c = (+0.6, +0.3, +1.0)  ->  expected Y
alter Vcx = 0.6
alter Vcy = 0.3
alter Vcz = 1.0
dc Vamp 200u 0.02 200u
wrdata oct_03.txt v(cx) v(cy) v(cz) v(S1P) v(S1N) v(S2P) v(S2N) v(S3P) v(S3N)
+ v(x3.SX) v(x3.SY) v(x3.SZ) v(x3.net1) v(x3.net2) v(x3.net3)
+ v(X2) v(Y2) v(Z2)
+ v(SX4) v(SY4) v(SZ4) v(XY4) v(XZ4) v(YZ4)
+ v(X4) v(Y4) v(Z4)
* case 04: c = (+1.0, +0.6, -0.3)  ->  expected Z
alter Vcx = 1.0
alter Vcy = 0.6
alter Vcz = -0.3
dc Vamp 200u 0.02 200u
wrdata oct_04.txt v(cx) v(cy) v(cz) v(S1P) v(S1N) v(S2P) v(S2N) v(S3P) v(S3N)
+ v(x3.SX) v(x3.SY) v(x3.SZ) v(x3.net1) v(x3.net2) v(x3.net3)
+ v(X2) v(Y2) v(Z2)
+ v(SX4) v(SY4) v(SZ4) v(XY4) v(XZ4) v(YZ4)
+ v(X4) v(Y4) v(Z4)
* case 05: c = (+0.3, +1.0, -0.6)  ->  expected Z
alter Vcx = 0.3
alter Vcy = 1.0
alter Vcz = -0.6
dc Vamp 200u 0.02 200u
wrdata oct_05.txt v(cx) v(cy) v(cz) v(S1P) v(S1N) v(S2P) v(S2N) v(S3P) v(S3N)
+ v(x3.SX) v(x3.SY) v(x3.SZ) v(x3.net1) v(x3.net2) v(x3.net3)
+ v(X2) v(Y2) v(Z2)
+ v(SX4) v(SY4) v(SZ4) v(XY4) v(XZ4) v(YZ4)
+ v(X4) v(Y4) v(Z4)
* case 06: c = (+0.6, +0.3, -1.0)  ->  expected Z
alter Vcx = 0.6
alter Vcy = 0.3
alter Vcz = -1.0
dc Vamp 200u 0.02 200u
wrdata oct_06.txt v(cx) v(cy) v(cz) v(S1P) v(S1N) v(S2P) v(S2N) v(S3P) v(S3N)
+ v(x3.SX) v(x3.SY) v(x3.SZ) v(x3.net1) v(x3.net2) v(x3.net3)
+ v(X2) v(Y2) v(Z2)
+ v(SX4) v(SY4) v(SZ4) v(XY4) v(XZ4) v(YZ4)
+ v(X4) v(Y4) v(Z4)
* case 07: c = (+1.0, -0.6, +0.3)  ->  expected Y
alter Vcx = 1.0
alter Vcy = -0.6
alter Vcz = 0.3
dc Vamp 200u 0.02 200u
wrdata oct_07.txt v(cx) v(cy) v(cz) v(S1P) v(S1N) v(S2P) v(S2N) v(S3P) v(S3N)
+ v(x3.SX) v(x3.SY) v(x3.SZ) v(x3.net1) v(x3.net2) v(x3.net3)
+ v(X2) v(Y2) v(Z2)
+ v(SX4) v(SY4) v(SZ4) v(XY4) v(XZ4) v(YZ4)
+ v(X4) v(Y4) v(Z4)
* case 08: c = (+0.3, -1.0, +0.6)  ->  expected Y
alter Vcx = 0.3
alter Vcy = -1.0
alter Vcz = 0.6
dc Vamp 200u 0.02 200u
wrdata oct_08.txt v(cx) v(cy) v(cz) v(S1P) v(S1N) v(S2P) v(S2N) v(S3P) v(S3N)
+ v(x3.SX) v(x3.SY) v(x3.SZ) v(x3.net1) v(x3.net2) v(x3.net3)
+ v(X2) v(Y2) v(Z2)
+ v(SX4) v(SY4) v(SZ4) v(XY4) v(XZ4) v(YZ4)
+ v(X4) v(Y4) v(Z4)
* case 09: c = (+0.6, -0.3, +1.0)  ->  expected Y
alter Vcx = 0.6
alter Vcy = -0.3
alter Vcz = 1.0
dc Vamp 200u 0.02 200u
wrdata oct_09.txt v(cx) v(cy) v(cz) v(S1P) v(S1N) v(S2P) v(S2N) v(S3P) v(S3N)
+ v(x3.SX) v(x3.SY) v(x3.SZ) v(x3.net1) v(x3.net2) v(x3.net3)
+ v(X2) v(Y2) v(Z2)
+ v(SX4) v(SY4) v(SZ4) v(XY4) v(XZ4) v(YZ4)
+ v(X4) v(Y4) v(Z4)
* case 10: c = (+1.0, -0.6, -0.3)  ->  expected Y
alter Vcx = 1.0
alter Vcy = -0.6
alter Vcz = -0.3
dc Vamp 200u 0.02 200u
wrdata oct_10.txt v(cx) v(cy) v(cz) v(S1P) v(S1N) v(S2P) v(S2N) v(S3P) v(S3N)
+ v(x3.SX) v(x3.SY) v(x3.SZ) v(x3.net1) v(x3.net2) v(x3.net3)
+ v(X2) v(Y2) v(Z2)
+ v(SX4) v(SY4) v(SZ4) v(XY4) v(XZ4) v(YZ4)
+ v(X4) v(Y4) v(Z4)
* case 11: c = (+0.3, -1.0, -0.6)  ->  expected Y
alter Vcx = 0.3
alter Vcy = -1.0
alter Vcz = -0.6
dc Vamp 200u 0.02 200u
wrdata oct_11.txt v(cx) v(cy) v(cz) v(S1P) v(S1N) v(S2P) v(S2N) v(S3P) v(S3N)
+ v(x3.SX) v(x3.SY) v(x3.SZ) v(x3.net1) v(x3.net2) v(x3.net3)
+ v(X2) v(Y2) v(Z2)
+ v(SX4) v(SY4) v(SZ4) v(XY4) v(XZ4) v(YZ4)
+ v(X4) v(Y4) v(Z4)
* case 12: c = (+0.6, -0.3, -1.0)  ->  expected Z
alter Vcx = 0.6
alter Vcy = -0.3
alter Vcz = -1.0
dc Vamp 200u 0.02 200u
wrdata oct_12.txt v(cx) v(cy) v(cz) v(S1P) v(S1N) v(S2P) v(S2N) v(S3P) v(S3N)
+ v(x3.SX) v(x3.SY) v(x3.SZ) v(x3.net1) v(x3.net2) v(x3.net3)
+ v(X2) v(Y2) v(Z2)
+ v(SX4) v(SY4) v(SZ4) v(XY4) v(XZ4) v(YZ4)
+ v(X4) v(Y4) v(Z4)
* case 13: c = (-1.0, +0.6, +0.3)  ->  expected X
alter Vcx = -1.0
alter Vcy = 0.6
alter Vcz = 0.3
dc Vamp 200u 0.02 200u
wrdata oct_13.txt v(cx) v(cy) v(cz) v(S1P) v(S1N) v(S2P) v(S2N) v(S3P) v(S3N)
+ v(x3.SX) v(x3.SY) v(x3.SZ) v(x3.net1) v(x3.net2) v(x3.net3)
+ v(X2) v(Y2) v(Z2)
+ v(SX4) v(SY4) v(SZ4) v(XY4) v(XZ4) v(YZ4)
+ v(X4) v(Y4) v(Z4)
* case 14: c = (-0.3, +1.0, +0.6)  ->  expected X
alter Vcx = -0.3
alter Vcy = 1.0
alter Vcz = 0.6
dc Vamp 200u 0.02 200u
wrdata oct_14.txt v(cx) v(cy) v(cz) v(S1P) v(S1N) v(S2P) v(S2N) v(S3P) v(S3N)
+ v(x3.SX) v(x3.SY) v(x3.SZ) v(x3.net1) v(x3.net2) v(x3.net3)
+ v(X2) v(Y2) v(Z2)
+ v(SX4) v(SY4) v(SZ4) v(XY4) v(XZ4) v(YZ4)
+ v(X4) v(Y4) v(Z4)
* case 15: c = (-0.6, +0.3, +1.0)  ->  expected X
alter Vcx = -0.6
alter Vcy = 0.3
alter Vcz = 1.0
dc Vamp 200u 0.02 200u
wrdata oct_15.txt v(cx) v(cy) v(cz) v(S1P) v(S1N) v(S2P) v(S2N) v(S3P) v(S3N)
+ v(x3.SX) v(x3.SY) v(x3.SZ) v(x3.net1) v(x3.net2) v(x3.net3)
+ v(X2) v(Y2) v(Z2)
+ v(SX4) v(SY4) v(SZ4) v(XY4) v(XZ4) v(YZ4)
+ v(X4) v(Y4) v(Z4)
* case 16: c = (-1.0, +0.6, -0.3)  ->  expected X
alter Vcx = -1.0
alter Vcy = 0.6
alter Vcz = -0.3
dc Vamp 200u 0.02 200u
wrdata oct_16.txt v(cx) v(cy) v(cz) v(S1P) v(S1N) v(S2P) v(S2N) v(S3P) v(S3N)
+ v(x3.SX) v(x3.SY) v(x3.SZ) v(x3.net1) v(x3.net2) v(x3.net3)
+ v(X2) v(Y2) v(Z2)
+ v(SX4) v(SY4) v(SZ4) v(XY4) v(XZ4) v(YZ4)
+ v(X4) v(Y4) v(Z4)
* case 17: c = (-0.3, +1.0, -0.6)  ->  expected Z
alter Vcx = -0.3
alter Vcy = 1.0
alter Vcz = -0.6
dc Vamp 200u 0.02 200u
wrdata oct_17.txt v(cx) v(cy) v(cz) v(S1P) v(S1N) v(S2P) v(S2N) v(S3P) v(S3N)
+ v(x3.SX) v(x3.SY) v(x3.SZ) v(x3.net1) v(x3.net2) v(x3.net3)
+ v(X2) v(Y2) v(Z2)
+ v(SX4) v(SY4) v(SZ4) v(XY4) v(XZ4) v(YZ4)
+ v(X4) v(Y4) v(Z4)
* case 18: c = (-0.6, +0.3, -1.0)  ->  expected Z
alter Vcx = -0.6
alter Vcy = 0.3
alter Vcz = -1.0
dc Vamp 200u 0.02 200u
wrdata oct_18.txt v(cx) v(cy) v(cz) v(S1P) v(S1N) v(S2P) v(S2N) v(S3P) v(S3N)
+ v(x3.SX) v(x3.SY) v(x3.SZ) v(x3.net1) v(x3.net2) v(x3.net3)
+ v(X2) v(Y2) v(Z2)
+ v(SX4) v(SY4) v(SZ4) v(XY4) v(XZ4) v(YZ4)
+ v(X4) v(Y4) v(Z4)
* case 19: c = (-1.0, -0.6, +0.3)  ->  expected X
alter Vcx = -1.0
alter Vcy = -0.6
alter Vcz = 0.3
dc Vamp 200u 0.02 200u
wrdata oct_19.txt v(cx) v(cy) v(cz) v(S1P) v(S1N) v(S2P) v(S2N) v(S3P) v(S3N)
+ v(x3.SX) v(x3.SY) v(x3.SZ) v(x3.net1) v(x3.net2) v(x3.net3)
+ v(X2) v(Y2) v(Z2)
+ v(SX4) v(SY4) v(SZ4) v(XY4) v(XZ4) v(YZ4)
+ v(X4) v(Y4) v(Z4)
* case 20: c = (-0.3, -1.0, +0.6)  ->  expected Y
alter Vcx = -0.3
alter Vcy = -1.0
alter Vcz = 0.6
dc Vamp 200u 0.02 200u
wrdata oct_20.txt v(cx) v(cy) v(cz) v(S1P) v(S1N) v(S2P) v(S2N) v(S3P) v(S3N)
+ v(x3.SX) v(x3.SY) v(x3.SZ) v(x3.net1) v(x3.net2) v(x3.net3)
+ v(X2) v(Y2) v(Z2)
+ v(SX4) v(SY4) v(SZ4) v(XY4) v(XZ4) v(YZ4)
+ v(X4) v(Y4) v(Z4)
* case 21: c = (-0.6, -0.3, +1.0)  ->  expected X
alter Vcx = -0.6
alter Vcy = -0.3
alter Vcz = 1.0
dc Vamp 200u 0.02 200u
wrdata oct_21.txt v(cx) v(cy) v(cz) v(S1P) v(S1N) v(S2P) v(S2N) v(S3P) v(S3N)
+ v(x3.SX) v(x3.SY) v(x3.SZ) v(x3.net1) v(x3.net2) v(x3.net3)
+ v(X2) v(Y2) v(Z2)
+ v(SX4) v(SY4) v(SZ4) v(XY4) v(XZ4) v(YZ4)
+ v(X4) v(Y4) v(Z4)
* case 22: c = (-1.0, -0.6, -0.3)  ->  expected X
alter Vcx = -1.0
alter Vcy = -0.6
alter Vcz = -0.3
dc Vamp 200u 0.02 200u
wrdata oct_22.txt v(cx) v(cy) v(cz) v(S1P) v(S1N) v(S2P) v(S2N) v(S3P) v(S3N)
+ v(x3.SX) v(x3.SY) v(x3.SZ) v(x3.net1) v(x3.net2) v(x3.net3)
+ v(X2) v(Y2) v(Z2)
+ v(SX4) v(SY4) v(SZ4) v(XY4) v(XZ4) v(YZ4)
+ v(X4) v(Y4) v(Z4)
* case 23: c = (-0.3, -1.0, -0.6)  ->  expected Y
alter Vcx = -0.3
alter Vcy = -1.0
alter Vcz = -0.6
dc Vamp 200u 0.02 200u
wrdata oct_23.txt v(cx) v(cy) v(cz) v(S1P) v(S1N) v(S2P) v(S2N) v(S3P) v(S3N)
+ v(x3.SX) v(x3.SY) v(x3.SZ) v(x3.net1) v(x3.net2) v(x3.net3)
+ v(X2) v(Y2) v(Z2)
+ v(SX4) v(SY4) v(SZ4) v(XY4) v(XZ4) v(YZ4)
+ v(X4) v(Y4) v(Z4)
* case 24: c = (-0.6, -0.3, -1.0)  ->  expected Z
alter Vcx = -0.6
alter Vcy = -0.3
alter Vcz = -1.0
dc Vamp 200u 0.02 200u
wrdata oct_24.txt v(cx) v(cy) v(cz) v(S1P) v(S1N) v(S2P) v(S2N) v(S3P) v(S3N)
+ v(x3.SX) v(x3.SY) v(x3.SZ) v(x3.net1) v(x3.net2) v(x3.net3)
+ v(X2) v(Y2) v(Z2)
+ v(SX4) v(SY4) v(SZ4) v(XY4) v(XZ4) v(YZ4)
+ v(X4) v(Y4) v(Z4)
alter Vsel = 0
.endc
"}
C {a_zonetic2026/XSCHEM/COMBINATION/GRADIENT.sym} -60 -220 0 0 {name=x2}
C {a_zonetic2026/XSCHEM/COMBINATION/GRADIENT2.sym} 330 -230 0 0 {name=x3}
C {res.sym} -250 -490 0 0 {name=R1
value=1meg*(1-v(by))
format="@name @pinlist r=' @value '"
footprint=1206
device=resistor
m=1}
C {res.sym} -190 -490 0 0 {name=R2
value=1meg*(1+v(by))
format="@name @pinlist r=' @value '"
footprint=1206
device=resistor
m=1}
C {res.sym} -250 -410 0 0 {name=R3
value=1meg*(1+v(by))
format="@name @pinlist r=' @value '"
footprint=1206
device=resistor
m=1}
C {res.sym} -190 -410 0 0 {name=R4
value=1meg*(1-v(by))
format="@name @pinlist r=' @value '"
footprint=1206
device=resistor
m=1}
C {devices/lab_wire.sym} -220 -520 1 0 {name=pV1 sig_type=std_logic lab=VEXC}
C {devices/gnd.sym} -220 -380 0 0 {name=lVcm1 lab=GND
value=5}
C {devices/lab_wire.sym} -110 -300 0 0 {name=pV2 sig_type=std_logic lab=VDD1}
C {devices/lab_wire.sym} 280 -310 0 0 {name=pV3 sig_type=std_logic lab=VDD2}
C {devices/gnd.sym} -110 -140 0 0 {name=lVcm2 lab=GND
value=5}
C {devices/gnd.sym} 280 -150 0 0 {name=lVcm3 lab=GND
value=5}
C {devices/vsource.sym} 340 -520 0 0 {name=V3 value=5
}
C {devices/lab_wire.sym} 340 -550 0 0 {name=pV4 sig_type=std_logic lab=VDD3}
C {devices/gnd.sym} 340 -490 0 0 {name=lV3 lab=GND
value=5}
C {devices/vsource.sym} 420 -520 0 0 {name=V4 value=5
}
C {devices/lab_wire.sym} 420 -550 0 0 {name=pV5 sig_type=std_logic lab=VDD4}
C {devices/gnd.sym} 420 -490 0 0 {name=lV4 lab=GND
value=5}
C {devices/lab_wire.sym} -250 -450 0 0 {name=pV6 sig_type=std_logic lab=S2P}
C {devices/lab_wire.sym} -190 -450 2 0 {name=pV7 sig_type=std_logic lab=S2N}
C {res.sym} -120 -490 0 0 {name=R5
value=1meg*(1-v(bz))
format="@name @pinlist r=' @value '"
footprint=1206
device=resistor
m=1}
C {res.sym} -60 -490 0 0 {name=R6
value=1meg*(1+v(bz))
format="@name @pinlist r=' @value '"
footprint=1206
device=resistor
m=1}
C {res.sym} -120 -410 0 0 {name=R7
value=1meg*(1+v(bz))
format="@name @pinlist r=' @value '"
footprint=1206
device=resistor
m=1}
C {res.sym} -60 -410 0 0 {name=R8
value=1meg*(1-v(bz))
format="@name @pinlist r=' @value '"
footprint=1206
device=resistor
m=1}
C {devices/lab_wire.sym} -90 -520 1 0 {name=pV8 sig_type=std_logic lab=VEXC}
C {devices/gnd.sym} -90 -380 0 0 {name=lVcm4 lab=GND
value=5}
C {devices/lab_wire.sym} -120 -450 0 0 {name=pV9 sig_type=std_logic lab=S3P}
C {devices/lab_wire.sym} -60 -450 2 0 {name=pV10 sig_type=std_logic lab=S3N}
C {res.sym} -400 -490 0 0 {name=R9
value=1meg*(1-v(bx))
format="@name @pinlist r=' @value '"
footprint=1206
device=resistor
m=1}
C {res.sym} -340 -490 0 0 {name=R10
value=1meg*(1+v(bx))
format="@name @pinlist r=' @value '"
footprint=1206
device=resistor
m=1}
C {res.sym} -400 -410 0 0 {name=R11
value=1meg*(1+v(bx))
format="@name @pinlist r=' @value '"
footprint=1206
device=resistor
m=1}
C {res.sym} -340 -410 0 0 {name=R12
value=1meg*(1-v(bx))
format="@name @pinlist r=' @value '"
footprint=1206
device=resistor
m=1}
C {devices/lab_wire.sym} -370 -520 1 0 {name=pV11 sig_type=std_logic lab=VEXC}
C {devices/gnd.sym} -370 -380 0 0 {name=lVcm5 lab=GND
value=5}
C {devices/lab_wire.sym} -400 -450 0 0 {name=pV12 sig_type=std_logic lab=S1P}
C {devices/lab_wire.sym} -340 -450 2 0 {name=pV13 sig_type=std_logic lab=S1N}
C {devices/lab_wire.sym} -210 -250 0 0 {name=pV14 sig_type=std_logic lab=S1P}
C {devices/lab_wire.sym} -210 -270 0 0 {name=pV15 sig_type=std_logic lab=S1N}
C {devices/lab_wire.sym} -210 -210 0 0 {name=pV16 sig_type=std_logic lab=S2P}
C {devices/lab_wire.sym} -210 -170 0 0 {name=pV17 sig_type=std_logic lab=S3P}
C {devices/lab_wire.sym} -210 -190 0 0 {name=pV18 sig_type=std_logic lab=S3N}
C {devices/lab_wire.sym} -210 -230 0 0 {name=pV19 sig_type=std_logic lab=S2N}
C {devices/lab_wire.sym} 180 -260 0 0 {name=pV20 sig_type=std_logic lab=S1P}
C {devices/lab_wire.sym} 180 -280 0 0 {name=pV21 sig_type=std_logic lab=S1N}
C {devices/lab_wire.sym} 180 -220 0 0 {name=pV22 sig_type=std_logic lab=S2P}
C {devices/lab_wire.sym} 180 -180 0 0 {name=pV23 sig_type=std_logic lab=S3P}
C {devices/lab_wire.sym} 180 -200 0 0 {name=pV24 sig_type=std_logic lab=S3N}
C {devices/lab_wire.sym} 180 -240 0 0 {name=pV25 sig_type=std_logic lab=S2N}
C {devices/lab_wire.sym} 0 -240 2 0 {name=pV26 sig_type=std_logic lab=X1}
C {devices/lab_wire.sym} 0 -200 2 0 {name=pV27 sig_type=std_logic lab=Z1}
C {devices/lab_wire.sym} 0 -220 2 0 {name=pV28 sig_type=std_logic lab=Y1}
C {devices/lab_wire.sym} 390 -250 2 0 {name=pV29 sig_type=std_logic lab=X2}
C {devices/lab_wire.sym} 390 -210 2 0 {name=pV30 sig_type=std_logic lab=Z2}
C {devices/lab_wire.sym} 390 -230 2 0 {name=pV31 sig_type=std_logic lab=Y2}
