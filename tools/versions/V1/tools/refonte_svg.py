"""Illustrations SVG originales du kit, gardees en fichiers independants.

Les formes des pictogrammes sont construites ici ; SVG/ reste une reference
historique et n'est pas insere dans les ressources actives.
"""
from pathlib import Path
from generer_icones import MOTIFS
from signatures_svg import SIGNES

RACINE = Path(__file__).resolve().parents[1]
INTERFACE = RACINE / 'assets/visual/interface'
GLYPHES = RACINE / 'assets/visual/azur/glyphes'
MODELES = RACINE / 'tools/design_svg'

DEFS = '''<defs>
<linearGradient id="acier" x1=".08" y1="0" x2=".86" y2="1"><stop stop-color="#fff9eb"/><stop offset=".22" stop-color="#d8e5ed"/><stop offset=".55" stop-color="#8ea8c3"/><stop offset=".8" stop-color="#577395"/><stop offset="1" stop-color="#b7c9d3"/></linearGradient>
<linearGradient id="or" x1="0" y1="0" x2="1" y2="1"><stop stop-color="#fff2cd"/><stop offset=".43" stop-color="#d5b891"/><stop offset="1" stop-color="#776884"/></linearGradient>
<linearGradient id="violet" x1=".12" y1="0" x2=".8" y2="1"><stop stop-color="#f4eafc"/><stop offset=".46" stop-color="#b5a1d4"/><stop offset="1" stop-color="#645b9b"/></linearGradient>
<linearGradient id="turquoise" x1=".13" y1="0" x2=".78" y2="1"><stop stop-color="#e6fff9"/><stop offset=".4" stop-color="#8bdce3"/><stop offset="1" stop-color="#3e80ab"/></linearGradient>
<linearGradient id="vert" x1=".15" y1="0" x2=".8" y2="1"><stop stop-color="#efffee"/><stop offset=".42" stop-color="#a4ddba"/><stop offset="1" stop-color="#4b947e"/></linearGradient>
<linearGradient id="ambre" x1=".12" y1="0" x2=".88" y2="1"><stop stop-color="#fff6dc"/><stop offset=".45" stop-color="#f3c487"/><stop offset="1" stop-color="#ae6680"/></linearGradient>
<linearGradient id="cuir" x1=".12" y1="0" x2=".88" y2="1"><stop stop-color="#bd9c84"/><stop offset=".55" stop-color="#856c78"/><stop offset="1" stop-color="#443f68"/></linearGradient>
<linearGradient id="nuit" x1="0" y1="0" x2=".35" y2="1"><stop stop-color="#52628d"/><stop offset=".42" stop-color="#31436f"/><stop offset="1" stop-color="#182950"/></linearGradient>
<linearGradient id="email" x1="0" y1="0" x2=".2" y2="1"><stop stop-color="#8c77b4"/><stop offset=".47" stop-color="#655b9b"/><stop offset="1" stop-color="#3e4277"/></linearGradient>
<linearGradient id="papier" x1=".15" y1="0" x2=".75" y2="1"><stop stop-color="#fff9e9"/><stop offset=".53" stop-color="#e9e4e0"/><stop offset="1" stop-color="#bcc9d8"/></linearGradient>
<radialGradient id="lueur"><stop stop-color="#c5f7f5" stop-opacity=".38"/><stop offset="1" stop-color="#c5f7f5" stop-opacity="0"/></radialGradient>
</defs>'''


def ecrire(destination: Path, corps: str, vue='0 0 120 120', taille=(384, 384)):
    destination.parent.mkdir(parents=True, exist_ok=True)
    destination.write_text(
        f'<svg xmlns="http://www.w3.org/2000/svg" width="{taille[0]}" '
        f'height="{taille[1]}" viewBox="{vue}">{DEFS}{corps}</svg>\n', encoding='utf-8')


def modele(nom: str, destination: Path):
    destination.parent.mkdir(parents=True, exist_ok=True)
    destination.write_text((MODELES / f'{nom}.svg').read_text(encoding='utf-8'), encoding='utf-8')


def p(d, fill, stroke='#354568', w=1.5, extra=''):
    return f'<path d="{d}" fill="{fill}" stroke="{stroke}" stroke-width="{w}" stroke-linejoin="round" {extra}/>'


def trait(d, couleur='#f6f5eb', w=1.5, alpha=1):
    return f'<path d="{d}" fill="none" stroke="{couleur}" stroke-width="{w}" stroke-opacity="{alpha}" stroke-linecap="round" stroke-linejoin="round"/>'


def eclat(x, y, r=5, couleur='#d8fff8'):
    return p(f'M{x} {y-r}l{r*.27:g} {r*.73:g}L{x+r} {y}l{-r*.73:g} {r*.27:g}L{x} {y+r}l{-r*.27:g} {-r*.73:g}L{x-r} {y}l{r*.73:g} {-r*.27:g}Z', couleur, 'none', 0)


