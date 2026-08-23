#!/usr/bin/env python3
"""Rellena los huecos del top con transistores conectados como condensadores.

    python3 scripts/decap_fill.py --tile 16x47.85    # una baldosa suelta, para DRC
    python3 scripts/decap_fill.py                    # el top entero

QUE SE DIBUJA. En cada hueco, bandas de NMOS y PMOS con sus tiras de taps. El
NMOS lleva la puerta a VDD y el canal, la fuente, el drenador y el sustrato a
VSS; el PMOS al reves. Asi los dos quedan en inversion y dan la capacidad de
oxido de puerta completa, que es de lo que se trata.

COMO SE ALIMENTAN, que es lo que decide donde se puede rellenar y donde no. La
red de alimentacion del top son tiras de Metal4 (verticales, por encima de los
bloques) y de Metal5 (horizontales, por los canales): en los huecos no hay
alimentacion en metal bajo. Pero **dentro de un estante todos los macros miden lo
mismo** y cada bloque saca su riel VSS en Metal1 abajo y VDD en Metal1 arriba, a
la misma altura. Un relleno metido en un hueco de ese estante conecta con los
rieles del vecino **por abutment en Metal1**, sin una sola via y sin tocar Metal2
ni Metal3, que es por donde va el ruteo que ya cerro con DRC 0.

Corolario: solo se rellena lo que tenga un macro al lado con los rieles a su
misma altura. El resto del hueco -- la banda de margen y los canales entre
estantes -- se queda vacio y se reporta, porque llegar alli exigiria una pila de
vias hasta el Metal5 y esa pila cruza el ruteo.

**Los rieles NO llegan a los dos bordes del macro.** Medido en el top: el riel
VSS del vecino de la izquierda termina exacto en su borde derecho (x = 96.830),
pero el del vecino de la derecha empieza **0.26 um dentro** (x = 112.820 para un
macro cuyo borde esta en 112.560). Una baldosa que dibuje su riel de borde a
borde queda **abierta por ese lado**, y 0.26 > 0.23 asi que el DRC no dice nada.
Por eso los rieles se estiran hasta SOLAPAR el del vecino, midiendolo en el GDS
(`alcance`), y al final se comprueba la conectividad de verdad (`comprobar`).

Lo que quedo resuelto por el camino, y conviene no volver a pisarlo:

  * **La puerta es `cajas[-1]` en LOS DOS tipos.** Los dos dispositivos se
    construyen con `gate_con="top"`, asi que la placa de puerta es siempre la de
    arriba. Cogiendo `cajas[0]` para el PMOS se tomaba un drenador por puerta:
    se estiraba la placa de puerta (2.0 um de ancho, la del canal) hasta el riel
    contrario, pasaba a 0.07 um de la fuente y del drenador -- las cuatro
    `M1.2a` que quedaban -- y ademas el PMOS quedaba con la puerta a VDD y un
    drenador a VSS, o sea **cortado y sin capacidad ninguna**.
  * **No se llama al PCell en crudo.** `map_device` de `coil_layout` ya pone el
    metal1 de los pads y aplica `_fix_pcell_co7_gf180`; sin el salian 220 `CO.7`.
  * **Sin anillo de guarda.** El del PCell sale con `grw=0.22` y `DF.1a_MV` pide
    0.30: 768 `CO.4` + 348 `CO.7` + 184 `CO.6` en una baldosa. El sustrato y el
    pozo los atan las tiras de `_tap`.
  * **Los taps van EN los huecos entre dispositivos**, no a paso fijo desde el
    borde, o caen a 0.12 um del metal1 del vecino. Y el hueco tiene que medir al
    menos `TAP_W + 2*CLR`: con 1.20 no cabia ninguno y saltaba `DF.14_MV`, que
    pide un tap de sustrato a menos de 15 um de cada NCOMP.
  * **La barra VSS de cierre arrancaba en `x0 - CLR`** y tocaba el carril de VDD:
    cortocircuitaba las dos alimentaciones. El DRC solo lo asomaba como cuatro
    `M1.2a`; se vio extrayendo las nets, no leyendo el informe.
  * **El pozo se aparta 1.8 um del borde de la baldosa.** Sin `CONNECTIVITY_RULES`
    el deck aplica `NW.2b_MV` y pide **1.7 um entre pozos aunque sean la misma
    net**; el pozo del macro de la derecha llega justo a su borde.

COLUMNAS ALTERNAS, y no dos filas. Con una fila de NMOS abajo y otra de PMOS
arriba, la puerta de cada uno tiene que cruzar toda la altura del hueco hasta el
riel contrario, y esos dos caminos se cruzan entre si. Alternando el tipo por
bandas, cada dispositivo tiene su barra propia debajo y la contraria encima, y su
puerta sale por arriba. Ni un cruce.
"""

from __future__ import annotations

import os
import re
import sys
import warnings
from pathlib import Path

warnings.filterwarnings("ignore")

import klayout.db as kdb

sys.path.insert(0, "/foss/designs/zotnetic_layout")
sys.path.insert(0, str(Path(__file__).resolve().parent))
from coil_layout.device_map import map_device               # noqa: E402
from coil_layout.spice_parser import Device                 # noqa: E402
from fill_density import colocacion                         # noqa: E402

ROOT = Path(__file__).resolve().parent.parent
PROJECT = ROOT.parent

#: Directorio y celda del top, igual que en el resto del flujo (`TOP_OUT` /
#: `TOP_CELL` los pone el Makefile).
OUT = ROOT / os.environ.get("TOP_OUT", "out")
TOP = os.environ.get("TOP_CELL", "GRADIENT_NAV")

GDS_IN = OUT / f"{TOP}.gds"
GDS_OUT = OUT / f"{TOP}_decap.gds"
DEF = OUT / f"{TOP}_routed.def"
DEV_TXT = OUT / "decap_devices.txt"
HUECOS_TXT = OUT / "decap_huecos.txt"
SCH = PROJECT / "XSCHEM" / f"{TOP}.sch"

