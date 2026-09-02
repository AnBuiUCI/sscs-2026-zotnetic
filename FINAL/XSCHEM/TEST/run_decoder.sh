#!/bin/bash
# Corre el testbench del DECODER de punta a punta y comprueba el resultado.
#
#   ./run_decoder.sh
#
# Tres pasos, en este orden:
#
#   1. Renombra el subckt del layout extraido a DECODER_LAY.
#
#      This is not cosmetic. Layout and schematic both call the same cell
#      DECODER, and ngspice keeps the FIRST definition it reads and discards the
#      second with a warning that is easy to miss:
#
#          Warning: redefinition of .subckt decoder, ignored
#
#      Since the pex .include comes before the xschem netlist, the layout won
#      and instance x1 -- which should be the schematic -- ended up bound to the
#      extracted subckt. The pin orders have nothing to do with each other
#      (esquematico VDD XY XZ X Y YZ Z VSS contra layout VSS VDD YZ Z XY XZ Y X),
#      so its VSS landed on VDD and its VDD on signal VXY. Hence the v(X)
#      absurdo que no se parecia a v(test).
#
#      The rename is redone on every run from the real pex, so the copy does not
#      go stale when the layout is re-extracted.
#
#   2. Regenera el netlist desde el .sch. Nunca se edita el .spice a mano: xschem
#      rewrites it whole and it would be lost. The -o is essential, because the
#      global xschemrc netlist_dir points somewhere else.
#
#   3. Simula y comprueba.
#
# test_weight.sch does not suffer this because there the schematic is called
# WEIGHT / COMP_OUT y el layout WEIGHT_COMP: no hay choque de nombres.

set -euo pipefail

AQUI="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MAG="$AQUI/../../Layouts/DECODER/mag"
SIM="$AQUI/simulation/test_decoder.sch"

"$AQUI/preparar_extraidos.sh" DECODER > /dev/null || {
    echo "  ERROR: no se pudieron preparar los extraidos de la v2" >&2; exit 1; }

echo "==> 1/3  renombrando el subckt del layout a DECODER_LAY"
test -f "$MAG/DECODER_pex_rc.spice" || {
    echo "$MAG/DECODER_pex_rc.spice missing -- re-extract DECODER with magic" >&2
    exit 1
}
sed 's/^\.subckt DECODER /.subckt DECODER_LAY /' \
    "$MAG/DECODER_pex_rc.spice" > "$MAG/DECODER_pex_rc_LAY.spice"
grep -q "^\.subckt DECODER_LAY " "$MAG/DECODER_pex_rc_LAY.spice" || {
    echo "the rename did not take -- check what the pex .subckt is called" >&2
    exit 1
}

echo "==> 2/3  regenerando el netlist desde test_decoder.sch"
mkdir -p "$SIM"
#  xschem sometimes returns code 10 even though it writes the netlist fine, and
#  with `set -e` that kills the script. The file is checked, not its code.
( cd "$AQUI" && xschem -n -s -q -o "$SIM" test_decoder.sch ) || true
[ -s "$SIM/test_decoder.spice" ] || { echo "xschem no regenero el netlist" >&2; exit 1; }

echo "==> 3/3  simulando"
#  ngspice -b vuelca el punto de operacion entero al terminal y ahoga cualquier
#  useful warning, so it all goes to the log and only what matters is printed.
#  'plot' does not work headless: the warnings are harmless and get filtered.
( cd "$SIM" && ngspice -b test_decoder.spice > ngspice.log 2>&1 ) || true
grep -iE "error|singular|no DC path|redefinition" "$SIM/ngspice.log" || true
grep -q "^No. of Data Rows" "$SIM/ngspice.log" || {
    echo "la .tran no llego a terminar -- mira $SIM/ngspice.log" >&2
    exit 1
}

python3 - "$SIM" <<'PY'
import sys, pathlib
import numpy as np

sim = pathlib.Path(sys.argv[1])

def leer(nombre, cols):
    """wrdata escribe un par (tiempo, valor) por vector."""
    d = np.loadtxt(sim / nombre)
    return d[:, 0], {c: d[:, 2 * i + 1] for i, c in enumerate(cols)}