def navigation():
    for nom in ('mine', 'epreuves', 'grimoire'):
        modele(nom, INTERFACE / f'{nom}.svg')
    corps = {}
    # La forge se lit comme un plastron, et non comme une armure generique plaquee.
    corps['forge'] = (
        '<ellipse cx="60" cy="58" rx="43" ry="43" fill="url(#lueur)"/>'
        + p('M39 21 48 17Q60 30 72 17L81 21 102 37 93 62 84 58 84 103H36V58L27 62 18 37Z', 'url(#acier)', '#344465', 2)
        + p('M39 27 25 39 29 53 38 48ZM81 27 95 39 91 53 82 48Z', 'url(#nuit)', '#899bb7', 1.3)
        + p('M46 29Q60 37 74 29L78 53 60 64 42 53Z', 'url(#email)', '#596382', 1.5)
        + p('M42 61 60 68 78 61 76 91H44Z', 'url(#nuit)', '#a8b9cf', 1.2)
        + p('M60 42 68 52 60 62 52 52Z', 'url(#turquoise)', '#e8e2cb', 1.2)
        + trait('M49 27Q60 34 71 27M47 75h26M47 84h26', '#fff8e9', 1.5, .65)
        + trait('M23 39 20 47M97 39l3 8M38 99h44', '#e8e3d7', 1.8, .5))
    corps['portail'] = (
        '<ellipse cx="60" cy="58" rx="45" ry="44" fill="url(#lueur)"/>'
        + p('M28 104V50Q28 16 60 16T92 50v54H80V51Q80 28 60 28T40 51v53Z', 'url(#acier)', '#384867', 1.8)
        + p('M42 98V52Q42 32 60 32T78 52v46Z', 'url(#nuit)', '#8db4ca', 1.1)
        + p('M44 94Q53 81 61 75 69 64 76 46V97H44Z', 'url(#turquoise)', 'none', 0, 'opacity=".58"')
        + '<ellipse cx="60" cy="56" rx="14" ry="21" fill="url(#lueur)"/>'
        + p('M22 104h76l-9 9H31Z', 'url(#or)', '#5e6280', 1.4)
        + trait('M32 48Q32 26 52 22M43 51v37M76 52v36', '#fff8ed', 1.8, .8)
        + eclat(62, 52, 7))
    corps['astrolabe'] = (
        '<ellipse cx="60" cy="53" rx="48" ry="43" fill="url(#lueur)"/>'
        + '<ellipse cx="60" cy="52" rx="43" ry="27" fill="none" stroke="url(#or)" stroke-width="5" transform="rotate(-24 60 52)"/>'
        + '<ellipse cx="60" cy="52" rx="23" ry="42" fill="none" stroke="url(#acier)" stroke-width="4" transform="rotate(32 60 52)"/>'
        + '<circle cx="60" cy="52" r="19" fill="url(#nuit)" stroke="#d7d0c2" stroke-width="2"/>'
        + '<circle cx="60" cy="52" r="11" fill="url(#turquoise)"/>'
        + p('M57 94h6v9h21v7H36v-7h21Z', 'url(#or)', '#575a76', 1)
        + trait('M35 26Q56 13 79 28M22 57Q35 79 58 82', '#f7f3e9', 1.7, .72)
        + eclat(60, 51, 4))
    corps['heros'] = (
        '<ellipse cx="60" cy="56" rx="43" ry="43" fill="url(#lueur)"/>'
        + p('M24 87 39 65 43 32Q56 10 68 18q5 2 6 10l6 39 17 20q-34 18-73 0Z', 'url(#email)', '#383b65', 2)
        + p('M33 86 42 69 49 77 60 82 72 77 79 69 89 86Q60 101 33 86Z', 'url(#nuit)', '#7e8fac', 1.1)
        + p('M43 42Q59 33 77 42v17Q70 74 60 77 50 74 43 59Z', 'url(#cuir)', '#353752', 1.2)
        + p('M38 41Q46 20 64 21 78 27 82 42q-18-7-44-1Z', 'url(#violet)', '#cab9d7', 1.2)
        + p('M60 30 65 37 60 44 55 37Z', 'url(#turquoise)', '#f3e6cf', 1)
        + trait('M43 46v13M77 46v13M47 84q13 8 26 0', '#f7e9e5', 1.5, .5))
    corps['couronne'] = (
        p('M18 38 39 54 59 20 81 54 102 38 95 91H25Z', 'url(#or)', '#6a5c73', 2)
        + p('M29 62 42 68 59 40 78 68 92 61 87 84H33Z', 'url(#email)', '#797494', 1)
        + p('M60 49 69 62 60 77 51 62Z', 'url(#turquoise)', '#e4d5ae', 1)
        + p('M24 88h72v12H24Z', 'url(#acier)', '#625a72', 1.5)
        + trait('M21 39 38 57M60 22 60 35M100 40 83 57M29 94h62', '#fff8e7', 1.5, .75))
    corps['gouttes'] = (
        '<ellipse cx="59" cy="64" rx="32" ry="40" fill="url(#lueur)"/>'
        + p('M60 13Q96 57 94 79 91 106 60 108 29 106 26 79 24 56 60 13Z', 'url(#turquoise)', '#41688a', 2)
        + p('M60 17Q33 62 32 79q0 21 21 26Q47 83 60 17Z', '#e9fff8', 'none', 0, 'opacity=".48"')
        + p('M60 18Q88 62 88 80q0 17-18 23Q80 70 60 18Z', '#365e93', 'none', 0, 'opacity=".46"')
        + trait('M44 74Q45 61 53 48M50 91q8 8 18 6', '#fff', 2.2, .75))
    corps['pierres'] = (
        '<ellipse cx="58" cy="65" rx="47" ry="38" fill="url(#lueur)"/>'
        + p('M15 81 33 57 57 62 63 91 43 106 21 101Z', 'url(#turquoise)', '#4c6189', 1.5)
        + p('M45 91 57 27 84 21 106 47 88 101 62 109Z', 'url(#violet)', '#484b7f', 2)
        + p('M57 27 71 58 45 91Z', '#f5eafa', 'none', 0, 'opacity=".54"')
        + p('M71 58 106 47 88 101 62 109Z', '#5f60a3', 'none', 0, 'opacity=".5"')
        + trait('M61 31 82 25 99 46M23 81 34 63', '#fff9f4', 1.8, .73)
        + eclat(72, 56, 4))
    corps['fiole'] = (
        '<ellipse cx="60" cy="74" rx="41" ry="37" fill="url(#lueur)"/>'
        + p('M47 14h26v9H47Z', 'url(#or)', '#595b73', 1.4)
        + p('M50 24h20v24q28 26 26 44-1 15-17 17H41Q25 107 24 92q-2-18 26-44Z', 'url(#papier)', '#7d91aa', 1.8, 'fill-opacity=".75"')
        + p('M33 78Q44 72 60 79 77 88 88 76l5 20-13 10H40L28 96Z', 'url(#turquoise)', '#629bb0', 1)
        + trait('M54 28v21Q40 63 36 71M43 86q7 4 14 3', '#fff', 2, .7)
        + eclat(77, 69, 6))
    corps['parametres'] = (
        '<ellipse cx="60" cy="62" rx="44" ry="44" fill="url(#lueur)"/>'
        + p('M54 13h12l3 11 11 4 10-6 9 9-5 10 4 11 11 3v12l-11 3-4 11 5 10-9 9-10-6-11 4-3 11H54l-3-11-11-4-10 6-9-9 6-10-5-11-11-3V55l11-3 5-11-6-10 9-9 10 6 11-4Z', 'url(#acier)', '#475472', 1.6)
        + '<circle cx="60" cy="61" r="27" fill="url(#nuit)" stroke="#f1e0bf" stroke-width="1.6"/>'
        + '<circle cx="60" cy="61" r="15" fill="url(#turquoise)" stroke="#849cba" stroke-width="1.6"/>'
        + trait('M48 37q12-7 24 0M48 82q12 7 24 0', '#f8f2e7', 1.6, .7))
    return corps


