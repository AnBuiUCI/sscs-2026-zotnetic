# -----------------------------------------------------------------------------
#  Ruteo de senal del top.
#
#      openroad -no_init -exit scripts/route_top.tcl
#
#  Va DESPUES del floorplan: lee el DEF que este dejo (con los macros colocados,
#  las mallas de alimentacion y los pines del top ya puestos) y rutea las nets de
#  senal. Se separa del floorplan a proposito, porque el ruteo detallado tarda
#  bastante y no hace falta repetirlo cada vez que se mueve un macro.
# -----------------------------------------------------------------------------

#  Se rehace el floorplan en vez de leer su DEF. `read_def -incremental` sobre un
#  bloque recien ligado no trae la estructura de pistas y el router muere con
#  `ODB-0139 Missing track structure for layer Metal1`; rehacerlo cuesta segundos
#  y deja la base de datos completa.
source scripts/floorplan_top.tcl

set block [ord::get_db_block]

#  Reparto de capas: la senal va por Metal2 (vertical), Metal3 (horizontal) y
#  Metal4 (vertical); Metal5 se queda entero para la alimentacion.
#
#  Metal1 queda fuera: ahi viven los rieles y el ruteo interno de los bloques.
#
#  Metal4 hace falta aunque sea la capa de los MIM. Con solo Metal2 y Metal3 el
#  router acababa con 667 de desbordamiento en Metal3 y **46 de demanda en
#  Metal2 sobre 23190 de recurso**: encima de un macro no puede bajar a Metal2
#  —esa capa la ocupa el ruteo del propio bloque, asi que la via2 esta
#  bloqueada—, de modo que todo el trafico vertical tenia que salir al canal.
#  Metal4 le da corredores verticales por encima de los bloques; el margen de
#  `MIMTM.1` ya viene en las obstrucciones del LEF.
set_routing_layers -signal Metal2-Metal4

#  Regla no estandar: cables de 0.38 en las tres capas de senal, no los 0.28
#  minimos. Es lo que iguala el ancho del cable al del recuadro de la via, que
#  mide 0.38 x 0.28. Con 0.28 quedaba un escalon de 0.05 en el encuentro —de ahi
#  las `M3.1` y los roces de 0.04..0.08 de `M2.2a`— y un pad suelto de 0.38 x 0.28
#  se queda en 0.1064 um2 cuando `Mn.3` pide 0.1444, que son las `M3.3`.
#  Un cable de 0.38 cubre las dos cosas: ni escalon ni area corta.
create_ndr -name ANCHO -width {Metal2 0.38 Metal3 0.38 Metal4 0.38} \
                       -spacing {Metal2 0.28 Metal3 0.28 Metal4 0.28}
foreach net [$block getNets] {
    if {[$net getSigType] in {POWER GROUND}} { continue }
    assign_ndr -ndr ANCHO -net [$net getName]
}

set n 0
foreach net [$block getNets] {
    if {[$net getSigType] in {POWER GROUND}} { continue }
    incr n
}
puts "--------------------------------------------------------------"
puts "Nets de senal a rutear: $n"
puts "--------------------------------------------------------------"

file mkdir out
#  `-allow_congestion`: el ruteo global se queda con un puñado de GCells
#  desbordadas sobre un 2.3% de ocupacion total — un atasco local en el acceso a
#  algun pin, no falta de recurso; ni ensanchar canales ni multiplicar las
#  plataformas de los puertos lo bajaron de ahi. El desbordamiento del global es
#  una estimacion sobre una rejilla gruesa: quien decide es el ruteo DETALLADO,
#  y su informe de DRC (`out/route_drc.rpt`) mas el DRC de firma de KLayout son
#  los que hay que mirar. Si el detallado no cerrara, se veria ahi.
#  Sitios que el DRC de firma marco en una vuelta anterior y que el router tiene
#  prohibido volver a usar (ver `scripts/drc_blockages.py`). El fichero puede no
#  existir: la primera vuelta va sin nada.
set bloqueos out/drc_blockages.txt
if {[file exists $bloqueos]} {
  set blk  [ord::get_db_block]
  set tech [ord::get_db_tech]
  set dbu  [$tech getDbUnitsPerMicron]
  set nb 0
  set fh [open $bloqueos r]
  while {[gets $fh linea] >= 0} {
    if {[string trim $linea] eq ""} { continue }
    lassign $linea capa x0 y0 x1 y1
    set l [$tech findLayer $capa]
    if {$l eq "NULL" || $l eq ""} { continue }
    odb::dbObstruction_create $blk $l \
        [expr {int($x0*$dbu)}] [expr {int($y0*$dbu)}] \
        [expr {int($x1*$dbu)}] [expr {int($y1*$dbu)}]
    incr nb
  }
  close $fh
  puts "  $nb obstrucciones de DRC leidas de $bloqueos"
}

global_route -guide_file out/route.guide -allow_congestion -verbose
#  `-disable_via_gen`: sin esto el router se fabrica sus propias vias con las
#  `VIARULE ... GENERATE` del techlef, que dan un pad de 0.38 x 0.28 — por debajo
#  del area minima y con un escalon de 0.05 contra un cable de 0.28, de donde
#  salian `M3.3`, `M3.1` y los rocecillos de `M3.2a`/`M2.2a`. Con el flag usa las
#  vias cuadradas de `lef/vias.lef`.
detailed_route -disable_via_gen \
               -output_drc out/route_drc.rpt \
               -output_maze out/route_maze.log \
               -droute_end_iter 5 -verbose 1

write_def out/GRADIENT_NAV_routed.def
puts "--------------------------------------------------------------"
report_design_area
puts "DEF ruteado en out/GRADIENT_NAV_routed.def"
puts "informe DRC del router en out/route_drc.rpt"
puts "--------------------------------------------------------------"
