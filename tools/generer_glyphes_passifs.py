"""Compose les passifs depuis seize silhouettes distinctes de la banque SVG."""

from __future__ import annotations

from pathlib import Path
from xml.etree import ElementTree

from generer_glyphes_menus import FAMILIERS, MAITRISES, silhouette


RACINE = Path(__file__).resolve().parent.parent
SORTIE = RACINE / "assets/visual/interface/menu/passifs/glyphes"

# Les silhouettes restent distinctes de celles des maitrises et des familiers.
PASSIFS = {
    "vigueur": ("Double Axe", "offensif"),
    "vitalite": ("Necklace", "defensif"),
    "carapace": ("Belt", "defensif"),
    "celerite": ("Double Dagger", "offensif"),
    "pas_leger": ("Winter", "utilitaire"),
    "oeil_precis": ("Dagger", "offensif"),
    "impact_critique": ("Axe", "offensif"),
    "projectiles_vifs": ("Long Dagger", "offensif"),
    "soins_renforces": ("Fire 1", "defensif"),
    "recuperation": ("Ring", "defensif"),
    "moisson_vitale": ("Sickle", "defensif"),
    "sang_froid": ("Resources", "utilitaire"),
    "rempart_initial": ("Torch", "offensif"),
    "audace": ("Skull Demon", "offensif"),
    "butin_precieux": ("Cargo Bag", "utilitaire"),
    "savoir_pratique": ("Wizard's Cap", "utilitaire"),
}

PALETTES = {
    "offensif": ("#ffecd2", "#efa982", "#bb606c", "#684766"),
    "defensif": ("#e3fff0", "#8ed5c5", "#479ca4", "#3d637c"),
    "utilitaire": ("#f1e8ff", "#cbb2f3", "#9679c5", "#635880"),
}


def gravure(identifiant: str) -> str:
    traits = 'fill="none" stroke="#fff1d4" stroke-width="4" stroke-linecap="round" stroke-linejoin="round"'
    if identifiant == "vitalite":
        return '<path d="M128 149C104 128 100 145 108 156L128 179 148 156C156 145 152 128 128 149Z" fill="#fff1d4" stroke="#3d637c" stroke-width="3"/>'
    if identifiant == "carapace":
        return '<path d="M104 102L128 94 152 102 150 131Q146 146 128 155 110 146 106 131Z" fill="url(#metal)" stroke="#fff1d4" stroke-width="3"/><path d="M128 104v37" stroke="#3d637c" stroke-width="3"/>'
    if identifiant == "oeil_precis":
        return f'<circle cx="188" cy="187" r="24" {traits}/><path d="M188 156v16m0 30v16m-31-31h16m30 0h16" {traits}/>'
    if identifiant == "soins_renforces":
        return '<path d="M128 134v36m-18-18h36" fill="none" stroke="#3d637c" stroke-width="11" stroke-linecap="round"/><path d="M128 134v36m-18-18h36" fill="none" stroke="#fff1d4" stroke-width="6" stroke-linecap="round"/>'
    if identifiant == "recuperation":
        return f'<path d="M199 81Q224 113 205 145m-2-15 2 16 16-3" {traits}/>'
    if identifiant == "sang_froid":
        return f'<path d="M185 56v38m-16-29 32 20m-32 0 32-20" {traits}/>'
    if identifiant == "butin_precieux":
        return '<path d="M128 127L146 148 128 173 110 148Z" fill="url(#metal)" stroke="#fff1d4" stroke-width="3"/>'
    if identifiant == "savoir_pratique":
        return '<path d="M67 203Q94 193 128 203 161 193 188 203v26Q160 219 128 229 96 219 67 229Z" fill="url(#metal)" stroke="#fff1d4" stroke-width="3"/><path d="M128 204v24" stroke="#635880" stroke-width="3"/>'
    return ""


def composer(identifiant: str, nom_source: str, categorie: str) -> str:
    clair, moyen, profond, ombre = PALETTES[categorie]
    trace = silhouette(nom_source)
    return f'''<svg xmlns="http://www.w3.org/2000/svg" width="512" height="512" viewBox="0 0 256 256">
<title>{identifiant.replace('_', ' ')}</title>
<desc>Silhouette Wenrexa {nom_source}, banque tools/sources_svg ; habillage Alambik.</desc>
<defs>
<linearGradient id="email" x1="0" y1="0" x2=".75" y2="1"><stop stop-color="{clair}"/><stop offset=".38" stop-color="{moyen}"/><stop offset=".77" stop-color="{profond}"/><stop offset="1" stop-color="{ombre}"/></linearGradient>
<linearGradient id="metal" x1="0" y1="0" x2="1" y2="1"><stop stop-color="#fff5dc"/><stop offset=".48" stop-color="#e5c695"/><stop offset="1" stop-color="#a08077"/></linearGradient>
<linearGradient id="reflet" x1="0" y1="0" x2=".9" y2="1"><stop stop-color="#ffffff" stop-opacity=".3"/><stop offset=".55" stop-color="#ffffff" stop-opacity="0"/></linearGradient>
</defs>
<path d="{trace}" transform="translate(23 26) scale(.82)" fill="#19283c" fill-rule="evenodd" opacity=".65"/>
<path d="{trace}" transform="translate(23 20) scale(.82)" fill="url(#email)" fill-rule="evenodd" stroke="#283951" stroke-width="5" stroke-linejoin="round"/>
<path d="{trace}" transform="translate(23 20) scale(.82)" fill="url(#reflet)" fill-rule="evenodd" stroke="{clair}" stroke-width="1.8" stroke-linejoin="round"/>
{gravure(identifiant)}
</svg>
'''


def generer() -> None:
    sources = [source for source, _ in PASSIFS.values()]
    if len(set(sources)) != len(sources):
        raise ValueError("Une silhouette differente est requise pour chaque passif")
    sources_menus = {source for branche in MAITRISES.values() for source in branche.values()}
    sources_menus.update(source for source, _ in FAMILIERS.values())
    if sources_menus.intersection(sources):
        raise ValueError("Les passifs ne doivent pas reprendre les silhouettes des autres glyphes de menu")
    contenus = {identifiant: composer(identifiant, source, categorie)
                for identifiant, (source, categorie) in PASSIFS.items()}
    for contenu in contenus.values():
        ElementTree.fromstring(contenu)
    SORTIE.mkdir(parents=True, exist_ok=True)
    for identifiant, contenu in contenus.items():
        (SORTIE / f"{identifiant}.svg").write_text(contenu, encoding="utf-8")
    print(f"{len(contenus)} passifs SVG, tous avec une silhouette distincte")


if __name__ == "__main__":
    generer()
