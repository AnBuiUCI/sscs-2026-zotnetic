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
C {devices/code_shown.sym} 900 400 0 0 {name=DUTL only_toplevel=true
format="tcleval( @value )"
value="
* The OPAM_LIN layout with RC parasitics, in both versions, also in
* seguidor: la entrada negativa va atada a su propia salida.
* Puertos del extraido: VSS VDD INP OUT INN.
.include "../../../../Layouts/OPAM_LIN_flat/mag/OPAM_LIN_flat_pex_rc.spice"
XextrcL GND VDDL1 vin OUTL1 OUTL1 OPAM_LIN_flat
.include "../../../../layouts_v2/OPAM_LIN_flat/mag/OPAM_LIN_flat_V2_pex_rc.spice"
XextrcL2 GND VDDL2 vin OUTL2 OUTL2 OPAM_LIN_flat_V2
"}
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
C {devices/vsource.sym} -600 -140 0 0 {name=Vin value="pulse(1.5 2.5 2u 1n 1n 8u 20u)"
}
C {devices/lab_wire.sym} -600 -170 0 0 {name=pVina sig_type=std_logic lab=vin}
C {devices/gnd.sym} -600 -110 0 0 {name=lVin lab=GND
value=5}
N 150 -70 150 -60 {lab=VDDR}
N 80 -20 90 -20 {lab=OUTR}
N 80 20 90 20 {lab=vin}
N 250 0 260 0 {lab=OUTR}
N 150 60 150 70 {lab=GND}
C {a_zonetic2026/XSCHEM/OPAM/OPAMt.sym} 190 0 0 0 {name=xR}
C {devices/lab_wire.sym} 150 -70 0 0 {name=pvR sig_type=std_logic lab=VDDR}
C {devices/lab_wire.sym} 80 -20 0 0 {name=pnR sig_type=std_logic lab=OUTR}
C {devices/lab_wire.sym} 80 20 0 0 {name=ppR sig_type=std_logic lab=vin}
C {devices/lab_wire.sym} 260 0 2 0 {name=poR sig_type=std_logic lab=OUTR}
C {devices/gnd.sym} 150 70 0 0 {name=lgR lab=GND
value=5}
N 150 130 150 140 {lab=VDDA}
N 80 180 90 180 {lab=OUTA}
N 80 220 90 220 {lab=vin}
N 250 200 260 200 {lab=OUTA}
N 150 260 150 270 {lab=GND}
C {a_zonetic2026/XSCHEM/OPAM/OPAM_G100A.sym} 190 200 0 0 {name=xA}
C {devices/lab_wire.sym} 150 130 0 0 {name=pvA sig_type=std_logic lab=VDDA}
C {devices/lab_wire.sym} 80 180 0 0 {name=pnA sig_type=std_logic lab=OUTA}
C {devices/lab_wire.sym} 80 220 0 0 {name=ppA sig_type=std_logic lab=vin}
C {devices/lab_wire.sym} 260 200 2 0 {name=poA sig_type=std_logic lab=OUTA}
C {devices/gnd.sym} 150 270 0 0 {name=lgA lab=GND
value=5}
N 150 330 150 340 {lab=VDDB}
N 80 380 90 380 {lab=OUTB}
N 80 420 90 420 {lab=vin}
N 250 400 260 400 {lab=OUTB}
N 150 460 150 470 {lab=GND}
C {a_zonetic2026/XSCHEM/OPAM/OPAM_G100B.sym} 190 400 0 0 {name=xB}
C {devices/lab_wire.sym} 150 330 0 0 {name=pvB sig_type=std_logic lab=VDDB}
C {devices/lab_wire.sym} 80 380 0 0 {name=pnB sig_type=std_logic lab=OUTB}
C {devices/lab_wire.sym} 80 420 0 0 {name=ppB sig_type=std_logic lab=vin}
C {devices/lab_wire.sym} 260 400 2 0 {name=poB sig_type=std_logic lab=OUTB}
C {devices/gnd.sym} 150 470 0 0 {name=lgB lab=GND
value=5}
C {devices/code_shown.sym} 700 -100 0 0 {name=s1
only_toplevel=false
value="
* CAREFUL: not one brace in this text. xschem counts braces to find where
* the attribute block ends, so a single one inside a comment cuts it in
* half and the netlist comes out with the template 'blabla', without
* dar ningun error.
*
* All three as followers -OUT tied to INN- with a 2 to 3 V step. What matters
* porque el diodo cambia la polarizacion de reposo de la etapa de salida clase
* AB, and slew rate and settling is where it shows most.
.save all
.control
tran 2n 20u
wrdata tran.txt v(vin) v(OUTR) v(OUTA) v(OUTB) v(OUTL) v(OUTL1) v(OUTL2)
.endc
"}
N 150 530 150 540 {lab=VDDL}
N 80 580 90 580 {lab=OUTL}
N 80 620 90 620 {lab=vin}
N 250 600 260 600 {lab=OUTL}
N 150 660 150 670 {lab=GND}
C {a_zonetic2026/XSCHEM/OPAM/OPAM_LIN.sym} 190 600 0 0 {name=xL}
C {devices/lab_wire.sym} 150 530 0 0 {name=pvL sig_type=std_logic lab=VDDL}
C {devices/lab_wire.sym} 80 580 0 0 {name=pnL sig_type=std_logic lab=OUTL}
C {devices/lab_wire.sym} 80 620 0 0 {name=ppL sig_type=std_logic lab=vin}
C {devices/lab_wire.sym} 260 600 2 0 {name=poL sig_type=std_logic lab=OUTL}
C {devices/gnd.sym} 150 670 0 0 {name=lgL lab=GND
value=5}
