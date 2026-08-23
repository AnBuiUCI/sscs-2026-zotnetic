# -----------------------------------------------------------------------------
#  Floorplan of GRADIENT_NAV: place every macro and build the power grid.
#
#      openroad -no_init -exit scripts/floorplan_top.tcl
#
#  The design is nothing but hard macros (see verilog/top_macros.v), so there is
#  no placement to do beyond deciding where the blocks go, and no routing here at
#  all — only power. Signal routing is deliberately out of scope: the macro pins
#  are not on the 0.56 um routing grid.
#
#  Nothing below is a hard-coded coordinate. Sizes are read from the LEF through
#  the database, so the floorplan re-arranges itself when a block changes size.
# -----------------------------------------------------------------------------

#  Directorio de salida. Por defecto `out`, que es el del top de la v1.
#  `TOP_OUT` lo cambia para poder construir el top con las celdas de otra
#  version sin pisar el anterior: los dos tienen que poder coexistir para
#  compararlos.
set OUT [expr {[info exists env(TOP_OUT)] ? $env(TOP_OUT) : "out"}]
file mkdir $OUT

#  Nombre de la celda de arriba. Ver scripts/load_design.tcl.
set TOPCELL [expr {[info exists env(TOP_CELL)] ? $env(TOP_CELL) : "GRADIENT_NAV"}]

source scripts/load_design.tcl

set block [ord::get_db_block]
set dbu   [[ord::get_db_tech] getDbUnitsPerMicron]

# --- geometry knobs ----------------------------------------------------------
#  Sized to land the whole chip inside 500 x 500 um. The channels have to stay
#  wide enough for a stripe pair plus clearance; 12 um fits 3 + 3 + 3 with room.
set HGAP     16.0   ;# hueco entre macros de un estante: por ahi va todo el
                    ;# trafico vertical de Metal2, porque dentro de un macro esa
                    ;# capa esta ocupada por el ruteo del propio bloque.
set VGAP     12.0   ;# canal entre estantes; tiene que caber un par de tiras (9)
set MARGIN    9.0   ;# core a die
set STRIPE_W  3.0
set BUDGET  500.0   ;# lado maximo del die
set ASPECT    1.2   ;# proporcion maxima; dentro de eso se minimiza el AREA
set SNAP_PAD  3.0   ;# holgura para el ajuste del core a la rejilla del site
set PIN_GAP   5.0   ;# separacion minima entre pines del top, en micras
set PIN_CORNER 10.0 ;# y cuanto se apartan de las esquinas del die

#: Everything handed to pdngen has to land on the 0.005 um manufacturing grid;
#: a band centred between two obstructions lands on 66.3875 as easily as not,
#: and `PDN-0191` aborts rather than rounding.
proc mfg {v} { return [expr {round($v / 0.005) * 0.005}] }

#: Los macros se colocan sobre la rejilla de ruteo (paso 0.56), no solo sobre la
#: de fabricacion. Sus plataformas de metal3 ya van sobre pista dentro del bloque
#: (ver coil_layout/power.py); si el bloque no cae en un multiplo del paso, esa
#: alineacion se pierde al colocarlo y el router vuelve a aterrizar de refilon.
proc ontrack {v} { return [expr {round($v / 0.56) * 0.56}] }

#: `MIMTM.1` pide 1.2 um de la placa de un MIM a cualquier otro metal4. Evitar el
#: solape no basta: las tiras de alimentacion pasaban rozando y salieron 41
#: violaciones. El LEF ya trae el espaciado de la capa; esto anade el resto.
set MIM_CLEAR 1.2

proc blocked_x {master dbu dx} {
    #: Rangos de x con Metal4 obstruido, desplazados a donde esta el macro.
    global MIM_CLEAR
    set out {}
    foreach box [$master getObstructions] {
        if {[[$box getTechLayer] getName] ne "Metal4"} { continue }
        lappend out [list [expr {$dx + [$box xMin] / double($dbu) - $MIM_CLEAR}] \
                          [expr {$dx + [$box xMax] / double($dbu) + $MIM_CLEAR}]]
    }
    return $out
}

proc free_bands {blocked lo hi} {
    #: the complement of `blocked` inside [lo, hi], merged.
    set free [list [list $lo $hi]]
    foreach u [lsort -real -index 0 $blocked] {
        lassign $u ua ub
        set next {}
        foreach f $free {
            lassign $f fa fb
            if {$ub <= $fa || $ua >= $fb} { lappend next $f ; continue }
            if {$ua > $fa} { lappend next [list $fa $ua] }
            if {$ub < $fb} { lappend next [list $ub $fb] }
        }
        set free $next
    }
    return $free
}

