# OpenROAD collateral

Everything OpenROAD needs to assemble the analog blocks of this project into the
top level, `GRADIENT_NAV`. Nothing here is a source: it is all generated from the
layouts and the xschem netlist, and it is regenerated with one command.

## El proceso completo

De cero a fichero de submision, en orden. Cada paso depende del anterior.

```bash
# 0. Los cuatro bloques, si han cambiado los esquematicos (fuera de esta carpeta)
cd /foss/designs/zotnetic_layout
for B in COMP OPAM DECODER WEIGHT_COMP; do
  env -u PYTHONPATH /headless/.venvs/zotnetic/bin/python build_block.py $B
done

# 1. El top entero: verilog -> colateral -> floorplan -> ruteo -> GDS -> relleno
cd /foss/designs/a_zonetic2026/openroad
make top

# 2. Verificacion. Los tres comprueban cosas DISTINTAS, no son opiniones del mismo.
make drc          # KLayout, deck de firma: FEOL/BEOL/conectividad
make drc-density  # KLayout, reglas de densidad: `make drc` NO las corre
make drc-magic    # magic: incluye las reglas de relleno `DPF.*` que KLayout no mira
make lvs          # netgen sobre la extraccion de magic
python3 scripts/check_connectivity.py   # que el ruteo conecte: 55/55
```

o paso a paso:

```bash
make verilog      # xschem netlist -> structural + flat Verilog
make collateral   # layouts -> LEF / Liberty / black-box Verilog
make check        # load it all in OpenROAD and list the macros
make floorplan    # place the macros, build the power grid, write the DEF
make route        # ruteo global + detallado
make gds          # DEF -> GDS, with the real layout inside every macro
make fill         # relleno de densidad -> out/GRADIENT_NAV_filled.gds
```

**Cual es el entregable.** `out/GRADIENT_NAV.gds` es el de trabajo: es el que leen
el DRC, el LVS y `check_connectivity.py`, y el que hay que mirar cuando algo falla.
El de submision es **`out/GRADIENT_NAV_filled.gds`**, el mismo con el relleno de
densidad encima.

**Si el DRC del top no sale limpio a la primera**, no es raro: el lazo dirigido por
DRC necesita un par de vueltas (ver mas abajo). `out/drc_blockages.txt` es
acumulativo y viene ya con las 11 zonas que hacen falta; si se borra, hay que
rehacer las vueltas.

    python3 scripts/drc_blockages.py   # anade lo de la ultima tanda de DRC
    make top && make drc               # y otra vuelta

## What is here

| Path | What it is | Generated? |
|---|---|---|
| `gds/` | relative symlinks to `../Layouts/*/…gds` | links, nothing was moved |
| `lef/` | abstract LEF: outline, pins, obstructions | yes, by magic |
| `lib/` | black-box Liberty (pins only, no timing arcs) | yes |
| `verilog/<MACRO>.v` | black-box module declarations, for yosys | yes |
| `verilog/GRADIENT_NAV.v` | structural Verilog, full hierarchy | yes |
| `verilog/top_macros.v` | **the design OpenROAD reads**: flat, macros only | yes |
| `verilog/top.v` | the hand-written template from before there was a netlist | by hand, unused |
| `constraints/top.sdc` | placeholder constraints (no clock yet) | by hand |
| `scripts/` | the generators and the OpenROAD scripts | by hand |
| `out/GRADIENT_NAV.gds` | el top, **fichero de trabajo**: lo leen DRC, LVS y conectividad | si |
| `out/GRADIENT_NAV_filled.gds` | el top con relleno de densidad, **el que se entrega** | si |
| `out/drc_blockages.txt` | zonas prohibidas al router, del lazo dirigido por DRC | si, acumulativo |

## The blocks

| Macro | Size | Pins | Status |
|---|---|---|---|
| `COMP` | 104.28 × 31.46 µm | `VDD INN OUT INP VSS` | DRC 0, LVS matches, 2 MIM |
| `OPAM` | 88.27 × 31.46 µm | `VDD INN OUT INP VSS` | DRC 0, LVS matches, 2 MIM, `M43` girado y a caballo |
| `WEIGHT_COMP` | 37.17 × 25.00 µm | `VDD VSS VA VB VC VD WE OUT OUT_N` | DRC 0, LVS matches |
| `DECODER` | 37.89 × 15.84 µm | `VDD XY XZ X Y YZ Z VSS` | DRC 0, LVS matches |

**`M43` del OPAM va aparte.** Es un `pfet_06v0` de `L=20u W=0.7u`; girado 90° mide
4.46 × 22.96 µm, y dentro de la fila P la estiraba entera a 22.96 cuando el resto
de sus dispositivos miden 11.96 — el bloque acababa en 43.12 de alto. Ahora se
coloca **a la derecha de todo, a caballo de las dos filas**, que es donde su
altura cabe en lo que ya ocupan N + canal + P: **87.44 × 43.12 → 88.27 × 31.46**,
un 27 % menos de área, y OPAM deja de ser el bloque más alto del chip.

