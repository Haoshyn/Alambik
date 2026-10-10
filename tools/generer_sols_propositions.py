"""Propositions de sols de combat : quatre matieres procedurales raccordables.

Chaque texture est un relief en niveaux de gris (512 x 512) ; la teinte du
monde la colore dans le materiau. Lumiere commune en haut a gauche.
  pierres   : paves irreguliers (cellules de Voronoi), joints profonds
  damier    : grandes dalles en damier a liseré grave
  parquet   : lames de bois decalees, veines et clous
  hexagones : carreaux hexagonaux emailles, bombes
"""

from __future__ import annotations

import math
import random
import sys
from pathlib import Path

from PIL import Image, ImageFilter

COTE = 512


def _bruit(graine: int, taille: int, flou: float) -> Image.Image:
    random.seed(graine)
    image = Image.effect_noise((taille, taille), 70).resize((COTE, COTE), Image.BICUBIC)
    return image.filter(ImageFilter.GaussianBlur(flou))


def _ecrire(valeurs, chemin: Path, hauteur: int = COTE) -> None:
    image = Image.new("L", (COTE, hauteur))
    image.putdata([max(0, min(255, round(v * 255))) for v in valeurs])
    image = image.filter(ImageFilter.GaussianBlur(0.6))
    image.convert("RGB").save(chemin)


def pierres() -> list[float]:
    hasard = random.Random(11)
    grille = 6
    pas = COTE / grille
    germes = {}
    for gx in range(grille):
        for gy in range(grille):
            germes[(gx, gy)] = ((gx + hasard.uniform(.2, .8)) * pas, (gy + hasard.uniform(.2, .8)) * pas,
                                hasard.uniform(-.09, .09))
    grain = _bruit(3, 128, 1.2)
    taches = _bruit(5, 16, 6)
    valeurs = []
    for y in range(COTE):
        for x in range(COTE):
            cx, cy = int(x // pas), int(y // pas)
            proches = []
            for dx in (-1, 0, 1):
                for dy in (-1, 0, 1):
                    gx, gy = cx + dx, cy + dy
                    px, py, nuance = germes[(gx % grille, gy % grille)]
                    px += (gx - gx % grille) * pas
                    py += (gy - gy % grille) * pas
                    proches.append((math.hypot(x - px, y - py), px, py, nuance))
            proches.sort()
            d1, px, py, nuance = proches[0]
            bord = (proches[1][0] - d1) * .5
            if bord < 3.5:
                v = .42
            else:
                v = .9 + nuance
                # Bombe de la pierre : plus claire vers la lumiere, plus sombre au bord oppose.
                nx, ny = (x - px) / (pas * .6), (y - py) / (pas * .6)
                v += (-nx * .5 - ny * .7) * .07
                v -= max(0.0, 1.0 - bord / 14.0) ** 2 * .16
                v += (grain.getpixel((x, y)) - 128) / 128 * .04
                v += (taches.getpixel((x, y)) - 128) / 128 * .05
            valeurs.append(v)
    return valeurs


def damier() -> list[float]:
    demi = COTE / 2
    grain = _bruit(7, 128, 1.0)
    valeurs = []
    for y in range(COTE):
        for x in range(COTE):
            ix, iy = int(x // demi), int(y // demi)
            lx, ly = x - ix * demi, y - iy * demi
            bord = min(lx, ly, demi - lx, demi - ly)
            v = .95 if (ix + iy) % 2 == 0 else .74
            if bord < 4:
                v = .40
            elif bord < 14:
                # Biseau : arete claire en haut a gauche, ombre en bas a droite.
                v += .1 if (lx < 14 or ly < 14) and lx < demi - 14 and ly < demi - 14 else -.12
            elif 26 < bord < 31:
                v -= .2  # liseré grave
            v += (grain.getpixel((x, y)) - 128) / 128 * .03
            valeurs.append(v)
    return valeurs


def parquet() -> list[float]:
    hasard = random.Random(21)
    lames = 8
    largeur = COTE / lames
    decalages = [hasard.uniform(0, COTE) for _ in range(lames)]
    longueur = COTE / 2
    veines = _bruit(9, 24, 2.0)
    valeurs = []
    for y in range(COTE):
        for x in range(COTE):
            rang = int(x // largeur)
            lx = x - rang * largeur
            ly = (y + decalages[rang]) % COTE
            morceau = int(ly // longueur)
            nuance = random.Random(rang * 7 + morceau).uniform(-.1, .1)
            fin = ly - morceau * longueur
            if lx < 2.5 or fin < 2.5:
                v = .38
            else:
                vagues = math.sin((lx * .9 + (veines.getpixel((x, y)) - 128) * .25) * .55)
                v = .82 + nuance + vagues * .05
                v += .06 if lx < 7 else (-.08 if lx > largeur - 7 else 0)
                if abs(fin - 10) < 2.6 and abs(lx - largeur / 2) < 2.6:
                    v = .5  # clou
            valeurs.append(v)
    return valeurs


HEX_RAYON = COTE / 6
HEX_HAUTEUR = round(3 * math.sqrt(3) * HEX_RAYON)


def hexagones() -> list[float]:
    # Quatre colonnes et trois rangees exactes : le motif raccorde dans les deux sens.
    rayon = HEX_RAYON
    pas_y = HEX_HAUTEUR / 3
    grain = _bruit(13, 64, 1.0)
    valeurs = []
    for y in range(HEX_HAUTEUR):
        for x in range(COTE):
            meilleur = None
            for colonne in range(-1, 5):
                for rangee in range(-1, 4):
                    cx = colonne * rayon * 1.5
                    cy = rangee * pas_y + (pas_y / 2 if colonne % 2 else 0)
                    d = math.hypot(x - cx, y - cy)
                    if meilleur is None or d < meilleur[0]:
                        meilleur = (d, cx, cy, colonne % 4, rangee % 3)
            _, cx, cy, colonne, rangee = meilleur
            lx, ly = abs(x - cx), abs(y - cy)
            bord = min(pas_y / 2 - ly, (math.sqrt(3) * rayon - math.sqrt(3) * lx - ly) / 2)
            nuance = (.07, -.05, .0)[(colonne + rangee * 2) % 3]
            if bord < 3.5:
                v = .40
            else:
                v = .88 + nuance - max(0.0, 1.0 - bord / 18) ** 2 * .2
                v += (-(x - cx) * .5 - (y - cy) * .7) / rayon * .07
                if 14 < bord < 18:
                    v += .08
                v += (grain.getpixel((x, y % COTE)) - 128) / 128 * .025
            valeurs.append(v)
    return valeurs


if __name__ == "__main__":
    sortie = Path(sys.argv[1])
    sortie.mkdir(parents=True, exist_ok=True)
    for nom, fabrique in (("pierres", pierres), ("damier", damier), ("parquet", parquet), ("hexagones", hexagones)):
        _ecrire(fabrique(), sortie / f"sol_{nom}.png", HEX_HAUTEUR if nom == "hexagones" else COTE)
        print("ecrit", nom)
