#!/usr/bin/env python3
"""Comprueba que las comprobaciones fallan cuando tienen que fallar.

Un "limpio" solo vale si sabes que esa herramienta habria cantado el fallo. En
este proyecto eso no es teoria: `check_connectivity.py` daba **55/55 pasara lo
que pasara** durante dias, porque usaba `net.name` como identidad de la net y ese
campo esta vacio en casi todas. No fallaba: mentia.

Asi que aqui se rompe el layout **a proposito**, de tres formas conocidas, y se
mira quien se entera. Es la unica forma de demostrar que un "limpio" significa
algo.

    python3 scripts/probar_verificacion.py            # los tres, sin DRC
    python3 scripts/probar_verificacion.py --con-drc  # ademas el DRC (mas lento)

Los ficheros rotos se escriben en `work_prueba/` y no los usa nadie mas.
"""

from __future__ import annotations

import re
import subprocess
import sys
from pathlib import Path

import klayout.db as kdb

ROOT = Path(__file__).resolve().parent.parent
GDS = ROOT / "out/GRADIENT_NAV.gds"
#: Todo lo de esta prueba es desechable y NO se sube: `make clean` se lo lleva.
TMP = ROOT / "work_prueba"
DEF = ROOT / "out/GRADIENT_NAV_routed.def"
PY = sys.executable
KPY = "/headless/.venvs/zotnetic/bin/python"

M3 = (42, 0)
VIA2 = (38, 0)


def conectividad(gds: Path) -> tuple[int, int]:
    """(abiertas, cortos) que reporta la comprobacion sobre ese GDS."""
    r = subprocess.run([PY, str(ROOT / "scripts/check_connectivity.py"),
                        str(DEF), f"--gds={gds}"],
                       capture_output=True, text=True, check=False)
    txt = r.stdout + r.stderr
    ab = len(re.findall(r"^\s*ABIERTA", txt, re.M))
    co = len(re.findall(r"^\s*CORTO", txt, re.M))
    return ab, co


def _pads_de_dos_nets():
    """Dos pads de Metal3 de nets DISTINTAS que esten cerca, para poder unirlos."""
    sys.path.insert(0, str(ROOT / "scripts"))
    from check_connectivity import lef_pins, macro_size, place, read_def
    from def_to_gds import lef_origin

    inst, nets, units = read_def(DEF)
    lefs, sizes, orig = {}, {}, {}
    for p in (ROOT / "lef").glob("*.lef"):
        if p.name in ("vias.lef", "techlef_patched.tlef"):
            continue
        lefs[p.stem], sizes[p.stem], orig[p.stem] = (
            lef_pins(p), macro_size(p), lef_origin(p))

    puntos = []
    for net, pins in sorted(nets.items()):
        if net in ("VDD", "VSS"):
            continue
        for iname, pin in pins:
            if iname not in inst:
                continue
            cell, x, y, o = inst[iname]
            for r in lefs.get(cell, {}).get(pin, []):
                a = place(r, x / units, y / units, o, sizes[cell], orig[cell])
                puntos.append((net, (a[0] + a[2]) / 2, (a[1] + a[3]) / 2))
                break
            break
    #  El par mas cercano de nets distintas: cuanto mas corto el puente, menos se
    #  parece a "he redibujado medio chip".
    mejor = None
    for i, (na, xa, ya) in enumerate(puntos):
        for nb, xb, yb in puntos[i + 1:]:
            if na == nb:
                continue
            d = abs(xa - xb) + abs(ya - yb)
            if mejor is None or d < mejor[0]:
                mejor = (d, (na, xa, ya), (nb, xb, yb))
    return mejor


def romper_corto(dst: Path):
    """Une dos nets con una tira de Metal3. **Esto no viola ninguna regla de DRC.**"""
    d, (na, xa, ya), (nb, xb, yb) = _pads_de_dos_nets()
    ly = kdb.Layout()
    ly.read(str(GDS))
    top = ly.top_cell()
    caja = kdb.DBox(min(xa, xb), min(ya, yb), max(xa, xb), max(ya, yb))
    caja = caja.enlarged(0.19, 0.19)
    top.shapes(ly.layer(*M3)).insert(caja.to_itype(ly.dbu))
    ly.write(str(dst))
    return f"{na} y {nb} unidas con Metal3 ({d:.1f} um de puente)"


def romper_abierto(dst: Path):
    """Borra las Via2 de una ventana: corta la subida de una net a Metal3."""
    ly = kdb.Layout()
    ly.read(str(GDS))
    top = ly.top_cell()
    d, (na, xa, ya), _ = _pads_de_dos_nets()
    ventana = kdb.DBox(xa - 6, ya - 6, xa + 6, ya + 6).to_itype(ly.dbu)
    capa = ly.layer(*VIA2)
    fuera = [s for s in top.shapes(capa).each()
             if s.is_box() or s.is_polygon() or s.is_path()]
    n = 0
    for s in fuera:
        if ventana.contains(s.dbbox().center().to_itype(ly.dbu)):
            top.shapes(capa).erase(s)
            n += 1
    ly.write(str(dst))
    return f"{n} via2 borradas alrededor de {na} ({xa:.1f}, {ya:.1f})"