proc dim {block dbu name what} {
    set m [[$block findInst $name] getMaster]
    return [expr {[$m get$what] / double($dbu)}]
}

# --- gather the macros -------------------------------------------------------
#  Instances are grouped by the first field of their hierarchical name, which the
#  Verilog generator builds from the instance path: `x1_x4` is instance x4 inside
#  GRADIENT x1. So every group is one GRADIENT.
#  --- empaquetado por estantes ------------------------------------------------
#  La rejilla de columnas se ha ido. Obligaba a que toda columna fuese tan ancha
#  como su macro mas ancho, y como cada columna mezclaba OPAM (87.44) con COMP
#  (104.28), cada fila de OPAM tiraba 16.84 um de ancho, doce veces.
#
#  En su lugar, First-Fit-Decreasing-Height: los macros se ordenan de mas alto a
#  mas bajo y se van metiendo en estantes; el alto de cada estante lo fija el
#  primero que entra, que por el orden es siempre el mas alto. Lo que sobra al
#  final de un estante lo aprovecha un macro mas bajo — asi es como los
#  WEIGHT_COMP acaban en el hueco que dejan tres COMP.
#
#  Se barren anchos objetivo y se elige el de MENOR AREA entre los que dejan la
#  proporcion por debajo de ASPECT y los dos lados por debajo de BUDGET. No se
#  rellena nada para igualar los lados: no hace falta el cuadrado exacto, y ese
#  relleno seria area tirada.
set items {}
foreach inst [$block getInsts] {
    if {![[$inst getMaster] isBlock]} { continue }
    set m [$inst getMaster]
    lappend items [list [$inst getName] \
                        [expr {[$m getWidth] / double($dbu)}] \
                        [expr {[$m getHeight] / double($dbu)}] \
                        [$m getName]]
}
#  Orden: por alto descendente, y dentro de cada altura por nombre de instancia,
#  que agrupa `x1_*` con `x1_*`. Los macros de un mismo GRADIENT tienden asi a
#  caer en la misma x de estantes distintos, que acorta las nets que los unen.
set items [lsort -index 0 $items]
set items [lsort -real -decreasing -index 2 $items]

proc pack {items W hgap} {
    #: FFDH. Devuelve {shelves used_width total_height}, con shelves como lista de
    #: {alto  {{nombre x w} ...}}.
    set shelves {}
    foreach it $items {
        lassign $it name w h
        set done 0
        for {set i 0} {$i < [llength $shelves]} {incr i} {
            lassign [lindex $shelves $i] sh smembers sused
            set nx [expr {$sused == 0 ? 0.0 : $sused + $hgap}]
            if {$nx + $w <= $W} {
                lappend smembers [list $name $nx $w]
                lset shelves $i [list $sh $smembers [expr {$nx + $w}]]
                set done 1
                break
            }
        }
        if {!$done} {
            if {$w > $W} { return {} }          ;# no cabe ni solo: ancho invalido
            lappend shelves [list $h [list [list $name 0.0 $w]] $w]
        }
    }
    set used 0.0
    set tot  0.0
    foreach s $shelves {
        set used [expr {max($used, [lindex $s 2])}]
        set tot  [expr {$tot + [lindex $s 0]}]
    }
    return [list $shelves $used $tot]
}

set best {}
set widest 0.0
foreach it $items { set widest [expr {max($widest, [lindex $it 1])}] }
for {set W [expr {ceil($widest)}] } {$W <= $BUDGET - 2 * $MARGIN} {set W [expr {$W + 2.0}]} {
    set r [pack $items $W $HGAP]
    if {![llength $r]} { continue }
    lassign $r shelves used tot
    set n [llength $shelves]
    set w [expr {$used + 2 * $MARGIN}]
    set h [expr {$tot + ($n + 1) * $VGAP + 2 * $MARGIN}]
    if {$w > $BUDGET || $h > $BUDGET} { continue }
    set ratio [expr {max($w, $h) / min($w, $h)}]
    if {$ratio > $ASPECT} { continue }
    if {![llength $best] || $w * $h < [lindex $best 0]} {
        set best [list [expr {$w * $h}] $shelves $w $h $n]
    }
}
if {![llength $best]} {
    error "ningun ancho da un die dentro de $BUDGET um con proporcion <= $ASPECT"
}
lassign $best best_area shelves die_w die_h nshelf