# --- capas de GF180 -----------------------------------------------------------
COMP, POLY, PPLUS, NPLUS, CONT, M1, NWELL = (22, 0), (30, 0), (31, 0), (32, 0), (33, 0), (34, 0), (21, 0)

# --- geometria ----------------------------------------------------------------
RAIL_W = 0.9        # ancho de los rieles del bloque; el relleno los continua
CLR = 0.40          # holgura de metal1 contra metal1 de otra net (M1.2a: 0.23)
L_CANAL = 2.0       # canal largo: mas area de oxido por dispositivo
ALTO_MIN = 12.0     # por debajo no cabe dispositivo entre los dos rieles
ANCHO_MIN = 6.0
GRID = 0.005
TAP_W = 0.48        # DF.9 pide 0.2025 um2 de COMP; 0.45 es el lado minimo
IMP_ENC = 0.18      # NP.5di/PP.5di piden 0.16
CO_S = 0.22
NWELL_ENC = 0.50    # nwell sobre la difusion p
NWELL_BORDE = 1.80  # del nwell al borde de la baldosa: NW.2b_MV pide 1.7 um
TAP_PITCH = 6.0
BAR = 0.40          # alto de las barras horizontales de VDD/VSS
CARRIL = 0.60       # ancho de los carriles verticales de los bordes
RISER_W = 0.50      # ancho del cable que sube de la puerta a su barra
W_MAX = 26.0        # `DF.13_MV` y `DF.14_MV` piden un tap a menos de 15 um de
                    # cada PCOMP / NCOMP. Con tap **arriba y abajo** de cada fila
                    # el punto peor es el centro del canal, o sea W/2 + holguras:
                    # 26 um deja el centro a 14 y pico. Con un solo tap el tope
                    # eran 11.
DEVICE_GAP = 1.44   # separacion entre dispositivos de una misma fila. Tiene
                    # que dar para un tap (0.48) con su holgura de metal1 a
                    # cada lado: los taps van EN estos huecos, no encima del
                    # dispositivo. Con 1.20 no cabia NINGUNO y saltaba
                    # `DF.14_MV`.
CLR_TAP = 0.60      # del COMP de un tap al bbox del dispositivo vecino
BORDE_DIE = 2.00    # margen de guarda contra el contorno del die. Un puerto SI
                    # tiene que tocar el borde -- es por donde se entra -- pero
                    # el relleno no: pegado al contorno, cualquier cosa que el
                    # integrador ponga al lado (un anillo de sellado, otro
                    # proyecto) queda a espaciado CERO. Antes el metal1 de las
                    # baldosas de margen llegaba a 0.000 del borde.
SOLAPE = 0.20       # cuanto tiene que montar el riel sobre el del vecino
ALCANCE_MAX = 1.20  # y como mucho cuanto se le deja entrar

#: Ventana en x de cada fila, medida desde el borde de la baldosa. La del PMOS va
#: mas adentro porque arrastra el pozo, que necesita `NWELL_BORDE`.
MARGEN_N = 2 * CLR + CARRIL
MARGEN_P = NWELL_BORDE + NWELL_ENC

#: Margen del pozo por un lado que da al CONTORNO DEL DIE. Ahi `NW.2b_MV` no
#: aplica -- no hay otro pozo enfrente -- y el margen de guarda de `BORDE_DIE` ya
#: deja 2 um libres por fuera. Sin esta distincion, las ocho baldosas de los
#: margenes del die se quedaban sin sitio para un solo dispositivo (2.92 um de
#: ventana contra los 3.66 que mide) y se perdian 0.77 pF.
NWELL_BORDE_DIE = 0.20


def _reg(cell, capa) -> kdb.Region:
    ly = cell.kcl.layout
    return kdb.Region(cell.kdb_cell.begin_shapes_rec(ly.layer(*capa)))


_HECHOS: dict = {}


def dispositivo(tipo: str, w_gate: float):
    """El dispositivo, envuelto por el MISMO codigo que usan los bloques.

    No se llama al PCell en crudo. `coil_layout.device_map.map_device` ya le pone
    el metal1 encima de los contactos de fuente, drenador y puerta, le deja
    puertos con nombre y le aplica `_fix_pcell_co7_gf180`, que corrige una
    separacion contacto-poly del PCell: llamandolo a pelo salian 220 `CO.7` en
    una sola baldosa. Reaprovecharlo es tambien la garantia de que el relleno
    esta hecho con los mismos dispositivos que el resto del chip.

    `bulk` no entra: `map_device` los pide siempre sin anillo de guarda, y el
    sustrato y el pozo los atan las tiras de taps de `_tap`.
    """
    clave = (tipo, round(w_gate, 3))
    if clave in _HECHOS:
        return _HECHOS[clave]
    dev = Device(name=f"{tipo}{len(_HECHOS)}",
                 model=("nfet_06v0" if tipo == "n" else "pfet_06v0"),
                 nodes={"drain": "d", "gate": "g", "source": "s", "bulk": "b"},
                 params={"L": f"{L_CANAL}u", "W": f"{w_gate}u", "nf": "1", "m": "1"})
    #  Los DOS con el contacto de puerta ARRIBA. En esta estructura cada
    #  dispositivo tiene su barra propia debajo (la de su fuente) y la contraria
    #  encima, asi que la puerta sale siempre hacia arriba. Sacando la del PMOS
    #  por abajo, su riser tenia que volver a subir bordeando el drenador y
    #  pasaba a 0.07 um de el.
    wd = map_device(dev, "gf180", gate_con="top")
    _HECHOS[clave] = wd.component
    return wd.component


