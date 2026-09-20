"""Gestes du squelette utilise par le generateur du mage sculpte."""
import json
import math
import struct


FPS = 60
DUREES = {'repos': 2.4, 'course': .72, 'attaque': .4}


def rampe(a, b, valeur):
    t = max(0., min(1., (valeur-a)/(b-a)))
    return t*t*t*(t*(t*6-15)+10)


def quaternion(x, y, z):
    cx, cy, cz = (math.cos(a*.5) for a in (x, y, z))
    sx, sy, sz = (math.sin(a*.5) for a in (x, y, z))
    return (sx*cy*cz-cx*sy*sz, cx*sy*cz+sx*cy*sz,
            cx*cy*sz-sx*sy*cz, cx*cy*cz+sx*sy*sz)


def pose(nom, t, noeuds):
    rotations = {n: [0., 0., 0.] for n in noeuds}
    positions = {n: list(v.get('translation', [0., 0., 0.])) for n, v in noeuds.items()}
    phase = math.tau*t
    for signe, cote in ((1, 'gauche'), (-1, 'droite')):
        rotations['bras_'+cote] = [0., 0., -signe*1.12]
        rotations['avant_bras_'+cote][1] = signe*.30
    rotations['torse'][0] = .012*math.sin(phase)
    rotations['tete'][0] = -.009*math.sin(phase-.35)
    rotations['chapeau'][2] = .016*math.sin(phase-.6)
    if 'echarpe' in rotations:
        rotations['echarpe'][0] = .035*math.sin(phase-.8)

    if nom == 'repos':
        positions['torse'][1] += .004*math.sin(phase)
    elif nom == 'course':
        # Deux compressions par cycle, puis une remontee souple entre les appuis.
        rebond = -.055+.023*(1-math.cos(2*phase-.8))
        positions['bassin'][1] += rebond
        rotations['torse'] = [.10+.018*math.cos(2*phase-.8),
                              .065*math.sin(phase), .025*math.cos(phase)]
        rotations['tete'] = [-.065, -.04*math.sin(phase-.2), -.018*math.cos(phase)]
        rotations['chapeau'] = [.028*math.sin(2*phase-1.), 0., .035*math.sin(phase-.6)]
        rotations['echarpe'] = [.16+.07*math.sin(2*phase-.9),
                               .06*math.sin(phase-.7), .035*math.cos(phase-.7)]
        for signe, cote in ((1, 'gauche'), (-1, 'droite')):
            u = (t+(.5 if signe > 0 else 0.)) % 1.
            pas = math.tau*u
            # Un appui recule sous le bassin ; le retour leve le pied sous le corps.
            if u < .5:
                progression = rampe(0., .5, u)
                avance = .13*(1-2*progression)
                levee = 0.
                pointe = -.10*(1-rampe(0., .12, u))+.22*rampe(.32, .5, u)
            else:
                progression = rampe(.5, 1., u)
                avance = -.13+.26*progression
                levee = .10*math.sin(math.pi*(u-.5)*2)**2
                pointe = .22*(1-progression)-.10*progression
            cuisse = -noeuds['tibia_'+cote]['translation'][1]
            bas_jambe = noeuds['pied_'+cote]['translation']
            tibia = math.hypot(bas_jambe[1], bas_jambe[2])
            hauteur = cuisse-bas_jambe[1]+rebond-levee
            profondeur = bas_jambe[2]+avance
            distance = min(cuisse+tibia-.0001, math.hypot(hauteur, profondeur))
            # Resoudre le genou depuis l'appui evite l'effet de jambes en pendule.
            hanche = math.atan2(-profondeur, hauteur)-math.acos(max(-1., min(1.,
                (cuisse*cuisse+distance*distance-tibia*tibia)/(2*cuisse*distance))))
            genou = math.acos(max(-1., min(1.,
                (distance*distance-cuisse*cuisse-tibia*tibia)/(2*cuisse*tibia))))
            genou += math.atan2(bas_jambe[2], -bas_jambe[1])
            rotations['cuisse_'+cote][0] = hanche
            rotations['tibia_'+cote][0] = genou
            rotations['pied_'+cote][0] = pointe-hanche-genou
            rotations['bras_'+cote] = [.035*math.sin(pas), signe*.36*math.cos(pas),
                                      -signe*(1.15+.025*math.sin(pas))]
            rotations['avant_bras_'+cote][1] = signe*(.38+.10*math.sin(pas-.45))
            rotations['main_'+cote][1] = signe*.035*math.sin(pas-.7)
    elif nom == 'attaque':
        # La projection est a 0,05 s en jeu ; ne pas decaler son impulsion visuelle.
        secondes = t*DUREES[nom]
        anticipation = rampe(0., .025, secondes)*(1-rampe(.025, .05, secondes))
        geste = rampe(.025, .05, secondes)*(1-rampe(.10, .4, secondes))
        retard = rampe(.05, .11, secondes)*(1-rampe(.11, .4, secondes))
        rotations['bras_droite'] = [0., -.35*anticipation+1.35*geste,
                                   1.12-.80*geste]
        rotations['avant_bras_droite'][1] = -.30-.45*anticipation+.25*geste
        rotations['bras_gauche'][1] = .15*geste
        rotations['torse'] = [.075*geste, .16*anticipation-.20*geste, 0.]
        rotations['tete'] = [-.035*geste, -.10*anticipation+.12*geste, 0.]
        rotations['chapeau'] = [-.045*retard, 0., .025*retard]
        rotations['echarpe'] = [-.12*retard, .06*retard, 0.]
    for i, os in enumerate(('echarpe_milieu', 'echarpe_bout')):
        if os in rotations:
            amplitude = .10 if nom == 'course' else .018
            rotations[os] = [amplitude*math.sin(phase-.7-i*.55),
                             .025*math.sin(phase-i*.5), .04*math.sin(phase-1.-i*.6)]
    return rotations, positions


