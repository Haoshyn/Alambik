"""Sylphe et gardien de jade originaux, construits en coordonnees Godot.

Les volumes continus portent l'anatomie. Les remiges et plaques minerales
suivent ces volumes au lieu de masquer des assemblages de boules.
"""
import math

import bpy
from mathutils import Vector


BLEU = '899CCA'
BLEU_OMBRE = '6078A5'
BLEU_CLAIR = 'B5BBDD'
IVOIRE = 'ECE9D8'
BEC = 'C8AD71'
SOMBRE = '293641'
JADE = '6A8277'
JADE_OMBRE = '455D55'
PIERRE = 'A7B29E'
PIERRE_CLAIRE = 'C1C8AD'
MOUSSE = '829B5B'


def _soustraire(point, origine):
    return tuple(a-b for a, b in zip(point, origine))


def _points_locaux(points, origine):
    return [_soustraire(p, origine) for p in points]


def _volume(h, parent, nom, point, rayons, couleur, rotation=(0, 0, 0)):
    return h.ellipsoide(parent, nom, point, rayons, couleur, rotation=rotation)


def _pierre(h, parent, nom, point, rayons, couleur, rotation=(0, 0, 0)):
    """Ecaille minerale : pans obliques, cassures inegales, relief peu profond."""
    rx, ry, rz = rayons
    # Les couronnes se decalent et se resserrent : la pierre ne prend pas
    # l'aspect d'un petit cylindre regulier pose sur l'anatomie.
    phase = sum((i+1)*ord(c) for i, c in enumerate(nom))*.017
    profils = [(-.78, .57, -.06, .03), (-.39, 1.0, 0, 0),
               (.31, .91, .10, -.09), (.78, .43, .21, -.17)]
    vertices = []
    for couronne, (niveau, facteur, derive_x, derive_z) in enumerate(profils):
        for i in range(8):
            angle = math.tau*(i+.5)/8+.10*math.sin(phase+i*2.13)
            irregularite = .88+.16*math.sin(phase*.7+i*1.71)
            hauteur = niveau+.12*math.sin(angle+phase)*(couronne/3)
            vertices.append(h.V((rx*(math.cos(angle)*facteur*irregularite+derive_x),
                                 ry*hauteur,
                                 rz*(math.sin(angle)*facteur+derive_z))))
    faces = [tuple(reversed(range(8)))]
    for niveau in range(3):
        for i in range(8):
            a = niveau*8+i
            b = niveau*8+(i+1) % 8
            faces.append((a, b, b+8, a+8))
    faces.append(tuple(range(24, 32)))
    mesh = bpy.data.meshes.new(nom)
    mesh.from_pydata(vertices, [], faces)
    mesh.update()
    objet = bpy.data.objects.new(nom, mesh)
    bpy.context.collection.objects.link(objet)
    objet.parent = parent
    objet.location = h.V(point)
    # Convertir aussi l'axe vertical pour que les torsions restent coherentes.
    objet.rotation_euler = (rotation[0], -rotation[2], rotation[1])
    h.peindre(objet, couleur)
    return objet


def _plume(h, parent, nom, debut, fin, largeur, couleur, origine=(0, 0, 0), courbure=.025):
    debut, fin = Vector(debut), Vector(fin)
    direction = (fin-debut).normalized()
    normale = Vector((0, 0, 1))
    if abs(direction.dot(normale)) > .82:
        normale = Vector((0, 1, 0))
    cote = normale.cross(direction).normalized()
    normale = direction.cross(cote).normalized()
    sommets, faces = [], []
    for i in range(13):
        t = i/12
        point = debut.lerp(fin, t)+Vector((0, 0, math.sin(math.pi*t)*courbure))
        profil = max(.0004, math.sin(math.pi*t)**.72*(1-.22*t)*largeur*.5)
        for lateral, relief in ((-1, 0), (0, 1), (1, 0), (0, -.4)):
            q = point+cote*profil*lateral+normale*(.010*math.sin(math.pi*t)*relief)
            sommets.append(h.V(_soustraire(tuple(q), origine)))
        if i:
            for j in range(4):
                faces.append(((i-1)*4+j, (i-1)*4+(j+1)%4, i*4+(j+1)%4, i*4+j))
    faces.extend([(3, 2, 1, 0), (48, 49, 50, 51)])
    mesh = bpy.data.meshes.new(nom)
    mesh.from_pydata(sommets, [], faces)
    mesh.update()
    objet = bpy.data.objects.new(nom, mesh)
    bpy.context.collection.objects.link(objet)
    objet.parent = parent
    for polygon in mesh.polygons:
        polygon.use_smooth = True
    h.peindre(objet, couleur)
    return objet