def copiar_dispositivo(pc, destino, layout: kdb.Layout) -> None:
    """Vuelca la geometria de un PCell en `destino`, reescalando el dbu.

    Los PCells viven en un layout de `coil_layout` con dbu 0.001 y el GDS del top
    va a 0.0005. `Cell.copy_tree` copia entre layouts pero **no reescala**, y
    traer las baldosas por fichero es peor: `Layout.read` sobre un layout que ya
    tiene celdas **le cambia el dbu al de destino sin tocar lo que ya habia**, o
    sea que el top entero se queda con las coordenadas al doble. Se vio porque el
    riel de una baldosa aparecia de 1.37 um de alto en vez de 0.9.

    `begin_shapes_rec` recorre el arbol y devuelve las formas ya transformadas,
    asi que el dispositivo entra aplanado -- que es como acaba el top de todas
    formas (`def_to_gds.py::flatten_all`).
    """
    origen = pc.kdb_cell.layout()
    escala = origen.dbu / layout.dbu
    for li in origen.layer_indexes():
        r = kdb.Region(pc.kdb_cell.begin_shapes_rec(li))
        if r.is_empty():
            continue
        if escala != 1.0:
            r.transform(kdb.ICplxTrans(escala))
        destino.shapes(layout.layer(origen.get_info(li))).insert(r)



def sn(v: float) -> float:
    return round(v / GRID) * GRID


def _tap(cell, layers, x, y, implante):
    """Un tap: COMP + implante + contacto + metal1, con las cotas del generador."""
    cell.shapes(layers[COMP]).insert(kdb.DBox(x, y, x + TAP_W, y + TAP_W))
    cell.shapes(layers[implante]).insert(
        kdb.DBox(x - IMP_ENC, y - IMP_ENC, x + TAP_W + IMP_ENC, y + TAP_W + IMP_ENC))
    cx = sn(x + (TAP_W - CO_S) / 2)
    cy = sn(y + (TAP_W - CO_S) / 2)
    cell.shapes(layers[CONT]).insert(kdb.DBox(cx, cy, cx + CO_S, cy + CO_S))


def _alto_pcell(tipo: str, w: float) -> float:
    return dispositivo(tipo, w).kdb_cell.dbbox().height()


def _alto_fila(tipo: str, w: float) -> float:
    """Alto de una fila: barra + tap de abajo + dispositivo + tap de arriba."""
    return (BAR + 0.10 + TAP_W + CLR_TAP + _alto_pcell(tipo, w)
            + CLR_TAP + TAP_W + 0.10)


def _alto_banda(w: float) -> float:
    """Alto exacto de la banda entera: una fila de NMOS y una de PMOS."""
    return _alto_fila("n", w) + _alto_fila("p", w)


def _plan(util: float) -> tuple[int, float]:
    """Con que ancho de canal, en **una sola banda**.

    Una fila de NMOS y una de PMOS, y nada mas. Antes se repartia la altura en
    varias bandas apiladas y se elegia la combinacion que mas area de oxido daba;
    ahora la altura entera va a **un solo transistor por tipo**, lo mas largo que
    quepa. Sale la misma capacidad con menos dispositivos, y sin la escalera de
    barras y taps que hacia falta para intercalar bandas.

    El ancho del dispositivo en x no depende de W -- son siempre 3.66 um, porque
    W va en vertical -- asi que el numero de dispositivos por fila es el mismo se
    elija lo que se elija, y lo unico que se reparte es la altura.
    """
    mejor, w = 0.0, 0.5
    while w <= W_MAX + 1e-9:
        if _alto_banda(w) + BAR <= util:
            mejor = w
        else:
            break
        w = round(w + 0.25, 2)
    return (1, sn(mejor)) if mejor >= 0.5 else (0, 0.0)


def baldosa(layout: kdb.Layout, ancho: float, alto: float, nombre: str,
            ext: tuple[float, float, float, float] = (0.0, 0.0, 0.0, 0.0),
            nw: tuple[float, float] = (NWELL_BORDE, NWELL_BORDE)):
    """Una celda de relleno de `ancho` x `alto`, con sus rieles en los bordes.

    Estructura, de abajo arriba y repetida tantas veces como quepa:

        barra VSS / taps p+ / fila NMOS (puerta arriba) / barra VDD
                  / taps n+ en el pozo / fila PMOS (puerta arriba) / [barra VSS...]

    **Cada cruce de metal es entre la MISMA net**: la fuente y el drenador del
    NMOS bajan a su barra VSS cruzando los taps p+, que son VSS; los del PMOS
    bajan a la barra VDD cruzando los taps n+, que son VDD. Por eso no hace falta
    ni un hueco en ninguna tira ni una sola via.

    Las barras se atan a los rieles por dos carriles verticales, VDD por la
    izquierda y VSS por la derecha. Es toda la distribucion vertical que hay.

    `ext` son los cuatro estirones de riel medidos contra el vecino, en el orden
    (VSS izquierda, VSS derecha, VDD izquierda, VDD derecha). `nw` es cuanto se
    aparta el pozo de cada borde de la baldosa: `NWELL_BORDE` contra un macro y
    `NWELL_BORDE_DIE` contra el contorno del die.
    """
    top = layout.create_cell(nombre)
    L = {c: layout.layer(*c) for c in (COMP, POLY, PPLUS, NPLUS, CONT, M1, NWELL)}
    vss_i, vss_d, vdd_i, vdd_d = ext

    def m1(x0, y0, x1, y1):
        top.shapes(L[M1]).insert(kdb.DBox(sn(x0), sn(y0), sn(x1), sn(y1)))

    m1(-vss_i, 0, ancho + vss_d, RAIL_W)                     # VSS, abuta con el vecino
    m1(-vdd_i, alto - RAIL_W, ancho + vdd_d, alto)           # VDD, idem

    margen_p = (nw[0] + NWELL_ENC, nw[1] + NWELL_ENC)
    util = alto - 2 * RAIL_W - 2 * CLR
    if util <= 0 or ancho - margen_p[0] - margen_p[1] < 3.0:
        return top, []
    n_per, w_gate = _plan(util)
    if n_per == 0:
        return top, []

    #  Carriles verticales: cada uno arranca por encima del riel contrario, y
    #  los dos van metidos `CLR` hacia dentro. Pegados al borde, el carril VSS de
    #  una baldosa quedaba a **0.14 um del riel VDD del DECODER de al lado** --
    #  ese macro es de otro estante y su riel empieza 0.14 dentro de su borde.
    #  Lo unico que puede asomar por el borde son los dos rieles horizontales,
    #  que es de lo que se trata.
    m1(CLR, RAIL_W + CLR, CLR + CARRIL, alto)
    m1(ancho - CLR - CARRIL, 0.0, ancho - CLR, alto - RAIL_W - CLR)

    devs: list[tuple[str, float, float]] = []
    y = RAIL_W + CLR
    for k in range(n_per):
        y = _banda(layout, top, L, m1, y, w_gate, ancho, devs, nombre, k,
                   nw, margen_p)
    #  Una barra VSS final: la puerta de los PMOS de la ultima banda tiene que
    #  aterrizar en algo, y arriba lo que hay es el riel de VDD.
    #  Arranca en CARRIL + CLR como las demas. Arrancandola en `x0 - CLR` tocaba
    #  el carril de VDD por su borde derecho y **cortocircuitaba las dos
    #  alimentaciones**: la extraccion daba una sola net de metal1 en toda la
    #  baldosa, y el DRC solo lo asomaba como cuatro `M1.2a` de 0.07 um.
    m1(2 * CLR + CARRIL, y, ancho - CLR, y + BAR)
    return top, devs