def controles():
    corps = {
        'fleche_gauche': p('M61 18 18 60 61 102 75 88 47 60 75 32Z', 'url(#acier)', '#4e5d7b', 2)+trait('M53 32 28 60 53 88', '#fff', 2, .68),
        'fleche_droite': p('M59 18 102 60 59 102 45 88 73 60 45 32Z', 'url(#acier)', '#4e5d7b', 2)+trait('M67 32 92 60 67 88', '#fff', 2, .68),
        'fleche_bas': p('M17 42 60 87 103 42 90 29 60 59 30 29Z', 'url(#acier)', '#4e5d7b', 2)+trait('M28 43 60 75 92 43', '#fff', 2, .65),
        'cadenas': p('M37 54V39q0-24 23-24t23 24v15H72V40q0-13-12-13T48 40v14Z', 'url(#acier)', '#4b5470', 1.6)+p('M27 51h66v57H27Z', 'url(#or)', '#615c73', 2)+p('M34 59h52v42H34Z', 'url(#nuit)', '#9fabc0', 1.2)+p('M60 67q11 0 8 11l-3 7v9H55v-9l-3-7q-3-11 8-11Z', 'url(#turquoise)', '#d5d5cf', 1),
        'pause': p('M27 19h22v83H27ZM71 19h22v83H71Z', 'url(#acier)', '#4c5877', 2)+trait('M32 25v70M76 25v70', '#fff', 1.8, .76),
        'validation': p('M17 62 44 88 103 26 92 16 44 66 27 51Z', 'url(#vert)', '#42697b', 2)+trait('M24 61 44 79 95 24', '#fff', 2, .7),
        'selection': p('M60 12 77 44 108 60 77 77 60 109 43 77 12 60 43 44Z', 'url(#or)', '#636379', 1.7)+p('M60 32 74 60 60 88 46 60Z', 'url(#turquoise)', '#f5e2bb', 1.2),
    }
    return corps


