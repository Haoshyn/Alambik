"""Prepare les couches mobiles de la clairiere a partir des peintures sources."""

from __future__ import annotations

from io import BytesIO
from pathlib import Path
from xml.etree import ElementTree
from zipfile import ZIP_DEFLATED, ZIP_STORED, ZipFile

from PIL import Image, ImageChops, ImageDraw, ImageFilter


RACINE = Path(__file__).resolve().parents[1]
SORTIE = RACINE / "assets/visual/interface/clairiere_vivante"
SOURCES = Path(__file__).resolve().parent / "sources_clairiere"
TAILLE = (948, 1659)
CADRE_LAC = (318, 748, 765, 855)
CADRE_CASCADE = (506, 652, 570, 760)


def enregistrer(image: Image.Image, nom: str) -> None:
    image.save(SORTIE / nom, optimize=True, compress_level=9)


def masque_polygone(taille: tuple[int, int], points: list[tuple[int, int]], flou: float) -> Image.Image:
    masque = Image.new("L", taille)
    ImageDraw.Draw(masque).polygon(points, fill=255)
    return masque.filter(ImageFilter.GaussianBlur(flou))


def multiplier_alpha(image: Image.Image, masque: Image.Image) -> Image.Image:
    resultat = image.copy()
    resultat.putalpha(ImageChops.multiply(image.getchannel("A"), masque))
    return resultat


def decouper_branche(image: Image.Image, points: list[tuple[int, int]], nom: str) -> tuple[Image.Image, Image.Image, tuple[int, int]]:
    masque = masque_polygone(TAILLE, points, 3.0)
    branche_entiere = multiplier_alpha(image, masque)
    boite = branche_entiere.getchannel("A").point(lambda valeur: 255 if valeur > 4 else 0).getbbox()
    assert boite is not None
    x0, y0, x1, y1 = boite
    boite = (max(0, x0 - 2), max(0, y0 - 2), min(TAILLE[0], x1 + 2), min(TAILLE[1], y1 + 2))
    branche = branche_entiere.crop(boite)
    enregistrer(branche, nom)
    return masque, branche, boite[:2]