def _banda(layout, top, L, m1, y, w_gate, ancho, devs, nombre, idx,
           nw=(NWELL_BORDE, NWELL_BORDE), margen_p=(MARGEN_P, MARGEN_P)):
    """Dibuja una banda a partir de `y`. Devuelve la `y` de la barra de arriba."""
    izq, der = 2 * CLR + CARRIL, ancho - 2 * CLR - CARRIL
    h_n, h_p = _alto_pcell("n", w_gate), _alto_pcell("p", w_gate)

    #  Todas las cotas ANTES de dibujar: la puerta del NMOS tiene que saber donde
    #  esta su barra VDD, y esa barra va por encima de el.
    #
    #  Cada fila lleva **dos** tiras de taps, una debajo y otra encima. Con una
    #  sola, el tap queda en un extremo del canal y `DF.13_MV` / `DF.14_MV` -- 15
    #  um como mucho del tap a cada PCOMP / NCOMP -- limitan el dispositivo a
    #  unos 11 um de largo. Con las dos, el punto peor es el centro del canal y
    #  el mismo margen da para 26.
    y_vss = y
    y_ptap0 = y_vss + BAR + 0.10
    y_n0 = y_ptap0 + TAP_W + CLR_TAP
    y_ptap1 = y_n0 + h_n + CLR_TAP
    y_vdd = y_ptap1 + TAP_W + 0.10
    y_ntap0 = y_vdd + BAR + 0.10
    y_p0 = y_ntap0 + TAP_W + CLR_TAP
    y_ntap1 = y_p0 + h_p + CLR_TAP
    y_fin = y_ntap1 + TAP_W + 0.10

    def barra(y0, net):
        #  Cada barra toca solo SU carril y se aparta del otro.
        if net == "VDD":
            m1(CLR, y0, der, y0 + BAR)
        else:
            m1(izq, y0, ancho - CLR, y0 + BAR)

    def taps(y_tap, implante, y_barra, sitios):
        """Un tap por dispositivo, **entre sus dos pads de fuente y drenador**.

        Ahi hay 2.14 um libres -- el ancho del canal menos los dos pads-- y esa
        banda esta despejada: lo unico que la cruza en vertical son los propios
        pads, que van a la barra de abajo, y el riser de puerta, que va hacia
        arriba.

        Antes se metian en los huecos ENTRE dispositivos y eso los dejaba fuera
        cuando el hueco medida menos de `TAP_W + 2*CLR`: en una baldosa estrecha
        (las de 9.52 um del margen del die) solo cabe un PMOS y el unico hueco
        que quedaba media 1.26 um, dos centesimas por debajo. Resultado: **once
        `DF.13_MV`**, que pide un tap de pozo a menos de 15 um de cada PCOMP.

        A paso fijo desde el borde tampoco valia: caian a 0.12 um del metal1 de
        un dispositivo. Como la fuente y el tap son la MISMA net el corto no
        existe, pero `M1.2a` se comprueba sobre la geometria y salta igual.
        """
        ultimo = -1e9
        for a, b in sitios:
            if b - a < TAP_W or (a + b) / 2 - ultimo < TAP_PITCH:
                continue
            x = sn((a + b - TAP_W) / 2)
            _tap(top, L, x, sn(y_tap), implante)
            m1(x, min(y_tap, y_barra), x + TAP_W, max(y_tap + TAP_W, y_barra + BAR))
            ultimo = (a + b) / 2

    def fila(tipo, y_base, y_sd, y_g):
        """Una fila de dispositivos, con su metal1 estirado hasta las barras.

        Los pads de metal1 ya vienen puestos por `map_device`; aqui solo se
        alargan: fuente y drenador hasta la barra de su net y la puerta hasta la
        contraria.

        **La puerta es siempre `cajas[-1]`**, la placa de mas arriba, porque los
        dos tipos se construyen con `gate_con="top"`. Ver la cabecera del
        fichero: cogiendo `cajas[0]` para el PMOS se tomaba un drenador por
        puerta y salian cuatro `M1.2a` por baldosa, con el PMOS ademas cortado.
        """
        pc = dispositivo(tipo, w_gate)
        bb = pc.kdb_cell.dbbox()
        #  A MICRAS con el dbu del PCell, no con el del layout de destino. Las
        #  cajas salen en unidades enteras del layout de origen (0.001) y aqui se
        #  dibuja en el del top (0.0005): multiplicandolas por el dbu de destino
        #  el dispositivo entero salia **a la mitad de tamano**, con pads de
        #  metal1 de 0.18 um. 1180 `M1.1` y 886 `M1.2a`, y ni una en la baldosa
        #  suelta, que se construye en un layout de 0.001 y por eso cuadraba.
        dbu_pc = pc.kdb_cell.layout().dbu
        cajas = [poly.bbox().to_dtype(dbu_pc) for poly in _reg(pc, M1).merged().each()]
        if len(cajas) < 3:
            return []
        cajas.sort(key=lambda b: b.bottom)
        g = cajas[-1]
        sd = [b for b in cajas if b is not g]

        x0 = MARGEN_N if tipo == "n" else margen_p[0]
        x1 = ancho - (MARGEN_N if tipo == "n" else margen_p[1])
        #  Dos sitios de tap por dispositivo, en coordenadas del PCell:
        #
        #  * el de ABAJO va en el hueco interno, entre los dos pads de S/D, y
        #    baja recto a la barra;
        #  * el de ARRIBA va **encima de un pad de S/D**, porque ahi lo unico que
        #    tiene a mano de su misma net es ese pad: en el centro esta la placa
        #    de puerta, que es de la net contraria.
        sd_orden = sorted(sd, key=lambda b: b.left)
        interno = (sd_orden[0].right, sd_orden[-1].left)
        sobre_pad = (sd_orden[0].left, sd_orden[0].right)
        x = x0
        sitios, sitios_alto = [], []
        while x + bb.width() <= x1:
            celda = layout.create_cell(f"{nombre}_{idx}{tipo}{len(devs)}")
            copiar_dispositivo(pc, celda, layout)
            dx, dy = x - bb.left, y_base - bb.bottom
            top.insert(kdb.DCellInstArray(celda.cell_index(),
                                          kdb.DTrans(kdb.DVector(dx, dy))))
            for b, destino, estrecho in ([(k, y_sd, False) for k in sd]
                                         + [(g, y_g, True)]):
                a0, a1 = b.left + dx, b.right + dx
                if estrecho and a1 - a0 > RISER_W:
                    #  El pad de puerta es tan ancho como el canal (2 um) y queda
                    #  a 0.07 de la fuente y del drenador. Mientras no se solapen
                    #  en `y` eso es legal -- es el end cap del poly -- pero
                    #  estirarlo hacia la barra lo mete en la banda de los otros
                    #  dos y lo convierte en `M1.2a`. El riser va centrado y
                    #  estrecho, que deja de sobra a cada lado.
                    c = (a0 + a1) / 2
                    a0, a1 = c - RISER_W / 2, c + RISER_W / 2
                    m1(b.left + dx, b.bottom + dy, b.right + dx, b.top + dy)
                m1(a0, min(b.bottom + dy, destino), a1, max(b.top + dy, destino))
            devs.append((tipo, w_gate, L_CANAL))
            sitios.append((interno[0] + dx, interno[1] + dx))
            sitios_alto.append((sobre_pad[0] + dx, sobre_pad[1] + dx))
            x += bb.width() + DEVICE_GAP
        return sitios, sitios_alto

    #  Las filas primero: los taps se meten en los huecos que dejan.
    barra(y_vss, "VSS")
    barra(y_vdd, "VDD")
    sitios_n, altos_n = fila("n", y_n0, y_vss + BAR, y_vdd) or ([], [])
    sitios_p, altos_p = fila("p", y_p0, y_vdd + BAR, y_fin + BAR) or ([], [])
    taps(y_ptap0, PPLUS, y_vss, sitios_n)
    taps(y_ntap0, NPLUS, y_vdd, sitios_p)
    #  Las tiras de arriba se atan al pad que tienen justo debajo, que es de su
    #  misma net (la fuente/drenador del NMOS es VSS como el tap p+; la del PMOS
    #  es VDD como el tap n+). No hace falta llegar a ninguna barra.
    taps(y_ptap1, PPLUS, y_ptap1 - CLR_TAP - BAR, altos_n)
    taps(y_ntap1, NPLUS, y_ntap1 - CLR_TAP - BAR, altos_p)

    #  El pozo cubre las DOS tiras de taps n+ y la fila p entera, con su
    #  enclosure, pero se queda a `NWELL_BORDE` del borde de la baldosa: sin
    #  `CONNECTIVITY_RULES` el deck aplica `NW.2b_MV` y pide 1.7 um al pozo del
    #  macro vecino **aunque sea la misma net**, y el de la derecha llega justo
    #  hasta su borde.
    top.shapes(L[NWELL]).insert(
        kdb.DBox(sn(nw[0]), sn(y_ntap0 - NWELL_ENC),
                 sn(ancho - nw[1]), sn(y_ntap1 + TAP_W + NWELL_ENC)))
    return y_fin