def cadres():
    modele('action', INTERFACE / 'cadres/action.svg')
    # Les silhouettes gardent leurs coins dans les 40 px fixes du 9-slice Godot.
    variantes = {
        'action': ('#816bb3', '#624b9c', '#413771', '#f2e3cd'),
        'action_depart': ('#9b7bc5', '#6d54ad', '#3c3a79', '#f6deb6'),
        'action_pressee': ('#675886', '#4f4579', '#37325f', '#cfc3c1'),
        'secondaire': ('#5976a0', '#3d5987', '#273f6b', '#d2d9db'),
        'secondaire_pressee': ('#455e86', '#344a73', '#1d3259', '#bcc6ce'),
        'secondaire_mine': ('#9d816c', '#695b68', '#34415a', '#e6c49b'),
        'secondaire_epreuves': ('#8b80b3', '#625c9b', '#384573', '#dfd2ee'),
        'bandeau': ('#5d74a3', '#435b8a', '#293f69', '#d1cec8'),
        'compteur': ('#5f7ba9', '#49628f', '#2c4571', '#c7cdcf'),
        'compteur_gouttes': ('#629bad', '#40768f', '#285372', '#add9d8'),
        'compteur_pierres': ('#9a87be', '#6d5f9f', '#41477a', '#dec8dc'),
        'conteneur': ('#5f7295', '#465b7d', '#2c4265', '#d3c9ba'),
        'carte': ('#61749a', '#455a7d', '#293e62', '#d3d2d1'),
        'carte_selection': ('#8d78ae', '#6c5c9a', '#413d76', '#efe2cf'),
        'recompense': ('#6282a0', '#416080', '#283d62', '#d4d3c2'),
        'recompense_selection': ('#a08dbd', '#705d9a', '#493d75', '#f3d9b3'),
        'case': ('#5f779d', '#405a84', '#284169', '#ccd4d5'),
        'case_selection': ('#8a7baf', '#665f9b', '#3c4a7a', '#f1e5d7'),
        'medaillon': ('#5b6a95', '#425583', '#2b3d68', '#dad2c0'),
        'panneau': ('#fff9ec', '#f4ebec', '#e1e6f1', '#d5b992'),
        'zone_texte': ('#faf9ff', '#ebedf9', '#d7e0f4', '#b7c7de'),
        'saisie': ('#f9f8f7', '#edeef0', '#d9e2ed', '#cbd0cf'),
        'saisie_focus': ('#ffffff', '#eef1fa', '#d5e1f2', '#ede1d5'),
    }
    for nom, (haut, milieu, bas, bord) in variantes.items():
        if nom == 'action_depart':
            famille = 'capsule_large'
        elif nom in ('compteur_gouttes', 'compteur_pierres'):
            famille = 'pilule'
        elif nom in ('secondaire', 'secondaire_pressee', 'secondaire_mine', 'secondaire_epreuves',
                     'bandeau', 'carte', 'carte_selection', 'case', 'case_selection'):
            famille = 'angulaire'
        elif nom in ('panneau', 'zone_texte', 'saisie', 'saisie_focus'):
            famille = 'lecture'
        elif nom in ('recompense', 'recompense_selection'):
            famille = 'recompense'
        else:
            famille = 'action'
        exemple = (MODELES / f'{famille}.svg').read_text(encoding='utf-8')
        exemple = exemple.replace('width="256" height="256"', 'width="128" height="128"')
        svg = exemple.replace('#8a77b5', haut).replace('#695a9c', milieu).replace('#3f4279', bas).replace('#faf0d4', bord)
        if nom.endswith('selection') or nom.endswith('focus'):
            trace = 'M27 16H101L112 27V101L101 112H27L16 101V27Z' if famille == 'angulaire' else 'M29 16H99Q112 16 112 29V99Q112 112 99 112H29Q16 112 16 99V29Q16 16 29 16Z'
            if famille == 'recompense':
                trace = 'M29 17H95Q106 17 111 29V99L99 111H30Q17 111 17 97V29Z'
            svg = svg.replace('</svg>', f'<path d="{trace}" fill="none" stroke="#a9dbe6" stroke-opacity=".75" stroke-width="1.3"/></svg>')
        if nom in ('panneau', 'zone_texte', 'saisie', 'saisie_focus'):
            svg = svg.replace('fill="#1e2c4e"', 'fill="#7e90a9"').replace('stroke="#394b70"', 'stroke="#aab7c6"')
        if nom == 'action_depart':
            svg = svg.replace('</svg>', '<path d="M31 34 35 29 39 34 35 39ZM97 34 93 29 89 34 93 39ZM31 94 35 89 39 94 35 99ZM97 94 93 89 89 94 93 99Z" fill="#b8e4e5" fill-opacity=".68"/><path d="M57 19H71M57 109H71" fill="none" stroke="#f7e6bd" stroke-opacity=".55" stroke-width="1.5" stroke-linecap="round"/></svg>')
        elif nom == 'secondaire_mine':
            svg = svg.replace('</svg>', '<path d="M27 31 32 25 37 31 32 37ZM101 31 96 25 91 31 96 37Z" fill="#f0cb94" fill-opacity=".7"/></svg>')
        elif nom == 'secondaire_epreuves':
            svg = svg.replace('</svg>', '<path d="M27 31 32 24 37 31 32 38ZM101 31 96 24 91 31 96 38Z" fill="#9ee4ec" fill-opacity=".72"/></svg>')
        (INTERFACE / 'cadres' / f'{nom}.svg').write_text(svg, encoding='utf-8')
    modele('navigation', INTERFACE / 'cadres/navigation.svg')
    modele('bandeau_monde', INTERFACE / 'cadres/bandeau_monde.svg')
    modele('mode_mine', INTERFACE / 'cadres/mode_mine.svg')
    modele('mode_epreuves', INTERFACE / 'cadres/mode_epreuves.svg')
    rond = (MODELES / 'rond.svg').read_text(encoding='utf-8')
    (INTERFACE / 'cadres/rond.svg').write_text(rond, encoding='utf-8')
    rond_selection = rond.replace('</svg>', '<circle cx="64" cy="62" r="53" fill="none" stroke="#b6eef2" stroke-width="2"/><path d="M26 25q16-16 37-17" fill="none" stroke="#fff7df" stroke-width="2" stroke-linecap="round"/></svg>')
    (INTERFACE / 'cadres/rond_selection.svg').write_text(rond_selection, encoding='utf-8')
    for nom, cadre in {'panneau':'conteneur', 'cadre':'conteneur', 'carte_augment':'recompense',
                       'bouton_principal':'action', 'bouton_secondaire':'secondaire',
                       'bandeau':'bandeau', 'medaillon':'medaillon'}.items():
        (INTERFACE / f'{nom}.svg').write_text((INTERFACE / 'cadres' / f'{cadre}.svg').read_text(encoding='utf-8'), encoding='utf-8')


