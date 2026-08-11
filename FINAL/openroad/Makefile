# OpenROAD collateral for the analog macros.
#
#   make collateral   regenerate LEF / Liberty / Verilog from the layouts
#   make verilog      regenerate the top Verilog from the xschem netlist
#   make check        load everything in OpenROAD and list the macros
#   make floorplan    place the whole top, build the power grid, write the DEF
#   make route        place_pins + global_route + detailed_route
#   make gds          DEF -> GDS, with the real layout inside every macro
#   make top          verilog + collateral + floorplan + route + gds
#   make drc          KLayout sign-off DRC on the four blocks and the top
#   make drc-magic    magic DRC, a second opinion with a different deck
#   make lvs          netgen LVS on the four blocks and the top
#   make lvs-ref      netlist de referencia para el LVS externo del chipathon
#   make probar       rompe el layout a proposito: comprueba que el DRC/LVS se enteran
#   make check-all    the three above
#   make clean        remove generated outputs (not the collateral)

OPENROAD := /foss/tools/bin/openroad
PYTHON   := python3
# KLayout's Python module lives in the project venv; PYTHONPATH has to be
# dropped or the system packages shadow it (see zotnetic_layout/DRC_KLAYOUT.md).
KPYTHON  := env -u PYTHONPATH /headless/.venvs/zotnetic/bin/python

.PHONY: all top verilog collateral check floorplan route gds fill \
        drc drc-magic drc-density lvs lvs-klayout lvs-ref probar check-all clean

all: verilog collateral check

top: verilog collateral floorplan route gds fill lvs-ref

verilog:
	$(PYTHON) scripts/spice_to_verilog.py

collateral:
	$(PYTHON) scripts/patch_techlef.py
	$(KPYTHON) scripts/build_collateral.py

check:
	$(OPENROAD) -no_init -exit scripts/load_design.tcl

floorplan:
	$(OPENROAD) -no_init -exit scripts/floorplan_top.tcl

route:
	$(OPENROAD) -no_init -exit -threads 4 scripts/route_top.tcl

gds:
	$(KPYTHON) scripts/def_to_gds.py

#  El relleno de densidad va DESPUES del GDS y no toca nada de arriba: lee
#  out/GRADIENT_NAV.gds y escribe out/GRADIENT_NAV_filled.gds, que es el fichero
#  de submision. El de partida se queda para el lazo de depuracion.
fill:
	$(KPYTHON) scripts/fill_density.py

drc:
	$(KPYTHON) scripts/drc_klayout.py

#  Las reglas de densidad son un pase aparte: el deck no las corre si no se le
#  piden. magic no sirve de segunda opinion aqui — su techfile de GF180 no trae
#  ni una regla de densidad.
drc-density:
	$(KPYTHON) scripts/drc_klayout.py --density GRADIENT_NAV_FILLED

drc-magic:
	$(PYTHON) scripts/drc_magic.py

lvs:
	$(PYTHON) scripts/lvs_netgen.py

lvs-klayout:
	$(PYTHON) scripts/lvs_klayout.py

#  Netlist de referencia para el LVS de FUERA (el del chipathon, que lee
#  lvs_config.json de la raiz del repo). Va encadenado en `top` a proposito: si
#  se queda viejo, el LVS externo compara el GDS de hoy contra el esquematico de
#  la semana pasada y dice que cuadra.
lvs-ref:
	$(PYTHON) scripts/lvs_reference.py

#  Rompe el layout a proposito y comprueba que las comprobaciones se enteran. Un
#  "limpio" solo vale si sabes que esa herramienta habria cantado el fallo.
probar:
	$(PYTHON) scripts/probar_verificacion.py

check-all: drc drc-magic drc-density lvs

clean:
	rm -rf out work work_drc work_lvs work_prueba
