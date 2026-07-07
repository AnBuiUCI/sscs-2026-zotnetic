v {xschem version=3.4.8RC file_version=1.3}
G {}
K {}
V {}
S {}
F {}
E {}
N -690 -310 -650 -310 {lab=bias1}
N -690 -290 -650 -290 {lab=bias2}
N -690 -230 -650 -230 {lab=bias3}
N -690 -210 -650 -210 {lab=bias4}
N -1190 -90 -1130 -90 {lab=bias1}
N -980 -140 -980 -90 {lab=bias2}
N -860 -140 -860 -90 {lab=bias3}
N -730 -140 -730 -90 {lab=bias4}
N -1190 -30 -1130 -30 {lab=GND}
N -980 -30 -980 0 {lab=GND}
N -860 -30 -860 0 {lab=GND}
N -730 -30 -730 0 {lab=GND}
N -950 -270 -950 -240 {lab=GND}
N -1040 -270 -1040 -240 {lab=GND}
N -950 -370 -950 -330 {lab=VSS}
N -1040 -370 -1040 -330 {lab=VDD}
N -350 -310 -320 -310 {lab=VDD}
N -350 -270 -320 -270 {lab=VSS}
N -580 -40 -580 -10 {lab=GND}
N -450 -40 -450 -10 {lab=GND}
N -580 -150 -580 -100 {lab=vinn}
N -450 -150 -450 -100 {lab=vinp}
N -690 -270 -640 -270 {lab=vinn}
N -700 -250 -650 -250 {lab=vinp}
N -350 -290 -320 -290 {lab=#net1}
N -1130 -140 -1130 -90 {lab=bias1}
N -1130 -30 -1130 0 {lab=GND}
C {vsource.sym} -1190 -60 0 0 {name=V1 value=PAR_bias1 savecurrent=false}
C {vsource.sym} -980 -60 0 0 {name=V2 value=PAR_bias2 savecurrent=false}
C {vsource.sym} -860 -60 0 0 {name=V3 value=PAR_bias3 savecurrent=false}
C {vsource.sym} -730 -60 0 0 {name=V4 value=PAR_bias4 savecurrent=false}
C {lab_pin.sym} -690 -310 0 0 {name=p1 sig_type=std_logic lab=bias1}
C {lab_pin.sym} -690 -290 0 0 {name=p2 sig_type=std_logic lab=bias2}
C {lab_pin.sym} -690 -230 0 0 {name=p3 sig_type=std_logic lab=bias3}
C {lab_pin.sym} -690 -210 0 0 {name=p4 sig_type=std_logic lab=bias4}
C {lab_pin.sym} -1130 -130 0 0 {name=p5 sig_type=std_logic lab=bias1}
C {lab_pin.sym} -980 -130 0 0 {name=p6 sig_type=std_logic lab=bias2}
C {lab_pin.sym} -860 -130 0 0 {name=p7 sig_type=std_logic lab=bias3}
C {lab_pin.sym} -730 -130 0 0 {name=p8 sig_type=std_logic lab=bias4}
C {gnd.sym} -1130 0 0 0 {name=l1 lab=GND}
C {gnd.sym} -980 0 0 0 {name=l2 lab=GND}
C {gnd.sym} -860 0 0 0 {name=l3 lab=GND}
C {gnd.sym} -730 0 0 0 {name=l4 lab=GND}
C {vsource.sym} -1040 -300 0 0 {name=V5 value=5V savecurrent=false}
C {vsource.sym} -950 -300 0 0 {name=V6 value=0V savecurrent=false}
C {lab_pin.sym} -320 -310 2 0 {name=p9 sig_type=std_logic lab=VDD}
C {lab_pin.sym} -320 -270 2 0 {name=p10 sig_type=std_logic lab=VSS}
C {gnd.sym} -950 -240 0 0 {name=l5 lab=GND}
C {gnd.sym} -1040 -240 0 0 {name=l6 lab=GND}
C {lab_pin.sym} -950 -360 2 0 {name=p11 sig_type=std_logic lab=VSS}
C {lab_pin.sym} -1040 -360 2 0 {name=p12 sig_type=std_logic lab=VDD}
C {vsource.sym} -580 -70 0 0 {name=V8 value=PAR_vinn savecurrent=false}
C {vsource.sym} -450 -70 0 0 {name=V9 value=PAR_vinp savecurrent=false}
C {gnd.sym} -580 -10 0 0 {name=l7 lab=GND}
C {gnd.sym} -450 -10 0 0 {name=l8 lab=GND}
C {lab_pin.sym} -580 -140 0 0 {name=p13 sig_type=std_logic lab=vinn}
C {lab_pin.sym} -450 -140 0 0 {name=p14 sig_type=std_logic lab=vinp}
C {lab_pin.sym} -690 -270 0 0 {name=p15 sig_type=std_logic lab=vinn}
C {lab_pin.sym} -700 -250 0 0 {name=p16 sig_type=std_logic lab=vinp}
C {code_shown.sym} -1300 -570 0 0 {name=MODELS only_toplevel=false value=".include /foss/pdks/gf180mcuD/libs.tech/ngspice/design.ngspice
.lib /foss/pdks/gf180mcuD/libs.tech/ngspice/sm141064.ngspice typical
.lib /foss/pdks/gf180mcuD/libs.tech/ngspice/smbb000149.ngspice typical
.lib /foss/pdks/gf180mcuD/libs.tech/ngspice/sm141064.ngspice cap_mim
.lib /foss/pdks/gf180mcuD/libs.tech/ngspice/sm141064.ngspice mimcap_typical"}
C {code_shown.sym} -270 -610 0 0 {name=NGSPICE only_toplevel=false value="** PARAMETERS
.PARAM PAR_bias1=3.425
.PARAM PAR_bias2=3.425
.PARAM PAR_bias3=3.425
.PARAM PAR_bias4=3.425
.PARAM PAR_vinn=2.5
.PARAM PAR_vinp=2.5

.control
  * clear the results file and write a header row
  echo \\"# bias1 bias2 bias3 bias4 gain\\" > /foss/designs/sscs-2026-zotnetic/activities/opamp2AKAM/simulations_testbench/simulation_results/high12low34.txt

  * ---- OUTER LOOP: try many bias combinations ----
  * nominal point is 3.425 / 2.428 / 1.909 / 1.209.
  * (the +0.001 on each limit dodges float-rounding overshoot)
  let b1 = 4.0 
  while b1 <= 5.001
    let b2 = 4.0 
    while b2 <= 5.001
      let b3 = 0 
      while b3 <= 1.001
        let b4 = 0 
        while b4 <= 1.001

          * set the four bias knobs for this combination
          alter V1 = b1
          alter V2 = b2
          alter V3 = b3
          alter V4 = b4

          * ---- INNER LOOP: sweep the input to measure gain ----
          dc V9 0 5 0.001

          * read the slope: input where output passes 1.5 V and 3.5 V
          meas dc vlo when v(net1)=1.5 cross=1
          meas dc vhi when v(net1)=3.5 cross=1
          let gain = 2.0/abs(vhi-vlo)

          * write one row of the table
          echo \\"$&b1 $&b2 $&b3 $&b4 $&gain\\" >> /foss/designs/sscs-2026-zotnetic/activities/opamp2AKAM/simulations_testbench/simulation_results/high12low34.txt

          let b4 = b4 + 0.5
        end
        let b3 = b3 + 0.5
      end
      let b2 = b2 + 0.5
    end
    let b1 = b1 + 0.5
  end

  echo \\"DONE - results in high12low34.txt\\"
.endc"

}
C {/foss/designs/sscs-2026-zotnetic/activities/opamp2AKAM/opamp.sym} -500 -260 0 0 {name=x1}