t, ent = leer("in.txt", ["VXY", "VXZ", "VYZ"])
_, sx = leer("outX.txt", ["X", "X1", "X2"])
_, sy = leer("outY.txt", ["Y", "Y1", "Y2"])
_, sz = leer("outZ.txt", ["Z", "Z1", "Z2"])
_, pw = leer("power.txt", ["p_esq", "p_v1", "p_v2"])

fallos = []

#  There is no longer a reference gate in the bench: what is compared is the
#  schematic against the extracted layout, output by output.

#  2. Logica esperada del decodificado winner-take-all de tres comparadores
#     pairwise. Sampled at the centre of each 125 ms plateau, far from the
#     edges, because the extraction arrives with RC delay.
print(f"\n  {'t':>7} {'XY XZ YZ':>9}   {'X  X1':>7} {'Y  Y1':>7} {'Z  Z1':>7}   esperado")
for centro in np.arange(0.0625, 1.0, 0.125):
    k = int(np.argmin(abs(t - centro)))
    xy, xz, yz = (ent[n][k] > 2.5 for n in ("VXY", "VXZ", "VYZ"))
    esp = {"X": xy and xz, "Y": yz and not xy, "Z": not (xz or yz)}
    got = {"X": (sx["X"][k] > 2.5, sx["X1"][k] > 2.5),
           "Y": (sy["Y"][k] > 2.5, sy["Y1"][k] > 2.5),
           "Z": (sz["Z"][k] > 2.5, sz["Z1"][k] > 2.5)}
    marca = ""
    for n in "XYZ":
        for etiqueta, val in zip((n, n + "1"), got[n]):
            if val != esp[n]:
                fallos.append(f"t={t[k]:.4f}: {etiqueta}={int(val)}, esperado {int(esp[n])}")
                marca = "  <<<"
    print(f"  {t[k]:7.4f} {int(xy):3d}{int(xz):3d}{int(yz):3d}   "
          + " ".join(f"{int(a):2d}{int(b):3d}" for a, b in
                     (got['X'], got['Y'], got['Z']))
          + f"   X={int(esp['X'])} Y={int(esp['Y'])} Z={int(esp['Z'])}{marca}")

#  3. Si VDD1 no alimentase el bloque extraido, i(v2) seria exactamente cero.
pico = abs(pw["p_v1"]).max()
print(f"\n  consumo pico   esquematico {abs(pw['p_esq']).max()*1e3:.3f} mW"
      f"   layout {pico*1e3:.3f} mW")
if pico == 0:
    fallos.append("layout current is zero: VDD1 is not powering the block")


#  Energy per transition. Peak current says little; what adds up when estimating
#  the chip's consumption is energy, which comes from integrating power over
#  time and dividing it among the transitions that occurred.
ent = np.column_stack([ent[n] for n in ("VXY", "VXZ", "VYZ")])
cambios = int(np.sum(np.any(np.diff(ent > 2.5, axis=0), axis=1)))
for nom, p in (("esquematico", pw["p_esq"]), ("layout v1", pw["p_v1"]),
               ("layout v2", pw["p_v2"])):
    e = np.trapezoid(abs(p), t) if hasattr(np, "trapezoid") else np.trapz(abs(p), t)
    print(f"  energia {nom:12s} {e*1e9:8.2f} nJ en {t[-1]:.2f} s"
          f"   ->  {e/max(cambios,1)*1e9:7.2f} nJ por transicion  ({cambios} transiciones)")
print("  CAREFUL: the input edges of this bench last 1 ms, six orders of")
print("  magnitude slower than reality, so this energy is dominated by")
print("  la corriente de cruce durante el flanco y NO representa el coste de conmutar.")
print("  For a useful figure the stimulus would need ns edges.")

if fallos:
    print(f"\n  FALLA ({len(fallos)}):")
    for f in fallos[:20]:
        print(f"    {f}")
    sys.exit(1)
print("\n  all matches: schematic and layout give the same logic")
PY