# --------------------------------------------------------------------------- #
#  El top: donde caben las baldosas
# --------------------------------------------------------------------------- #
def estantes(macros) -> dict[tuple[float, float], list[tuple[float, float]]]:
    """Los macros agrupados por estante: misma `y` y mismo alto.

    Esa es la condicion para que sus rieles esten a la misma cota, que es lo que
    permite que una baldosa metida entre dos de ellos conecte por abutment.
    """
    out: dict[tuple[float, float], list[tuple[float, float]]] = {}
    for _, _, x, y, w, h in macros:
        out.setdefault((round(y, 3), round(h, 3)), []).append((x, x + w))
    for v in out.values():
        v.sort()
    return out


def huecos(macros, die: kdb.DBox):
    """Los intervalos libres de cada estante, incluidos los dos margenes del die.

    Devuelve `(x0, x1, y, alto, hay_izq, hay_der)`.

    Lo que tapa un estante **no son solo los macros del estante**: WEIGHT_COMP
    esta en su propio estante (y = 202.15, 25 um de alto) y se mete de lleno en
    el hueco derecho de los cuatro estantes de COMP. Restando solo los del propio
    estante salia un "hueco" de 356 um de ancho que en realidad esta lleno de
    macros, y lo unico que lo cazaba era la comprobacion de metal1.
    """
    out = []
    for (y, h), _ in sorted(estantes(macros).items()):
        if h < ALTO_MIN:
            continue
        #  Todo macro que solape en `y` con este estante tapa su trozo de x.
        tapado = sorted((mx, mx + mw) for _, _, mx, my, mw, mh in macros
                        if my < y + h and my + mh > y)
        fundido: list[list[float]] = []
        for a, b in tapado:
            if fundido and a <= fundido[-1][1] + 1e-9:
                fundido[-1][1] = max(fundido[-1][1], b)
            else:
                fundido.append([a, b])
        bordes = ([[die.left, die.left]] + fundido + [[die.right, die.right]])
        for i in range(len(bordes) - 1):
            x0, x1 = bordes[i][1], bordes[i + 1][0]
            if x1 - x0 < ANCHO_MIN:
                continue
            out.append((x0, x1, y, h, i > 0, i + 1 < len(bordes) - 1))
    return out