Lo que hay que cuidar de un PFET ahí es el pozo. Baja hasta la altura de la fila
N, así que se dibuja **en L**, de una pieza con el de la fila P (dos pozos
separados pedirían 1.7 µm por `NW.2b_MV`), y su franja se excluye de la tira de
taps p+ — un tap ahí sería pplus dentro del nwell, que además cortocircuita VGND
con el pozo de VDD. Y como mide 23 µm de alto, la tira de taps n+ de bajo VPWR no
le llega al extremo de abajo (`DF.13_MV` pide un tap a menos de 15 µm), así que
lleva una **columna de taps** a su derecha.

Los terminales no necesitaron nada nuevo: los carriles laterales del envoltorio
girado ya recorren toda su altura, de modo que el stub del router los prolonga
hasta el trunk del canal, que le cruza por la mitad.

Cada bloque **sube sus puertos a Metal3**: los rieles con una barra del ancho
completo y cada puerto de señal con la suya sobre su trunk
(`zotnetic_layout/coil_layout/power.py`). Sin eso, un pin de señal se queda en
Metal1/Metal2 rodeado del ruteo del propio bloque y el router del top no le puede
bajar una vía sin tocar al vecino: 43 `Cut Short` en el ruteo detallado.

The top is **31 macros**: 12 `OPAM`, 12 `COMP`, 4 `DECODER`, 3 `WEIGHT_COMP`.

## The top

| | |
|---|---|
| Die | 371.70 × 408.52 µm, 151 847 µm², proporción **1.099** |
| Macro area | 77 880 µm², **57 %** de utilización |
| Arrangement | empaquetado por estantes (FFDH), 9 estantes; ocho de ellos miden 31.46 porque `OPAM` y `COMP` ya son igual de altos, y cada estante de OPAM se lleva de propina un `WEIGHT_COMP` |
| Power | Metal4 vertical sobre los bloques, Metal5 horizontal en los canales, hasta la barra de Metal3 de cada bloque. **31 de 31 atados a las dos nets** |
| Signal | 53 nets, **100 % ruteadas**, `detailed_route` con **0 violaciones** |
| Output | `out/GRADIENT_NAV.def`, `..._routed.def`, `.gds`, `.png` |

Antes de todo esto el die medía 495.12 × 390.58 (193 385 µm², proporción 1.27) al
51 %: **13 % menos de área, más cuadrado y más denso**. Lo que sobraba era la
rejilla de columnas, que obligaba a que toda columna fuese tan ancha como su
macro más ancho — cada fila de OPAM (87.44) tiraba 16.84 µm dentro de una columna
de 104.28, doce veces.

Rows and columns are sized **per row and per column**, not once from the tallest
macro. A single pitch left the 15.84 µm `DECODER` floating in the middle of a
43.46 µm cell, too far from the channel for anything to reach it.

A macro narrower than its column is **shifted right onto the column's widest
Metal4-free band**, because that is where the power straps come down. Left flush
against the column edge, the `DECODER` and the `WEIGHT_COMP` sat under the MIM
plates of `OPAM` and `COMP`, which block Metal4 exactly there, and pdngen aborted
with `PDN-0232` on all four DECODERs.

## How the power gets in

Each block brings `VDD` and `VSS` up from its Metal1 rail to a **full-width
Metal3 bar** over that rail (`zotnetic_layout/coil_layout/power.py`, run after
routing because the vias need a gap in Metal2 and there is no gap to find until
the router has finished). That bar is the landing pad.

The top then runs **Metal4 vertically over the blocks** — not down the channels,
which was the earlier attempt and could never work, because a stripe in a channel
never crosses a pin. Where Metal4 may go is read from the LEF obstructions of
each column's macros, since the MIM plates block it across the middle of `COMP`
and `OPAM` and the free bands are not the same in the two. Metal5 stays in the
row channels and only has to meet Metal4.

All 31 macros end up tied to both nets: 67 via3 per net.

Two traps worth remembering:

- pdngen reports a block whose grid came out empty (`PDN-0232`) and then aborts
  the whole run (`PDN-0233`). It is not a warning you can ignore.
- `PDN-0231 <inst> is not connected to any power/ground nets` is about the
  **netlist**, not the geometry. That is how the floating supplies on the twelve
  OPAMs surfaced: in `COMBINATION/GRADIENT.sch` the `VDD`/`VSS` labels of the
  three OPAM instances sat 20 units to the left of the pins and never touched
  them, so the netlist gave them `net4`…`net9` instead. Twelve op-amps with no
  supply, and nothing else in the flow had complained.

## Verificación

```bash
make drc         # KLayout, el deck de firma: cuatro bloques + top
make fill        # relleno de densidad -> out/GRADIENT_NAV_filled.gds
make drc-density # las reglas de densidad, que `make drc` NO corre
make drc-magic   # magic — NO es segunda opinión: trae las reglas de relleno
                 # `DPF.*` que KLayout no comprueba, y le faltan las de densidad
make lvs         # netgen sobre la extracción de magic
make lvs-klayout # el deck de firma, también sobre el top
make check-all   # drc + drc-magic + drc-density + lvs
```

Estado a día de hoy:

