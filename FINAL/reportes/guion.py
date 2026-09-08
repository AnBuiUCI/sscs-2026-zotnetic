#!/usr/bin/env python3
"""The plain-text companion that ships beside every deck in `reportes/`.

STANDING RULE (HANDOFF.md §8): anything delivered from `reportes/` gets a `.txt`
of the SAME NAME next to it, explaining IN SPANISH what each slide is there to
say -- for both the Spanish and the English deck. The slide is the visual, this
is what you say out loud while it is on screen.

It is generated from the same pass that builds the deck, not written afterwards.
`estilo.OBSERVADOR` fires as each slide is born, so the narration is bound to the
slide ORDER rather than to a hand-kept count. Add a slide and forget its line and
`escribir()` refuses to write, naming the slide -- which is the whole point: a
script that silently numbers the narration wrong is worse than no script.
"""

from __future__ import annotations

import textwrap
from pathlib import Path

import estilo as E

#: Wrapped so it reads in a terminal, an e-mail body, or the notes pane of
#: whoever is presenting.
ANCHO = 78


class Guion:
    """One entry per slide, in the order the slides are created."""

    def __init__(self, cabecera: list[str]) -> None:
        self.cabecera = cabecera
        self.entradas: list[dict] = []

    def engancha(self) -> "Guion":
        E.OBSERVADOR = self._nace
        return self

    def suelta(self) -> None:
        E.OBSERVADOR = None

    def _nace(self, tipo: str, titulo: str) -> None:
        self.entradas.append({"tipo": tipo, "titulo": titulo, "texto": []})

    def di(self, *parrafos: str) -> None:
        """Attaches the narration to the slide that was just created.

        Each argument is ONE paragraph. Passing a list instead of unpacking it
        used to reach `textwrap` and die there with an AttributeError about
        `expandtabs`, six frames from the mistake; caught here it names the
        slide.
        """
        if not self.entradas:
            raise RuntimeError("di() antes de crear ninguna diapositiva")
        for p in parrafos:
            if p and not isinstance(p, str):
                raise TypeError(
                    f"di() quiere parrafos sueltos, no {type(p).__name__}, "
                    f"en «{self.entradas[-1]['titulo']}» — "
                    f"¿falta desempaquetar con *?")
        self.entradas[-1]["texto"].extend(p for p in parrafos if p)

    def escribir(self, ruta: Path, n_diapositivas: int) -> None:
        #  Two independent ways of being out of step, both fatal. The hook can
        #  only miss a slide if `estilo` grows a fourth way to make one, and the
        #  empty check catches the ordinary mistake: a slide added without its
        #  line, which would shift every explanation after it by one.
        if len(self.entradas) != n_diapositivas:
            raise SystemExit(
                f"{ruta.name}: {len(self.entradas)} entradas de guion para "
                f"{n_diapositivas} diapositivas")
        mudas = [f"{i}. {e['titulo']}"
                 for i, e in enumerate(self.entradas, 1) if not e["texto"]]
        if mudas:
            raise SystemExit(f"{ruta.name}: diapositivas sin explicar:\n  "
                             + "\n  ".join(mudas))

        lineas = list(self.cabecera) + [""]
        for i, e in enumerate(self.entradas, 1):
            marca = {"portada": "PORTADA", "seccion": "SECCIÓN"}.get(e["tipo"], "")
            titulo = f"DIAPOSITIVA {i} · {e['titulo']}"
            if marca:
                titulo += f"  [{marca}]"
            lineas += [titulo, "-" * min(len(titulo), ANCHO)]
            for p in e["texto"]:
                lineas += textwrap.wrap(p, ANCHO) or [""]
                lineas.append("")
            if not e["texto"]:
                lineas.append("")
        ruta.write_text("\n".join(lineas).rstrip() + "\n", encoding="utf-8")
        print(f"  {ruta.name}   {len(self.entradas)} diapositivas explicadas")