def objets():
    # Un anneau partage une construction bijoutiere ; chaque pierre a sa taille propre.
    gemmes = {
        'anneau_azur': ('M60 16Q76 30 60 47 44 30Z', 'turquoise'),
        'anneau_amethyste': ('M60 14 76 28 68 46H52L44 28Z', 'violet'),
        'anneau_givre': ('M60 13 69 24 82 30 69 36 60 48 51 36 38 30 51 24Z', 'acier'),
        'anneau_ambre': ('M60 14C77 14 79 42 60 47 41 42 43 14 60 14Z', 'ambre'),
        'anneau_emeraude': ('M60 13 76 25 72 39 60 48 48 39 44 25Z', 'vert'),
    }
    for nom, (forme, matiere) in gemmes.items():
        corps = '<ellipse cx="60" cy="70" rx="31" ry="35" fill="none" stroke="#293450" stroke-width="15"/>'
        corps += '<ellipse cx="60" cy="68" rx="31" ry="35" fill="none" stroke="url(#or)" stroke-width="12"/>'
        corps += '<ellipse cx="60" cy="68" rx="25" ry="29" fill="none" stroke="#fff3db" stroke-opacity=".65" stroke-width="1.6"/>'
        corps += p('M41 24 50 17 70 17 79 24 74 42 46 42Z', 'url(#acier)', '#756a7b', 1.4)
        corps += p(forme, f'url(#{matiere})', '#4e5b83', 1.5)
        corps += trait('M49 25 60 18 71 25M48 92q12 7 24 0', '#fff8e9', 1.5, .7)
        corps += p('M60 20 66 29 60 42 54 29Z', '#fff', 'none', 0, 'opacity=".2"')
        ecrire(INTERFACE / 'equipement' / f'{nom}.svg', corps)
    pendentifs = {
        'pendentif_azur': ('M60 40Q87 63 77 84 69 99 60 105 51 99 43 84 33 63 60 40Z', 'turquoise'),
        'pendentif_lune': ('M68 41Q39 50 42 77q5 23 30 26Q59 89 62 72q0-18 6-31Z', 'acier'),
        'pendentif_soleil': ('M60 40 68 55 85 54 77 70 86 85 68 83 60 102 52 83 34 85 43 70 35 54 52 55Z', 'ambre'),
    }
    for nom, (forme, matiere) in pendentifs.items():
        corps = trait('M21 16Q32 66 60 48 88 66 99 16', '#364666', 6)
        corps += trait('M21 16Q32 61 60 44 88 61 99 16', '#e1cba8', 4)
        corps += '<circle cx="60" cy="46" r="8" fill="url(#or)" stroke="#605d76" stroke-width="1"/>'
        corps += p(forme, f'url(#{matiere})', '#545d7a', 2)
        corps += trait('M60 47q-12 10-13 22M56 93q4 4 8 0', '#fff9e9', 1.7, .72)
        corps += eclat(60, 68, 4)
        ecrire(INTERFACE / 'equipement' / f'{nom}.svg', corps)

    def manche():
        return (p('M20 103 76 36 83 43 31 109Q23 112 20 103Z', 'url(#cuir)', '#48506e', 1.4)
                + trait('M29 98 76 41M35 88l8 7M45 76l8 7', '#fae4c5', 2, .7))
    armes = {
        'standard': manche() + p('M75 17 96 31 85 52 64 38Z', 'url(#turquoise)', '#53658a', 2)+p('M75 17 81 35 64 38Z', '#e8fffb', 'none', 0, 'opacity=".48"'),
        'veloce': manche() + p('M85 7 99 39 79 54 67 37Z', 'url(#acier)', '#4a5d7f', 2)+trait('M83 15 86 38M69 32l13 4', '#fff', 1.7, .73)+eclat(102, 24, 5),
        'lourd': manche() + p('M64 23h43v36H64Z', 'url(#acier)', '#435471', 2)+p('M67 28h35v25H67Z', 'url(#nuit)', '#acb9c6', 1)+p('M75 32 94 32 94 49 75 49Z', 'url(#violet)', '#d9d1d0', 1.2),
        'chercheur': manche() + '<circle cx="84" cy="36" r="23" fill="url(#acier)" stroke="#4f5c78" stroke-width="2"/><circle cx="84" cy="36" r="16" fill="url(#nuit)" stroke="#dfcda8" stroke-width="1.2"/><circle cx="84" cy="36" r="9" fill="url(#turquoise)"/>'+trait('M59 20q11-12 23-10M106 57q9-9 7-19', '#c8faff', 1.5, .72),
        'explosif': manche() + p('M84 8 90 26 109 19 103 38 117 50 98 53 94 73 80 57 62 63 69 46 55 34 75 32Z', 'url(#ambre)', '#6d607a', 2)+p('M84 29 95 40 84 51 73 40Z', 'url(#violet)', '#f7e3bf', 1.2)+eclat(104, 12, 4),
    }
    for nom, corps in armes.items():
        ecrire(INTERFACE / 'armes' / f'{nom}.svg', corps)


