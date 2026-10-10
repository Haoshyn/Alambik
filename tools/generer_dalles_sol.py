"""Genere le dallage multiplie sur l'enduit des sols de combat.

Motif original et raccordable : deux rangees de deux dalles en appareil
decale. Chaque dalle a sa nuance, un grain de pierre, un biseau eclaire en
haut a gauche et ombre en bas a droite ; les joints sont sombres. Le blanc
laisse l'enduit intact (melange par multiplication dans le materiau).
"""

from __future__ import annotations

import math
import random
from pathlib import Path

from PIL import Image, ImageFilter

RACINE = Path(__file__).resolve().parent.parent
SORTIE = RACINE / "assets/visual/sols/dalles_jeu.png"
COTE = 512
JOINT = 7.0
BISEAU = 16.0
RAYON_COIN = 18.0


def _dalles() -> list[tuple[float, float, float, float, float]]:
    # (x, y, largeur, hauteur, nuance) en pixels ; les bords debordent pour raccorder.
    hasard = random.Random(48)
    demi = COTE / 2
    dalles = []
    for rangee in range(2):
        y = rangee * demi
        decalage = 0.0 if rangee == 0 else demi / 2
        for colonne in range(-1, 3):
            x = decalage + colonne * demi
            dalles.append((x, y, demi, demi, hasard.uniform(-0.05, 0.05)))
    return dalles


def _distance_rectangle_arrondi(px: float, py: float, x: float, y: float, l: float, h: float) -> float:
    # Distance signee au bord interieur d'un rectangle arrondi (positive dedans).
    cx, cy = x + l / 2, y + h / 2
    qx = abs(px - cx) - (l / 2 - JOINT / 2 - RAYON_COIN)
    qy = abs(py - cy) - (h / 2 - JOINT / 2 - RAYON_COIN)
    exterieur = math.hypot(max(qx, 0.0), max(qy, 0.0))
    interieur = min(max(qx, qy), 0.0)
    return -(exterieur + interieur - RAYON_COIN)


def generer() -> None:
    hasard = random.Random(7)
    grain = Image.effect_noise((COTE, COTE), 38).filter(ImageFilter.GaussianBlur(1.6))
    nuages = Image.effect_noise((COTE // 8, COTE // 8), 60).resize((COTE, COTE), Image.BICUBIC)
    image = Image.new("L", (COTE, COTE))
    pixels = image.load()
    dalles = _dalles()
    for py in range(COTE):
        for px in range(COTE):
            meilleure = None
            for x, y, l, h, nuance in dalles:
                for dx in (-COTE, 0, COTE):
                    for dy in (-COTE, 0, COTE):
                        d = _distance_rectangle_arrondi(px, py, x + dx, y + dy, l, h)
                        if meilleure is None or d > meilleure[0]:
                            meilleure = (d, nuance, x + dx + l / 2, y + dy + h / 2)
            d, nuance, cx, cy = meilleure
            if d <= 0.0:
                valeur = 0.60
            else:
                valeur = 1.0 + nuance
                if d < BISEAU:
                    # Biseau : la lumiere vient du haut a gauche, comme pour les icones.
                    nx, ny = px - cx, py - cy
                    longueur = math.hypot(nx, ny) or 1.0
                    eclairage = -(nx * 0.55 + ny * 0.83) / longueur
                    force = (1.0 - d / BISEAU) ** 1.6
                    valeur += eclairage * 0.16 * force - 0.05 * force
                valeur += (grain.getpixel((px, py)) - 128) / 128 * 0.025
                valeur += (nuages.getpixel((px, py)) - 128) / 128 * 0.03
            pixels[px, py] = max(0, min(255, round(valeur * 236)))
    image = image.filter(ImageFilter.GaussianBlur(0.7))
    SORTIE.parent.mkdir(parents=True, exist_ok=True)
    image.convert("RGB").save(SORTIE)
    print(f"Dallage ecrit : {SORTIE.relative_to(RACINE)}")


if __name__ == "__main__":
    generer()
