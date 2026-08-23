"""Genera un .sym de caja a partir de una lista de puertos.

El orden de la lista ES el orden de puertos del subcircuito: xschem los saca de
las lineas B del simbolo, asi que cambiar el orden aqui cambia el netlist.
"""
import sys

def sym(nombre, izq, der, arriba, abajo, alto=None):
    n = max(len(izq), len(der))
    h = alto or max(60, 20 * n + 40)
    w = 140
    L = ["v {xschem version=3.4.8RC file_version=1.3}", "G {}",
         "K {type=subcircuit", 'format="@name @pinlist @symname"',
         'template="name=x1"', "}", "V {}", "S {}", "F {}", "E {}",
         f"L 4 {-w/2} {-h/2} {w/2} {-h/2} {{}}", f"L 4 {w/2} {-h/2} {w/2} {h/2} {{}}",
         f"L 4 {w/2} {h/2} {-w/2} {h/2} {{}}", f"L 4 {-w/2} {h/2} {-w/2} {-h/2} {{}}",
         f'T {{{nombre}}} {-w/2+10} {-h/2-20} 0 0 0.3 0.3 {{}}',
         f'T {{@name}} {-w/2+10} {h/2+4} 0 0 0.2 0.2 {{}}']
    B = []
    def poner(lista, x0, dx, y0, dy, dirp, tx):
        for i, (p, d) in enumerate(lista):
            x = x0 + dx * i; y = y0 + dy * i
            B.append((p, d, x, y))
            L.append(f"L 4 {x} {y} {x + tx} {y} {{}}")
            L.append(f'T {{{p}}} {x + (14 if tx > 0 else -14 - 7*len(p))} {y-6} 0 0 0.2 0.2 {{}}')
    poner(izq, -w/2-20, 0, -h/2+30, 20, "in", 20)
    poner(der,  w/2+20, 0, -h/2+30, 20, "out", -20)
    poner(arriba, -w/2+30, 40, -h/2-20, 0, "inout", 0)
    poner(abajo,  -w/2+30, 40,  h/2+20, 0, "inout", 0)
    for p, d, x, y in B:
        L.append(f"B 5 {x-2.5} {y-2.5} {x+2.5} {y+2.5} {{name={p} dir={d}}}")
    return "\n".join(L) + "\n"

if __name__ == "__main__":
    pass
