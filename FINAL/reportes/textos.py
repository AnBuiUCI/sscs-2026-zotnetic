#!/usr/bin/env python3
"""Every word of the deck, in both languages, side by side.

Kept apart from `hacer_pptx.py` so that the two presentations are the SAME
structure with different strings, and cannot drift into being two documents.
Whoever edits a sentence sees its counterpart on the next line.

Figure labels are NOT here: they are baked into the PNGs and stay in English in
both decks, on purpose -- that is what `figuras.py` has always done and what
these get used for.

Every number quoted below is traceable:
  * source test        XSCHEM/TEST_TOTAL/datos_fuente/fuente.csv
  * geometry sweep     XSCHEM/TEST_TOTAL/datos_geo/resumen.csv
  * layout vs schematic XSCHEM_v3/datos_nav3/fino_nav2.csv (721 points)
                       -- the version that ships; the earlier top's sweep is
                       still at XSCHEM/TEST_TOTAL/datos_nav2/ and is only
                       quoted as the before of a comparison
  * DRC / LVS          openroad/out/drc_*/  and  layouts_v2/*/lvs/RESUMEN.txt
"""

ES = {
    "idioma": "ES",
    "portada_t": "TEAM ZOTNETIC",
    "portada_s": "B26 · Navegador de gradiente magnético en GF180MCU",
    "portada_l": [
        "SSCS Chipathon 2026 · UCI Samueli School of Engineering",
        "Líder: Juan Sánchez · An Bui · Enzo Li · Akam Khinda · Aysha Hussaini",
        "Reporte de diseño, simulación y verificación",
    ],

    "s1": "QUÉ HACE EL CHIP",
    "s1_b": "Cuatro sensores leen el módulo del campo. El chip deduce hacia dónde crece.",
    "s2": "LOS TRES BLOQUES",
    "s2_b": "GRADIENT_NAV2 por dentro: cada bloque con su diagrama, su esquemático, su layout y sus simulaciones.",
    "s3": "RESULTADOS TOTALES",
    "s3_b": "El sistema completo, siempre comparando layout contra esquemático.",
    "s4": "LOS BANCOS DE PRUEBA",
    "s4_b": "Qué se estimula, cómo se modela el sensor y qué número se busca.",
    "s5": "TEST TOTAL",
    "s5_b": "De un gradiente impuesto a una fuente real puesta en un sitio.",
    "s6": "VERIFICACIÓN FÍSICA",
    "s6_b": "DRC, LVS, conectividad y densidad de corriente sobre el fichero que se entrega.",
    "s7": "CONCLUSIONES",
    "s7_b": "Lo esperado frente a lo medido, incluido lo que no cerró.",

    "idea_t": "EL PRINCIPIO",
    "idea_e": "Los sensores no miden un vector: miden módulo. Esa distinción es el diseño entero.",
    "idea": [
        ("Cuatro puentes magnetorresistivos leen |B| en los vértices de un tetraedro.", True),
        "Cada puente da una tensión proporcional a dR/R, es decir al módulo del campo en su vértice, no a su dirección.",
        ("Comparando los cuatro módulos se reconstruye grad|B|.", True),
        "El gradiente del módulo apunta hacia donde el campo crece, y el campo crece hacia la fuente. Por eso el chip puede señalar un imán sin medir nunca un vector.",
        ("La salida es un signo por eje: XP/XN, YP/YN, ZP/ZN.", True),
        "Seis salidas digitales. No dice cuánto, dice hacia dónde.",
    ],

    "cadena_t": "LA CADENA DE SEÑAL",
    "cadena_e": "De los puentes a las seis salidas digitales.",
    "cadena": [
        ("Puentes → OPAM_LIN_flat → WEIGHT_COMP → DECODER → COMP → salidas", True),
        "OPAM_LIN_flat: amplificador lineal de 40 dB. Es el que se instancia; el de 98 dB quedó fuera por saturar antes.",
        "WEIGHT_COMP: contador de votos en modo corriente. Combina las lecturas de tres sensores por eje.",
        "DECODER: decide qué eje gana. DECODER_MAX es la variante que elige el máximo.",
        "COMP: comparador que convierte la decisión en el par digital de cada eje.",
        "ESD_CDM: protección secundaria junto a cada pad. Once instancias, dibujadas por nosotros sobre el esquemático exacto de los organizadores.",
    ],

    "modelo_t": "CÓMO SE MODELA EL SENSOR",
    "modelo_e": "Común a todos los bancos. Es lo que permite leer las curvas sin ambigüedad.",
    "modelo": [
        ("Puente completo: los cuatro brazos de 1 MΩ varían a la vez.", True),
        "VEXC —R(1−b)— SkP —R(1+b)— GND      →   V(SkP) = VEXC·(1+b)/2",
        "VEXC —R(1+b)— SkN —R(1−b)— GND      →   V(SkN) = VEXC·(1−b)/2",
        ("De donde Vdiff = VEXC·b  y  Vcm = VEXC/2 exacto, independiente de b.", True),
        "Lo segundo es lo que importa: si el modo común se moviera con la señal, se mezclaría con la sensibilidad en modo común de las celdas y no habría forma de separar las dos cosas al leer la curva.",
        "b es literalmente dR/R.",
    ],

    "grad_t": "BANCO DEL GRADIENTE · MÉTODO",
    "grad_e": "run_gradient.sh — tres puentes, y solo el amplificador lineal.",
    "grad": [
        ("Dos cadenas colgadas de los MISMOS seis nodos de sensor:", True),
        "G2 — el esquemático GRADIENT2, con el OPAM_LIN de 40 dB",
        "G4 — el mismo circuito reconstruido desde el layout v2, con el "
        "OPAM_LIN_flat y extraído con parásitos RC",
        ("Es el mismo amplificador dibujado de dos maneras.", True),
        "Así toda comparación de esta sección es layout contra esquemático, "
        "nunca un amplificador contra otro.",
        ("Qué se mide: los tres campos van a 120°, suman cero y el vector solo "
         "cambia de dirección.", True),
        "Barriendo de 0 a 360° cada eje debería ganar un sector de exactamente "
        "120°. La cifra que sale es cuánto derivan esas tres fronteras y en qué "
        "porcentaje del barrido el eje decodificado es el correcto.",
    ],

    "nav_t": "BANCO DEL NAVEGADOR · MÉTODO",
    "nav_e": "run_nav2.sh — cuatro puentes contra dos navegadores. Es también la comparación layout-esquemático.",
    "nav": [
        ("Dos navegadores sobre los mismos ocho nodos de sensor:", True),
        "N_esq — el esquemático GRADIENT_NAV2, alimentación VDDS",
        "N_lay — el mismo circuito reconstruido desde el layout v2 y extraído CON PARÁSITOS RC, alimentación VDDR",
        ("Cuatro sensores a 0, 90, 180 y 270°, y el campo girando de 0 a 360°.", True),
        "Cada una de las cuatro cadenas lee TRES de los cuatro sensores, en combinaciones distintas, y los tres pesos combinan sus salidas.",
        ("Qué se mide: en qué porcentaje del barrido las nueve salidas del esquemático coinciden con las del layout, y donde no, cuántos grados dura el desacuerdo.", True),
    ],

    "geo_t": "BANCO DE GEOMETRÍA · MÉTODO",
    "geo_e": "run_nav2_geo.sh — cómo depende el navegador de la caja donde van los sensores.",
    "geo": [
        ("Los cuatro sensores van en los vértices del tetraedro inscrito en una caja Lxy × Lxy × Lz.", True),
        "Seis combinaciones: Lxy de 1000, 2000 y 3000 µm, y Lz de 500 y 1000 µm.",
        ("1 · Resolución.", True),
        "Para cada caja y cada nivel de gradiente se barre la dirección 360° y se cuenta en qué fracción acierta el eje. De esa curva sale un número: el gradiente más pequeño al que el acierto llega al 95 %. Captura los dos límites de golpe — por abajo el offset del comparador, por arriba la saturación del amplificador — sin depender de ninguna definición prestada.",
        ("2 · Lo mismo en el plano X-Y, donde Lz no juega.", True),
        "Separa la resolución en x-y de la de z.",
        ("3 · Fondo.", True),
        "El campo terrestre es común a los cuatro sensores, así que se cancela en la comparación pero NO en el amplificador, que lo ve entero. Se barre para ver a qué nivel se pierde la medida.",
    ],

    "src_t": "BANCO DE FUENTE · MÉTODO",
    "src_e": "run_fuente.sh — ¿apunta el chip hacia ella? Es la pregunta para la que existe.",
    "src": [
        ("Todo lo anterior imponía un gradiente uniforme en una dirección. Aquí el campo viene de una fuente puesta en un sitio y cada sensor lee el módulo en su propio vértice.", True),
        ("Dos modelos, y la pareja es el método:", True),
        "SIMÉTRICO — |B| depende solo de la distancia, así que grad|B| apunta EXACTAMENTE a la fuente. Cualquier error que salga es del chip.",
        "DIPOLO REAL — eje en +z. |B| depende también del ángulo, y grad|B| NO apunta exactamente a la fuente ni con un chip perfecto.",
        ("La diferencia entre los dos números separa el error del circuito del error de la física.", True),
        "Que es lo que hace falta tener antes de creerse nada medido con un imán de verdad.",
        "42 barridos: tres distancias, siete azimuts, los dos modelos.",
    ],

    "res_lay_t": "RESULTADO · LAYOUT CONTRA ESQUEMÁTICO",
    "salida_e": "Los seis pines digitales: tres decisiones y sus complementos.",
    "salida": [
        ("XP alto significa «gana este eje». XN es su negado, no «el otro sentido».", True),
        "COMP_OUT es OUT = búfer(IN) y OUT_N = NOT(IN), instanciado como x8 VDD XN X XP VSS. El par es redundante por construcción: para leer el chip basta XP, y XN está para alimentar directamente el puente en H.",
        ("El chip contesta QUÉ EJE, no hacia qué lado.", True),
        "El decodificador saca el eje cuyo puente lee MENOS, que es el vértice aguas arriba del gradiente. Eso identifica un eje entre tres, no un sentido entre seis.",
        ("Distinguir +X de −X pide una comparación más.", True),
        "Es la que añade GRADIENT_NAV3, que compara componentes en lugar de lecturas y sí saca los seis sentidos. No está instanciado en este die.",
    ],

    "v3_t": "LA MEJORA, YA DENTRO DEL DIE",
    "v3_e": "Reordenar los puertos de sensor: 76.2 % a 90.7 %, sin tocar una sola celda. Es el núcleo que se entrega.",

    "res_lay_e": "721 puntos de 0 a 360°. La naranja discontinua es el layout extraído con parásitos.",
    "res_lay": [
        ("Las seis salidas digitales coinciden en el 99.58 % del barrido.", True),
        "1.5 grados de desacuerdo sobre 360, y caen donde tienen que caer: en las fronteras entre sectores, que es exactamente donde la decisión está en el filo y el offset del layout decide. Los cuatro bloques GRADIENT2 del layout, extraídos con parásitos RC, deciden lo mismo que los del esquemático.",
        ("Los tres ejes al mismo nivel: 99.72 % cada uno.", True),
        "En la versión anterior eran 99.45 % en X e Y y 98.89 % en Z — Z iba por detrás. Con el reparto de puertos de la v3 los tres empatan, y el desacuerdo baja de 2–4 grados a 1.5.",
        ("Desviación peor caso en el nodo del contador: 693.8 mV.", True),
        "Consumo: 74.85 mW el esquemático, 74.82 mW el layout. Tres centésimas de diferencia: los parásitos RC no mueven el punto de trabajo de forma apreciable.",
    ],

    "res_src_t": "RESULTADO · ¿APUNTA A LA FUENTE?",
    "res_src_e": "Ángulo que da el chip contra el ángulo ideal, por modelo y distancia.",
    "res_src_intro": "El acierto cae con la distancia, que es lo esperado: el gradiente se debilita y el offset del comparador pesa más.",
    "res_src_tab": ["Modelo", "Distancia", "Chip", "Ideal", "Acierto"],
    "res_src_pie": "Lo que hay que leer es la ÚLTIMA COLUMNA de grados, no las dos primeras. «Chip» es el ángulo que sale de las tensiones simuladas de los cuatro puentes; «Ideal» es el mismo cálculo sobre lecturas analíticas, sin circuito. Ninguno de los dos es cero, y el culpable no es el circuito: el chip no mide el gradiente en un punto, hace una DIFERENCIA FINITA sobre una caja de 1 mm, y a 3 mm de la fuente el campo se curva tanto sobre esa caja que un chip perfecto ya falla 14°. Lo que pone el circuito es la resta: +0.25° a 3 mm, +7.48° a 12 mm.",

    "res_geo_t": "RESULTADO · GEOMETRÍA DE LA CAJA",
    "res_geo_e": "Acierto en el sentido, por caja y nivel de gradiente.",
    "res_geo_tab": ["Caja Lxy × Lz [µm]", "Gradiente bajo", "Gradiente alto"],
    "res_geo_pie": "Con gradiente alto la caja de 1000 × 1000 llega al 97.8 %. Achatar la caja (Lz 500) siempre cuesta acierto, porque el eje z queda peor resuelto que x-y.",

    "lim_t": "DÓNDE SE ROMPE, Y BAJO QUÉ CONDICIÓN",
    "lim_e": "Un banco hecho para llevar al límite ese fallo, y sólo ese.",
    "lim_pie": "Tres familias con el MISMO margen entre los dos que compiten y la tercera lectura aparcada donde no compite: A par abajo a fondo de escala, B par abajo a media, C par arriba a media. A contra B separa el raíl del tamaño; B contra C separa los dos raíles a igual tamaño.",

    "cond_filas": [
        ("a raíles opuestos, el mayor a 0.6", "6", "100 %", "100 %", "> 2.00 %"),
        ("a raíles opuestos, el mayor a 1.0", "3", "100 %", "100 %", "> 2.00 %"),
        ("los dos hacia ARRIBA, el mayor a 0.6", "3", "100 %", "100 %", "> 2.00 %"),
        ("los dos hacia ABAJO, el mayor a 0.6", "3", "100 %", "100 %", "> 2.00 %"),
        ("los dos hacia ABAJO, el mayor a 1.0", "9", "86.2 %", "83.6 %", "1.38 / 1.26 %"),
    ],
    "g2res_filas": [
        ("Eje decodificado correcto, barrido de rotación", "95.42 %", "93.34 %", "figuras_trazabilidad.py"),
        ("Esquemático y layout coinciden", "97.92 % del barrido", "7.5° de desacuerdo", "figuras_trazabilidad.py"),
        ("Error de frontera de sector", "5.25°", "7.75°", "figuras_trazabilidad.py"),
        ("Los 24 casos de octante, saturación incluida", "94.8 %", "93.8 %", "figuras_octantes.py"),
        ("Alcance dR/R fuera de la esquina mala", "> 2.00 %", "> 2.00 %", "figuras_limite.py"),
        ("… y dentro de ella", "1.38 %", "1.26 %", "figuras_limite.py"),
        ("Suelo por ruido del amplificador", "44.4 ppm de dR/R", "222 µVrms a la entrada", "figuras_campo.py"),
        ("Amplificador: ganancia y reposo", "494 V/V sobre dR/R", "0.72 V (4.24 ↑ / 0.68 ↓)", "oct_*.txt"),
        ("Consumo de la cadena, ventana fina", "17.851 mW", "17.286 mW", "analizar.py"),
    ],
    "pdn_filas": [
        ("Metal4 vertical · VDD", "48.08 µm", "32.21 mA"),
        ("Metal4 vertical · VSS", "46.89 µm", "31.42 mA"),
        ("Metal5 horizontal · VDD", "39.95 µm", "59.92 mA"),
        ("Metal5 horizontal · VSS", "78.14 µm", "117.21 mA"),
        ("Pin del bloque · VDD", "3 puertos, 29.95 µm", "44.92 mA"),
        ("Pin del bloque · VSS", "4 puertos, 39.07 µm", "58.61 mA"),
        ("Vías Metal3–Metal4", "960–1130 cortes", "173–203 mA"),
        ("Vías Metal4–Metal5", "4704–5742 cortes", "847–1034 mA"),
    ],

    "g2res_t": "GRADIENT2, TODO LO MEDIDO",
    "g2res_e": "La corrida del 2026-09-07, con la procedencia de cada cifra.",
    "g2res_tab": ["Medida", "Esquemático", "Layout", "De dónde sale"],
    "g2res_pie": "La última columna importa: son cifras de guiones distintos y con denominadores distintos. El 95.42 % cuenta todo el barrido; el 94.8 % de octantes cuenta 24 casos de amplitud; el alcance es el dR/R hasta donde no falla ni una vez. Mezclarlas sin decirlo es como se acaba comparando dos cosas que no se comparan.",

    "lim2_e": "Los mismos doce casos en números: el margen que aguanta cada condición.",
    "lim_tab": ["Familia — condición", "Margen d", "Esquemático", "Layout"],
    "lim2_pie": "B contra C, mismo tamaño y sólo cambia el raíl: hacia arriba no falla nunca; hacia abajo falla en cuanto el margen baja de 0.20. A contra B, mismo raíl y sólo cambia el tamaño: con el mismo margen de 0.40, a media escala no falla y a fondo de escala se queda en 1.38 %. Hacen falta las dos.",

    "cond_t": "POR QUÉ UNOS CASOS FALLAN Y OTROS NO",
    "cond_e": "Los mismos 24 casos, agrupados por la condición que los distingue.",
    "cond_tab": ["Los dos que compiten por ser el menor", "Casos", "Esquemático", "Layout", "Alcance"],
    "cond_pie": "El amplificador reposa en 0.72 V: tiene 4.24 V de recorrido hacia arriba y sólo 0.68 hacia abajo. Por eso hace falta que se cumplan LAS DOS condiciones —hacia abajo Y a fondo de escala— para que falle; con una sola, acierta siempre.",

    "pdn_t": "LA ALIMENTACIÓN DEL BLOQUE",
    "pdn_e": "Dimensionada al doble del pico medido: 31 mA contra 15.50 mA.",
    "pdn_tab": ["Conductor", "Sección", "Capacidad"],
    "pdn_pie": "Las filas van espejadas, así que cada canal lleva un solo net y los raíles abutan: la separación entre VDD y VSS pasa de 2 µm a 43.46 µm. Los límites salen del tech-LEF del PDK y ninguna regla del DRC los comprueba.",

    "verif_t": "VERIFICACIÓN FÍSICA",
    "verif_e": "Sobre B26_A_filled4.gds, el fichero que se entrega.",
    "verif_tab": ["Comprobación", "Resultado"],
    "verif_pie": "Todo medido sobre B26_A_filled4.gds, el fichero que se entrega, y archivado bajo su propio nombre. El DRC de firma en los dos modos de conectividad se corrió sobre la versión anterior, _filled3, y NO se ha vuelto a correr sobre esta: lo que sí está sobre _filled4 es el de 63 tablas, 0 violaciones.",

    "conc_t": "LO ESPERADO CONTRA LO MEDIDO",
    "conc_e": "Tres cosas que la simulación encontró y el diseño corrigió.",
    "conc": [
        ("1 · Se esperaba que XP y XN correspondieran a su nombre. No era así.", True),
        "El banco destapó que estaban cambiados respecto a la etiqueta. Corregido en el esquemático.",
        ("2 · Se esperaba que el umbral de decisión estuviera centrado. Estaba mal puesto.", True),
        "El barrido de disparo lo midió y se reajustó.",
        ("3 · Se esperaba que los tres ejes compitieran en igualdad. Z no podía ganar nunca.", True),
        "Y su propio WEIGHT no lo arreglaba: lo que lo arregló fue cambiar el orden dentro de cada trío.",
        ("Los tres se encontraron simulando, no revisando. Ese es el argumento a favor de los bancos.", True),
    ],

    "abierto_t": "LO QUE NO CERRÓ",
    "abierto_e": "Dicho con la misma claridad que lo que salió bien.",
    "abierto": [
        ("El LVS de KLayout sobre el top no termina la extracción.", True),
        "Tres intentos en una máquina de 31 GB: 2h33m sobre el GDS relleno, y 1h04m y 30m52 sobre el GDS sin rellenar. Ninguno llegó a la fase de comparación.",
        ("No es falta de memoria: cada proceso se quedó en ~540 MB con 31 GB libres.", True),
        "Es número de nets, no tamaño de máquina.",
        ("Lo que sí casa: netgen dice Circuits match uniquely sobre los mismos 1442 dispositivos, clase por clase.", True),
        "Importa para la entrega porque el LVS externo del chipathon corre el deck de KLayout, no netgen.",
    ],

    "cierre_t": "ESTADO",
    "cierre": [
        ("El chip está terminado y verificado.", True),
        "DRC limpio, LVS netgen casando único sobre 1442 dispositivos y 894 nets, 17 de 17 pines conducen, y los cuatro conductores de alimentación dan 31 mA —el doble del pico medido— en el PEOR corte de cada eje, no en el centro.",
        "Entregable: B26_A_filled4.gds, sha 543d31ff, archivado en integration/gds/2026-09-08_01. Es a lo que apuntan lvs_config.json e info.yaml.",
    ],

    # --- added when the deck was restructured around the block hierarchy -----
    "esp_t": "ESPECIFICACIONES",
    "esp_e": "Lo que entra, lo que sale y lo que cuesta.",
    "esp_cab": ["Parámetro", "Valor"],
    "esp_pie": "Los 6 V son la clase de dispositivo, no el punto de trabajo: "
               "todo se simula y se mide a 5.0 V.",

    "arq_t": "ARQUITECTURA",
    "arq_e": "Del sensor al actuador, y qué parte de eso es este chip.",
    "arq": [
        ("Cuatro sensores de gradiente, un calculador de pesos, un puente en H.", True),
        "Cada bloque de sensado lee TRES de los cuatro puentes, en combinaciones "
        "distintas, y entrega su voto para X, Y y Z.",
        ("El chip termina en las seis salidas digitales.", True),
        "El puente en H y los actuadores magnéticos son externos: el chip dice "
        "hacia dónde, y quien mueve es el puente.",
    ],

    "nav_int_t": "GRADIENT_NAV2_V3 POR DENTRO",
    "nav_int_e": "4 × GRADIENT2  →  3 × WEIGHT  →  3 × COMP_OUT.",

    "g2_t": "BLOQUE 1 · SENSADO DE GRADIENTE",
    "g2_e": "GRADIENT2 — tres amplificadores, tres comparadores y un decodificador.",
    "g2": [
        ("Un bloque de sensado lee tres puentes y decide un eje.", True),
        "Los tres OPAM_LIN amplifican las tres diferencias de puente. Los tres "
        "COMP las comparan POR PARES — X con Y, X con Z, Y con Z — y el "
        "DECODER convierte ese orden en un eje ganador.",
        ("Comparar por pares, y no contra un umbral, es la decisión de diseño.", True),
        "El decodificador no necesita saber cuánto vale cada eje, solo cuál es "
        "mayor. Eso hace la decisión inmune a la ganancia absoluta y al offset "
        "común de los tres canales.",
        ("Hay cuatro de estos bloques, uno por cada trío de sensores.", True),
    ],

    "res_g2_t": "RESULTADO DEL BLOQUE · SENSADO DE GRADIENTE",
    "res_g2_e": "El gradiente rotatorio: cómo decide X, Y y Z por sí solo.",

    "wei_t": "BLOQUE 2 · WEIGHT",
    "wei_e": "El contador de votos: cuatro cadenas votan, un eje suma.",
    "cout_t": "BLOQUE 3 · COMP_OUT",
    "cout_e": "La etapa de salida: tres inversores y el par digital del eje.",

    "esd_t": "ESD_CDM · PROTECCIÓN SECUNDARIA",
    "esd_e": "Fuera de la cadena de señal, pero dentro del área de usuario.",
    "esd": [
        ("Once instancias, una por cada pad analógico.", True),
        "Los pads analógicos del PDK traen solo diodos HBM, así que la red CDM "
        "—resistencia de poly en serie más diodos— hay que ponerla nosotros, y "
        "va JUNTO al pad: lo que quede entre el pad y el clamp está sin proteger.",
        ("El circuito es el de los organizadores; el dibujo es nuestro.", True),
        "Sus tres celdas publicadas violan MSLOT.1, y nadie lo había visto "
        "porque la tabla mslot del PDK se cae antes de llegar. La nuestra ocupa "
        "1762 µm² contra 6457: unos 52 000 µm² de área de usuario recuperados.",
        ("Aquí se fusionaron las nwells.", True),
        "Los cuatro pozos estaban a 1.330 µm, que solo vale si el verificador "
        "sabe que son equipotenciales. Ahora son uno solo y pasa en los dos modos.",
    ],
    "dim_pie": "Dimensiones medidas sobre el GDS con KLayout.",
    "tra_t": "TRAZABILIDAD DEL SENSADO",
    "tra_e": "Una señal, cuatro etapas: puente → amplificador → comparador → decodificador.",
    "tra": [
        ("Se sigue la MISMA señal por las cuatro etapas del bloque de sensado.", True),
        "El banco ya registra cada nodo intermedio, incluidos los que no tienen "
        "nombre: las salidas de los comparadores se sondean jerárquicamente.",
        ("En cada etapa, el esquemático y el layout uno encima del otro.", True),
        "Solo con el amplificador lineal: G2, el esquemático, contra G4, el "
        "layout.",
        ("Y al final, en qué porcentaje del barrido el eje decodificado es el "
         "correcto.", True),
    ],
    "pie_fuente": "Fuente:",
}