def alcance(m1: kdb.Region, dbu: float, y0: float, y1: float,
            x_borde: float, hacia: int) -> float:
    """Cuanto hay que estirar un riel para SOLAPAR el del vecino.

    Devuelve el estiron (positivo) si por ese lado hay riel, y `-CLR` si no lo
    hay: entonces el riel se **retira** del borde, porque lo que asome puede
    quedar a menos de 0.23 um del metal del macro.

    Lo que se busca es una **barra horizontal maciza**, no cualquier metal. Un
    dedo de transistor que cruce la banda del riel la llena de arriba abajo y
    mide 0.9 um de alto igual que un riel: mirando solo el alto del bbox, el
    generador tomo tres dedos de WEIGHT_COMP por rieles, estiro el VSS de tres
    baldosas hasta dentro de ellos y **cortocircuito `net5`/`net6` de tres
    WEIGHT contra VSS**. El DRC daba limpio -- son solapes, no espaciados -- y
    solo lo vio el LVS: 877 nets contra 880. De ahi la sonda del fondo, que un
    dedo de 0.36 um de ancho no puede cubrir.
    """
    x0, x1 = (x_borde, x_borde + ALCANCE_MAX) if hacia > 0 else (x_borde - ALCANCE_MAX, x_borde)
    ventana = kdb.Region(kdb.DBox(x0, y0, x1, y1).to_itype(dbu))
    cerca = (m1 & ventana).merged()
    if cerca.is_empty():
        return 0.0
    #  Sonda: media micra de la banda ENTERA, al fondo de la ventana. Solo la
    #  llena algo que cruce la ventana de lado a lado con toda la altura.
    sx0, sx1 = (x1 - 0.5, x1) if hacia > 0 else (x0, x0 + 0.5)
    sonda = kdb.Region(kdb.DBox(sx0, y0, sx1, y1).to_itype(dbu))
    riel = cerca.interacting(sonda)
    if riel.is_empty() or not (sonda - riel).is_empty():
        return -CLR
    caja = riel.bbox().to_dtype(dbu)
    d = (caja.left - x_borde) if hacia > 0 else (x_borde - caja.right)
    return min(round(max(d, 0.0) + SOLAPE, 3), ALCANCE_MAX)


def comprobar(m1: kdb.Region, dbu: float, puestas, ext_de) -> list[str]:
    """Que cada baldosa tenga sus dos rieles separados y pegados a los del vecino.

    `Region.merged()` funde los poligonos que se tocan, asi que **un poligono es
    una componente conexa**. Con eso se contesta a las dos preguntas que el DRC
    no contesta: si VDD y VSS acabaron siendo la misma cosa (un corto, que ya
    paso una vez) y si el relleno quedo colgando (un abierto, que el DRC no ve
    porque 0.26 um de aire cumplen el espaciado de sobra).
    """
    fundido = m1.merged()
    fallos = []

    def componente(x, y):
        p = kdb.Region(kdb.DBox(x - 0.05, y - 0.05, x + 0.05, y + 0.05).to_itype(dbu))
        return fundido.interacting(p)

    for nombre, x0, x1, y, h, hay_izq, hay_der in puestas:
        cx = (x0 + x1) / 2
        c_vss = componente(cx, y + RAIL_W / 2)
        c_vdd = componente(cx, y + h - RAIL_W / 2)
        if c_vss.is_empty() or c_vdd.is_empty():
            fallos.append(f"{nombre}: no encuentro metal en un riel")
            continue
        if c_vss.bbox() == c_vdd.bbox():
            fallos.append(f"{nombre}: VDD y VSS son la MISMA componente (corto)")
            continue
        for net, comp, yy, lado in (("VSS", c_vss, y + RAIL_W / 2, 0),
                                    ("VDD", c_vdd, y + h - RAIL_W / 2, 2)):
            x_vec = (x0 - 2.0) if ext_de[nombre][lado] > 0 else (x1 + 2.0)
            sonda = kdb.Region(kdb.DBox(x_vec - 0.05, yy - 0.05,
                                        x_vec + 0.05, yy + 0.05).to_itype(dbu))
            if comp.interacting(sonda).is_empty():
                fallos.append(f"{nombre}: el riel {net} no llega al macro vecino")
    return fallos


