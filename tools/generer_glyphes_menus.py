"""Habille les silhouettes SVG fournies dans le depot pour les menus du jeu."""

from __future__ import annotations

from pathlib import Path
from xml.etree import ElementTree


RACINE = Path(__file__).resolve().parent.parent
SOURCES = RACINE / "SVG"
SORTIE = RACINE / "assets/visual/interface/menu"
ESPACE_SVG = "{http://www.w3.org/2000/svg}"

# Une silhouette source differente pour chaque noeud de maitrise.
MAITRISES = {
    "offensif": {
        "force": "Hand Gesture of Power", "cadence": "Preparing for an attack",
        "precision": "Arrow", "puissance": "Hammer", "rythme": "Battle magic",
        "catalyse": "Potion", "trajectoire": "Bow", "tempete": "Lightning",
        "domination": "Swords", "grand_oeuvre": "Special magic",
    },
    "defensif": {
        "constitution": "Healing magic", "armure": "Armor 2 + Body",
        "vitalite": "Plus", "rempart": "Shield", "robustesse": "Helmet",
        "carapace": "Armor 1 + Body", "endurance": "Shoes", "bastion": "Chest",
        "colosse": "Hand + Glove", "immortel": "Spiritual magic",
    },
    "utilitaire": {
        "celerite": "Drop Water or Blood", "collecte": "Money Gold 1",
        "distillation": "Water", "fortune": "Earh magic",
        "sagesse": "Notepad", "abondance": "Money Gold 2",
        "savoir": "Inkwell with pen", "elan": "Feather",
        "prescience": "Palm of Hand", "philosophe": "Paper",
    },
}

SORTS = {
    "onde_alchimique": ("Battle magic", "arcane"),
    "nova_de_givre": ("Winter", "givre"),
    "barrage_de_braise": ("Fire 1", "feu"),
    "impulsion_foudroyante": ("Lightning", "foudre"),
    "explosion_corrosive": ("Potion", "acide"),
    "vortex_alchimique": ("Spiritual magic", "vortex"),
    "moisson_vitale": ("Healing magic", "vie"),
    "sang_froid": ("Water", "givre"),
    "riposte_alchimique": ("Hand Gesture of Power", "acide"),
    "reserve_ultime": ("Special magic", "arcane"),
    "rempart_initial": ("Shield", "protection"),
    "heritage_reactif": ("Resources", "cristal"),
    "audace": ("Preparing for an attack", "feu"),
    "echo_alchimique": ("Earh magic", "vortex"),
    "grand_oeuvre": ("Fire 2", "solaire"),
    "temps_suspendu": ("Ring", "temps"),
    "transmutation_totale": ("Drop Water or Blood", "cristal"),
    "purification_totale": ("Torch", "solaire"),
}

FAMILIERS = {
    "homoncule_encre": ("Mascot", "arcane"),
    "salamandre": ("Fire 2", "feu"),
    "ondine": ("Water", "givre"),
    "sylphe": ("Feather", "foudre"),
    "golem": ("Armor 2 + Body", "protection"),
}

# Eclat, matiere, ombre et aura. Les ombres gardent le volume de la silhouette.
PALETTES = {
    "offensif": ("#fff0b7", "#ff8739", "#a93439", "#ff673f"),
    "defensif": ("#dffff0", "#44e3a2", "#127d73", "#49e9ae"),
    "utilitaire": ("#fce4ff", "#b86dff", "#593cb6", "#b37eff"),
    "arcane": ("#e6ffff", "#51d1ff", "#3158c5", "#61ceff"),
    "givre": ("#f4ffff", "#74d8ff", "#3658c9", "#7be4ff"),
    "feu": ("#fff2b6", "#ff8b36", "#bb304b", "#ff773c"),
    "foudre": ("#f5ffff", "#42caff", "#3a4cc4", "#62d9ff"),
    "acide": ("#f2ffad", "#82ef65", "#168b62", "#a7f269"),
    "vortex": ("#f6dfff", "#c164ff", "#5935b8", "#ca76ff"),
    "vie": ("#e8ffca", "#63e596", "#138a6b", "#65efa4"),
    "protection": ("#fff4b9", "#d0b67c", "#526c9b", "#ffe3a3"),
    "cristal": ("#f3e8ff", "#a779ff", "#4875b7", "#b593ff"),
    "solaire": ("#fff9c4", "#ffcb63", "#bc5972", "#ffe080"),
    "temps": ("#e8ffff", "#7bcbea", "#6655b2", "#a8dbff"),
}