EN = {
    "idioma": "EN",
    "portada_t": "TEAM ZOTNETIC",
    "portada_s": "B26 · Magnetic gradient navigator in GF180MCU",
    "portada_l": [
        "SSCS Chipathon 2026 · UCI Samueli School of Engineering",
        "Lead: Juan Sánchez · An Bui · Enzo Li · Akam Khinda · Aysha Hussaini",
        "Design, simulation and verification report",
    ],

    "s1": "WHAT THE CHIP DOES",
    "s1_b": "Four sensors read the magnitude of the field. The chip works out which way it grows.",
    "s2": "THE THREE BLOCKS",
    "s2_b": "GRADIENT_NAV2 inside: each block with its diagram, its schematic, its layout and its simulations.",
    "s3": "FULL-SYSTEM RESULTS",
    "s3_b": "The whole system, always layout against schematic.",
    "s4": "THE TEST BENCHES",
    "s4_b": "What is driven, how the sensor is modelled, and what number is being looked for.",
    "s5": "FULL-SYSTEM TEST",
    "s5_b": "From an imposed gradient to a real source sitting somewhere.",
    "s6": "PHYSICAL VERIFICATION",
    "s6_b": "DRC, LVS, connectivity and current density on the file that ships.",
    "s7": "CONCLUSIONS",
    "s7_b": "Expected against measured, including what did not close.",

    "idea_t": "THE PRINCIPLE",
    "idea_e": "The sensors do not measure a vector: they measure magnitude. That distinction is the whole design.",
    "idea": [
        ("Four magnetoresistive bridges read |B| at the vertices of a tetrahedron.", True),
        "Each bridge gives a voltage proportional to dR/R, that is to the magnitude of the field at its vertex, not to its direction.",
        ("Comparing the four magnitudes reconstructs grad|B|.", True),
        "The gradient of the magnitude points where the field grows, and the field grows towards the source. That is how the chip can point at a magnet without ever measuring a vector.",
        ("The output is one sign per axis: XP/XN, YP/YN, ZP/ZN.", True),
        "Six digital outputs. It does not say how much, it says which way.",
    ],

    "cadena_t": "THE SIGNAL CHAIN",
    "cadena_e": "From the bridges to the six digital outputs.",
    "cadena": [
        ("Bridges → OPAM_LIN_flat → WEIGHT_COMP → DECODER → COMP → outputs", True),
        "OPAM_LIN_flat: 40 dB linear amplifier. This is the one instantiated; the 98 dB part was dropped because it saturates earlier.",
        "WEIGHT_COMP: current-mode vote counter. It combines the readings of three sensors per axis.",
        "DECODER: decides which axis wins. DECODER_MAX is the variant that picks the maximum.",
        "COMP: comparator that turns the decision into each axis's digital pair.",
        "ESD_CDM: secondary protection beside every pad. Eleven instances, drawn by us to the organisers' exact schematic.",
    ],

    "modelo_t": "HOW THE SENSOR IS MODELLED",
    "modelo_e": "Common to every bench. It is what makes the curves readable without ambiguity.",
    "modelo": [
        ("Full bridge: the four 1 MΩ arms vary together.", True),
        "VEXC —R(1−b)— SkP —R(1+b)— GND      →   V(SkP) = VEXC·(1+b)/2",
        "VEXC —R(1+b)— SkN —R(1−b)— GND      →   V(SkN) = VEXC·(1−b)/2",
        ("From which Vdiff = VEXC·b  and  Vcm = VEXC/2 exactly, independent of b.", True),
        "The second is what matters: if the common mode moved with the signal it would mix with these cells' common-mode sensitivity, and there would be no way to separate the two when reading the curve.",
        "b is literally dR/R.",
    ],

    "grad_t": "GRADIENT BENCH · METHOD",
    "grad_e": "run_gradient.sh — three bridges, and only the linear amplifier.",
    "grad": [
        ("Two chains hung off the SAME six sensor nodes:", True),
        "G2 — the schematic GRADIENT2, with the 40 dB OPAM_LIN",
        "G4 — the same circuit rebuilt from the v2 layout, with OPAM_LIN_flat "
        "and extracted with RC parasitics",
        ("It is the same amplifier drawn two ways.", True),
        "So every comparison in this section is layout against schematic, never "
        "one amplifier against another.",
        ("What it measures: the three fields are 120° apart, sum to zero, and "
         "the vector only changes direction.", True),
        "Sweeping 0 to 360° each axis should win a sector of exactly 120°. The "
        "figures are how far those three boundaries drift and on what "
        "percentage of the sweep the decoded axis is the right one.",
    ],

    "nav_t": "NAVIGATOR BENCH · METHOD",
    "nav_e": "run_nav2.sh — four bridges against two navigators. It is also the layout-vs-schematic comparison.",
    "nav": [
        ("Two navigators on the same eight sensor nodes:", True),
        "N_esq — the schematic GRADIENT_NAV2, supply VDDS",
        "N_lay — the same circuit rebuilt from the v2 layout and extracted WITH RC PARASITICS, supply VDDR",
        ("Four sensors at 0, 90, 180 and 270°, and the field turning from 0 to 360°.", True),
        "Each of the four chains reads THREE of the four sensors, in different combinations, and the three weights combine their outputs.",
        ("What it measures: on what percentage of the sweep the nine schematic outputs agree with the layout ones, and where they do not, how many degrees wide the disagreement is.", True),
    ],

    "geo_t": "GEOMETRY BENCH · METHOD",
    "geo_e": "run_nav2_geo.sh — how the navigator depends on the box the sensors sit in.",
    "geo": [
        ("The four sensors sit at the vertices of the tetrahedron inscribed in a box Lxy × Lxy × Lz.", True),
        "Six combinations: Lxy of 1000, 2000 and 3000 µm, and Lz of 500 and 1000 µm.",
        ("1 · Resolution.", True),
        "For each box and each gradient level the direction is swept 360° and we count on what fraction it gets the axis right. From that curve comes one number: the smallest gradient at which accuracy reaches 95 %. It captures both limits at once — from below the comparator offset, from above the amplifier's saturation — without depending on any borrowed definition.",
        ("2 · The same in the X-Y plane, where Lz plays no part.", True),
        "It separates the x-y resolution from the z one.",
        ("3 · Background.", True),
        "Earth's field is common to all four sensors, so it cancels in the comparison but NOT in the amplifier, which sees all of it. It is swept to find the level at which the measurement is lost.",
    ],

    "src_t": "SOURCE BENCH · METHOD",
    "src_e": "run_fuente.sh — does the chip point at it? This is the question it exists to answer.",
    "src": [
        ("Everything so far imposed a uniform gradient in a direction. Here the field comes from a source sitting somewhere and each sensor reads the magnitude at its own vertex.", True),
        ("Two models, and the pair is the method:", True),
        "SYMMETRIC — |B| depends on distance only, so grad|B| points EXACTLY at the source. Whatever error comes out is the chip's.",
        "REAL DIPOLE — axis along +z. |B| depends on the angle too, and grad|B| does NOT point exactly at the source, not even with a perfect chip.",
        ("The difference between the two numbers separates the error of the circuit from the error of the physics.", True),
        "Which is what you need before believing anything measured with a real magnet.",
        "42 sweeps: three distances, seven azimuths, both models.",
    ],

    "res_lay_t": "RESULT · LAYOUT AGAINST SCHEMATIC",
    "salida_e": "The six digital pins: three decisions and their complements.",
    "salida": [
        ("XP high means \u00abthis axis wins\u00bb. XN is its inverse, not \u00abthe other sense\u00bb.", True),
        "COMP_OUT is OUT = buffer(IN) and OUT_N = NOT(IN), instantiated as x8 VDD XN X XP VSS. The pair is redundant by construction: reading XP is enough, and XN is there to drive the H-bridge directly.",
        ("The chip answers WHICH AXIS, not which way along it.", True),
        "The decoder puts out the axis whose bridge reads LEAST, the vertex upstream of the gradient. That identifies one axis out of three, not one sense out of six.",
        ("Telling +X from \u2212X needs one more comparison.", True),
        "That is what GRADIENT_NAV3 adds, comparing components instead of readings, and it does give the six senses. It is not instantiated on this die.",
    ],

    "v3_t": "THE IMPROVEMENT, NOW IN THE DIE",
    "v3_e": "Reordering the sensor ports: 76.2 % to 90.7 %, without touching a single cell. It is the core that ships.",

    "res_lay_e": "721 points from 0 to 360°. The dashed orange is the layout extracted with parasitics.",
    "res_lay": [
        ("The six digital outputs agree on 99.58 % of the sweep.", True),
        "The layout's four GRADIENT2 blocks, extracted with RC parasitics, decide what the schematic's do. The whole analogue chain - amplifier, comparator, decoder - reproduces the schematic.",
        ("All three axes level: 99.72 % each.", True),
        "In the earlier version they were 99.45 % on X and Y and 98.89 % on Z - Z lagged. With the v3 port order the three come level, and the disagreement drops from 2-4 degrees to 1.5, all of it on the sector boundaries where the decision is on a knife edge.",
        ("Worst-case deviation at the counter node: 693.8 mV.", True),
        "Power: 74.85 mW schematic, 74.82 mW layout. Three hundredths apart: the RC parasitics do not move the operating point appreciably.",
    ],

    "res_src_t": "RESULT · DOES IT POINT AT THE SOURCE?",
    "res_src_e": "Angle the chip gives against the ideal angle, by model and distance.",
    "res_src_intro": "Accuracy falls with distance, as expected: the gradient weakens and the comparator offset weighs more.",
    "res_src_tab": ["Model", "Distance", "Chip", "Ideal", "Accuracy"],
    "res_src_pie": "Read the LAST degrees column, not the first two. \u00abChip\u00bb is the angle out of the four simulated bridge voltages; \u00abIdeal\u00bb is the same computation on analytical readings, with no circuit. Neither is zero, and the circuit is not why: the chip does not measure the gradient at a point, it takes a FINITE DIFFERENCE over a 1 mm box, and 3 mm from the source the field curves so sharply across that box that a perfect chip already misses by 14°. What the circuit adds is the difference: +0.25° at 3 mm, +7.48° at 12 mm.",

    "res_geo_t": "RESULT · GEOMETRY OF THE BOX",
    "res_geo_e": "Accuracy on the direction, by box and gradient level.",
    "res_geo_tab": ["Box Lxy × Lz [µm]", "Low gradient", "High gradient"],
    "res_geo_pie": "At high gradient the 1000 × 1000 box reaches 97.8 %. Flattening the box (Lz 500) always costs accuracy, because the z axis ends up worse resolved than x-y.",

    "lim_t": "WHERE IT BREAKS, AND UNDER WHICH CONDITION",
    "lim_e": "A bench built to push that one failure to its limit, and nothing else.",
    "lim_pie": "Three families with the SAME margin between the two contenders and the third reading parked where it cannot compete: A pair down at full scale, B pair down at half, C pair up at half. A against B separates the rail from the size; B against C separates the two rails at equal size.",

    "cond_filas": [
        ("to OPPOSITE rails, larger one at 0.6", "6", "100 %", "100 %", "> 2.00 %"),
        ("to OPPOSITE rails, larger one at 1.0", "3", "100 %", "100 %", "> 2.00 %"),
        ("both heading UP, larger one at 0.6", "3", "100 %", "100 %", "> 2.00 %"),
        ("both heading DOWN, larger one at 0.6", "3", "100 %", "100 %", "> 2.00 %"),
        ("both heading DOWN, larger one at 1.0", "9", "86.2 %", "83.6 %", "1.38 / 1.26 %"),
    ],
    "g2res_filas": [
        ("Decoded axis correct, rotation sweep", "95.42 %", "93.34 %", "figuras_trazabilidad.py"),
        ("Schematic and layout agree", "97.92 % of the sweep", "7.5° of disagreement", "figuras_trazabilidad.py"),
        ("Sector boundary error", "5.25°", "7.75°", "figuras_trazabilidad.py"),
        ("The 24 octant cases, saturation included", "94.8 %", "93.8 %", "figuras_octantes.py"),
        ("Reach in dR/R outside the bad corner", "> 2.00 %", "> 2.00 %", "figuras_limite.py"),
        ("… and inside it", "1.38 %", "1.26 %", "figuras_limite.py"),
        ("Noise floor of the amplifier", "44.4 ppm of dR/R", "222 µVrms input referred", "figuras_campo.py"),
        ("Amplifier: gain and quiescent output", "494 V/V on dR/R", "0.72 V (4.24 ↑ / 0.68 ↓)", "oct_*.txt"),
        ("Chain power, fine window", "17.851 mW", "17.286 mW", "analizar.py"),
    ],
    "pdn_filas": [
        ("Metal4 vertical · VDD", "48.08 µm", "32.21 mA"),
        ("Metal4 vertical · VSS", "46.89 µm", "31.42 mA"),
        ("Metal5 horizontal · VDD", "39.95 µm", "59.92 mA"),
        ("Metal5 horizontal · VSS", "78.14 µm", "117.21 mA"),
        ("Block pin · VDD", "3 ports, 29.95 µm", "44.92 mA"),
        ("Block pin · VSS", "4 ports, 39.07 µm", "58.61 mA"),
        ("Metal3–Metal4 vias", "960–1130 cuts", "173–203 mA"),
        ("Metal4–Metal5 vias", "4704–5742 cuts", "847–1034 mA"),
    ],

    "g2res_t": "GRADIENT2, EVERYTHING MEASURED",
    "g2res_e": "The 2026-09-07 run, with where each figure comes from.",
    "g2res_tab": ["Measurement", "Schematic", "Layout", "Where it comes from"],
    "g2res_pie": "That last column matters: these come from different scripts with different denominators. The 95.42 % counts the whole sweep; the 94.8 % counts 24 amplitude cases; the reach is the dR/R up to which it never fails once. Mixing them silently is how two things that do not compare end up compared.",

    "lim2_e": "The same twelve cases in numbers: the margin each condition survives.",
    "lim_tab": ["Family — condition", "Margin d", "Schematic", "Layout"],
    "lim2_pie": "B against C, same size and only the rail changes: heading up it never fails; heading down it fails as soon as the margin drops below 0.20. A against B, same rail and only the size changes: at the same 0.40 margin, half scale never fails and full scale stops at 1.38 %. Both conditions are needed.",

    "cond_t": "WHY SOME CASES FAIL AND OTHERS DO NOT",
    "cond_e": "The same 24 cases, grouped by the condition that tells them apart.",
    "cond_tab": ["The two contending for smallest", "Cases", "Schematic", "Layout", "Reach"],
    "cond_pie": "The amplifier rests at 0.72 V: 4.24 V of room upward and only 0.68 downward. That is why BOTH conditions have to hold — heading down AND at full scale — for it to fail; with either one alone it is always right.",

    "pdn_t": "THE BLOCK'S POWER DISTRIBUTION",
    "pdn_e": "Sized for double the measured peak: 31 mA against 15.50 mA.",
    "pdn_tab": ["Conductor", "Section", "Capacity"],
    "pdn_pie": "The rows are mirrored, so each channel carries one net and the rails abut: VDD-to-VSS separation goes from 2 \u00b5m to 43.46 \u00b5m. The limits come from the PDK's tech-LEF and no DRC rule checks them.",

    "verif_t": "PHYSICAL VERIFICATION",
    "verif_e": "On B26_A_filled4.gds, the file that ships.",
    "verif_tab": ["Check", "Result"],
    "verif_pie": "All of it measured on B26_A_filled4.gds, the file that ships, and archived under its own name. The sign-off DRC in both connectivity modes was run on the previous version, _filled3, and has NOT been re-run on this one: what is on _filled4 is the split-table deck, 63 tables, 0 violations.",

    "conc_t": "EXPECTED AGAINST MEASURED",
    "conc_e": "Three things simulation found and the design corrected.",
    "conc": [
        ("1 · XP and XN were expected to match their names. They did not.", True),
        "The bench uncovered that they were swapped with respect to the label. Corrected in the schematic.",
        ("2 · The decision threshold was expected to be centred. It was misplaced.", True),
        "The trip sweep measured it and it was readjusted.",
        ("3 · The three axes were expected to compete on equal terms. Z could never win.", True),
        "And its own WEIGHT did not fix it: what fixed it was changing the order within each triple.",
        ("All three were found by simulating, not by reviewing. That is the argument for the benches.", True),
    ],

    "abierto_t": "WHAT DID NOT CLOSE",
    "abierto_e": "Said as plainly as what went right.",
    "abierto": [
        ("The KLayout LVS on the top does not finish the extraction.", True),
        "Three attempts on a 31 GB machine: 2h33m on the filled GDS, then 1h04m and 30m52 on the unfilled one. None reached the compare stage.",
        ("Not a memory problem: each process sat at ~540 MB with 31 GB free.", True),
        "It is net count, not machine size.",
        ("What does match: netgen says Circuits match uniquely on the same 1442 devices, class by class.", True),
        "It matters for the submission because the chipathon's external LVS runs the KLayout deck, not netgen.",
    ],

    "cierre_t": "STATUS",
    "cierre": [
        ("The chip is finished and verified.", True),
        "DRC clean, netgen LVS matching uniquely over 1442 devices and 894 nets, 17 of 17 pins conducting, and all four supply conductors carrying 31 mA \u2014 double the measured peak \u2014 at the WORST cut of each axis, not at the middle.",
        "Deliverable: B26_A_filled4.gds, sha 543d31ff, archived under integration/gds/2026-09-08_01. It is what lvs_config.json and info.yaml point at.",
    ],

    # --- added when the deck was restructured around the block hierarchy -----
    "esp_t": "SPECIFICATIONS",
    "esp_e": "What goes in, what comes out and what it costs.",
    "esp_cab": ["Parameter", "Value"],
    "esp_pie": "The 6 V is the device class, not the operating point: "
               "everything is simulated and measured at 5.0 V.",

    "arq_t": "ARCHITECTURE",
    "arq_e": "From sensor to actuator, and which part of that is this chip.",
    "arq": [
        ("Four gradient sensors, a weight calculator, an H-bridge.", True),
        "Each sensing block reads THREE of the four bridges, in different "
        "combinations, and delivers its vote for X, Y and Z.",
        ("The chip ends at the six digital outputs.", True),
        "The H-bridge and the magnetic actuators are external: the chip says "
        "which way, and the bridge is what moves.",
    ],

    "nav_int_t": "GRADIENT_NAV2_V3 INSIDE",
    "nav_int_e": "4 × GRADIENT2  →  3 × WEIGHT  →  3 × COMP_OUT.",

    "g2_t": "BLOCK 1 · GRADIENT SENSING",
    "g2_e": "GRADIENT2 — three amplifiers, three comparators and a decoder.",
    "g2": [
        ("One sensing block reads three bridges and decides an axis.", True),
        "The three OPAM_LIN amplify the three bridge differences. The three "
        "COMP compare them PAIRWISE — X with Y, X with Z, Y with Z — and the "
        "DECODER turns that order into a winning axis.",
        ("Comparing pairwise, rather than against a threshold, is the design "
         "decision.", True),
        "The decoder does not need to know what each axis is worth, only which "
        "is larger. That makes the decision immune to absolute gain and to any "
        "offset common to the three channels.",
        ("There are four of these blocks, one per sensor triple.", True),
    ],

    "res_g2_t": "BLOCK RESULT · GRADIENT SENSING",
    "res_g2_e": "The rotating gradient: how it decides X, Y and Z on its own.",

    "wei_t": "BLOCK 2 · WEIGHT",
    "wei_e": "The vote counter: four chains vote, one axis sums.",
    "cout_t": "BLOCK 3 · COMP_OUT",
    "cout_e": "The output stage: three inverters and the axis's digital pair.",

    "esd_t": "ESD_CDM · SECONDARY PROTECTION",
    "esd_e": "Outside the signal chain, but inside the user area.",
    "esd": [
        ("Eleven instances, one per analogue pad.", True),
        "The PDK's analogue pads carry HBM diodes only, so the CDM network — a "
        "series poly resistor plus diodes — is ours to add, and it goes BESIDE "
        "the pad: whatever sits between pad and clamp is unprotected.",
        ("The circuit is the organisers'; the drawing is ours.", True),
        "All three of their published cells violate MSLOT.1, and nobody had "
        "seen it because the PDK's mslot table crashes before reaching them. "
        "Ours is 1762 µm² against 6457: about 52,000 µm² of user area back.",
        ("This is where the n-wells were merged.", True),
        "The four wells sat 1.330 µm apart, which is fine only if the checker "
        "knows they are equipotential. They are one well now and it passes in "
        "both modes.",
    ],
    "dim_pie": "Dimensions measured on the GDS with KLayout.",
    "tra_t": "SENSING TRACEABILITY",
    "tra_e": "One signal, four stages: bridge → amplifier → comparator → decoder.",
    "tra": [
        ("The SAME signal is followed through the sensing block's four stages.", True),
        "The bench already records every intermediate node, including the ones "
        "with no name: the comparator outputs are probed hierarchically.",
        ("At each stage, schematic and layout on top of each other.", True),
        "Only the linear amplifier: G2, the schematic, against G4, the layout.",
        ("And at the end, on what percentage of the sweep the decoded axis is "
         "the right one.", True),
    ],
    "pie_fuente": "Source:",
}
