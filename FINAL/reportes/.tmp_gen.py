import sys
from pathlib import Path
sys.path.insert(0,"/foss/designs/a_zonetic2026/reportes")
import hacer_pptx as H
H.construir(H.EN, Path("/tmp/EN_gen.pptx"))
