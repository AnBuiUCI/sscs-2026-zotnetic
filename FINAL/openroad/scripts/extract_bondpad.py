#!/usr/bin/env python3
"""The bare wire-bond pad of the GF180 I/O library, as a cell of our own.

    python3 scripts/extract_bondpad.py        # -> layouts/BONDPAD/

WHAT IT IS. Every pad cell of `gf180mcu_fd_io` is built around one sub-cell,
`Bondpad_5LM`: a 68 x 65.3 um Metal5 plate with the 60 x 60 um passivation
opening (layer Pad, 37/0) that the bond wire lands on, and under it a slotted
stack of Metal2/3/4 tied together by via arrays. It carries no ESD, no driver,
no rails -- it is only the landing site. That is what this script lifts out,
so a bond or probe point can be dropped anywhere inside our own GDS: an
internal node we want to reach with a probe needle, or an extra wire bond.

WHY RENAMED. The sub-cells are called `M5_M4_CDNS_4066195314556` and the
like, and the SAME names exist inside the padring the organisers build around
the user area. Two different cells with one name in the final GDS is a merge
that goes wrong silently -- one of them wins. Every cell here gets the prefix
`ZN_BP_`, and the top is `ZN_BONDPAD`.

WHAT IT DOES NOT SETTLE. A pad in the middle of the die is legal GF180
geometry, but whether the SHUTTLE accepts one -- and bonds to it -- is theirs
to say (the tapeout checklist, section 1: "permitted bond-pad construction").
Nothing sits under it here except its own metal stack: no circuit-under-pad.

Writes two cells, the first a faithful copy and the second DRC-clean:
  layouts/BONDPAD/ZN_BONDPAD.gds   the cell, origin at the lower-left corner
                                   of its Metal5
  layouts/BONDPAD/ZN_BONDPAD.lef   abstract: pin PAD on Metal5, the stack below
                                   as obstruction, for OpenROAD placement
  layouts/BONDPAD/ZN_BONDPAD_M5.gds/.lef  the same Metal5 plate and opening
                                   with no stack under them (see below)
"""

from __future__ import annotations

import os
import sys
from pathlib import Path

import klayout.db as kdb

ROOT = Path(__file__).resolve().parent.parent
SRC = (Path(os.environ["PDK_ROOT"]) / "gf180mcuD/libs.ref/gf180mcu_fd_io/gds"
       / "gf180mcu_fd_io.gds")
CELL_SRC = "Bondpad_5LM"
CELL = "ZN_BONDPAD"
PREFIX = "ZN_BP_"
OUT_GDS = ROOT / "layouts" / "BONDPAD" / f"{CELL}.gds"
#: Next to the GDS and NOT in lef/: def_to_gds.py takes every lef/*.lef as a
#: macro of the integration, demands its gds/, and would stop there.
OUT_LEF = ROOT / "layouts" / "BONDPAD" / f"{CELL}.lef"
#: The same plate and opening with nothing under them -- see the end of main().
CELL_M5 = "ZN_BONDPAD_M5"
OUT_GDS_M5 = ROOT / "layouts" / "BONDPAD" / f"{CELL_M5}.gds"
OUT_LEF_M5 = ROOT / "layouts" / "BONDPAD" / f"{CELL_M5}.lef"

#: GF180 5LM layer numbers, the ones this cell uses.
PAD = (37, 0)
METAL = {"Metal2": (36, 0), "Metal3": (42, 0), "Metal4": (46, 0), "Metal5": (81, 0)}
M5_LABEL = (81, 10)


