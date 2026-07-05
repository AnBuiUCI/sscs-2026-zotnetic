v {xschem version=3.4.7 file_version=1.2}
G {}
K {}
V {}
S {}
E {}
N 30 -160 70 -160 {lab=bias1}
N 30 -140 70 -140 {lab=bias2}
N 30 -80 70 -80 {lab=bias3}
N 30 -60 70 -60 {lab=bias4}
N -470 60 -410 60 {lab=bias1}
N -260 10 -260 60 {lab=bias2}
N -140 10 -140 60 {lab=bias3}
N -10 10 -10 60 {lab=bias4}
N -470 120 -410 120 {lab=GND}
N -260 120 -260 150 {lab=GND}
N -140 120 -140 150 {lab=GND}
N -10 120 -10 150 {lab=GND}
N -230 -120 -230 -90 {lab=GND}
N -320 -120 -320 -90 {lab=GND}
N -230 -220 -230 -180 {lab=VSS}
N -320 -220 -320 -180 {lab=VDD}
N 370 -160 400 -160 {lab=VDD}
N 370 -120 400 -120 {lab=VSS}
N 140 110 140 140 {lab=GND}
N 270 110 270 140 {lab=GND}
N 140 0 140 50 {lab=vinn}
N 270 0 270 50 {lab=vinp}
N 30 -120 80 -120 {lab=vinn}
N 20 -100 70 -100 {lab=vinp}
N 370 -140 400 -140 {lab=#net1}
N -410 10 -410 60 {lab=bias1}
N -410 120 -410 150 {lab=GND}
C {vsource.sym} -470 90 0 0 {name=V1 value=PAR_bias1 savecurrent=false}
C {vsource.sym} -260 90 0 0 {name=V2 value=PAR_bias2 savecurrent=false}
C {vsource.sym} -140 90 0 0 {name=V3 value=PAR_bias3 savecurrent=false}
C {vsource.sym} -10 90 0 0 {name=V4 value=PAR_bias4 savecurrent=false}
C {lab_pin.sym} 30 -160 0 0 {name=p1 sig_type=std_logic lab=bias1}
C {lab_pin.sym} 30 -140 0 0 {name=p2 sig_type=std_logic lab=bias2}
C {lab_pin.sym} 30 -80 0 0 {name=p3 sig_type=std_logic lab=bias3}
C {lab_pin.sym} 30 -60 0 0 {name=p4 sig_type=std_logic lab=bias4}
C {lab_pin.sym} -410 20 0 0 {name=p5 sig_type=std_logic lab=bias1}
C {lab_pin.sym} -260 20 0 0 {name=p6 sig_type=std_logic lab=bias2}
C {lab_pin.sym} -140 20 0 0 {name=p7 sig_type=std_logic lab=bias3}
C {lab_pin.sym} -10 20 0 0 {name=p8 sig_type=std_logic lab=bias4}
C {gnd.sym} -410 150 0 0 {name=l1 lab=GND}
C {gnd.sym} -260 150 0 0 {name=l2 lab=GND}
C {gnd.sym} -140 150 0 0 {name=l3 lab=GND}
C {gnd.sym} -10 150 0 0 {name=l4 lab=GND}
C {vsource.sym} -320 -150 0 0 {name=V5 value=5V savecurrent=false}
C {vsource.sym} -230 -150 0 0 {name=V6 value=0V savecurrent=false}
C {lab_pin.sym} 400 -160 2 0 {name=p9 sig_type=std_logic lab=VDD}
C {lab_pin.sym} 400 -120 2 0 {name=p10 sig_type=std_logic lab=VSS}
C {gnd.sym} -230 -90 0 0 {name=l5 lab=GND}
C {gnd.sym} -320 -90 0 0 {name=l6 lab=GND}
C {lab_pin.sym} -230 -210 2 0 {name=p11 sig_type=std_logic lab=VSS}
C {lab_pin.sym} -320 -210 2 0 {name=p12 sig_type=std_logic lab=VDD}
C {vsource.sym} 140 80 0 0 {name=V8 value=PAR_vinn savecurrent=false}
C {vsource.sym} 270 80 0 0 {name=V9 value=PAR_vinp savecurrent=false}
C {gnd.sym} 140 140 0 0 {name=l7 lab=GND}
C {gnd.sym} 270 140 0 0 {name=l8 lab=GND}
C {lab_pin.sym} 140 10 0 0 {name=p13 sig_type=std_logic lab=vinn}
C {lab_pin.sym} 270 10 0 0 {name=p14 sig_type=std_logic lab=vinp}
C {lab_pin.sym} 30 -120 0 0 {name=p15 sig_type=std_logic lab=vinn}
C {lab_pin.sym} 20 -100 0 0 {name=p16 sig_type=std_logic lab=vinp}
C {code_shown.sym} -570 -320 0 0 {name=MODELS only_toplevel=false value=".include /foss/pdks/gf180mcuD/libs.tech/ngspice/design.ngspice
.lib /foss/pdks/gf180mcuD/libs.tech/ngspice/sm141064.ngspice typical
.lib /foss/pdks/gf180mcuD/libs.tech/ngspice/smbb000149.ngspice typical
.lib /foss/pdks/gf180mcuD/libs.tech/ngspice/sm141064_mim.ngspice typical"}
C {sscs-2026-zotnetic/activities/opamp2AKAM/opamp.sym} 220 -110 0 0 {name=x1}
C {code_shown.sym} 450 -450 0 0 {name=NGSPICE only_toplevel=false value="** PARAMETERS
.PARAM PAR_bias1=3.425
.PARAM PAR_bias2=3.425
.PARAM PAR_bias3=3.425
.PARAM PAR_bias4=3.425
.PARAM PAR_vinn=2.5
.PARAM PAR_vinp=2.5

.control
* clear the results file and write a header row
  echo "# bias1 bias2 bias3 bias4 gain" > sweep_results.txt

  * ---- OUTER LOOP: try many bias combinations ----
  * nominal point is 3.425 / 2.428 / 1.909 / 1.209.
  * (the +0.001 on each limit dodges float-rounding overshoot)
  let b1 = 3.0
  while b1 <= 3.801
    let b2 = 2.2
    while b2 <= 2.601
      let b3 = 1.7
      while b3 <= 2.101
        let b4 = 1.0
        while b4 <= 1.401

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
          echo "$&b1 $&b2 $&b3 $&b4 $&gain" >> sweep_results.txt

          let b4 = b4 + 0.2
        end
        let b3 = b3 + 0.2
      end
      let b2 = b2 + 0.2
    end
    let b1 = b1 + 0.2
  end

  echo "DONE - results in sweep_results.txt"
.endc
}
