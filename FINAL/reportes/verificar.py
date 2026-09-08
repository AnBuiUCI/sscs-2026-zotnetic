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
            if nombre.endswith("EN.pptx") and sh.has_text_frame:
                t = sh.text_frame.text
                if len(ES_PAL.findall(t)) >= 3:
                    leaks.append((i, t[:70].replace("\n", " ")))
    print(f"{nombre}: {len(prs.slides.__iter__.__self__._sldIdLst)} diapositivas, "
          f"{len(desb)} formas desbordadas, {len(leaks)} posibles fugas de idioma")
    for d in desb[:6]: print("   desborde:", d)
    for l in leaks[:6]: print("   español en el EN:", l)
    malo += len(desb) + len(leaks)

# figuras referenciadas que no existen, y figuras huerfanas
src = (AQUI / "hacer_pptx.py").read_text() + (AQUI / "bloques.py").read_text()
usadas = set(re.findall(r'"([A-Za-z][A-Za-z0-9_]+)"', src))
png = {p.stem for p in (AQUI / "figuras").glob("*.png")}
huerf = sorted(png - usadas)
print(f"\nfiguras en disco no referenciadas: {len(huerf)}")
for h in huerf: print("   ", h)
sys.exit(1 if malo else 0)
