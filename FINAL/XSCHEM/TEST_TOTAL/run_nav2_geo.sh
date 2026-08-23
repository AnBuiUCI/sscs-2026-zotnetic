#!/bin/bash
# Como se comporta el navegador segun la CAJA en que van los sensores.
#
#   ./run_nav2_geo.sh [paso_en_grados]      (por defecto 2)
#
# La caja es (Lxy x Lxy x Lz) y los cuatro sensores van en los vertices del
# tetraedro inscrito. Se estudian las seis combinaciones que se plantean:
# Lxy de 1000, 2000 y 3000 um, y Lz de 500 y 1000.
#
# LO QUE SE MIDE, Y QUE SIGNIFICA CADA COSA:
#
#   1. RESOLUCION. Para cada caja y cada nivel de gradiente se barre la direccion
#      360 grados y se cuenta en que fraccion de las direcciones el navegador
#      acierta el eje que le toca. De esa curva sale un numero: el gradiente
#      minimo con el que el acierto llega al 95 %. Captura los dos limites de
#      golpe -- por abajo el offset del comparador, por arriba la saturacion del
#      amplificador -- sin depender de ninguna definicion prestada.
#   2. Lo mismo en el plano X-Y, donde Lz no entra: separa la resolucion en x-y
#      de la de z.
#   3. FONDO. El campo terrestre es COMUN a los cuatro sensores, asi que se
#      cancela en la comparacion pero NO en el amplificador, que lo ve entero.
#      Se barre para ver a partir de que nivel se pierde la medida.
#
# El gradiente va en dR/R POR MILIMETRO. Convertirlo a campo pide la sensibilidad
# del AMR, que no esta fijada; la conversion queda explicada en el documento.
#
# Todo cabe en UNA sola invocacion de ngspice, con `alter` entre barridos: la
# netlist son 31 bloques extraidos con RC y lo caro es montarla, no barrerla.

set -euo pipefail
AQUI="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SIM="$AQUI/simulation/test_NAV2_geo.sch"
DAT="$AQUI/datos_geo"
#  Paso del barrido angular. 2 grados es el compromiso: son 84 barridos y lo que
#  importa es el tiempo total, pero sigue resolviendo las fronteras con holgura.
PASO=${1:-2}
MODO=${2:-completo}
export MODO
mkdir -p "$SIM" "$DAT"

echo "==> preparando los extraidos de la v2"
/foss/designs/a_zonetic2026/XSCHEM/TEST/preparar_extraidos.sh \
    OPAM_LIN_flat COMP DECODER WEIGHT_COMP | grep pex_rc | sed 's/^/  /'

echo "==> netlist"
rm -f "$SIM/test_NAV2_geo.spice"
( cd "$AQUI" && xschem -n -s -q -o "$SIM" test_NAV2_geo.sch ) || true
if [ ! -s "$SIM/test_NAV2_geo.spice" ] || [ "$AQUI/test_NAV2_geo.sch" -nt "$SIM/test_NAV2_geo.spice" ]; then
    echo "  xschem no regenero $SIM/test_NAV2_geo.spice" >&2; exit 1
fi
for e in "xnav2 VDDV GND XPv Xv XNv YPv Yv YNv ZPv Zv ZNv S2P S2N S4P S4N S3P S3N S1P S1N GRADIENT_NAV2_V2" \
         "xnav3 VDD3 GND XP3 XN3 YP3 YN3 ZP3 ZN3 S2P S2N S4P S4N S3P S3N S1P S1N lxy lz GRADIENT_NAV3"; do
    inst=${e%% *}
    real=$(grep -m1 "^$inst " "$SIM/test_NAV2_geo.spice" || true)
    if [ "$real" != "$e" ]; then
        echo "  CABLEADO ROTO en test_NAV2_geo.sch" >&2
        echo "    esperado: $e" >&2; echo "    netlist : ${real:-<no aparece>}" >&2; exit 1
    fi
done
echo "    las dos instancias, cableadas como toca"

#  El bloque de control se GENERA aqui y no vive en el esquematico: son 84
#  barridos con cuatro parametros cada uno, y escribirlos a mano en el .sch seria
#  un sitio mas donde equivocarse. El manifiesto dice que hay en cada fichero.
python3 - "$SIM" "$DAT" "$PASO" "${MODO:-completo}" <<'PY'
import sys
from pathlib import Path
SIM, DAT, PASO, MODO = Path(sys.argv[1]), Path(sys.argv[2]), int(sys.argv[3]), sys.argv[4]
CAJAS = [(1000, 1000), (1000, 500), (2000, 1000), (2000, 500),
         (3000, 1000), (3000, 500)]
#  Doce niveles en escala logaritmica, de 200 ppm/mm a 40 000. El rango se
#  estrecho a proposito despues de la primera tanda: con 20 ppm/mm por abajo se
#  gastaban puntos donde no pasa nada, y con solo ocho niveles el suelo y el
#  techo caian en la misma casilla y no se podian separar.
NIVELES = [200e-6 * (200 ** (i / 11)) for i in range(12)]
FONDOS = [0.0, 500e-6, 1e-3, 2e-3, 5e-3, 10e-3]