def _oeil(h, parent, centre, normale, largeur, hauteur, iris):
    enfants_avant = set(parent.children)
    h.oeil(parent, centre, normale, largeur, hauteur, iris)
    for objet in set(parent.children)-enfants_avant:
        if objet.type != 'MESH' or objet.name.startswith('Regard'):
            continue
        bpy.ops.object.select_all(action='DESELECT')
        objet.select_set(True)
        bpy.context.view_layer.objects.active = objet
        reduction = objet.modifiers.new('Regard_mobile', 'DECIMATE')
        reduction.ratio = .13
        bpy.ops.object.modifier_apply(modifier=reduction.name)


def _sylphe(h):
    racine = h.racine('sylphe')
    masses = [
        _volume(h, racine, 'Poitrine', (0, .358, .004), (.117, .172, .112), BLEU),
        _volume(h, racine, 'Bassin', (0, .267, -.064), (.100, .103, .104), BLEU),
        _volume(h, racine, 'Nuque', (0, .474, .039), (.067, .105, .068), BLEU),
        _volume(h, racine, 'Crane', (0, .566, .070), (.074, .075, .070), BLEU),
        _volume(h, racine, 'Front', (0, .570, .119), (.059, .044, .040), BLEU),
        _volume(h, racine, 'Gorge', (0, .459, .094), (.064, .092, .062), BLEU),
    ]
    corps = h.fusionner(racine, 'Anatomie_sylphe', masses, BLEU, ventre=IVOIRE,
                        voxel=.009, triangles=1600)
    # Des petites plumes de gorge donnent un poitrail effile et une transition
    # entre tete et tronc, sans grande bavette rapportee.
    for cote in (-1, 1):
        for i in range(3):
            _plume(h, racine, 'Gorge_duvet_%s_%s' % (cote, i),
                   (cote*(.016+i*.026), .450-i*.018, .113-i*.014),
                   (cote*(.028+i*.026), .325-i*.009, .121-i*.013),
                   .039, IVOIRE, courbure=.005)
        _plume(h, racine, 'Plume_joue_%s' % cote,
               (cote*.039, .534, .117), (cote*.084, .486, .084),
               .034, IVOIRE, courbure=.006)
        # Rapace : le regard lateral apparait sous la pente de l'arcade.
        _oeil(h, racine, (cote*.055, .571, .143), (cote*.45, .18, .9),
                .041, .023, 'BDA666')
        h.tube(racine, 'Arcade_sylphe_%s' % cote,
               [(cote*.030, .591, .150), (cote*.055, .592, .145),
                (cote*.073, .582, .129)],
               [(.009, .009), (.013, .009), (.007, .006)], BLEU_CLAIR, facettes=8)
        _plume(h, racine, 'Aigrette_%s' % cote,
               (cote*.031, .612, .054), (cote*.061, .672, -.025),
               .041, BLEU_CLAIR, courbure=.006)
    _plume(h, racine, 'Aigrette_centrale', (0, .615, .047), (0, .687, -.052),
           .044, BLEU_CLAIR, courbure=.006)
    # Le bec court se courbe a sa pointe ; sa base entre dans le front.
    h.tube(racine, 'Bec_superieur', [(0, .559, .135), (0, .552, .165),
                                   (0, .538, .191), (0, .522, .187)],
           [(.026, .017), (.020, .016), (.007, .013), (.001, .001)], BEC, facettes=10)
    h.tube(racine, 'Bec_inferieur', [(0, .537, .137), (0, .531, .164),
                                   (0, .531, .180)],
           [(.021, .009), (.013, .005), (.002, .002)], BEC, facettes=8)
    for cote in (-1, 1):
        _aile(h, racine, cote)
        _patte_sylphe(h, racine, cote)
    origine_queue = (0, .270, -.105)
    queue = h.pivot(racine, 'queue', origine_queue)
    for cote in (-1, 1):
        for i in range(2):
            debut = (cote*(.021+i*.028), .276-i*.013, -.080)
            fin = (cote*(.166-i*.045), .160+i*.024, -.598+i*.110)
            _plume(h, queue, 'Rectrice_longue_%s_%s' % (cote, i), debut, fin,
                   .088-i*.012, BLEU_CLAIR if i == 0 else BLEU, origine_queue, .022)
        _plume(h, queue, 'Rectrice_dorsale_%s' % cote,
               (cote*.028, .297, -.069), (cote*.089, .216, -.315),
               .065, BLEU_OMBRE, origine_queue, .017)
    return racine


