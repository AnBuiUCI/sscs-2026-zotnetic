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
C {devices/vsource.sym} -600 -140 0 0 {name=V5 value="pulse(-10m 10m 200n 100p 100p 800n 2u)"
}
C {devices/lab_wire.sym} -600 -170 0 0 {name=pV5a sig_type=std_logic lab=va}
C {devices/lab_wire.sym} -600 -110 0 0 {name=pV5b sig_type=std_logic lab=vb}
C {devices/vsource.sym} -500 -140 0 0 {name=Vcm value=2.5
}
C {devices/lab_wire.sym} -500 -170 0 0 {name=pVcma sig_type=std_logic lab=vb}
C {devices/gnd.sym} -500 -110 0 0 {name=lVcm lab=GND
value=5}
N 200 -70 200 -60 {lab=VDD}
N 130 -20 140 -20 {lab=vb}
N 130 20 140 20 {lab=va}
N 300 0 310 0 {lab=OUT}
N 200 60 200 70 {lab=GND}
C {a_zonetic2026/XSCHEM/OPAM/COMP_sc.sym} 200 0 0 0 {name=x1}
C {devices/lab_wire.sym} 200 -70 0 0 {name=pcv sig_type=std_logic lab=VDD}
C {devices/lab_wire.sym} 130 -20 0 0 {name=pcn sig_type=std_logic lab=vb}
C {devices/lab_wire.sym} 130 20 0 0 {name=pcp sig_type=std_logic lab=va}
C {devices/lab_wire.sym} 310 0 2 0 {name=pco sig_type=std_logic lab=OUT}
C {devices/gnd.sym} 200 70 0 0 {name=lcg lab=GND
value=5}
C {devices/vsource.sym} -240 -140 0 0 {name=V6 value=5
}
C {devices/lab_wire.sym} -240 -170 0 0 {name=pV6a sig_type=std_logic lab=VDD2}
C {devices/gnd.sym} -240 -110 0 0 {name=lV6 lab=GND
value=5}
C {devices/code_shown.sym} 700 -420 0 0 {name=DUT1 only_toplevel=true
format="tcleval( @value )"
value="
.include "../../../../Layouts/COMP/mag/COMP_pex_rc.spice"
Xextrc GND VDD1 OUT1 va vb COMP
*COMP VSS VDD OUT INP INN
"}
C {devices/code_shown.sym} 700 -320 0 0 {name=DUT2 only_toplevel=true
format="tcleval( @value )"
value="
.include "../../../../layouts_v2/COMP/mag/COMP_V2_pex_rc.spice"
Xextrc2 GND VDD2 OUT2 va vb COMP_V2
"}
C {devices/code_shown.sym} 700 -100 0 0 {name=s1
only_toplevel=false
value="
* CAREFUL: not one brace in this text. xschem counts them to find where the
* attribute block ends and a single one inside a comment cuts it in half,
* leaving the netlist with the template 'blabla' and raising no error.
*
* Transitorio de comparador, no de amplificador: lazo abierto y un escalon de
* overdrive of +-10 mV around the threshold. What is measured is the propagation
* delay -- from the input crossing to the half-rail crossing of the
* output -- and the rise and fall times, for the schematic and for the
* layout extraido.
* The threshold is zero because the measured COMP offset is tenths of a millivolt.
.save all
.control
tran 200p 2u
wrdata tran.txt v(va)-v(vb) v(OUT) v(OUT1) v(OUT2)
.endc
"}