def main() -> int:
    if not SRC.exists():
        sys.exit(f"  I/O library not found: {SRC}")
    src = kdb.Layout()
    src.read(str(SRC))
    if not src.has_cell(CELL_SRC):
        sys.exit(f"  {CELL_SRC} is not in {SRC.name}")

    #  Copy the cell WITH its hierarchy into a fresh layout: `copy_tree` brings
    #  every sub-cell along, so the via arrays stay arrays.
    dst = kdb.Layout()
    dst.dbu = src.dbu
    top = dst.create_cell(CELL)
    top.copy_tree(src.cell(CELL_SRC))
    for c in dst.each_cell():
        if c.cell_index() != top.cell_index():
            c.name = PREFIX + c.name

    #  Origin at the lower-left corner of the Metal5 plate, so a placement
    #  coordinate means the same thing in the GDS and in the LEF.
    m5 = dst.layer(*METAL["Metal5"])
    bb = top.bbox_per_layer(m5)
    top.transform(kdb.Trans(-bb.left, -bb.bottom))

    #  A label on the pad, so an extractor sees a port and a viewer shows it.
    lab = dst.layer(*M5_LABEL)
    pad = dst.layer(*PAD)
    pb = top.bbox_per_layer(pad)
    top.shapes(lab).insert(kdb.Text("PAD", kdb.Trans(pb.center().x, pb.center().y)))

    OUT_GDS.parent.mkdir(parents=True, exist_ok=True)
    dst.write(str(OUT_GDS))

    #  --- LEF ---------------------------------------------------------------
    u = dst.dbu
    full = top.bbox()
    m5b = top.bbox_per_layer(m5)
    padb = top.bbox_per_layer(pad)

    def box(b):
        return f"{b.left * u:.3f} {b.bottom * u:.3f} {b.right * u:.3f} {b.top * u:.3f}"

    lef = [
        "VERSION 5.7 ;", "BUSBITCHARS \"[]\" ;", "DIVIDERCHAR \"/\" ;", "",
        f"MACRO {CELL}",
        "  CLASS BLOCK ;",
        "  ORIGIN 0 0 ;",
        f"  SIZE {full.width() * u:.3f} BY {full.height() * u:.3f} ;",
        "  SYMMETRY X Y ;",
        "  PIN PAD",
        "    DIRECTION INOUT ;",
        "    USE SIGNAL ;",
        "    PORT",
        "      LAYER Metal5 ;",
        f"        RECT {box(m5b)} ;",
        "    END",
        "  END PAD",
        "  OBS",
    ]
    for name in ("Metal2", "Metal3", "Metal4"):
        li = dst.layer(*METAL[name])
        b = top.bbox_per_layer(li)
        if not b.empty():
            lef += [f"    LAYER {name} ;", f"      RECT {box(b)} ;"]
    lef += ["  END", f"END {CELL}", "", "END LIBRARY", ""]
    OUT_LEF.write_text("\n".join(lef))

    #  --- the Metal5-only variant ----------------------------------------------
    #  GF's stack under the pad is a comb of 1.7 um lines with 0.3 um slots on
    #  Metal2/3/4, and the open deck's CUP.3 wants those slots at 1 um: 87
    #  markers on this one cell. Inside THEIR pad cells that is the foundry's
    #  own construction; renamed and dropped into our area it reads as ours. So
    #  a second cell keeps exactly their Metal5 plate and their opening -- same
    #  enclosure -- and nothing under it, which no CUP rule can see.
    only = kdb.Layout()
    only.dbu = dst.dbu
    tp = only.create_cell(CELL_M5)
    for spec in (METAL["Metal5"], PAD):
        tp.shapes(only.layer(*spec)).insert(
            kdb.Region(top.begin_shapes_rec(dst.layer(*spec))).merged())
    tp.shapes(only.layer(*M5_LABEL)).insert(
        kdb.Text("PAD", kdb.Trans(pb.center().x, pb.center().y)))
    only.write(str(OUT_GDS_M5))
    lef_m5 = [l.replace(CELL, CELL_M5) for l in lef[:lef.index("  OBS")]]
    lef_m5 += [f"END {CELL_M5}", "", "END LIBRARY", ""]
    OUT_LEF_M5.write_text("\n".join(lef_m5))

    print(f"  {CELL}: {full.width() * u:.2f} x {full.height() * u:.2f} um, "
          f"{sum(1 for _ in dst.each_cell())} cells")
    print(f"    Metal5 plate   {box(m5b)}")
    print(f"    Pad opening    {box(padb)}  "
          f"({padb.width() * u:.0f} x {padb.height() * u:.0f} um)")
    print(f"  -> {OUT_GDS.relative_to(ROOT)}")
    print(f"  -> {OUT_LEF.relative_to(ROOT)}")
    print(f"  {CELL_M5}: the same Metal5 plate and opening, nothing under them")
    print(f"  -> {OUT_GDS_M5.relative_to(ROOT)}")
    print(f"  -> {OUT_LEF_M5.relative_to(ROOT)}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