def _aile(h, racine, cote):
    origine = (cote*.086, .425, -.007)
    aile = h.pivot(racine, 'aile', origine, cote=cote)
    # Epaule, coude et carpe forment le bord d'attaque. Les longues remiges
    # partent de cet arc et s'etagent comme une vraie aile ouverte.
    h.tube(aile, 'Bord_attaque_%s' % cote,
           _points_locaux([(cote*.077, .416, -.008),
                           (cote*.205, .475, -.025),
                           (cote*.317, .594, -.043),
                           (cote*.456, .707, -.058)], origine),
           [(.037, .047), (.041, .040), (.029, .032), (.010, .015)],
           BLEU, facettes=10)
    for i in range(10):
        debut = (cote*(.148+.027*i), .430+.026*i, -.053-.002*i)
        fin = (cote*(.390+.034*i), .454+.039*i, -.051-.004*i)
        couleur = BLEU_CLAIR if i > 5 else BLEU
        _plume(h, aile, 'Remige_%s_%s' % (cote, i), debut, fin,
               .086-.0018*i, couleur, origine, .021)
    # Couvertures plus courtes : une deuxieme couche souligne l'anatomie.
    for i in range(7):
        debut = (cote*(.117+.035*i), .420+.034*i, -.010)
        fin = (cote*(.254+.040*i), .425+.042*i, -.010)
        _plume(h, aile, 'Couverture_%s_%s' % (cote, i), debut, fin,
               .075-i*.0025, BLEU_OMBRE if i < 3 else BLEU, origine, .027)
    for i in range(4):
        _plume(h, aile, 'Epaule_duvet_%s_%s' % (cote, i),
               (cote*(.090+i*.026), .447+i*.018, .018),
               (cote*(.170+i*.031), .433+i*.025, .036),
               .056, BLEU_CLAIR, origine, .007)


def _patte_sylphe(h, racine, cote):
    origine = (cote*.053, .237, -.011)
    patte = h.pivot(racine, 'patte', origine, cote=cote)
    h.tube(patte, 'Tarse_sylphe_%s' % cote,
           _points_locaux([(cote*.053, .249, -.016), (cote*.065, .173, .003),
                           (cote*.066, .108, -.008), (cote*.064, .064, .015)], origine),
           [(.025, .029), (.021, .020), (.013, .013), (.014, .012)], BEC, facettes=8)
    for i in (-1, 0, 1):
        debut = (cote*.064, .073, .012)
        milieu = (cote*.064+i*.023, .058, .058)
        fin = (cote*.064+i*.029, .045, .079)
        h.tube(patte, 'Doigt_sylphe_%s_%s' % (cote, i),
               _points_locaux([debut, milieu, fin], origine),
               [(.010, .010), (.009, .008), (.003, .003)], BEC, facettes=6)
        h.tube(patte, 'Griffe_sylphe_%s_%s' % (cote, i),
               _points_locaux([fin, (fin[0], .048, fin[2]+.014),
                               (fin[0], .041, fin[2]+.023)], origine),
               [(.006, .006), (.005, .005), (.001, .001)], SOMBRE, facettes=6)
    h.tube(patte, 'Doigt_arriere_%s' % cote,
           _points_locaux([(cote*.064, .064, .012), (cote*.064, .051, -.037),
                           (cote*.064, .045, -.055)], origine),
           [(.009, .009), (.008, .007), (.002, .002)], BEC, facettes=6)


