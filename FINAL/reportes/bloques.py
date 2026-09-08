#!/usr/bin/env python3
"""Per-block data sheets: what each one does, its supply, power and size.

Kept apart from `textos.py` because these are FACTS with a source, not prose.
Every number here is traceable and was measured, not quoted from a datasheet:

  * areas          klayout `dbbox()` on layouts_v2/<block>/<block>_flat_gf180.gds
  * power          figuras_bloques.py, printed when it runs
  * gain, BW, PM   figuras_bloques.py, from test_opam_g100_ac.sch/ac.txt
  * supply         5.0 V, the value every bench sources (VDD, VEXC)
  * pin counts     the block's own .sym

A NOTE ON THE SUPPLY. `info.yaml` comments VDD as "6 V supply". That is the
DEVICE CLASS -- everything is gf180mcu 06v0 -- not the operating point. Every
simulation in this project runs at 5.0 V, so 5.0 V is what the report states,
with the 6 V devices mentioned as headroom.

Spanish first, English second, on the same line, exactly as `textos.py`.
"""

from __future__ import annotations

#: The chip's specification table. Replaces the old signal-chain slide: a list
#: of block names told the reader nothing they could not read off the next
#: section, and this is the thing an outsider actually asks for.
ESPECIFICACIONES = {
    "ES": [
        ("Tecnología", "GF180MCU-D, dispositivos de 6 V"),
        ("Alimentación", "5.0 V (VDD / VSS), medida a 5.0 V en todos los bancos"),
        ("Consumo total", "74.02 mW esquemático · 74.03 mW layout (14.81 mA)"),
        ("Área entregada", "1110 × 1110 µm = 1.232 mm² (área de usuario B26_A)"),
        ("Área del navegador", "460.9 × 387.0 µm = 0.178 mm² (GRADIENT_NAV2)"),
        ("Entradas analógicas", "8 — S1P/S1N … S4P/S4N, cuatro puentes magnetorresistivos"),
        ("Puntos de prueba", "3 — X, Y, Z, contadores de votos entre 1.814 y 3.035 V"),
        ("Salidas digitales", "6 — XP/XN, YP/YN, ZP/ZN, de raíl a raíl"),
        ("Pads", "11 analógicos + 6 digitales + 2 de alimentación = 19"),
        ("Tipo de pad analógico", "analog, con ESD secundaria propia (ESD_CDM)"),
        ("Tipo de pad digital", "bidirectional, permanentemente en salida"),
        ("ESD secundaria", "ESD_CDM, 63.2 × 27.9 µm, 8 diodos + 87.5 Ω de poly, 11 instancias"),
    ],
    "EN": [
        ("Technology", "GF180MCU-D, 6 V devices"),
        ("Supply", "5.0 V (VDD / VSS), every bench sourced at 5.0 V"),
        ("Total power", "74.02 mW schematic · 74.03 mW layout (14.81 mA)"),
        ("Delivered area", "1110 × 1110 µm = 1.232 mm² (B26_A user area)"),
        ("Navigator area", "460.9 × 387.0 µm = 0.178 mm² (GRADIENT_NAV2)"),
        ("Analogue inputs", "8 — S1P/S1N … S4P/S4N, four magnetoresistive bridges"),
        ("Test points", "3 — X, Y, Z, vote counters between 1.814 and 3.035 V"),
        ("Digital outputs", "6 — XP/XN, YP/YN, ZP/ZN, rail to rail"),
        ("Pads", "11 analogue + 6 digital + 2 supply = 19"),
        ("Analogue pad type", "analog, with our own secondary ESD (ESD_CDM)"),
        ("Digital pad type", "bidirectional, permanently driving"),
        ("Secondary ESD", "ESD_CDM, 63.2 × 27.9 µm, 8 diodes + 87.5 Ω poly, 11 instances"),
    ],
}

#: Column headers for a block's own data sheet.
FICHA_CAB = {"ES": ["Parámetro", "Valor"], "EN": ["Parameter", "Value"]}


