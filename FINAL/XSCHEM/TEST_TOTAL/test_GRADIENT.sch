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
C {devices/code_shown.sym} 570 -600 0 0 {name=MODELS1 only_toplevel=true
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
C {devices/code_shown.sym} -340 -1040 0 0 {name=ESTIMULO only_toplevel=true
value="
* EL CAMPO. Tres componentes desfasadas 120 grados entre si, que es lo que hace
* que sumen cero: el vector solo cambia de DIRECCION, no de modulo. Barriendo
* Vang de 0 a 360 se recorre el circulo entero, y si la cadena esta bien cada
* eje deberia ganar exactamente 120 grados: X de -60 a 60, Y de 60 a 180 y Z de
* 180 a 300. Lo que se desvien esas tres fronteras es la cifra del banco.
*
* v(amp) ES dR/R, sin factores de conversion por medio: cada rama del puente
* vale 1meg*(1 +- v(bx)), asi que el amplificador ve VEXC*v(bx) de senal
* diferencial y el modo comun se queda clavado en VEXC/2 pase lo que pase con
* la senal. Eso segundo no es un adorno: si el modo comun se moviera con la
* senal se mezclaria con la sensibilidad al modo comun de estas celdas y no
* habria forma de separar las dos cosas al leer la curva.
*
* Va con fuentes B y resistencias de comportamiento, y no barriendo
* resistencias, porque dc admite dos fuentes anidadas como mucho y aqui hay
* DOCE resistencias que se tienen que mover a la vez y de forma coherente.
Vamp amp 0 0.02
Vang ang 0 0
Bbx bx 0 v='v(amp)*cos( v(ang)       *3.14159265358979/180)'
Bby by 0 v='v(amp)*cos((v(ang)-120.0)*3.14159265358979/180)'
Bbz bz 0 v='v(amp)*cos((v(ang)+120.0)*3.14159265358979/180)'
"}
C {devices/code_shown.sym} 900 -1010 0 0 {name=RECONSTRUCCION only_toplevel=true
value="
* LAS MISMAS DOS CADENAS, REHECHAS CON LOS BLOQUES EXTRAIDOS DEL LAYOUT v2.
* Cuelgan de los MISMOS seis nodos de sensor que las esquematicas y cada una
* lleva su propia alimentacion, para poder comparar tambien el consumo.
*
* La topologia es la de COMBINATION/GRADIENT.sch, copiada nodo a nodo:
*
*     amp X: S1N->INN  S1P->INP  -> SX        COMP XY: INN=SX INP=SY -> XY
*     amp Y: S2N->INN  S2P->INP  -> SY        COMP XZ: INN=SX INP=SZ -> XZ
*     amp Z: S3N->INN  S3P->INP  -> SZ        COMP YZ: INN=SY INP=SZ -> YZ
*                                             DECODER: XY XZ YZ -> X Y Z
*
* OJO CON EL ORDEN DE PUERTOS. xschem los emite en el orden de las lineas B del
* simbolo y magic en el orden en que los encuentra en el layout, y NO coinciden:
* el esquematico declara OPAM VDD INN OUT INP VSS y el extraido OPAM VSS VDD OUT
* INP INN. Cablear las dos igual significa cosas distintas y no da ningun error.
* Por eso encima de cada grupo va el orden de verdad, y por eso los ficheros son
* los _V2_ que produce TEST/preparar_extraidos.sh: renombra el subcircuito -- los
* dos declaran el mismo nombre y no se pueden incluir juntos -- y normaliza el
* orden. Fijate en que el OPAM_LIN_flat lleva OUT en medio y los otros no.
.include ../../../../layouts_v2/OPAM/mag/OPAM_V2_pex_rc.spice
.include ../../../../layouts_v2/OPAM_LIN_flat/mag/OPAM_LIN_flat_V2_pex_rc.spice
.include ../../../../layouts_v2/COMP/mag/COMP_V2_pex_rc.spice
.include ../../../../layouts_v2/DECODER/mag/DECODER_V2_pex_rc.spice

* --- G3: la cadena de G1, con el OPAM del layout v2
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

* --- G4: la cadena de G2, con el OPAM_LIN_flat del layout v2
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
C {devices/code_shown.sym} 520 -1010 0 0 {name=s1
only_toplevel=false
value="
* OJO: ni una llave en este texto. xschem las cuenta para saber donde acaba el
* bloque de atributos y una sola dentro de un comentario lo corta por la mitad,
* dejando el netlist con el 'blabla' de la plantilla y sin dar ningun error.
*
* Este banco NO necesita fuente de modo comun, al contrario que test_comp_* y
* test_opam_*: alli el par de entrada eran dos puertas sin camino de continua a
* masa, y aqui el propio puente se lo da.
*
* Las senales intermedias de las cadenas esquematicas se sacan por nombre
* jerarquico, v(x2.SX) y compania. En las rehechas a mano los nodos son de
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
