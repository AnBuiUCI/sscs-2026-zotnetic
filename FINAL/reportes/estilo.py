#!/usr/bin/env python3
"""The Zotnetic deck's look, in one place.

Taken from the team's own Canva presentation (*LAYOUT of Team zotnetic*): deep
navy sections with white type, white slides for the technical content, and a
wide-tracked monospaced face for the titles.

It lives in its own module so the two presentations -- Spanish and English --
cannot drift apart. Change the navy here and both change.
"""

from __future__ import annotations

from pptx.dml.color import RGBColor
from pptx.enum.text import MSO_ANCHOR, PP_ALIGN
from pptx.util import Emu, Inches, Pt

# --- colour ------------------------------------------------------------------
#: The deck's navy, sampled from the Canva cover. `AZUL_HONDO` is the corner it
#: fades from, `AZUL` the centre it fades to.
AZUL_HONDO = RGBColor(0x08, 0x10, 0x3A)
AZUL = RGBColor(0x16, 0x25, 0x6B)
BLANCO = RGBColor(0xFF, 0xFF, 0xFF)
#: For body text on white. Not pure black: against the navy headings a softer
#: ink reads as one family, and pure black reads as a different document.
TINTA = RGBColor(0x1C, 0x22, 0x38)
GRIS = RGBColor(0x6B, 0x74, 0x92)
#: The one warm accent, used for the layout traces and for numbers that carry
#: the argument. Sparingly: on this palette it only works because it is rare.
AMBAR = RGBColor(0xE0, 0x8A, 0x1E)
VERDE = RGBColor(0x2E, 0x9E, 0x6B)
ROJO = RGBColor(0xC8, 0x3A, 0x3A)

# --- type --------------------------------------------------------------------
#: Titles: the Canva cover uses a wide-tracked technical face. python-pptx
#: cannot set letter-spacing, so the tracking is faked by spacing the words in
#: the title text itself where it matters (`titulo_ancho`).
FUENTE_TITULO = "Consolas"
FUENTE_TEXTO = "Calibri"

# --- geometry ----------------------------------------------------------------
#: 16:9, which is what the Canva deck is and what a projector expects.
ANCHO_DIAPO = Inches(13.333)
ALTO_DIAPO = Inches(7.5)
MARGEN = Inches(0.62)


# --- narration hook ----------------------------------------------------------
#: Set by `guion.py`. Called with (kind, title) every time a slide is born, so a
#: companion narration can stay locked to the slide ORDER without the deck
#: having to know anything is listening. Left as None the deck behaves exactly
#: as before, which is what keeps this from being a second thing to maintain.
OBSERVADOR = None


def _nace(tipo: str, titulo: str, diapo=None) -> None:
    #: Se le pasa TAMBIEN la diapositiva, para que quien escuche pueda dejarle
    #: la narracion en su panel de notas. Antes solo iba el titulo y el guion
    #: acababa unicamente en el `.txt` de al lado: quien presenta desde el
    #: PowerPoint no tenia nada delante.
    if OBSERVADOR is not None:
        OBSERVADOR(tipo, titulo, diapo)


def titulo_ancho(texto: str) -> str:
    """One space between letters, the cover's tracking, for short titles only.

    `TEAM ZOTNETIC` on the cover is spaced this way. It is a display trick and
    it destroys readability past a few words, so it is applied by hand and never
    to a sentence.
    """
    return " ".join(texto)


def _caja(diapo, x, y, cx, cy):
    caja = diapo.shapes.add_textbox(x, y, cx, cy)
    marco = caja.text_frame
    marco.word_wrap = True
    marco.margin_left = marco.margin_right = 0
    marco.margin_top = marco.margin_bottom = 0
    return marco


def _parrafo(marco, texto, tam, color, fuente=FUENTE_TEXTO, negrita=False,
             alineado=PP_ALIGN.LEFT, espaciado=Pt(6), primero=False):
    p = marco.paragraphs[0] if primero else marco.add_paragraph()
    p.alignment = alineado
    p.space_after = espaciado
    t = p.add_run()
    t.text = texto
    t.font.size = Pt(tam)
    t.font.bold = negrita
    t.font.color.rgb = color
    t.font.name = fuente
    return p


