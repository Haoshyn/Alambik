"""Convertit les illustrations originales en aplats vectoriels, sans bitmap embarque."""
from pathlib import Path
import argparse
import ast
import re

import numpy as np
from PIL import Image, ImageFilter

RACINE = Path(__file__).resolve().parents[1]


def simplifier(points, tolerance=0.5):
    if len(points) < 4:
        return points
    debut, fin = np.asarray(points[0]), np.asarray(points[-1])
    interieur = np.asarray(points[1:-1])
    direction = fin - debut
    longueur = float(np.dot(direction, direction))
    if longueur == 0:
        distances = np.sum((interieur - debut) ** 2, axis=1)
    else:
        projection = np.clip(((interieur - debut) @ direction) / longueur, 0, 1)
        distances = np.sum((interieur - debut - projection[:, None] * direction) ** 2, axis=1)
    index = int(np.argmax(distances)) + 1
    if distances[index - 1] <= tolerance * tolerance:
        return [points[0], points[-1]]
    return simplifier(points[:index + 1], tolerance)[:-1] + simplifier(points[index:], tolerance)


def contours(masque):
    hauteur, largeur = masque.shape
    entoure = np.pad(masque, 1)
    voisins = [entoure[:-2, 1:-1], entoure[1:-1, 2:], entoure[2:, 1:-1], entoure[1:-1, :-2]]
    aretes = {}
    for cote, voisin in enumerate(voisins):
        lignes, colonnes = np.nonzero(masque & ~voisin)
        for y, x in zip(lignes.tolist(), colonnes.tolist()):
            sommets = [(x, y), (x + 1, y), (x + 1, y + 1), (x, y + 1)]
            debut, fin = sommets[cote], sommets[(cote + 1) % 4]
            aretes.setdefault(debut, []).append(fin)
    directions = {(1, 0): 0, (0, 1): 1, (-1, 0): 2, (0, -1): 3}
    while aretes:
        debut = next(iter(aretes))
        point = debut
        boucle = [point]
        orientation = 0
        while point in aretes:
            choix = aretes[point]
            # Au contact diagonal, suivre le bord du meme ilot plutot que le croiser.
            rang = {1: 0, 0: 1, 3: 2, 2: 3}
            suivant = min(choix, key=lambda p: rang[(directions[(p[0]-point[0], p[1]-point[1])] - orientation) % 4])
            choix.remove(suivant)
            if not choix:
                del aretes[point]
            orientation = directions[(suivant[0]-point[0], suivant[1]-point[1])]
            point = suivant
            boucle.append(point)
            if point == debut:
                break
        if len(boucle) < 5:
            continue
        aire = sum(a[0]*b[1]-b[0]*a[1] for a,b in zip(boucle, boucle[1:])) / 2
        if abs(aire) < 1:
            continue
        milieu = len(boucle) // 2
        reduite = simplifier(boucle[:milieu+1])[:-1] + simplifier(boucle[milieu:])[:-1]
        if len(reduite) >= 3:
            yield reduite


def chemin(points):
    def milieu(a, b):
        return ((a[0]+b[0])/2, (a[1]+b[1])/2)
    debut = milieu(points[-1], points[0])
    morceaux = [f'M{debut[0]:g},{debut[1]:g}']
    for index, point in enumerate(points):
        fin = milieu(point, points[(index+1) % len(points)])
        morceaux.append(f'Q{point[0]},{point[1]} {fin[0]:g},{fin[1]:g}')
    return ''.join(morceaux) + 'Z'