def animer(chemin):
    brut = chemin.read_bytes()
    taille = struct.unpack_from('<I', brut, 12)[0]
    doc = json.loads(brut[20:20+taille])
    binaire = bytearray(brut[28+taille:])
    extras = doc.setdefault('extras', {})
    # Rejouer l'outil remplace son propre bloc, sans grossir le GLB a chaque passe.
    precedent = extras.get('animation_v2_bloc')
    if precedent:
        del binaire[precedent['octets']:]
        del doc['accessors'][precedent['accesseurs']:]
        del doc['bufferViews'][precedent['vues']:]
    extras['animation_v2_bloc'] = {'octets': len(binaire),
        'accesseurs': len(doc['accessors']), 'vues': len(doc['bufferViews'])}
    indices = {n['name']: i for i, n in enumerate(doc['nodes'])}
    articulations = set(j for peau in doc['skins'] for j in peau['joints'])
    noeuds = {n['name']: n for i, n in enumerate(doc['nodes']) if i in articulations}

    def ajouter(valeurs, type_valeur):
        largeur = {'SCALAR': 1, 'VEC3': 3, 'VEC4': 4}[type_valeur]
        binaire.extend(b'\0'*(-len(binaire) % 4))
        depart = len(binaire)
        for valeur in valeurs:
            binaire.extend(struct.pack('<'+'f'*largeur, *valeur))
        vue = len(doc['bufferViews'])
        doc['bufferViews'].append({'buffer': 0, 'byteOffset': depart, 'byteLength': len(binaire)-depart})
        accesseur = {'bufferView': vue, 'componentType': 5126, 'count': len(valeurs), 'type': type_valeur}
        if type_valeur == 'SCALAR':
            accesseur.update(min=[valeurs[0][0]], max=[valeurs[-1][0]])
        indice = len(doc['accessors'])
        doc['accessors'].append(accesseur)
        return indice

    for nom, duree in DUREES.items():
        frames = round(duree*FPS)
        instants = ajouter([(f*duree/frames,) for f in range(frames+1)], 'SCALAR')
        poses = [pose(nom, f/frames, noeuds) for f in range(frames+1)]
        if nom in ('repos', 'course'):
            poses[-1] = poses[0]
        animation = {'name': nom, 'channels': [], 'samplers': []}
        for os in noeuds:
            for propriete, type_valeur in (('rotation', 'VEC4'), ('translation', 'VEC3')):
                valeurs = ([quaternion(*p[0][os]) for p in poses] if propriete == 'rotation'
                           else [p[1][os] for p in poses])
                sortie = ajouter(valeurs, type_valeur)
                canal = len(animation['samplers'])
                animation['samplers'].append({'input': instants, 'output': sortie, 'interpolation': 'LINEAR'})
                animation['channels'].append({'sampler': canal, 'target': {'node': indices[os], 'path': propriete}})
        indice = next(i for i, a in enumerate(doc['animations']) if a['name'] == nom)
        doc['animations'][indice] = animation
    binaire.extend(b'\0'*(-len(binaire) % 4))
    doc['buffers'] = [{'byteLength': len(binaire)}]
    texte = json.dumps(doc, separators=(',', ':')).encode()
    texte += b' '*(-len(texte) % 4)
    sortie = (struct.pack('<III', 0x46546c67, 2, 28+len(texte)+len(binaire))
              + struct.pack('<II', len(texte), 0x4e4f534a)+texte
              + struct.pack('<II', len(binaire), 0x004e4942)+binaire)
    chemin.write_bytes(sortie)
    print('Repos, course et attaque recomposes ; geometrie et textures conservees.')
