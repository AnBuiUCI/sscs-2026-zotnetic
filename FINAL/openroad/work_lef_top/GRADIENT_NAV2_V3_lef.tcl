gds read /foss/designs/a_zonetic2026/openroad/out_v2_GRADIENT_NAV2_V3/GRADIENT_NAV2_V3_decap.gds
load GRADIENT_NAV2_V3
select top cell
port makeall
lef write GRADIENT_NAV2_V3
quit -noprompt