def extraire_atmosphere(image: Image.Image, case: tuple[int, int], nom: str) -> Image.Image:
    x, y = case
    morceau = image.crop((x * 768, y * 512, (x + 1) * 768, (y + 1) * 512))
    alpha = morceau.getchannel("A")
    # Le faible alpha du fond de l'atlas formerait un rectangle dans le ciel.
    alpha = alpha.point([max(0, min(255, int((valeur - 9) * 255 / 246))) for valeur in range(256)])
    boite = alpha.point(lambda valeur: 255 if valeur > 5 else 0).getbbox()
    assert boite is not None
    morceau.putalpha(alpha)
    morceau = morceau.crop(boite)
    largeur = 480
    hauteur = round(morceau.height * largeur / morceau.width)
    morceau = morceau.resize((largeur, hauteur), Image.Resampling.LANCZOS)
    bord_x = max(1, round(largeur * 0.10))
    bord_y = max(1, round(hauteur * 0.12))
    def fondu(distance: int, largeur_bord: int) -> float:
        t = min(1.0, distance / largeur_bord)
        return t * t * (3.0 - 2.0 * t)
    horizontal = [fondu(min(x, largeur - 1 - x), bord_x) for x in range(largeur)]
    vertical = [fondu(min(y, hauteur - 1 - y), bord_y) for y in range(hauteur)]
    alpha = morceau.getchannel("A").tobytes()
    fondu_alpha = bytes(round(valeur * horizontal[index % largeur] * vertical[index // largeur]) for index, valeur in enumerate(alpha))
    morceau.putalpha(Image.frombytes("L", (largeur, hauteur), fondu_alpha))
    enregistrer(morceau, nom)
    return morceau


def creer_cascade(paysage: Image.Image) -> tuple[Image.Image, Image.Image]:
    source = Image.open(SOURCES / "cascade_etude.png").convert("RGBA")
    largeur_source = source.width // 4
    base = paysage.crop(CADRE_CASCADE)
    masque = masque_polygone(
        TAILLE,
        [
            (521, 665), (530, 660), (543, 661), (553, 667), (558, 680),
            (558, 701), (557, 726), (552, 747), (540, 752), (520, 750),
            (515, 735), (515, 701), (517, 678),
        ],
        4.5,
    ).crop(CADRE_CASCADE)
    bord = 5
    alpha = masque.tobytes()
    largeur, hauteur = masque.size
    fondu = bytes(
        round(valeur * min(1.0, x / bord, (largeur - 1 - x) / bord)
              * min(1.0, y / bord, (hauteur - 1 - y) / bord))
        for y in range(hauteur) for x, valeur in enumerate(alpha[y * largeur:(y + 1) * largeur])
    )
    masque = Image.frombytes("L", base.size, fondu)
    planche = Image.new("RGBA", ((base.width + 4) * 4, base.height))
    for index in range(4):
        image = source.crop((index * largeur_source + 62, 47, (index + 1) * largeur_source - 62, 674))
        image = image.resize(base.size, Image.Resampling.LANCZOS)
        # La peinture originale fixe le contour ; l'etude n'apporte que du detail interieur.
        melange = Image.blend(base.convert("RGB"), image.convert("RGB"), 0.48)
        cadre = melange.convert("RGBA")
        cadre.putalpha(masque)
        x = index * (base.width + 4)
        planche.alpha_composite(cadre, (x + 2, 0))
        planche.paste(cadre.crop((0, 0, 1, base.height)), (x, 0))
        planche.paste(cadre.crop((0, 0, 1, base.height)), (x + 1, 0))
        planche.paste(cadre.crop((base.width - 1, 0, base.width, base.height)), (x + 2 + base.width, 0))
        planche.paste(cadre.crop((base.width - 1, 0, base.width, base.height)), (x + 3 + base.width, 0))
    enregistrer(planche, "cascade_boucle.png")
    masque.save(SOURCES / "masque_cascade.png", optimize=True, compress_level=9)
    return planche, masque


def png_bytes(image: Image.Image) -> bytes:
    sortie = BytesIO()
    image.save(sortie, format="PNG", optimize=True)
    return sortie.getvalue()


def creer_source_calquee(calques: list[tuple[str, Image.Image, tuple[int, int], bool, float]], apercu: Image.Image) -> None:
    pile = ElementTree.Element("image", {"w": str(TAILLE[0]), "h": str(TAILLE[1]), "name": "Clairiere vivante", "version": "0.0.3"})
    stack = ElementTree.SubElement(pile, "stack")
    cible = SOURCES / "clairiere_vivante.ora"
    with ZipFile(cible, "w") as archive:
        archive.writestr("mimetype", "image/openraster", compress_type=ZIP_STORED)
        for index, (nom, image, position, visible, opacite) in enumerate(reversed(calques)):
            chemin = f"data/layer{index}.png"
            archive.writestr(chemin, png_bytes(image), compress_type=ZIP_DEFLATED)
            ElementTree.SubElement(stack, "layer", {
                "name": nom, "src": chemin, "x": str(position[0]), "y": str(position[1]),
                "opacity": str(opacite), "visibility": "visible" if visible else "hidden", "composite-op": "svg:src-over",
            })
        archive.writestr("stack.xml", ElementTree.tostring(pile, encoding="utf-8", xml_declaration=True))
        archive.writestr("mergedimage.png", png_bytes(apercu), compress_type=ZIP_DEFLATED)
        miniature = apercu.copy()
        miniature.thumbnail((256, 256))
        archive.writestr("Thumbnails/thumbnail.png", png_bytes(miniature), compress_type=ZIP_DEFLATED)


def main() -> None:
    SOURCES.mkdir(parents=True, exist_ok=True)
    paysage = Image.open(SORTIE / "paysage.png").convert("RGBA")
    vegetation_source = Image.open(SORTIE / "vegetation.png").convert("RGBA")
    vegetation = vegetation_source.resize(TAILLE, Image.Resampling.LANCZOS)
    atmosphere = Image.open(SORTIE / "atmosphere.png").convert("RGBA")

    gauche, branche_gauche, position_gauche = decouper_branche(
        vegetation,
        [(239, 121), (266, 125), (307, 142), (343, 159), (356, 180),
         (353, 208), (323, 216), (286, 208), (257, 185), (237, 159)],
        "rameau_gauche.png",
    )
    droite, branche_droite, position_droite = decouper_branche(
        vegetation,
        [(613, 174), (651, 157), (702, 149), (752, 157), (797, 163),
         (835, 150), (841, 180), (803, 198), (760, 197), (728, 221),
         (682, 239), (635, 229), (604, 207)],
        "rameau_droit.png",
    )
    cote_gauche, branche_cote_gauche, position_cote_gauche = decouper_branche(
        vegetation,
        [(83, 363), (96, 357), (116, 361), (134, 372),
         (134, 396), (116, 404), (98, 398), (82, 385)],
        "rameau_cote_gauche.png",
    )
    cote_droit, branche_cote_droit, position_cote_droit = decouper_branche(
        vegetation,
        [(830, 369), (846, 352), (871, 349), (887, 333), (904, 329),
         (921, 341), (916, 353), (889, 365), (866, 382), (845, 387)],
        "rameau_cote_droit.png",
    )
    zones_mobiles = ImageChops.lighter(ImageChops.lighter(gauche, droite),
                                        ImageChops.lighter(cote_gauche, cote_droit))
    alpha = vegetation.getchannel("A")
    table = bytes(
        0 if origine == 255 and masque == 255 else
        round((origine - origine * masque / 255.0) / (1.0 - origine * masque / 65025.0))
        for origine in range(256) for masque in range(256)
    )
    # Les deux calques doivent restituer exactement l'alpha source au repos.
    alpha_fixe = bytes(table[(origine << 8) | masque] for origine, masque in zip(alpha.tobytes(), zones_mobiles.tobytes()))
    vegetation_fixe = vegetation.copy()
    vegetation_fixe.putalpha(Image.frombytes("L", TAILLE, alpha_fixe))
    # Les separations traversent des zones transparentes de la peinture.
    enregistrer(vegetation_fixe.crop((0, 0, 580, 630)), "vegetation_haut_gauche.png")
    enregistrer(vegetation_fixe.crop((580, 0, 948, 500)), "vegetation_haut_droite.png")
    enregistrer(vegetation_fixe.crop((0, 1160, 948, 1659)), "vegetation_basse.png")

    lac = paysage.crop(CADRE_LAC)
    masque_lac = masque_polygone(
        TAILLE,
        [(350, 775), (410, 770), (510, 768), (630, 769), (714, 774),
         (739, 783), (737, 799), (715, 815), (671, 826), (585, 831),
         (486, 831), (415, 827), (368, 815), (344, 796)],
        7.0,
    ).crop(CADRE_LAC)
    enregistrer(lac, "reflets_lac.png")
    enregistrer(masque_lac, "masque_lac.png")
    cascade, masque_cascade = creer_cascade(paysage)
    nuage_gauche = extraire_atmosphere(atmosphere, (0, 0), "nuage_gauche.png")
    nuage_droit = extraire_atmosphere(atmosphere, (1, 0), "nuage_droit.png")
    brume = extraire_atmosphere(atmosphere, (0, 1), "brume_lac.png")

    ciel = Image.new("RGBA", TAILLE)
    trace = ImageDraw.Draw(ciel)
    for y in range(TAILLE[1]):
        t = min(1.0, y / 720.0)
        if t < 0.62:
            facteur = t / 0.62
            depart, arrivee = (84, 138, 235), (172, 197, 255)
        else:
            facteur = (t - 0.62) / 0.38
            depart, arrivee = (172, 197, 255), (241, 221, 235)
        couleur = tuple(round(depart[i] * (1.0 - facteur) + arrivee[i] * facteur) for i in range(3)) + (255,)
        trace.line((0, y, TAILLE[0], y), fill=couleur)

    nuage_gauche_source = nuage_gauche.resize((360, 188), Image.Resampling.LANCZOS)
    nuage_droit_source = nuage_droit.resize((346, 126), Image.Resampling.LANCZOS)
    brume_source = brume.resize((432, 155), Image.Resampling.LANCZOS)
    apercu = ciel.copy()
    for image, position, opacite in [
        (nuage_gauche_source, (75, 78), 0.52),
        (nuage_droit_source, (475, 143), 0.46),
        (paysage, (0, 0), 1.0),
        (brume_source, (230, 705), 0.22),
        (vegetation, (0, 0), 1.0),
    ]:
        couche = image.copy()
        if opacite < 1.0:
            couche.putalpha(couche.getchannel("A").point(lambda valeur: round(valeur * opacite)))
        apercu.alpha_composite(couche, position)
    cascade_repos = cascade.crop((2, 0, 66, cascade.height))
    apercu.alpha_composite(cascade_repos, CADRE_CASCADE[:2])
    calques = [
        ("Ciel indicatif", ciel, (0, 0), True, 1.0),
        ("Nuage gauche", nuage_gauche_source, (75, 78), True, 0.52),
        ("Nuage droit", nuage_droit_source, (475, 143), True, 0.46),
        ("Paysage fixe", paysage, (0, 0), True, 1.0),
        ("Masque lac", masque_lac.convert("RGBA"), CADRE_LAC[:2], False, 1.0),
        ("Reflets lac", lac, CADRE_LAC[:2], False, 1.0),
        ("Masque cascade", masque_cascade.convert("RGBA"), CADRE_CASCADE[:2], False, 1.0),
        *[
            (f"Cascade image {index}", cascade.crop((index * 68 + 2, 0, index * 68 + 66, cascade.height)), CADRE_CASCADE[:2], index == 0, 1.0)
            for index in range(4)
        ],
        ("Brume lac", brume_source, (230, 705), True, 0.22),
        ("Vegetation fixe", vegetation_fixe, (0, 0), True, 1.0),
        ("Rameau gauche", branche_gauche, position_gauche, True, 1.0),
        ("Rameau droit", branche_droite, position_droite, True, 1.0),
        ("Rameau cote gauche", branche_cote_gauche, position_cote_gauche, True, 1.0),
        ("Rameau cote droit", branche_cote_droit, position_cote_droit, True, 1.0),
    ]
    creer_source_calquee(calques, apercu)
    print("Couches de la clairiere regenerees.")
    print("Rameaux cote :", position_cote_gauche, position_cote_droit)


if __name__ == "__main__":
    main()
