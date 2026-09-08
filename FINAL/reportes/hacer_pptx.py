#!/usr/bin/env python3
"""Builds the two report decks, Spanish and English, from one structure.

    env -u PYTHONPATH /headless/.venvs/doc/bin/python hacer_pptx.py

ONE GENERATOR, TWO DECKS. The slide order lives here, the words live in
`textos.py`, and the per-block facts live in `bloques.py`; the same function
runs twice with a different dictionary. Two files that must say the same thing
and that nothing keeps in step will not stay in step -- this project already
paid for that with a duplicated `info.yaml` whose two copies pointed at
different GDS for a week.

THE ORDER IS THE HIERARCHY. The deck walks the design the way the design is
built: the chip, then GRADIENT_NAV2's three blocks, and inside the sensing one
its three sub-blocks. Every block gets a diagram of what it does, its data
sheet, its schematic beside its layout, and then its simulations -- and only
after all of them the block's own result. System results come last. Every
result in the deck is a schematic-against-layout comparison, because that is
what the benches measure.

FIGURE CAPTIONS ARE ENGLISH IN BOTH DECKS, like the figures themselves.

AND ONE NARRATION PER DECK. Standing rule (HANDOFF.md §8): everything delivered
out of `reportes/` gets a `.txt` of the same name beside it, saying IN SPANISH
what each slide is for. Those are the `G.di(...)` calls, written next to the
slide they explain; `guion.py` refuses to write the file if a slide has none.
"""

from __future__ import annotations

import sys
from pathlib import Path

from pptx import Presentation

import estilo as E
from bloques import BLOQUES, ESPECIFICACIONES, FICHA_CAB, ORDEN_GRADIENT2, \
    ORDEN_NAV, ficha
from guion import Guion
from textos import ES, EN

AQUI = Path(__file__).resolve().parent
FIG = AQUI / "figuras"

#: Measured on the GDS with KLayout `dbbox()`. The user asked for the layouts to
#: carry their size, and a layout shown without one is a picture, not a result.
DIMENSIONES = {
    "layout_OPAM_LIN_flat": "95.88 × 48.05 µm",
    "layout_OPAM": "76.45 × 30.76 µm",
    "layout_COMP": "99.60 × 31.46 µm",
    "layout_DECODER": "31.76 × 13.82 µm",
    "layout_DECODER_MAX": "31.76 × 14.48 µm",
    "layout_WEIGHT_COMP": "45.34 × 25.00 µm",
    "layout_ESD_CDM": "63.16 × 27.90 µm",
    "layout_GRADIENT_NAV2_V3": "460.90 × 386.99 µm",
    "layout_B26_A": "1110 × 1110 µm",
    "layout_B26_A_sin_fill": "1110 × 1110 µm",
}

#: Source-test results, read off `datos_fuente/fuente.csv`.
FUENTE = [
    ("symmetric", "3000 µm", "14.46°", "14.21°", "90.8 %"),
    ("symmetric", "6000 µm", "9.02°", "7.56°", "86.9 %"),
    ("symmetric", "12000 µm", "11.32°", "3.84°", "76.1 %"),
    ("dipole", "3000 µm", "16.53°", "16.40°", "93.2 %"),
    ("dipole", "6000 µm", "12.31°", "11.66°", "90.6 %"),
    ("dipole", "12000 µm", "12.41°", "9.92°", "84.3 %"),
]

#: Geometry sweep, from `datos_geo/resumen.csv`.
GEOMETRIA = [
    ("1000 × 1000", "90.0 %", "97.8 %"),
    ("1000 × 500", "87.2 %", "91.7 %"),
    ("2000 × 1000", "91.1 %", "92.2 %"),
    ("2000 × 500", "92.7 %", "94.4 %"),
    ("3000 × 1000", "92.7 %", "93.3 %"),
    ("3000 × 500", "92.7 %", "94.4 %"),
]

#: LOS 24 CASOS DE OCTANTE, AGRUPADOS POR LA CONDICION QUE LOS DISTINGUE.
#:
#: La figura por octante enseña ocho barras desiguales y deja al lector
#: suponiendo que el chip trata distinto a un signo que a otro. No es eso. El
#: decodificador saca el MENOR, y "el menor" cae en la señal mas pequeña cuando
#: los tres sentidos son positivos y en la MAS GRANDE cuando son negativos.
#: Como saturar depende del tamaño y no del signo, los octantes negativos le
#: piden al comparador que resuelva justo el par que se pega antes al rail.
#: Agrupados por esa condicion los 24 casos se ordenan solos, y cuatro de las
#: cinco filas salen al 100 %.
#:
#: Medido con `figuras_octantes.cargar_sensado()` sobre los `oct_*.txt`.
#: "Alcance" es el dR/R hasta donde no falla ni una vez; el barrido acaba en
#: 2.00 %, asi que "> 2.00" quiere decir que no llego a fallar.
CONDICIONES = [
    ("a raíles opuestos, el mayor a 0.6", "6", "100 %", "100 %", "> 2.00 %"),
    ("a raíles opuestos, el mayor a 1.0", "3", "100 %", "100 %", "> 2.00 %"),
    ("los dos hacia ARRIBA, el mayor a 0.6", "3", "100 %", "100 %", "> 2.00 %"),
    ("los dos hacia ABAJO, el mayor a 0.6", "3", "100 %", "100 %", "> 2.00 %"),
    ("los dos hacia ABAJO, el mayor a 1.0", "9", "86.2 %", "83.6 %", "1.38 / 1.26 %"),
]

#: LO ULTIMO MEDIDO EN GRADIENT2, todo de la corrida del 2026-09-07 de
#: `run_gradient.sh`, y cada fila del guion que la produce. Se pone junta
#: porque hasta ahora estaba repartida entre cinco diapositivas y no habia
#: donde mirar "cuanto da el bloque".
GRAD2 = [
    ("Eje decodificado correcto, barrido de rotación", "95.42 %", "93.34 %",
     "figuras_trazabilidad.py"),
    ("Esquemático y layout coinciden", "97.92 % del barrido", "7.5° de desacuerdo",
     "figuras_trazabilidad.py"),
    ("Error de frontera de sector", "5.25°", "7.75°", "figuras_trazabilidad.py"),
    ("Los 24 casos de octante", "94.8 %", "93.8 %", "figuras_octantes.py"),
    ("Alcance dR/R fuera de la esquina mala", "> 2.00 %", "> 2.00 %",
     "figuras_limite.py"),
    ("… y dentro de ella", "1.38 %", "1.26 %", "figuras_limite.py"),
    ("Suelo por ruido del amplificador", "44.4 ppm de dR/R", "222 µVrms a la entrada",
     "figuras_campo.py"),
    ("Amplificador: ganancia y reposo", "494 V/V sobre dR/R", "0.72 V (4.24 ↑ / 0.68 ↓)",
     "oct_*.txt"),
    ("Consumo de la cadena, ventana fina", "17.851 mW", "17.286 mW", "analizar.py"),
]

#: EL BANCO DEL LIMITE, del bloque `LIMIT CASES` de `test_GRADIENT.sch` y
#: medido por `figuras_limite.py`. Tres familias que sólo se diferencian en una
#: cosa cada vez, para que la causa quede aislada sin suponer nada:
#:
#:   A  par ABAJO,  fondo de escala    c = (-1.0, -1.0+d, +0.3)
#:   B  par ABAJO,  media escala       c = (-0.5, -0.5+d, +1.0)
#:   C  par ARRIBA, media escala       c = (+0.5, +0.5+d, +1.0)
#:
#: "> 2.00" es el final del barrido: no llego a fallar.
LIMITE = [
    ("A — par ABAJO, fondo de escala", "0.05", "0.62 %", "0.50 %"),
    ("A — par ABAJO, fondo de escala", "0.40", "1.38 %", "1.26 %"),
    ("B — par ABAJO, media escala", "0.05", "1.60 %", "1.36 %"),
    ("B — par ABAJO, media escala", "0.10", "> 2.00 %", "1.78 %"),
    ("B — par ABAJO, media escala", "0.20", "> 2.00 %", "> 2.00 %"),
    ("C — par ARRIBA, media escala", "0.05", "> 2.00 %", "> 2.00 %"),
    ("C — par ARRIBA, media escala", "0.40", "> 2.00 %", "> 2.00 %"),
]