| | KLayout DRC | densidad | KLayout LVS | magic DRC | netgen LVS |
|---|---|---|---|---|---|
| `COMP` | limpio | n/a (1) | match | limpio | **match** |
| `OPAM` | limpio | n/a (1) | match | limpio | **match** |
| `WEIGHT_COMP` | limpio | n/a (1) | match | limpio | **match** |
| `DECODER` | limpio | n/a (1) | match | limpio | **match** |
| `GRADIENT_NAV` | **limpio** | no cumple | — | **limpio** | dispositivos OK, 54 nets |
| `GRADIENT_NAV_filled` | **limpio** | **limpio** | pendiente (2) | **limpio** | pendiente (2) |

(1) La densidad se mide **sobre el die entero**, asi que sobre un bloque suelto de
3 000 um2 no significa nada. El unico sitio donde tiene sentido es el top.

(2) El relleno aparece en la extraccion como metal flotante —los decks suman el
dummy a la capa fisica—, asi que el LVS sobre el fichero con relleno hay que
volver a pasarlo. No cambia nada de lo de arriba, pero esta sin comprobar.

Y una comprobación más, que no es DRC ni LVS pero contesta a la pregunta que
ninguno de los dos contesta —¿está el ruteo realmente conectado?—:

```bash
python3 scripts/check_connectivity.py    # 55/55 nets del DEF conectadas en el GDS
```

### Densidad: un pase aparte, y solo en KLayout

**El DRC de firma no comprueba densidad si no se le pide.** El deck solo ejecuta
esas reglas con `--density` / `--density_only`, asi que todos los "limpio" de las
demas secciones son de FEOL/BEOL/conectividad **sin densidad**. Y `magic` no sirve
de segunda opinion: su techfile de GF180 no trae ni una regla de densidad, asi que
esta comprobacion existe unicamente en KLayout.

Pedidas, el top las incumplia todas. Son de **minimo**: falta metal, no sobra.

| regla | capa | sin relleno | con relleno | pide |
|---|---|---|---|---|
| `DCF.1b` | COMP (activo) | 10.19 % | **32.27 %** | 25 % |
| `PL.8` | Poly2 | 7.26 % | **20.77 %** | 14 % |
| `M1.4` | Metal1 | 9.98 % | **31.37 %** | 30 % |
| `M2.4` | Metal2 | 3.83 % | **31.34 %** | 30 % |
| `M3.4` | Metal3 | 5.30 % | **30.47 %** | 30 % |
| `M4.4` | Metal4 | 21.43 % | **32.70 %** | 30 % |
| `M5.4` `MT.3` `MT.1` | Metal5 | 20.00 % | **30.46 %** | 30 % |

`scripts/fill_density.py` corre **despues** del GDS (`make fill`): lee
`out/GRADIENT_NAV.gds` y escribe `out/GRADIENT_NAV_filled.gds`, que es el fichero
de submision. El de partida no se toca, para que el lazo de depuracion siga igual.

**Basta con rellenar los canales.** Los 31 macros ocupan 77 880 um2 de los 151 847
del die y quedan 73 967 libres; con eso las siete capas llegan al minimo, asi que
**no hay metal flotante encima de los amplificadores ni de los MIM**.

Tres cosas que costaron un intento fallido de 6214 violaciones:

1. **El DRC y el LVS SI ven el dummy.** Lo que se define como `get_polygons(34, 0)`
   es la capa *drawn*; la fisica se compone despues con
   `metal1 = metal1_drawn + metal1_dummy` (`layers_def.drc`), y el LVS hace lo
   mismo. El relleno tiene que cumplir el DRC entero, y aparece en la extraccion
   como metal flotante.
2. **Cuadrados enteros, nunca recortados.** Recortar la rejilla contra la zona
   libre deja cuellos y trozos por debajo del area minima: de ahi salian miles de
   `M*.1` y `M*.3`. Ahora un cuadrado o cabe entero o no se pone, con lo que ancho
   y area se cumplen por construccion.
3. **`MT.*` se aplica a Metal5.** Para el stack de 5 metales el deck hace
   `top_metal = metal5`, asi que Metal5 se rige por `MT.1` (0.36 de ancho),
   `MT.2a` (0.46 de espaciado) y `MT.4` (0.5625 um2 de area), no por los 0.28 y
   0.1444 de las `M5.*`.

Y una advertencia honesta: `comp_dummy` y `poly2_dummy` son lo que el deck cuenta,
pero en silicio el activo dummy necesita su implante. Para pasar el DRC del PDK
basta con dibujar el datatype; para fabricar, habria que revisarlo con la foundry.

La rejilla se genera por erosion de region —un cuadrado de lado L cabe entero si su
centro cae en la zona erosionada L/2—, no probando poligono a poligono, que tardaba
minutos por capa.

### El MIM y la jerarquía: 572 por bloque, y 13 745 en el top

magic daba 572 violaciones `Can't overlap those layers` en cada bloque con MIM, y
su extracción dejaba los terminales del condensador en nets propias (43 nets
contra 41 en netgen). Un solo motivo, y no era del deck:

**Los booleanos con que magic lee un GDS se evalúan celda a celda.** La regla que
reconoce el contacto del MIM es

```
layer mimcc VIA4 and MET5 and CAPM and CAPDEF
```

y el mar de vía4 salía de `gf180.via_generator`, que trae jerarquía propia. En esa
subcelda no hay ni `fusetop` (CAPM) ni `cap_mk` (CAPDEF) ni metal5 — los
marcadores viven en la celda de arriba —, así que la regla no disparaba nunca: la
vía entraba como `via4` plana dentro de un `mimcap`, dos tipos del mismo plano, y
de ahí el conflicto. Aplanar **después** del `gds read` no vale: para entonces la
capa ya está mal pintada.

