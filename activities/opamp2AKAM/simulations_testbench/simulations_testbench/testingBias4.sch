v {xschem version=3.4.8RC file_version=1.3}
G {}
K {}
V {}
S {}
F {}
E {}
N 430 -270 470 -270 {lab=bias1}
N 430 -250 470 -250 {lab=bias2}
N 430 -190 470 -190 {lab=bias3}
N 430 -170 470 -170 {lab=bias4}
N -70 -50 -10 -50 {lab=bias1}
N 140 -100 140 -50 {lab=bias2}
N 260 -100 260 -50 {lab=bias3}
N 390 -100 390 -50 {lab=bias4}
N -70 10 -10 10 {lab=GND}
N 140 10 140 40 {lab=GND}
N 260 10 260 40 {lab=GND}
N 390 10 390 40 {lab=GND}
N 170 -230 170 -200 {lab=GND}
N 80 -230 80 -200 {lab=GND}
N 170 -330 170 -290 {lab=VSS}
N 80 -330 80 -290 {lab=VDD}
N 770 -270 800 -270 {lab=VDD}
N 770 -230 800 -230 {lab=VSS}
N 540 0 540 30 {lab=GND}
N 670 0 670 30 {lab=GND}
N 540 -110 540 -60 {lab=vinn}
N 670 -110 670 -60 {lab=vinp}
N 430 -230 480 -230 {lab=vinn}
N 420 -210 470 -210 {lab=vinp}
N 770 -250 800 -250 {lab=#net1}
N -10 -100 -10 -50 {lab=bias1}
N -10 10 -10 40 {lab=GND}
C {vsource.sym} -70 -20 0 0 {name=V1 value=PAR_bias1 savecurrent=false}
C {vsource.sym} 140 -20 0 0 {name=V2 value=PAR_bias2 savecurrent=false}
C {vsource.sym} 260 -20 0 0 {name=V3 value=PAR_bias3 savecurrent=false}
C {vsource.sym} 390 -20 0 0 {name=V4 value=PAR_bias4 savecurrent=false}
C {lab_pin.sym} 430 -270 0 0 {name=p1 sig_type=std_logic lab=bias1}
C {lab_pin.sym} 430 -250 0 0 {name=p2 sig_type=std_logic lab=bias2}
C {lab_pin.sym} 430 -190 0 0 {name=p3 sig_type=std_logic lab=bias3}
C {lab_pin.sym} 430 -170 0 0 {name=p4 sig_type=std_logic lab=bias4}
C {lab_pin.sym} -10 -90 0 0 {name=p5 sig_type=std_logic lab=bias1}
C {lab_pin.sym} 140 -90 0 0 {name=p6 sig_type=std_logic lab=bias2}
C {lab_pin.sym} 260 -90 0 0 {name=p7 sig_type=std_logic lab=bias3}
C {lab_pin.sym} 390 -90 0 0 {name=p8 sig_type=std_logic lab=bias4}
C {gnd.sym} -10 40 0 0 {name=l1 lab=GND}
C {gnd.sym} 140 40 0 0 {name=l2 lab=GND}
C {gnd.sym} 260 40 0 0 {name=l3 lab=GND}
C {gnd.sym} 390 40 0 0 {name=l4 lab=GND}
C {vsource.sym} 80 -260 0 0 {name=V5 value=5V savecurrent=false}
C {vsource.sym} 170 -260 0 0 {name=V6 value=0V savecurrent=false}
C {lab_pin.sym} 800 -270 2 0 {name=p9 sig_type=std_logic lab=VDD}
C {lab_pin.sym} 800 -230 2 0 {name=p10 sig_type=std_logic lab=VSS}
C {gnd.sym} 170 -200 0 0 {name=l5 lab=GND}
C {gnd.sym} 80 -200 0 0 {name=l6 lab=GND}
C {lab_pin.sym} 170 -320 2 0 {name=p11 sig_type=std_logic lab=VSS}
C {lab_pin.sym} 80 -320 2 0 {name=p12 sig_type=std_logic lab=VDD}
C {vsource.sym} 540 -30 0 0 {name=V8 value=PAR_vinn savecurrent=false}
C {vsource.sym} 670 -30 0 0 {name=V9 value=PAR_vinp savecurrent=false}
C {gnd.sym} 540 30 0 0 {name=l7 lab=GND}
C {gnd.sym} 670 30 0 0 {name=l8 lab=GND}
C {lab_pin.sym} 540 -100 0 0 {name=p13 sig_type=std_logic lab=vinn}
C {lab_pin.sym} 670 -100 0 0 {name=p14 sig_type=std_logic lab=vinp}
C {lab_pin.sym} 430 -230 0 0 {name=p15 sig_type=std_logic lab=vinn}
C {lab_pin.sym} 420 -210 0 0 {name=p16 sig_type=std_logic lab=vinp}
C {code_shown.sym} -180 -530 0 0 {name=MODELS only_toplevel=false value=".include /foss/pdks/gf180mcuD/libs.tech/ngspice/design.ngspice
.lib /foss/pdks/gf180mcuD/libs.tech/ngspice/sm141064.ngspice typical
.lib /foss/pdks/gf180mcuD/libs.tech/ngspice/smbb000149.ngspice typical
.lib /foss/pdks/gf180mcuD/libs.tech/ngspice/sm141064.ngspice cap_mim
.lib /foss/pdks/gf180mcuD/libs.tech/ngspice/sm141064.ngspice mimcap_typical"}
C {code_shown.sym} 850 -570 0 0 {name=NGSPICE only_toplevel=false value="** PARAMETERS
.PARAM PAR_bias1=3.425
.PARAM PAR_bias2=3.425
.PARAM PAR_bias3=3.425
.PARAM PAR_bias4=3.425
.PARAM PAR_vinn=2.5
.PARAM PAR_vinp=2.5

.control
 let x=0
 alter V1 = 3.425
 alter V2 = 2.428
 alter V3 = 1.909
 echo \\"bias4Value Gain\\" > /foss/designs/sscs-2026-zotnetic/activities/opamp2AKAM/simulations_testbench/simulation_results/tuningBias4.txt
 while x<3.001
  alter V4=x
  dc V9 0 5 0.001
  meas dc vlo when v(net1)=1.5 cross=1
  meas dc vhi when v(net1)=3.5 cross=1
  let g = 2.0/abs(vhi-vlo)
  echo \\"$&x $&g\\" >>/foss/designs/sscs-2026-zotnetic/activities/opamp2AKAM/simulations_testbench/simulation_results/tuningBias4.txt
  let x = x+0.05
  end
.endc"

}
C {/foss/designs/sscs-2026-zotnetic/activities/opamp2AKAM/opamp.sym} 620 -220 0 0 {name=x1}
