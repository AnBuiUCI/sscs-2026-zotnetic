* CUATRO CADENAS POR TRIOS, Y SEIS SALIDAS (una por SENTIDO).
*
* POR QUE CUATRO CADENAS. Cada trio de tres sensores determina el gradiente
* por si solo -- las tres posiciones son linealmente independientes -- asi que
* hay CUATRO estimaciones del mismo gradiente y se pueden votar. Es la misma
* redundancia que ya tiene el diseno, y se conserva a proposito: con mas
* sensores la votacion empieza a pagar (con 7 ya hay mayoria de trios que no
* usan al sensor averiado; con 4 no, y esta medido).
*
* POR QUE SEIS SALIDAS. Con tres no se puede dar el SENTIDO del gradiente: el
* decodificador senala la componente MAS NEGATIVA, y cuando el gradiente apunta
* hacia +x esa componente no es gx sino una de las otras dos, que valen casi
* cero -- ahi decide el ruido. Medido: 50 % de acierto, o sea una moneda. Con
* dos decodificadores por cadena -- el minimo y el maximo, que salen de los
* MISMOS tres comparadores -- se cubren los seis sentidos y el acierto sube al
* 100 %. Aqui el maximo se monta instanciando la cadena otra vez con P y N
* cambiados, que es lo mismo y no pide celda nueva; en silicio se compartirian
* los comparadores y solo se duplicaria el decodificador.
*
* LOS PESOS de la red sumadora salen de invertir la matriz de posiciones del
* trio, y son +-0.5 y 0: cada componente usa DOS de los tres sensores, con
* resistencias iguales. No hay nada exotico que ajustar.

* --- cadena 1: trio S1 S2 S3
*     gx = -0.50*b(S1) -0.50*b(S3)
RX11p S1N GX1P 100k
RX11n S1P GX1N 100k
RX13p S3N GX1P 100k
RX13n S3P GX1N 100k
*     gy = -0.50*b(S2) -0.50*b(S3)
RY12p S2N GY1P 100k
RY12n S2P GY1N 100k
RY13p S3N GY1P 100k
RY13n S3P GY1N 100k
*     gz = +0.50*b(S1) +0.50*b(S2)
RZ11p S1P GZ1P 100k
RZ11n S1N GZ1N 100k
RZ12p S2P GZ1P 100k
RZ12n S2N GZ1N 100k
* compensacion de la caja: se atenuan x e y por Lz/Lxy, que es lo unico que
* una red pasiva puede hacer. LXY y LZ entran como PUERTOS porque el banco
* barre la caja; en un chip de verdad es un valor fijo de resistencia.
RX1D GX1P GX1N r='50k*(v(LZ)/v(LXY))/(1-v(LZ)/v(LXY)+1e-9)'
RY1D GY1P GY1N r='50k*(v(LZ)/v(LXY))/(1-v(LZ)/v(LXY)+1e-9)'
* .subckt GRADIENT2 SXN SXP VDD X SYN Y Z SYP VSS SZN SZP
XCN1 GX1N GX1P VDD XN1 GY1N YN1 ZN1 GY1P VSS GZ1N GZ1P GRADIENT2
XCP1 GX1P GX1N VDD XP1 GY1P YP1 ZP1 GY1N VSS GZ1P GZ1N GRADIENT2

* --- cadena 2: trio S1 S2 S4
*     gx = +0.50*b(S2) +0.50*b(S4)
RX22p S2P GX2P 100k
RX22n S2N GX2N 100k
RX24p S4P GX2P 100k
RX24n S4N GX2N 100k
*     gy = +0.50*b(S1) +0.50*b(S4)
RY21p S1P GY2P 100k
RY21n S1N GY2N 100k
RY24p S4P GY2P 100k
RY24n S4N GY2N 100k
*     gz = +0.50*b(S1) +0.50*b(S2)
RZ21p S1P GZ2P 100k
RZ21n S1N GZ2N 100k
RZ22p S2P GZ2P 100k
RZ22n S2N GZ2N 100k
* compensacion de la caja: se atenuan x e y por Lz/Lxy, que es lo unico que
* una red pasiva puede hacer. LXY y LZ entran como PUERTOS porque el banco
* barre la caja; en un chip de verdad es un valor fijo de resistencia.
RX2D GX2P GX2N r='50k*(v(LZ)/v(LXY))/(1-v(LZ)/v(LXY)+1e-9)'
RY2D GY2P GY2N r='50k*(v(LZ)/v(LXY))/(1-v(LZ)/v(LXY)+1e-9)'
* .subckt GRADIENT2 SXN SXP VDD X SYN Y Z SYP VSS SZN SZP
XCN2 GX2N GX2P VDD XN2 GY2N YN2 ZN2 GY2P VSS GZ2N GZ2P GRADIENT2
XCP2 GX2P GX2N VDD XP2 GY2P YP2 ZP2 GY2N VSS GZ2P GZ2N GRADIENT2