def romper_drc(dst: Path):
    """Mete Metal3 a 0.10 um de otro Metal3: `M3.2a` pide 0.28."""
    ly = kdb.Layout()
    ly.read(str(ROOT / "gds/COMP.gds"))
    top = ly.top_cell()
    capa = ly.layer(*M3)
    origen = next(s for s in top.shapes(capa).each() if s.is_box() or s.is_polygon())
    b = origen.dbbox()
    top.shapes(capa).insert(
        kdb.DBox(b.right + 0.10, b.bottom, b.right + 0.50, b.bottom + 0.40)
        .to_itype(ly.dbu))
    ly.write(str(dst))
    return f"Metal3 a 0.10 um de ({b.right:.2f}, {b.bottom:.2f}) en COMP"


def drc_limpio(gds: Path, celda: str) -> bool:
    """True si el DRC de KLayout no saca ni una violacion. Aborta si no corrio.

    La primera version daba "limpio" cuando el deck **no llegaba a arrancar**
    —`klayout` no estaba en el PATH— porque sumaba violaciones sobre cero
    ficheros. Esta prueba existe justo para cazar eso, asi que empezo cazandose a
    si misma. El PATH tiene que llevar `/foss/tools/klayout`, y `PDK_ROOT` tiene
    que estar puesto: es lo mismo que hace `drc_klayout.py`.
    """
    run = TMP / f"drc_{celda}"
    subprocess.run(["rm", "-rf", str(run)], check=False)
    run.mkdir(parents=True, exist_ok=True)
    subprocess.run(
        ["python3", "/foss/pdks/gf180mcuD/libs.tech/klayout/tech/drc/run_drc.py",
         f"--path={gds}", "--variant=D", f"--topcell={celda}",
         f"--run_dir={run}", "--mp=4"],
        capture_output=True, text=True, check=False, timeout=14400,
        env={"PATH": "/foss/tools/klayout:/usr/bin:/bin",
             "HOME": "/tmp", "PDK_ROOT": "/foss/pdks"})
    dbs = list(run.glob("*.lyrdb"))
    if not dbs:
        sys.exit(f"el DRC no llego a correr sobre {gds} — ni un .lyrdb en {run}")
    return sum(len(re.findall(r"<item>", f.read_text(errors="replace")))
               for f in dbs) == 0


def main() -> int:
    TMP.mkdir(parents=True, exist_ok=True)
    con_drc = "--con-drc" in sys.argv
    print("Referencia: el layout de verdad\n")
    ab, co = conectividad(GDS)
    print(f"  conectividad sobre el GDS bueno: {ab} abiertas, {co} cortos"
          f"   {'OK' if (ab, co) == (0, 0) else 'OJO: ya venia roto'}\n")

    fallos = 0
    print("Ahora, roturas a proposito:\n")

    dst = TMP / "roto_corto.gds"
    print(f"  1. CORTO      {romper_corto(dst)}")
    ab, co = conectividad(dst)
    bien = co > 0
    print(f"     conectividad: {ab} abiertas, {co} cortos"
          f"      -> {'LO VE' if bien else 'NO LO VE  <-- MAL'}")
    fallos += 0 if bien else 1

    dst = TMP / "roto_abierto.gds"
    print(f"  2. ABIERTO    {romper_abierto(dst)}")
    ab, co = conectividad(dst)
    bien = ab > 0
    print(f"     conectividad: {ab} abiertas, {co} cortos"
          f"      -> {'LO VE' if bien else 'NO LO VE  <-- MAL'}")
    fallos += 0 if bien else 1

    if con_drc:
        dst = TMP / "roto_drc.gds"
        print(f"  3. DRC        {romper_drc(dst)}")
        bien = not drc_limpio(dst, "COMP")
        print(f"     DRC de KLayout sobre COMP roto: "
              f"{'LO VE' if bien else 'NO LO VE  <-- MAL'}")
        fallos += 0 if bien else 1

        print("\n  Y el control que mas dice de todo esto:")
        limpio = drc_limpio(TMP / "roto_corto.gds", "GRADIENT_NAV")
        print(f"     DRC sobre el GDS CON EL CORTO: "
              f"{'limpio' if limpio else 'saca violaciones'}"
              f"   <- limpio es lo ESPERADO: el DRC no ve un corto")
    else:
        print("\n  (con --con-drc se anaden las dos pruebas de DRC)")

    print(f"\n{'todas las comprobaciones reaccionan' if not fallos else str(fallos) + ' comprobacion(es) NO reaccionan'}")
    return 1 if fallos else 0


if __name__ == "__main__":
    sys.exit(main())
