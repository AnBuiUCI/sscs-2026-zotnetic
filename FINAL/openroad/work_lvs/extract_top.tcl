gds read /foss/designs/a_zonetic2026/openroad/out_v2_GRADIENT_NAV2/GRADIENT_NAV2_filled.gds
load GRADIENT_NAV2
flatten GRADIENT_NAV2_f
load GRADIENT_NAV2_f
cellname delete GRADIENT_NAV2
cellname rename GRADIENT_NAV2_f GRADIENT_NAV2
select top cell
extract path /foss/designs/a_zonetic2026/openroad/work_lvs/.ext
ext2spice lvs
extract all
ext2spice -p /foss/designs/a_zonetic2026/openroad/work_lvs/.ext -o GRADIENT_NAV2_extracted.spice
quit -noprompt
