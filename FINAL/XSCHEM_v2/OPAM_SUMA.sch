v {xschem version=3.4.8RC file_version=1.3}
G {}
K {}
V {}
S {}
F {}
E {}
C {a_zonetic2026/XSCHEM/OPAM/OPAM_LIN.sym} 0 0 0 0 {name=xamp}
C {devices/lab_pin.sym} -40.0 -60.0 0 0 {name=l1 sig_type=std_logic lab=VDD}
C {devices/lab_pin.sym} -100.0 -20.0 0 0 {name=l2 sig_type=std_logic lab=NSN}
C {devices/lab_pin.sym} 60.0 0.0 0 0 {name=l3 sig_type=std_logic lab=OUT}
C {devices/lab_pin.sym} -100.0 20.0 0 0 {name=l4 sig_type=std_logic lab=NSP}
C {devices/lab_pin.sym} -40.0 60.0 0 0 {name=l5 sig_type=std_logic lab=VSS}
C {symbols/ppolyf_u_3k.sym} -250 -450 0 0 {name=RA1
W=1e-6
L=55.56e-6
model=ppolyf_u_3k
spiceprefix=X
m=1
s=3
format="@spiceprefix@name @pinlist @model r_width=@W r_length=@L m=@m s=@s"}
C {devices/lab_pin.sym} -250 -480 0 0 {name=r6 sig_type=std_logic lab=A1}
C {devices/lab_pin.sym} -250 -420 0 0 {name=r7 sig_type=std_logic lab=NSP}
C {devices/lab_pin.sym} -270 -450 0 0 {name=r8 sig_type=std_logic lab=VSS}
C {symbols/nfet_06v0.sym} -560 -450 0 0 {name=xmcA1
L=2u
W=2u
nf=1
m=1
ad="'int((nf+1)/2) * W/nf * 0.18u'"
pd="'2*int((nf+1)/2) * (W/nf + 0.18u)'"
as="'int((nf+2)/2) * W/nf * 0.18u'"
ps="'2*int((nf+2)/2) * (W/nf + 0.18u)'"
nrd="'0.18u / W'"
nrs="'0.18u / W'"
sa=0
sb=0
sd=0
model=nfet_06v0
spiceprefix=X
}
C {devices/lab_pin.sym} -540.0 -480.0 0 0 {name=l9 sig_type=std_logic lab=VSS}
C {devices/lab_pin.sym} -580.0 -450.0 0 0 {name=l10 sig_type=std_logic lab=A1}
C {devices/lab_pin.sym} -540.0 -420.0 0 0 {name=l11 sig_type=std_logic lab=VSS}
C {devices/lab_pin.sym} -540.0 -450.0 0 0 {name=l12 sig_type=std_logic lab=VSS}
C {symbols/ppolyf_u_3k.sym} -250 -250 0 0 {name=RA2
W=1e-6
L=55.56e-6
model=ppolyf_u_3k
spiceprefix=X
m=1
s=3
format="@spiceprefix@name @pinlist @model r_width=@W r_length=@L m=@m s=@s"}
C {devices/lab_pin.sym} -250 -280 0 0 {name=r13 sig_type=std_logic lab=A2}
C {devices/lab_pin.sym} -250 -220 0 0 {name=r14 sig_type=std_logic lab=NSP}
C {devices/lab_pin.sym} -270 -250 0 0 {name=r15 sig_type=std_logic lab=VSS}
C {symbols/nfet_06v0.sym} -560 -250 0 0 {name=xmcA2
L=2u
W=2u
nf=1
m=1
ad="'int((nf+1)/2) * W/nf * 0.18u'"
pd="'2*int((nf+1)/2) * (W/nf + 0.18u)'"
as="'int((nf+2)/2) * W/nf * 0.18u'"
ps="'2*int((nf+2)/2) * (W/nf + 0.18u)'"
nrd="'0.18u / W'"
nrs="'0.18u / W'"
sa=0
sb=0
sd=0
model=nfet_06v0
spiceprefix=X
}
C {devices/lab_pin.sym} -540.0 -280.0 0 0 {name=l16 sig_type=std_logic lab=VSS}
C {devices/lab_pin.sym} -580.0 -250.0 0 0 {name=l17 sig_type=std_logic lab=A2}
C {devices/lab_pin.sym} -540.0 -220.0 0 0 {name=l18 sig_type=std_logic lab=VSS}
C {devices/lab_pin.sym} -540.0 -250.0 0 0 {name=l19 sig_type=std_logic lab=VSS}
C {symbols/ppolyf_u_3k.sym} -250 -50 0 0 {name=RB1
W=1e-6
L=55.56e-6
model=ppolyf_u_3k
spiceprefix=X
m=1
s=3
format="@spiceprefix@name @pinlist @model r_width=@W r_length=@L m=@m s=@s"}
C {devices/lab_pin.sym} -250 -80 0 0 {name=r20 sig_type=std_logic lab=B1}
C {devices/lab_pin.sym} -250 -20 0 0 {name=r21 sig_type=std_logic lab=NSN}
C {devices/lab_pin.sym} -270 -50 0 0 {name=r22 sig_type=std_logic lab=VSS}
C {symbols/nfet_06v0.sym} -560 -50 0 0 {name=xmcB1
L=2u
W=2u
nf=1
m=1
ad="'int((nf+1)/2) * W/nf * 0.18u'"
pd="'2*int((nf+1)/2) * (W/nf + 0.18u)'"
as="'int((nf+2)/2) * W/nf * 0.18u'"
ps="'2*int((nf+2)/2) * (W/nf + 0.18u)'"
nrd="'0.18u / W'"
nrs="'0.18u / W'"
sa=0
sb=0
sd=0
model=nfet_06v0
spiceprefix=X
}
C {devices/lab_pin.sym} -540.0 -80.0 0 0 {name=l23 sig_type=std_logic lab=VSS}
C {devices/lab_pin.sym} -580.0 -50.0 0 0 {name=l24 sig_type=std_logic lab=B1}
C {devices/lab_pin.sym} -540.0 -20.0 0 0 {name=l25 sig_type=std_logic lab=VSS}
C {devices/lab_pin.sym} -540.0 -50.0 0 0 {name=l26 sig_type=std_logic lab=VSS}
C {symbols/ppolyf_u_3k.sym} -250 150 0 0 {name=RB2
W=1e-6
L=55.56e-6
model=ppolyf_u_3k
spiceprefix=X
m=1
s=3
format="@spiceprefix@name @pinlist @model r_width=@W r_length=@L m=@m s=@s"}
C {devices/lab_pin.sym} -250 120 0 0 {name=r27 sig_type=std_logic lab=B2}
C {devices/lab_pin.sym} -250 180 0 0 {name=r28 sig_type=std_logic lab=NSN}
C {devices/lab_pin.sym} -270 150 0 0 {name=r29 sig_type=std_logic lab=VSS}
C {symbols/nfet_06v0.sym} -560 150 0 0 {name=xmcB2
L=2u
W=2u
nf=1
m=1
ad="'int((nf+1)/2) * W/nf * 0.18u'"
pd="'2*int((nf+1)/2) * (W/nf + 0.18u)'"
as="'int((nf+2)/2) * W/nf * 0.18u'"
ps="'2*int((nf+2)/2) * (W/nf + 0.18u)'"
nrd="'0.18u / W'"
nrs="'0.18u / W'"
sa=0
sb=0
sd=0
model=nfet_06v0
spiceprefix=X
}
C {devices/lab_pin.sym} -540.0 120.0 0 0 {name=l30 sig_type=std_logic lab=VSS}
C {devices/lab_pin.sym} -580.0 150.0 0 0 {name=l31 sig_type=std_logic lab=B2}
C {devices/lab_pin.sym} -540.0 180.0 0 0 {name=l32 sig_type=std_logic lab=VSS}
C {devices/lab_pin.sym} -540.0 150.0 0 0 {name=l33 sig_type=std_logic lab=VSS}
C {ipin.sym} -800 -450 0 0 {name=q34 lab=A1}
C {ipin.sym} -800 -390 0 0 {name=q35 lab=A2}
C {ipin.sym} -800 -330 0 0 {name=q36 lab=B1}
C {ipin.sym} -800 -270 0 0 {name=q37 lab=B2}
C {opin.sym} 420 0 0 0 {name=q38 lab=OUT}
C {iopin.sym} 420 60 0 0 {name=q39 lab=VDD}
C {iopin.sym} 420 120 0 0 {name=q40 lab=VSS}
