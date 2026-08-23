v {xschem version=3.4.8RC file_version=1.3}
G {}
K {}
V {}
S {}
F {}
E {}
C {devices/code_shown.sym} 570 -700 0 0 {name=MODELS1 only_toplevel=true
format="tcleval( @value )"
value="
.include $::180MCU_MODELS/design.ngspice
.lib $::180MCU_MODELS/sm141064.ngspice typical
.lib $::180MCU_MODELS/sm141064.ngspice cap_mim
.lib $::180MCU_MODELS/sm141064.ngspice res_typical
.lib $::180MCU_MODELS/sm141064.ngspice moscap_typical
.lib $::180MCU_MODELS/sm141064.ngspice mimcap_typical
"}
C {devices/vsource.sym} 110 -520 0 0 {name=V1 value=5
}
C {devices/lab_wire.sym} 110 -550 0 0 {name=pV1a sig_type=std_logic lab=VEXC}
C {devices/gnd.sym} 110 -490 0 0 {name=lV1 lab=GND
value=5}
C {devices/gnd.sym} 190 -490 0 0 {name=lV2 lab=GND
value=5}
C {devices/vsource.sym} 270 -520 0 0 {name=V3 value=5
}
C {devices/lab_wire.sym} 270 -550 0 0 {name=pV3a sig_type=std_logic lab=VDDR}
C {devices/gnd.sym} 270 -490 0 0 {name=lV3 lab=GND
value=5}
C {devices/code_shown.sym} -700 -700 0 0 {name=ESTIMULO only_toplevel=true
value="
* LOS CUATRO SENSORES, CON LA CAJA COMO PARAMETRO.
*
* Vertices en (+-Lxy/2, +-Lxy/2, +-Lz/2), con la asignacion de la foto:
*
*     S1 (-Lxy/2, +Lxy/2, +Lz/2)      S2 (+Lxy/2, -Lxy/2, +Lz/2)   plano z de arriba
*     S3 (-Lxy/2, -Lxy/2, -Lz/2)      S4 (+Lxy/2, +Lxy/2, -Lz/2)   plano z de abajo
*
* Lo que lee cada sensor es la proyeccion de SU POSICION sobre la direccion del
* gradiente, mas el campo de fondo, que es COMUN a los cuatro:
*
*     b_k = bg + gmm * (r_k . direccion) ,  con r_k en mm
*
* `gmm` va en dR/R POR MILIMETRO. No se convierte a campo: eso pide la
* sensibilidad del AMR, que no esta fijada todavia.
*
* La caja, el gradiente, el fondo y el plano de barrido son FUENTES DE CONTINUA,
* no numeros de este texto: asi las seis cajas y todos los niveles caben en una
* sola corrida de ngspice, con `alter` entre barridos. La netlist son 31 bloques
* extraidos con RC y lo caro es montarla, no barrerla.
* DESAJUSTE DE SENSOR. Sin el, la resolucion por abajo NO EXISTE: los cuatro
* puentes y los tres amplificadores de la simulacion son identicos, asi que la
* comparacion es exacta por pequena que sea la senal, y el acierto se queda
* clavado en el 98.9 % hasta el nivel mas bajo que se barra. Eso es una
* propiedad del modelo, no del chip.
*
* Lo que de verdad pone el suelo es el offset del puente, que en una AMR real es
* grande y distinto en cada uno. Se modela como un dR/R fijo por sensor, con un
* patron arbitrario pero FIJO y documentado, escalado por `Voff`:
*
*     p = (+1.00, -0.62, +0.31, -0.85)
*
* El patron no es simetrico a proposito: un offset que se parezca a un gradiente
* sesga la respuesta hacia esa direccion, que es justo lo que hace en la realidad.
Voff  off  0 0
Vlxy  lxy  0 1000
Vlz   lz   0 1000
Vgmm  gmm  0 2000u
Vbg   bg   0 0
Vang  ang  0 0
Vtilt tilt 0 0

Bgx gx 0 v='cos(v(ang)*3.14159265358979/180)'
Bgy gy 0 v='sin(v(ang)*3.14159265358979/180)*sin(v(tilt)*3.14159265358979/180)'
Bgz gz 0 v='sin(v(ang)*3.14159265358979/180)*cos(v(tilt)*3.14159265358979/180)'

Bb1 b1 0 v='v(bg) +1.00*v(off) + v(gmm)*(-v(lxy)*v(gx) +v(lxy)*v(gy) +v(lz)*v(gz))/2000'
Bb2 b2 0 v='v(bg) -0.62*v(off) + v(gmm)*( v(lxy)*v(gx) -v(lxy)*v(gy) +v(lz)*v(gz))/2000'
Bb3 b3 0 v='v(bg) +0.31*v(off) + v(gmm)*(-v(lxy)*v(gx) -v(lxy)*v(gy) -v(lz)*v(gz))/2000'
Bb4 b4 0 v='v(bg) -0.85*v(off) + v(gmm)*( v(lxy)*v(gx) +v(lxy)*v(gy) -v(lz)*v(gz))/2000'

* Los cuatro puentes, de 1 Mohm por rama y las cuatro ramas moviendose a la vez.
* Vcm = VEXC/2 exacto e independiente de b, que es lo que permite leer la curva
* sin mezclarla con la sensibilidad al modo comun de estas celdas.
R1a VEXC S1P r='1meg*(1-v(b1))'
R1b S1P  GND r='1meg*(1+v(b1))'
R1c VEXC S1N r='1meg*(1+v(b1))'
R1d S1N  GND r='1meg*(1-v(b1))'
R2a VEXC S2P r='1meg*(1-v(b2))'
R2b S2P  GND r='1meg*(1+v(b2))'
R2c VEXC S2N r='1meg*(1+v(b2))'
R2d S2N  GND r='1meg*(1-v(b2))'
R3a VEXC S3P r='1meg*(1-v(b3))'
R3b S3P  GND r='1meg*(1+v(b3))'
R3c VEXC S3N r='1meg*(1+v(b3))'
R3d S3N  GND r='1meg*(1-v(b3))'
R4a VEXC S4P r='1meg*(1-v(b4))'
R4b S4P  GND r='1meg*(1+v(b4))'
R4c VEXC S4N r='1meg*(1+v(b4))'
R4d S4N  GND r='1meg*(1-v(b4))'
"}
C {a_zonetic2026/XSCHEM_v2/GRADIENT_NAV2_V2.sym} 0 400 0 0 {name=xnav2}
C {devices/lab_wire.sym} -150 300 0 0 {name=qS1P sig_type=std_logic lab=S1P}
C {devices/lab_wire.sym} -150 320 0 0 {name=qS1N sig_type=std_logic lab=S1N}
C {devices/lab_wire.sym} -150 340 0 0 {name=qS2P sig_type=std_logic lab=S2P}
C {devices/lab_wire.sym} -150 360 0 0 {name=qS2N sig_type=std_logic lab=S2N}
C {devices/lab_wire.sym} -150 400 0 0 {name=qS3P sig_type=std_logic lab=S3P}
C {devices/lab_wire.sym} -150 420 0 0 {name=qS3N sig_type=std_logic lab=S3N}
C {devices/lab_wire.sym} -150 440 0 0 {name=qS4P sig_type=std_logic lab=S4P}
C {devices/lab_wire.sym} -150 460 0 0 {name=qS4N sig_type=std_logic lab=S4N}
C {devices/lab_wire.sym} 150 300 2 0 {name=qXPv sig_type=std_logic lab=XPv}
C {devices/lab_wire.sym} 150 320 2 0 {name=qXv sig_type=std_logic lab=Xv}
C {devices/lab_wire.sym} 150 340 2 0 {name=qXNv sig_type=std_logic lab=XNv}
C {devices/lab_wire.sym} 150 360 2 0 {name=qYPv sig_type=std_logic lab=YPv}
C {devices/lab_wire.sym} 150 380 2 0 {name=qYv sig_type=std_logic lab=Yv}
C {devices/lab_wire.sym} 150 400 2 0 {name=qYNv sig_type=std_logic lab=YNv}
C {devices/lab_wire.sym} 150 420 2 0 {name=qZPv sig_type=std_logic lab=ZPv}
C {devices/lab_wire.sym} 150 440 2 0 {name=qZv sig_type=std_logic lab=Zv}
C {devices/lab_wire.sym} 150 460 2 0 {name=qZNv sig_type=std_logic lab=ZNv}
C {devices/lab_wire.sym} 0 270 1 0 {name=qVDD sig_type=std_logic lab=VDDV}
C {devices/gnd.sym} 0 490 0 0 {name=qVSS lab=GND
value=5}
C {devices/vsource.sym} 350 -520 0 0 {name=V4 value=5
}
C {devices/lab_wire.sym} 350 -550 0 0 {name=pV4a sig_type=std_logic lab=VDDV}
C {devices/gnd.sym} 350 -490 0 0 {name=lV4 lab=GND
value=5}
C {a_zonetic2026/XSCHEM_v2/GRADIENT_NAV3.sym} 0 800 0 0 {name=xnav3}
C {devices/lab_wire.sym} -150 700 0 0 {name=rS1P sig_type=std_logic lab=S1P}
C {devices/lab_wire.sym} -150 720 0 0 {name=rS1N sig_type=std_logic lab=S1N}
C {devices/lab_wire.sym} -150 740 0 0 {name=rS2P sig_type=std_logic lab=S2P}
C {devices/lab_wire.sym} -150 760 0 0 {name=rS2N sig_type=std_logic lab=S2N}
C {devices/lab_wire.sym} -150 800 0 0 {name=rS3P sig_type=std_logic lab=S3P}
C {devices/lab_wire.sym} -150 820 0 0 {name=rS3N sig_type=std_logic lab=S3N}
C {devices/lab_wire.sym} -150 840 0 0 {name=rS4P sig_type=std_logic lab=S4P}
C {devices/lab_wire.sym} -150 860 0 0 {name=rS4N sig_type=std_logic lab=S4N}
C {devices/lab_wire.sym} -150 880 0 0 {name=rLXY sig_type=std_logic lab=lxy}
C {devices/lab_wire.sym} -150 900 0 0 {name=rLZ sig_type=std_logic lab=lz}
C {devices/lab_wire.sym} 150 700 2 0 {name=rXP3 sig_type=std_logic lab=XP3}
C {devices/lab_wire.sym} 150 740 2 0 {name=rXN3 sig_type=std_logic lab=XN3}
C {devices/lab_wire.sym} 150 760 2 0 {name=rYP3 sig_type=std_logic lab=YP3}
C {devices/lab_wire.sym} 150 800 2 0 {name=rYN3 sig_type=std_logic lab=YN3}
C {devices/lab_wire.sym} 150 820 2 0 {name=rZP3 sig_type=std_logic lab=ZP3}
C {devices/lab_wire.sym} 150 860 2 0 {name=rZN3 sig_type=std_logic lab=ZN3}
C {devices/lab_wire.sym} 0 670 1 0 {name=rVDD sig_type=std_logic lab=VDD3}
C {devices/gnd.sym} 0 890 0 0 {name=rVSS lab=GND
value=5}
C {devices/vsource.sym} 430 -520 0 0 {name=V5 value=5
}
C {devices/lab_wire.sym} 430 -550 0 0 {name=pV5a sig_type=std_logic lab=VDD3}
C {devices/gnd.sym} 430 -490 0 0 {name=lV5 lab=GND
value=5}