def chemin_source(nom: str) -> Path:
    return SOURCES / f"Wenrexa {nom}.svg"


def silhouette(nom: str) -> str:
    source = chemin_source(nom)
    if not source.is_file():
        raise FileNotFoundError(source)
    formes = ElementTree.parse(source).getroot().findall(f".//{ESPACE_SVG}path")
    if len(formes) != 1 or not formes[0].get("d"):
        raise ValueError(f"Une silhouette SVG attendue dans {source}")
    return str(formes[0].get("d"))


def poussiere(couleur: str, decalee: bool = False) -> str:
    points = [(28, 55, 3), (213, 39, 4), (226, 173, 3), (35, 204, 2)]
    if decalee:
        points = [(42, 31, 3), (224, 76, 2), (207, 221, 4), (18, 155, 3)]
    return "".join(
        f'<path d="M{x} {y-r*2}L{x+r} {y} {x} {y+r*2} {x-r} {y}Z" '
        f'fill="{couleur}" fill-opacity=".82"/>'
        for x, y, r in points
    )


def mouvement(effet: str, couleur: str) -> str:
    commun = f'fill="none" stroke="{couleur}" stroke-linecap="round" stroke-linejoin="round"'
    if effet == "feu":
        return (f'<path d="M20 164Q48 139 43 112M204 146Q230 121 217 93M64 224Q104 201 89 180" {commun} stroke-width="4" opacity=".82"/>'
                '<circle cx="38" cy="96" r="4" fill="#ffe6a4"/><circle cx="211" cy="79" r="3" fill="#ffe6a4"/>')
    if effet == "givre":
        return (f'<path d="M34 70l18-9-2-19M206 56l-16 9 3 17M33 189l18 4 1 18M207 184l-18 5-2 17" {commun} stroke-width="3.5"/>'
                f'<path d="M29 126h25m-13-13v26M217 126h-25m13-13v26" {commun} stroke-width="2.5" opacity=".75"/>')
    if effet == "foudre":
        return (f'<path d="M24 75l24-12-9 24 20-11M212 159l-26 6 14 18-28-3M95 26l12 16-11 9" {commun} stroke-width="4"/>'
                '<circle cx="208" cy="62" r="3" fill="#eaffff"/>')
    if effet == "acide":
        return (f'<circle cx="34" cy="150" r="9" fill="none" stroke="{couleur}" stroke-width="3"/>'
                f'<circle cx="211" cy="91" r="5" fill="none" stroke="{couleur}" stroke-width="2.5"/>'
                f'<circle cx="210" cy="191" r="11" fill="none" stroke="{couleur}" stroke-width="3"/>')
    if effet == "vortex":
        return (f'<path d="M31 70Q90 13 168 40M225 164Q199 230 119 218M42 189Q19 152 31 119" {commun} stroke-width="4" opacity=".72"/>'
                f'<path d="M43 43l13 2-3 14M210 203l-15-1 5-14" {commun} stroke-width="3"/>')
    if effet == "vie":
        return (f'<path d="M29 180Q47 140 66 156Q58 191 29 180ZM226 173Q207 136 188 152Q197 190 226 173Z" '
                f'fill="{couleur}" fill-opacity=".42" stroke="{couleur}" stroke-width="2"/>')
    if effet == "protection":
        return f'<path d="M30 122Q30 52 99 29M226 122Q226 52 157 29M40 176Q63 223 117 228M216 176Q193 223 139 228" {commun} stroke-width="3" opacity=".75"/>'
    if effet == "cristal":
        return (f'<path d="M36 84l14-19 13 17-13 19ZM203 146l17-25 12 20-17 25ZM71 213l8-14 12 10-8 14Z" '
                f'fill="{couleur}" fill-opacity=".42" stroke="{couleur}" stroke-width="2"/>')
    if effet == "temps":
        return (f'<circle cx="128" cy="128" r="101" fill="none" stroke="{couleur}" stroke-width="2.5" opacity=".6"/>'
                f'<path d="M128 25v15M128 216v15M25 128h15M216 128h15M57 57l10 10M189 189l10 10" {commun} stroke-width="4"/>')
    if effet == "solaire":
        return (f'<path d="M128 14v22M128 220v22M14 128h22M220 128h22M48 48l16 16M192 192l16 16M48 208l16-16M192 64l16-16" '
                f'{commun} stroke-width="3.5" opacity=".85"/>')
    return (f'<path d="M31 90Q58 37 112 29M225 166Q199 218 143 226" {commun} stroke-width="3.5" opacity=".7"/>'
            f'<circle cx="128" cy="128" r="103" fill="none" stroke="{couleur}" stroke-width="1.8" opacity=".3"/>')


