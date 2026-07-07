v {xschem version=3.4.8RC file_version=1.3}
G {}
K {}
V {}
S {}
F {}
E {}
N -340 -220 -300 -220 {lab=bias1}
N -340 -200 -300 -200 {lab=bias2}
N -340 -140 -300 -140 {lab=bias3}
N -340 -120 -300 -120 {lab=bias4}
N -840 0 -780 0 {lab=bias1}
N -630 -50 -630 0 {lab=bias2}
N -510 -50 -510 0 {lab=bias3}
N -380 -50 -380 0 {lab=bias4}
N -840 60 -780 60 {lab=GND}
N -630 60 -630 90 {lab=GND}
N -510 60 -510 90 {lab=GND}
N -380 60 -380 90 {lab=GND}
N -600 -180 -600 -150 {lab=GND}
N -690 -180 -690 -150 {lab=GND}
N -600 -280 -600 -240 {lab=VSS}
N -690 -280 -690 -240 {lab=VDD}
N 0 -220 30 -220 {lab=VDD}
N 0 -180 30 -180 {lab=VSS}
N -230 50 -230 80 {lab=GND}
N -100 50 -100 80 {lab=GND}
N -230 -60 -230 -10 {lab=vinn}
N -100 -60 -100 -10 {lab=vinp}
N -340 -180 -290 -180 {lab=vinn}
N -350 -160 -300 -160 {lab=vinp}
N 0 -200 30 -200 {lab=#net1}
N -780 -50 -780 0 {lab=bias1}
N -780 60 -780 90 {lab=GND}
C {vsource.sym} -840 30 0 0 {name=V1 value=PAR_bias1 savecurrent=false}
C {vsource.sym} -630 30 0 0 {name=V2 value=PAR_bias2 savecurrent=false}
C {vsource.sym} -510 30 0 0 {name=V3 value=PAR_bias3 savecurrent=false}
C {vsource.sym} -380 30 0 0 {name=V4 value=PAR_bias4 savecurrent=false}
C {lab_pin.sym} -340 -220 0 0 {name=p1 sig_type=std_logic lab=bias1}
C {lab_pin.sym} -340 -200 0 0 {name=p2 sig_type=std_logic lab=bias2}
C {lab_pin.sym} -340 -140 0 0 {name=p3 sig_type=std_logic lab=bias3}
C {lab_pin.sym} -340 -120 0 0 {name=p4 sig_type=std_logic lab=bias4}
C {lab_pin.sym} -780 -40 0 0 {name=p5 sig_type=std_logic lab=bias1}
C {lab_pin.sym} -630 -40 0 0 {name=p6 sig_type=std_logic lab=bias2}
C {lab_pin.sym} -510 -40 0 0 {name=p7 sig_type=std_logic lab=bias3}
C {lab_pin.sym} -380 -40 0 0 {name=p8 sig_type=std_logic lab=bias4}
C {gnd.sym} -780 90 0 0 {name=l1 lab=GND}
C {gnd.sym} -630 90 0 0 {name=l2 lab=GND}
C {gnd.sym} -510 90 0 0 {name=l3 lab=GND}
C {gnd.sym} -380 90 0 0 {name=l4 lab=GND}
C {vsource.sym} -690 -210 0 0 {name=V5 value=5V savecurrent=false}
C {vsource.sym} -600 -210 0 0 {name=V6 value=0V savecurrent=false}
C {lab_pin.sym} 30 -220 2 0 {name=p9 sig_type=std_logic lab=VDD}
C {lab_pin.sym} 30 -180 2 0 {name=p10 sig_type=std_logic lab=VSS}
C {gnd.sym} -600 -150 0 0 {name=l5 lab=GND}
C {gnd.sym} -690 -150 0 0 {name=l6 lab=GND}
C {lab_pin.sym} -600 -270 2 0 {name=p11 sig_type=std_logic lab=VSS}
C {lab_pin.sym} -690 -270 2 0 {name=p12 sig_type=std_logic lab=VDD}
C {vsource.sym} -230 20 0 0 {name=V8 value=PAR_vinn savecurrent=false}
C {vsource.sym} -100 20 0 0 {name=V9 value=PAR_vinp savecurrent=false}
C {gnd.sym} -230 80 0 0 {name=l7 lab=GND}
C {gnd.sym} -100 80 0 0 {name=l8 lab=GND}
C {lab_pin.sym} -230 -50 0 0 {name=p13 sig_type=std_logic lab=vinn}
C {lab_pin.sym} -100 -50 0 0 {name=p14 sig_type=std_logic lab=vinp}
C {lab_pin.sym} -340 -180 0 0 {name=p15 sig_type=std_logic lab=vinn}
C {lab_pin.sym} -350 -160 0 0 {name=p16 sig_type=std_logic lab=vinp}
C {code_shown.sym} -950 -480 0 0 {name=MODELS only_toplevel=false value=".include /foss/pdks/gf180mcuD/libs.tech/ngspice/design.ngspice
.lib /foss/pdks/gf180mcuD/libs.tech/ngspice/sm141064.ngspice typical
.lib /foss/pdks/gf180mcuD/libs.tech/ngspice/smbb000149.ngspice typical
.lib /foss/pdks/gf180mcuD/libs.tech/ngspice/sm141064.ngspice cap_mim
.lib /foss/pdks/gf180mcuD/libs.tech/ngspice/sm141064.ngspice mimcap_typical"}
C {code_shown.sym} 80 -520 0 0 {name=NGSPICE only_toplevel=false value="** PARAMETERS
.PARAM PAR_bias1=3.425
.PARAM PAR_bias2=3.425
.PARAM PAR_bias3=3.425
.PARAM PAR_bias4=3.425
.PARAM PAR_vinn=2.5
.PARAM PAR_vinp=2.5

.control
  * clear the results file and write a header row
  echo \\"# bias1 bias2 bias3 bias4 gain\\" > /foss/designs/sscs-2026-zotnetic/activities/opamp2AKAM/simulations_testbench/simulation_results/gain10.txt

  * ---- OUTER LOOP: try many bias combinations ----
  * nominal point is 3.425 / 2.428 / 1.909 / 1.209.
  * (the +0.001 on each limit dodges float-rounding overshoot)
  let b1 = 4.55
  let b2 = 4.5

  *while b2 <= 5.001
      let b3 = 0.27
      while b3 >= 0.19
        let b4 = 0.2
        while b4 >= 0.15

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
          echo \\"$&b1 $&b2 $&b3 $&b4 $&gain\\" >> /foss/designs/sscs-2026-zotnetic/activities/opamp2AKAM/simulations_testbench/simulation_results/gain10.txt

          let b4 = b4 -0.01
        end
        let b3 = b3 -0.01
    end
    *let b2 = b2 + 0.05
  *end

  echo \\"DONE - results in gain10.txt\\"
.endc"

}
C {/foss/designs/sscs-2026-zotnetic/activities/opamp2AKAM/opamp.sym} -150 -170 0 0 {name=x1}
