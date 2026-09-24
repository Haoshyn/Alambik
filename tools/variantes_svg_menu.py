"""Cree des variantes SVG du menu sans toucher aux glyphes actifs."""

from __future__ import annotations

import re
from pathlib import Path


RACINE = Path(__file__).resolve().parent.parent
SOURCE_NAVIGATION = RACINE / "assets/visual/interface"
SORTIE = RACINE / "assets/visual/interface/menu"

PALETTES = {
    "offensif": ("#fff0bb", "#ff9237", "#d93233", "#681f3a", "#fff8d9"),
    "defensif": ("#e3ffc0", "#5aeea6", "#149773", "#184444", "#f4ffdd"),
    "utilitaire": ("#ffe0ff", "#c377ff", "#7544d6", "#34236c", "#fff0ff"),
    "heros": ("#d8ffbf", "#76e99f", "#278f65", "#20464b", "#f3ffe0"),
    "forge": ("#f4d7ff", "#b684f4", "#7045bd", "#302450", "#fff0ff"),
    "portail": ("#dcf7ff", "#6dd6ff", "#328add", "#20375e", "#f1ffff"),
    "astrolabe": ("#fff1bd", "#f3c56d", "#bd7854", "#4c324a", "#fff9dd"),
    "grimoire": ("#ffe2ed", "#f28ab5", "#b7538f", "#4b294d", "#fff1f7"),
}

GRADIENT = re.compile(
    r"(<(?:linearGradient|radialGradient)\b[^>]*\bid=\"([^\"]+)\"[^>]*>)(.*?)(</(?:linearGradient|radialGradient)>)",
    re.DOTALL,
)
STOP = re.compile(r'stop-color="#[0-9a-fA-F]{6}"')


def _gamme(nom: str, palette: tuple[str, ...], nombre: int) -> list[str]:
    clair, vif, profond, ombre, reflet = palette
    if nom in ("acier", "papier", "page"):
        couleurs = [reflet, clair, vif, profond, clair]
    elif nom in ("or",):
        couleurs = [reflet, "#e7b56b", "#795263"]
    elif nom in ("nuit",):
        couleurs = [profond, ombre, "#151b35"]
    elif nom in ("lueur", "magie"):
        couleurs = [clair, clair]
    else:
        couleurs = [clair, vif, profond, ombre]
    if nombre == 1:
        return [couleurs[0]]
    return [couleurs[round(i * (len(couleurs) - 1) / (nombre - 1))] for i in range(nombre)]


def _variante(source: Path, destination: Path, palette: tuple[str, ...]) -> None:
    contenu = source.read_text(encoding="utf-8")

    def remplacer_gradient(match: re.Match[str]) -> str:
        debut, nom, corps, fin = match.groups()
        couleurs = _gamme(nom, palette, len(STOP.findall(corps)))
        compteur = iter(couleurs)
        corps = STOP.sub(lambda _match: f'stop-color="{next(compteur)}"', corps)
        return debut + corps + fin

    contenu = GRADIENT.sub(remplacer_gradient, contenu)
    destination.parent.mkdir(parents=True, exist_ok=True)
    destination.write_text(contenu, encoding="utf-8")


def _noeud(destination: Path, palette: tuple[str, ...]) -> None:
    clair, vif, profond, ombre, _reflet = palette
    contenu = f'''<svg xmlns="http://www.w3.org/2000/svg" width="384" height="384" viewBox="0 0 128 128">
<defs><radialGradient id="email"><stop stop-color="{profond}"/><stop offset=".68" stop-color="{ombre}"/><stop offset="1" stop-color="#151a32"/></radialGradient><linearGradient id="metal" x1="0" y1="0" x2="1" y2="1"><stop stop-color="#ffebad"/><stop offset=".42" stop-color="#9e6f64"/><stop offset=".8" stop-color="#f0c589"/><stop offset="1" stop-color="#775466"/></linearGradient><radialGradient id="halo"><stop stop-color="{vif}" stop-opacity=".25"/><stop offset="1" stop-color="{vif}" stop-opacity="0"/></radialGradient></defs>
<circle cx="64" cy="64" r="63" fill="url(#halo)"/><circle cx="64" cy="64" r="58" fill="#131a30" stroke="url(#metal)" stroke-width="4"/><circle cx="64" cy="64" r="51" fill="url(#email)" stroke="{clair}" stroke-opacity=".5" stroke-width="1.3"/><circle cx="64" cy="64" r="46" fill="none" stroke="{vif}" stroke-opacity=".32" stroke-width="1"/><path d="M64 3l4 7-4 7-4-7ZM64 125l4-7-4-7-4 7ZM3 64l7-4 7 4-7 4ZM125 64l-7-4-7 4 7 4Z" fill="#f5cd91" stroke="#52394d" stroke-width="1"/><path d="M29 29A49 49 0 0 1 99 29" fill="none" stroke="#fff0b9" stroke-opacity=".48" stroke-width="1.3"/></svg>'''
    destination.write_text(contenu, encoding="utf-8")


def generer() -> None:
    arbre = (RACINE / "data/arbre_competences.gd").read_text(encoding="utf-8")
    branches = arbre.split("const BRANCHES := {", 1)[1].split("}\n", 1)[0]
    for libelle, _liste in re.findall(r'"([^\"]+)":\s*(\[[^\]]+\])', branches):
        nom = {"Offensif": "offensif", "Défensif": "defensif", "Utilitaire": "utilitaire"}[libelle]
        repertoire = SORTIE / "glyphes" / nom
        # Les glyphes de noeud ont leur dessin propre dans generer_glyphes_menus.py.
        _noeud(SORTIE / f"noeud_{nom}.svg", PALETTES[nom])
    for nom in ("heros", "forge", "portail", "astrolabe", "grimoire"):
        _variante(SOURCE_NAVIGATION / f"{nom}.svg", SORTIE / "navigation" / f"{nom}.svg", PALETTES[nom])


if __name__ == "__main__":
    generer()
