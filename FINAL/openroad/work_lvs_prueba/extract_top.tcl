gds read /foss/designs/a_zonetic2026/openroad/out/prueba_etiquetas/B26_A_filled2_labeled.gds
load B26_A
flatten B26_A_f
load B26_A_f
cellname delete B26_A
cellname rename B26_A_f B26_A
select top cell
extract path /foss/designs/a_zonetic2026/openroad/work_lvs_prueba/.ext
ext2spice lvs
extract all
ext2spice -p /foss/designs/a_zonetic2026/openroad/work_lvs_prueba/.ext -o B26_A_extracted.spice
quit -noprompt
