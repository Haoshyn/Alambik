"""Habillage commun des glyphes de menu : icone de jeu en aplats ombres.

Contour sombre epais, ombre portee, trois tons (bord eclaire en haut a gauche,
matiere en degrade, ombre franche en bas a droite), reflet dur et eclat.
ThorVG (le rendu SVG de Godot) ignore <use> et les masques : chaque couche
recopie donc la silhouette en ligne et les tons sont obtenus par des
decoupes imbriquees de copies decalees.
"""

from __future__ import annotations

import hashlib

CONTOUR = "#1a0f2c"

# Eclat, haut de la matiere, bas de la matiere, ombre franche.
PALETTES = {
    "offensif": ("#fff1c9", "#ffb65e", "#ee6a2c", "#9c2430"),
    "defensif": ("#e6fff3", "#74f2c2", "#1fae86", "#0d5658"),
    "utilitaire": ("#f7e9ff", "#cfa6ff", "#8650ee", "#43208e"),
    "arcane": ("#e9fdff", "#79dcff", "#2f84e3", "#173f8f"),
    "feu": ("#fff2b6", "#ffae4a", "#ef5a2a", "#8f1f33"),
    "givre": ("#f2ffff", "#8fe6ff", "#3a9fe0", "#1d4c94"),
    "foudre": ("#fbffd8", "#ffe36a", "#f2a81c", "#8a4a12"),
    "protection": ("#fff6d6", "#ffd98a", "#c98c3a", "#6b4120"),
}


def _couche(trace: str, cadre: str, attributs: str, dx: float = 0.0, dy: float = 0.0) -> str:
    decalage = f"translate({dx:g} {dy:g}) " if dx or dy else ""
    return f'<path d="{trace}" transform="{decalage}{cadre}" fill-rule="evenodd" {attributs}/>'


def habiller(trace: str, palette: tuple[str, str, str, str], cadre: str = "translate(23 23) scale(.82)",
             contour: float = 18.0, eclat: tuple[float, float] | None = (74.0, 64.0)) -> str:
    """Couches SVG d'une silhouette ; `contour` est exprime dans le repere 256."""
    clair, haut, bas, ombre = palette
    # Le trait suit l'echelle du cadre : il est converti dans le repere de la silhouette.
    echelle = 0.82
    if "scale(" in cadre:
        echelle = float(cadre.split("scale(")[1].split(")")[0].split()[0])
    trait = contour / echelle
    # Identifiants stables : une regeneration ne change pas les fichiers inchanges.
    identifiant = hashlib.sha1((trace + "".join(palette)).encode()).hexdigest()[:8]
    c1, c2, g = f"s{identifiant}", f"l{identifiant}", f"m{identifiant}"
    couches = [
        f'<defs><clipPath id="{c1}">{_couche(trace, cadre, "")}</clipPath>',
        f'<clipPath id="{c2}">{_couche(trace, cadre, "", -5, -7)}</clipPath>',
        f'<linearGradient id="{g}" x1="0" y1="0" x2=".35" y2="1"><stop stop-color="{haut}"/>'
        f'<stop offset="1" stop-color="{bas}"/></linearGradient></defs>',
        _couche(trace, cadre, f'fill="{CONTOUR}" opacity=".5"', 3, 11),
        _couche(trace, cadre, f'fill="{CONTOUR}" stroke="{CONTOUR}" stroke-width="{trait:.1f}" stroke-linejoin="round"'),
        f'<g clip-path="url(#{c1})"><rect width="256" height="256" fill="{ombre}"/>',
        f'<g clip-path="url(#{c2})"><rect width="256" height="256" fill="{clair}"/>',
        _couche(trace, cadre, f'fill="url(#{g})"', 3, 4),
        '</g>',
        '<ellipse cx="86" cy="62" rx="78" ry="30" fill="#ffffff" opacity=".2" transform="rotate(-28 86 62)"/>',
        '</g>',
        _couche(trace, cadre, f'fill="none" stroke="#ffffff" stroke-opacity=".16" stroke-width="{2.0 / echelle:.1f}" stroke-linejoin="round"'),
    ]
    if eclat is not None:
        x, y = eclat
        couches.append(f'<path d="M{x:g} {y - 15:g}l5 10 10 5-10 5-5 10-5-10-10-5 10-5z" fill="#ffffff"/>')
    return "\n".join(couches)