def _golem(h):
    racine = h.racine('golem')
    masses = [
        _volume(h, racine, 'Thorax', (0, .470, -.019), (.223, .180, .124), JADE),
        _volume(h, racine, 'Abdomen', (0, .360, .015), (.143, .128, .128), JADE),
        _volume(h, racine, 'Bassin', (0, .297, -.041), (.153, .087, .125), JADE),
        _volume(h, racine, 'Cou', (0, .566, .025), (.125, .114, .110), JADE),
        _volume(h, racine, 'Crane', (0, .671, .099), (.132, .124, .113), JADE),
        _volume(h, racine, 'Front', (0, .710, .179), (.105, .067, .046), JADE),
        _volume(h, racine, 'Joue_gauche', (-.082, .625, .172), (.059, .071, .068), JADE),
        _volume(h, racine, 'Joue_droite', (.082, .625, .172), (.059, .071, .068), JADE),
        _volume(h, racine, 'Museau', (0, .608, .216), (.085, .051, .066), JADE),
        _volume(h, racine, 'Menton', (0, .573, .195), (.081, .042, .061), JADE),
    ]
    h.fusionner(racine, 'Anatomie_gardien', masses, JADE, ventre=JADE_OMBRE,
                voxel=.009, triangles=1800)
    # Le crane et les pommettes sont tailles dans la meme pierre que les
    # epaules ; les yeux restent etroits et loges sous de vraies arcades.
    _pierre(h, racine, 'Calotte_frontale', (0, .750, .187), (.064, .050, .029), PIERRE_CLAIRE,
            rotation=(.14, 0, .12))
    for cote in (-1, 1):
        _pierre(h, racine, 'Temple_%s' % cote, (cote*.106, .720, .153),
                (.050, .057, .039), PIERRE, rotation=(.12, 0, -cote*.36))
        _pierre(h, racine, 'Arcade_gardien_%s' % cote, (cote*.067, .705, .229),
                (.057, .018, .026), PIERRE_CLAIRE, rotation=(.17, 0, cote*.19))
        _oeil(h, racine, (cote*.068, .671, .243), (cote*.2, .13, .97),
                .047, .029, '84C8B7')
        _pierre(h, racine, 'Pommette_%s' % cote, (cote*.098, .632, .224),
                (.045, .043, .022), PIERRE, rotation=(.15, 0, -cote*.24))
        _volume(h, racine, 'Oreille_%s' % cote, (cote*.140, .670, .045),
                (.039, .050, .025), JADE_OMBRE)
        _volume(h, racine, 'Oreille_interieure_%s' % cote, (cote*.149, .672, .055),
                (.019, .028, .012), JADE)
    _volume(h, racine, 'Nez', (0, .626, .271), (.043, .021, .014), JADE_OMBRE)
    for cote in (-1, 1):
        _volume(h, racine, 'Narine_%s' % cote, (cote*.022, .619, .282),
                (.010, .006, .003), '2B4039')
    h.tube(racine, 'Commissure', [(-.054, .588, .255), (0, .582, .268),
                                 (.054, .588, .255)],
           [(.003, .003), (.004, .003), (.003, .003)], JADE_OMBRE, facettes=6)
    _pierre(h, racine, 'Sternum', (0, .481, .117), (.065, .109, .027), PIERRE,
            rotation=(.10, 0, 0))
    for cote in (-1, 1):
        _pierre(h, racine, 'Plaque_pectorale_%s' % cote, (cote*.113, .508, .101),
                (.087, .072, .027), PIERRE, rotation=(.16, 0, -cote*.32))
        _pierre(h, racine, 'Flanc_%s' % cote, (cote*.123, .362, .085),
                (.055, .065, .030), JADE, rotation=(0, 0, cote*.25))
        _bras_golem(h, racine, cote)
        _patte_golem(h, racine, cote)
    # Quelques pousses epousent les fissures hautes ; la silhouette reste
    # celle d'un animal mineral, sans casque ni armure rapportes.
    for i in range(3):
        x = (i-1)*.063
        _pierre(h, racine, 'Couronne_roche_%s' % i, (x, .769+(.016 if i == 1 else 0), .072),
                (.043, .032 if i == 1 else .026, .027), PIERRE,
                rotation=(.24, 0, (i-1)*.28))
        _plume(h, racine, 'Pousse_crane_%s' % i,
               (x, .788, .047), (x-.020, .822 if i == 1 else .810, .015),
               .024, MOUSSE, courbure=.005)
    return racine