* --- cadena 3: trio S1 S3 S4
*     gx = -0.50*b(S1) -0.50*b(S3)
RX31p S1N GX3P 100k
RX31n S1P GX3N 100k
RX33p S3N GX3P 100k
RX33n S3P GX3N 100k
*     gy = +0.50*b(S1) +0.50*b(S4)
RY31p S1P GY3P 100k
RY31n S1N GY3N 100k
RY34p S4P GY3P 100k
RY34n S4N GY3N 100k
*     gz = -0.50*b(S3) -0.50*b(S4)
RZ33p S3N GZ3P 100k
RZ33n S3P GZ3N 100k
RZ34p S4N GZ3P 100k
RZ34n S4P GZ3N 100k
* compensacion de la caja: se atenuan x e y por Lz/Lxy, que es lo unico que
* una red pasiva puede hacer. LXY y LZ entran como PUERTOS porque el banco
* barre la caja; en un chip de verdad es un valor fijo de resistencia.
RX3D GX3P GX3N r='50k*(v(LZ)/v(LXY))/(1-v(LZ)/v(LXY)+1e-9)'
RY3D GY3P GY3N r='50k*(v(LZ)/v(LXY))/(1-v(LZ)/v(LXY)+1e-9)'
* .subckt GRADIENT2 SXN SXP VDD X SYN Y Z SYP VSS SZN SZP
XCN3 GX3N GX3P VDD XN3 GY3N YN3 ZN3 GY3P VSS GZ3N GZ3P GRADIENT2
XCP3 GX3P GX3N VDD XP3 GY3P YP3 ZP3 GY3N VSS GZ3P GZ3N GRADIENT2

* --- cadena 4: trio S2 S3 S4
*     gx = +0.50*b(S2) +0.50*b(S4)
RX42p S2P GX4P 100k
RX42n S2N GX4N 100k
RX44p S4P GX4P 100k
RX44n S4N GX4N 100k
*     gy = -0.50*b(S2) -0.50*b(S3)
RY42p S2N GY4P 100k
RY42n S2P GY4N 100k
RY43p S3N GY4P 100k
RY43n S3P GY4N 100k
*     gz = -0.50*b(S3) -0.50*b(S4)
RZ43p S3N GZ4P 100k
RZ43n S3P GZ4N 100k
RZ44p S4N GZ4P 100k
RZ44n S4P GZ4N 100k
* compensacion de la caja: se atenuan x e y por Lz/Lxy, que es lo unico que
* una red pasiva puede hacer. LXY y LZ entran como PUERTOS porque el banco
* barre la caja; en un chip de verdad es un valor fijo de resistencia.
RX4D GX4P GX4N r='50k*(v(LZ)/v(LXY))/(1-v(LZ)/v(LXY)+1e-9)'
RY4D GY4P GY4N r='50k*(v(LZ)/v(LXY))/(1-v(LZ)/v(LXY)+1e-9)'
* .subckt GRADIENT2 SXN SXP VDD X SYN Y Z SYP VSS SZN SZP
XCN4 GX4N GX4P VDD XN4 GY4N YN4 ZN4 GY4P VSS GZ4N GZ4P GRADIENT2
XCP4 GX4P GX4N VDD XP4 GY4P YP4 ZP4 GY4N VSS GZ4P GZ4N GRADIENT2

* LOS SEIS PESOS: uno por sentido, votando entre las cuatro cadenas.
* .subckt WEIGHT VDD GND OUT VA VC VB VD
XWXN VDD VSS WXN XN1 XN2 XN3 XN4 WEIGHT
XWYN VDD VSS WYN YN1 YN2 YN3 YN4 WEIGHT
XWZN VDD VSS WZN ZN1 ZN2 ZN3 ZN4 WEIGHT
XWXP VDD VSS WXP XP1 XP2 XP3 XP4 WEIGHT
XWYP VDD VSS WYP YP1 YP2 YP3 YP4 WEIGHT
XWZP VDD VSS WZP ZP1 ZP2 ZP3 ZP4 WEIGHT

* Y la decision, como en el resto de XSCHEM_v2: comparador contra la
* referencia de dos replicas del bloque de pesos, una con 1 voto y otra con 2.
XREF1 VDD VSS VREFA VDD VSS VSS VSS WEIGHT
XREF2 VDD VSS VREFB VDD VDD VSS VSS WEIGHT
RREF1 VREFA VREF 100k
RREF2 VREF VREFB 100k
XCMPXN VDD WXN XN VREF VSS COMP
XCMPYN VDD WYN YN VREF VSS COMP
XCMPZN VDD WZN ZN VREF VSS COMP
XCMPXP VDD WXP XP VREF VSS COMP
XCMPYP VDD WYP YP VREF VSS COMP
XCMPZP VDD WZP ZP VREF VSS COMP
