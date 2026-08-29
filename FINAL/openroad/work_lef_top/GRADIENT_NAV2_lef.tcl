gds read /foss/designs/a_zonetic2026/openroad/out_v2_GRADIENT_NAV2/GRADIENT_NAV2_decap.gds
load GRADIENT_NAV2
select top cell
port makeall
lef write GRADIENT_NAV2
quit -noprompt