def glyphes():
    groupes = {
        'attaque': 'tir_multiple salve ricochet perforation fragmentation homing frappe_lourde puissance force audace trait_transpercant riposte_alchimique trajectoire precision',
        'defense': 'egide rempart bastion rempart_initial dernier_rempart sceau_garde carapace robustesse peau_de_pierre',
        'armure': 'armure constitution colosse endurance mannequin',
        'vitesse': 'cadence cadence_febrile celerite elan rythme sceau_celerite tempete',
        'vie': 'regeneration vitalite elan_vital moisson_vitale seconde_chance immortel',
        'alchimie': 'catalyse distillation echo_alchimique chaine_alchimique onde_alchimique explosion_corrosive heritage_reactif transmutation_totale',
        'sceau': 'sceau_furie sceau_portee sceau_ruine',
        'magie': 'spirale orbes_chargees onde_de_choc zone_heros grand_oeuvre temps_suspendu',
        'familiers': 'familier_gardien familier_tireur',
        'savoir': 'prescience philosophe sagesse savoir lumiere',
        'richesse': 'avidite fortune abondance collecte reserve_ultime',
        'feu': 'feu barrage_de_braise meteores courageux',
        'eau': 'eau soif_de_sang',
        'air': 'air',
        'terre': 'terre',
        'givre': 'nova_de_givre sang_froid',
        'foudre': 'impulsion_foudroyante',
        'ombre': 'tenebres domination',
    }
    categorie = {nom: groupe for groupe, noms in groupes.items() for nom in noms.split()}
    couleurs = {
        'attaque': 'acier', 'defense': 'acier', 'armure': 'acier', 'vitesse': 'turquoise',
        'vie': 'vert', 'alchimie': 'turquoise', 'sceau': 'violet', 'magie': 'violet',
        'familiers': 'papier', 'savoir': 'papier', 'richesse': 'or', 'feu': 'ambre',
        'eau': 'turquoise', 'air': 'acier', 'terre': 'or', 'givre': 'acier',
        'foudre': 'turquoise', 'ombre': 'violet',
    }
    bases = {
        'attaque': p('M27 92 77 32 96 41 48 104 30 108Z', 'url(#acier)', '#4a5878', 1.7)+p('M75 17 105 33 89 61 61 44Z', 'url(#nuit)', '#a6bfd1', 1.6)+trait('M77 23 96 34 85 49M36 94 74 44', '#fff', 1.6, .72),
        'defense': p('M64 14 101 33v31q0 27-37 47Q27 91 27 64V33Z', 'url(#acier)', '#465575', 2)+p('M64 24 91 38v25q0 23-27 37Q37 86 37 63V38Z', 'url(#nuit)', '#b0c0cd', 1.2)+trait('M64 19v84M34 49v13Q34 81 55 96', '#fff', 1.3, .45),
        'armure': p('M43 19 51 15q12 15 26 0l8 4 19 24-15 18-7-7v51H46V54l-7 7-15-18Z', 'url(#acier)', '#465778', 2)+p('M49 36 64 46 79 36v54H49Z', 'url(#nuit)', '#aebdcc', 1.1)+trait('M52 20q12 9 24 0M47 98h34', '#fff', 1.6, .68),
        'vitesse': p('M20 88Q32 35 99 18 75 76 20 88Z', 'url(#acier)', '#465b7c', 1.8)+p('M32 78Q61 42 99 18 78 76 32 78Z', 'url(#turquoise)', '#618fab', 1)+trait('M25 84 92 24M37 90 20 101M56 83 43 98', '#fff', 1.5, .72),
        'vie': p('M64 108Q18 80 24 52q7-32 40-14 33-18 40 14 6 28-40 56Z', 'url(#vert)', '#4e7080', 1.9)+p('M64 96Q34 78 34 55q2-17 15-17 8 0 15 10 7-10 15-10 13 0 15 17Q94 78 64 96Z', 'url(#nuit)', '#b1d7c4', 1.2)+trait('M31 53q0-17 14-17', '#fff', 1.7, .55),
        'alchimie': p('M48 15h32v9H48ZM53 24h22v26l24 39q9 18-13 20H42Q20 107 29 89l24-39Z', 'url(#papier)', '#59728e', 1.8, 'fill-opacity=".85"')+p('M36 84q28-8 56 0l7 14-15 9H44l-15-9Z', 'url(#turquoise)', '#4b8eaa', 1)+trait('M56 28v22L35 84M48 93q12 4 25 0', '#fff', 1.5, .67),
        'sceau': p('M64 13 105 39v49l-41 25-41-25V39Z', 'url(#or)', '#5f5878', 1.8)+p('M64 22 96 43v40l-32 19-32-19V43Z', 'url(#nuit)', '#cab5bd', 1.2)+trait('M64 18 99 42M26 44v39', '#fff', 1.5, .56),
        'magie': '<circle cx="64" cy="64" r="47" fill="url(#nuit)" stroke="url(#or)" stroke-width="4"/><circle cx="64" cy="64" r="37" fill="url(#violet)" fill-opacity=".65"/>'+trait('M21 65A43 43 0 0 1 65 21M104 65a40 40 0 0 1-34 39', '#fff', 1.6, .62),
        'familiers': p('M28 91 24 38 49 50 64 27 79 50 104 38 100 91 64 110Z', 'url(#papier)', '#596881', 1.8)+p('M35 59 49 67 64 51 79 67 93 59 91 89 64 100 37 89Z', 'url(#nuit)', '#b0b6c5', 1)+trait('M31 48 47 57M97 48 81 57', '#fff', 1.5, .65),
        'savoir': p('M18 30Q42 20 64 32q22-12 46-2v70q-22-9-46 3-24-12-46-3Z', 'url(#papier)', '#767c95', 1.8)+trait('M64 32v71M26 44q17-6 30 1M72 45q14-7 30-1M24 95q20-5 40 5 21-10 40-5', '#8b9bb0', 1.4, .8),
        'richesse': p('M36 39 50 21h28l14 18-10 14H46Z', 'url(#or)', '#696078', 1.7)+p('M46 53h36q25 27 18 46-17 18-72 0-7-19 18-46Z', 'url(#cuir)', '#615775', 1.7)+trait('M40 77q23 9 49 0M50 48h28', '#fff3d6', 1.7, .68),
        'feu': p('M61 110Q28 108 27 77q0-21 20-51 1 23 15 26 6-24 21-40-2 26 13 45 21 34-14 49-9 4-21 4Z', 'url(#ambre)', '#855b72', 1.9)+p('M61 104Q44 97 49 80q4-11 15-22 0 15 10 18 9-9 11-22 15 27 0 44-8 7-24 6Z', 'url(#or)', 'none', 0, 'opacity=".68"'),
        'eau': p('M64 12Q24 62 29 86q5 24 35 25 30-1 35-25 5-24-35-74Z', 'url(#turquoise)', '#466c8b', 2)+p('M64 18Q37 60 35 83q-1 16 17 22Q47 78 64 18Z', '#eafffb', 'none', 0, 'opacity=".38"')+trait('M39 75q2-14 12-27', '#fff', 1.7, .68),
        'air': p('M20 51Q55 23 92 39q13 10-3 20-16 11-52 4 28 3 42 18 8 14-15 20-24 3-39-13', 'url(#acier)', '#60728c', 1.7)+trait('M25 53q38-23 63-11M36 85q21 12 42 6', '#fff', 1.7, .72),
        'terre': p('M18 101 46 34 60 56 79 19 110 101Z', 'url(#or)', '#696478', 1.8)+p('M43 45 55 67 61 59 79 28 93 83 70 101H32Z', 'url(#nuit)', 'none', 0, 'opacity=".57"')+trait('M45 36 29 80M79 21 95 66', '#fff5db', 1.5, .65),
        'givre': p('M64 10 73 44 107 31 88 61 112 84 77 78 64 112 51 78 16 84 40 61 21 31 55 44Z', 'url(#acier)', '#6d8aa6', 1.8)+p('M64 33 73 60 64 91 55 60Z', 'url(#turquoise)', '#e9fcff', 1)+trait('M64 15v82M26 34l67 53', '#fff', 1.2, .62),
        'foudre': p('M68 11 24 71h31l-4 38 53-59H72l10-39Z', 'url(#turquoise)', '#4c6385', 2)+p('M68 14 32 66h29l-4 30 34-41H65l10-31Z', '#eafffd', 'none', 0, 'opacity=".45"')+eclat(102, 25, 5),
        'ombre': p('M79 15Q30 21 25 61q-2 44 48 51-25-20-19-51 5-24 25-46Z', 'url(#violet)', '#4e4c79', 1.9)+p('M64 31Q36 62 60 98q-20-6-23-34 3-20 27-33Z', 'url(#nuit)', 'none', 0, 'opacity=".5"')+eclat(88, 52, 8, '#d4bef1'),
    }
    if set(SIGNES) != set(MOTIFS):
        raise ValueError("Liste des signatures non synchronisee avec les capacites")
    manquants = set(SIGNES) - set(categorie)
    if manquants:
        raise ValueError(f'Glyphes sans categorie : {sorted(manquants)}')
    for nom, signe in SIGNES.items():
        groupe = categorie[nom]
        matiere = couleurs[groupe]
        fond = '<ellipse cx="64" cy="64" rx="57" ry="55" fill="url(#lueur)"/>' + bases[groupe]
        # Le trace sert de gravure secondaire sur une forme illustree originale.
        fond += (f'<g transform="translate(11 11) scale(.82)" fill="none" '
                 f'stroke="#152747" stroke-width="7" stroke-linecap="round" '
                 f'stroke-linejoin="round" opacity=".72"><path d="{signe}"/></g>')
        fond += (f'<g transform="translate(11 11) scale(.82)" fill="none" '
                 f'stroke="url(#{matiere})" stroke-width="3.5" stroke-linecap="round" '
                 f'stroke-linejoin="round" opacity=".95"><path d="{signe}"/></g>')
        fond += eclat(98, 19, 3)
        ecrire(GLYPHES / f'{nom}.svg', fond, '0 0 128 128')