#  Un pelin de holgura: `initialize_floorplan` ajusta el core a la rejilla del
#  site y lo encoge hasta un site por lado. Sin esto el primer macro caia fuera
#  por 0.52 um (`MPL-0034`).
set die_w [expr {$die_w + $SNAP_PAD}]
set die_h [expr {$die_h + $SNAP_PAD}]
set core_w [expr {$die_w - 2 * $MARGIN}]
set core_h [expr {$die_h - 2 * $MARGIN}]

initialize_floorplan \
    -die_area  "0 0 $die_w $die_h" \
    -core_area "$MARGIN $MARGIN [expr {$MARGIN + $core_w}] [expr {$MARGIN + $core_h}]" \
    -site      GF018hv5v_green_sc9

foreach layer {Metal1 Metal2 Metal3 Metal4} {
    make_tracks $layer -x_offset 0.28 -x_pitch 0.56 -y_offset 0.28 -y_pitch 0.56
}
make_tracks Metal5 -x_offset 0.45 -x_pitch 0.90 -y_offset 0.45 -y_pitch 0.90

# --- place -------------------------------------------------------------------
set core0   [$block getCoreArea]
set org_x   [expr {[$core0 xMin] / double($dbu)}]
set org_y   [expr {[$core0 yMin] / double($dbu)}]

set masters [dict create]
set inst_of [dict create]
set hlanes  {}
set y $VGAP
lappend hlanes [expr {$VGAP / 2.0}]
foreach s $shelves {
    lassign $s sh smembers
    foreach mem $smembers {
        lassign $mem name x w
        place_macro -macro_name $name -orientation R0 \
            -location [list [ontrack [expr {$org_x + $x}]] \
                            [ontrack [expr {$org_y + $y}]]]
        set mn [[[$block findInst $name] getMaster] getName]
        dict set masters $mn 1
        dict set inst_of $mn $name
    }
    set y [expr {$y + $sh + $VGAP}]
    lappend hlanes [expr {$y - $VGAP / 2.0}]
}

# --- power -------------------------------------------------------------------
#  Every block brings VDD and VSS up to a full-width Metal3 bar over its own
#  Metal1 rail (see coil_layout/power.py). That bar is the landing pad: a
#  vertical Metal4 stripe crossing the block hits it, and pdngen can drop a via.
add_global_connection -net VDD -inst_pattern {.*} -pin_pattern {VDD} -power
add_global_connection -net VSS -inst_pattern {.*} -pin_pattern {VSS} -ground
global_connect

set_voltage_domain -power VDD -ground VSS

#  The core is read back from the database rather than reused from what was asked
#  for: `initialize_floorplan` snaps it to the site grid, and a strap computed
#  against the requested size overflowed the real one by a couple of microns —
#  `PDN-0185 Insufficient width` aborts the run rather than clipping.
set core    [$block getCoreArea]
set core_x0 [expr {[$core xMin] / double($dbu)}]
set core_y0 [expr {[$core yMin] / double($dbu)}]
set real_w  [expr {([$core xMax] - [$core xMin]) / double($dbu)}]
set real_h  [expr {([$core yMax] - [$core yMin]) / double($dbu)}]

define_pdn_grid -name core -voltage_domains CORE

#  Metal4 (vertical) has to run OVER the blocks, not down the channels: that is
#  the only way it crosses their Metal3 bars. Where it may go is read from the
#  LEF obstructions rather than assumed — the MIM plates block Metal4 across the
#  middle of COMP and OPAM, and the free bands are not the same in the two.

set PAIR  [expr {$STRIPE_W}]
set need  [expr {2 * $STRIPE_W + $PAIR}]

#  Metal5 (horizontal) se queda en los canales entre estantes: solo tiene que
#  encontrarse con Metal4, y por encima de un macro caeria sobre los platos MIM.
#  `hlanes` viene de la colocacion, un carril por canal.
set extent [expr {2 * $STRIPE_W + $PAIR}]
foreach c $hlanes {
    set off [mfg [expr {$c - $extent / 2.0}]]
    if {$off < 0 || $off + $extent > $real_h} { continue }
    add_pdn_stripe -grid core -layer Metal5 -width $STRIPE_W -spacing $STRIPE_W \
                   -pitch [expr {2 * $real_h}] -offset $off
}
add_pdn_connect -grid core -layers {Metal4 Metal5}