Se arregla en el origen (`coil_layout/caps.py::flat_add`): la geometría de las
vías se copia dentro de la celda de arriba en vez de instanciarse. Con eso magic
lee el bloque limpio en 0.8 s, sin banderas ni parches. `gds flatglob` al leer
también funciona, pero hay que aplanar además los rectángulos y las celdas sin
nombre —la jerarquía de `via_generator` cuelga de ellas— y son minutos por bloque.

El top heredaba lo mismo multiplicado por sus 24 MIM: **13 745 → 17**.

### Lo que netgen necesitaba además

Tres traducciones de la netlist de referencia, todas en `lvs_netgen.py` y sólo
para netgen — el `<B>_lvs.spice` de disco se queda como lo quiere KLayout:

- **`M` → `X`** en los MOSFET. KLayout necesita `M` (un elemento que empieza por
  otra letra no es un MOSFET para SPICE); magic extrae `X ... pfet_06v0`, porque
  en el PDK esos modelos son subcircuitos.
- **`C ... cap_mim_2f0fF` → `X ... cap_mim_2f0_m4m5_noshield`**, que es como lo
  llama magic. Antes netgen comparaba un condensador de pines `top`/`bottom`
  contra un subcircuito de pines posicionales.
- **Los dos terminales del MIM, declarados permutables.** Los dos condensadores de
  COMP son idénticos y comparten un terminal en `OUT`: topológicamente son
  intercambiables salvo por el orden de sus pines, y netgen no sabe deshacer ese
  empate — lo dice él mismo, `Port matching may fail to disambiguate symmetries`.
  Permutar las dos patas de un condensador es lo que hace el LVS de KLayout.

Y el orden de los puertos del `.subckt` extraído se reordena para seguir al de
referencia: netgen empareja los pines del top **por posición**, y con la misma
conectividad exacta terminaba en `Top level cell failed pin matching`.

### El top: cuatro causas, y ninguna era el layout

El LVS del top empezó en 1436 dispositivos y 1003 nets contra los 1389 y 880 de
la referencia. Antes de tocar nada conviene saber **si el layout está bien**, y
para eso está `scripts/check_connectivity.py`: extrae la conectividad del GDS con
KLayout —sólo metales y vías, sin dispositivos, medio minuto— y comprueba que
todos los terminales de cada net del DEF caen en la misma net extraída. Da
**55/55**. Un circuito abierto no viola ninguna regla de DRC, así que sin esta
comprobación no hay forma de separar un fallo del layout de uno de la extracción.

Lo que iba mal, por orden de tamaño:

1. **El pin del LEF era la caja envolvente, no el metal.** `lef write` de magic da
   un rectángulo por puerto. Cuando los pads de un puerto no llegaron a unirse en
   barra (`add_signal_access` sólo los une si el espaciado se lo permite), ese
   rectángulo declara como aterrizable el hueco que hay entre ellos: en `OPAM.INN`
   son 0.4 µm de nada, y por debajo pasa además un riser de otra net. El router
   aterrizaba ahí, a 0.14 µm del pad de al lado. **Eran ocho nets realmente
   abiertas.** `build_collateral.py::_clip_to_real` recorta ahora cada RECT del pin
   contra el metal que hay de verdad en el GDS.
2. **El pozo n de cada macro salía flotante.** Otra vez los booleanos por celda: al
   sustituir los macros, el lector de DEF de KLayout reconstruye su jerarquía
   interna de otra manera y el tap deja de cumplir `COMP and NPLUS and NWELL`, así
   que el pozo quedaba como nodo suelto (`w_1724_75756#`) en vez de VDD. Leyendo el
   mismo bloque de su propio GDS sí queda atado. **43 nets de pozo y 47 de activo
   de más.** Se cura aplanando el top al escribir el GDS
   (`def_to_gds.py::flatten_all`).
3. **Al aplanar, las etiquetas de los macros se pisan.** Cada bloque trae sus
   propias etiquetas de puerto en Metal1 (`OUT`, `INN`, `Z`, `VDD`...), y aplanadas
   caen todas en la misma celda: doce `OUT`, doce `INN`, cuatro `Z`. magic da por
   **unido** todo lo que comparte nombre de etiqueta, así que la net `Z` salía con
   1501 pines y el chip se quedaba en 848 nets, por debajo de las 880. Se guardan
   las etiquetas del top antes de aplanar y se reponen después: quedan las 19 de
   los pines del DEF y ninguna más.
4. Y una pista falsa que conviene no volver a seguir: **el GDS del top sí tiene las
   vías del router**. Parecía que no porque `cell.shapes()` sin recursión no las
   ve — el lector de DEF mete cada vía en una celda propia (`VIA_Via3_HH`). Las
   vías de tecnología que el router se fabrica de las `VIARULE` se resuelven solas
   desde el LEF de la librería de celdas; no hace falta volcarlas a ningún sitio.

### El MIM que no cuadraba en OPAM