#: The sensing block traced stage by stage, from figuras_trazabilidad.py.
#: Replaces the old `grad_*` figures, which drew all four chains and so put the
#: discarded 98 dB amplifier on the slide next to the one that ships.
FIG_TRAZA = [
    ("grid_lineal", "the whole chain on one sheet — amplifier still linear",
     "Aquí está el bloque entero en una sola hoja, que es como se pidió. Una "
     "COLUMNA es un eje y una FILA es una etapa, así que un eje se sigue de "
     "arriba abajo sin cambiar de diapositiva: el campo, lo que entrega su "
     "puente, el amplificador que lo lee, el comparador y la decisión.",
     "Ésta es con dR/R de 50 ppm, donde el amplificador trabaja en su zona "
     "lineal y se le ve la forma del coseno. Fíjate en la segunda fila: el modo "
     "común, punteado, se queda clavado en la mitad de la excitación mientras "
     "la diferencia se mueve. Ésa es la condición que hace legible todo lo de "
     "abajo.",
     "Y un aviso de lectura honesto: los comparadores no son uno por eje. Hay "
     "tres y comparan PARES — XY, XZ, YZ. Poner uno debajo de cada columna es "
     "una decisión de maquetación, no que XY sea «el comparador de X»."),
    ("grid_saturado", "the same chain at dR/R = 2 %, what a real AMR gives",
     "La misma hoja con el campo que da una AMR de verdad, dR/R del 2 %. La "
     "diferencia con la anterior es la única variable: aquí el amplificador "
     "SATURA, y se ve recortado contra los dos raíles en toda la fila tercera.",
     "Lo importante es lo que pasa debajo: las dos últimas filas son idénticas "
     "a las de la hoja anterior. Saturar no rompe la decisión, porque para "
     "decidir hace falta el CRUCE, no el pico. El chip no mide cuánto, ordena."),
    ("field_1_chain", "the other experiment: field SIZE swept, direction held",
     "Esta diapositiva y la siguiente contestan una pregunta distinta a todo lo "
     "anterior, y conviene decirlo antes de enseñarla. Hasta aquí el campo "
     "GIRABA manteniendo su tamaño: se probaba si el chip acierta la dirección. "
     "Aquí se hace lo contrario — la dirección se clava a 60°, en mitad de un "
     "sector, y lo que se barre es el MÓDULO del campo, de casi nada hasta el "
     "2 %.",
     "Por qué ese experimento: porque es el eje por el que se mueve un imán de "
     "verdad. Cuando te acercas a una fuente la dirección apenas cambia y lo "
     "que crece es el tamaño. Así que esto mide DESDE QUÉ CAMPO el chip decide, "
     "que es su alcance.",
     "Se lee de arriba abajo como la rejilla: los puentes son lineales en el "
     "campo por construcción, el amplificador es lineal hasta que satura, y "
     "abajo se ve a partir de qué campo la decisión se asienta y ya no cambia."),
    ("field_2_fine", "the low end on its own scale: where the chip goes deaf",
     "La misma pregunta, en el extremo bajo y con su propia escala. Ésta es la "
     "que da el número que importa: el campo MÍNIMO que el chip puede resolver.",
     "Y quién pone ese límite: el ruido del amplificador. Son 222 µVrms "
     "referidos a la entrada, y como la excitación del puente son 5 V, eso "
     "equivale a 44.4 ppm de dR/R. Por debajo de ahí la señal está por debajo "
     "del ruido y la decisión ya no se sostiene — no porque el circuito esté "
     "mal, sino porque no hay nada que leer.",
     "Lo que le da crédito al número es que el banco de geometría llega al "
     "mismo suelo por otro camino, midiendo resolución. Dos experimentos "
     "independientes y el mismo límite."),
    ("field_3_power", "what the chain costs as the field grows",
     "El consumo de la cadena a lo largo del mismo barrido. Sube al pasar por "
     "la zona activa y se aplana cuando el amplificador satura."),
    ("oct_sensado", "all eight sign combinations of the three bridge readings",
     "Los casos de prueba por octante que pediste, en el bloque de sensado. El "
     "banco se amplió para poder fijar las tres lecturas de puente de forma "
     "INDEPENDIENTE: el barrido giratorio de siempre las obliga a sumar cero, "
     "así que combinaciones como (+,+,+) eran inalcanzables y solo se veían "
     "tres de los ocho signos posibles.",
     "La respuesta correcta en cada punto es argmin(bx, by, bz), porque el "
     "decodificador saca el eje MENOR. Y el resultado es limpio: acierta en los "
     "ocho octantes, el 100 %, hasta dR/R = 1.40 %.",
     "A partir de ahí cae, y la curva gris dice por qué: es justo donde DOS "
     "amplificadores se quedan pegados al mismo raíl. Cuando eso pasa, el orden "
     "entre esos dos ya se ha perdido antes de que el comparador lo mire, y "
     "quien decide es el offset — 94.8 % el esquemático y 93.8 % el layout "
     "sobre el barrido entero, saturación incluida.",
     "Y eso mismo fija el alcance útil del bloque: el esquemático decide bien "
     "siempre hasta dR/R = 1.40 % y el layout hasta 1.28 %, en los ocho "
     "octantes. Esa diferencia entre los dos es su offset. No es un límite "
     "de ruido, es de recorrido — con 103 V/V de ganancia y 5 V de raíl, "
     "1.4 % de dR/R ya son 70 mV a la entrada y la salida no da más de sí."),
    ("trace_7_decision", "how the decision is taken, and how accurate it is",
     "Y ahora sí, la vista condensada de la decisión, que va aquí y no antes "
     "porque hasta este punto el comparador ya está explicado. Las salidas de "
     "los amplificadores, las de los comparadores y las del decodificador, una "
     "debajo de otra, con un color por eje para poder seguir un eje entero. "
     "Continuo el esquemático, discontinuo el layout.",
     "El número: el eje decodificado es el correcto en el 95.4 % del barrido "
     "con el esquemático y el 93.3 % con el layout, sin un solo punto "
     "indeciso. Lo que se pierde está todo en las fronteras entre sectores."),
    ("trace_6_errors", "decoded sector against the ideal, and the boundary error",
     "Y el número. Arriba, el eje decodificado contra el ideal — que es el eje "
     "MENOR, no el mayor: está en la tabla de verdad del decodificador, "
     "X = XY·XZ. Abajo, dónde cae cada frontera respecto a los 0, 120 y 240° "
     "exactos.",
     "Las cifras: el esquemático acierta el 95.4 % del barrido y el layout el "
     "93.3 %, sin un solo punto indeciso. Entre ellos coinciden en el 97.9 %, "
     "siete grados y medio de desacuerdo sobre 360.",
     "Y conviene decir de dónde sale ese 4-6 % que falta: no está repartido, "
     "está entero en las tres fronteras de sector. En medio de un sector las "
     "dos versiones no fallan nunca."),
]

FIG_GEOMETRIA = [
    ("geo_resolucion",
     "La resolución, y por qué son DOS límites y no uno. Por abajo el offset "
     "de los sensores pone un suelo: con un gradiente demasiado pequeño la "
     "diferencia entre esquinas se pierde dentro del offset. Por arriba la "
     "saturación del amplificador pone un techo. El número que se extrae —el "
     "gradiente más pequeño con 95 % de acierto— captura los dos a la vez."),
    ("geo_cajas",
     "Las seis cajas dibujadas. Al achatarlas el tetraedro pierde separación "
     "en z, y con ella la información que distingue arriba de abajo. Explica "
     "de un vistazo por qué la tabla penaliza siempre a las de Lz 500."),
    ("geo_fondo",
     "El campo terrestre. Es común a los cuatro sensores, así que se cancela "
     "al compararlos entre sí, pero NO en el amplificador, que lo ve entero y "
     "lo amplifica. La curva enseña a qué nivel de fondo se pierde la medida."),
]

FIG_FUENTE = [
    ("src_sensores",
     "Ésta es la diapositiva que estaba al principio y que movimos aquí: "
     "ahora llega en su sitio. Para cada uno de los cuatro vértices se dibuja "
     "el módulo que debería leer y lo que su puente entrega. Las cuatro "
     "lecturas son distintas entre sí, y esa diferencia ES el gradiente."),
    ("src_fuente_apunta",
     "Primero qué es cada eje, porque no es obvio. El eje horizontal NO es el "
     "ángulo medido: es dónde está la fuente alrededor de la caja. El vertical "
     "sí es el error — el ángulo entre el gradiente que el chip reconstruye de "
     "los cuatro puentes y la dirección real a la fuente.",
     "Y qué son las curvas tenues, que es lo que no se decía: cada una es UN "
     "azimut de la fuente, siete por panel. La banda que forman es cuánto "
     "depende la respuesta de por dónde se acerque la fuente. Las dos gruesas "
     "son su promedio: azul el chip, naranja discontinua un chip perfecto.",
     "Ojo con la lectura fácil y falsa: en el modelo simétrico un chip perfecto "
     "NO da cero. Da 14° a 3 mm. Eso no es del circuito, es de hacer una "
     "diferencia finita sobre una caja de 1 mm con la fuente a solo tres. Lo "
     "que pone el circuito es únicamente el hueco sombreado entre las dos "
     "curvas, y a 3 mm son 0.25°."),
    ("field_real_2_fuente",
     "La pregunta práctica: ¿sigue encontrando la fuente según te alejas? A la "
     "izquierda, el acierto contra la distancia, con los dos modelos de campo y "
     "las dos versiones de cableado. Cae de forma suave: a 2 mm el chip acierta "
     "el 91 % y a 18 mm el 67 %.",
     "El panel de la derecha explica por qué, y de paso valida los bancos. Es "
     "lo mismo dibujado contra la magnitud que de verdad manda: cuánto CAMBIA "
     "el campo a lo largo de la caja de 1 mm. Alejarse no reduce el campo —el "
     "modelo mantiene 156 µT en el centro— reduce su PENDIENTE, que es lo único "
     "que el chip puede leer.",
     "Y fíjate en que los triángulos, que vienen del banco de caja con "
     "gradiente uniforme impuesto, caen sobre la misma curva que los círculos "
     "del banco de fuente. Son dos experimentos independientes, uno con un imán "
     "y otro con un gradiente sintético, y dan lo mismo.",
     "En verde, el reordenado de puertos de XSCHEM_v3: gana entre 5 y 17 "
     "puntos, y la ventaja CRECE con la distancia, que es justo donde hace "
     "falta."),
    ("src_fuente_resumen",
     "Los dos separados: lo que sale del chip, y lo que sale menos lo que "
     "daría un chip perfecto. Lo segundo es la parte que pone el circuito. "
     "Justifica haber corrido dos modelos en lugar de uno."),
]


