#  Estudio de espacio del slot quarter de wafer.space, con OpenROAD a pelo.
#
#  Para que existe: el flujo de librelane de `waferspace/` no cierra en este
#  contenedor -- ver waferspace/ZOTNETIC.md, es cosa de versiones y le pasa
#  igual a la plantilla sin tocar -- y la pregunta que hay encima de la mesa no
#  necesita el flujo entero. Es cuanto sitio queda: el marco del vendedor, los
#  56 pads donde el los pone, GRADIENT_NAV2_V3 en la esquina superior
#  izquierda, y que se ve en lo que sobra.
#
#  El padring se reproduce con el MISMO reparto que usa librelane
#  (pad_cfg.tcl): suma los anchos de la fila, divide el hueco sobrante entre el
#  numero de pads mas uno y redondea al sitio minimo. Copiado a proposito, para
#  que las posiciones de aqui sean las de alli y no una aproximacion. Los
#  numeros salen identicos a los que imprimio el flujo real:
#
#      norte  hueco 1174 um, 349 de relleno, 29.0 entre pads
#      este   hueco 1769 um, 494 de relleno, 27.4 entre pads
#
#      CANAL  -- separacion minima que se le exige al macro por los cuatro
#                costados. Es la variable del estudio: en librelane serian
#                FP_MACRO_*_HALO. Cambiala y vuelve a correr.
#
#  Uso:   openroad -exit scripts/waferspace_floorplan.tcl
#         CANAL=20 openroad -exit scripts/waferspace_floorplan.tcl

set PDK   /foss/designs/a_zonetic2026/waferspace/gf180mcu/gf180mcuD
set SC    gf180mcu_fd_sc_mcu7t5v0
set IO    gf180mcu_fd_io
set CANAL [expr {[info exists ::env(CANAL)] ? $::env(CANAL) : 10.0}]

#  --- el marco del vendedor, de waferspace/librelane/slots/slot_0p5x0p5.yaml
set DIE   {0 0 1936 2531}
set CORE  {442 442 1494 2089}
set SELLO 26.0
set PADH  350.0
set CORNER 355.0

#  --- el bloque
set MACRO   GRADIENT_NAV2_V3
set M_X     442.0
set M_Y     1702.01
set M_OR    MX          ;# FS en nombres LEF

