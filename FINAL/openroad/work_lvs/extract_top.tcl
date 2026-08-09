gds read /foss/designs/a_zonetic2026/openroad/out/GRADIENT_NAV.gds
load GRADIENT_NAV
flatten GRADIENT_NAV_f
load GRADIENT_NAV_f
cellname delete GRADIENT_NAV
cellname rename GRADIENT_NAV_f GRADIENT_NAV
select top cell
extract path /foss/designs/a_zonetic2026/openroad/work_lvs/.ext
ext2spice lvs
extract all
ext2spice -p /foss/designs/a_zonetic2026/openroad/work_lvs/.ext -o GRADIENT_NAV_extracted.spice
quit -noprompt