`OPAM` se quedaba en 38 nets contra 37 con netgen: un terminal de uno de los dos
condensadores salia como net suelta (`m4_6467_2958#`). No era el metal5, como
parecia al medir la geometria en planta — era la **placa de arriba**, y el motivo
es el mismo tipo de cosa que el resto de este apartado.

Cada placa de metal5 baja a metal3 por una sola via4 fuera del marcador del MIM.
La del MIM B aterriza en un pad de metal4 propio, limpio. La del MIM A aterrizaba
**encima de la placa de metal4 del MIM B**, que esta entera dentro de su `cap_mk`.
Ahi magic ya no ve metal4 sino `mimcap`, y una via4 normal sobre `mimcap` no es ni
via ni contacto de MIM —`mimcc` exige ademas estar dentro del `fusetop`—, asi que
el terminal se quedaba flotando. En silicio esa via es buena; para la extraccion
no existe.

Lo permitia la excepcion de misma net de `caps.py::_too_close`, que deja que dos
formas de la misma net se contengan una a otra porque al fusionarse no hay
separacion que medir. Correcta entre dos pads, no contra una placa de MIM. Con la
condicion anadida —y **simetrica**, porque da igual cual de los dos se coloque
primero— el buscador encuentra otra colocacion sin que el bloque crezca: OPAM
sigue en 88.27 x 31.46 y netgen da `Circuits match uniquely`.

### El DRC del top: de 37 a cero

Lo primero fue saber **contra que** eran. Restando del metal del top el que aportan
las instancias de los bloques, las 15 que quedaban resultaron ser todas lo mismo:
**cable del router contra metal de un macro**, ninguna macro contra macro ni
router contra router, y con huecos de 0.236 a 0.273 — justo por debajo del 0.28
de la regla. Eso ya no es azar, son dos sesgos sistematicos:

1. **La obstruccion tiene que llevar media anchura de cable.** Las nets del top van
   con la regla no estandar `ANCHO` (0.38), y el router mantiene el cable fuera de
   la obstruccion midiendo por su **eje**: creciendola solo el espaciado, el borde
   acababa dentro. `_OBS_GROW` crece ahora `0.30 + 0.19`.
2. **El router mide por proyeccion y el deck en euclidea.** `Mn.2a` se comprueba
   esquina con esquina, asi que dejar exactamente 0.280 en ortogonal da menos en
   una esquina en diagonal. El techlef parcheado le pide al router **0.300** en
   Metal2/3/4: cualquier separacion euclidea es entonces >= 0.300 > 0.280 y el
   problema desaparece por construccion. Cuesta un 7% de holgura, que sobra.

Y lo mismo, un escalon antes, en dos sitios mas: el pin del LEF era la caja
envolvente y declaraba aterrizable el hueco entre dos pads; y una plataforma de
puerto necesita hueco para el cable que va a aterrizar en ella, no solo para si
misma (`_LAND_CLEAR` en `power.py`; en DECODER dos pads de puertos distintos
quedaban a 0.295 um, legal entre ellos pero sin sitio para el cable).

Con eso se llego a **9-10, sin patron comun**: sitios sueltos que cada tanda
cambiaba de sitio sin bajar de la decena. De ahi para abajo subir margenes solo
baraja, asi que se cierra con un **lazo dirigido por DRC**, entero dentro de
OpenROAD (`scripts/drc_blockages.py`):

```
ruteo -> GDS -> DRC de firma -> obstrucciones -> ruteo
```

Los sitios que marca el deck se convierten en `dbObstruction` y el router vuelve a
tender. El fichero `out/drc_blockages.txt` es **acumulativo a proposito**: lo
prohibido en una vuelta lo sigue estando en la siguiente, y por eso el lazo
converge en vez de oscilar. **10 -> 1 -> 0 en dos vueltas**, con las 55 nets del
DEF conectadas en las tres — no ha cerrado el DRC rompiendo el ruteo. `magic` da
tambien limpio.

    python3 scripts/drc_blockages.py           # anade lo de la ultima tanda
    python3 scripts/drc_blockages.py --reset   # empieza de cero

### Lo que queda

**El top, en LVS.** Ahora tiene tambien el deck de firma
(`scripts/lvs_klayout.py`), que le faltaba: hasta ahora solo se comprobaba con
netgen. Montarlo pedia tres cosas en la preparacion de la referencia, y cada una
tapaba a la siguiente:

1. Las sondas de corriente `Vmeas` del netlist de xschem. Son fuentes de 0 V, o
   sea un cable: lo correcto no es tirarlas sino **unir las dos nets**, y por
   ambito, porque los nombres se repiten entre bloques. Sin esto el deck ni
   arrancaba (`Not a known element type: 'V'`).
2. La referencia iba **jerarquica** contra un layout que es una sola celda plana.
   Asi no emparejaba ni una de 1815 nets ni uno de 3414 dispositivos.
3. El netlist extraido salia **sin un solo pin**; el deck solo llama a
   `make_top_level_pins` con `--top_lvl_pins`.

Con eso el resultado ya es informativo: **los dispositivos cuadran exactamente,
1707 contra 1707**. Lo que bloquea la comparacion es que la extraccion del top
asigna el bulk de **780 de los 801 pfet al sustrato** en vez de a su pozo n. Eso
hincha un solo nodo hasta 2438 terminales, que se traga VDD, VSS y el nombre de
nueve pines, y de ahi el descuadre de nets (954 contra 861). magic ve el mismo
nodo con 2442, asi que no es mania de una herramienta.