# --------------------------------------------------------------------------- #
#  Salidas
# --------------------------------------------------------------------------- #
#: Capacidad de oxido de puerta del dispositivo de 6 V, en fF/um2. Sale de
#: `sm141064.ngspice` (`toxe` del modelo de 6 V) y solo se usa para dar la cifra
#: por pantalla: no entra en ningun fichero ni en ninguna comprobacion.
COX_FF_UM2 = 1.55


def lineas_spice(devs) -> list[str]:
    """Las lineas SPICE de los transistores, en el formato del proyecto.

    `spiceprefix=X`, que es como los instancia xschem y como los extrae magic:
    en este PDK los modelos son subcircuitos, asi que un elemento `M` no
    emparejaria con la llamada `X0 ... nfet_06v0` del extraido.

    El orden de nodos es el del modelo: `d g s b`.
    """
    out = []
    for i, (tipo, w, l) in enumerate(devs):
        if tipo == "n":
            nodos, modelo = "VSS VDD VSS VSS", "nfet_06v0"
        else:
            nodos, modelo = "VDD VSS VDD VDD", "pfet_06v0"
        out.append(f"XMdec{tipo}{i} {nodos} {modelo} "
                   f"L={l}u W={w}u nf=1 m=1")
    return out


#: Marca del bloque de codigo en el esquematico. Se busca por el `name=` de la
#: instancia, que es lo unico estable: la geometria del simbolo la mueve xschem.
NOMBRE_BLOQUE = "DESACOPLE"


def parchear_sch(lineas: list[str]) -> bool:
    """Mete (o sustituye) el bloque de desacople en el esquematico del top.

    Va **escrito por el generador y no a mano** a proposito: el layout y el
    esquematico tienen que salir de la misma corrida o el LVS deja de significar
    nada. Es una instancia de `devices/code_shown.sym` con `only_toplevel=true`,
    el mismo patron que usan los bancos de `XSCHEM/TEST*`.
    """
    if not SCH.exists():
        print(f"  AVISO: no encuentro {SCH}; no toco el esquematico")
        return False
    texto = SCH.read_text()
    cuerpo = "\n".join(lineas)
    bloque = ("C {devices/code_shown.sym} 700 700 0 0 {name=" + NOMBRE_BLOQUE
              + " only_toplevel=true value=\"\n"
              + "* Condensadores de desacople: NMOS y PMOS en inversion metidos en\n"
              + "* los huecos entre macros. LO ESCRIBE scripts/decap_fill.py -- no\n"
              + "* se edita a mano: tiene que ser exactamente lo que hay en el GDS.\n"
              + cuerpo + "\n\"}\n")
    patron = re.compile(r"^C \{devices/code_shown\.sym\}[^\n]*name=" + NOMBRE_BLOQUE
                        + r"\b.*?\"\}\n", re.S | re.M)
    nuevo, n = patron.subn(bloque, texto)
    if not n:
        nuevo = texto.rstrip("\n") + "\n" + bloque
    SCH.write_text(nuevo)
    return True


