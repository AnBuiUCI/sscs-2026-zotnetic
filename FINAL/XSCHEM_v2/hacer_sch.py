"""Builds xschem schematics by hanging labels off each symbol's pins.

xschem connects by NAME: a lab_pin placed exactly over a pin joins it to that
net. So instead of drawing wires, this module reads the pin coordinates from the
.sym (the B lines) and drops a lab_pin on each. It is mechanical and does not
make mistakes, which is what a forty-macro top needs.
"""
import re
from pathlib import Path

#  Where symbols are looked up, in the same order as XSCHEM_LIBRARY_PATH: the
#  project's first and then the PDK's.
RAICES = [Path("/foss/designs"),
          Path("/foss/pdks/gf180mcuD/libs.tech/xschem")]

def pines(sym):
    """Returns [(name, x, y)] in the ORDER of the B lines, which is the port
    order xschem will give the subcircuit."""
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