def vectoriser(source, region, destination, resolution=256):
    with Image.open(source) as originale:
        # Le cadrage et l'echantillonnage appartiennent a la conversion ; seul le SVG est ecrit.
        image = originale.convert('RGBA').crop(region)
        image.thumbnail((resolution, resolution), Image.Resampling.LANCZOS)
    rgba = np.asarray(image)
    opaque = rgba[:, :, 3] >= 128
    quantifiee = image.convert('RGB').filter(ImageFilter.GaussianBlur(.55)).quantize(colors=128, method=Image.Quantize.MEDIANCUT)
    indices = np.asarray(quantifiee)
    palette = quantifiee.getpalette()
    elements = []
    for index in np.unique(indices[opaque]):
        couleur = '#%02x%02x%02x' % tuple(palette[int(index)*3:int(index)*3+3])
        traces = ''.join(chemin(boucle) for boucle in contours((indices == index) & opaque))
        if traces:
            elements.append(f'<path fill="{couleur}" stroke="{couleur}" stroke-width=".8" d="{traces}"/>')
    destination.parent.mkdir(parents=True, exist_ok=True)
    largeur, hauteur = image.size
    echelle = 128 / largeur if destination.parent.name == 'cadres' else 2
    svg = f'<svg xmlns="http://www.w3.org/2000/svg" width="{largeur*echelle:g}" height="{hauteur*echelle:g}" viewBox="0 0 {largeur} {hauteur}"><g fill-rule="evenodd" stroke-linejoin="round">' + ''.join(elements) + '</g></svg>\n'
    destination.write_text(svg, encoding='utf-8')


def travaux():
    interface = RACINE / 'assets/visual/interface'
    cadres = {
        'panneau': (28,28,600,600), 'action': (649,28,1226,600),
        'secondaire': (28,642,600,1210), 'navigation': (649,642,1226,1210),
    }
    for nom, region in cadres.items():
        yield interface/'peint/surfaces_grimoire.png', region, interface/'cadres'/(nom+'.svg'), 384
    noms = ['forge','portail','astrolabe','grimoire','couronne','parametres','gouttes','pierres','fiole']
    regions = [(0,0,418,451),(418,0,836,451),(836,0,1254,451),
               (0,451,418,840),(418,451,836,815),(836,451,1254,815),
               (0,840,418,1254),(418,815,836,1254),(836,815,1254,1254)]
    for nom, region in zip(noms, regions):
        yield interface/'peint/icones_grimoire.png', region, interface/(nom+'.svg'), 320
    bijoux = ['anneau_azur','anneau_amethyste','pendentif_azur','anneau_givre','anneau_ambre','pendentif_lune','anneau_emeraude','pendentif_soleil']
    for index, nom in enumerate(bijoux):
        x, y = (index % 4)*313.5, (index // 4)*313.5
        yield RACINE/'assets/visual/azur/icones.png', (round(x),round(y),round(x+313.5),round(y+313.5)), interface/'equipement'/(nom+'.svg'), 256
    for index, nom in enumerate(['standard','veloce','lourd','chercheur','explosif']):
        if index == 0:
            yield RACINE/'assets/visual/manga/baguette_atelier.png', (0,0,512,512), interface/'armes/standard.svg', 256
        else:
            x, y = (index % 3)*512, (index // 3)*512
            yield RACINE/'assets/visual/atelier/armes.png', (x,y,x+512,y+512), interface/'armes'/(nom+'.svg'), 256
    texte = (RACINE/'scripts/presentation/icones_arcane.gd').read_text()
    identifiants = ast.literal_eval(re.search(r'const IDENTIFIANTS := (\[.*?\])', texte, re.S).group(1))
    for index, nom in enumerate(identifiants):
        if nom.startswith('navigation_') or nom in ['parametres','gouttes','pierres']:
            continue
        source = RACINE/f'assets/visual/manga/icones_{index//30}.png'
        local = index % 30
        y0, hauteur = (70,204) if index < 30 else (0,229)
        x, y = (local % 6)*229, y0+(local // 6)*hauteur
        yield source, (x,y,x+229,y+hauteur), RACINE/'assets/visual/azur/glyphes'/(nom+'.svg'), 256


if __name__ == '__main__':
    arguments = argparse.ArgumentParser()
    arguments.add_argument('--nom', help='Limiter la regeneration a un nom de fichier.')
    options = arguments.parse_args()
    for source, region, destination, resolution in travaux():
        if options.nom and destination.stem != options.nom:
            continue
        vectoriser(source, region, destination, resolution)
        print(destination.relative_to(RACINE), flush=True)
