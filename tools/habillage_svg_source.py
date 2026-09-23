"""Surfaces modulaires et adaptation des SVG fournis dans SVG/."""
from pathlib import Path
import json
import hashlib
import re
import xml.etree.ElementTree as ET
from generer_icones import MOTIFS, AJOUTS

RACINE = Path(__file__).resolve().parents[1]
INTERFACE = RACINE / 'assets/visual/interface'
NS = '{http://www.w3.org/2000/svg}'


def generer(ecrire):
    cadrages = json.loads((RACINE / "tools/sources_email/cadrages_wenrexa.json").read_text())
    # Les contours fournis gardent leur identite ; l'ombre et les reflets restent discrets.
    details = {
        'mine': '<path d="M25 105 94 12M36 87l8 5M43 77l8 5" fill="none" stroke="#f0e9dd" stroke-opacity=".48" stroke-width="1.2" stroke-linecap="round"/>',
        'grimoire': '<path d="M47 44q15-4 33 1M47 55q17-4 33 1M49 68q10-3 22 0" fill="none" stroke="#9caed0" stroke-opacity=".7" stroke-width="1.2" stroke-linecap="round"/><path d="M85 73l4 5 5-5" fill="none" stroke="#85cbd7" stroke-width="1.3"/>',
        'gouttes': '<path d="M55 35q-12 20-14 34" fill="none" stroke="#efffff" stroke-opacity=".65" stroke-width="2.2" stroke-linecap="round"/>',
        'epreuves': '<path d="M38 30 88 80M88 30 40 80" fill="none" stroke="#fff2dd" stroke-opacity=".38" stroke-width="1.5" stroke-linecap="round"/>',
        'forge': '<path d="M42 75h36M49 88h22" fill="none" stroke="#f5f8ff" stroke-opacity=".3" stroke-width="1.4"/>',
        'fiole': '<path d="M39 76q20 8 42 0M53 88h16" fill="none" stroke="#dcfaff" stroke-opacity=".6" stroke-width="1.5"/>',
        'pierres': '<path d="M38 79 52 60l14 15 17-24" fill="none" stroke="#eee5f9" stroke-opacity=".35" stroke-width="1.3"/>',
    }

    bijoux = {
        'anneau_azur': '<path d="M44 22Q35 33 44 43Q53 34 44 22Z" fill="#3c8fae" stroke="#e3ffff" stroke-width="1.4"/><path d="M43 25q-5 8-2 12" fill="none" stroke="#d8fcff" stroke-opacity=".8" stroke-width="1.2"/>',
        'anneau_amethyste': '<path d="M45 22 54 32 44 43 35 32Z" fill="url(#violet)" stroke="#f7eaff" stroke-opacity=".85" stroke-width="1.3"/><path d="M35 32h19M45 22v21" stroke="#faf5ff" stroke-opacity=".38" stroke-width=".8"/>',
        'anneau_givre': '<path d="M44 21 49 29 57 32 49 36 44 44 39 36 31 32 39 29Z" fill="url(#givre)" stroke="#f5ffff" stroke-width="1.1"/>',
        'anneau_ambre': '<ellipse cx="44" cy="32" rx="10" ry="12" fill="url(#ambre)" stroke="#f8e9ce" stroke-width="1.2"/><path d="M40 27q2-3 5-3" fill="none" stroke="#fff7e3" stroke-opacity=".7" stroke-width="1.2"/>',
        'anneau_emeraude': '<path d="M44 21 54 29 50 40 44 44 38 40 34 29Z" fill="url(#emeraude)" stroke="#e8fff2" stroke-width="1.2"/><path d="M34 29h20M44 21v23" fill="none" stroke="#f5fff8" stroke-opacity=".42" stroke-width=".8"/>',
        'pendentif_azur': '<path d="M60 68q-10 12 0 24 10-12 0-24Z" fill="none" stroke="#d6f6fa" stroke-opacity=".9" stroke-width="1.6"/><path d="M50 83q10 5 20 0" fill="none" stroke="#d6f6fa" stroke-opacity=".75" stroke-width="1.1"/>',
        'pendentif_lune': '<path d="M66 68q-14 6-8 22 5 10 17 8-15-5-12-19Z" fill="url(#ivoire)" stroke="#f4eaff" stroke-opacity=".7" stroke-width="1"/>',
        'pendentif_soleil': '<circle cx="60" cy="82" r="8" fill="url(#soleil)" stroke="#fff5dc" stroke-width="1"/><path d="M60 67v5M60 92v5M45 82h5M70 82h5M49 71l4 4M67 89l4 4M71 71l-4 4M53 89l-4 4" fill="none" stroke="#fff3d3" stroke-opacity=".8" stroke-width="1.2" stroke-linecap="round"/>',
    }

    def icone(destination, source, matiere='ivoire', indice=0):
        racine = ET.parse(RACINE / 'SVG' / f'Wenrexa {source}.svg').getroot()
        vue = cadrages[source]
        facteur = 98 / max(vue[2:])
        x = 60 - vue[2] * facteur / 2 - vue[0] * facteur
        y = 59 - vue[3] * facteur / 2 - vue[1] * facteur
        chemins = [noeud.get('d') for noeud in racine.iter()
                   if noeud.tag == NS + 'path' and noeud.get('d')]
        if not chemins:
            raise ValueError(f'Silhouette vide : {source}')
        if destination.parent.name == 'glyphes':
            nom = destination.stem
            if nom not in MOTIFS:
                raise ValueError(f'Motif unique manquant : {nom}')
            facteur_glyphe = 83 / max(vue[2:])
            x_glyphe = 64 - vue[2] * facteur_glyphe / 2 - vue[0] * facteur_glyphe
            y_glyphe = 64 - vue[3] * facteur_glyphe / 2 - vue[1] * facteur_glyphe
            silhouette = ''.join(f'<path d="{trace}" fill="url(#{matiere})" fill-rule="evenodd"/>'
                                 for trace in chemins)
            signe = f'<path d="{MOTIFS[nom]}"/>' + AJOUTS.get(nom, '')
            corps = (f'<g opacity=".22" transform="translate({x_glyphe:g} {y_glyphe:g}) '
                     f'scale({facteur_glyphe:g})">' + silhouette + '</g>')
            corps += (f'<g fill="none" stroke="#14213c" stroke-width="8" '
                      'stroke-linecap="round" stroke-linejoin="round" '
                      f'transform="translate(0 1.5)">{signe}</g>')
            corps += (f'<g fill="none" stroke="url(#{matiere})" stroke-width="4.8" '
                      f'stroke-linecap="round" stroke-linejoin="round">{signe}</g>')
            ecrire(destination, corps, '0 0 128 128')
            return
        ombre = ''.join(f'<path d="{trace}" fill="#172242" fill-rule="evenodd"/>'
                        for trace in chemins)
        forme = ''.join(
            f'<path d="{trace}" fill="url(#{matiere})" fill-rule="evenodd" '
            'stroke="#354264" stroke-width=".65" stroke-linejoin="round"/>'
            for trace in chemins)
        decoupe = ''.join(f'<path d="{trace}" fill-rule="evenodd"/>' for trace in chemins)
        corps = (f'<defs><clipPath id="silhouette"><g transform="translate({x:g} {y:g}) scale({facteur:g})">'
                 + decoupe + '</g></clipPath></defs>')
        corps += (f'<g transform="translate({x + 1.5:g} {y + 3:g}) scale({facteur:g})" opacity=".28">'
                  + ombre + '</g>')
        corps += f'<g transform="translate({x:g} {y:g}) scale({facteur:g})">' + forme + '</g>'
        corps += ('<g clip-path="url(#silhouette)"><path d="M0 60H120V120H0Z" '
                  'fill="#203458" opacity=".1"/><ellipse cx="37" cy="22" rx="63" ry="55" '
                  'fill="url(#eclat)" opacity=".55"/></g>')
        corps += details.get(destination.stem, '')
        corps += bijoux.get(destination.stem, '')
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

    # Les coins restent dans 40 px pour conserver le trait lors de l'etirement.
    def surface(nom, matiere='profond', genre='panneau', actif=False, enfonce=False):
        if genre == 'bouton':
            contour = 'M28 5H88Q103 5 112 17L123 29V99Q123 123 99 123H28Q5 123 5 100V28Q5 5 28 5Z'
            interieur = 'M30 13H88Q100 13 107 23L115 31V98Q115 115 98 115H30Q13 115 13 98V30Q13 13 30 13Z'
        elif genre in ('case', 'carte'):
            contour = 'M27 5H93L123 35V100Q123 123 100 123H27Q5 123 5 101V27Q5 5 27 5Z'
            interieur = 'M29 13H89L115 39V98Q115 115 98 115H29Q13 115 13 99V29Q13 13 29 13Z'
        else:
            contour = 'M28 5H100Q123 5 123 28V100Q123 123 100 123H28Q5 123 5 100V28Q5 5 28 5Z'
            interieur = 'M30 13H98Q115 13 115 30V98Q115 115 98 115H30Q13 115 13 98V30Q13 13 30 13Z'
        corps = f'<path d="{contour}" transform="translate(0 3)" fill="#101b39" opacity=".34"/>'
        corps += f'<path d="{contour}" fill="url(#bronze)" stroke="#5c607d" stroke-width="1.1"/>'
        corps += f'<path d="{interieur}" fill="url(#{matiere})" stroke="#233354" stroke-width="1.1"/>'
        corps += ('<path d="M29 12H86Q100 12 108 23M12 31V83" fill="none" '
                  'stroke="#f4f1ed" stroke-width="1.6" stroke-opacity=".48" stroke-linecap="round"/>')
        corps += ('<path d="M29 112H98Q112 112 112 98" fill="none" '
                  'stroke="#182544" stroke-width="2" stroke-opacity=".65" stroke-linecap="round"/>')
        corps += ('<path d="M35 19H84M20 40V77" fill="none" '
                  'stroke="#e8e2f0" stroke-opacity=".22" stroke-width="1"/>')
        corps += ('<path d="M103 16l9 9M18 101l8 8" fill="none" '
                  'stroke="#e9d6b7" stroke-opacity=".7" stroke-width="1.5" stroke-linecap="round"/>')
        if actif:
            corps += f'<path d="{interieur}" fill="none" stroke="#9bcdda" stroke-width="1.7" stroke-opacity=".8"/>'
        if enfonce:
            corps += f'<path d="{interieur}" fill="#182446" opacity=".18"/>'
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
        corps = '<circle cx="64" cy="67" r="59" fill="#101a36" opacity=".33"/>'
        corps += '<circle cx="64" cy="63" r="59" fill="url(#bronze)" stroke="#5a6080" stroke-width="1"/>'
        corps += '<circle cx="64" cy="63" r="54" fill="url(#profond)" stroke="#2e3c60" stroke-width="1"/>'
        corps += '<circle cx="64" cy="63" r="49" fill="none" stroke="#b6c3da" stroke-opacity=".34" stroke-width="1.5"/>'
        corps += '<path d="M26 42A43 43 0 0 1 97 34M29 99A43 43 0 0 0 93 100" fill="none" stroke="#f6f5f0" stroke-opacity=".42" stroke-width="1.8" stroke-linecap="round"/>'
        corps += '<path d="M64 12v5M112 63h-5" fill="none" stroke="#e9d6b7" stroke-opacity=".8" stroke-width="2" stroke-linecap="round"/>'
        if actif:
            corps += '<circle cx="64" cy="63" r="51" fill="none" stroke="#9bcdda" stroke-width="2" stroke-opacity=".8"/>'
        ecrire(INTERFACE / 'cadres' / f'{nom}.svg', corps, '0 0 128 128', (256, 256))

    # Conserver la palette retenue lors des prochaines regenerations du kit.
    from palette_cadres import appliquer
    appliquer(INTERFACE / 'cadres')
