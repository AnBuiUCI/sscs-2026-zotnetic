v {xschem version=3.4.8RC file_version=1.3}
G {}
K {}
V {}
S {}
F {}
E {}
N 230 -100 230 -80 {
lab=GND}
N 230 -220 230 -160 {
lab=VDD}
N 70 -100 70 -80 {
lab=GND}
N 70 -220 70 -160 {
lab=VA}
N 190 40 220 40 {lab=OUT}
N 60 50 80 50 {lab=WE}
N -150 30 -120 30 {lab=VA}
N -150 50 -120 50 {lab=VB}
N -150 70 -120 70 {lab=VC}
N -150 90 -120 90 {lab=VD}
N 190 60 220 60 {lab=OUT_N}
N 70 50 70 80 {lab=WE}
N -30 -100 -30 -80 {
lab=GND}
N -30 -220 -30 -160 {
lab=VB}
N -90 -100 -90 -80 {
lab=GND}
N -90 -220 -90 -160 {
lab=VC}
N -160 -100 -160 -80 {
lab=GND}
N -160 -220 -160 -160 {
lab=VD}
N 290 -100 290 -80 {
lab=GND}
N 290 -220 290 -160 {
lab=VDD1}
N 370 -100 370 -80 {
lab=GND}
N 370 -220 370 -160 {
lab=VDD2}
C {devices/vsource.sym} 230 -130 0 0 {name=V1 value=5
}
C {devices/gnd.sym} 230 -80 0 0 {name=l1 lab=GND
value=5}
C {devices/lab_wire.sym} 230 -200 0 0 {name=p7 sig_type=std_logic lab=VDD}
C {devices/code_shown.sym} 475 -45 0 0 {name=s1
only_toplevel=false
value="
* OJO: nada de llaves en este texto. xschem las cuenta para saber donde acaba
* el bloque de atributos y una sola lo corta por la mitad.
*
* CORRIENTES DE RAMA EN EL LAYOUT.
* En el esquematico se miden con las cuatro fuentes de 0 V Vmeas..Vmeas3 que
* hay dentro de WEIGHT, en serie con la cola de cada rama. El netlist extraido
* no tiene esas fuentes, pero ngspice sabe dar la corriente de drenador de un
* transistor si se le pide con .save ANTES de correr -- las variables internas
* de dispositivo no se pueden pedir despues. El .m0 del final hace falta porque
* el modelo del PDK es un subcircuito y el MOS de dentro se llama m0.
*
* Que transistor es cada rama se traza por los nodos: las cuatro colas del
* extraido son las de w=1.24u, y cada una cuelga del nodo intermedio al que
* llegan los dos transistores de entrada de esa rama.
*
*   rama   esquematico   nodo intermedio   cola en el layout
*   VA     Vmeas         a_5026_1208       X31
*   VB     Vmeas1        a_1038_1208       X16
*   VC     Vmeas2        a_n74_0           X23
*   VD     Vmeas3        a_n74_1208        X24
.tran 1m 1
.save all
.save @m.xextrc.x31.m0[id] @m.xextrc.x16.m0[id]
+ @m.xextrc.x23.m0[id] @m.xextrc.x24.m0[id]
.control
run
wrdata input.txt   v(VA) v(VB) V(VC) V(VD)
wrdata middle.txt  v(WE) v(WE1) v(WE2)
wrdata power.txt   v(VDD)*i(V1) v(VDD1)*i(V6) v(VDD2)*i(V9)
wrdata out.txt     v(OUT) v(OUT1) v(OUT2) v(OUT_N) v(OUT_N1) v(OUT_N2)
* Las ocho corrientes de rama: primero las cuatro del esquematico y luego las
* cuatro del layout, en el mismo orden VA VB VC VD.
wrdata current.txt i(v.x1.Vmeas) i(v.x1.Vmeas1) i(v.x1.Vmeas2) i(v.x1.Vmeas3)
+ @m.xextrc.x31.m0[id] @m.xextrc.x16.m0[id]
+ @m.xextrc.x23.m0[id] @m.xextrc.x24.m0[id]
.endc
"}
C {devices/code_shown.sym} 335 -225 0 0 {name=MODELS1 only_toplevel=true
format="tcleval( @value )"
value="
.include $::180MCU_MODELS/design.ngspice
.lib $::180MCU_MODELS/sm141064.ngspice typical
.lib $::180MCU_MODELS/sm141064.ngspice cap_mim
.lib $::180MCU_MODELS/sm141064.ngspice res_typical
.lib $::180MCU_MODELS/sm141064.ngspice moscap_typical
.lib $::180MCU_MODELS/sm141064.ngspice mimcap_typical
* .lib $::180MCU_MODELS/sm141064.ngspice res_statistical
"}
C {devices/vsource.sym} 70 -130 0 0 {name=V5 value="pulse(0 5 0 5m 
+ 5m 0.5 1)"
}
C {devices/gnd.sym} 70 -80 0 0 {name=l3 lab=GND
value=5}
C {devices/lab_wire.sym} 70 -200 0 0 {name=p13 sig_type=std_logic lab=VA}
C {devices/lab_wire.sym} -30 0 0 0 {name=p8 sig_type=std_logic lab=VDD}
C {devices/lab_wire.sym} 220 40 2 0 {name=p9 sig_type=std_logic lab=OUT}
C {a_zonetic2026/XSCHEM/WEIGTH/WEIGHT.sym} 30 70 0 0 {name=x1}
C {a_zonetic2026/XSCHEM/WEIGTH/COMP_OUT.sym} 230 70 0 0 {name=x2}
C {devices/lab_wire.sym} 120 0 0 0 {name=p4 sig_type=std_logic lab=VDD}
C {devices/gnd.sym} -30 120 0 0 {name=l6 lab=GND
value=5}
C {devices/gnd.sym} 120 100 0 0 {name=l7 lab=GND
value=5}
C {devices/lab_wire.sym} 220 60 2 0 {name=p17 sig_type=std_logic lab=OUT_N}
C {devices/lab_wire.sym} 70 80 2 0 {name=p1 sig_type=std_logic lab=WE}
C {devices/lab_wire.sym} -150 50 0 0 {name=p3 sig_type=std_logic lab=VB}
C {devices/lab_wire.sym} -150 30 0 0 {name=p6 sig_type=std_logic lab=VA}
C {devices/lab_wire.sym} -150 70 0 0 {name=p2 sig_type=std_logic lab=VC}
C {devices/lab_wire.sym} -150 90 0 0 {name=p10 sig_type=std_logic lab=VD}
C {devices/code_shown.sym} -180 230 0 0 {name=DUT1 only_toplevel=true
format="tcleval( @value )"
value="
.include "../../../../Layouts/WEIGHT_COMP/mag/WEIGHT_COMP_pex_rc.spice"
Xextrc GND VDD1 VD WE1 VA VB OUT1 OUT_N1 VC WEIGHT_COMP
.include "../../../../layouts_v2/WEIGHT_COMP/mag/WEIGHT_COMP_V2_pex_rc.spice"
Xextrc2 GND VDD2 VD WE2 VA VB OUT2 OUT_N2 VC WEIGHT_COMP_V2
*WEIGHT_COMP VSS VDD VD WE VA VB OUT OUT_N VC
"}
C {devices/gnd.sym} -30 -80 0 0 {name=l2 lab=GND
value=5}
C {devices/lab_wire.sym} -30 -200 0 0 {name=p5 sig_type=std_logic lab=VB}
C {devices/gnd.sym} -90 -80 0 0 {name=l4 lab=GND
value=5}
C {devices/lab_wire.sym} -90 -200 0 0 {name=p11 sig_type=std_logic lab=VC}
C {devices/gnd.sym} -160 -80 0 0 {name=l5 lab=GND
value=5}
C {devices/lab_wire.sym} -160 -200 0 0 {name=p12 sig_type=std_logic lab=VD}
C {devices/vsource.sym} 290 -130 0 0 {name=V6 value=5
}
C {devices/gnd.sym} 290 -80 0 0 {name=l8 lab=GND
value=5}
C {devices/lab_wire.sym} 290 -200 0 0 {name=p14 sig_type=std_logic lab=VDD1}
C {devices/vsource.sym} 370 -130 0 0 {name=V9 value=5
}
C {devices/gnd.sym} 370 -80 0 0 {name=l9 lab=GND
value=5}
C {devices/lab_wire.sym} 370 -200 0 0 {name=p14b sig_type=std_logic lab=VDD2}
C {devices/vsource.sym} -30 -130 0 0 {name=V2 value="pulse(0 5 0 5m 
+ 5m 0.25 0.5)"
}
C {devices/vsource.sym} -90 -130 0 0 {name=V3 value="pulse(0 5 0 5m 
+ 5m 0.125 0.25)"
}
C {devices/vsource.sym} -160 -130 0 0 {name=V4 value="pulse(0 5 0 5m 
+ 5m 0.0625 0.125)"
}