#  Las tiras de Metal4 van en la rejilla del CORE y se calculan **por instancia**,
#  no por columna: para cada macro se miran las bandas donde SU LEF deja el Metal4
#  libre, se llevan a coordenadas del core con su posicion ya colocada y se pide
#  una tira ahi. Que esa tira quede bloqueada al pasar por otro macro da igual —
#  pdngen la recorta en trozos y sigue sirviendo a los macros donde si esta libre.
#
#  La alternativa aparente, una rejilla `-macro` con tiras propias por instancia,
#  NO funciona: sale vacia (`PDN-0232`) porque sus straps no tienen ninguna
#  rejilla de core a la que subir, y pdngen las descarta y aborta la corrida.
set base [expr {$MARGIN - $core_x0}]
set nstripe 0
set seen {}
foreach inst [$block getInsts] {
    if {![[$inst getMaster] isBlock]} { continue }
    set m  [$inst getMaster]
    set ix [expr {[[$inst getBBox] xMin] / double($dbu)}]
    set iw [expr {[$m getWidth] / double($dbu)}]
    foreach band [free_bands [blocked_x $m $dbu $ix] $ix [expr {$ix + $iw}]] {
        lassign $band lo hi
        if {$hi - $lo < $need} { continue }
        set off [mfg [expr {$lo - $core_x0 + ($hi - $lo - $need) / 2.0}]]
        if {$off < 0 || $off + $need > $real_w} { continue }
        if {[lsearch -exact $seen $off] >= 0} { continue }
        lappend seen $off
        add_pdn_stripe -grid core -layer Metal4 -width $STRIPE_W -spacing $PAIR \
                       -pitch [expr {2 * $real_w}] -offset $off
        incr nstripe
    }
}

#  Y la rejilla de macro, que es lo que ata cada bloque: Metal3 (la barra que el
#  bloque expone sobre su riel) contra Metal4 (las tiras de arriba).
define_pdn_grid -macro -name macro -cells [lsort [dict keys $masters]] -halo {0 0}
add_pdn_connect -grid macro -layers {Metal3 Metal4}

pdngen

# --- halo de los MIM ---------------------------------------------------------
#  `MIMTM.1` pide 1.2 um de la placa de un MIM a cualquier otro metal4, y esa
#  distancia se mide **fuera** del macro tambien. Engordar la obstruccion del LEF
#  no sirve: OpenROAD la recorta al contorno del macro, asi que el router tendia
#  Metal4 a 0.51 um de una placa por el canal de al lado. Lo que si respeta es un
#  bloqueo declarado en el top, y eso es lo que se pone aqui: la geometria de
#  Metal4 de cada instancia, engordada, en coordenadas del die.
set nblock 0
foreach inst [$block getInsts] {
    if {![[$inst getMaster] isBlock]} { continue }
    set bb [$inst getBBox]
    set ox [$bb xMin] ; set oy [$bb yMin]
    set halo [expr {round($MIM_CLEAR * $dbu)}]
    foreach box [[$inst getMaster] getObstructions] {
        if {[[$box getTechLayer] getName] ne "Metal4"} { continue }
        odb::dbObstruction_create $block [$box getTechLayer] \
            [expr {$ox + [$box xMin] - $halo}] [expr {$oy + [$box yMin] - $halo}] \
            [expr {$ox + [$box xMax] + $halo}] [expr {$oy + [$box yMax] + $halo}]
        incr nblock
    }
}
puts "Bloqueos de Metal4 alrededor de los MIM: $nblock"

# --- pines del top -----------------------------------------------------------
#  Los 19 puertos no tienen pin fisico: hoy son solo nombres en el Verilog. Sin
#  esto las nets que van a ellos no tienen donde terminar y el router no puede
#  cerrarlas. Metal3 es horizontal y Metal2 vertical, asi que los de los lados
#  izquierdo y derecho salen en Metal3 y los de arriba y abajo en Metal2.
#  `-min_distance` en micras. Sin el, `place_pins` los apretaba al paso de la
#  rejilla y salian a **1.12 um** uno de otro (S1N/S1P abajo, y los seis de la
#  izquierda). No es ilegal, pero deja al integrador del padframe abriendo el
#  abanico desde un paso de pista; 5 um es holgado y siguen cabiendo de sobra.
place_pins -hor_layers Metal3 -ver_layers Metal2 -min_distance $PIN_GAP \
           -corner_avoidance $PIN_CORNER

