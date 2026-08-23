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
C {devices/vsource.sym} -600 -140 0 0 {name=Vin value="dc 0 ac 0"
}
C {devices/lab_wire.sym} -600 -170 0 0 {name=pVina sig_type=std_logic lab=vin}
C {devices/gnd.sym} -600 -110 0 0 {name=lVin lab=GND
value=5}
C {devices/vsource.sym} -480 -140 0 0 {name=Vcm value="dc 2.0 ac 0"
}
C {devices/lab_wire.sym} -480 -170 0 0 {name=pVcma sig_type=std_logic lab=vcm}
C {devices/gnd.sym} -480 -110 0 0 {name=lVcm lab=GND
value=5}
C {devices/vsource.sym} -360 -140 0 0 {name=V1 value="dc 5 ac 0"
}
C {devices/lab_wire.sym} -360 -170 0 0 {name=pV1a sig_type=std_logic lab=VDD}
C {devices/gnd.sym} -360 -110 0 0 {name=lV1 lab=GND
value=5}
N 150 -70 150 -60 {lab=VDD}
N 80 -20 90 -20 {lab=fb}
N 80 20 90 20 {lab=vcm}
N 250 0 260 0 {lab=OUT}
N 150 60 150 70 {lab=GND}
C {a_zonetic2026/XSCHEM/OPAM/OPAM_LIN.sym} 190 0 0 0 {name=x1}
C {devices/lab_wire.sym} 150 -70 0 0 {name=pv sig_type=std_logic lab=VDD}
C {devices/lab_wire.sym} 80 -20 0 0 {name=pn sig_type=std_logic lab=fb}
C {devices/lab_wire.sym} 80 20 0 0 {name=pp sig_type=std_logic lab=vcm}
C {devices/lab_wire.sym} 260 0 2 0 {name=po sig_type=std_logic lab=OUT}
C {devices/gnd.sym} 150 70 0 0 {name=lg lab=GND
value=5}
N 350 -40 350 -30 {lab=OUT}
N 350 30 350 40 {lab=fb}
N 430 -40 430 -30 {lab=vin}
N 430 30 430 40 {lab=fb}
N 530 -40 530 -30 {lab=OUT}
N 530 30 530 40 {lab=GND}
C {devices/ind.sym} 350 0 0 0 {name=L1 value=1G}
C {devices/capa.sym} 430 0 0 0 {name=C1 value=1G}
C {devices/capa.sym} 530 0 0 0 {name=CL value=1p}
C {devices/lab_wire.sym} 350 -40 0 0 {name=pla sig_type=std_logic lab=OUT}
C {devices/lab_wire.sym} 350 40 0 0 {name=plb sig_type=std_logic lab=fb}
C {devices/lab_wire.sym} 430 -40 0 0 {name=pca sig_type=std_logic lab=vin}
C {devices/lab_wire.sym} 430 40 0 0 {name=pcb sig_type=std_logic lab=fb}
C {devices/lab_wire.sym} 530 -40 0 0 {name=pcla sig_type=std_logic lab=OUT}
C {devices/gnd.sym} 530 40 0 0 {name=lcl lab=GND
value=5}
C {devices/code_shown.sym} 700 -100 0 0 {name=s1
only_toplevel=false
value="
* OJO: ni una llave en este texto, xschem las cuenta.
*
* Cuatro medidas del mismo banco y del mismo punto de operacion. Las tres
* fuentes arrancan con ac=0 y se van activando de una en una, que es mas fiable
* que montar tres esquematicos y esperar que polaricen igual.
*
* CL es la carga capacitiva: en el chip estos amplificadores no atacan el vacio.
.save all
.control
* 1. ruido referido a la entrada. Va PRIMERO a proposito: ngspice numera los
* plots por orden de analisis, asi que si antes corre un .ac el espectro de
* ruido deja de llamarse noise1 y el setplot falla sin decir nada util.
alter @Vin[acmag]=1
noise v(OUT) Vin dec 20 1 1G
print inoise_total onoise_total
setplot noise1
wrdata noise.txt inoise_spectrum onoise_spectrum
setplot new
* 2. ganancia en lazo abierto, con carga
ac dec 100 1 1G
wrdata gain.txt v(OUT)
alter @Vin[acmag]=0
* 3. rechazo de alimentacion: se agita VDD y se mira cuanto llega a la salida
alter @V1[acmag]=1
ac dec 100 1 1G
wrdata psrr.txt v(OUT)
alter @V1[acmag]=0
* 4. rechazo de modo comun. Ojo: hay que agitar LAS DOS entradas a la vez. Si
* solo se mueve Vcm, la otra entrada se queda atada a masa por el condensador
* del lazo y lo que se mide es la ganancia diferencial otra vez -- me paso.
alter @Vcm[acmag]=1
alter @Vin[acmag]=1
ac dec 100 1 1G
wrdata cmrr.txt v(OUT)
.endc
"}