def main() -> int:
    args = sys.argv[1:]
    #  --- baldosa suelta: el lazo corto de DRC ---------------------------------
    for a in args:
        if a.startswith("--tile"):
            spec = a.split("=", 1)[1] if "=" in a else args[args.index(a) + 1]
            w, h = (float(v) for v in spec.lower().split("x"))
            ly = kdb.Layout()
            ly.dbu = 0.001
            _, devs = baldosa(ly, w, h, f"T{spec.replace('.', 'p').replace('x', 'x')}")
            dst = OUT / "decap_tile.gds"
            dst.parent.mkdir(parents=True, exist_ok=True)
            ly.write(str(dst))
            print(f"  baldosa {w} x {h}: {len(devs)} dispositivos -> {dst}")
            return 0

    if not GDS_IN.exists():
        sys.exit(f"no hay {GDS_IN} — corre antes `make top T={TOP}`")
    if not DEF.exists():
        sys.exit(f"no hay {DEF}")

    ly = kdb.Layout()
    ly.read(str(GDS_IN))
    top = ly.top_cell()
    die = top.dbbox()
    dbu = ly.dbu
    m1 = kdb.Region(top.begin_shapes_rec(ly.layer(*M1)))
    m1.merge()

    macros = colocacion(DEF)
    libres = huecos(macros, die)

    #  Las baldosas se construyen DENTRO del layout del top: `copiar_dispositivo`
    #  se encarga del cambio de dbu de los PCells, y asi no hay que pasar por un
    #  fichero intermedio (que le cambiaba el dbu al top; ver alli).
    especs, devs_por_baldosa, ext_de = [], {}, {}
    saltados = []
    #  De mayor a menor, y descartando lo que pise a una baldosa ya puesta: los
    #  estantes **se solapan en `y`** (WEIGHT_COMP ocupa 202.15..227.15 y el de
    #  COMP 202.13..233.59), asi que el mismo trozo de silicio aparece como hueco
    #  de dos estantes distintos. Poniendo los dos salian baldosas encima de
    #  baldosas -- y la comprobacion de conectividad lo cantaba como corto.
    puestas: list[tuple[float, float, float, float]] = []
    for x0, x1, y, h, hay_izq, hay_der in sorted(
            libres, key=lambda r: -(r[1] - r[0]) * r[3]):
        if any(x0 < bx1 and x1 > bx0 and y < by1 and y + h > by0
               for bx0, bx1, by0, by1 in puestas):
            continue
        #  Margen de guarda contra el contorno del die por los lados que lo
        #  tocan. Los estantes nunca llegan arriba ni abajo del die -- los
        #  macros van a `MARGIN` = 9 um -- asi que solo hace falta en x.
        nw = [NWELL_BORDE, NWELL_BORDE]
        if x0 <= die.left + 1e-6:
            x0 += BORDE_DIE
            nw[0] = NWELL_BORDE_DIE
        if x1 >= die.right - 1e-6:
            x1 -= BORDE_DIE
            nw[1] = NWELL_BORDE_DIE
        if x1 - x0 < ANCHO_MIN:
            saltados.append((x0, x1, y, h, "no cabe tras el margen del die"))
            continue
        ancho = round(x1 - x0, 3)
        ventana = kdb.Region(kdb.DBox(x0, y, x1, y + h).to_itype(dbu))
        if not (m1 & ventana).is_empty():
            saltados.append((x0, x1, y, h, "hay metal1 del ruteo dentro"))
            continue
        ext = (alcance(m1, dbu, y, y + RAIL_W, x0, -1),
               alcance(m1, dbu, y, y + RAIL_W, x1, +1),
               alcance(m1, dbu, y + h - RAIL_W, y + h, x0, -1),
               alcance(m1, dbu, y + h - RAIL_W, y + h, x1, +1))
        #  Las DOS alimentaciones tienen que tener a quien agarrarse. No basta
        #  con que haya macro al lado: WEIGHT_COMP no saca riel VSS por su borde
        #  de abajo -- ahi lo que asoma son los dedos de sus transistores -- asi
        #  que una baldosa a su derecha se quedaria con el VSS al aire, y eso el
        #  DRC no lo ve.
        if not ((ext[0] > 0 or ext[1] > 0) and (ext[2] > 0 or ext[3] > 0)):
            saltados.append((x0, x1, y, h, "el macro vecino no tiene riel a esa altura"))
            continue
        nombre = f"DECAP_{int(round(x0*100))}_{int(round(y*100))}"
        celda, devs = baldosa(ly, ancho, h, nombre, ext, tuple(nw))
        if not devs:
            #  Y se borra: una baldosa creada y no instanciada se queda como
            #  **celda de arriba suelta** en el layout, y al releer el GDS
            #  `top_cell()` aborta con "multiple top cells".
            ly.delete_cell_rec(celda.cell_index())
            saltados.append((x0, x1, y, h, "no cabe ni una banda"))
            continue
        especs.append((nombre, x0, x1, y, h, hay_izq, hay_der))
        devs_por_baldosa[nombre] = devs
        ext_de[nombre] = ext
        puestas.append((x0, x1, y, y + h))

    if not especs:
        sys.exit("  no se pudo rellenar ningun hueco")

    for nombre, x0, x1, y, h, _, _ in especs:
        celda = ly.cell(nombre)
        top.insert(kdb.DCellInstArray(celda.cell_index(),
                                      kdb.DTrans(kdb.DVector(x0, y))))
    #  Aplanado, como el resto del top (`def_to_gds.py::flatten_all`): el LVS
    #  compara contra una referencia aplanada y una jerarquia nueva aqui haria
    #  que el deck extrajera subcircuitos que la referencia no tiene.
    top.flatten(-1, True)
    ly.write(str(GDS_OUT))

    #  --- comprobaciones -------------------------------------------------------
    ly2 = kdb.Layout()
    ly2.read(str(GDS_OUT))
    t2 = ly2.top_cell()
    m1_final = kdb.Region(t2.begin_shapes_rec(ly2.layer(*M1)))
    fallos = comprobar(m1_final, ly2.dbu, especs, ext_de)

    #  --- salidas --------------------------------------------------------------
    devs = [d for nombre, *_ in especs for d in devs_por_baldosa[nombre]]
    lineas = lineas_spice(devs)
    DEV_TXT.write_text("\n".join(lineas) + "\n")
    HUECOS_TXT.write_text("\n".join(
        f"{x0:.3f} {y:.3f} {x1:.3f} {y + h:.3f}" for _, x0, x1, y, h, _, _ in especs) + "\n")
    parchear_sch(lineas)

    #  --- informe --------------------------------------------------------------
    #  La UNION, no la suma: los huecos de estantes que se solapan cuentan el
    #  mismo silicio dos veces.
    reg_libre = kdb.Region()
    for x0, x1, y, h, _, _ in libres:
        reg_libre.insert(kdb.DBox(x0, y, x1, y + h).to_itype(dbu))
    reg_libre.merge()
    area_total = reg_libre.area() * dbu * dbu
    area_llena = sum((x1 - x0) * h for _, x0, x1, y, h, _, _ in especs)
    n_n = sum(1 for t, _, _ in devs if t == "n")
    w_n = sum(w for t, w, _ in devs if t == "n")
    w_p = sum(w for t, w, _ in devs if t == "p")
    cap = (w_n + w_p) * L_CANAL * COX_FF_UM2 / 1000.0
    print(f"  {TOP}: {len(especs)} baldosas en {len(libres)} huecos de estante")
    print(f"    hueco de estante  {area_total:9,.0f} um2")
    print(f"    rellenado         {area_llena:9,.0f} um2  "
          f"({100 * area_llena / area_total:.0f} %)")
    print(f"    sin rellenar      {area_total - area_llena:9,.0f} um2")
    for x0, x1, y, h, motivo in saltados:
        print(f"      hueco {x0:7.2f}..{x1:7.2f} y={y:7.2f} "
              f"({(x1 - x0) * h:6.0f} um2): {motivo}")
    print(f"    {len(devs)} transistores: {n_n} NMOS + {len(devs) - n_n} PMOS")
    print(f"    W total  N {w_n:8.1f} um   P {w_p:8.1f} um   L {L_CANAL} um")
    print(f"    desacople estimado ~{cap:.2f} pF")
    print(f"  {GDS_OUT}")
    print(f"  {DEV_TXT}   ({len(lineas)} lineas, metidas en {SCH.name})")
    if fallos:
        print("\n  CONECTIVIDAD:")
        for f in fallos:
            print(f"    {f}")
        return 1
    print("  conectividad: cada baldosa con sus dos rieles separados y "
          "pegados al macro vecino")
    return 0


if __name__ == "__main__":
    sys.exit(main())
