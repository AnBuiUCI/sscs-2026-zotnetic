integration/ -- what the chip is assembled from, and every version of it
=======================================================================

This directory is the archive of the INTEGRATION, the 1110 x 1110 um user area
the organisers give us inside their padring. Two kinds of thing live here, and
neither of them is built by the flow:

  padframe/   The files the organisers sent through GitHub. Copies -- the
              working set stays in openroad/padframe/, which is what
              padframe_def.py, integrate_top.tcl and check_integration.py read.
              Copied and not moved on purpose: a script left pointing at the old
              path fails silently, and this archive is meant to be read by
              people, not by the flow.

  esd/        Their secondary-ESD cell exactly as it arrived, before anything of
              ours touched it. What actually gets built from it is in
              layouts_v2/io_secondary_5p0/, which has its own README_ORIGEN.txt.

  gds/        One directory per version of the WHOLE integrated area, newest
              last. Each carries the GDS gzipped and a NOTAS.txt with what
              changed and the MEASURED verdict of DRC, density and LVS -- not a
              summary of them, the numbers.

  HISTORIAL.txt   One line per version, newest first. The index.

WHY GZIPPED. A filled B26_A is 42.5 MB and there will be one per revision. The
convention already exists: FINAL/.gitattributes declares `*.gds.gz binary`. The
live, uncompressed file stays where the flow writes it,
openroad/out_integration/.

The snapshots are made by openroad/scripts/archivar_integracion.py, not by hand.
A note written by hand drifts from the file it describes, and a version history
that lies about which GDS passed what is worse than no history.