def fondo_azul(diapo, prs) -> None:
    """The navy ground, as a gradient from the deep corner to the lighter centre.

    Drawn as a full-bleed rectangle rather than a slide background because
    python-pptx can set a gradient on a shape but not on a slide's own
    background fill.
    """
    from pptx.enum.shapes import MSO_SHAPE
    caja = diapo.shapes.add_shape(MSO_SHAPE.RECTANGLE, 0, 0,
                                  prs.slide_width, prs.slide_height)
    caja.line.fill.background()
    relleno = caja.fill
    relleno.gradient()
    relleno.gradient_angle = 315.0
    paradas = relleno.gradient_stops
    paradas[0].color.rgb = AZUL_HONDO
    paradas[0].position = 0.0
    paradas[1].color.rgb = AZUL
    paradas[1].position = 1.0
    #  Behind everything else added afterwards.
    diapo.shapes._spTree.remove(caza := caja._element)
    diapo.shapes._spTree.insert(2, caza)


def portada(prs, titulo, subtitulo, lineas) -> None:
    diapo = prs.slides.add_slide(prs.slide_layouts[6])
    _nace("portada", titulo, diapo)
    fondo_azul(diapo, prs)
    m = _caja(diapo, MARGEN, Inches(2.15), prs.slide_width - 2 * MARGEN, Inches(1.5))
    _parrafo(m, titulo_ancho(titulo), 46, BLANCO, FUENTE_TITULO, True,
             PP_ALIGN.CENTER, Pt(10), primero=True)
    m2 = _caja(diapo, MARGEN, Inches(3.5), prs.slide_width - 2 * MARGEN, Inches(1.0))
    _parrafo(m2, subtitulo, 19, BLANCO, FUENTE_TEXTO, False, PP_ALIGN.CENTER,
             Pt(4), primero=True)
    m3 = _caja(diapo, MARGEN, Inches(4.6), prs.slide_width - 2 * MARGEN, Inches(2.2))
    for i, l in enumerate(lineas):
        _parrafo(m3, l, 14, BLANCO, FUENTE_TEXTO, False, PP_ALIGN.CENTER,
                 Pt(3), primero=(i == 0))
    return diapo


def seccion(prs, numero, titulo, bajada="") -> None:
    """A navy divider. Its job is to let the reader breathe between blocks."""
    diapo = prs.slides.add_slide(prs.slide_layouts[6])
    _nace("seccion", f"{numero:02d} {titulo}", diapo)
    fondo_azul(diapo, prs)
    m = _caja(diapo, MARGEN * 2, Inches(2.7), prs.slide_width - 4 * MARGEN, Inches(0.8))
    _parrafo(m, f"{numero:02d}", 30, AMBAR, FUENTE_TITULO, True,
             PP_ALIGN.LEFT, Pt(6), primero=True)
    m2 = _caja(diapo, MARGEN * 2, Inches(3.35), prs.slide_width - 4 * MARGEN, Inches(1.4))
    _parrafo(m2, titulo, 34, BLANCO, FUENTE_TITULO, True, PP_ALIGN.LEFT,
             Pt(8), primero=True)
    if bajada:
        m3 = _caja(diapo, MARGEN * 2, Inches(4.6),
                   prs.slide_width - 5 * MARGEN, Inches(1.4))
        _parrafo(m3, bajada, 15, BLANCO, FUENTE_TEXTO, False, PP_ALIGN.LEFT,
                 Pt(4), primero=True)
    return diapo


def _titulo_blanco(diapo, prs, titulo, epigrafe=""):
    m = _caja(diapo, MARGEN, Inches(0.42), prs.slide_width - 2 * MARGEN, Inches(0.7))
    _parrafo(m, titulo, 25, AZUL, FUENTE_TITULO, True, PP_ALIGN.LEFT, Pt(2),
             primero=True)
    if epigrafe:
        m2 = _caja(diapo, MARGEN, Inches(1.02),
                   prs.slide_width - 2 * MARGEN, Inches(0.42))
        _parrafo(m2, epigrafe, 13, GRIS, FUENTE_TEXTO, False, PP_ALIGN.LEFT,
                 Pt(0), primero=True)
    #  A short rule under the title, the deck's one piece of furniture.
    from pptx.enum.shapes import MSO_SHAPE
    raya = diapo.shapes.add_shape(MSO_SHAPE.RECTANGLE, MARGEN,
                                  Inches(1.46 if epigrafe else 1.14),
                                  Inches(1.15), Emu(26000))
    raya.line.fill.background()
    raya.fill.solid()
    raya.fill.fore_color.rgb = AMBAR
    return Inches(1.72 if epigrafe else 1.40)


