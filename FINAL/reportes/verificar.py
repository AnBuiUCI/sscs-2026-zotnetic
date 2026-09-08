"""Checks the deck before it ships: overflow, language, orphan figures."""
import re, sys
from pathlib import Path
from pptx import Presentation
from pptx.util import Emu

AQUI = Path("/foss/designs/a_zonetic2026/reportes")
ES_PAL = re.compile(r"\b(el|la|los|las|de|del|que|con|para|una|por|como|"
                    r"cada|entre|desde|esto|esta|donde|cuando|más|así|"
                    r"decisión|salida|entrada|campo|puente|eje)\b", re.I)
malo = 0
for nombre in ("reporte_zotnetic_ES.pptx", "reporte_zotnetic_EN.pptx"):
    prs = Presentation(AQUI / nombre)
    W, H = prs.slide_width, prs.slide_height
    desb = fuera = []
    desb = []
    leaks = []
    for i, s in enumerate(prs.slides, 1):
        for sh in s.shapes:
            if sh.left is None: continue
            if sh.left < -Emu(1) or sh.top < -Emu(1) or \
               sh.left + sh.width > W + Emu(1) or sh.top + sh.height > H + Emu(1):
                desb.append((i, sh.shape_type, sh.name))
            if nombre.endswith("EN.pptx"):
                #  TAMBIEN DENTRO DE LAS TABLAS. `has_text_frame` es falso en
                #  un GraphicFrame, asi que este chequeo miraba solo los
                #  cuadros de texto y daba cero fugas mientras cuatro tablas
                #  enteras iban en castellano en el mazo ingles.
                trozos = []
                if sh.has_text_frame:
                    trozos.append(sh.text_frame.text)
                if getattr(sh, "has_table", False) and sh.has_table:
                    #  LA TABLA ENTERA COMO UN TEXTO, no celda a celda. Una
                    #  celda suelta como "a railes opuestos, el mayor a 0.6"
                    #  trae UNA palabra de la lista y no llega al umbral de
                    #  tres; la tabla completa trae docenas.
                    trozos.append(" ".join(c.text for fila in sh.table.rows
                                           for c in fila.cells))
                for t in trozos:
                    if len(ES_PAL.findall(t)) >= 3:
                        leaks.append((i, t[:70].replace("\n", " ")))
    print(f"{nombre}: {len(prs.slides.__iter__.__self__._sldIdLst)} diapositivas, "
          f"{len(desb)} formas desbordadas, {len(leaks)} posibles fugas de idioma")
    for d in desb[:6]: print("   desborde:", d)
    for l in leaks[:6]: print("   español en el EN:", l)
    malo += len(desb) + len(leaks)

#  QUE FIGURA LLEVA CADA DIAPOSITIVA, sobre el PPTX GENERADO y no sobre el
#  guion que lo genera. Un `hay("oct_nav2")` donde iba `oct_nav3` no rompe
#  nada: la diapositiva sale, con titulo correcto, con su narracion, y
#  enseñando el mapa de la version anterior. Ya paso una vez -- el cambio se
#  hizo y se perdio en una reescritura del fichero-- y solo se vio abriendo el
#  PowerPoint. Esto lo caza sin abrirlo.
import hashlib
FIG = AQUI / "figuras"
por_hash = {hashlib.md5(f.read_bytes()).hexdigest(): f.stem
            for f in FIG.glob("*.png")}
#: subtitulo de la diapositiva -> figura que TIENE que llevar.
ESPERADO = {
    "all eight sign combinations of the gradient": "oct_nav3",
    "the same sweep, with the earlier port order": "oct_nav2",
}
for nombre in ("reporte_zotnetic_ES.pptx", "reporte_zotnetic_EN.pptx"):
    prs = Presentation(AQUI / nombre)
    for i, s in enumerate(prs.slides, 1):
        subs = [sh.text_frame.text.strip() for sh in s.shapes
                if sh.has_text_frame and sh.text_frame.text.strip()]
        figs = [por_hash.get(hashlib.md5(sh.image.blob).hexdigest())
                for sh in s.shapes if sh.shape_type == 13]
        for sub in subs:
            if sub in ESPERADO and ESPERADO[sub] not in figs:
                print(f"{nombre}: diapositiva {i} «{sub[:44]}» lleva {figs} "
                      f"y tiene que llevar {ESPERADO[sub]}")
                malo += 1

# figuras referenciadas que no existen, y figuras huerfanas
src = (AQUI / "hacer_pptx.py").read_text() + (AQUI / "bloques.py").read_text()
usadas = set(re.findall(r'"([A-Za-z][A-Za-z0-9_]+)"', src))
png = {p.stem for p in (AQUI / "figuras").glob("*.png")}
huerf = sorted(png - usadas)
print(f"\nfiguras en disco no referenciadas: {len(huerf)}")
for h in huerf: print("   ", h)
sys.exit(1 if malo else 0)
