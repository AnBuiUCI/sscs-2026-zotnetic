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
C {devices/vsource.sym} -160 -140 0 0 {name=V4 value=5
}
C {devices/lab_wire.sym} -160 -170 0 0 {name=p4L sig_type=std_logic lab=VDDL}
C {devices/gnd.sym} -160 -110 0 0 {name=l4L lab=GND
value=5}
C {devices/vsource.sym} -80 -140 0 0 {name=V6 value=5
}
C {devices/lab_wire.sym} -80 -170 0 0 {name=p6L sig_type=std_logic lab=VDDL1}
C {devices/gnd.sym} -80 -110 0 0 {name=l6L lab=GND
value=5}
C {devices/vsource.sym} 0 -140 0 0 {name=V7 value=5
}
C {devices/lab_wire.sym} 0 -170 0 0 {name=p7L sig_type=std_logic lab=VDDL2}
C {devices/gnd.sym} 0 -110 0 0 {name=l7L lab=GND
value=5}
C {devices/vsource.sym} -400 -140 0 0 {name=V1 value=5
}
C {devices/lab_wire.sym} -400 -170 0 0 {name=pV1a sig_type=std_logic lab=VDDR}
C {devices/gnd.sym} -400 -110 0 0 {name=lV1 lab=GND
value=5}
C {devices/vsource.sym} -320 -140 0 0 {name=V2 value=5
}
C {devices/lab_wire.sym} -320 -170 0 0 {name=pV2a sig_type=std_logic lab=VDDA}
C {devices/gnd.sym} -320 -110 0 0 {name=lV2 lab=GND
value=5}
C {devices/vsource.sym} -240 -140 0 0 {name=V3 value=5
}
C {devices/lab_wire.sym} -240 -170 0 0 {name=pV3a sig_type=std_logic lab=VDDB}
C {devices/gnd.sym} -240 -110 0 0 {name=lV3 lab=GND
value=5}
C {devices/vsource.sym} -600 -140 0 0 {name=Vin value="AC 1"
}
C {devices/lab_wire.sym} -600 -170 0 0 {name=pVina sig_type=std_logic lab=vin}
C {devices/gnd.sym} -600 -110 0 0 {name=lVin lab=GND
value=5}
C {devices/vsource.sym} -500 -140 0 0 {name=Vcm value=2.0
}
C {devices/lab_wire.sym} -500 -170 0 0 {name=pVcma sig_type=std_logic lab=vcm}
C {devices/gnd.sym} -500 -110 0 0 {name=lVcm lab=GND
value=5}
N 150 -70 150 -60 {lab=VDDR}
N 80 -20 90 -20 {lab=fbR}
N 80 20 90 20 {lab=vcm}
N 250 0 260 0 {lab=OUTR}
N 150 60 150 70 {lab=GND}
C {a_zonetic2026/XSCHEM/OPAM/OPAMt.sym} 190 0 0 0 {name=xR}
C {devices/lab_wire.sym} 150 -70 0 0 {name=pvR sig_type=std_logic lab=VDDR}
C {devices/lab_wire.sym} 80 -20 0 0 {name=pnR sig_type=std_logic lab=fbR}
C {devices/lab_wire.sym} 80 20 0 0 {name=ppR sig_type=std_logic lab=vcm}
C {devices/lab_wire.sym} 260 0 2 0 {name=poR sig_type=std_logic lab=OUTR}
C {devices/gnd.sym} 150 70 0 0 {name=lgR lab=GND
value=5}
N 350 -40 350 -30 {lab=OUTR}
N 350 30 350 40 {lab=fbR}
N 430 -40 430 -30 {lab=vin}
N 430 30 430 40 {lab=fbR}
C {devices/ind.sym} 350 0 0 0 {name=LR value=1G}
C {devices/capa.sym} 430 0 0 0 {name=CR value=1G}
C {devices/lab_wire.sym} 350 -40 0 0 {name=plRa sig_type=std_logic lab=OUTR}
C {devices/lab_wire.sym} 350 40 0 0 {name=plRb sig_type=std_logic lab=fbR}
C {devices/lab_wire.sym} 430 -40 0 0 {name=pcRa sig_type=std_logic lab=vin}
C {devices/lab_wire.sym} 430 40 0 0 {name=pcRb sig_type=std_logic lab=fbR}
N 150 130 150 140 {lab=VDDA}
N 80 180 90 180 {lab=fbA}
N 80 220 90 220 {lab=vcm}
N 250 200 260 200 {lab=OUTA}
N 150 260 150 270 {lab=GND}
C {a_zonetic2026/XSCHEM/OPAM/OPAM_G100A.sym} 190 200 0 0 {name=xA}
C {devices/lab_wire.sym} 150 130 0 0 {name=pvA sig_type=std_logic lab=VDDA}
C {devices/lab_wire.sym} 80 180 0 0 {name=pnA sig_type=std_logic lab=fbA}
C {devices/lab_wire.sym} 80 220 0 0 {name=ppA sig_type=std_logic lab=vcm}
C {devices/lab_wire.sym} 260 200 2 0 {name=poA sig_type=std_logic lab=OUTA}
C {devices/gnd.sym} 150 270 0 0 {name=lgA lab=GND
value=5}
N 350 160 350 170 {lab=OUTA}
N 350 230 350 240 {lab=fbA}
N 430 160 430 170 {lab=vin}
N 430 230 430 240 {lab=fbA}
C {devices/ind.sym} 350 200 0 0 {name=LA value=1G}
C {devices/capa.sym} 430 200 0 0 {name=CA value=1G}
C {devices/lab_wire.sym} 350 160 0 0 {name=plAa sig_type=std_logic lab=OUTA}
C {devices/lab_wire.sym} 350 240 0 0 {name=plAb sig_type=std_logic lab=fbA}
C {devices/lab_wire.sym} 430 160 0 0 {name=pcAa sig_type=std_logic lab=vin}
C {devices/lab_wire.sym} 430 240 0 0 {name=pcAb sig_type=std_logic lab=fbA}
N 150 330 150 340 {lab=VDDB}
N 80 380 90 380 {lab=fbB}
N 80 420 90 420 {lab=vcm}
N 250 400 260 400 {lab=OUTB}
N 150 460 150 470 {lab=GND}
C {a_zonetic2026/XSCHEM/OPAM/OPAM_G100B.sym} 190 400 0 0 {name=xB}
C {devices/lab_wire.sym} 150 330 0 0 {name=pvB sig_type=std_logic lab=VDDB}
C {devices/lab_wire.sym} 80 380 0 0 {name=pnB sig_type=std_logic lab=fbB}
C {devices/lab_wire.sym} 80 420 0 0 {name=ppB sig_type=std_logic lab=vcm}
C {devices/lab_wire.sym} 260 400 2 0 {name=poB sig_type=std_logic lab=OUTB}
C {devices/gnd.sym} 150 470 0 0 {name=lgB lab=GND
value=5}
N 350 360 350 370 {lab=OUTB}
N 350 430 350 440 {lab=fbB}
N 430 360 430 370 {lab=vin}
N 430 430 430 440 {lab=fbB}
C {devices/ind.sym} 350 400 0 0 {name=LB value=1G}
C {devices/capa.sym} 430 400 0 0 {name=CB value=1G}
C {devices/lab_wire.sym} 350 360 0 0 {name=plBa sig_type=std_logic lab=OUTB}
C {devices/lab_wire.sym} 350 440 0 0 {name=plBb sig_type=std_logic lab=fbB}
C {devices/lab_wire.sym} 430 360 0 0 {name=pcBa sig_type=std_logic lab=vin}
C {devices/lab_wire.sym} 430 440 0 0 {name=pcBb sig_type=std_logic lab=fbB}
C {devices/code_shown.sym} 700 -100 0 0 {name=s1
only_toplevel=false
value="
* OJO: ni una llave en este texto. xschem cuenta las llaves para saber donde
* acaba el bloque de atributos, asi que una sola dentro de un comentario lo
* corta por la mitad y el netlist sale con el 'blabla' de la plantilla, sin
* dar ningun error.
*
* No se puede lanzar un .ac con la entrada atada en continua: con el offset de
* -200 mV que mete el diodo el punto de operacion cae saturado y la
* linealizacion no significa nada. Por eso cada amplificador lleva su lazo de
* L de 1 GH y C de 1 GF: en continua la L es un corto y el lazo unitario coloca
* al amplificador en su propio offset, sea cual sea; en alterna la L abre y la
* C cortocircuita, y lo que se mide es la ganancia en lazo abierto.
* OUT realimenta a INN porque INP es la entrada no inversora: en el barrido de
* continua, subir INP-INN sube OUT.
* Vin vale AC 1, asi que v(OUT) ES la ganancia.
.save all
.control
ac dec 100 0.001 10G
wrdata ac.txt v(OUTR) v(OUTA) v(OUTB) v(OUTL) v(OUTL1) v(OUTL2)
.endc
"}
N 150 530 150 540 {lab=VDDL}
N 80 580 90 580 {lab=fbL}
N 80 620 90 620 {lab=vcm}
N 250 600 260 600 {lab=OUTL}
N 150 660 150 670 {lab=GND}
C {a_zonetic2026/XSCHEM/OPAM/OPAM_LIN.sym} 190 600 0 0 {name=xL}
C {devices/lab_wire.sym} 150 530 0 0 {name=pvL sig_type=std_logic lab=VDDL}
C {devices/lab_wire.sym} 80 580 0 0 {name=pnL sig_type=std_logic lab=fbL}
C {devices/lab_wire.sym} 80 620 0 0 {name=ppL sig_type=std_logic lab=vcm}
C {devices/lab_wire.sym} 260 600 2 0 {name=poL sig_type=std_logic lab=OUTL}
C {devices/gnd.sym} 150 670 0 0 {name=lgL lab=GND
value=5}
N 350 560 350 570 {lab=OUTL}
N 350 630 350 640 {lab=fbL}
N 430 560 430 570 {lab=vin}
N 430 630 430 640 {lab=fbL}
C {devices/ind.sym} 350 600 0 0 {name=LL value=1G}
C {devices/capa.sym} 430 600 0 0 {name=CL value=1G}
C {devices/lab_wire.sym} 350 560 0 0 {name=plLa sig_type=std_logic lab=OUTL}
C {devices/lab_wire.sym} 350 640 0 0 {name=plLb sig_type=std_logic lab=fbL}
C {devices/lab_wire.sym} 430 560 0 0 {name=pcLa sig_type=std_logic lab=vin}
C {devices/lab_wire.sym} 430 640 0 0 {name=pcLb sig_type=std_logic lab=fbL}
N 350 720 350 730 {lab=OUTL1}
N 350 790 350 800 {lab=fbL1}
N 430 720 430 730 {lab=vin}
N 430 790 430 800 {lab=fbL1}
C {devices/ind.sym} 350 760 0 0 {name=LL1 value=1G}
C {devices/capa.sym} 430 760 0 0 {name=CL1 value=1G}
C {devices/lab_wire.sym} 350 720 0 0 {name=plL1a sig_type=std_logic lab=OUTL1}
C {devices/lab_wire.sym} 350 800 0 0 {name=plL1b sig_type=std_logic lab=fbL1}
C {devices/lab_wire.sym} 430 720 0 0 {name=pcL1a sig_type=std_logic lab=vin}
C {devices/lab_wire.sym} 430 800 0 0 {name=pcL1b sig_type=std_logic lab=fbL1}
N 350 880 350 890 {lab=OUTL2}
N 350 950 350 960 {lab=fbL2}
N 430 880 430 890 {lab=vin}
N 430 950 430 960 {lab=fbL2}
C {devices/ind.sym} 350 920 0 0 {name=LL2 value=1G}
C {devices/capa.sym} 430 920 0 0 {name=CL2 value=1G}
C {devices/lab_wire.sym} 350 880 0 0 {name=plL2a sig_type=std_logic lab=OUTL2}
C {devices/lab_wire.sym} 350 960 0 0 {name=plL2b sig_type=std_logic lab=fbL2}
C {devices/lab_wire.sym} 430 880 0 0 {name=pcL2a sig_type=std_logic lab=vin}
C {devices/lab_wire.sym} 430 960 0 0 {name=pcL2b sig_type=std_logic lab=fbL2}
C {devices/code_shown.sym} 900 400 0 0 {name=DUTL only_toplevel=true
format="tcleval( @value )"
value="
* El layout de OPAM_LIN con parasitos RC, en sus dos versiones y cada una con su
* lazo de autopolarizacion. Puertos del extraido: VSS VDD INP OUT INN.
.include "../../../../Layouts/OPAM_LIN_flat/mag/OPAM_LIN_flat_pex_rc.spice"
XextrcL GND VDDL1 vcm OUTL1 fbL1 OPAM_LIN_flat
.include "../../../../layouts_v2/OPAM_LIN_flat/mag/OPAM_LIN_flat_V2_pex_rc.spice"
XextrcL2 GND VDDL2 vcm OUTL2 fbL2 OPAM_LIN_flat_V2
"}