**No es el layout.** Comprobado: el pozo esta entero en el top (33 442.9 um2 en
43 islas, exactamente la suma de las 31 instancias), **los 43 pozos tienen su tap
n+ contactado** (286 contactos), no hay solape entre las tiras de VDD y las de
VSS, ni una sola via3 que toque la barra de una alimentacion y la tira de la
otra, ni metal del router sobre las barras de los macros. Y el mismo bloque
suelto extrae bien: en COMP los 37 pfet dan `bulk=VDD`.

Queda, por tanto, alinear la invocacion del deck para el top con la que usan los
bloques desde `build_block.py`. Una diferencia conocida: al aplanar el top se
quitan las etiquetas internas de los macros (hace falta, si no magic funde por
nombre todo lo que se llama igual), y con ellas el nodo del pozo se queda sin
nombre.

**Antes, con netgen: 54 nets de diferencia** (venia de 47 dispositivos y 123 nets).
Los **dispositivos ya cuadran exactamente**: 1389 contra 1389. Lo que sobra son 54
nets, y de ellas quedan tres pozos flotantes localizados; el resto son nodos de
activo sin etiqueta (`a_...#`), de los que hay 922 y que en su mayoria si emparejan.
La conectividad del ruteo esta verificada aparte y da 55/55, asi que lo que falta
esta en la extraccion, no en el layout — pero hasta cerrarlo no es una
verificacion, es una indicacion.

## Things that will bite you

**1. Do not give the black-box Verilog to OpenROAD.** `verilog/COMP.v` and
friends are for synthesis (yosys). OpenROAD binds each instance to the LEF
`MACRO` with the same name; if you also hand it the module definition, it
elaborates it as an empty hierarchical module and the instances vanish —
`link_design` still reports success and you get a block with **0 instances**.
`scripts/load_design.tcl` reads only `verilog/top_macros.v` for this reason.

**2. `WEIGHT` and `COMP_OUT` become one `WEIGHT_COMP`.** The top instantiates
them separately; the macro that exists packs both. `spice_to_verilog.py` does not
hard-code the substitution: it reads the pattern from `WEIGHT_COMP`'s own netlist
and matches it, and raises if it stops matching. That matters because the pin
order is not the identity — `WEIGHT_COMP` feeds its `VB` into `WEIGHT`'s `VC` pin
and vice versa, so a hand-typed mapping would swap two weights and route
perfectly.

**3. `+`, `-` and `.` are not Verilog.** The schematics used to carry `S1+`,
`X-`, `IN-` and a symbol called `comp._out`. They are now `S1P`, `XN`, `INN` and
`COMP_OUT`. Anything that still refers to the old names (the `TEST/` testbenches)
needs updating.

**4. El abstracto no puede anunciar más de lo que el top puede usar.** Los pines
de señal se recortan a Metal3 (`keep_top_access`), y lo que se les quita **pasa a
obstrucción**, no a la basura: en COMP y OPAM esas formas de Metal4/Metal5 son la
placa del MIM, y borrarlas del LEF la dejó invisible — las tiras de alimentación
se le pusieron a 0.51 µm cuando `MIMTM.1` pide 1.2.

**5. Una obstrucción del LEF se recorta al contorno del macro.** Engordarla no
protege lo de fuera, así que el router tendía Metal4 pegado a una placa desde el
canal de al lado. Lo que sí respeta es un bloqueo declarado en el top, y eso es
lo que hace `floorplan_top.tcl` con los 72 halos de Metal4.

**6. KLayout y netgen quieren convenios opuestos para el mismo transistor.**
KLayout necesita `M` (un elemento que empieza por otra letra no es un MOSFET para
SPICE); magic extrae `X ... pfet_06v0`, porque en el PDK esos modelos son
subcircuitos, y netgen entonces compara una llamada a subcircuito contra un
dispositivo y no empareja ni uno. `lvs_netgen.py` traduce la referencia al vuelo;
el `<B>_lvs.spice` de disco se queda como lo quiere KLayout.

**7. `lef write` without `-hide`.** With `-hide`, magic collapses the
obstructions into a few coarse blocks and one of them covered the block's own
Metal1 power rail — pdngen reported `VSS on Metal1 is partially blocked (99.0%)`
and could not place a single via. Detailed obstructions are verbose and correct.

**8. This OpenROAD has no `write_gds`.** The stream-out goes through KLayout,
which reads the DEF and substitutes each macro's abstract for the GDS it was
abstracted from (`macro_resolution_mode = 2`). Mode 1 reads the GDS files,
ignores them, and writes LEF outlines — a chip-shaped box with no transistors.

**9. Pin directions come from the schematic, and some look wrong.** `OUT` on
`COMP`, and `WE` / `OUT` / `OUT_N` on `WEIGHT_COMP`, come out as `inout` because
that is how they are drawn in xschem (`iopin` / `:B`). If they really are
outputs, change them to `opin` and re-run `make collateral`.

## Reglas aprendidas

Lo que ha costado descubrir, en una linea cada una. Casi todas se pagaron con horas.

**Sobre las herramientas**

