v {xschem version=3.4.8RC file_version=1.3}
G {}
K {}
V {}
S {}
F {}
E {}
N 320 -70 320 -60 {lab=VDDR}
N 250 -20 260 -20 {lab=vb}
N 250 20 260 20 {lab=va}
N 420 0 430 0 {lab=OUTR}
N 320 60 320 70 {lab=GND}
N 610 -70 610 -60 {lab=VDDA}
N 710 0 720 0 {lab=OUTA}
N 610 60 610 70 {lab=GND}
N 900 -70 900 -60 {lab=VDDB}
N 1000 0 1010 0 {lab=OUTB}
N 900 60 900 70 {lab=GND}
N 540 -20 550 -20 {lab=vb}
N 540 20 550 20 {lab=va}
N 830 -20 840 -20 {lab=vb}
N 830 20 840 20 {lab=va}
C {devices/code_shown.sym} 1600 -120 0 0 {name=MODELS1 only_toplevel=true
format="tcleval( @value )"
value="
.include $::180MCU_MODELS/design.ngspice
.lib $::180MCU_MODELS/sm141064.ngspice typical
.lib $::180MCU_MODELS/sm141064.ngspice cap_mim
.lib $::180MCU_MODELS/sm141064.ngspice res_typical
.lib $::180MCU_MODELS/sm141064.ngspice moscap_typical
.lib $::180MCU_MODELS/sm141064.ngspice mimcap_typical
"}
C {devices/vsource.sym} 950 320 0 0 {name=V1 value=5
}
C {devices/lab_wire.sym} 950 290 0 0 {name=pV1a sig_type=std_logic lab=VDDR}
C {devices/gnd.sym} 950 350 0 0 {name=lV1 lab=GND
value=5}
C {devices/vsource.sym} 1030 320 0 0 {name=V2 value=5
}
C {devices/lab_wire.sym} 1030 290 0 0 {name=pV2a sig_type=std_logic lab=VDDA}
C {devices/gnd.sym} 1030 350 0 0 {name=lV2 lab=GND
value=5}
C {devices/vsource.sym} 1110 320 0 0 {name=V3 value=5
}
C {devices/lab_wire.sym} 1110 290 0 0 {name=pV3a sig_type=std_logic lab=VDDB}
C {devices/gnd.sym} 1110 350 0 0 {name=lV3 lab=GND
value=5}
C {devices/vsource.sym} 1190 320 0 0 {name=V4 value=5
}
C {devices/lab_wire.sym} 1190 290 0 0 {name=pV4a sig_type=std_logic lab=VDDL}
C {devices/gnd.sym} 1190 350 0 0 {name=lV4 lab=GND
value=5}
C {devices/vsource.sym} 1270 320 0 0 {name=V6 value=5
}
C {devices/lab_wire.sym} 1270 290 0 0 {name=pV6a sig_type=std_logic lab=VDDL1}
C {devices/gnd.sym} 1270 350 0 0 {name=lV6 lab=GND
value=5}
C {devices/vsource.sym} 1350 320 0 0 {name=V7 value=5
}
C {devices/lab_wire.sym} 1350 290 0 0 {name=pV7a sig_type=std_logic lab=VDDL2}
C {devices/gnd.sym} 1350 350 0 0 {name=lV7 lab=GND
value=5}
C {devices/code_shown.sym} 1500 -420 0 0 {name=DUTL only_toplevel=true
format="tcleval( @value )"
value="
* El layout de OPAM_LIN, extraido con parasitos RC, en sus dos versiones. Es la
* comparacion que faltaba: hasta ahora el banco solo tenia el esquematico, asi
* que nada decia si el layout se come la linealidad o el margen de fase.
* Los puertos del extraido van en este orden: VSS VDD INP OUT INN.
.include "../../../../Layouts/OPAM_LIN_flat/mag/OPAM_LIN_flat_pex_rc.spice"
XextrcL GND VDDL1 va OUTL1 vb OPAM_LIN_flat
.include "../../../../layouts_v2/OPAM_LIN_flat/mag/OPAM_LIN_flat_V2_pex_rc.spice"
XextrcL2 GND VDDL2 va OUTL2 vb OPAM_LIN_flat_V2
"}
C {devices/vsource.sym} 750 320 0 0 {name=V5 value=0
}
C {devices/lab_wire.sym} 750 290 0 0 {name=pV5a sig_type=std_logic lab=va}
C {devices/lab_wire.sym} 750 350 0 0 {name=pV5b sig_type=std_logic lab=vb}
C {devices/vsource.sym} 850 320 0 0 {name=Vcm value=2.0
}
C {devices/lab_wire.sym} 850 290 0 0 {name=pVcma sig_type=std_logic lab=vb}
C {devices/gnd.sym} 850 350 0 0 {name=lVcm lab=GND
value=5}
C {a_zonetic2026/XSCHEM/OPAM/OPAMt.sym} 360 0 0 0 {name=xR}
C {devices/lab_wire.sym} 320 -70 0 0 {name=pvR sig_type=std_logic lab=VDDR}
C {devices/lab_wire.sym} 250 -20 0 0 {name=pnR sig_type=std_logic lab=vb}
C {devices/lab_wire.sym} 250 20 0 0 {name=ppR sig_type=std_logic lab=va}
C {devices/lab_wire.sym} 430 0 2 0 {name=poR sig_type=std_logic lab=OUTR}
C {devices/gnd.sym} 320 70 0 0 {name=lgR lab=GND
value=5}
C {a_zonetic2026/XSCHEM/OPAM/OPAM_G100A.sym} 650 0 0 0 {name=xA}
C {devices/lab_wire.sym} 610 -70 0 0 {name=pvA sig_type=std_logic lab=VDDA}
C {devices/lab_wire.sym} 720 0 2 0 {name=poA sig_type=std_logic lab=OUTA}
C {devices/gnd.sym} 610 70 0 0 {name=lgA lab=GND
value=5}
C {a_zonetic2026/XSCHEM/OPAM/OPAM_G100B.sym} 940 0 0 0 {name=xB}
C {devices/lab_wire.sym} 900 -70 0 0 {name=pvB sig_type=std_logic lab=VDDB}
C {devices/lab_wire.sym} 1010 0 2 0 {name=poB sig_type=std_logic lab=OUTB}
C {devices/gnd.sym} 900 70 0 0 {name=lgB lab=GND
value=5}
C {devices/code_shown.sym} 1600 220 0 0 {name=s1
only_toplevel=false
value="
.save all
.control
dc V5 -0.3 0.1 200u
wrdata ancho.txt v(OUTR) v(OUTA) v(OUTB) v(OUTL) v(OUTL1) v(OUTL2)
+ v(VDDR)*i(v1) v(VDDA)*i(v2) v(VDDB)*i(v3) v(VDDL)*i(v4)
+ v(VDDL1)*i(v6) v(VDDL2)*i(v7)
plot v(OUTR) v(OUTA) v(OUTB) v(OUTL)
* Ventana fina para la referencia, cuya transicion mide 85 uV.
dc V5 -1m 1m 2u
wrdata fino.txt v(OUTR) v(OUTA) v(OUTB) v(OUTL) v(OUTL1) v(OUTL2)
plot v(OUTR) v(OUTA) v(OUTB) v(OUTL)
.endc
"}
C {devices/lab_wire.sym} 540 -20 0 0 {name=pnR1 sig_type=std_logic lab=vb}
C {devices/lab_wire.sym} 540 20 0 0 {name=ppR1 sig_type=std_logic lab=va}
C {devices/lab_wire.sym} 830 -20 0 0 {name=pnR2 sig_type=std_logic lab=vb}
C {devices/lab_wire.sym} 830 20 0 0 {name=ppR2 sig_type=std_logic lab=va}
N 1190 -70 1190 -60 {lab=VDDL}
N 1120 -20 1130 -20 {lab=vb}
N 1120 20 1130 20 {lab=va}
N 1290 0 1300 0 {lab=OUTL}
N 1190 60 1190 70 {lab=GND}
C {a_zonetic2026/XSCHEM/OPAM/OPAM_LIN.sym} 1230 0 0 0 {name=xL}
C {devices/lab_wire.sym} 1190 -70 0 0 {name=pvL sig_type=std_logic lab=VDDL}
C {devices/lab_wire.sym} 1120 -20 0 0 {name=pnL sig_type=std_logic lab=vb}
C {devices/lab_wire.sym} 1120 20 0 0 {name=ppL sig_type=std_logic lab=va}
C {devices/lab_wire.sym} 1300 0 2 0 {name=poL sig_type=std_logic lab=OUTL}
C {devices/gnd.sym} 1190 70 0 0 {name=lgL lab=GND
value=5}
