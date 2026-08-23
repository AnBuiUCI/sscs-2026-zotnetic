"""Monta esquematicos de xschem colgando etiquetas de los pines de cada simbolo.

xschem conecta por NOMBRE: un lab_pin puesto exactamente encima de un pin lo une
a esa red. Asi que en vez de tirar cables, este modulo lee las coordenadas de los
pines del .sym (las lineas B) y suelta un lab_pin en cada una. Es mecanico y no
se equivoca, que es lo que hace falta para un top de cuarenta macros.
"""
import re
from pathlib import Path

#  Donde busca los simbolos, en el mismo orden que XSCHEM_LIBRARY_PATH: primero
#  los del proyecto y luego los del PDK.
RAICES = [Path("/foss/designs"),
          Path("/foss/pdks/gf180mcuD/libs.tech/xschem")]

def pines(sym):
    """Devuelve [(nombre, x, y)] en el ORDEN de las lineas B, que es el orden de
    puertos que xschem le pondra al subcircuito."""
    if sym.startswith("/"):
        ruta = Path(sym)
    else:
        ruta = next((r / sym for r in RAICES if (r / sym).exists()), None)
        if ruta is None:
            raise SystemExit(f"  simbolo no encontrado: {sym}")
    txt = ruta.read_text()
    out = []
    for m in re.finditer(r"^B\s+\S+\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+\{([^}]*)\}",
                         txt, re.M):
        x1, y1, x2, y2, at = m.groups()
        nom = re.search(r"name=(\S+)", at).group(1)
        out.append((nom, (float(x1) + float(x2)) / 2, (float(y1) + float(y2)) / 2))
    return out

class Hoja:
    def __init__(self):
        self.lin = []
        self.n = 0

    def macro(self, sym, nombre, x, y, conex):
        """Instancia `sym` en (x,y) y etiqueta sus pines segun `conex`."""
        ps = pines(sym)
        faltan = {p for p, _, _ in ps} - set(conex)
        if faltan:
            raise SystemExit(f"  {nombre} ({sym}): pines sin conectar {sorted(faltan)}")
        sobran = set(conex) - {p for p, _, _ in ps}
        if sobran:
            raise SystemExit(f"  {nombre} ({sym}): pines que no existen {sorted(sobran)}")
        self.lin.append(f"C {{{sym}}} {x} {y} 0 0 {{name={nombre}}}")
        for p, dx, dy in ps:
            self.n += 1
            self.lin.append(f"C {{devices/lab_pin.sym}} {x+dx} {y+dy} 0 0 "
                            f"{{name=l{self.n} sig_type=std_logic lab={conex[p]}}}")

    def puerto(self, tipo, lab, x, y):
        self.n += 1
        self.lin.append(f"C {{{tipo}.sym}} {x} {y} 0 0 {{name=q{self.n} lab={lab}}}")

    def texto(self, val):
        self.lin.append('C {devices/code_shown.sym} -1200 -1200 0 0 '
                        f'{{name=NOTA only_toplevel=false\nvalue="{val}"}}')

    def escribir(self, ruta):
        cab = ["v {xschem version=3.4.8RC file_version=1.3}", "G {}", "K {}",
               "V {}", "S {}", "F {}", "E {}"]
        Path(ruta).write_text("\n".join(cab + self.lin) + "\n")