def _bras_golem(h, racine, cote):
    origine = (cote*.178, .526, .002)
    bras = h.pivot(racine, 'bras', origine, cote=cote)
    masses = [
        _volume(h, bras, 'Deltoide_%s' % cote, _soustraire((cote*.211, .506, .008), origine),
                (.095, .111, .103), JADE),
        _volume(h, bras, 'Biceps_%s' % cote, _soustraire((cote*.252, .404, .036), origine),
                (.084, .127, .084), JADE, rotation=(0, 0, cote*.19)),
        _volume(h, bras, 'Avant_bras_%s' % cote, _soustraire((cote*.288, .259, .132), origine),
                (.084, .148, .082), JADE, rotation=(.47, 0, cote*.09)),
        _volume(h, bras, 'Main_%s' % cote, _soustraire((cote*.306, .115, .263), origine),
                (.088, .062, .081), JADE),
    ]
    for doigt in range(4):
        x = cote*(.251+.035*doigt)
        z = .288+(0.016 if doigt in (1, 2) else 0)
        masses.append(h.tube(bras, 'Doigt_gardien_%s_%s' % (cote, doigt),
                     _points_locaux([(x, .112, z), (x, .073, z+.036),
                                     (x, .046, z+.055)], origine),
                     [(.021, .027), (.022, .021), (.016, .014)], JADE, facettes=8))
    masses.append(h.tube(bras, 'Pouce_%s' % cote,
                   _points_locaux([(cote*.248, .143, .250), (cote*.224, .112, .281),
                                   (cote*.237, .079, .300)], origine),
                   [(.025, .026), (.022, .022), (.016, .016)], JADE, facettes=8))
    h.fusionner(bras, 'Anatomie_bras_%s' % cote, masses, JADE,
                voxel=.008, triangles=1100)
    _pierre(h, bras, 'Rocher_epaule_%s' % cote, _soustraire((cote*.222, .550, .065), origine),
            (.097, .052, .075), PIERRE, rotation=(.24, 0, -cote*.29))
    _pierre(h, bras, 'Rocher_biceps_%s' % cote, _soustraire((cote*.288, .428, .100), origine),
            (.071, .073, .037), PIERRE, rotation=(.25, 0, cote*.19))
    for i in range(2):
        _pierre(h, bras, 'Rocher_avant_bras_%s_%s' % (cote, i),
                _soustraire((cote*(.303+.012*i), .330-.107*i, .171+.074*i), origine),
                (.074, .086, .036), PIERRE if i == 0 else PIERRE_CLAIRE,
                rotation=(.47, 0, cote*(.12 if i == 0 else -.12)))
    for i in range(4):
        _pierre(h, bras, 'Phalange_%s_%s' % (cote, i),
                _soustraire((cote*(.252+.034*i), .107, .307), origine),
                (.024, .025, .033), PIERRE)
    for i in range(3):
        debut = (cote*(.168+.041*i), .594-i*.012, -.008)
        fin = (cote*(.196+.044*i), .619-i*.015, .013)
        _plume(h, bras, 'Mousse_epaule_%s_%s' % (cote, i), debut, fin,
               .030, MOUSSE, origine, .005)


def _patte_golem(h, racine, cote):
    origine = (cote*.098, .294, -.037)
    patte = h.pivot(racine, 'patte', origine, cote=cote)
    masses = [
        _volume(h, patte, 'Cuisse_%s' % cote, _soustraire((cote*.126, .227, -.018), origine),
                (.082, .102, .082), JADE),
        _volume(h, patte, 'Tibia_%s' % cote, _soustraire((cote*.143, .132, .026), origine),
                (.060, .084, .063), JADE),
        _volume(h, patte, 'Pied_%s' % cote, _soustraire((cote*.145, .072, .088), origine),
                (.080, .036, .095), JADE),
    ]
    for i in range(3):
        masses.append(_volume(h, patte, 'Orteil_%s_%s' % (cote, i),
                      _soustraire((cote*.145+(i-1)*.043, .064, .167), origine),
                      (.024, .026, .039), JADE))
    h.fusionner(patte, 'Anatomie_patte_%s' % cote, masses, JADE,
                voxel=.008, triangles=600)
    _pierre(h, patte, 'Genou_%s' % cote, _soustraire((cote*.142, .164, .072), origine),
            (.056, .052, .035), PIERRE)
    for i in range(3):
        _pierre(h, patte, 'Ongle_pierre_%s_%s' % (cote, i),
                _soustraire((cote*.145+(i-1)*.043, .073, .173), origine),
                (.022, .020, .028), PIERRE)


def construire(h, identifiant):
    if identifiant == 'sylphe':
        return _sylphe(h)
    if identifiant == 'golem':
        return _golem(h)
    raise ValueError('Familier aerien ou mineral inconnu : '+identifiant)