def composants():
    for nom, corps in navigation().items():
        ecrire(INTERFACE / f'{nom}.svg', corps)
    for nom, corps in controles().items():
        taille = (48, 48) if nom == 'fleche_bas' else (384, 384)
        ecrire(INTERFACE / f'{nom}.svg', corps, taille=taille)
    ecrire(INTERFACE / 'oui.svg',
           p('M26 3h48q22 0 23 23-1 23-23 23H26Q3 49 3 26T26 3Z', 'url(#acier)', '#5b6681', 1, 'fill-opacity=".75"')
           + p('M26 8h48q17 0 18 18-1 18-18 18H26Q8 44 8 26T26 8Z', 'url(#nuit)', '#7d91aa', 1)
           + '<circle cx="72" cy="26" r="21" fill="url(#turquoise)" stroke="#e8e0d5" stroke-width="1.6"/>'
           + trait('M62 18q9-8 18 0', '#fff', 1.5, .66), '0 0 100 52', (100, 52))
    ecrire(INTERFACE / 'non.svg',
           p('M26 3h48q22 0 23 23-1 23-23 23H26Q3 49 3 26T26 3Z', 'url(#acier)', '#5b6681', 1, 'fill-opacity=".75"')
           + p('M26 8h48q17 0 18 18-1 18-18 18H26Q8 44 8 26T26 8Z', 'url(#nuit)', '#7d91aa', 1)
           + '<circle cx="27" cy="26" r="21" fill="url(#acier)" stroke="#e8e0d5" stroke-width="1.6"/>'
           + trait('M17 18q9-8 18 0', '#fff', 1.5, .66), '0 0 100 52', (100, 52))
    ecrire(INTERFACE / 'curseur.svg',
           '<circle cx="24" cy="26" r="22" fill="url(#acier)" stroke="#66718f" stroke-width="1"/>'
           '<circle cx="24" cy="24" r="17" fill="url(#turquoise)" stroke="#e8f7f5" stroke-width="1.2"/>'
           + eclat(24, 23, 5), '0 0 48 48', (48, 48))
    ecrire(INTERFACE / 'jauge_fond.svg',
           '<rect x="2" y="3" width="252" height="26" rx="13" fill="url(#acier)" stroke="#5d6986" stroke-width="1"/>'
           '<rect x="6" y="7" width="244" height="18" rx="9" fill="url(#nuit)"/>'
           + trait('M18 9H236', '#fff', 1, .35), '0 0 256 32', (256, 32))
    ecrire(INTERFACE / 'jauge_plein.svg',
           '<rect x="3" y="5" width="250" height="22" rx="10" fill="url(#turquoise)" stroke="#4d7597" stroke-width="1"/>'
           '<rect x="9" y="9" width="238" height="4" rx="2" fill="#fff" opacity=".51"/>', '0 0 256 32', (256, 32))
    ecrire(INTERFACE / 'separateur.svg',
           trait('M7 16H237M275 16h230', '#bfc9d7', 2, .6)
           + p('M256 3 270 16 256 29 242 16Z', 'url(#turquoise)', '#d4c9b8', 1.2)
           + eclat(256, 16, 4), '0 0 512 32', (512, 32))
    ecrire(INTERFACE / 'joystick_base.svg',
           '<circle cx="60" cy="60" r="54" fill="url(#nuit)" fill-opacity=".38" stroke="url(#acier)" stroke-width="2"/>'
           '<circle cx="60" cy="60" r="42" fill="none" stroke="#a1c7d2" stroke-opacity=".52" stroke-width="1.5"/>'
           + trait('M60 12v8M60 100v8M12 60h8M100 60h8', '#e9f4f1', 1.5, .55))
    ecrire(INTERFACE / 'joystick_curseur.svg',
           '<circle cx="60" cy="63" r="47" fill="#1f3157" opacity=".34"/>'
           '<circle cx="60" cy="59" r="47" fill="url(#acier)" stroke="#596986" stroke-width="1.3"/>'
           '<circle cx="60" cy="59" r="40" fill="url(#nuit)" stroke="#c8d5da" stroke-width="1.1"/>'
           + p('M60 32 82 59 60 86 38 59Z', 'url(#turquoise)', '#e7f1ed', 1.3)
           + eclat(60, 59, 5))
    victoire = '<ellipse cx="60" cy="59" rx="48" ry="48" fill="url(#lueur)"/>'
    victoire += p('M27 21h66v22q0 37-33 47Q27 80 27 43Z', 'url(#or)', '#635e76', 1.8)
    victoire += p('M35 28h50v15q0 27-25 38Q35 70 35 43Z', 'url(#nuit)', '#dfc9a4', 1.1)
    victoire += p('M60 37 67 52 83 55 71 67 74 83 60 75 46 83 49 67 37 55 53 52Z', 'url(#turquoise)', '#e6d9c5', 1.2)
    victoire += p('M54 87h12v12h20v9H34v-9h20Z', 'url(#acier)', '#5e627c', 1.3)
    ecrire(INTERFACE / 'victoire.svg', victoire)
    defaite = p('M60 15 99 35v29q0 27-39 47Q21 91 21 64V35Z', 'url(#acier)', '#4e5b7a', 1.8)
    defaite += p('M60 24 90 40v24q0 20-30 36Q30 84 30 64V40Z', 'url(#nuit)', '#a8b5c6', 1)
    defaite += p('M68 32 51 58 64 65 47 89', 'none', '#bfc9dc', 4)
    defaite += trait('M49 62 62 68 47 91M31 38l28-17', '#fff', 1.5, .53)
    ecrire(INTERFACE / 'defaite.svg', defaite)
    ecrire(INTERFACE / 'halo_recompense.svg',
           '<defs><radialGradient id="halo"><stop stop-color="#fff8e8" stop-opacity=".67"/><stop offset=".36" stop-color="#b9d7f0" stop-opacity=".43"/><stop offset="1" stop-color="#a18dcb" stop-opacity="0"/></radialGradient></defs>'
           '<circle cx="256" cy="256" r="248" fill="url(#halo)"/>'
           + p('M256 18 278 207 402 90 304 228 494 256 304 284 402 422 278 305 256 494 234 305 110 422 208 284 18 256 208 228 110 90 234 207Z', '#e9f6ff', 'none', 0, 'opacity=".22"')
           + '<circle cx="256" cy="256" r="155" fill="none" stroke="#e4d6ea" stroke-width="2" stroke-opacity=".43"/>'
           + eclat(106, 138, 17)+eclat(418, 357, 13), '0 0 512 512', (512, 512))


def generer():
    cadres()
    composants()
    objets()
    glyphes()
    print('Refonte SVG illustree : 154 ressources autonomes generees.')


if __name__ == '__main__':
    generer()