- **magic evalua los booleanos del GDS celda a celda.** Una forma solo existe para el si
  todas las capas que la definen estan en la MISMA celda. Nos costo tres veces: las vias
  del MIM en una subcelda sin los marcadores (572 violaciones por bloque), el tap del pozo
  al sustituir macros (43 nets de pozo flotantes) y, de rebote, la solucion —aplanar— trajo
  la siguiente.
- **magic funde por nombre de etiqueta.** Al aplanar el top caian doce `OUT`, doce `INN` y
  cuatro `Z` en la misma celda y la net `Z` acabo con 1501 pines. Solo deben sobrevivir las
  etiquetas de los pines del top.
- **Ninguna herramienta cubre todo.** KLayout tiene las reglas de densidad pero no mira la
  geometria del relleno de poly; magic no tiene ni una regla de densidad pero si las
  `DPF.*`. Sobre el mismo fichero, KLayout decia limpio y magic sacaba 134 488 violaciones.
- **El DRC no ve un corto.** Dos formas de nets distintas que se solapan se funden en un
  poligono y ninguna regla salta. Un abierto tampoco: no viola nada. Por eso existe
  `check_connectivity.py`, que es lo unico que contesta "¿esta el ruteo conectado?".
- **KLayout y netgen quieren convenios opuestos** para el mismo transistor (`M` vs `X`) y
  para el mismo condensador (`C ... cap_mim_2f0fF` vs `X ... cap_mim_2f0_m4m5_noshield`).
  La traduccion vive en `lvs_netgen.py` y no toca el `.spice` de disco.

**Sobre el deck de GF180**

- **`MT.*` se aplica a Metal5** en un stack de cinco metales: el deck hace
  `top_metal = metal5`. Son mas duras que las `M5.*` — 0.36 de ancho, 0.46 de espaciado,
  0.5625 um2 de area.
- **El DRC y el LVS SI ven el dummy.** `get_polygons(34, 0)` es la capa *drawn*; la fisica
  se compone despues con `metal1 = metal1_drawn + metal1_dummy`. El relleno tiene que
  cumplir el DRC entero.
- **`make drc` no corre densidad.** Hay que pedirla aparte. Todos los "limpio" de un deck
  sin `--density` son de FEOL/BEOL/conectividad y nada mas.
- **El deck mide `Mn.2a` en euclidea**, esquina con esquina; el router mide por proyeccion.
  Dejar exactamente 0.280 en ortogonal da menos en una esquina en diagonal.

**Sobre el flujo de OpenROAD**

- **Una obstruccion del LEF se recorta al contorno del macro.** Engordarla no la saca de
  ahi; para proteger algo fuera hacen falta obstrucciones a nivel de top.
- **La obstruccion tiene que llevar media anchura de cable.** El router la respeta midiendo
  por el eje del cable, no por su borde.
- **Una plataforma de puerto necesita hueco para el cable que va a aterrizar en ella**, no
  solo para si misma.
- **El pin del LEF debe declarar el metal que hay, no su caja envolvente.** `lef write` da
  un rectangulo por puerto; si los pads no llegaron a unirse, ese rectangulo declara
  aterrizable un hueco vacio y el router aterriza ahi.
- **Cuando ya no hay patron comun, el lazo dirigido por DRC cierra el resto**: las zonas
  que marca el deck se vuelven obstrucciones y el router repite. Acumulativo, para que
  converja en vez de oscilar. 10 -> 1 -> 0 en dos vueltas.

**Sobre el relleno de densidad**

- **Cuadrados enteros, nunca recortados.** Recortar la rejilla contra la zona libre deja
  cuellos y trozos bajo el area minima: miles de `M*.1` y `M*.3`.
- **Basta con los canales.** Los macros ocupan el 51 % del die y el 49 % libre da de sobra
  para las siete capas — sin metal flotante sobre los amplificadores ni sobre los MIM.
- **La rejilla se genera por erosion de region**: un cuadrado de lado L cabe entero si su
  centro cae en la zona erosionada L/2. Probar poligono a poligono tardaba minutos por capa.

**Sobre el proyecto**

- **Regenerar siempre el spice desde el esquematico.** Nunca leer el que uno mismo genero:
  puede haber cambiado en xschem.
- **Una fuente de 0 V (`Vmeas`) es un cable.** Para el LVS no se tira: se **unen** las dos
  nets, y por ambito, porque los nombres se repiten entre bloques.
- **El LVS del top pide la referencia aplanada y `--top_lvl_pins`.** Sin lo primero no
  empareja nada; sin lo segundo el extraido sale sin un solo pin y la comparacion no
  arranca.

## Subir a GitHub

El repositorio es **`git@github.com:AnBuiUCI/sscs-2026-zotnetic.git`**, compartido con
el resto del equipo: tiene `main`, `add-pads` y `glayout`. La clave SSH de esta maquina
autentica como `Juander28`; el repositorio es de `AnBuiUCI`, asi que el acceso de
escritura depende de que te tengan como colaborador.

**Que se sube y donde.** Todo `a_zonetic2026/` va dentro de `FINAL/` en el repositorio.
No `zotnetic_layout/`, que es un arbol hermano y queda fuera.

