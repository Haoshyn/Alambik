"""Palette Charbon vegetal des surfaces, independante des icones."""
import xml.etree.ElementTree as ET


def melanger(a, b, proportion):
    composantes_a = [int(a[i:i + 2], 16) for i in (1, 3, 5)]
    composantes_b = [int(b[i:i + 2], 16) for i in (1, 3, 5)]
    return '#' + ''.join(f'{round(x * (1 - proportion) + y * proportion):02x}'
                         for x, y in zip(composantes_a, composantes_b))


def appliquer(dossier):
    ET.register_namespace('', 'http://www.w3.org/2000/svg')
    clair, sombre, metal = '#829e8b', '#3d5749', '#bdc6af'
    degrades = {
        'email': [clair, melanger(clair, sombre, .55), sombre],
        'profond': [melanger(sombre, '#232925', .12), melanger(sombre, '#19201c', .48)],
        'bronze': [melanger(metal, '#f2eee2', .5), metal, melanger(metal, sombre, .52), metal],
        'ivoire': [melanger(metal, '#f2efe5', .8), melanger(metal, '#dbdbcf', .6)],
        'verre': [melanger(clair, '#e0e8dc', .7), clair, sombre],
        'ambre': [melanger(clair, '#e8ebdc', .8), clair, melanger(clair, sombre, .6), sombre],
    }
    for fichier in dossier.glob('*.svg'):
        arbre = ET.parse(fichier)
        for noeud in arbre.iter():
            for attribut, valeur in list(noeud.attrib.items()):
                if valeur.startswith('#') and len(valeur) == 7:
                    luminosite = sum(int(valeur[i:i + 2], 16) for i in (1, 3, 5)) / 765
                    noeud.set(attribut, melanger(sombre, melanger(metal, '#f1f2e8', .65), luminosite))
        for noeud in arbre.iter():
            if noeud.get('id') in degrades:
                for palier, couleur in zip(noeud, degrades[noeud.get('id')]):
                    palier.set('stop-color', couleur)
        arbre.write(fichier, encoding='unicode')