def contenido(prs, titulo, epigrafe="") -> tuple:
    """White slide: title, rule, and the area below it left to the caller."""
    diapo = prs.slides.add_slide(prs.slide_layouts[6])
    _nace("contenido", titulo, diapo)
    y = _titulo_blanco(diapo, prs, titulo, epigrafe)
    return diapo, y


def figura(diapo, prs, ruta, y, alto_max=None, pie="", x=None, ancho=None):
    """Places an image scaled to fit, centred, with an optional caption.

    Scales by the IMAGE's own aspect ratio rather than forcing a box, because a
    layout render squashed to fit is a layout that lies about its proportions.
    """
    from PIL import Image
    alto_max = alto_max or (prs.slide_height - y - Inches(0.75))
    ancho_disp = ancho or (prs.slide_width - 2 * MARGEN)
    with Image.open(ruta) as im:
        pw, ph = im.size
    escala = min(ancho_disp / pw, alto_max / ph)
    cx, cy = int(pw * escala), int(ph * escala)
    #  Centre the image inside ITS OWN column, not the slide: with two figures
    #  side by side the second would otherwise sit on top of the first.
    hueco_x = x if x is not None else MARGEN
    hueco_w = ancho_disp
    x = int(hueco_x + (hueco_w - cx) / 2)
    #  And centre it vertically in the space left, so a wide short figure does
    #  not hang from the title with the bottom half of the slide empty.
    y_img = int(y + max(0, (alto_max - cy) / 2))
    diapo.shapes.add_picture(str(ruta), x, y_img, cx, cy)
    if pie:
        #  The caption belongs under its own figure, in its own column.
        m = _caja(diapo, hueco_x, y_img + cy + Inches(0.08), hueco_w, Inches(0.4))
        _parrafo(m, pie, 11, GRIS, FUENTE_TEXTO, False, PP_ALIGN.CENTER, Pt(0),
                 primero=True)
    return y_img + cy


def texto(diapo, prs, y, lineas, x=None, ancho=None, tam=17, centrado_v=True,
          alto=None):
    """A bulleted block, vertically centred in what is left of the slide.

    Centring matters more than it sounds. A six-line block pinned to the top of
    a 16:9 slide leaves half the frame empty and reads as an unfinished slide;
    the same block centred reads as a deliberate one. `MSO_ANCHOR.MIDDLE` does
    it without having to measure the text.
    """
    x = x if x is not None else MARGEN
    ancho = ancho or (prs.slide_width - 2 * MARGEN)
    alto = alto or (prs.slide_height - y - Inches(0.55))
    m = _caja(diapo, x, y, ancho, alto)
    if centrado_v:
        m.vertical_anchor = MSO_ANCHOR.MIDDLE
    for i, l in enumerate(lineas):
        t, negrita = l if isinstance(l, tuple) else (l, False)
        _parrafo(m, t, tam, TINTA if not negrita else AZUL, FUENTE_TEXTO,
                 negrita, PP_ALIGN.LEFT, Pt(11 if negrita else 9),
                 primero=(i == 0))
    return m


def tabla(diapo, prs, y, cabecera, filas, ancho=None, alto=None, tam=12,
          x=None):
    """A table in the deck's colours, header in navy with white type.

    `x` defaults to the left margin; pass it to put the table in a column, next
    to a block of text rather than under it.
    """
    ancho = ancho or (prs.slide_width - 2 * MARGEN)
    alto = alto or Inches(0.36) * (len(filas) + 1)
    forma = diapo.shapes.add_table(len(filas) + 1, len(cabecera),
                                   MARGEN if x is None else x, y, ancho, alto)
    t = forma.table
    for j, c in enumerate(cabecera):
        celda = t.cell(0, j)
        celda.text = c
        celda.fill.solid()
        celda.fill.fore_color.rgb = AZUL
        celda.vertical_anchor = MSO_ANCHOR.MIDDLE
        p = celda.text_frame.paragraphs[0]
        p.font.size = Pt(tam)
        p.font.bold = True
        p.font.color.rgb = BLANCO
        p.font.name = FUENTE_TEXTO
    for i, fila in enumerate(filas, start=1):
        for j, v in enumerate(fila):
            celda = t.cell(i, j)
            celda.text = str(v)
            celda.fill.solid()
            celda.fill.fore_color.rgb = RGBColor(0xF3, 0xF5, 0xFA) if i % 2 else BLANCO
            celda.vertical_anchor = MSO_ANCHOR.MIDDLE
            p = celda.text_frame.paragraphs[0]
            p.font.size = Pt(tam)
            p.font.color.rgb = TINTA
            p.font.name = FUENTE_TEXTO
    return forma