VEC = " ".join(["v(S1P)", "v(S1N)", "v(S2P)", "v(S2N)",
                "v(S3P)", "v(S3N)", "v(S4P)", "v(S4N)"]
               + [f"v({e}{s}v)" for e in "XYZ" for s in ("P", "", "N")]
               + [f"v(xnav2.{e}{k})" for e in "XYZ" for k in (1, 2, 3, 4)]
               + [f"v({e}{s}3)" for e in "XYZ" for s in ("P", "N")])

filas, ctrl = [], [".control"]
def barrido(lxy, lz, gmm, bg, tilt, tipo, off=0.0):
    i = len(filas) + 1
    filas.append(f"{i},{tipo},{lxy},{lz},{gmm:.6e},{bg:.6e},{tilt},{off:.6e}")
    ctrl.extend([f"alter Vlxy = {lxy}", f"alter Vlz = {lz}",
                 f"alter Vgmm = {gmm:.6e}", f"alter Vbg = {bg:.6e}",
                 f"alter Voff = {off:.6e}", f"alter Vtilt = {tilt}",
                 f"dc Vang 0 360 {PASO}", f"wrdata s{i:03d}.txt {VEC}"])

#  1: sin desajuste, solo dos cajas de referencia: ya se sabe que ahi no hay
#  suelo, y lo que interesa de esta familia es el techo por saturacion.
def cerrar():
    ctrl.append(".endc")
    (DAT / "manifiesto.csv").write_text(
        "idx,tipo,lxy_um,lz_um,gmm,bg,tilt_deg,off\n" + "\n".join(filas) + "\n")
    src = (SIM / "test_NAV2_geo.spice").read_text().splitlines()
    corte = max(i for i, l in enumerate(src) if l.strip().lower() == ".end")
    (SIM / "corrida.spice").write_text(
        "\n".join(src[:corte] + [".save all"] + ctrl + [".end"]) + "\n")
    print(f"    {len(filas)} barridos de {int(360 / PASO) + 1} puntos")


if MODO == "sentido":
    #  Corrida corta: las seis cajas a dos niveles de gradiente. Es lo justo para
    #  contestar si las salidas dan el SENTIDO. El estudio de resolucion ya esta
    #  hecho con NAV2 y repetirlo con NAV3 dentro cuesta tres horas.
    for lxy, lz in CAJAS:
        for g in (2223e-6, 9430e-6):
            barrido(lxy, lz, g, 0.0, 0, "sentido", 200e-6)
    cerrar()
    raise SystemExit(0)

for lxy, lz in ((1000, 1000), (3000, 1000)):
    for g in NIVELES:
        barrido(lxy, lz, g, 0.0, 0, "res_xz")
for lxy in (1000, 2000, 3000):              # 2: y en el X-Y, donde Lz no entra
    for g in NIVELES:
        barrido(lxy, 1000, g, 0.0, 90, "res_xy")
for lxy, lz in ((1000, 1000), (3000, 500)):  # 3: el campo de fondo
    for bg in FONDOS:
        barrido(lxy, lz, 2000e-6, bg, 0, "fondo")
#  4: LA RESOLUCION DE VERDAD. Con desajuste de sensor puesto, que es lo que pone
#  el suelo: sin el, la comparacion es exacta por pequena que sea la senal.
OFFSET = 200e-6
for lxy, lz in CAJAS:
    for g in NIVELES:
        barrido(lxy, lz, g, 0.0, 0, "res_off", OFFSET)
#  5: y como se mueve ese suelo con el propio desajuste, en dos cajas.
for lxy, lz in ((1000, 1000), (3000, 1000)):
    for off in (50e-6, 200e-6):
        for g in NIVELES:
            barrido(lxy, lz, g, 0.0, 0, f"off{int(off * 1e6)}", off)
ctrl.append(".endc")

(DAT / "manifiesto.csv").write_text(
    "idx,tipo,lxy_um,lz_um,gmm,bg,tilt_deg,off\n" + "\n".join(filas) + "\n")
src = (SIM / "test_NAV2_geo.spice").read_text().splitlines()
corte = max(i for i, l in enumerate(src) if l.strip().lower() == ".end")
(SIM / "corrida.spice").write_text(
    "\n".join(src[:corte] + [".save all"] + ctrl + [".end"]) + "\n")
print(f"    {len(filas)} barridos de {int(360 / PASO) + 1} puntos "
      f"-> {SIM / 'corrida.spice'}")
PY

echo "==> simulando  (es lo largo: 84 barridos sobre 31 bloques con RC)"
( cd "$SIM" && ngspice -b corrida.spice > ngspice.log 2>&1 ) || true
if grep -iqE "error|singular|no DC path" "$SIM/ngspice.log"; then
    echo "  ngspice se ha quejado:" >&2
    grep -iE "error|singular|no DC path" "$SIM/ngspice.log" | head -5 | sed 's/^/    /' >&2
    exit 1
fi
python3 "$AQUI/analizar_geo.py" "$SIM" "$DAT"