#: La alimentacion del bloque, medida sobre el DEF ruteado con
#: `openroad/scripts/check_current_density.py ... 31`. El objetivo es 31 mA, el
#: doble del pico de 15.50 mA que consume el bloque.
POTENCIA = [
    ("Metal4 vertical · VDD", "48.08 µm", "32.21 mA"),
    ("Metal4 vertical · VSS", "46.89 µm", "31.42 mA"),
    ("Metal5 horizontal · VDD", "39.95 µm", "59.92 mA"),
    ("Metal5 horizontal · VSS", "78.14 µm", "117.21 mA"),
    ("Pin del bloque · VDD", "3 puertos, 29.95 µm", "44.92 mA"),
    ("Pin del bloque · VSS", "4 puertos, 39.07 µm", "58.61 mA"),
    ("Vías Metal3–Metal4", "960–1130 cortes", "173–203 mA"),
    ("Vías Metal4–Metal5", "4704–5742 cortes", "847–1034 mA"),
]


def verificacion(es: bool):
    if es:
        return [
            ("DRC de 63 tablas", "63 tablas, 0 violaciones"),
            ("Densidad de relleno", "las 7 capas cumplen"),
            ("LVS netgen", "Circuits match uniquely, 1442 = 1442"),
            ("Nets", "894 = 894"),
            ("Conectividad", "17 de 17 señales, 11 por su clamp"),
            ("Tie-offs y alimentaciones", "50 de 50 en su raíl"),
            ("Densidad de corriente a 31 mA", "los 4 conductores, en el peor corte"),
            ("PR_bndry", "exactamente una"),
        ]
    return [
        ("Split-table DRC, 63 tables", "63 tables, 0 violations"),
        ("Density fill", "all 7 layers pass"),
        ("LVS netgen", "Circuits match uniquely, 1442 = 1442"),
        ("Nets", "894 = 894"),
        ("Connectivity", "17 of 17 signals, 11 through their clamp"),
        ("Tie-offs and supplies", "50 of 50 on the right rail"),
        ("Current density at 31 mA", "all 4 conductors, at the worst cut"),
        ("PR_bndry", "exactly one"),
    ]


def hay(nombre: str) -> Path | None:
    p = FIG / f"{nombre}.png"
    return p if p.exists() else None


def pie_layout(stem: str) -> str:
    """English caption for a layout, carrying its measured size."""
    d = DIMENSIONES.get(stem)
    return f"layout — {d}" if d else "layout"


def dos_figuras(prs, diapo, y, izq, der, pie_izq="", pie_der=""):
    """Two images side by side, each scaled to its own aspect ratio."""
    hueco = int((prs.slide_width - 2 * E.MARGEN - E.Inches(0.3)) / 2)
    alto = prs.slide_height - y - E.Inches(0.95)
    if izq:
        E.figura(diapo, prs, izq, y, alto, pie_izq, x=E.MARGEN, ancho=hueco)
    if der:
        E.figura(diapo, prs, der, y, alto, pie_der,
                 x=int(E.MARGEN + hueco + E.Inches(0.3)), ancho=hueco)


#: Two things are true of EVERY block and were being said on every block: that
#: the data sheet is measured rather than quoted, and why schematic and layout
#: are shown side by side. Said five times they stop being information; said on
#: the first block they are the frame for the other four. Reset per deck, in
#: `construir`, or the English one would lose them.
_YA_DICHO: set = set()


def _una_vez(clave: str) -> bool:
    nuevo = clave not in _YA_DICHO
    _YA_DICHO.add(clave)
    return nuevo


def sub_bloque(prs, G, T, es, clave):
    """One sub-block: what it does and its numbers, its drawing, its curves."""
    B = BLOQUES[clave]
    epi = B["epi_es"] if es else B["epi_en"]

    #  Description on the left, data sheet on the right: the prose says why the
    #  block is the way it is, the table says what it measures. Side by side
    #  they answer both questions a reviewer asks about a block.
    d, y = E.contenido(prs, B["titulo"], epi)
    media = int((prs.slide_width - 2 * E.MARGEN - E.Inches(0.35)) / 2)
    E.texto(d, prs, y, B["desc_es"] if es else B["desc_en"],
            x=E.MARGEN, ancho=media, tam=13)
    E.tabla(d, prs, y, FICHA_CAB["ES" if es else "EN"], ficha(es, B["ficha"]),
            ancho=media, tam=10.5,
            x=int(E.MARGEN + media + E.Inches(0.35)))
    G.di(f"{B['titulo']}: qué hace y cuánto cuesta, en la misma diapositiva. "
         f"El texto de la izquierda está en pantalla; basta señalar el titular "
         f"en negrita y pasar a la tabla.",
         *(["La tabla de la derecha son medidas, no cifras de catálogo: el "
            "área sale del GDS con KLayout y el consumo de su propio banco, "
            "donde cada bloque lleva su fuente separada. Vale igual para los "
            "cinco bloques que vienen."] if _una_vez("ficha") else []))

    sch, lay = hay(B["sch"]), hay(B["lay"])
    if sch or lay:
        d, y = E.contenido(prs, B["titulo"], epi)
        dos_figuras(prs, d, y, sch, lay, "schematic", pie_layout(B["lay"]))
        G.di(f"El esquemático de {B['titulo']} y su layout, uno al lado del "
             f"otro, con las dimensiones medidas debajo.",
             *(["Enseñarlos juntos es la forma corta de decir que todo lo que "
                "se simuló está además dibujado, y que lo dibujado es lo que "
                "se midió. Los cinco bloques van así; no lo repito en cada "
                "uno."] if _una_vez("par") else []))

    #  TWO PER SLIDE. The user merged these by hand and asked for it to stay:
    #  a slide per curve is a slide that says one thing, and most of these
    #  belong in pairs -- DC with its power, frequency with its noise. The
    #  order in `bloques.py` is the pairing.
    presentes = [(stem, pie, nota) for stem, pie, *nota in B["figs"]
                 if hay(stem)]
    for k in range(0, len(presentes), 2):
        lote = presentes[k:k + 2]
        d, y = E.contenido(prs, B["titulo"],
                           "  ·  ".join(p for _, p, _ in lote))
        if len(lote) == 2:
            dos_figuras(prs, d, y, hay(lote[0][0]), hay(lote[1][0]),
                        lote[0][1], lote[1][1])
        else:
            E.figura(d, prs, hay(lote[0][0]), y,
                     pie="XSCHEM/TEST — schematic vs layout v2")
        G.di(*[n for _, _, notas in lote for n in notas])