def ficha(es: bool, filas) -> list:
    """Rows as (label_es, label_en, value); a value may itself be (es, en)."""
    def v(x):
        return (x[0] if es else x[1]) if isinstance(x, tuple) else x
    return [(a if es else b, v(c)) for a, b, c in filas]


#: Each block: the figure stems it uses, its data sheet, and what to say.
#:
#: `lay` is the layout figure. WEIGHT and COMP_OUT SHARE one: the cell that was
#: drawn is WEIGHT_COMP, which contains both, and pretending otherwise would be
#: inventing a layout that does not exist.
BLOQUES = {
    "OPAM_LIN": dict(
        titulo="OPAM_LIN",
        sch="sch_OPAM_LIN_flat", lay="layout_OPAM_LIN_flat",
        epi_es="Amplificador lineal de 40 dB. El primer bloque de la cadena.",
        epi_en="40 dB linear amplifier. The first block in the chain.",
        ficha=[
            ("Función", "Function",
             ("amplifica la diferencia de un puente", "amplifies one bridge's difference")),
            ("Alimentación", "Supply", "5.0 V"),
            ("Consumo", "Power", ("2.55 mW esquemático / 2.45 mW layout",
                                  "2.55 mW schematic / 2.45 mW layout")),
            ("Ganancia DC", "DC gain", "40.1 dB (103 V/V)"),
            ("Ancho de banda", "Bandwidth", ("338 kHz a −3 dB", "338 kHz at −3 dB")),
            ("Margen de fase", "Phase margin",
             ("74° (ganancia unidad a 36.9 MHz)", "74° (unity gain at 36.9 MHz)")),
            ("Slew rate", "Slew rate",
             ("no lo limita: un escalón de 2 V sube a 102 V/µs (esq.) y "
              "562 V/µs (layout), y el techo que impone el ancho de banda "
              "por sí solo son 456 V/µs — manda la banda, no la corriente",
              "not slew limited: a 2 V step rises at 102 V/µs (schematic) "
              "and 562 V/µs (layout) against the 456 V/µs the bandwidth "
              "alone allows — the band sets it, not the output current")),
            ("Linealidad", "Linearity",
             ("INL 0.10 % sobre 1–4 V de salida", "INL 0.10 % over the 1–4 V output")),
            ("Ruido a la entrada", "Input-referred noise",
             ("1.95 µV/√Hz a 1 kHz · 222 µVrms en 338 kHz",
              "1.95 µV/√Hz at 1 kHz · 222 µVrms over 338 kHz")),
            ("Área", "Area", "95.88 × 48.05 µm = 0.0046 mm²"),
            ("Instancias", "Instances", ("12 (3 por cada GRADIENT2)", "12 (3 per GRADIENT2)")),
        ],
        desc_es=[
            ("Amplifica la diferencia de un puente, y nada más.", True),
            "Entra el par SkP/SkN de un sensor y sale una sola tensión "
            "proporcional a dR/R. Es el único bloque de la cadena que trabaja "
            "en pequeña señal, así que su linealidad fija la del sistema.",
            ("Por qué 40 dB.", True),
            "La ganancia se eligió por medida, no por gusto: es la que mantiene "
            "la celda dentro de su rango lineal para el margen de entrada que "
            "dan los puentes. Más ganancia satura antes y pierde los cruces, "
            "que es lo único que la decisión necesita.",
            ("El modo común no se mueve con la señal.", True),
            "Que el puente entregue Vcm = VEXC/2 constante es lo que permite "
            "leer estas curvas sin confundir señal con sensibilidad en modo "
            "común.",
        ],
        desc_en=[
            ("It amplifies one bridge's difference, and nothing else.", True),
            "The SkP/SkN pair of a sensor goes in and a single voltage "
            "proportional to dR/R comes out. It is the only small-signal block "
            "in the chain, so its linearity sets the system's.",
            ("Why 40 dB.", True),
            "The gain was chosen on a measurement, not a taste: it is the one "
            "that keeps the cell inside its linear range over the input span "
            "the bridges deliver. More gain saturates earlier and loses the "
            "crossings, which is all the decision needs.",
            ("The common mode does not move with the signal.", True),
            "The bridge delivering a constant Vcm = VEXC/2 is what makes these "
            "curves readable without confusing signal with common-mode "
            "sensitivity.",
        ],
        figs=[
            ("blk_OPAM_LIN_transfer",
             "input against output, and the slope that is the gain",
             "La curva de transferencia y su pendiente. La pendiente ES la "
             "ganancia: 103 V/V en la zona lineal, que son los 40 dB. Las dos "
             "versiones, esquemático y layout, van superpuestas."),
            ("blk_OPAM_LIN_power",
             "supply power",
             "El consumo, 2.5 mW, con su propia fuente en el banco — así que "
             "es el suyo y no el de la cadena entera. La joroba del centro es "
             "el paso por la zona activa."),
            ("blk_OPAM_LIN_bode",
             "frequency response",
             "El Bode. 40.1 dB en continua, −3 dB a 338 kHz y 74° de margen de "
             "fase en el cruce por 0 dB. El margen de fase es lo que dice que "
             "no va a oscilar, y 74° es holgado."),
            ("blk_OPAM_LIN_rejection",
             "rejection and noise",
             "PSRR, CMRR y ruido referido a la entrada, con 1 pF de carga. "
             "Importa porque el campo terrestre entra como modo común y lo "
             "que lo frena es el CMRR."),
            ("blk_OPAM_LIN_linearity",
             "linearity error",
             "Lo que queda al restar la mejor recta: 0.10 % sobre todo el "
             "recorrido de 1 a 4 V. Es el número que justifica llamarlo "
             "amplificador lineal."),
            ("blk_OPAM_LIN_slew",
             "large-signal step",
             "El escalón grande, con paso interno de 20 ps para poder medirlo. "
             "Y el resultado es que este amplificador NO está limitado por slew "
             "a 2 V: el flanco va tan rápido como le permite su ancho de banda. "
             "Por eso la ficha no da una cifra de slew rate — darla sería medir "
             "algo que no está pasando."),
            ("blk_OPAM_LIN_mismatch",
             "device-mismatch Monte Carlo",
             "El offset bajo desapareo de dispositivos, Monte Carlo. Es el "
             "suelo de resolución del sistema: por debajo de este offset la "
             "diferencia entre dos esquinas del tetraedro deja de ser legible."),
        ],
    ),
    "COMP": dict(
        titulo="COMP",
        sch="sch_COMP", lay="layout_COMP",
        epi_es="Comparador. Convierte la comparación entre dos ejes en un nivel.",
        epi_en="Comparator. Turns the comparison of two axes into a level.",
        ficha=[
            ("Función", "Function",
             ("compara dos ejes entre sí", "compares two axes against each other")),
            ("Alimentación", "Supply", "5.0 V"),
            ("Consumo", "Power", "3.08 mW"),
            ("Umbral de entrada", "Input threshold",
             ("+7 µV esquemático / +62 µV layout (cruce por 2.5 V)",
              "+7 µV schematic / +62 µV layout (2.5 V crossing)")),
            ("Entrada para salida alta", "Input for a high output",
             ("+50 µV esquemático / +104 µV layout (>4.5 V)",
              "+50 µV schematic / +104 µV layout (>4.5 V)")),
            ("Retardo de decisión", "Decision delay",
             ("399 ns medio, 456 ns peor caso", "399 ns mean, 456 ns worst case")),
            ("Slew rate", "Slew rate",
             ("6.3 V/µs de subida y de bajada (6.2 en layout); es una rampa "
              "recta durante los 601 ns del flanco",
              "6.3 V/µs rising and falling (6.2 in layout); a straight ramp "
              "over the whole 601 ns edge")),
            ("Ruido", "Noise",
             ("lo fija el amplificador que lleva delante, no esta celda",
              "set by the amplifier ahead of it, not by this cell")),
            ("Área", "Area", "99.60 × 31.46 µm = 0.0031 mm²"),
            ("Instancias", "Instances", ("12 (3 por cada GRADIENT2)", "12 (3 per GRADIENT2)")),
        ],
        desc_es=[
            ("No compara contra un umbral fijo: compara dos ejes entre sí.", True),
            "Por eso hay tres comparadores para tres ejes — X contra Y, X "
            "contra Z, Y contra Z. Al decodificador le hace falta el ORDEN de "
            "los tres, no su valor.",
            ("Aquí vive el umbral que hubo que corregir.", True),
            "El segundo de los tres hallazgos del final salió de este bloque: "
            "el punto de disparo no estaba donde se creía, y el barrido fino "
            "lo midió.",
        ],
        desc_en=[
            ("It does not compare against a fixed threshold: it compares two "
             "axes against each other.", True),
            "That is why three comparators serve three axes — X against Y, X "
            "against Z, Y against Z. The decoder needs the ORDER of the three, "
            "not their values.",
            ("This is where the threshold that had to be corrected lives.", True),
            "The second of the three findings at the end came out of this "
            "block: the trip point was not where it was believed to be, and "
            "the fine sweep measured it.",
        ],
        figs=[
            ("blk_COMP_decision",
             "input sweep against output, and what it costs",
             "El barrido de la entrada contra la salida, que es la gráfica que "
             "pediste. Arriba la excursión completa; en medio la MISMA curva "
             "ampliada a ±500 µV, que es donde de verdad se toma la decisión — "
             "la transición mide 227 µV y la ventana ancha se la salta entera.",
             "El flanco del layout va desplazado respecto al esquemático: +62 µV "
             "contra +7 µV. Eso es offset que introduce el dibujo, y es el que "
             "acaba fijando el campo mínimo que el chip puede resolver."),
            ("blk_COMP_slew",
             "slew rate",
             "El slew rate. Lo que lo hace legítimo es que la pendiente es "
             "constante durante los 601 ns enteros del flanco: 6.3 V/µs subiendo "
             "y bajando. Una rampa recta es la definición de estar limitado por "
             "slew; si fuera una exponencial no habría número que dar."),
            ("blk_COMP_step",
             "step response",
             "La respuesta al escalón: arriba el exceso de entrada, abajo la "
             "salida cruzando la mitad de la alimentación. Da el retardo de "
             "decisión."),
            ("blk_COMP_bode",
             "frequency response",
             "El Bode del comparador en lazo abierto. Se enseña porque un "
             "comparador con poco margen se convierte en un oscilador cuando "
             "la entrada se queda cerca del punto de disparo."),
        ],
    ),
    "DECODER": dict(
        titulo="DECODER",
        sch="sch_DECODER", lay="layout_DECODER",
        epi_es="Decide qué eje gana a partir de las tres comparaciones.",
        epi_en="Decides which axis wins from the three comparisons.",
        ficha=[
            ("Función", "Function",
             ("de tres comparaciones a un eje ganador",
              "three comparisons to one winning axis")),
            ("Alimentación", "Supply", "5.0 V"),
            ("Consumo", "Power", "1.4 µW"),
            ("Área", "Area", "31.76 × 13.82 µm = 0.0004 mm²"),
            ("Instancias", "Instances", ("4 (una por GRADIENT2)", "4 (one per GRADIENT2)")),
        ],
        desc_es=[
            ("Entra XY, XZ, YZ. Sale X, Y o Z.", True),
            "Lógica pura: las tres comparaciones por pares determinan un orden, "
            "y el orden determina el ganador. Es el bloque más pequeño y el "
            "que menos consume de toda la cadena, por tres órdenes de magnitud.",
            ("Aquí apareció el problema del eje Z.", True),
            "Z no podía ganar nunca. Lo que lo arregló no fue subirle el peso "
            "sino cambiar el orden dentro de cada trío.",
        ],
        desc_en=[
            ("XY, XZ, YZ go in. X, Y or Z comes out.", True),
            "Pure logic: the three pairwise comparisons determine an order, and "
            "the order determines the winner. It is the smallest block in the "
            "chain and the lowest-power by three orders of magnitude.",
            ("This is where the Z-axis problem showed up.", True),
            "Z could never win. What fixed it was not raising its weight but "
            "changing the order within each triple.",
        ],
        figs=[
            ("blk_DECODER_logic",
             "logic",
             "Arriba las tres comparaciones que entran, debajo las tres "
             "salidas. Esquemático y layout dan la misma decisión en todo el "
             "recorrido."),
            ("blk_DECODER_power",
             "supply power",
             "El consumo, en microvatios. Es lógica: solo gasta cuando "
             "conmuta, y los picos coinciden exactamente con los cambios de "
             "decisión de la figura anterior."),
        ],
    ),
    "WEIGHT": dict(
        titulo="WEIGHT",
        sch="sch_WEIGHT", lay="layout_WEIGHT_COMP",
        epi_es="Contador de votos en modo corriente. Un bloque por eje.",
        epi_en="Current-mode vote counter. One per axis.",
        ficha=[
            ("Función", "Function",
             ("suma los cuatro votos de un eje", "sums the four votes of one axis")),
            ("Alimentación", "Supply", "5.0 V"),
            ("Consumo", "Power", "3.48 mW"),
            ("Dispositivos", "Devices",
             ("17 nfet_06v0 + 2 pfet_06v0 (cinco ramas: cuatro votos y una fija)",
              "17 nfet_06v0 + 2 pfet_06v0 (five branches: four votes and one fixed)")),
            ("Umbral de decisión", "Decision threshold",
             ("2 de 4 votos", "2 of 4 votes")),
            ("Corriente por rama", "Branch current", "~170 µA, igual en las cuatro"),
            ("Área", "Area",
             ("45.34 × 25.00 µm = 0.0011 mm² (celda WEIGHT_COMP, con COMP_OUT)",
              "45.34 × 25.00 µm = 0.0011 mm² (WEIGHT_COMP cell, with COMP_OUT)")),
            ("Instancias", "Instances", ("3 (una por eje)", "3 (one per axis)")),
        ],
        desc_es=[
            ("Cuatro entradas con el MISMO peso, una salida.", True),
            "Cada una de las cuatro cadenas GRADIENT2 vota sobre este eje, y "
            "el bloque cuenta los votos en modo corriente: las ramas se suman "
            "juntando hilos, así que contar no cuesta una etapa más. Las "
            "cuatro llevan la misma corriente, unos 170 µA: lo que sale "
            "depende de CUÁNTAS votan, no de cuáles.",
            ("El eje se reclama desde 2 de 4 votos.", True),
            "Y eso lo consigue una QUINTA rama, copia exacta de las otras pero con "
            "la puerta fija a VDD. Al sumar siempre uno, N votos reales se leen "
            "como N+1 y el disparo baja de 3 de 4 a 2 de 4, que es la decisión "
            "que el chip tiene que tomar con cuatro cadenas y tres ejes.",
            ("Es una hoja: no tiene subbloques.", True),
            "17 transistores n y 2 p, dibujados a mano. La salida WE es el "
            "nodo de suma, y es lo que sale al pad analógico X, Y o Z.",
        ],
        desc_en=[
            ("Four inputs of EQUAL weight, one output.", True),
            "Each of the four GRADIENT2 chains votes on this axis, and the "
            "block counts the votes in current mode: the branches add by "
            "joining wires, so counting costs no extra stage. All four carry "
            "the same ~170 µA: what comes out depends on HOW MANY vote, not "
            "on which.",
            ("The axis is claimed from 2 of 4 votes on.", True),
            "A FIFTH branch does that: an exact copy of the others with its "
            "gate tied to VDD. Always adding one, N real votes read as N+1 and "
            "the trip drops from 3 of 4 to 2 of 4, which is the decision the "
            "chip has to make with four chains and three axes.",
            ("It is a leaf: no sub-blocks.", True),
            "17 n devices and 2 p, drawn by hand. The WE output is the summing "
            "node, and it is what leaves through the X, Y or Z analogue pad.",
        ],
        figs=[
            ("blk_WEIGHT_signals",
             "inputs, sum node and outputs",
             "Las cuatro entradas arriba, el nodo de suma WE en medio y las "
             "salidas abajo. WE es lo que sale al pad analógico del eje: es el "
             "punto de prueba X, Y o Z del chip."),
            ("blk_WEIGHT_decision",
             "from four votes to one decision",
             "La figura que faltaba: cómo los cuatro votos se convierten en una "
             "decisión. A la derecha, WE contra el NÚMERO de ramas que votan — "
             "cae unos 0.34 V por voto — y la salida bascula a 2 de 4, medido "
             "en las quince esquinas de 4.5–5.5 V y 0–85 °C.",
             "Y el hallazgo: las cuatro ramas pesan IGUAL, no en binario. Lo "
             "prueba el propio dato — sumas ponderadas distintas (3, 5, 6, 9, "
             "10, 12 bajo una lectura 1-2-4-8) caen todas en el mismo WE, y las "
             "cuatro corrientes de rama son los mismos 170 µA."),
            ("blk_WEIGHT_currents",
             "branch currents",
             "Las corrientes de las cuatro ramas, arriba el esquemático y "
             "abajo el layout. Se miden de forma distinta a propósito — en el "
             "esquemático con fuentes de 0 V, en el layout pidiendo la "
             "corriente de drenador de cada transistor de cola — y aun así "
             "coinciden."),
        ],
    ),
    "COMP_OUT": dict(
        titulo="COMP_OUT",
        sch="sch_COMP_OUT", lay="layout_WEIGHT_COMP",
        epi_es="Etapa de salida: tres inversores que dan el par digital.",
        epi_en="Output stage: three inverters giving the digital pair.",
        ficha=[
            ("Función", "Function",
             ("amplifica el voto y da su complemento",
              "buffers the vote and gives its complement")),
            ("Alimentación", "Supply", "5.0 V"),
            ("Subbloques", "Sub-blocks", "3 × INV_1"),
            ("Área", "Area",
             ("compartida con WEIGHT en la celda WEIGHT_COMP",
              "shared with WEIGHT in the WEIGHT_COMP cell")),
            ("Instancias", "Instances", ("3 (una por eje)", "3 (one per axis)")),
        ],
        desc_es=[
            ("Toma el nodo de suma y lo lleva a niveles digitales.", True),
            "Tres inversores en cadena: el primero decide, los siguientes dan "
            "pendiente y capacidad de carga. De ahí salen las dos señales del "
            "eje, la directa y su complemento.",
            ("Por eso las salidas van de dos en dos.", True),
            "XP/XN, YP/YN, ZP/ZN llegan al pad de raíl a raíl, y por eso "
            "toman un pad digital y no uno analógico.",
        ],
        desc_en=[
            ("It takes the summing node up to digital levels.", True),
            "Three inverters in a chain: the first decides, the rest give edge "
            "rate and drive. Out of it come the axis's two signals, the direct "
            "one and its complement.",
            ("That is why the outputs come in pairs.", True),
            "XP/XN, YP/YN, ZP/ZN reach the pad rail to rail, which is why they "
            "take a digital pad and not an analogue one.",
        ],
        figs=[
            ("blk_COMP_OUT_votes",
             "output state against the number of branches voting",
             "La segunda gráfica del comparador de salida: qué hace la salida "
             "según CUÁNTAS ramas votan. A la izquierda el nivel del contador, "
             "que baja 389 mV por voto y es igual en las nueve esquinas de "
             "4.5–5.5 V y 0–85 °C. A la derecha la decisión.",
             "Y el número que hay que retener: el eje se reclama desde 2 votos "
             "de 4, en las quince esquinas de 4.5–5.5 V y 0–85 °C sin "
             "excepción. Eso es lo que consigue la quinta rama del WEIGHT, la "
             "que va siempre encendida: sin ella harían falta 3 de 4, que con "
             "cuatro cadenas y tres ejes es una mayoría difícil de reunir."),
        ],
    ),
}

#: The order the report walks them in: the chain's own order.
ORDEN_GRADIENT2 = ["OPAM_LIN", "COMP", "DECODER"]
ORDEN_NAV = ["WEIGHT", "COMP_OUT"]
