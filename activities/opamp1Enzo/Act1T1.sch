v {xschem version=3.4.7 file_version=1.2}
G {}
K {}
V {}
S {}
E {}
N -540 0 -540 20 {
lab=GND}
N -540 -120 -540 -60 {
lab=VDD}
N -440 -130 -440 -70 {
lab=VP}
N -440 10 -440 30 {
lab=GND}
N -360 -120 -360 -60 {lab=VN}
N -280 -120 -280 -60 {lab=BIAS_DIFF}
N -360 0 -360 40 {lab=GND}
N -440 -70 -440 -50 {lab=VP}
N -110 -120 -110 -50 {lab=OUT}
N -110 10 -110 30 {lab=0}
N -280 -260 -280 -180 {lab=VDD}
N -180 10 -180 70 {lab=BIAS_CS}
N -180 -130 -180 -50 {lab=VDD}
C {devices/vsource.sym} -540 -30 0 0 {name=V1 value=5
}
C {devices/gnd.sym} -540 20 0 0 {name=l1 lab=GND
value=5}
C {devices/lab_wire.sym} -540 -100 0 0 {name=p7 sig_type=std_logic lab=VDD}
C {devices/code_shown.sym} 115 105 0 0 {name=s1
only_toplevel=false
value="
*.tran 10p 0.3u
.dc V2 0 5 0.001
.save all
.control
run
display
plot v(VP) v(VN) v(OUT) v(BIAS_CS) v(BIAS_DIFF)
* 1. Calculate the derivative (slope) across the sweep
  let derivative = deriv(v(OUT))
  
  * 2. Find the maximum open-loop gain (V/V)
  meas dc max_gain max derivative
  
  * 3. Convert that maximum gain into decibels (dB)
  *let max_gain_db = 20 * log10(abs(max_gain))
  
  * 4. WRITE TO TEXT FILE
  * This creates (or overwrites) a file named 'gain_report.txt' in your current folder
  print max_gain > /foss/designs/sscs-2026-zotnetic/activities/opamp1Enzo/Sim_results1/Act1T1_results.txt
  
  * (Optional) If you want to APPEND to the file instead of overwriting it 
  * every time you run a new simulation, use '>>' like this:
  * print max_gain max_gain_db >> gain_history.txt
.endc
"}
C {devices/code_shown.sym} 25 -115 0 0 {name=MODELS1 only_toplevel=false
value="
.include /foss/pdks/gf180mcuD/libs.tech/ngspice/design.ngspice
.lib /foss/pdks/gf180mcuD/libs.tech/ngspice/sm141064.ngspice typical
.lib /foss/pdks/gf180mcuD/libs.tech/ngspice/smbb000149.ngspice typical
.lib /foss/pdks/gf180mcuD/libs.tech/ngspice/sm141064.ngspice cap_mim
.lib /foss/pdks/gf180mcuD/libs.tech/ngspice/sm141064.ngspice mimcap_typical
.options scale=1u
"}
C {devices/lab_wire.sym} -440 -100 0 0 {name=p5 sig_type=std_logic lab=VP
}
C {devices/gnd.sym} -440 30 0 0 {name=l2 lab=GND
value=5}
C {devices/code_shown.sym} -640 400 0 0 {name=DUT only_toplevel=true
format="tcleval( @value )"
value="
.include "/foss/designs/sscs-2026-zotnetic/designs/notebooks/opamp.spice"
XOPAMP VDD GND BIAS_DIFF VP VN BIAS_CS OUT OPAMP_TWO_STAGE"}
C {devices/vsource.sym} -440 -20 0 0 {name=V2 value=2.5
}
C {devices/vsource.sym} -360 -30 0 0 {name=V3 value=2.5
}
C {devices/gnd.sym} -360 40 0 0 {name=l3 lab=GND
value=5}
C {devices/lab_wire.sym} -360 -110 0 0 {name=p1 sig_type=std_logic lab=VN
}
C {devices/lab_wire.sym} -280 -100 0 0 {name=p2 sig_type=std_logic lab=BIAS_DIFF
}
C {devices/lab_wire.sym} -110 -100 0 0 {name=p4 sig_type=std_logic lab=OUT
}
C {gnd.sym} -110 30 0 0 {name=l6 lab=0}
C {capa.sym} -110 -20 0 0 {name=C1
m=1
value=1p
footprint=1206
device="ceramic capacitor"}
C {isource.sym} -280 -150 0 0 {name=I0 value=10u}
C {devices/lab_wire.sym} -280 -240 0 0 {name=p3 sig_type=std_logic lab=VDD}
C {devices/lab_wire.sym} -180 30 0 0 {name=p6 sig_type=std_logic lab=BIAS_CS
}
C {isource.sym} -180 -20 0 0 {name=I1 value=10u}
C {devices/lab_wire.sym} -180 -110 0 0 {name=p8 sig_type=std_logic lab=VDD}