#  ...pero los DOS de alimentacion hay que ponerlos a mano, encima de su propia
#  tira de Metal5. `place_pins` los trata como una senal mas y los deja en el
#  borde del die, en un pad de Metal2/Metal3 que no toca la malla: quedan
#  FLOTANDO. No lo ve el DRC (un abierto no viola ninguna regla) ni
#  `check_connectivity.py` (que solo mira terminales de macro, no los pines del
#  top), y el router tampoco los cierra, porque salta las nets POWER/GROUND.
#
#  Donde si aparece es en el LVS, y era lo ultimo que le quedaba al top: netgen
#  daba `Netlists match with 144 symmetries` con 880 nets y 1389 dispositivos
#  iguales a cada lado, y fallaba solo en el emparejamiento de pines — la red de
#  alimentacion de verdad salia sin nombre (`w_1904_7964#` el pozo,
#  `a_2082_4860#` el sustrato) y los puertos `VDD` y `VSS` salian sueltos.
#
#  Se pone el pin sobre la tira, no la tira sobre el pin: la malla ya esta hecha
#  y tocarla es rehacer el reparto entero.
proc tira_de {block nombre capa} {
    set net [$block findNet $nombre]
    if {$net eq "NULL" || $net eq ""} { return {} }
    foreach sw [$net getSWires] {
        foreach caja [$sw getWires] {
            if {[$caja isVia]} { continue }
            set l [$caja getTechLayer]
            if {$l eq "NULL" || [$l getName] ne $capa} { continue }
            return [list [$caja xMin] [$caja yMin] [$caja xMax] [$caja yMax]]
        }
    }
    return {}
}

set dbu_pin [[ord::get_db_tech] getDbUnitsPerMicron]

#: Prolonga la tira hasta el borde IZQUIERDO del die y devuelve la caja nueva.
#:
#: Sin esto la tira de Metal5 se queda a ~20 um del borde y el pin cae **dentro**
#: del die: un padframe que conecte por abutment no llega. Un puerto es
#: precisamente lo que si tiene que tocar el contorno -- el resto de la
#: geometria se retira de el (ver `decap_fill.BORDE_DIE` y
#: `fill_density.BORDE_DIE`).
proc alargar_al_borde {block nombre capa} {
    set net [$block findNet $nombre]
    if {$net eq "NULL" || $net eq ""} { return {} }
    foreach sw [$net getSWires] {
        foreach caja [$sw getWires] {
            if {[$caja isVia]} { continue }
            set l [$caja getTechLayer]
            if {$l eq "NULL" || [$l getName] ne $capa} { continue }
            odb::dbSBox_create $sw $l 0 [$caja yMin] [$caja xMax] [$caja yMax] "STRIPE"
            return [list 0 [$caja yMin] [$caja xMax] [$caja yMax]]
        }
    }
    return {}
}

foreach nombre {VDD VSS} {
    set caja [alargar_al_borde $block $nombre Metal5]
    if {[llength $caja] != 4} {
        puts "  AVISO: $nombre no tiene tira de Metal5; el pin se queda donde estaba"
        continue
    }
    lassign $caja x0 y0 x1 y1
    set alto  [expr {($y1 - $y0) / double($dbu_pin)}]
    set ancho $alto
    #  Pegado al borde izquierdo del die, encima de la tira ya prolongada.
    set cx [expr {$ancho / 2.0}]
    set cy [expr {(($y0 + $y1) / 2.0) / $dbu_pin}]
    place_pin -pin_name $nombre -layer Metal5 \
              -location [list $cx $cy] -pin_size [list $ancho $alto]
    #  Y que se declaren como lo que son. `place_pins` los deja en `USE SIGNAL`,
    #  y el integrador del padframe distingue las alimentaciones por ahi.
    set bt [$block findBTerm $nombre]
    if {$bt ne "NULL" && $bt ne ""} {
        $bt setSigType [expr {$nombre eq "VDD" ? "POWER" : "GROUND"}]
    }
    puts [format "  pin %s en el borde del die, sobre su tira de Metal5: (%.3f, %.3f), %.3f x %.3f" \
              $nombre $cx $cy $ancho $alto]
}

# --- output ------------------------------------------------------------------
file mkdir out
write_def $OUT/$TOPCELL.def

puts "--------------------------------------------------------------"
puts [format "Die       %.2f x %.2f um   (budget %.0f)" $die_w $die_h $BUDGET]
puts [format "Area      %.0f um2   proporcion %.3f" \
          [expr {$die_w * $die_h}] [expr {max($die_w,$die_h)/min($die_w,$die_h)}]]
puts [format "Estantes  %d" $nshelf]
foreach s $shelves {
    puts [format "   alto %5.2f um : %s" [lindex $s 0] \
              [join [lmap m [lindex $s 1] {lindex $m 0}] " "]]
}
report_design_area
puts "DEF written to $OUT/$TOPCELL.def"
puts "--------------------------------------------------------------"
