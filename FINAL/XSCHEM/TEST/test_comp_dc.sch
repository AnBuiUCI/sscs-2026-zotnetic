v {xschem version=3.4.8RC file_version=1.3}
G {}
K {}
V {}
S {}
F {}
E {}
N 370 -190 370 -180 {lab=VDD}
N 300 -140 310 -140 {lab=vb}
N 300 -100 310 -100 {lab=va}
N 470 -120 480 -120 {lab=OUT}
N 370 -60 370 -50 {lab=GND}
C {devices/code_shown.sym} 320 -590 0 0 {name=MODELS1 only_toplevel=true
format="tcleval( @value )"
value="
.include $::180MCU_MODELS/design.ngspice
.lib $::180MCU_MODELS/sm141064.ngspice typical
.lib $::180MCU_MODELS/sm141064.ngspice cap_mim
.lib $::180MCU_MODELS/sm141064.ngspice res_typical
.lib $::180MCU_MODELS/sm141064.ngspice moscap_typical
.lib $::180MCU_MODELS/sm141064.ngspice mimcap_typical
"}
C {devices/vsource.sym} 100 -250 0 0 {name=V1 value=5
}
C {devices/lab_wire.sym} 100 -280 0 0 {name=pV1a sig_type=std_logic lab=VDD}
C {devices/gnd.sym} 100 -220 0 0 {name=lV1 lab=GND
value=5}
C {devices/vsource.sym} 180 -250 0 0 {name=V2 value=5
}
C {devices/lab_wire.sym} 180 -280 0 0 {name=pV2a sig_type=std_logic lab=VDD1}
C {devices/gnd.sym} 180 -220 0 0 {name=lV2 lab=GND
value=5}
C {devices/vsource.sym} 260 -250 0 0 {name=V6 value=5
}
C {devices/lab_wire.sym} 260 -280 0 0 {name=pV6a sig_type=std_logic lab=VDD2}
C {devices/gnd.sym} 260 -220 0 0 {name=lV6 lab=GND
value=5}
C {devices/vsource.sym} -100 -250 0 0 {name=V5 value=0
}
C {devices/lab_wire.sym} -100 -280 0 0 {name=pV5a sig_type=std_logic lab=va}
C {devices/lab_wire.sym} -100 -220 0 0 {name=pV5b sig_type=std_logic lab=vb}
C {devices/vsource.sym} 0 -250 0 0 {name=Vcm value=2.5
}
C {devices/lab_wire.sym} 0 -280 0 0 {name=pVcma sig_type=std_logic lab=vb}
C {devices/gnd.sym} 0 -220 0 0 {name=lVcm lab=GND
value=5}
C {a_zonetic2026/XSCHEM/OPAM/COMP_sc.sym} 370 -120 0 0 {name=x1}
C {devices/lab_wire.sym} 370 -190 0 0 {name=pcv sig_type=std_logic lab=VDD}
C {devices/lab_wire.sym} 300 -140 0 0 {name=pcn sig_type=std_logic lab=vb}
C {devices/lab_wire.sym} 300 -100 0 0 {name=pcp sig_type=std_logic lab=va}
C {devices/lab_wire.sym} 480 -120 2 0 {name=pco sig_type=std_logic lab=OUT}
C {devices/gnd.sym} 370 -50 0 0 {name=lcg lab=GND
value=5}
C {devices/code_shown.sym} -230 -580 0 0 {name=DUT1 only_toplevel=true
format="tcleval( @value )"
value="
.include "../../../../Layouts/COMP/mag/COMP_pex_rc.spice"
Xextrc GND VDD1 OUT1 va vb COMP
*COMP VSS VDD OUT INP INN
"}
C {devices/code_shown.sym} -220 -440 0 0 {name=DUT2 only_toplevel=true
format="tcleval( @value )"
value="
* The v2 layout, beside v1. The subcircuit is renamed to COMP_V2 because both
* extractions declare the same name -- the cell is named the same on purpose,
* which is what allows comparing them against the SAME reference in
* LVS. preparar_extraidos.sh renames it, touching only .subckt and .ends.
.include "../../../../layouts_v2/COMP/mag/COMP_V2_pex_rc.spice"
Xextrc2 GND VDD2 OUT2 va vb COMP_V2
"}
C {devices/code_shown.sym} 560 -410 0 0 {name=s1
only_toplevel=false
value="
* CAREFUL: not one brace in this text. xschem counts them to find where the
* attribute block ends and a single one inside a comment cuts it in half,
* leaving the netlist with the template 'blabla' and raising no error.
*
* The inputs are gates, so the va/vb pair has no DC path to ground on its own.
* Vcm provides it. 2.5 V was chosen after sweeping it: unlike
* the OPAM, the COMP gain does not depend on common mode -- about
* 22000 V/V between 1.5 and 3.5 V -- because its output stage is properly
* dimensionada y no se sale de saturacion.
.save all
.control
* Wide window, to see the full swing of both branches.
dc V5 -0.3 0.3 1m
wrdata ancho.txt v(OUT) v(OUT1) v(OUT2) v(VDD)*i(v1) v(VDD1)*i(v2) v(VDD2)*i(v6)
plot v(OUT) v(OUT1) v(OUT2) title 'ANCHO'
plot v(VDD)*i(v1) v(VDD1)*i(v2) v(VDD2)*i(v6) title 'ANCHO'
* Fine window: at gain 22000 the transition is 5V/22000 = 227 uV, which the
* ventana de arriba se salta entera.
dc V5 -0.5m 0.5m 1u
wrdata fino.txt v(OUT) v(OUT1) v(OUT2)
plot v(OUT) v(OUT1) v(OUT2) title 'FINO'
plot v(VDD)*i(v1) v(VDD1)*i(v2) v(VDD2)*i(v6) title 'FINO'
.endc
"}