read_lef $PDK/libs.ref/$SC/techlef/${SC}__nom.tlef
read_lef $PDK/libs.ref/$SC/lef/$SC.lef
foreach f [glob $PDK/libs.ref/$IO/lef/*.lef] { read_lef $f }
read_lef lef/$MACRO.lef

set db  [ord::get_db]
set dbu 2000

proc maestro {nombre} {
    foreach lib [[ord::get_db] getLibs] {
        set m [$lib findMaster $nombre]
        if {$m != "NULL"} { return $m }
    }
    error "no encuentro el master $nombre"
}
proc um {v} { expr {$v / 2000.0} }

#  --- floorplan ---------------------------------------------------------------
set chip [odb::dbChip_create $db [$db getTech]]
set blk  [odb::dbBlock_create $chip "waferspace_quarter"]
$blk setDefUnits $dbu
lassign $DIE dx0 dy0 dx1 dy1
set rx0 [expr {int($dx0*$dbu)}] ; set ry0 [expr {int($dy0*$dbu)}]
set rx1 [expr {int($dx1*$dbu)}] ; set ry1 [expr {int($dy1*$dbu)}]
set caja [odb::Rect]
$caja init $rx0 $ry0 $rx1 $ry1
$blk setDieArea $caja

lassign $CORE cx0 cy0 cx1 cy1

#  --- el padring, con el reparto de pad_cfg.tcl -------------------------------
#  Cada fila es {nombre_de_lado {maestro ...}}. Los nombres de senal van al lado
#  para poder decir despues a que distancia queda cada pin de su pad.
set FILA(sur)   {in_s in_c dvss dvdd bi_24t bi_24t bi_24t bi_24t bi_24t bi_24t bi_24t}
set FILA(este)  {bi_24t bi_24t bi_24t bi_24t bi_24t bi_24t bi_24t bi_24t dvss dvdd
                 bi_24t bi_24t bi_24t bi_24t bi_24t bi_24t bi_24t}
set FILA(norte) {asig_5p0 asig_5p0 dvss dvdd asig_5p0 asig_5p0 asig_5p0 asig_5p0
                 asig_5p0 asig_5p0 bi_24t}
set FILA(oeste) {bi_24t bi_24t bi_24t bi_24t bi_24t bi_24t bi_24t bi_24t bi_24t
                 bi_24t bi_24t in_c in_c dvss dvdd in_c in_c}
set SENAL(norte) {S1P S1N . . S2N S2P S3P S3N S4N S4P .}
set SENAL(este)  {. . . . . . . . . . . . . . ZP YP XP}

set SITIO 0.1
puts "\n=== padring, reparto de pad_cfg.tcl ==="
foreach lado {sur este norte oeste} {
    set n [llength $FILA($lado)]
    set ancho 0.0
    foreach m $FILA($lado) { set ancho [expr {$ancho + [um [[maestro ${IO}__$m] getWidth]]}] }
    set largo [expr {($lado eq "sur" || $lado eq "norte")
                     ? $dx1 - 2*$SELLO - 2*$CORNER : $dy1 - 2*$SELLO - 2*$CORNER}]
    set relleno [expr {$largo - $ancho}]
    set entre   [expr {floor(($relleno/($n+1)) / $SITIO) * $SITIO}]
    set orilla  [expr {($relleno - $entre*($n-1)) / 2.0}]
    set cur     [expr {$orilla + $SELLO + $CORNER}]
    puts [format "  %-6s %2d pads  hueco %7.1f  relleno %6.1f  entre %5.1f  orilla %5.1f" \
              $lado $n $largo $relleno $entre $orilla]
    set POS($lado) {}
    foreach m $FILA($lado) {
        set w [um [[maestro ${IO}__$m] getWidth]]
        lappend POS($lado) [list $m $cur [expr {$cur + $w}]]
        set cur [expr {$cur + $entre + $w}]
    }
}

#  --- el macro ----------------------------------------------------------------
set mst [maestro $MACRO]
set inst [odb::dbInst_create $blk $mst "u_nav"]
$inst setOrient $M_OR
$inst setLocation [expr {int($M_X*$dbu)}] [expr {int($M_Y*$dbu)}]
$inst setPlacementStatus FIRM
set bb [$inst getBBox]
set mx0 [um [$bb xMin]] ; set my0 [um [$bb yMin]]
set mx1 [um [$bb xMax]] ; set my1 [um [$bb yMax]]

puts "\n=== el marco ==="
puts [format "  die            %8.1f x %8.1f um" $dx1 $dy1]
puts [format "  core           %8.1f x %8.1f um   = %.3f mm2" \
          [expr {$cx1-$cx0}] [expr {$cy1-$cy0}] [expr {($cx1-$cx0)*($cy1-$cy0)/1e6}]]
puts [format "  padring        %8.1f um de alto, sello %.0f" $PADH $SELLO]
puts "\n=== el bloque ==="
puts [format "  %s  x %.2f .. %.2f   y %.2f .. %.2f  (%s)" \
          $MACRO $mx0 $mx1 $my0 $my1 $M_OR]
puts [format "  ocupa %.3f mm2, el %.1f %% del core" \
          [expr {($mx1-$mx0)*($my1-$my0)/1e6}] \
          [expr {100.0*($mx1-$mx0)*($my1-$my0)/(($cx1-$cx0)*($cy1-$cy0))}]]

#  --- que queda libre ---------------------------------------------------------
#  El macro esta en una esquina, asi que lo que sobra es una L. Se parte en dos
#  rectangulos por el lado largo, que es como se mira si cabe otra cosa: un
#  rectangulo real es sitio para un bloque, la suma de areas no lo es.
set ax0 [expr {$mx1 + $CANAL}] ; set ax1 $cx1     ;# a la derecha del macro
set ay0 $cy0                   ; set ay1 $cy1
set bx0 $cx0                   ; set bx1 [expr {$mx1 + $CANAL}]
set by0 $cy0                   ; set by1 [expr {$my0 - $CANAL}]  ;# debajo

puts "\n=== lo que queda, con canal de $CANAL um ==="
puts [format "  franja derecha  %8.2f x %8.2f um   = %.3f mm2" \
          [expr {$ax1-$ax0}] [expr {$ay1-$ay0}] [expr {($ax1-$ax0)*($ay1-$ay0)/1e6}]]
puts [format "  franja inferior %8.2f x %8.2f um   = %.3f mm2" \
          [expr {$bx1-$bx0}] [expr {$by1-$by0}] [expr {($bx1-$bx0)*($by1-$by0)/1e6}]]
puts [format "  libre en total  %.3f mm2, el %.1f %% del core" \
          [expr {(($ax1-$ax0)*($ay1-$ay0) + ($bx1-$bx0)*($by1-$by0))/1e6}] \
          [expr {100.0*(($ax1-$ax0)*($ay1-$ay0) + ($bx1-$bx0)*($by1-$by0))
                 / (($cx1-$cx0)*($cy1-$cy0))}]]

#  --- cuantos bloques mas caben ------------------------------------------------
#  Empaquetado por estanterias sobre el CORE entero, con el canal por los cuatro
#  costados. No es el optimo teorico; es lo que un floorplan honesto consigue.
set W [expr {$mx1-$mx0}] ; set H [expr {$my1-$my0}]
puts "\n=== cuantos GRADIENT_NAV2_V3 caben en el core ==="
foreach c [list 0.0 $CANAL 20.0 40.0] {
    set nx [expr {int(($cx1-$cx0+$c) / ($W+$c))}]
    set ny [expr {int(($cy1-$cy0+$c) / ($H+$c))}]
    puts [format "  canal %5.1f um -> %d x %d = %2d bloques   (%.1f %% del core)" \
              $c $nx $ny [expr {$nx*$ny}] \
              [expr {100.0*$nx*$ny*$W*$H/(($cx1-$cx0)*($cy1-$cy0))}]]
}

#  --- distancias que importan ---------------------------------------------------
puts "\n=== holguras del macro ==="
puts [format "  al borde izquierdo del core   %6.2f um" [expr {$mx0-$cx0}]]
puts [format "  al techo del core             %6.2f um" [expr {$cy1-$my1}]]
puts [format "  al padring del norte          %6.2f um" \
          [expr {($dy1-$SELLO-$PADH) - $my1}]]
puts [format "  al padring del oeste          %6.2f um" \
          [expr {$mx0 - ($SELLO+$PADH)}]]

#  --- pad a pin -----------------------------------------------------------------
puts "\n=== de cada pin del bloque a su pad ==="
foreach lado {norte este} {
    set i 0
    foreach p $POS($lado) s $SENAL($lado) {
        if {$s eq "." || $s eq ""} { incr i ; continue }
        lassign $p m a b
        set centro [expr {($a+$b)/2.0}]
        set it [$inst findITerm $s]
        set pb [$it getBBox]
        if {$lado eq "norte"} {
            set d [expr {abs($centro - [um [$pb xMin]])}]
        } else {
            set d [expr {abs($centro - [um [$pb yMin]])}]
        }
        puts [format "  %-4s  pad %-9s centro %8.1f   pin %8.2f   -> %7.1f um" \
                  $s $m $centro [expr {$lado eq "norte" ? [um [$pb xMin]] : [um [$pb yMin]]}] $d]
        incr i
    }
}

write_def out_waferspace/quarter.def

#  Y un resumen para la figura, para que el dibujo no vuelva a calcular nada por
#  su cuenta: si el dibujo y el estudio pueden discrepar, un dia discrepan.
set j [open out_waferspace/quarter.json w]
puts $j "{"
puts $j "  \"die\": \[$dx0, $dy0, $dx1, $dy1\],"
puts $j "  \"core\": \[$cx0, $cy0, $cx1, $cy1\],"
puts $j "  \"sello\": $SELLO, \"padh\": $PADH, \"corner\": $CORNER,"
puts $j "  \"canal\": $CANAL,"
puts $j "  \"macro\": {\"nombre\": \"$MACRO\", \"caja\": \[$mx0, $my0, $mx1, $my1\], \"orient\": \"$M_OR\"},"
puts $j "  \"libre\": \[\[$ax0, $ay0, $ax1, $ay1\], \[$bx0, $by0, $bx1, $by1\]\],"
puts $j "  \"pads\": {"
set lados {}
foreach lado {sur este norte oeste} {
    set e {}
    set k 0
    foreach p $POS($lado) {
        lassign $p m a b
        set s "."
        if {[info exists SENAL($lado)]} { set s [lindex $SENAL($lado) $k] }
        if {$s eq ""} { set s "." }
        lappend e "\[\"$m\", $a, $b, \"$s\"\]"
        incr k
    }
    lappend lados "    \"$lado\": \[[join $e {, }]\]"
}
puts $j [join $lados ",\n"]
puts $j "  },"
puts $j "  \"pines\": {"
set e {}
foreach s {S1P S1N S2N S2P S3P S3N S4N S4P XP YP ZP VDD VSS} {
    set it [$inst findITerm $s]
    set pb [$it getBBox]
    lappend e "    \"$s\": \[[um [$pb xMin]], [um [$pb yMin]], [um [$pb xMax]], [um [$pb yMax]]\]"
}
puts $j [join $e ",\n"]
puts $j "  }"
puts $j "}"
close $j
puts "\n  DEF  -> out_waferspace/quarter.def"
puts "  JSON -> out_waferspace/quarter.json"
