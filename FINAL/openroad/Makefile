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
#   make check-all    the three above
#   make clean        remove generated outputs (not the collateral)

OPENROAD := /foss/tools/bin/openroad
PYTHON   := python3
# KLayout's Python module lives in the project venv; PYTHONPATH has to be
# dropped or the system packages shadow it (see zotnetic_layout/DRC_KLAYOUT.md).
KPYTHON  := env -u PYTHONPATH /headless/.venvs/zotnetic/bin/python

.PHONY: all top verilog collateral check floorplan route gds \
        drc drc-magic lvs check-all clean

all: verilog collateral check

top: verilog collateral floorplan route gds

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

drc:
	$(KPYTHON) scripts/drc_klayout.py

drc-magic:
	$(PYTHON) scripts/drc_magic.py

lvs:
	$(PYTHON) scripts/lvs_netgen.py

check-all: drc drc-magic lvs

clean:
	rm -rf out work work_drc work_lvs