def composer(nom_source: str, palette: tuple[str, str, str, str], effet: str, est_sort: bool) -> str:
    clair, moyen, ombre, lueur = palette
    trace = silhouette(nom_source)
    contour = "#fff2d8" if effet in ("feu", "solaire", "offensif") else "#ebf7ff"
    decorations = mouvement(effet, lueur) if est_sort else poussiere(lueur, len(nom_source) % 2 == 0)
    anneau = (f'<circle cx="128" cy="128" r="108" fill="none" stroke="{lueur}" stroke-width="2" opacity=".28"/>'
              if est_sort else "")
    echelle = "translate(23 23) scale(.82)"
    return f'''<svg xmlns="http://www.w3.org/2000/svg" width="512" height="512" viewBox="0 0 256 256">
<defs>
<linearGradient id="email" x1=".13" y1=".03" x2=".86" y2="1"><stop stop-color="#ffffff"/><stop offset=".13" stop-color="{clair}"/><stop offset=".46" stop-color="{moyen}"/><stop offset=".82" stop-color="{ombre}"/><stop offset="1" stop-color="{moyen}"/></linearGradient>
<linearGradient id="reflet" x1="0" y1="0" x2=".78" y2=".88"><stop stop-color="#ffffff" stop-opacity=".76"/><stop offset=".34" stop-color="{clair}" stop-opacity=".14"/><stop offset=".8" stop-color="{ombre}" stop-opacity="0"/></linearGradient>
<radialGradient id="halo"><stop stop-color="{lueur}" stop-opacity=".43"/><stop offset=".52" stop-color="{lueur}" stop-opacity=".16"/><stop offset="1" stop-color="{lueur}" stop-opacity="0"/></radialGradient>
</defs>
<circle cx="128" cy="128" r="121" fill="url(#halo)"/>{anneau}
{decorations}
<path d="{trace}" transform="translate(27 29) scale(.82)" fill="#0a1730" fill-rule="evenodd" opacity=".72"/>
<path d="{trace}" transform="{echelle}" fill="url(#email)" fill-rule="evenodd" stroke="{ombre}" stroke-width="4" stroke-linejoin="round"/>
<path d="{trace}" transform="{echelle}" fill="url(#reflet)" fill-rule="evenodd" opacity=".74"/>
<path d="{trace}" transform="{echelle}" fill="none" stroke="{contour}" stroke-opacity=".72" stroke-width="1.5" stroke-linejoin="round"/>
</svg>'''


def generer() -> None:
    sorties: list[tuple[Path, str]] = []
    sources_maitrises: list[str] = []
    for branche, glyphes in MAITRISES.items():
        for identifiant, source in glyphes.items():
            sources_maitrises.append(source)
            sorties.append((SORTIE / "glyphes" / branche / f"{identifiant}.svg",
                            composer(source, PALETTES[branche], branche, False)))
    if len(set(sources_maitrises)) != 30:
        raise ValueError("Chaque maîtrise doit garder une silhouette distincte")
    for identifiant, (source, effet) in SORTS.items():
        sorties.append((SORTIE / "sorts/icones" / f"{identifiant}.svg",
                        composer(source, PALETTES[effet], effet, True)))
    for identifiant, (source, effet) in FAMILIERS.items():
        sorties.append((SORTIE / "familiers" / f"{identifiant}.svg",
                        composer(source, PALETTES[effet], effet, True)))
    for destination, contenu in sorties:
        ElementTree.fromstring(contenu)
        destination.parent.mkdir(parents=True, exist_ok=True)
        destination.write_text(contenu, encoding="utf-8")
    print(f"{len(sorties)} glyphes SVG composes depuis des silhouettes sources")


if __name__ == "__main__":
    generer()
