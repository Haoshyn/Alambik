"""Surfaces modulaires et adaptation des SVG fournis dans SVG/."""
from pathlib import Path
import copy
import json
import hashlib
import re
import xml.etree.ElementTree as ET

RACINE = Path(__file__).resolve().parents[1]
INTERFACE = RACINE / 'assets/visual/interface'
NS = '{http://www.w3.org/2000/svg}'


def generer(ecrire):
    cadrages = json.loads((RACINE / "tools/sources_email/cadrages_wenrexa.json").read_text())
    # Les silhouettes originales restent dans SVG/ ; seules les copies sont colorees.
    def icone(destination, source, matiere='ivoire', indice=0):
        racine = ET.parse(RACINE / 'SVG' / f'Wenrexa {source}.svg').getroot()
        vue = cadrages[source]
        facteur = 94 / max(vue[2:])
        x = 60 - vue[2] * facteur / 2 - vue[0] * facteur
        y = 58 - vue[3] * facteur / 2 - vue[1] * facteur
        chemins = []
        for enfant in racine:
            if enfant.tag == NS + 'defs':
                continue
            for noeud in enfant.iter():
                for attribut in ['class', 'id', 'data-name', 'style']:
                    noeud.attrib.pop(attribut, None)
                if noeud.tag == NS + 'path':
                    noeud.set('fill', f'url(#{matiere})')
                    noeud.set('fill-rule', 'evenodd')
            chemins.append(ET.tostring(enfant, encoding='unicode'))
        dessin = ''.join(chemins)
        ombres = []
        reflets = []
        for texte in chemins:
            forme = ET.fromstring(texte)
            reflet = copy.deepcopy(forme)
            for noeud in forme.iter():
                if noeud.tag == NS + 'path':
                    noeud.set('fill', '#183447')
                    noeud.set('stroke', '#183447')
                    noeud.set('stroke-width', '2')
            for noeud in reflet.iter():
                if noeud.tag == NS + 'path':
                    noeud.set('fill', 'none')
                    noeud.set('stroke', '#fff4d9')
                    noeud.set('stroke-width', '1.2')
            ombres.append(ET.tostring(forme, encoding='unicode'))
            reflets.append(ET.tostring(reflet, encoding='unicode'))
        corps = f'<g transform="translate({x:g} {y + 1.5:g}) scale({facteur:g})">' + ''.join(ombres) + '</g>'
        corps += f'<g transform="translate({x:g} {y:g}) scale({facteur:g})">' + dessin + '<g opacity=".48">' + ''.join(reflets) + '</g></g>'
        ecrire(destination, corps)

    navigation = {
        'forge': ('Armor 1 + Body', 'argent'), 'portail': ('Special magic', 'verre'),
        'grimoire': ('Notepad', 'ivoire'), 'astrolabe': ('Spiritual magic', 'bronze'),
        'heros': ("Wizard's Cap", 'violet'), 'couronne': ('Helmet', 'bronze'),
        'gouttes': ('Drop Water or Blood', 'verre'), 'pierres': ('Resources', 'violet'),
        'fiole': ('Potion', 'verre'), 'mine': ('Pickaxe', 'argent'),
        'epreuves': ('Swords', 'bronze'),
    }
    for nom, (source, matiere) in navigation.items():
        icone(INTERFACE / f'{nom}.svg', source, matiere)
    for fichier in sorted((INTERFACE / 'equipement').glob('*.svg')):
        matiere = 'violet' if any(v in fichier.stem for v in ['amethyste', 'lune']) else 'bronze' if any(v in fichier.stem for v in ['ambre', 'soleil']) else 'verre'
        icone(fichier, 'Ring' if fichier.stem.startswith('anneau') else 'Necklace', matiere)

    familles = [
        ('Money Gold 1', 'bronze', 'abondance fortune avidite'),
        ('Cargo Bag', 'bronze', 'collecte reserve_ultime'),
        ('Feather', 'ivoire', 'air celerite elan sceau_celerite trajectoire'),
        ('Shield', 'argent', 'armure bastion egide rempart rempart_initial dernier_rempart sceau_garde'),
        ('Armor 2 + Body', 'argent', 'carapace colosse constitution robustesse peau_de_pierre'),
        ('Battle magic', 'bronze', 'audace courageux puissance sceau_furie domination'),
        ('Fire 1', 'bronze', 'feu barrage_de_braise meteores'),
        ('Lightning', 'verre', 'cadence cadence_febrile impulsion_foudroyante orbes_chargees rythme'),
        ('Potion', 'verre', 'catalyse distillation echo_alchimique heritage_reactif onde_alchimique'),
        ('Special magic', 'violet', 'chaine_alchimique fragmentation grand_oeuvre transmutation_totale spirale'),
        ('Water', 'verre', 'eau'),
        ('Healing magic', 'verre', 'elan_vital regeneration vitalite seconde_chance immortel'),
        ('Shoes', 'argent', 'endurance'),
        ('Fire 2', 'bronze', 'explosion_corrosive'),
        ('Mascot', 'ivoire', 'familier_gardien familier_tireur'),
        ('Hand + Glove', 'bronze', 'force frappe_lourde'),
        ('Bow', 'argent', 'homing precision sceau_portee'),
        ('Spiritual magic', 'ivoire', 'lumiere philosophe prescience sagesse temps_suspendu'),
        ('Armor 1 + Body', 'argent', 'mannequin'),
        ('Sickle', 'violet', 'moisson_vitale'),
        ('Winter', 'verre', 'nova_de_givre sang_froid'),
        ('Hand Gesture of Power', 'verre', 'onde_de_choc zone_heros'),
        ('Arrow', 'argent', 'perforation trait_transpercant'),
        ('Double Dagger', 'argent', 'ricochet riposte_alchimique'),
        ('Swords', 'bronze', 'salve tir_multiple'),
        ('Inkwell with pen', 'ivoire', 'savoir'),
        ('Necromanty magic', 'violet', 'sceau_ruine tenebres'),
        ('Drop Water or Blood', 'violet', 'soif_de_sang'),
        ('Preparing for an attack', 'verre', 'tempete'),
        ('Earh magic', 'bronze', 'terre'),
    ]
    for source, matiere, noms in familles:
        for indice, nom in enumerate(noms.split()):
            icone(RACINE / 'assets/visual/azur/glyphes' / f'{nom}.svg', source, matiere, indice)

    # Les motifs tiennent dans les coins de 40 px ; les bandes centrales restent lisses.
    def surface(nom, matiere='profond', genre='panneau', actif=False, enfonce=False):
        bouton = genre == 'bouton'
        contour = ('M40 5H88C112 5 124 23 124 44V84C124 108 109 124 87 124H40C17 124 4 107 4 84V44C4 20 17 5 40 5Z'
                   if bouton else 'M35 5H91Q104 5 116 2Q122 16 123 35V92Q122 112 124 123Q106 120 91 123H36Q17 124 4 119Q8 103 5 90V36Q3 18 10 8Q22 3 35 5Z')
        creux = ('M40 24H88C101 24 106 33 106 45V83C106 97 99 104 86 104H41C27 104 22 96 22 83V45C22 32 28 24 40 24Z'
                 if bouton else 'M38 23H90Q102 20 106 33V91Q109 105 94 105H36Q20 108 23 92V38Q20 21 38 23Z')
        corps = f'<path d="{contour}" transform="translate(0 3)" fill="#102a3c" opacity=".65"/>'
        corps += f'<path d="{contour}" fill="url(#bronze)" stroke="#654b31" stroke-width="2"/>'
        corps += f'<path d="{contour}" transform="translate(5 5) scale(.922)" fill="url(#email)" stroke="#12394d" stroke-width="2"/>'
        # Canal d'email epais : plusieurs reflets larges remplacent le double filet fin.
        corps += '<path d="M37 12H89M12 38V87" fill="none" stroke="#a4eade" stroke-width="4" stroke-linecap="round"/>'
        corps += '<path d="M39 116H87M116 39V86" fill="none" stroke="#0d3a50" stroke-width="5" stroke-linecap="round"/>'
        corps += f'<path d="{creux}" fill="url(#{matiere})" stroke="#16394a" stroke-width="6"/>'
        corps += f'<path d="{creux}" fill="none" stroke="url(#bronze)" stroke-width="3"/>'
        corps += '<path d="M12 35Q10 14 32 12M96 115Q115 116 116 96" fill="none" stroke="#d4fff0" stroke-width="3" stroke-linecap="round"/>'
        # Bec verseur asymetrique en bronze, reconnaissable meme sur une petite case.
        corps += '<path d="M89 6Q104 10 124 2Q118 12 117 22L108 36Q105 24 94 24L99 16L89 18Z" fill="url(#bronze)" stroke="#705039" stroke-width="1.5"/>'
        corps += '<path d="M100 13L117 7L109 20" fill="none" stroke="#fff3c9" stroke-width="2.5" stroke-linecap="round"/>'
        corps += '<path d="M106 26Q96 33 99 38Q101 42 105 38Q108 34 106 26Z" fill="url(#verre)" stroke="#bcf9e8" stroke-width="1"/>'
        # Une lentille ambree sert de signature a la place d'une gemme minuscule.
        corps += '<circle cx="22" cy="106" r="17" fill="#173746"/><circle cx="22" cy="104" r="15" fill="url(#bronze)" stroke="#80603e" stroke-width="1"/><circle cx="22" cy="104" r="10.5" fill="url(#ambre)" stroke="#6e4b2b" stroke-width="1"/><ellipse cx="19" cy="100" rx="4" ry="3" fill="#fff4cc" opacity=".85"/>'
        corps += '<circle cx="13" cy="34" r="2.5" fill="#87e4db"/><circle cx="115" cy="94" r="2" fill="#87e4db"/>'
        if actif:
            corps += f'<path d="{contour}" fill="none" stroke="#a9fff0" stroke-width="3"/>'
        if enfonce:
            corps += f'<path d="{creux}" fill="#133046" opacity=".32"/>'
        # Des surfaces de lecture claires gardent un centre calme sans texture ni rune.
        ecrire(INTERFACE / 'cadres' / f'{nom}.svg', corps, '0 0 128 128', (128, 128))

    for nom, matiere, genre in [
        ('panneau', 'ivoire', 'lecture'), ('zone_texte', 'ivoire', 'lecture'),
        ('saisie', 'ivoire', 'saisie'), ('action', 'email', 'bouton'),
        ('secondaire', 'profond', 'bouton'), ('navigation', 'profond', 'panneau'),
        ('conteneur', 'profond', 'panneau'), ('bandeau', 'profond', 'bouton'),
        ('compteur', 'profond', 'saisie'), ('case', 'profond', 'case'),
        ('carte', 'profond', 'carte'), ('medaillon', 'profond', 'case'),
    ]:
        surface(nom, matiere, genre)
    surface('case_selection', 'email', 'case', actif=True)
    surface('carte_selection', 'email', 'carte', actif=True)
    surface('action_pressee', 'email', 'bouton', enfonce=True)
    surface('secondaire_pressee', 'profond', 'bouton', enfonce=True)
    surface('saisie_focus', 'ivoire', 'saisie', actif=True)

    # Ces options seront appliquees au prochain import par l'editeur du proprietaire.
    modele = (INTERFACE / 'cadres/action.svg.import').read_text()
    for fichier in (INTERFACE / 'cadres').glob('*.svg'):
        destination = Path(str(fichier) + '.import')
        if destination.exists():
            continue
        source = 'res://' + fichier.relative_to(RACINE).as_posix()
        cache = f'res://.godot/imported/{fichier.name}-{hashlib.md5(source.encode()).hexdigest()}.ctex'
        options = re.sub(r'^uid=.*\n', '', modele, flags=re.M)
        options = re.sub(r'res://\.godot/imported/[^"\n]+', cache, options)
        options = re.sub(r'source_file="[^"]+"', f'source_file="{source}"', options)
        destination.write_text(options)

    for nom, actif in [('rond', False), ('rond_selection', True)]:
        corps = '<circle cx="64" cy="64" r="60" fill="url(#bronze)"/><circle cx="64" cy="64" r="55" fill="url(#email)"/><circle cx="64" cy="64" r="47" fill="url(#profond)" stroke="url(#bronze)" stroke-width="2"/><path d="M17 45A51 51 0 0 1 92 20" fill="none" stroke="#bcf4e5" stroke-width="2"/><circle cx="25" cy="106" r="12" fill="url(#bronze)"/><circle cx="25" cy="106" r="8" fill="url(#ambre)"/>'
        if actif:
            corps += '<circle cx="64" cy="64" r="61" fill="none" stroke="#a3fff1" stroke-width="3"/>'
        ecrire(INTERFACE / 'cadres' / f'{nom}.svg', corps, '0 0 128 128', (256, 256))

    # Conserver la palette retenue lors des prochaines regenerations du kit.
    from palette_cadres import appliquer
    appliquer(INTERFACE / 'cadres')
