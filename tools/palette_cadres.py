"""Palette bleu-violet des surfaces du kit Email arcanique."""
from pathlib import Path
import xml.etree.ElementTree as ET


# Les deux generations de sources restent convertibles sans changer les formes.
COULEURS_FIXES = {
    '#102a3c': '#283457', '#748678': '#283457',
    '#654b31': '#786b91', '#819284': '#786b91',
    '#12394d': '#40547f', '#0d3a50': '#394e79',
    '#16394a': '#354872', '#788a7c': '#354872',
    '#a4eade': '#d8e5ff', '#b3bdaf': '#d8e5ff',
    '#d4fff0': '#f8f1e5', '#bfc7b8': '#f8f1e5',
    '#705039': '#746483', '#849486': '#746483',
    '#fff3c9': '#fff3de', '#bec6b7': '#fff3de',
    '#bcf9e8': '#91deef', '#bac3b4': '#91deef',
    '#173746': '#303a66', '#77897b': '#303a66',
    '#80603e': '#827299', '#89998a': '#827299',
    '#6e4b2b': '#715b7d', '#829284': '#715b7d',
    '#fff4cc': '#fff5e5', '#bec7b8': '#fff5e5',
    '#87e4db': '#a1e1f1', '#afb9ab': '#a1e1f1',
    '#a9fff0': '#b5e8f5', '#b9c2b4': '#b5e8f5',
    '#133046': '#283457', '#76887a': '#283457',
    '#bcf4e5': '#e7ebff', '#b9c2b3': '#e7ebff',
    '#a3fff1': '#b5e8f5',
    '#244c41': '#283457', '#846342': '#786b91',
    '#315b50': '#40547f', '#28554e': '#394e79',
    '#2b554c': '#354872', '#bde8d9': '#d8e5ff',
    '#f0f3d9': '#f8f1e5', '#87613f': '#746483',
    '#fff0c9': '#fff3de', '#9fe6d7': '#91deef',
    '#2d4b42': '#303a66', '#9b744b': '#827299',
    '#805638': '#715b7d', '#fff4d6': '#fff5e5',
    '#9beadf': '#a1e1f1', '#a9eeda': '#b5e8f5',
    '#1e4742': '#283457', '#d7f1d9': '#e7ebff',
}

DEGRADES = {
    'bronze': ['#eee7f5', '#b9abc9', '#716386', '#b9aac7'],
    'email': ['#5a70a1', '#425b8d', '#2c4170'],
    'profond': ['#374a77', '#253459'],
    'ivoire': ['#faf8ff', '#e3e5f6'],
    'violet': ['#d8c9f6', '#9b7bcf', '#625297'],
    'argent': ['#e5edff', '#adbee1', '#6c82ae'],
    'ambre': ['#fff3d8', '#e3c38d', '#b1895d', '#765a59'],
    'verre': ['#e2fbff', '#8bdef0', '#4398bb'],
}

LECTURE = {'panneau', 'zone_texte', 'saisie', 'saisie_focus'}
ACTIONS = {'action', 'action_pressee'}
SELECTIONS = {'case_selection', 'carte_selection', 'rond_selection'}
BARRES = {'navigation', 'bandeau', 'compteur'}


def appliquer(dossier):
    ET.register_namespace('', 'http://www.w3.org/2000/svg')
    for fichier in sorted(dossier.glob('*.svg')):
        degrades = {nom: couleurs[:] for nom, couleurs in DEGRADES.items()}
        if fichier.stem in LECTURE:
            degrades['email'] = ['#a9b5dc', '#798cc0', '#485c91']
        elif fichier.stem in ACTIONS:
            degrades['email'] = ['#7659ad', '#5d469c', '#413478']
        elif fichier.stem in SELECTIONS:
            degrades['email'] = ['#8e76c7', '#654ea9', '#433b82']
        elif fichier.stem in BARRES:
            degrades['email'] = ['#506691', '#384c7a', '#29385e']
            degrades['profond'] = ['#34456f', '#202d51']

        arbre = ET.parse(fichier)
        for noeud in arbre.iter():
            for attribut, valeur in list(noeud.attrib.items()):
                couleur = COULEURS_FIXES.get(valeur.lower())
                if couleur is not None:
                    noeud.set(attribut, couleur)
            couleurs = degrades.get(noeud.get('id'))
            if couleurs is not None:
                for palier, couleur in zip(noeud, couleurs):
                    palier.set('stop-color', couleur)
        arbre.write(fichier, encoding='unicode')


if __name__ == '__main__':
    appliquer(Path(__file__).resolve().parents[1] / 'assets/visual/interface/cadres')
