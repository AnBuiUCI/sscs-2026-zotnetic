v {xschem version=3.4.8RC file_version=1.3}
G {}
K {}
V {}
S {}
F {}
E {}
T {THE 1 kOHM SHEET, AND WHY THE RESISTOR DID NOT GROW.
This shuttle only offers the 1 kohm HRES implant (ppolyf_u_1k), not the 3 kohm
one. In the PDK's LVS deck the three values are a SWITCH, not a drawing --
`case POLY_RES when '1k'` over the same RES_MK on the same poly -- so the same
382 squares that were 1.147 Mohm are 382 kohm here. No polygon changes; the
GAIN does, from 103 to 33 V/V, because this stage's gain is Gm x RFB.
Tripling the drawn resistor would have meant 15 strips instead of 5, +22.5 um
of channel and a cell 47 % bigger, twelve times over. So the factor of three
was bought back in the transistors instead:
  M21 1u -> 7.5u, M22 1u -> 8.5u   the nfet pair carries the transconductance,
                                   and its asymmetry rebuilds the positive
                                   offset that M15/M16 used to set
  M29, M30 5u -> 10u               THE ONE THAT FIXES LINEARITY. With RFB
                                   divided by three the summing node G_OUT_P
                                   is asked for three times the current, and
                                   the cascode was what ran out: INL 0.53 %
                                   without this, 0.38 % with it
  M43 0.5u -> 1.0u (m=4)           the top of the output swing: the last
                                   -12 mV of residual at OUT = 4 V
  C1, C3 4x25 -> 8x25 um           the Miller capacitors. GBW goes as Gm/Cc,
                                   so tripling Gm without touching them made
                                   the cell three times faster and cost 18 deg
                                   of phase margin in the worst corner. These
                                   cost NO silicon -- a MIM sits on Metal4/5,
                                   over everything else -- and they put it back
  M15 1.1u -> 0.55u, M16 -> 0.5u   the pfet pair no longer carries any
  M27, M28 2.5u -> 2u              transconductance, so narrowing it and the
  M32, M33 5u -> 4u                class-AB drivers gives back the 0.24 mW the
                                   changes above cost. Its mismatch matters
                                   less for the same reason, and the offset is
                                   now set by a pair 8x wider than the old one.
Measured against the cell it replaces: gain 103.3 vs 103.4 V/V, INL 0.10 vs
0.12 %, offset +20 vs +24 mV, 2.673 vs 2.550 mW -- and under the 2.753 mW of
the OPAMt this family is not allowed to exceed. Over 27 corners of process,
temperature and supply: gain 50.1 to 189.4 against 47.5 to 188.0, INL never
worse than 0.68 % against 3.10 %, phase margin never under 73.8 deg against
75.3. The INL is better in every single corner.} 110 -1180 0 0 0.4 0.4 {}
P 4 1 -800 -300 {}
N -580 -460 -560 -460 {
lab=VDD}
N -400 -460 -380 -460 {
lab=VDD}
N -580 -670 -580 -650 {
lab=VDD}
N -580 -620 -560 -620 {
lab=VDD}
N -620 -660 -620 -620 {
lab=#net1}
N 140 -200 140 -150 {
lab=VSS}
N 140 -200 160 -200 {
lab=VSS}
N 160 -170 160 -150 {
lab=VSS}
N 160 -670 160 -650 {
lab=VDD}
N 140 -620 160 -620 {
lab=VDD}
N 400 -670 400 -650 {
lab=VDD}
N 400 -620 420 -620 {
lab=VDD}
N 420 -620 420 -520 {
lab=VDD}
N 400 -200 420 -200 {
lab=VSS}
N 400 -170 400 -150 {
lab=VSS}
N -620 -460 -620 -360 {
lab=INP}
N -10 -360 10 -360 {
lab=VSS}
N -190 -300 -170 -300 {
lab=VSS}
N -170 -200 -170 -150 {
lab=VSS}
N -190 -200 -170 -200 {
lab=VSS}
N -190 -270 -190 -230 {
lab=#net2}
N -190 -170 -190 -150 {
lab=VSS}
N -230 -200 -230 -160 {
lab=#net3}
N -230 -300 -230 -240 {
lab=#net4}
N -580 -520 -560 -520 {
lab=VDD}
N -580 -590 -580 -550 {
lab=#net5}
N -620 -580 -620 -520 {
lab=#net6}
N 140 -620 140 -520 {
lab=VDD}
N 140 -520 160 -520 {
lab=VDD}
N 160 -560 160 -550 {
lab=#net7}
N 140 -300 160 -300 {
lab=VSS}
N 140 -300 140 -200 {
lab=VSS}
N 160 -260 160 -230 {
lab=#net8}
N 400 -250 400 -230 {
lab=#net9}
N 400 -300 420 -300 {
lab=VSS}
N -340 -460 50 -460 {
lab=INN}
N 50 -460 50 -360 {
lab=INN}
N 400 -520 420 -520 {
lab=VDD}
N 400 -570 400 -550 {
lab=#net10}
N -580 -490 -380 -490 {
lab=#net11}
N -620 -360 -230 -360 {
lab=INP}
N -190 -330 10 -330 {
lab=#net12}
N 160 -490 160 -480 {
lab=#net13}
N 140 -450 160 -450 {
lab=VDD}
N 140 -520 140 -450 {
lab=VDD}
N 220 -200 360 -200 {
lab=#net14}
N 420 -200 420 -150 {
lab=VSS}
N 260 -370 300 -370 {
lab=#net15}
N 400 -450 420 -450 {
lab=VDD}
N 420 -520 420 -450 {
lab=VDD}
N 400 -490 400 -480 {
lab=#net16}
N 340 -370 420 -370 {
lab=VSS}
N 420 -370 420 -300 {
lab=VSS}
N 890 -410 890 -360 {
lab=OUT}
N 890 -490 910 -490 {
lab=VDD}
N 910 -670 910 -490 {
lab=VDD}
N 570 -670 700 -670 {
lab=VDD}
N 890 -330 910 -330 {
lab=VSS}
N 910 -330 910 -150 {
lab=VSS}
N 890 -300 890 -150 {
lab=VSS}
N 890 -670 890 -520 {
lab=VDD}
N 550 -620 570 -620 {
lab=VDD}
N 550 -670 550 -620 {
lab=VDD}
N 570 -670 570 -650 {
lab=VDD}
N 570 -590 570 -550 {
lab=#net17}
N 550 -520 570 -520 {
lab=VDD}
N 550 -620 550 -520 {
lab=VDD}
N 570 -490 570 -480 {
lab=#net18}
N 550 -450 570 -450 {
lab=VDD}
N 550 -520 550 -450 {
lab=VDD}
N 550 -300 570 -300 {
lab=VSS}
N 550 -200 550 -150 {
lab=VSS}
N 550 -200 570 -200 {
lab=VSS}
N 570 -270 570 -230 {
lab=#net19}
N 570 -170 570 -150 {
lab=VSS}
N 610 -200 610 -160 {
lab=#net3}
N 610 -300 610 -240 {
lab=#net4}
N 700 -620 720 -620 {
lab=VDD}
N 700 -670 700 -620 {
lab=VDD}
N 720 -670 720 -650 {
lab=VDD}
N 720 -590 720 -550 {
lab=#net20}
N 700 -520 720 -520 {
lab=VDD}
N 700 -620 700 -520 {
lab=VDD}
N 700 -300 720 -300 {
lab=VSS}
N 700 -200 700 -150 {
lab=VSS}
N 700 -200 720 -200 {
lab=VSS}
N 720 -270 720 -230 {
lab=#net21}
N 720 -170 720 -150 {
lab=VSS}
N 720 -340 720 -330 {
lab=#net22}
N 700 -370 720 -370 {
lab=VSS}
N 700 -370 700 -300 {
lab=VSS}
N 720 -670 890 -670 {
lab=VDD}
N -380 -670 -380 -650 {
lab=VDD}
N -400 -620 -380 -620 {
lab=VDD}
N -340 -660 -340 -620 {
lab=#net1}
N -400 -520 -380 -520 {
lab=VDD}
N -380 -590 -380 -550 {
lab=#net23}
N -340 -580 -340 -520 {
lab=#net6}
N -10 -300 10 -300 {
lab=VSS}
N -10 -200 10 -200 {
lab=VSS}
N 10 -270 10 -230 {
lab=#net24}
N 10 -170 10 -150 {
lab=VSS}
N 50 -200 50 -160 {
lab=#net3}
N 50 -300 50 -240 {
lab=#net4}
N -190 -360 -170 -360 {
lab=VSS}
N 610 -580 610 -520 {
lab=#net6}
N 610 -620 630 -620 {
lab=#net18}
N 630 -620 630 -490 {
lab=#net18}
N 570 -490 630 -490 {
lab=#net18}
N 610 -440 610 -420 {
lab=#net25}
N 570 -420 610 -420 {
lab=#net25}
N 570 -420 570 -330 {
lab=#net25}
N 760 -660 760 -620 {
lab=#net1}
N 760 -580 760 -520 {
lab=#net6}
N 360 -240 610 -240 {
lab=#net4}
N 760 -300 760 -240 {
lab=#net4}
N 760 -200 780 -200 {
lab=#net22}
N 780 -330 780 -200 {
lab=#net22}
N 720 -330 780 -330 {
lab=#net22}
N 760 -380 760 -370 {
lab=#net15}
N 720 -400 760 -400 {
lab=#net15}
N 720 -490 720 -400 {
lab=#net15}
N 220 -620 360 -620 {
lab=#net13}
N 200 -580 200 -520 {
lab=#net6}
N 360 -580 360 -520 {
lab=#net6}
N 200 -450 360 -450 {
lab=#net25}
N 160 -420 160 -330 {
lab=#net14}
N 220 -340 220 -330 {
lab=#net14}
N 160 -330 220 -330 {
lab=#net14}
N 340 -340 340 -330 {
lab=#net26}
N 340 -330 400 -330 {
lab=#net26}
N 140 -370 220 -370 {
lab=VSS}
N 140 -370 140 -300 {
lab=VSS}
N 400 -420 400 -330 {
lab=#net26}
N 220 -480 220 -400 {
lab=#net13}
N 160 -480 220 -480 {
lab=#net13}
N 340 -480 340 -400 {
lab=#net16}
N 340 -480 400 -480 {
lab=#net16}
N 610 -580 760 -580 {
lab=#net6}
N 50 -160 610 -160 {
lab=#net3}
N 610 -240 760 -240 {
lab=#net4}
N 360 -440 610 -440 {
lab=#net25}
N 360 -450 360 -440 {
lab=#net25}
N 300 -380 760 -380 {
lab=#net15}
N 300 -380 300 -370 {
lab=#net15}
N -580 -430 -580 -250 {
lab=#net9}
N -380 -430 -380 -260 {
lab=#net8}
N -190 -570 -190 -390 {
lab=#net10}
N 10 -560 10 -390 {
lab=#net7}
N 200 -300 200 -240 {
lab=#net4}
N 360 -300 360 -240 {
lab=#net4}
N 220 -330 220 -200 {
lab=#net14}
N 220 -620 220 -480 {
lab=#net13}
N 890 -670 910 -670 {
lab=VDD}
N 830 -490 850 -490 {
lab=#net16}
N 830 -690 830 -490 {
lab=#net16}
N 460 -690 830 -690 {
lab=#net16}
N 460 -690 460 -490 {
lab=#net16}
N 400 -490 460 -490 {
lab=#net16}
N 830 -330 850 -330 {
lab=#net26}
N 830 -330 830 -130 {
lab=#net26}
N 460 -130 830 -130 {
lab=#net26}
N 460 -330 460 -130 {
lab=#net26}
N 400 -330 460 -330 {
lab=#net26}
N 400 -250 800 -250 {
lab=#net9}
N 800 -410 800 -390 {
lab=OUT}
N -190 -570 400 -570 {
lab=#net10}
N 10 -560 160 -560 {
lab=#net7}
N -380 -260 160 -260 {
lab=#net8}
N -580 -250 400 -250 {
lab=#net9}
N 140 -670 160 -670 {
lab=VDD}
N 400 -670 420 -670 {
lab=VDD}
N 890 -150 910 -150 {
lab=VSS}
N -230 -240 50 -240 {
lab=#net4}
N -230 -160 50 -160 {
lab=#net3}
N -620 -660 -340 -660 {
lab=#net1}
N -620 -580 -340 -580 {
lab=#net6}
N 360 -580 610 -580 {
lab=#net6}
N -340 -660 760 -660 {
lab=#net1}
N -400 -670 -380 -670 {
lab=VDD}
N -770 -660 -620 -660 {
lab=#net1}
N -770 -580 -620 -580 {
lab=#net6}
N -770 -240 -230 -240 {
lab=#net4}
N -750 -160 -230 -160 {
lab=#net3}
N 800 -410 890 -410 {
lab=OUT}
N 800 -330 800 -250 {
lab=#net9}
N 400 -570 800 -570 {
lab=#net10}
N 800 -570 800 -490 {
lab=#net10}
N 800 -430 800 -410 {
lab=OUT}
N -400 -620 -400 -520 {
lab=VDD}
N -560 -620 -560 -520 {
lab=VDD}
N -10 -200 -10 -150 {
lab=VSS}
N -170 -360 -170 -300 {
lab=VSS}
N -10 -360 -10 -300 {
lab=VSS}
N -560 -520 -560 -460 {
lab=VDD}
N -400 -520 -400 -460 {
lab=VDD}
N -560 -670 -560 -620 {
lab=VDD}
N 10 -150 140 -150 {
lab=VSS}
N 140 -150 160 -150 {
lab=VSS}
N 140 -670 140 -620 {
lab=VDD}
N 160 -670 400 -670 {
lab=VDD}
N 420 -670 420 -620 {
lab=VDD}
N 420 -300 420 -200 {
lab=VSS}
N 160 -150 400 -150 {
lab=VSS}
N -190 -150 -170 -150 {
lab=VSS}
N -170 -300 -170 -200 {
lab=VSS}
N 400 -150 420 -150 {
lab=VSS}
N 720 -150 890 -150 {
lab=VSS}
N 420 -670 550 -670 {
lab=VDD}
N 550 -670 570 -670 {
lab=VDD}
N 420 -150 550 -150 {
lab=VSS}
N 550 -300 550 -200 {
lab=VSS}
N 550 -150 570 -150 {
lab=VSS}
N 700 -670 720 -670 {
lab=VDD}
N 570 -150 700 -150 {
lab=VSS}
N 700 -300 700 -200 {
lab=VSS}
N 700 -150 720 -150 {
lab=VSS}
N -400 -670 -400 -620 {
lab=VDD}
N -10 -300 -10 -200 {
lab=VSS}
N -10 -150 10 -150 {
lab=VSS}
N -340 -580 200 -580 {
lab=#net6}
N 200 -580 360 -580 {
lab=#net6}
N 610 -450 610 -440 {
lab=#net25}
N 760 -400 760 -380 {
lab=#net15}
N 50 -240 200 -240 {
lab=#net4}
N 200 -240 360 -240 {
lab=#net4}
N 200 -200 220 -200 {
lab=#net14}
N 200 -620 220 -620 {
lab=#net13}
N 400 -270 400 -250 {
lab=#net9}
N 400 -590 400 -570 {
lab=#net10}
N 160 -590 160 -560 {
lab=#net7}
N 160 -270 160 -260 {
lab=#net8}
N 890 -460 890 -410 {
lab=OUT}
N -170 -150 -10 -150 {
lab=VSS}
N -580 -670 -560 -670 {
lab=VDD}
N -380 -670 140 -670 {
lab=VDD}
N -560 -670 -400 -670 {
lab=VDD}
N -910 -280 -890 -280 {
lab=VSS}
N -910 -200 -910 -150 {
lab=VSS}
N -910 -200 -890 -200 {
lab=VSS}
N -890 -250 -890 -230 {
lab=#net27}
N -890 -170 -890 -150 {
lab=VSS}
N -890 -670 -890 -650 {
lab=VDD}
N -910 -620 -890 -620 {
lab=VDD}
N -910 -540 -890 -540 {
lab=VDD}
N -910 -620 -910 -540 {
lab=VDD}
N -890 -590 -890 -570 {
lab=#net28}
N -850 -580 -850 -540 {
lab=#net6}
N -850 -660 -850 -620 {
lab=#net1}
N -1050 -670 -1050 -650 {
lab=VDD}
N -1070 -620 -1050 -620 {
lab=VDD}
N -1070 -540 -1050 -540 {
lab=VDD}
N -1070 -620 -1070 -540 {
lab=VDD}
N -1050 -590 -1050 -570 {
lab=#net29}
N -1010 -580 -1010 -540 {
lab=#net6}
N -1010 -660 -1010 -620 {
lab=#net1}
N -1070 -280 -1050 -280 {
lab=VSS}
N -1070 -280 -1070 -150 {
lab=VSS}
N -1050 -250 -1050 -150 {
lab=VSS}
N -1010 -280 -1010 -240 {
lab=#net4}
N -1010 -240 -990 -240 {
lab=#net4}
N -1050 -350 -990 -350 {
lab=#net4}
N -850 -280 -850 -240 {
lab=#net4}
N -850 -200 -850 -160 {
lab=#net3}
N -850 -160 -830 -160 {
lab=#net3}
N -990 -240 -850 -240 {
lab=#net4}
N -890 -370 -830 -370 {
lab=#net3}
N -1050 -510 -1050 -350 {
lab=#net4}
N -890 -510 -890 -370 {
lab=#net3}
N -990 -350 -990 -240 {
lab=#net4}
N -830 -370 -830 -160 {
lab=#net3}
N -890 -370 -890 -310 {
lab=#net3}
N -1050 -350 -1050 -310 {
lab=#net4}
N -850 -660 -700 -660 {
lab=#net1}
N -850 -580 -700 -580 {
lab=#net6}
N -1230 -150 -1070 -150 {
lab=VSS}
N -1230 -670 -1230 -650 {
lab=VDD}
N -1250 -620 -1230 -620 {
lab=VDD}
N -1250 -540 -1230 -540 {
lab=VDD}
N -1250 -620 -1250 -540 {
lab=VDD}
N -1230 -590 -1230 -570 {
lab=#net30}
N -1190 -580 -1190 -540 {
lab=#net6}
N -1190 -660 -1190 -620 {
lab=#net1}
N -1230 -470 -1170 -470 {
lab=#net1}
N -1230 -470 -1230 -330 {
lab=#net1}
N -1370 -670 -1370 -570 {
lab=VDD}
N -1390 -540 -1370 -540 {
lab=VDD}
N -1390 -670 -1390 -540 {
lab=VDD}
N -1310 -580 -1190 -580 {
lab=#net6}
N -1330 -580 -1330 -540 {
lab=#net6}
N -1370 -470 -1310 -470 {
lab=#net6}
N -1370 -470 -1370 -330 {
lab=#net6}
N -1370 -510 -1370 -470 {
lab=#net6}
N -1230 -510 -1230 -470 {
lab=#net1}
N -1310 -580 -1310 -470 {
lab=#net6}
N -1170 -660 -1170 -470 {
lab=#net1}
N -1370 -210 -1370 -150 {
lab=VSS}
N -1230 -210 -1230 -150 {
lab=VSS}
N -1300 -240 -1270 -240 {
lab=#net6}
N -1390 -240 -1370 -240 {
lab=VSS}
N -1390 -240 -1390 -210 {
lab=VSS}
N -1390 -210 -1370 -210 {
lab=VSS}
N -1230 -240 -1210 -240 {
lab=VSS}
N -1210 -240 -1210 -210 {
lab=VSS}
N -1230 -210 -1210 -210 {
lab=VSS}
N -1300 -300 -1270 -300 {
lab=#net6}
N -1300 -300 -1300 -240 {
lab=#net6}
N -1390 -300 -1370 -300 {
lab=VSS}
N -1390 -300 -1390 -240 {
lab=VSS}
N -1230 -300 -1210 -300 {
lab=VSS}
N -1210 -300 -1210 -240 {
lab=VSS}
N -1300 -320 -1300 -300 {
lab=#net6}
N -1050 -150 -910 -150 {
lab=VSS}
N -910 -280 -910 -200 {
lab=VSS}
N -910 -150 -890 -150 {
lab=VSS}
N -910 -670 -890 -670 {
lab=VDD}
N -910 -670 -910 -620 {
lab=VDD}
N -1010 -580 -850 -580 {
lab=#net6}
N -1010 -660 -850 -660 {
lab=#net1}
N -1070 -670 -1050 -670 {
lab=VDD}
N -1070 -670 -1070 -620 {
lab=VDD}
N -1190 -580 -1010 -580 {
lab=#net6}
N -1170 -660 -1010 -660 {
lab=#net1}
N -1070 -150 -1050 -150 {
lab=VSS}
N -1250 -670 -1230 -670 {
lab=VDD}
N -1250 -670 -1250 -620 {
lab=VDD}
N -1390 -670 -1370 -670 {
lab=VDD}
N -1330 -580 -1310 -580 {
lab=#net6}
N -1190 -660 -1170 -660 {
lab=#net1}
N -1370 -150 -1230 -150 {
lab=VSS}
N -1330 -300 -1300 -300 {
lab=#net6}
N -1330 -240 -1300 -240 {
lab=#net6}
N -1050 -670 -910 -670 {
lab=VDD}
N -1230 -670 -1070 -670 {
lab=VDD}
N -1370 -670 -1250 -670 {
lab=VDD}
N -1370 -390 -1300 -390 {lab=#net6}
N -1300 -390 -1300 -320 {lab=#net6}
N -850 -240 -710 -240 {lab=#net4}
N -830 -160 -710 -160 {lab=#net3}
N -890 -670 -580 -670 {lab=VDD}
N -900 -150 -190 -150 {lab=VSS}
C {ipin.sym} 50 -400 2 0 {name=p1 lab=INN}
C {ipin.sym} -620 -400 0 0 {name=p2 lab=INP}
C {iopin.sym} 910 -670 0 0 {name=p3 lab=VDD}
C {iopin.sym} 910 -150 0 0 {name=p4 lab=VSS}
C {iopin.sym} 890 -410 0 0 {name=p5 lab=OUT}
C {symbols/pfet_06v0.sym} -600 -620 0 0 {name=M11
L=1.0u
W=10.0u
nf=1
m=1
ad="'int((nf+1)/2) * W/nf * 0.18u'"
pd="'2*int((nf+1)/2) * (W/nf + 0.18u)'"
as="'int((nf+2)/2) * W/nf * 0.18u'"
ps="'2*int((nf+2)/2) * (W/nf + 0.18u)'"
nrd="'0.18u / W'" nrs="'0.18u / W'"
sa=0 sb=0 sd=0
model=pfet_06v0
spiceprefix=X
}
C {symbols/pfet_06v0.sym} -600 -520 0 0 {name=M12
L=1.0u
W=10.0u
nf=1
m=1
ad="'int((nf+1)/2) * W/nf * 0.18u'"
pd="'2*int((nf+1)/2) * (W/nf + 0.18u)'"
as="'int((nf+2)/2) * W/nf * 0.18u'"
ps="'2*int((nf+2)/2) * (W/nf + 0.18u)'"
nrd="'0.18u / W'" nrs="'0.18u / W'"
sa=0 sb=0 sd=0
model=pfet_06v0
spiceprefix=X
}
C {symbols/pfet_06v0.sym} -360 -620 0 1 {name=M13
L=1.0u
W=10.0u
nf=1
m=1
ad="'int((nf+1)/2) * W/nf * 0.18u'"
pd="'2*int((nf+1)/2) * (W/nf + 0.18u)'"
as="'int((nf+2)/2) * W/nf * 0.18u'"
ps="'2*int((nf+2)/2) * (W/nf + 0.18u)'"
nrd="'0.18u / W'" nrs="'0.18u / W'"
sa=0 sb=0 sd=0
model=pfet_06v0
spiceprefix=X
}
C {symbols/pfet_06v0.sym} -360 -520 0 1 {name=M14
L=1.0u
W=10.0u
nf=1
m=1
ad="'int((nf+1)/2) * W/nf * 0.18u'"
pd="'2*int((nf+1)/2) * (W/nf + 0.18u)'"
as="'int((nf+2)/2) * W/nf * 0.18u'"
ps="'2*int((nf+2)/2) * (W/nf + 0.18u)'"
nrd="'0.18u / W'" nrs="'0.18u / W'"
sa=0 sb=0 sd=0
model=pfet_06v0
spiceprefix=X
}
C {symbols/pfet_06v0.sym} -600 -460 0 0 {name=M15
L=1.0u
W=0.55u
nf=1
m=1
ad="'int((nf+1)/2) * W/nf * 0.18u'"
pd="'2*int((nf+1)/2) * (W/nf + 0.18u)'"
as="'int((nf+2)/2) * W/nf * 0.18u'"
ps="'2*int((nf+2)/2) * (W/nf + 0.18u)'"
nrd="'0.18u / W'" nrs="'0.18u / W'"
sa=0 sb=0 sd=0
model=pfet_06v0
spiceprefix=X
}
C {symbols/pfet_06v0.sym} -360 -460 0 1 {name=M16
L=1.0u
W=0.5u
nf=1
m=1
ad="'int((nf+1)/2) * W/nf * 0.18u'"
pd="'2*int((nf+1)/2) * (W/nf + 0.18u)'"
as="'int((nf+2)/2) * W/nf * 0.18u'"
ps="'2*int((nf+2)/2) * (W/nf + 0.18u)'"
nrd="'0.18u / W'" nrs="'0.18u / W'"
sa=0 sb=0 sd=0
model=pfet_06v0
spiceprefix=X
}
C {symbols/nfet_06v0.sym} -210 -300 0 0 {name=M17
L=1.0u
W=5.0u
nf=1
m=1
ad="'int((nf+1)/2) * W/nf * 0.18u'"
pd="'2*int((nf+1)/2) * (W/nf + 0.18u)'"
as="'int((nf+2)/2) * W/nf * 0.18u'"
ps="'2*int((nf+2)/2) * (W/nf + 0.18u)'"
nrd="'0.18u / W'" nrs="'0.18u / W'"
sa=0 sb=0 sd=0
model=nfet_06v0
spiceprefix=X
}
C {symbols/nfet_06v0.sym} -210 -200 0 0 {name=M18
L=1.0u
W=5.0u
nf=1
m=1
ad="'int((nf+1)/2) * W/nf * 0.18u'"
pd="'2*int((nf+1)/2) * (W/nf + 0.18u)'"
as="'int((nf+2)/2) * W/nf * 0.18u'"
ps="'2*int((nf+2)/2) * (W/nf + 0.18u)'"
nrd="'0.18u / W'" nrs="'0.18u / W'"
sa=0 sb=0 sd=0
model=nfet_06v0
spiceprefix=X
}
C {symbols/nfet_06v0.sym} 30 -300 0 1 {name=M19
L=1.0u
W=5.0u
nf=1
m=1
ad="'int((nf+1)/2) * W/nf * 0.18u'"
pd="'2*int((nf+1)/2) * (W/nf + 0.18u)'"
as="'int((nf+2)/2) * W/nf * 0.18u'"
ps="'2*int((nf+2)/2) * (W/nf + 0.18u)'"
nrd="'0.18u / W'" nrs="'0.18u / W'"
sa=0 sb=0 sd=0
model=nfet_06v0
spiceprefix=X
}
C {symbols/nfet_06v0.sym} 30 -200 0 1 {name=M20
L=1.0u
W=5.0u
nf=1
m=1
ad="'int((nf+1)/2) * W/nf * 0.18u'"
pd="'2*int((nf+1)/2) * (W/nf + 0.18u)'"
as="'int((nf+2)/2) * W/nf * 0.18u'"
ps="'2*int((nf+2)/2) * (W/nf + 0.18u)'"
nrd="'0.18u / W'" nrs="'0.18u / W'"
sa=0 sb=0 sd=0
model=nfet_06v0
spiceprefix=X
}
C {symbols/nfet_06v0.sym} -210 -360 0 0 {name=M21
L=1.0u
W=7.5u
nf=1
m=1
ad="'int((nf+1)/2) * W/nf * 0.18u'"
pd="'2*int((nf+1)/2) * (W/nf + 0.18u)'"
as="'int((nf+2)/2) * W/nf * 0.18u'"
ps="'2*int((nf+2)/2) * (W/nf + 0.18u)'"
nrd="'0.18u / W'" nrs="'0.18u / W'"
sa=0 sb=0 sd=0
model=nfet_06v0
spiceprefix=X
}
C {symbols/nfet_06v0.sym} 30 -360 0 1 {name=M22
L=1.0u
W=8.5u
nf=1
m=1
ad="'int((nf+1)/2) * W/nf * 0.18u'"
pd="'2*int((nf+1)/2) * (W/nf + 0.18u)'"
as="'int((nf+2)/2) * W/nf * 0.18u'"
ps="'2*int((nf+2)/2) * (W/nf + 0.18u)'"
nrd="'0.18u / W'" nrs="'0.18u / W'"
sa=0 sb=0 sd=0
model=nfet_06v0
spiceprefix=X
}
C {symbols/pfet_06v0.sym} 180 -520 0 1 {name=M29
L=1.0u
W=10u
nf=1
m=1
ad="'int((nf+1)/2) * W/nf * 0.18u'"
pd="'2*int((nf+1)/2) * (W/nf + 0.18u)'"
as="'int((nf+2)/2) * W/nf * 0.18u'"
ps="'2*int((nf+2)/2) * (W/nf + 0.18u)'"
nrd="'0.18u / W'" nrs="'0.18u / W'"
sa=0 sb=0 sd=0
model=pfet_06v0
spiceprefix=X
}
C {symbols/pfet_06v0.sym} 380 -520 0 0 {name=M30
L=1.0u
W=10u
nf=1
m=1
ad="'int((nf+1)/2) * W/nf * 0.18u'"
pd="'2*int((nf+1)/2) * (W/nf + 0.18u)'"
as="'int((nf+2)/2) * W/nf * 0.18u'"
ps="'2*int((nf+2)/2) * (W/nf + 0.18u)'"
nrd="'0.18u / W'" nrs="'0.18u / W'"
sa=0 sb=0 sd=0
model=pfet_06v0
spiceprefix=X
}
C {symbols/pfet_06v0.sym} 180 -620 0 1 {name=M31
L=1.0u
W=5u
nf=1
m=1
ad="'int((nf+1)/2) * W/nf * 0.18u'"
pd="'2*int((nf+1)/2) * (W/nf + 0.18u)'"
as="'int((nf+2)/2) * W/nf * 0.18u'"
ps="'2*int((nf+2)/2) * (W/nf + 0.18u)'"
nrd="'0.18u / W'" nrs="'0.18u / W'"
sa=0 sb=0 sd=0
model=pfet_06v0
spiceprefix=X
}
C {symbols/pfet_06v0.sym} 380 -620 0 0 {name=M35
L=1.0u
W=5u
nf=1
m=1
ad="'int((nf+1)/2) * W/nf * 0.18u'"
pd="'2*int((nf+1)/2) * (W/nf + 0.18u)'"
as="'int((nf+2)/2) * W/nf * 0.18u'"
ps="'2*int((nf+2)/2) * (W/nf + 0.18u)'"
nrd="'0.18u / W'" nrs="'0.18u / W'"
sa=0 sb=0 sd=0
model=pfet_06v0
spiceprefix=X
}
C {symbols/pfet_06v0.sym} 180 -450 0 1 {name=M32
L=1.0u
W=4.0u
nf=1
m=1
ad="'int((nf+1)/2) * W/nf * 0.18u'"
pd="'2*int((nf+1)/2) * (W/nf + 0.18u)'"
as="'int((nf+2)/2) * W/nf * 0.18u'"
ps="'2*int((nf+2)/2) * (W/nf + 0.18u)'"
nrd="'0.18u / W'" nrs="'0.18u / W'"
sa=0 sb=0 sd=0
model=pfet_06v0
spiceprefix=X
}
C {symbols/pfet_06v0.sym} 380 -450 0 0 {name=M33
L=1.0u
W=4.0u
nf=1
m=1
ad="'int((nf+1)/2) * W/nf * 0.18u'"
pd="'2*int((nf+1)/2) * (W/nf + 0.18u)'"
as="'int((nf+2)/2) * W/nf * 0.18u'"
ps="'2*int((nf+2)/2) * (W/nf + 0.18u)'"
nrd="'0.18u / W'" nrs="'0.18u / W'"
sa=0 sb=0 sd=0
model=pfet_06v0
spiceprefix=X
}
C {symbols/nfet_06v0.sym} 180 -300 0 1 {name=M23
L=1.0u
W=2.5u
nf=1
m=1
ad="'int((nf+1)/2) * W/nf * 0.18u'"
pd="'2*int((nf+1)/2) * (W/nf + 0.18u)'"
as="'int((nf+2)/2) * W/nf * 0.18u'"
ps="'2*int((nf+2)/2) * (W/nf + 0.18u)'"
nrd="'0.18u / W'" nrs="'0.18u / W'"
sa=0 sb=0 sd=0
model=nfet_06v0
spiceprefix=X
}
C {symbols/nfet_06v0.sym} 380 -300 0 0 {name=M24
L=1.0u
W=2.5u
nf=1
m=1
ad="'int((nf+1)/2) * W/nf * 0.18u'"
pd="'2*int((nf+1)/2) * (W/nf + 0.18u)'"
as="'int((nf+2)/2) * W/nf * 0.18u'"
ps="'2*int((nf+2)/2) * (W/nf + 0.18u)'"
nrd="'0.18u / W'" nrs="'0.18u / W'"
sa=0 sb=0 sd=0
model=nfet_06v0
spiceprefix=X
}
C {symbols/nfet_06v0.sym} 180 -200 0 1 {name=M25
L=1.0u
W=2.5u
nf=1
m=1
ad="'int((nf+1)/2) * W/nf * 0.18u'"
pd="'2*int((nf+1)/2) * (W/nf + 0.18u)'"
as="'int((nf+2)/2) * W/nf * 0.18u'"
ps="'2*int((nf+2)/2) * (W/nf + 0.18u)'"
nrd="'0.18u / W'" nrs="'0.18u / W'"
sa=0 sb=0 sd=0
model=nfet_06v0
spiceprefix=X
}
C {symbols/nfet_06v0.sym} 380 -200 0 0 {name=M26
L=1.0u
W=2.5u
nf=1
m=1
ad="'int((nf+1)/2) * W/nf * 0.18u'"
pd="'2*int((nf+1)/2) * (W/nf + 0.18u)'"
as="'int((nf+2)/2) * W/nf * 0.18u'"
ps="'2*int((nf+2)/2) * (W/nf + 0.18u)'"
nrd="'0.18u / W'" nrs="'0.18u / W'"
sa=0 sb=0 sd=0
model=nfet_06v0
spiceprefix=X
}
C {symbols/nfet_06v0.sym} 240 -370 0 1 {name=M27
L=1.0u
W=2.0u
nf=1
m=1
ad="'int((nf+1)/2) * W/nf * 0.18u'"
pd="'2*int((nf+1)/2) * (W/nf + 0.18u)'"
as="'int((nf+2)/2) * W/nf * 0.18u'"
ps="'2*int((nf+2)/2) * (W/nf + 0.18u)'"
nrd="'0.18u / W'" nrs="'0.18u / W'"
sa=0 sb=0 sd=0
model=nfet_06v0
spiceprefix=X
}
C {symbols/nfet_06v0.sym} 320 -370 0 0 {name=M28
L=1.0u
W=2.0u
nf=1
m=1
ad="'int((nf+1)/2) * W/nf * 0.18u'"
pd="'2*int((nf+1)/2) * (W/nf + 0.18u)'"
as="'int((nf+2)/2) * W/nf * 0.18u'"
ps="'2*int((nf+2)/2) * (W/nf + 0.18u)'"
nrd="'0.18u / W'" nrs="'0.18u / W'"
sa=0 sb=0 sd=0
model=nfet_06v0
spiceprefix=X
}
C {symbols/pfet_06v0.sym} 590 -620 0 1 {name=M34
L=1.0u
W=10.0u
nf=1
m=1
ad="'int((nf+1)/2) * W/nf * 0.18u'"
pd="'2*int((nf+1)/2) * (W/nf + 0.18u)'"
as="'int((nf+2)/2) * W/nf * 0.18u'"
ps="'2*int((nf+2)/2) * (W/nf + 0.18u)'"
nrd="'0.18u / W'" nrs="'0.18u / W'"
sa=0 sb=0 sd=0
model=pfet_06v0
spiceprefix=X
}
C {symbols/pfet_06v0.sym} 590 -520 0 1 {name=M36
L=1.0u
W=10.0u
nf=1
m=1
ad="'int((nf+1)/2) * W/nf * 0.18u'"
pd="'2*int((nf+1)/2) * (W/nf + 0.18u)'"
as="'int((nf+2)/2) * W/nf * 0.18u'"
ps="'2*int((nf+2)/2) * (W/nf + 0.18u)'"
nrd="'0.18u / W'" nrs="'0.18u / W'"
sa=0 sb=0 sd=0
model=pfet_06v0
spiceprefix=X
}
C {symbols/pfet_06v0.sym} 590 -450 0 1 {name=M37
L=1.0u
W=10.0u
nf=1
m=1
ad="'int((nf+1)/2) * W/nf * 0.18u'"
pd="'2*int((nf+1)/2) * (W/nf + 0.18u)'"
as="'int((nf+2)/2) * W/nf * 0.18u'"
ps="'2*int((nf+2)/2) * (W/nf + 0.18u)'"
nrd="'0.18u / W'" nrs="'0.18u / W'"
sa=0 sb=0 sd=0
model=pfet_06v0
spiceprefix=X
}
C {symbols/nfet_06v0.sym} 590 -300 0 1 {name=M38
L=1.0u
W=5.0u
nf=1
m=1
ad="'int((nf+1)/2) * W/nf * 0.18u'"
pd="'2*int((nf+1)/2) * (W/nf + 0.18u)'"
as="'int((nf+2)/2) * W/nf * 0.18u'"
ps="'2*int((nf+2)/2) * (W/nf + 0.18u)'"
nrd="'0.18u / W'" nrs="'0.18u / W'"
sa=0 sb=0 sd=0
model=nfet_06v0
spiceprefix=X
}
C {symbols/nfet_06v0.sym} 590 -200 0 1 {name=M39
L=1.0u
W=5.0u
nf=1
m=1
ad="'int((nf+1)/2) * W/nf * 0.18u'"
pd="'2*int((nf+1)/2) * (W/nf + 0.18u)'"
as="'int((nf+2)/2) * W/nf * 0.18u'"
ps="'2*int((nf+2)/2) * (W/nf + 0.18u)'"
nrd="'0.18u / W'" nrs="'0.18u / W'"
sa=0 sb=0 sd=0
model=nfet_06v0
spiceprefix=X
}
C {symbols/pfet_06v0.sym} 740 -620 0 1 {name=M45
L=1.0u
W=10.0u
nf=1
m=1
ad="'int((nf+1)/2) * W/nf * 0.18u'"
pd="'2*int((nf+1)/2) * (W/nf + 0.18u)'"
as="'int((nf+2)/2) * W/nf * 0.18u'"
ps="'2*int((nf+2)/2) * (W/nf + 0.18u)'"
nrd="'0.18u / W'" nrs="'0.18u / W'"
sa=0 sb=0 sd=0
model=pfet_06v0
spiceprefix=X
}
C {symbols/pfet_06v0.sym} 740 -520 0 1 {name=M46
L=1.0u
W=10.0u
nf=1
m=1
ad="'int((nf+1)/2) * W/nf * 0.18u'"
pd="'2*int((nf+1)/2) * (W/nf + 0.18u)'"
as="'int((nf+2)/2) * W/nf * 0.18u'"
ps="'2*int((nf+2)/2) * (W/nf + 0.18u)'"
nrd="'0.18u / W'" nrs="'0.18u / W'"
sa=0 sb=0 sd=0
model=pfet_06v0
spiceprefix=X
}
C {symbols/nfet_06v0.sym} 740 -370 0 1 {name=M40
L=1.0u
W=5.0u
nf=1
m=1
ad="'int((nf+1)/2) * W/nf * 0.18u'"
pd="'2*int((nf+1)/2) * (W/nf + 0.18u)'"
as="'int((nf+2)/2) * W/nf * 0.18u'"
ps="'2*int((nf+2)/2) * (W/nf + 0.18u)'"
nrd="'0.18u / W'" nrs="'0.18u / W'"
sa=0 sb=0 sd=0
model=nfet_06v0
spiceprefix=X
}
C {symbols/nfet_06v0.sym} 740 -300 0 1 {name=M41
L=1.0u
W=5.0u
nf=1
m=1
ad="'int((nf+1)/2) * W/nf * 0.18u'"
pd="'2*int((nf+1)/2) * (W/nf + 0.18u)'"
as="'int((nf+2)/2) * W/nf * 0.18u'"
ps="'2*int((nf+2)/2) * (W/nf + 0.18u)'"
nrd="'0.18u / W'" nrs="'0.18u / W'"
sa=0 sb=0 sd=0
model=nfet_06v0
spiceprefix=X
}
C {symbols/nfet_06v0.sym} 740 -200 0 1 {name=M42
L=1.0u
W=5.0u
nf=1
m=1
ad="'int((nf+1)/2) * W/nf * 0.18u'"
pd="'2*int((nf+1)/2) * (W/nf + 0.18u)'"
as="'int((nf+2)/2) * W/nf * 0.18u'"
ps="'2*int((nf+2)/2) * (W/nf + 0.18u)'"
nrd="'0.18u / W'" nrs="'0.18u / W'"
sa=0 sb=0 sd=0
model=nfet_06v0
spiceprefix=X
}
C {symbols/pfet_06v0.sym} 870 -490 0 0 {name=M43
L=1.0u
W=1.0u
nf=1
m=4
ad="'int((nf+1)/2) * W/nf * 0.18u'"
pd="'2*int((nf+1)/2) * (W/nf + 0.18u)'"
as="'int((nf+2)/2) * W/nf * 0.18u'"
ps="'2*int((nf+2)/2) * (W/nf + 0.18u)'"
nrd="'0.18u / W'" nrs="'0.18u / W'"
sa=0 sb=0 sd=0
model=pfet_06v0
spiceprefix=X
}
C {symbols/nfet_06v0.sym} 870 -330 0 0 {name=M44
L=1.0u
W=1.0u
nf=1
m=1
ad="'int((nf+1)/2) * W/nf * 0.18u'"
pd="'2*int((nf+1)/2) * (W/nf + 0.18u)'"
as="'int((nf+2)/2) * W/nf * 0.18u'"
ps="'2*int((nf+2)/2) * (W/nf + 0.18u)'"
nrd="'0.18u / W'" nrs="'0.18u / W'"
sa=0 sb=0 sd=0
model=nfet_06v0
spiceprefix=X
}
C {symbols/cap_mim_2f0fF.sym} 800 -460 0 0 {name=C3
W=8e-6
L=25e-6
model=cap_mim_2f0fF
spiceprefix=X
m=1}
C {symbols/cap_mim_2f0fF.sym} 800 -360 0 0 {name=C1
W=8e-6
L=25e-6
model=cap_mim_2f0fF
spiceprefix=X
m=1}
C {symbols/pfet_06v0.sym} -1030 -620 0 1 {name=M4
L=1.0u
W=10.0u
nf=1
m=1
ad="'int((nf+1)/2) * W/nf * 0.18u'"
pd="'2*int((nf+1)/2) * (W/nf + 0.18u)'"
as="'int((nf+2)/2) * W/nf * 0.18u'"
ps="'2*int((nf+2)/2) * (W/nf + 0.18u)'"
nrd="'0.18u / W'" nrs="'0.18u / W'"
sa=0 sb=0 sd=0
model=pfet_06v0
spiceprefix=X
}
C {symbols/pfet_06v0.sym} -1030 -540 0 1 {name=M5
L=1.0u
W=10.0u
nf=1
m=1
ad="'int((nf+1)/2) * W/nf * 0.18u'"
pd="'2*int((nf+1)/2) * (W/nf + 0.18u)'"
as="'int((nf+2)/2) * W/nf * 0.18u'"
ps="'2*int((nf+2)/2) * (W/nf + 0.18u)'"
nrd="'0.18u / W'" nrs="'0.18u / W'"
sa=0 sb=0 sd=0
model=pfet_06v0
spiceprefix=X
}
C {symbols/nfet_06v0.sym} -1030 -280 0 1 {name=M6
L=1.0u
W=1.0u
nf=1
m=1
ad="'int((nf+1)/2) * W/nf * 0.18u'"
pd="'2*int((nf+1)/2) * (W/nf + 0.18u)'"
as="'int((nf+2)/2) * W/nf * 0.18u'"
ps="'2*int((nf+2)/2) * (W/nf + 0.18u)'"
nrd="'0.18u / W'" nrs="'0.18u / W'"
sa=0 sb=0 sd=0
model=nfet_06v0
spiceprefix=X
}
C {symbols/pfet_06v0.sym} -870 -620 0 1 {name=M7
L=1.0u
W=10.0u
nf=1
m=1
ad="'int((nf+1)/2) * W/nf * 0.18u'"
pd="'2*int((nf+1)/2) * (W/nf + 0.18u)'"
as="'int((nf+2)/2) * W/nf * 0.18u'"
ps="'2*int((nf+2)/2) * (W/nf + 0.18u)'"
nrd="'0.18u / W'" nrs="'0.18u / W'"
sa=0 sb=0 sd=0
model=pfet_06v0
spiceprefix=X
}
C {symbols/pfet_06v0.sym} -870 -540 0 1 {name=M8
L=1.0u
W=10.0u
nf=1
m=1
ad="'int((nf+1)/2) * W/nf * 0.18u'"
pd="'2*int((nf+1)/2) * (W/nf + 0.18u)'"
as="'int((nf+2)/2) * W/nf * 0.18u'"
ps="'2*int((nf+2)/2) * (W/nf + 0.18u)'"
nrd="'0.18u / W'" nrs="'0.18u / W'"
sa=0 sb=0 sd=0
model=pfet_06v0
spiceprefix=X
}
C {symbols/nfet_06v0.sym} -870 -280 0 1 {name=M9
L=1.0u
W=5.0u
nf=1
m=1
ad="'int((nf+1)/2) * W/nf * 0.18u'"
pd="'2*int((nf+1)/2) * (W/nf + 0.18u)'"
as="'int((nf+2)/2) * W/nf * 0.18u'"
ps="'2*int((nf+2)/2) * (W/nf + 0.18u)'"
nrd="'0.18u / W'" nrs="'0.18u / W'"
sa=0 sb=0 sd=0
model=nfet_06v0
spiceprefix=X
}
C {symbols/nfet_06v0.sym} -870 -200 0 1 {name=M10
L=1.0u
W=5.0u
nf=1
m=1
ad="'int((nf+1)/2) * W/nf * 0.18u'"
pd="'2*int((nf+1)/2) * (W/nf + 0.18u)'"
as="'int((nf+2)/2) * W/nf * 0.18u'"
ps="'2*int((nf+2)/2) * (W/nf + 0.18u)'"
nrd="'0.18u / W'" nrs="'0.18u / W'"
sa=0 sb=0 sd=0
model=nfet_06v0
spiceprefix=X
}
C {symbols/pfet_06v0.sym} -1350 -540 0 1 {name=M1
L=1.0u
W=2u
nf=1
m=1
ad="'int((nf+1)/2) * W/nf * 0.18u'"
pd="'2*int((nf+1)/2) * (W/nf + 0.18u)'"
as="'int((nf+2)/2) * W/nf * 0.18u'"
ps="'2*int((nf+2)/2) * (W/nf + 0.18u)'"
nrd="'0.18u / W'" nrs="'0.18u / W'"
sa=0 sb=0 sd=0
model=pfet_06v0
spiceprefix=X
}
C {symbols/pfet_06v0.sym} -1210 -620 0 1 {name=M2
L=1.0u
W=10.0u
nf=1
m=1
ad="'int((nf+1)/2) * W/nf * 0.18u'"
pd="'2*int((nf+1)/2) * (W/nf + 0.18u)'"
as="'int((nf+2)/2) * W/nf * 0.18u'"
ps="'2*int((nf+2)/2) * (W/nf + 0.18u)'"
nrd="'0.18u / W'" nrs="'0.18u / W'"
sa=0 sb=0 sd=0
model=pfet_06v0
spiceprefix=X
}
C {symbols/pfet_06v0.sym} -1210 -540 0 1 {name=M3
L=1.0u
W=10.0u
nf=1
m=1
ad="'int((nf+1)/2) * W/nf * 0.18u'"
pd="'2*int((nf+1)/2) * (W/nf + 0.18u)'"
as="'int((nf+2)/2) * W/nf * 0.18u'"
ps="'2*int((nf+2)/2) * (W/nf + 0.18u)'"
nrd="'0.18u / W'" nrs="'0.18u / W'"
sa=0 sb=0 sd=0
model=pfet_06v0
spiceprefix=X
}
C {symbols/nfet_06v0.sym} -1250 -240 0 0 {name=M47
L=1.0u
W=1.0u
nf=1
m=1
ad="'int((nf+1)/2) * W/nf * 0.18u'"
pd="'2*int((nf+1)/2) * (W/nf + 0.18u)'"
as="'int((nf+2)/2) * W/nf * 0.18u'"
ps="'2*int((nf+2)/2) * (W/nf + 0.18u)'"
nrd="'0.18u / W'" nrs="'0.18u / W'"
sa=0 sb=0 sd=0
model=nfet_06v0
spiceprefix=X
}
C {symbols/nfet_06v0.sym} -1350 -240 0 1 {name=M48
L=1.0u
W=1.0u
nf=1
m=1
ad="'int((nf+1)/2) * W/nf * 0.18u'"
pd="'2*int((nf+1)/2) * (W/nf + 0.18u)'"
as="'int((nf+2)/2) * W/nf * 0.18u'"
ps="'2*int((nf+2)/2) * (W/nf + 0.18u)'"
nrd="'0.18u / W'" nrs="'0.18u / W'"
sa=0 sb=0 sd=0
model=nfet_06v0
spiceprefix=X
}
C {symbols/nfet_06v0.sym} -1350 -300 0 1 {name=M49
L=1.0u
W=1.0u
nf=1
m=1
ad="'int((nf+1)/2) * W/nf * 0.18u'"
pd="'2*int((nf+1)/2) * (W/nf + 0.18u)'"
as="'int((nf+2)/2) * W/nf * 0.18u'"
ps="'2*int((nf+2)/2) * (W/nf + 0.18u)'"
nrd="'0.18u / W'" nrs="'0.18u / W'"
sa=0 sb=0 sd=0
model=nfet_06v0
spiceprefix=X
}
C {symbols/nfet_06v0.sym} -1250 -300 0 0 {name=M50
L=1.0u
W=1.0u
nf=1
m=1
ad="'int((nf+1)/2) * W/nf * 0.18u'"
pd="'2*int((nf+1)/2) * (W/nf + 0.18u)'"
as="'int((nf+2)/2) * W/nf * 0.18u'"
ps="'2*int((nf+2)/2) * (W/nf + 0.18u)'"
nrd="'0.18u / W'" nrs="'0.18u / W'"
sa=0 sb=0 sd=0
model=nfet_06v0
spiceprefix=X
}
C {devices/lab_pin.sym} 850 -490 0 0 {name=pRF0 sig_type=std_logic lab=G_OUT_P}
C {devices/lab_pin.sym} 1000 -430 0 0 {name=pRF1 sig_type=std_logic lab=OUT}
C {devices/lab_pin.sym} 1000 -370 0 0 {name=pRF2 sig_type=std_logic lab=G_OUT_P}
C {devices/lab_pin.sym} 980 -400 0 0 {name=pRF3 sig_type=std_logic lab=VSS}
C {symbols/ppolyf_u_1k.sym} 1000 -400 0 0 {name=RFB
W=1e-6
L=76.45e-6
model=ppolyf_u_1k
spiceprefix=X
m=1
s=5
format="@spiceprefix@name @pinlist @model r_width=@W r_length=@L m=@m s=@s"}