def construir(T: dict, salida: Path) -> None:
    _YA_DICHO.clear()
    es = T["idioma"] == "ES"
    prs = Presentation()
    prs.slide_width, prs.slide_height = E.ANCHO_DIAPO, E.ALTO_DIAPO

    G = Guion([
        "GUIÓN DEL REPORTE — TEAM ZOTNETIC B26",
        "",
        f"Acompaña a {salida.name} (presentación en "
        f"{'español' if es else 'inglés'}).",
        "Qué dice cada diapositiva y para qué está, en el mismo orden que el",
        "fichero. En español en las dos versiones: la presentación cambia de",
        "idioma, quien la presenta no.",
        "",
        "Generado por hacer_pptx.py junto con el .pptx. No editar a mano.",
        "=" * 78,
    ]).engancha()

    E.portada(prs, T["portada_t"], T["portada_s"], T["portada_l"])
    G.di("Presenta el trabajo: B26 Zotnetic, un navegador de gradiente "
         "magnético integrado en GF180MCU para el SSCS Chipathon 2026, con el "
         "equipo y la escuela.")

    # --- 1. the chip ---------------------------------------------------------
    E.seccion(prs, 1, T["s1"], T["s1_b"])
    G.di("Separador. Antes de enseñar un transistor, qué problema resuelve el "
         "chip.")

    d, y = E.contenido(prs, T["idea_t"], T["idea_e"])
    media = int((prs.slide_width - 2 * E.MARGEN - E.Inches(0.35)) / 2)
    E.texto(d, prs, y, T["idea"], x=E.MARGEN, ancho=media, tam=14)
    if (f := hay("diag_sensor_cube")):
        E.figura(d, prs, f, y, prs.slide_height - y - E.Inches(0.7),
                 "four sensors at the vertices",
                 x=int(E.MARGEN + media + E.Inches(0.35)), ancho=media)
    G.di("La idea que hay que entender antes que nada: los cuatro puentes NO "
         "miden la dirección del campo, miden su módulo en cuatro puntos.",
         "El dibujo de la derecha es dónde van esos cuatro sensores: en los "
         "vértices, con sus ejes. Comparando los cuatro módulos se reconstruye "
         "el gradiente, que apunta hacia donde el campo crece, y el campo crece "
         "hacia la fuente.",
         "La salida no dice cuánto, dice hacia dónde: un signo por eje.")

    if (f := hay("diag_chip")):
        d, y = E.contenido(prs, T["arq_t"], T["arq_e"])
        E.figura(d, prs, f, y, prs.slide_height - y - E.Inches(1.7),
                 "block diagram of the system")
        E.texto(d, prs, prs.slide_height - E.Inches(1.55), T["arq"][:1], tam=13,
                centrado_v=False, alto=E.Inches(0.5))
        G.di("El diagrama de bloques del sistema completo, el que ya teníais en "
             "la presentación.",
             "Lo que conviene señalar es dónde acaba el chip: en las seis "
             "salidas digitales. El puente en H y los actuadores magnéticos son "
             "externos. El chip dice hacia dónde; quien mueve es el puente.",
             "Y que cada bloque de sensado lee TRES de los cuatro puentes, en "
             "combinaciones distintas. Eso es lo que hace que los cuatro vean "
             "proyecciones distintas del mismo campo.")

    #  The specification table, in place of the old chain-of-names slide. A
    #  list of block names told the reader nothing the next section does not,
    #  and this is the thing an outsider actually asks for first.
    d, y = E.contenido(prs, T["esp_t"], T["esp_e"])
    E.tabla(d, prs, y, T["esp_cab"], ESPECIFICACIONES["ES" if es else "EN"],
            ancho=E.Inches(11.4), tam=11)
    E.texto(d, prs, y + E.Inches(4.86), [T["esp_pie"]], tam=11,
            centrado_v=False, alto=E.Inches(0.5))
    G.di("La tabla de especificaciones: entradas, salidas, consumo, tipos de "
         "pad y áreas, todo en una diapositiva.",
         "Es la diapositiva que sustituye a la vieja lista de nombres de "
         "bloque, y la que un revisor pide primero. 19 pads: 11 analógicos, 6 "
         "digitales y 2 de alimentación.",
         "Cuidado con un detalle si preguntan: los 6 V son la CLASE de "
         "dispositivo, no el punto de trabajo. Todo se simula y se mide a "
         "5.0 V, y así está escrito en la tabla.")
    if (f := hay("field_real_1_rango")):
        d, y = E.contenido(prs, T["esp_t"], "The same range in teslas")
        E.figura(d, prs, f, y, alto_max=E.Inches(3.4))
        G.di("Y la misma información en unidades que se pueden imaginar. Todo "
             "el reporte trabaja en dR/R —el cambio relativo de resistencia de "
             "un brazo del puente— porque es lo que ve el circuito y no depende "
             "del sensor que se le ponga delante. Pero nadie tiene intuición "
             "para 44 ppm.",
             "La conversión pide UN número que no es del chip: la sensibilidad "
             "del puente. Tomando un AMR de la clase que asume el diseño, "
             "3.2 mV/V/Oe, sale 1 ppm = 31.25 nT.",
             "Y entonces se lee de un vistazo: el chip trabaja de 1.4 µT a "
             "438 µT, un rango de 315 a 1, con el campo terrestre —50 µT— "
             "cómodamente en medio. Por debajo lo tapa el ruido del "
             "amplificador; por encima, dos amplificadores saturan contra el "
             "mismo raíl y el orden se pierde.",
             "Si se cambia el sensor, todos los teslas de esta diapositiva se "
             "mueven. Los ppm no: ésos son el chip.")

    # --- 2. the three blocks -------------------------------------------------
    E.seccion(prs, 2, T["s2"], T["s2_b"])
    G.di("Separador. Empieza el recorrido por la jerarquía: primero qué hace "
         "cada bloque y su diagrama interno, luego cada subbloque con su "
         "esquemático y sus simulaciones, y al final el resultado del bloque.")

    if (f := hay("diag_GRADIENT_NAV2")):
        d, y = E.contenido(prs, T["nav_int_t"], T["nav_int_e"])
        E.figura(d, prs, f, y, pie="internal block diagram")
        G.di("El navegador por dentro, en un solo dibujo: cuatro bloques de "
             "sensado, tres de peso y tres de salida.",
             "La idea que hay que dejar clara aquí es el reparto: cada cadena "
             "de sensado vota sobre los TRES ejes, y el bloque de peso de un "
             "eje recoge ese eje de las CUATRO cadenas. Por eso son cuatro "
             "sensados y tres pesos, y no cuatro y cuatro.")

    #  EL ESQUEMATICO Y EL LAYOUT DEL MISMO TOP. Aqui estaba el esquematico de
    #  `GRADIENT_NAV2` al lado del layout de la v3: dos versiones distintas en
    #  la misma diapositiva, y con el titulo de la que ya no se fabrica.
    if hay("sch_GRADIENT_NAV2_V3") or hay("layout_GRADIENT_NAV2_V3"):
        d, y = E.contenido(prs, "GRADIENT_NAV2_V3", T["nav_int_e"])
        dos_figuras(prs, d, y, hay("sch_GRADIENT_NAV2_V3"),
                    hay("layout_GRADIENT_NAV2_V3"), "schematic",
                    pie_layout("layout_GRADIENT_NAV2_V3"))
        G.di("El navegador que se fabrica, como esquemático y como layout. "
             "460.9 × 387.0 µm, que son 0.178 mm².",
             "Los dos son de la MISMA versión, la v3. Conviene decirlo porque "
             "hasta hace poco esta diapositiva enseñaba el esquemático de la "
             "anterior al lado de este layout.",
             "No hay que leer el esquemático durante la charla: está para dar "
             "la escala real de lo integrado, y para que se vea que las celdas "
             "son las mismas.")

    #  --- como se reparte la alimentacion dentro del bloque -------------------
    #  Es lo ultimo que se rehizo y no estaba contado en ninguna diapositiva:
    #  la tabla de verificacion lo resumia en una fila.
    d, y = E.contenido(prs, T["pdn_t"], T["pdn_e"])
    E.tabla(d, prs, y, T["pdn_tab"], POTENCIA, ancho=E.Inches(9.6))
    E.texto(d, prs, y + E.Inches(3.3), [T["pdn_pie"]], tam=13)
    G.di("Cómo se reparte la alimentación dentro del bloque, que es lo último "
         "que se rehízo.",
         "Las filas de macros van ESPEJADAS: una sí y una no se voltean, así "
         "que los raíles que se miran en un canal son del mismo net. Cada "
         "canal lleva entonces un solo strap, del net que le toca, en vez de "
         "una pareja VDD/VSS a 2 µm uno del otro. La separación entre nets "
         "contrarios pasa de 2 µm a 43.46 µm, y con ella el acoplo entre "
         "alimentación y masa.",
         "El dimensionado es al DOBLE del pico medido: el bloque consume 15.50 "
         "mA de pico y la malla se hace para 31. Los límites no son inventados, "
         "están en el tech-LEF del PDK como DCCURRENTDENSITY AVERAGE —0.67 mA "
         "por µm en Metal4, 1.5 en Metal5, 0.18 por corte de vía— y NINGUNA "
         "regla del DRC los comprueba. Hay que medirlos aparte.",
         "Y la columna de la derecha es el peor corte de cada eje, no el del "
         "centro: un límite que depende de dónde se mire no es un límite.")

    #  --- block 1: gradient sensing, and its three sub-blocks.
    d, y = E.contenido(prs, T["g2_t"], T["g2_e"])
    if (f := hay("diag_GRADIENT2")):
        E.figura(d, prs, f, y, E.Inches(3.0), "internal block diagram")
        E.texto(d, prs, y + E.Inches(3.15), T["g2"][:4], tam=12.5)
    else:
        E.texto(d, prs, y, T["g2"], tam=13)
    G.di("El primero de los tres bloques: el sensado de gradiente.",
         "Tres amplificadores suben las tres diferencias de puente, tres "
         "comparadores las comparan POR PARES —X con Y, X con Z, Y con Z— y el "
         "decodificador convierte ese orden en un eje ganador.",
         "Comparar por pares en lugar de contra un umbral es la decisión de "
         "diseño que merece contarse: el decodificador no necesita saber cuánto "
         "vale cada eje, solo cuál es mayor. Eso hace la decisión inmune a la "
         "ganancia absoluta y al offset común de los tres canales.")

    if (f := hay("sch_GRADIENT2")):
        d, y = E.contenido(prs, "GRADIENT2", T["g2_e"])
        E.figura(d, prs, f, y, pie="XSCHEM/COMBINATION/GRADIENT2.sch")
        G.di("El esquemático del bloque de sensado, para quien quiera seguir "
             "las conexiones del diagrama anterior una por una.")

    for clave in ORDEN_GRADIENT2:
        sub_bloque(prs, G, T, es, clave)
        #  OPAM_LIN is the only sub-block with sub-blocks of its own: a bias
        #  generator and the differential pair. Shown right after it, because
        #  "what is the amplifier made of" is the next question the slide
        #  before raises.
        if clave == "OPAM_LIN" and (hay("sch_bias") or hay("sch_sub_diff")):
            d, y = E.contenido(prs, "OPAM_LIN",
                               "Por dentro: el generador de polarización y el "
                               "par diferencial." if es else
                               "Inside: the bias generator and the differential "
                               "pair.")
            dos_figuras(prs, d, y, hay("sch_bias"), hay("sch_sub_diff"),
                        "bias generator", "differential pair (sub_diff_2_LIN)")
            G.di("De qué está hecho el amplificador: un generador de "
                 "polarización y el par diferencial. Son sus dos únicos "
                 "subbloques.",
                 "El de la izquierda fija las corrientes de cola; el de la "
                 "derecha es el que ve la señal del puente. Toda la linealidad "
                 "y todo el ruido de la diapositiva anterior salen del "
                 "derecho.")
        #  And the comparator's own pair, because it is the same circuit with
        #  two changes and showing them side by side is the clearest way to
        #  say what separates an amplifier from a comparator.
        if clave == "COMP" and hay("sch_sub_diff_comp"):
            d, y = E.contenido(prs, "COMP",
                               "Por dentro: el MISMO generador de polarización "
                               "y su propio par diferencial." if es else
                               "Inside: the SAME bias generator and its own "
                               "differential pair.")
            dos_figuras(prs, d, y, hay("sch_bias"), hay("sch_sub_diff_comp"),
                        "bias generator (the same cell as OPAM_LIN's)",
                        "differential pair (sub_diff)")
            G.di("El esquemático interno del comparador, que faltaba. Y lo "
                 "primero que hay que decir es que el bloque de la izquierda "
                 "no se parece al del amplificador: ES el del amplificador. "
                 "Mismo fichero, bias.sym, instanciado por los dos.",
                 "El par diferencial también es la misma topología, 36 "
                 "transistores colocados igual. Las diferencias son tres y "
                 "explican por qué uno amplifica y el otro decide: el "
                 "comparador NO lleva la resistencia de realimentación RFB, "
                 "usa multiplicadores m=2, 3 y 4 donde el amplificador va a "
                 "m=1, y su etapa de salida es de 30 µm y 15 µm contra 4 µm y "
                 "1 µm.",
                 "Traducido: al comparador no le importa la linealidad, le "
                 "importa empujar el raíl. Por eso su slew rate es una rampa "
                 "recta de 6.3 V/µs y el del amplificador ni siquiera existe "
                 "como tal.")

    #  --- block 1's own result: the rotating gradient.
    d, y = E.contenido(prs, T["grad_t"], T["grad_e"])
    E.texto(d, prs, y, T["grad"])
    G.di("Explicados los tres subbloques, el resultado del bloque de sensado.",
         "Cuatro cadenas colgadas de los MISMOS seis nodos de sensor, cada una "
         "con su alimentación propia para poder atribuir el consumo.",
         "El estímulo tiene truco: los tres campos van a 120°, suman cero y el "
         "vector solo cambia de dirección, nunca de tamaño. Así, barriendo de 0 "
         "a 360°, cada eje debería ganar un sector de exactamente 120°.")
    if (f := hay("tb_GRADIENT")):
        d, y = E.contenido(prs, T["grad_t"], T["grad_e"])
        E.figura(d, prs, f, y, pie="XSCHEM/TEST_TOTAL/test_GRADIENT.sch")
        G.di("El banco montado: los tres puentes a un lado y las cuatro "
             "cadenas colgando de los mismos nodos, cada una con su fuente "
             "separada — se ven las cuatro.")
    d, y = E.contenido(prs, T["tra_t"], T["tra_e"])
    E.texto(d, prs, y, T["tra"], tam=13)
    G.di("La sub-sección de trazabilidad del sensado, que es lo que faltaba: "
         "hasta aquí se enseñaba el resultado del bloque, no cómo llega la "
         "señal hasta él.",
         "Se sigue la misma señal por las cuatro etapas. El banco ya graba cada "
         "nodo intermedio, incluidos los que no tienen nombre — las salidas de "
         "los comparadores se sondean jerárquicamente, así que no hizo falta "
         "volver a simular.",
         "Y solo con el amplificador lineal, el que va en el chip: G2 contra "
         "G4, que es el mismo amplificador dibujado de dos maneras.")
    for stem, pie, *notas in FIG_TRAZA:
        if (f := hay(stem)):
            d, y = E.contenido(prs, T["res_g2_t"], pie)
            E.figura(d, prs, f, y, pie="run_gradient.sh — G2 schematic vs G4 layout")
            G.di(*notas)

    #  --- y POR QUE unos casos fallan y otros no, que la figura por octante no
    #  dice. Va inmediatamente detras de ella a proposito.
    d, y = E.contenido(prs, T["cond_t"], T["cond_e"])
    E.tabla(d, prs, y, T["cond_tab"], CONDICIONES, ancho=E.Inches(10.6))
    E.texto(d, prs, y + E.Inches(2.7), [T["cond_pie"]], tam=12.5)
    G.di("Ésta contesta la pregunta que deja la figura anterior: por qué los "
         "octantes con más signos negativos salen peor. Y la respuesta no es "
         "que el chip trate distinto a un signo que a otro.",
         "El decodificador saca el MENOR de los tres. Con los tres sentidos "
         "positivos el menor es la señal MÁS PEQUEÑA; con los tres negativos "
         "es la MÁS GRANDE. Saturar depende del tamaño, no del signo. Así que "
         "en los octantes negativos la decisión recae justo sobre el par que "
         "se pega antes al raíl.",
         "Agrupados por esa condición los 24 casos se ordenan solos: cuatro de "
         "las cinco filas aciertan el 100 % y no fallan en todo el barrido. "
         "Sólo cae una, y necesita las DOS condiciones a la vez — los dos "
         "candidatos hacia abajo Y el mayor a fondo de escala. Con una sola de "
         "las dos, acierta siempre.",
         "El porqué está en el pie, y está medido: el amplificador reposa en "
         "0.72 V, con 4.24 V de recorrido hacia arriba y 0.68 hacia abajo. "
         "Seis veces menos.",
         "Y de aquí sale la cifra que se defiende sola: el bloque decide bien "
         "hasta dR/R del 2 % o más, salvo en esa esquina, donde se queda en "
         "1.38 %. El «94.8 %» es la media de un test que mete nueve de sus "
         "veinticuatro casos en la esquina mala: se mueve cambiando el reparto "
         "de casos, sin tocar el chip.")

    #  --- y todo lo medido en el bloque, junto y con su procedencia.
    d, y = E.contenido(prs, T["g2res_t"], T["g2res_e"])
    E.tabla(d, prs, y, T["g2res_tab"], GRAD2, ancho=E.Inches(11.0))
    E.texto(d, prs, y + E.Inches(4.1), [T["g2res_pie"]], tam=12)
    G.di("Y todo lo medido en el bloque, junto. Hasta ahora estaba repartido "
         "entre cinco diapositivas y no había dónde mirar «cuánto da "
         "GRADIENT2».",
         "La última columna es de dónde sale cada fila. Está puesta a "
         "propósito: son cifras de guiones distintos, con denominadores "
         "distintos, y mezclarlas sin decirlo es como se acaba comparando dos "
         "cosas que no se comparan.",
         "Las dos primeras filas son la comparación que pide el banco: el "
         "esquemático acierta el 95.42 % del barrido de rotación y el layout "
         "el 93.34 %, y coinciden entre sí en el 97.92 %. Esa diferencia es su "
         "offset, y reaparece en todas las demás medidas.",
         "Y las dos del alcance son la conclusión de las dos diapositivas que "
         "vienen: el bloque llega a dR/R del 2 % o más salvo en una esquina "
         "concreta, donde se queda en 1.38.",
         "Todo es de la corrida del 7 de septiembre. Los datos del banco se "
         "rehicieron ese día al añadirle los casos de límite, así que las "
         "figuras de esta sección son de esa misma tanda y no de una anterior.")

    #  --- y el banco hecho a proposito para llevar esa esquina al limite.
    if (f := hay("lim_sensado")):
        d, y = E.contenido(prs, T["lim_t"], T["lim_e"])
        E.figura(d, prs, f, y, alto_max=E.Inches(3.9),
                 pie="test_GRADIENT.sch, bloque LIMIT CASES — 12 corridas")
        E.texto(d, prs, y + E.Inches(4.0), [T["lim_pie"]], tam=11.5)

        G.di("Y como la tabla anterior deja una condición señalada, el paso "
             "siguiente es un banco hecho para llevar ESA condición al límite "
             "y ninguna otra. Doce corridas nuevas en el mismo esquemático.",
             "El experimento está montado para que las tres familias sólo se "
             "diferencien en lo que se quiere medir. Mismo margen entre los "
             "dos que compiten, y la tercera lectura aparcada a fondo de "
             "escala donde no puede competir. La respuesta correcta es siempre "
             "X, así que una salida distinta es un fallo y no hay nada que "
             "interpretar.",
             "A contra B cambia sólo el TAMAÑO del par, con los dos yendo "
             "hacia abajo. B contra C cambia sólo el RAÍL, a igual tamaño. Con "
             "esas dos comparaciones la causa queda aislada sin suponer nada.",
             "El panel de la derecha es la prueba directa: las dos salidas que "
             "compiten, en el caso más apretado de cada familia. Las de abajo "
             "se juntan y se pegan al suelo; las de arriba siguen separadas "
             "cuando el barrido se acaba.",
             "Lo que esto deja dicho es una condición de uso, no un "
             "porcentaje: el bloque decide bien mientras el par que compite no "
             "vaya los dos hacia abajo estando a fondo de escala. Y el arreglo "
             "no es del decodificador, es subir la salida en reposo del "
             "amplificador hacia el centro del raíl — hoy desperdicia 3.5 V de "
             "recorrido por un lado y se queda sin margen por el otro.")

        #  Y la misma medida en numeros, porque de la figura se lee la
        #  tendencia y de la tabla el limite exacto.
        d, y = E.contenido(prs, T["lim_t"], T["lim2_e"])
        E.tabla(d, prs, y, T["lim_tab"], LIMITE, ancho=E.Inches(10.2))
        E.texto(d, prs, y + E.Inches(3.4), [T["lim2_pie"]], tam=12.5)
        G.di("Los mismos doce casos en números, que es donde se lee el límite "
             "exacto.",
             "Fíjate en las dos comparaciones que monta el banco. B contra C, "
             "mismo tamaño y sólo cambia el raíl: hacia arriba no falla NUNCA, "
             "ni con el margen más apretado; hacia abajo falla en cuanto el "
             "margen baja de 0.20. El raíl solo ya lo explica.",
             "Y A contra B, mismo raíl y sólo cambia el tamaño: con el mismo "
             "margen de 0.40, a media escala no falla en todo el barrido y a "
             "fondo de escala se queda en 1.38 %. Las dos condiciones son "
             "necesarias, ninguna sobra.",
             "La columna del layout va sistemáticamente unas doce centésimas "
             "por debajo del esquemático. Eso es su offset, y es el mismo "
             "número que sale en las otras medidas del bloque.")

    #  --- blocks 2 and 3.
    for clave, titulo, epi in ((("WEIGHT"), T["wei_t"], T["wei_e"]),
                               (("COMP_OUT"), T["cout_t"], T["cout_e"])):
        diag = hay(f"diag_{clave}")
        d, y = E.contenido(prs, titulo, epi)
        if diag:
            E.figura(d, prs, diag, y, pie="internal block diagram")
            #  The diagram gets narrated as a diagram. Repeating the block's
            #  description here would say in speech what the NEXT slide puts
            #  on screen in writing, two slides running.
            G.di(f"El diagrama interno de {clave}: por dónde entra cada señal "
                 f"y qué sale. Se recorre con el dedo de izquierda a derecha; "
                 f"los números vienen en la diapositiva siguiente.")
        else:
            E.texto(d, prs, y, BLOQUES[clave]["desc_es" if es else "desc_en"])
            G.di(f"El bloque {clave}, en palabras.")
        sub_bloque(prs, G, T, es, clave)

    if (f := hay("sch_INV_1")):
        d, y = E.contenido(prs, "INV_1",
                           "El subbloque de COMP_OUT: el inversor." if es
                           else "COMP_OUT's sub-block: the inverter.")
        E.figura(d, prs, f, y, pie="XSCHEM/WEIGTH/INV_1.sch")
        G.di("El inversor, que es el único subbloque de la etapa de salida. "
             "Tres de éstos en cadena son COMP_OUT.")

    #  --- the support block, outside the chain.
    d, y = E.contenido(prs, T["esd_t"], T["esd_e"])
    E.texto(d, prs, y, T["esd"], tam=13)
    G.di("La protección secundaria. No está en la cadena de señal, pero sí en "
         "el área de usuario y hay once instancias, una por pad analógico.",
         "Dos cosas que conviene decir: sus tres celdas publicadas violan "
         "MSLOT.1 y nadie lo había visto porque la tabla mslot del PDK se cae "
         "antes de llegar; y la nuestra ocupa la cuarta parte, unos 52 000 µm² "
         "de área recuperados.",
         "Y que aquí es donde se fusionaron las nwells para pasar el DRC en los "
         "dos modos de conectividad.")
    if hay("sch_ESD_CDM") or hay("layout_ESD_CDM"):
        d, y = E.contenido(prs, "ESD_CDM", T["esd_e"])
        dos_figuras(prs, d, y, hay("sch_ESD_CDM"), hay("layout_ESD_CDM"),
                    "schematic", pie_layout("layout_ESD_CDM"))
        G.di("ESD_CDM: su esquemático y su layout. Aquí el esquemático ES el "
             "bloque de código —la hoja no dibuja componentes— porque el "
             "circuito se escribió tal cual lo publican los organizadores, "
             "dispositivo por dispositivo.")

    # --- 3. full-system results ---------------------------------------------
    E.seccion(prs, 3, T["s3"], T["s3_b"])
    G.di("Separador. Explicados todos los bloques, los resultados del sistema "
         "completo. Todos son comparaciones de layout contra esquemático.")

    if (f := hay("tb_NAV3")):
        d, y = E.contenido(prs, T["nav_t"], T["nav_e"])
        E.figura(d, prs, f, y, pie="XSCHEM_v3/test_NAV3.sch")
        G.di("El banco del navegador completo, el de la versión que se "
             "fabrica: los cuatro puentes y, colgados de sus ocho nodos, los "
             "DOS navegadores — el del esquemático y el reconstruido desde el "
             "layout con parásitos.",
             "Que estén en la misma hoja es el argumento: comparten el estímulo "
             "exacto, así que cualquier diferencia en la salida es del circuito "
             "y no del estímulo.")
    d, y = E.contenido(prs, T["nav_t"], T["nav_e"])
    E.texto(d, prs, y, T["nav"])
    G.di("El método. El navegador del layout va extraído CON parásitos RC, que "
         "es lo que hace la comparación honrada: sin parásitos se estaría "
         "comparando el esquemático consigo mismo.",
         "Cada cadena con su alimentación, para medir los dos consumos sin que "
         "se mezclen.")
    if (f := hay("esq_vs_layout_salidas")):
        d, y = E.contenido(prs, T["res_lay_t"], T["res_lay_e"])
        E.figura(d, prs, f, y, alto_max=E.Inches(3.0),
                 pie="XSCHEM_v3/datos_nav3/fino_nav2.csv")
        E.texto(d, prs, y + E.Inches(3.2), T["res_lay"][:1], tam=13)
        G.di("El resultado en una imagen: las tres salidas de eje, las dos "
             "versiones superpuestas.",
             "Se ven tres trazas y no seis porque la naranja está encima de la "
             "azul. Aquí el dibujo aburrido es el buen resultado.")
    d, y = E.contenido(prs, T["res_lay_t"], "")
    E.texto(d, prs, y, T["res_lay"])
    dos_figuras(prs, d, y + E.Inches(2.6),
                hay("esq_vs_layout_error"), hay("esq_vs_layout_consumo"))
    G.di("Los números, sobre 721 puntos de 0 a 360°. Conviene decir que esta "
         "diapositiva llegó a poner 100 %, y era un artefacto: el banco tenía "
         "la reconstrucción cableada con el reparto de sensores viejo y estaba "
         "comparando un cableado contra otro. Arreglado eso y refrescados los "
         "netlists extraídos, éstos son los números de verdad.",
         "Las seis salidas digitales coinciden en el 99.58 % del barrido, "
         "con 1.5 grados de desacuerdo sobre 360, y los tres ejes al mismo "
         "nivel: 99.72 % cada uno. En la versión anterior Z iba por detrás "
         "—98.89 % contra 99.45 en X e Y— y con el reparto de puertos de la v3 "
         "los tres empatan.",
         "Y dónde caen esos grados importa: en las fronteras entre sectores. "
         "Ahí las dos entradas del comparador están casi iguales y quien "
         "decide es el offset, que en el layout es mayor. Fuera de las "
         "fronteras las dos versiones no discrepan en ningún punto.",
         "Abajo, lo que queda al restar una versión de la otra: 74.85 mW "
         "frente a 74.82, tres centésimas. Los parásitos RC no mueven el punto "
         "de trabajo.",
         "Este número es más fuerte que un LVS: el LVS dice que las conexiones "
         "coinciden, esto dice que el COMPORTAMIENTO coincide.")

    #  --- how the decision is built across the whole chip.
    for stem, pie, *notas in (
        ("total_1_votes", "four chains vote, the counter adds them up",
         "Cómo se construye una decisión en el chip entero, que es lo que no "
          "estaba en ninguna diapositiva: por cada eje, cuántas de las cuatro "
          "cadenas votan (escalera gris) y qué lee el contador analógico "
          "(color).",
         "Las dos van juntas a propósito: el contador debe ser una imagen fiel "
          "de un entero, y lo es: un escalón limpio por voto en los tres ejes."),
        ("total_2_outputs", "the six pins that leave the die",
         "Y las seis salidas que salen del chip, cada par con su gemela "
          "negada — que es literalmente su negado, no el otro sentido.",
         "Coinciden en el 99.72 % los tres, que es la otra cosa que arregla "
          "el reparto de puertos de la v3: antes Z se quedaba en 98.89 % "
          "mientras X e Y iban al 99.45. El contador analógico de debajo baja "
          "339.9 mV por voto en X e Y y 546.5 mV en Z, y el peor caso de "
          "desviación entre las dos versiones son 693.8 mV — no basta para "
          "cambiar la cuenta salvo justo en las fronteras."),
    ):
        if (f := hay(stem)):
            d, y = E.contenido(prs, T["res_lay_t"], pie)
            E.figura(d, prs, f, y, pie="XSCHEM_v3/datos_nav3/fino_nav2.csv")
            G.di(*notas)

    #  --- what the six pins actually say, and the octant sweep that tests it.
    d, y = E.contenido(prs, T["res_lay_t"], T["salida_e"])
    E.texto(d, prs, y, T["salida"])
    G.di("Conviene dejar claro qué dicen esos seis pines, porque es fácil "
         "leerlos mal. NO son seis sentidos. Son tres decisiones con su "
         "complemento: XP alto significa «gana el eje X», y XN es exactamente "
         "su negado, que es lo que alimenta el puente en H.",
         "Se ve en el netlist: COMP_OUT es OUT = búfer(IN) y OUT_N = NOT(IN), "
         "instanciado como x8 VDD XN X XP VSS. Así que para leer el chip basta "
         "mirar XP, XN es redundante por construcción.",
         "Y de ahí lo que este chip NO hace: distinguir +X de −X. El "
         "decodificador contesta QUÉ EJE, no hacia qué lado. Resolver el "
         "sentido pide una comparación más, que es la que añade GRADIENT_NAV3 "
         "y este die no lleva.")
    if (f := hay("oct_nav2")):
        d, y = E.contenido(prs, T["res_lay_t"],
                           "all eight sign combinations of the gradient")
        E.figura(d, prs, f, y, pie="run_nav2_geo.sh — sphere sweep")
        G.di("Los casos de prueba por octante en el navegador completo, que es "
             "lo que pediste: el gradiente recorriendo la esfera entera, no un "
             "plano, de modo que las ocho combinaciones de signo de X, Y y Z "
             "quedan cubiertas y con el mismo número de muestras cada una.",
             "A la izquierda, qué eje reclama el chip en cada octante. A la "
             "derecha, si es el que se esperaba — y el esperado sale de aplicar "
             "la MISMA regla de votación a lecturas ideales, así que un fallo "
             "es del circuito y no de la regla.",
             "Ésta es la cifra que sustituye a los grados: el chip no da un "
             "ángulo, da tres bits, y lo que hay que medir es cuántas veces "
             "acierta el eje.",
             "Dos avisos para leerla bien. Primero, este banco instancia los "
             "dos TOPS ESQUEMÁTICOS y no incluye ningún layout extraído: el "
             "76 % es del esquemático, no un defecto del dibujo.",
             "Y segundo, es una media sobre tres intensidades de gradiente, dos "
             "de ellas a propósito cerca del límite. Separadas: 65.1 % con el "
             "gradiente a 5 veces el desajuste de sensor, 78.2 % a 11 veces y "
             "85.3 % a 47 veces. No es una constante del chip, es dónde se le "
             "pone a medir. Las dos diapositivas siguientes lo desmontan.")

        #  Y el mismo barrido con el reparto anterior, para que se vea de donde
        #  se viene. Sale del MISMO fichero: el banco cuelga las dos versiones
        #  de los mismos ocho nodos.
        if (g := hay("oct_nav2")):
            d, y = E.contenido(prs, T["res_lay_t"],
                               "the same sweep, with the earlier port order")
            E.figura(d, prs, g, y, pie="the same stimulus, GRADIENT_NAV2")
            G.di("Y el mismo barrido con el reparto de puertos anterior, para "
                 "que se vea de dónde se viene: 76.2 % contra 90.7 %.",
                 "Los dos mapas salen del MISMO fichero de datos. El banco "
                 "cuelga las dos versiones de los mismos ocho nodos, así que "
                 "ninguna ve un estímulo que la otra no vea, y la diferencia "
                 "es del reparto de puertos y de nada más.",
                 "Lo que más se nota no es la media sino el peor octante: "
                 "60.9 % antes y 73.6 % ahora. Y tres octantes que estaban por "
                 "el 80 % pasan al 100 %.")

    #  --- and where that 76 % actually comes from, chain by chain. Without
    #  these two the octant slide reads as "a block is weak", which the data
    #  says is exactly wrong.
    for stem, pie, *notas in (
        ("chain_1_octantes",
         "every GRADIENT2, every octant, twice — the EARLIER port order",
         "Aviso antes de leerla: estas dos diapositivas son del reparto de "
          "puertos ANTERIOR, no del que se fabrica. Están aquí porque son el "
          "diagnóstico que llevó a la v3 — enseñan dónde se perdía el acierto, "
          "y sin ellas el cambio de reparto parece un capricho.",
         "Aquí está el bloque de sensado por dentro del navegador: las cuatro "
          "cadenas contra los ocho octantes. Los dos paneles son la misma "
          "medida hecha contra dos referencias distintas, y la diferencia entre "
          "ellos es toda la explicación.",
         "A la izquierda, contra el eje IDEAL: el que saldría si los cuatro "
          "puentes fueran perfectos. Sale irregular, 90.9 % de media, y con un "
          "patrón — en casi cada octante hay UNA cadena que cae y las otras "
          "tres quedan en 100 %.",
         "A la derecha, contra lo que la cadena REALMENTE recibe. Casi todo "
          "verde: 99.7 %. Es decir, el bloque de sensado hace su trabajo. Le "
          "das tres lecturas y saca la menor, siempre.",
         "Lo que hay en medio es el desajuste de los sensores, que el banco "
          "inyecta a 200 ppm con el patrón +1.00 / −0.62 / +0.31 / −0.85. Ese "
          "sesgo VOLTEA el orden de las lecturas antes de que el chip las vea, "
          "y en cada dirección le toca a la cadena cuyo trío queda peor puesto. "
          "Por eso el peor octante es el (−,−,−): ahí los sesgos se suman en "
          "vez de cancelarse y caen las cuatro a la vez.",
         "La única excepción de circuito es la cadena 2 al 96 %, y solo con el "
          "gradiente más fuerte: es la saturación del amplificador asomando, el "
          "mismo techo de dR/R = 1.4 % de la sección anterior."),
        ("chain_2_propagacion",
         "how one wrong chain out of four reaches the output — EARLIER order",
         "Y ésta contesta la pregunta que deja la anterior: si cada cadena "
          "acierta el 90.9 %, ¿por qué el chip entero se queda en 76.2 %?",
         "Porque no hay redundancia. A la izquierda, cuántas cadenas se "
          "equivocan a la vez: en el 73 % de las muestras no falla ninguna. A "
          "la derecha, si el chip sobrevive a ello — y no sobrevive: con las "
          "cuatro bien acierta el 100 %, con UNA sola mal acierta el 15 %.",
         "La causa es el reparto de votos. El eje ganador gana 2-1-1 en el 97 % "
          "de los casos, o sea por un solo voto, así que una cadena volteada "
          "cambia el eje. Cuatro cadenas que tienen que acertar TODAS dan "
          "0.909⁴ = 68 %; sale 76 % porque los errores se agrupan en las mismas "
          "muestras en vez de repartirse.",
         "La conclusión para el diseño: el sitio donde ganar precisión no es el "
          "bloque de sensado, que ya está al 99.7 %. Es calibrar los sensores, "
          "o pesar cada voto por su margen en lugar de contarlos todos igual."),
    ):
        if (f := hay(stem)):
            d, y = E.contenido(prs, T["res_lay_t"], pie)
            E.figura(d, prs, f, y, pie="run_nav2_geo.sh — sphere sweep, "
                                       "schematic tops only")
            G.di(*notas)

    #  --- geometry.
    d, y = E.contenido(prs, T["geo_t"], T["geo_e"])
    E.texto(d, prs, y, T["geo"], tam=13)
    G.di("El banco de geometría: los cuatro sensores en los vértices del "
         "tetraedro de una caja, y seis cajas distintas.",
         "Mide la resolución —el gradiente más pequeño con 95 % de acierto, que "
         "captura el offset por abajo y la saturación por arriba—, lo mismo "
         "restringido al plano X-Y, y el fondo.",
         "El criterio del 95 % se eligió para no depender de ninguna definición "
         "prestada: es un número que sale del propio experimento.")
    if (f := hay("tb_NAV3_geo")):
        d, y = E.contenido(prs, T["geo_t"], T["geo_e"])
        #  Este banco instancia LAS DOS versiones sobre el mismo estimulo -- el
        #  `GRADIENT_NAV2` de antes y el `GRADIENT_NAV2_V3` que se fabrica--, y
        #  por eso vale para las dos mitades de esta seccion: los numeros de la
        #  version anterior salen de su mitad y no de otra corrida.
        E.figura(d, prs, f, y, pie="XSCHEM_v3/test_NAV3_geo.sch — las dos "
                                   "versiones sobre el mismo estímulo")
        G.di("El banco de geometría montado: el navegador completo, con los "
             "sensores en los vértices de una caja concreta. El barrido repite "
             "el experimento entero para las seis.")
    d, y = E.contenido(prs, T["res_geo_t"], T["res_geo_e"])
    E.tabla(d, prs, y, T["res_geo_tab"], GEOMETRIA, ancho=E.Inches(7.4))
    E.texto(d, prs, y + E.Inches(2.9), [T["res_geo_pie"]], tam=13)
    G.di("La tabla de las seis cajas. Lo que hay que leer es la FORMA, no el "
         "tamaño: la caja cúbica de 1000 × 1000 llega al 97.8 % con gradiente "
         "alto, y achatarla a Lz 500 cuesta acierto siempre, en las tres "
         "anchuras.")
    for stem, nota in FIG_GEOMETRIA:
        if (f := hay(stem)):
            d, y = E.contenido(prs, T["res_geo_t"], T["res_geo_e"])
            E.figura(d, prs, f, y, pie="run_nav2_geo.sh")
            G.di(nota)

    #  --- source.
    d, y = E.contenido(prs, T["src_t"], T["src_e"])
    E.texto(d, prs, y, T["src"], tam=13)
    G.di("El banco de fuente, la pregunta para la que existe el chip. Ya no se "
         "impone un gradiente: se pone una fuente en un sitio y cada sensor lee "
         "el módulo en su vértice.",
         "El acierto está en usar DOS modelos. En el simétrico el módulo "
         "depende solo de la distancia, así que el gradiente apunta exactamente "
         "a la fuente y cualquier error es del chip. En el dipolo real ni un "
         "chip perfecto daría cero.",
         "La diferencia entre los dos números separa el error del circuito del "
         "error de la física. 42 barridos: tres distancias, siete azimuts, dos "
         "modelos.")
    if (f := hay("tb_FUENTE")):
        d, y = E.contenido(prs, T["src_t"], T["src_e"])
        E.figura(d, prs, f, y, pie="XSCHEM/TEST_TOTAL/test_FUENTE.sch")
        G.di("El banco de fuente montado. Es el que más se parece a un "
             "experimento real con un imán encima de la mesa.")
    d, y = E.contenido(prs, T["res_src_t"], T["res_src_e"])
    E.texto(d, prs, y, [T["res_src_intro"]], tam=13)
    E.tabla(d, prs, y + E.Inches(0.5), T["res_src_tab"], FUENTE)
    E.texto(d, prs, y + E.Inches(3.4), [T["res_src_pie"]], tam=13)
    G.di("El ángulo que da el chip frente al ideal, por modelo y distancia.",
         "Lo que hay que leer es la SEPARACIÓN entre «Chip» e «Ideal». A "
         "3000 µm en el modelo simétrico son 0.25°: el error es del circuito y "
         "es pequeño. A 12000 µm llega a 7.5° y la medida se pierde.")
    for stem, *notas in FIG_FUENTE:
        if (f := hay(stem)):
            d, y = E.contenido(prs, T["res_src_t"], T["res_src_e"])
            E.figura(d, prs, f, y, pie="run_fuente.sh")
            G.di(*notas)

    # --- 4. physical verification -------------------------------------------
    E.seccion(prs, 4, T["s6"], T["s6_b"])
    G.di("Separador. Se acaba la simulación y empieza lo que se entrega.")
    #  Both tops, side by side. The filled one ships, but the density fill
    #  covers the die in dummy metal and the structure disappears under it; the
    #  unfilled one is the same circuit with the routing visible.
    if hay("layout_B26_A_sin_fill") or hay("layout_B26_A"):
        d, y = E.contenido(prs, "B26_A", T["verif_e"])
        dos_figuras(prs, d, y, hay("layout_B26_A_sin_fill"), hay("layout_B26_A"),
                    f"unfilled — {DIMENSIONES['layout_B26_A_sin_fill']}",
                    f"density-filled — {DIMENSIONES['layout_B26_A']}")
        G.di("El chip entero, dos veces, 1110 × 1110 µm. A la izquierda sin "
             "relleno de densidad: se ven los bloques y el enrutado. A la "
             "derecha el fichero que se entrega, con el relleno puesto.",
             "Es la misma geometría; lo que cambia es que está cubierta de "
             "metal ficticio para cumplir las reglas de densidad. Enseñar las "
             "dos ahorra la pregunta de por qué el chip parece una mancha.")
    d, y = E.contenido(prs, T["verif_t"], T["verif_e"])
    E.tabla(d, prs, y, T["verif_tab"], verificacion(es), ancho=E.Inches(9.6))
    E.texto(d, prs, y + E.Inches(3.5), [T["verif_pie"]], tam=13)
    G.di("La verificación, toda sobre B26_A_filled4.gds, el fichero que se "
         "sube, no sobre una versión anterior.",
         "El LVS casa único sobre 1442 dispositivos y 894 nets, con el "
         "navegador v3 dentro: mismas celdas hoja, mismo interfaz, mismo "
         "hueco.",
         "La fila de corriente es electromigración, y conviene decir cómo está "
         "medida: es el PEOR corte de cada eje, no el del centro. Antes se "
         "cortaba el die por la mitad del lado mayor, que sobre un die "
         "rectangular no es el centro de ningún eje, y ese corte caía en un "
         "sitio afortunado.")

    # --- 5. conclusions ------------------------------------------------------
    E.seccion(prs, 5, T["s7"], T["s7_b"])
    G.di("Separador. Lo esperado contra lo medido, incluido lo que no cerró.")
    d, y = E.contenido(prs, T["conc_t"], T["conc_e"])
    E.texto(d, prs, y, T["conc"], tam=13)
    G.di("Tres cosas que se esperaban de una manera y resultaron ser de otra: "
         "XP y XN cambiados respecto a su etiqueta, el umbral fuera de sitio, y "
         "el eje Z sin poder ganar nunca.",
         "El tercero es el más interesante: subirle su propio peso no lo "
         "arreglaba; lo que lo arregló fue cambiar el ORDEN dentro de cada "
         "trío.",
         "Y el cierre justifica toda la sección de bancos: los tres se "
         "encontraron simulando, no revisando el esquemático.")
    d, y = E.contenido(prs, T["abierto_t"], T["abierto_e"])
    E.texto(d, prs, y, T["abierto"], tam=13)
    G.di("Lo que no cerró: el LVS de KLayout sobre el top no termina la "
         "extracción. Tres intentos, ninguno llegó a comparar.",
         "Importa decir por qué NO es falta de memoria: cada proceso se quedó "
         "en unos 540 MB con 31 GB libres. Es número de nets, no tamaño de "
         "máquina.",
         "Y lo que sí casa: netgen dice «Circuits match uniquely» sobre los "
         "mismos 1442 dispositivos. Se menciona porque el LVS externo del "
         "chipathon corre el deck de KLayout, no netgen.")
    #  --- the one change that is already measured and not yet in the die.
    if (f := hay("sch_GRADIENT_NAV2_V3")):
        d, y = E.contenido(prs, T["v3_t"], "The v3 top: same cells, sensor "
                                           "ports permuted")
        E.figura(d, prs, f, y, pie="XSCHEM_v3/GRADIENT_NAV2_V3.sch")
        G.di("El esquemático de la v3. Comparado con el del chip no cambia ni "
             "una celda: son los mismos cuatro GRADIENT2, los mismos tres "
             "WEIGHT y los mismos tres COMP_OUT.",
             "Lo único distinto es qué pad de sensor entra por qué puerto de "
             "cada GRADIENT2. Los cuatro tríos son los mismos; cambia el orden "
             "dentro de cada uno.",
             "Y esto ya NO es una propuesta: la v3 tiene layout propio, pasa "
             "DRC y LVS, y es lo que va dentro del chip que se entrega. El "
             "bloque mide los mismos 460.90 × 386.99 µm que la versión "
             "anterior, así que entró en el mismo hueco sin mover nada de la "
             "integración.")
    if (f := hay("chain_4_v3_layout")):
        d, y = E.contenido(prs, T["v3_t"], "And against its own extracted "
                                           "layout")
        E.figura(d, prs, f, y, alto_max=E.Inches(3.6),
                 pie="XSCHEM_v3/test_NAV3.sch — same extracted cells, v3 routing")
        G.di("La v3 contra su propio layout, con las celdas extraídas con "
             "parásitos RC. El verificador de grafo confirma que el navegador "
             "reconstruido ES el mismo circuito que el esquemático de la v3, "
             "31 celdas.",
             "Y aquí sale una ventaja que no buscábamos: la v3 no solo acierta "
             "más, aguanta mejor el layout. Las seis salidas coinciden en el "
             "99.72 % contra el 99.45 y 98.89 % del reparto ANTERIOR, y el "
             "desacuerdo baja de 2–4 grados a 1.",
             "El panel de la derecha dice por qué. El contador de la v3 "
             "recorre de 1.22 a 2.58 V —los cinco escalones, porque aparecen "
             "los 3-0-0— mientras que el del reparto anterior vivía entre 1.81 "
             "y 2.58, o sea "
             "en dos. Con más margen de voto, un offset del dibujo tiene que "
             "ser mucho mayor para cambiar la decisión.")
    if (f := hay("chain_3_v3")):
        d, y = E.contenido(prs, T["v3_t"], T["v3_e"])
        E.figura(d, prs, f, y, alto_max=E.Inches(3.6),
                 pie="XSCHEM_v3 — same sphere sweep, both wirings side by side")
        G.di("De dónde sale la mejora, que se ve directamente en el análisis "
             "de las cadenas.",
             "El bloque de sensado acierta el 99.7 % de lo que recibe, pero el "
             "chip entero se queda en el 76 %. La razón es que cada sensor "
             "ocupa una RANURA distinta en cada uno de los tres tríos que lo "
             "contienen: cuando es el mínimo, las tres cadenas que lo ven "
             "aciertan las tres y votan a ejes distintos. Se anulan, y decide "
             "la cuarta, la única que no lo vio.",
             "Reordenar qué sensor entra por qué puerto —los mismos tríos, "
             "cambiado el orden dentro de cada uno— hace que S1 caiga siempre "
             "en X, S4 en Y y S3 en Z. Medido en el mismo barrido: 76.2 % pasa "
             "a 90.7 %, y las salidas indefinidas de 1.1 % a 0.0 %.",
             "Lo que lo confirma es que las cuatro cadenas dan cifras "
             "IDÉNTICAS en las dos versiones. No se mejora ningún bloque: se "
             "deja de desperdiciar lo que ya decían. No cambia ninguna celda, "
             "solo el ruteo de los pads de sensor.",
             "Está en XSCHEM_v3, y desde el 7 de septiembre es el núcleo del "
             "GDS que se entrega: B26_A_filled4.gds. Se repitieron DRC y LVS "
             "del bloque y del área integrada, y los dos salen limpios.")

    E.seccion(prs, 6, T["cierre_t"],
              " ".join(l[0] if isinstance(l, tuple) else l for l in T["cierre"]))
    G.di("Cierre. El chip está terminado y verificado, y el entregable es "
         "B26_A_filled4.gds, con el navegador v3 dentro, sha 543d31ff.",
         "El sha está puesto a propósito: identifica el fichero exacto que se "
         "sube, y está archivado con sus veredictos en "
         "integration/gds/2026-09-08_01. Si alguien pregunta «¿contra qué GDS "
         "se corrió eso?», la respuesta cabe en la diapositiva.",
         "Es la que conviene dejar en pantalla mientras se responden "
         "preguntas.")

    G.suelta()
    n = len(prs.slides._sldIdLst)
    prs.save(str(salida))
    print(f"  {salida.name}   {n} diapositivas")
    G.escribir(salida.with_suffix(".txt"), n)


def main() -> int:
    if not FIG.exists():
        sys.exit(f"no hay figuras en {FIG}")
    construir(ES, AQUI / "reporte_zotnetic_ES.pptx")
    construir(EN, AQUI / "reporte_zotnetic_EN.pptx")
    return 0


if __name__ == "__main__":
    sys.exit(main())
