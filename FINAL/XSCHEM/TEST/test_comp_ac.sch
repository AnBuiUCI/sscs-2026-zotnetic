v {xschem version=3.4.8RC file_version=1.3}
G {}
K {}
V {}
S {}
F {}
E {}
C {devices/code_shown.sym} 700 -420 0 0 {name=MODELS1 only_toplevel=true
format="tcleval( @value )"
value="
.include $::180MCU_MODELS/design.ngspice
.lib $::180MCU_MODELS/sm141064.ngspice typical
.lib $::180MCU_MODELS/sm141064.ngspice cap_mim
.lib $::180MCU_MODELS/sm141064.ngspice res_typical
.lib $::180MCU_MODELS/sm141064.ngspice moscap_typical
.lib $::180MCU_MODELS/sm141064.ngspice mimcap_typical
"}
C {devices/vsource.sym} -400 -140 0 0 {name=V1 value=5
}
C {devices/lab_wire.sym} -400 -170 0 0 {name=pV1a sig_type=std_logic lab=VDD}
C {devices/gnd.sym} -400 -110 0 0 {name=lV1 lab=GND
value=5}
C {devices/vsource.sym} -320 -140 0 0 {name=V2 value=5
}
C {devices/lab_wire.sym} -320 -170 0 0 {name=pV2a sig_type=std_logic lab=VDD1}
C {devices/gnd.sym} -320 -110 0 0 {name=lV2 lab=GND
value=5}
C {devices/vsource.sym} -600 -140 0 0 {name=Vin value="dc 0 ac 1"
}
C {devices/lab_wire.sym} -600 -170 0 0 {name=pVina sig_type=std_logic lab=vin}
C {devices/gnd.sym} -600 -110 0 0 {name=lVin lab=GND
value=5}
C {devices/vsource.sym} -500 -140 0 0 {name=Vcm value=2.5
}
C {devices/lab_wire.sym} -500 -170 0 0 {name=pVcma sig_type=std_logic lab=vcm}
C {devices/gnd.sym} -500 -110 0 0 {name=lVcm lab=GND
value=5}
N 200 -70 200 -60 {lab=VDD}
N 130 -20 140 -20 {lab=fb}
N 130 20 140 20 {lab=vcm}
N 300 0 310 0 {lab=OUT}
N 200 60 200 70 {lab=GND}
C {a_zonetic2026/XSCHEM/OPAM/COMP_sc.sym} 200 0 0 0 {name=x1}
C {devices/lab_wire.sym} 200 -70 0 0 {name=pcv sig_type=std_logic lab=VDD}
C {devices/lab_wire.sym} 130 -20 0 0 {name=pcn sig_type=std_logic lab=fb}
C {devices/lab_wire.sym} 130 20 0 0 {name=pcp sig_type=std_logic lab=vcm}
C {devices/lab_wire.sym} 310 0 2 0 {name=pco sig_type=std_logic lab=OUT}
C {devices/gnd.sym} 200 70 0 0 {name=lcg lab=GND
value=5}
N 400 -40 400 -30 {lab=OUT}
N 400 30 400 40 {lab=fb}
N 480 -40 480 -30 {lab=vin}
N 480 30 480 40 {lab=fb}
C {devices/ind.sym} 400 0 0 0 {name=L1 value=1G}
C {devices/capa.sym} 480 0 0 0 {name=C1 value=1G}
C {devices/lab_wire.sym} 400 -40 0 0 {name=pl1a sig_type=std_logic lab=OUT}
C {devices/lab_wire.sym} 400 40 0 0 {name=pl1b sig_type=std_logic lab=fb}
C {devices/lab_wire.sym} 480 -40 0 0 {name=pc1a sig_type=std_logic lab=vin}
C {devices/lab_wire.sym} 480 40 0 0 {name=pc1b sig_type=std_logic lab=fb}
N 400 160 400 170 {lab=OUT1}
N 400 230 400 240 {lab=fb1}
N 480 160 480 170 {lab=vin}
N 480 230 480 240 {lab=fb1}
C {devices/ind.sym} 400 200 0 0 {name=L2 value=1G}
C {devices/capa.sym} 480 200 0 0 {name=C2 value=1G}
C {devices/lab_wire.sym} 400 160 0 0 {name=pl2a sig_type=std_logic lab=OUT1}
C {devices/lab_wire.sym} 400 240 0 0 {name=pl2b sig_type=std_logic lab=fb1}
C {devices/lab_wire.sym} 480 160 0 0 {name=pc2a sig_type=std_logic lab=vin}
C {devices/lab_wire.sym} 480 240 0 0 {name=pc2b sig_type=std_logic lab=fb1}
N 400 320 400 330 {lab=OUT2}
N 400 390 400 400 {lab=fb2}
N 480 320 480 330 {lab=vin}
N 480 390 480 400 {lab=fb2}
C {devices/ind.sym} 400 360 0 0 {name=L3 value=1G}
C {devices/capa.sym} 480 360 0 0 {name=C3 value=1G}
C {devices/lab_wire.sym} 400 320 0 0 {name=pl3a sig_type=std_logic lab=OUT2}
C {devices/lab_wire.sym} 400 400 0 0 {name=pl3b sig_type=std_logic lab=fb2}
C {devices/lab_wire.sym} 480 320 0 0 {name=pc3a sig_type=std_logic lab=vin}
C {devices/lab_wire.sym} 480 400 0 0 {name=pc3b sig_type=std_logic lab=fb2}
C {devices/vsource.sym} -240 -140 0 0 {name=V6 value=5
}
C {devices/lab_wire.sym} -240 -170 0 0 {name=pV6a sig_type=std_logic lab=VDD2}
C {devices/gnd.sym} -240 -110 0 0 {name=lV6 lab=GND
value=5}
C {devices/code_shown.sym} 700 -420 0 0 {name=DUT1 only_toplevel=true
format="tcleval( @value )"
value="
.include "../../../../Layouts/COMP/mag/COMP_pex_rc.spice"
Xextrc GND VDD1 OUT1 vcm fb1 COMP
*COMP VSS VDD OUT INP INN
"}
C {devices/code_shown.sym} 700 -320 0 0 {name=DUT2 only_toplevel=true
format="tcleval( @value )"
value="
* La v2 del layout, con su propio lazo de autopolarizacion (L3/C3, nodo fb2) y
* su propia alimentacion, para poder medirla igual que a la v1.
.include "../../../../layouts_v2/COMP/mag/COMP_V2_pex_rc.spice"
Xextrc2 GND VDD2 OUT2 vcm fb2 COMP_V2
"}
C {devices/code_shown.sym} 700 -100 0 0 {name=s1
only_toplevel=false
value="
* OJO: ni una llave en este texto. xschem las cuenta para saber donde acaba el
* bloque de atributos y una sola dentro de un comentario lo corta por la mitad,
* dejando el netlist con el 'blabla' de la plantilla y sin dar ningun error.
*
* No se puede atar la entrada en continua y lanzar un .ac: el punto de
* operacion cae saturado y linealizar ahi no significa nada. Cada rama lleva su
* lazo de L de 1 GH y C de 1 GF: en continua la L es un corto y el lazo unitario
* coloca al comparador en su propio offset; en alterna la L abre y la C
* cortocircuita, y lo que se mide es la ganancia en lazo abierto.
.save all
.control
ac dec 100 0.001 10G
wrdata ac.txt v(OUT) v(OUT1) v(OUT2)
.endc
"}