**Como, sin tocar el arbol de trabajo.** Nada de `git init` aqui dentro: git no sabe
empujar un repositorio local a un subdirectorio del remoto, y ademas conviene que
`/foss/designs/a_zonetic2026` siga sin `.git` ni nada movido. Se clona en un scratchpad
y se copia dentro:

```bash
cd /tmp/…/scratchpad
git clone git@github.com:AnBuiUCI/sscs-2026-zotnetic.git repo
git -C repo config user.name "Juander28"
git -C repo config user.email "jdsanch4@uci.edu"

/bin/cp -a /foss/designs/a_zonetic2026/. repo/FINAL/   # `/bin/` a proposito: cp esta
                                                        # aliaseado a `cp -i` y se queda
                                                        # preguntando por cada fichero
git -C repo add -A
git -C repo diff --cached --name-only --diff-filter=D   # debe salir VACIO
git -C repo commit -m "…"
git -C repo push origin main
```

**Cuatro cosas que hay que mirar antes de empujar:**

1. **`FINAL/` ya existe** desde el commit `d018403`. Se **actualiza**, no se recrea. Por
   eso `cp -a` y no `rsync --delete`: sobrescribe y anade, pero nunca borra. Comprobar
   siempre que `--diff-filter=D` sale vacio.
2. **Nada fuera de `FINAL/`.** `git diff --cached --name-only | grep -v '^FINAL/'` tiene
   que salir vacio: hay dos ramas mas con trabajo de otras personas.
3. **Los enlaces de `spice_blocks/` son absolutos** a `/foss/designs/...` y fuera de esta
   maquina llegan rotos. Hay que rehacerlos relativos antes del commit. Comprobacion:
   `find FINAL -xtype l` vacio.
4. **Nunca `--force`, nunca reescribir historia.**

**Verificar de verdad** es clonar en un directorio limpio, no mirar la copia de trabajo:

```bash
git clone git@github.com:AnBuiUCI/sscs-2026-zotnetic.git verify
cd verify && find FINAL -xtype l          # vacio
python3 -c "print(open('FINAL/openroad/out/GRADIENT_NAV_filled.gds','rb').read(4).hex())"
# 00060002 = cabecera GDSII valida
```

**El `lvs_config.json` de la raiz del repo es lo que apunta al entregable.** Es el
fichero que lee el chipathon, y llega a el por `info.yaml -> project.lvs_config`. Los dos
venian con los marcadores de la plantilla (`A01_topcell`,
`<relative-path-to-lvs_config.json>`); ahora dicen:

| clave | valor |
|---|---|
| `info.yaml` `project.lvs_config` | `lvs_config.json` |
| `lvs_config.json` `TOP_SOURCE` | `GRADIENT_NAV` |
| `lvs_config.json` `LAYOUT_FILE` | `$UPRJ_ROOT/FINAL/openroad/out/GRADIENT_NAV_filled.gds` |

`TOP_LAYOUT` se queda en `$TOP_SOURCE`: la celda top del GDS con relleno se llama
`GRADIENT_NAV`, igual que la del esquematico, y el fichero esta aplanado a una sola
celda. Si se rehace el die hay que revisar que estas tres claves sigan cuadrando —
apuntar al GDS sin relleno es incumplir las siete reglas de densidad de golpe.

No hace falta LFS: el fichero mas grande son los 25 MB de
`out/GRADIENT_NAV_filled.gds` — el relleno de densidad multiplica por cuatro los 5.7 MB
del GDS de trabajo — y sigue muy por debajo del limite de 100 MB de GitHub. Si algun dia
molesta, se baja instanciando una celda de relleno en vez de aplanar los cuadrados.
El `.gitattributes` de `FINAL/` solo declara `*.gds binary`, para
que la normalizacion de finales de linea no corrompa un GDS si a git le diera por tomarlo
por texto.

## Notes on the generated LEF

- The pins are marked as ports with magic's `port makeall`. Without it magic
  writes a LEF with **no pins at all and no error message**, which is why
  `build_collateral.py` fails loudly if the pin count does not match the netlist.
- `COMP` has `ORIGIN 1.260 0.000` because the substrate taps stick out to the
  left of the origin in the layout. That is legal LEF and OpenROAD handles it;
  KLayout applies it on stream-out too, which is worth checking after a change.
- OpenROAD warns that the macro pins are not on the routing grid (`MPL-0002`).
  That is why signal routing is out of scope here: snapping the stub positions to
  the 0.56 µm grid in the layout generator would have to come first.

## Where the PDK collateral comes from

```
/foss/pdks/gf180mcuD/libs.ref/gf180mcu_fd_sc_mcu9t5v0/
    techlef/gf180mcu_fd_sc_mcu9t5v0__nom.tlef      technology
    lef/gf180mcu_fd_sc_mcu9t5v0.lef                standard cells
    lib/gf180mcu_fd_sc_mcu9t5v0__tt_025C_5v00.lib  typical corner, 5 V
/foss/pdks/gf180mcuD/libs.tech/klayout/tech/gf180mcu.map   LEF/DEF -> GDS layers
```

The site for the floorplan is `GF018hv5v_green_sc9` (the name in the cell LEF,
not the library name). Routing tracks: 0.56 µm pitch on Metal1–Metal4, 0.90 µm on
Metal5. Metal4 is vertical and Metal5 horizontal, which is why the power stripes
are assigned to those layers the way they are.
