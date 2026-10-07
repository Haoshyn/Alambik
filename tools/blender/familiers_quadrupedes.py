"""Anatomies originales des trois petits compagnons quadrupedes.

Les points sont locaux au parent, en axes Godot : Y vertical et +Z avant.
Le corps reste une peau continue ; les pattes et la queue gardent leurs pivots.
"""


def construire(h, identifiant):
    racine = h.racine(identifiant)
    if identifiant == 'homoncule_encre':
        _renard(h, racine)
    elif identifiant == 'salamandre':
        _salamandre(h, racine)
    elif identifiant == 'ondine':
        _ondine(h, racine)
    else:
        raise ValueError('Quadrupede inconnu : ' + identifiant)
    return racine


def _volume(h, parent, nom, parties, couleur, ventre, triangles=2600):
    objets = [h.ellipsoide(parent, nom + '_forme_' + str(index), point, rayons, couleur)
              for index, (point, rayons) in enumerate(parties)]
    return h.fusionner(parent, nom, objets, couleur, ventre=ventre,
                       voxel=.010, triangles=triangles)


def _patte(h, parent, cote, point, arriere, couleur, ventre, style):
    pivot = h.pivot(parent, 'patte', point, cote * (-1 if arriere else 1))
    if style == 'renard':
        if arriere:
            points = [(0, -.008, 0), (cote * .015, -.099, .058),
                      (cote * .012, -.211, -.027), (cote * .017, -.281, .018)]
            rayons = [(.063, .072), (.042, .044), (.023, .027), (.025, .025)]
            pied = (cote * .017, -.287, .043)
        else:
            points = [(0, -.008, 0), (cote * .016, -.125, .012),
                      (cote * .021, -.238, .023), (cote * .022, -.311, .035)]
            rayons = [(.045, .048), (.030, .034), (.022, .023), (.022, .023)]
            pied = (cote * .022, -.316, .058)
        taille = (.041, .023, .058)
    elif style == 'salamandre':
        points = [(0, 0, 0), (cote * .084, -.044, -.032 if arriere else .017),
                  (cote * .111, -.106, .018 if arriere else .077),
                  (cote * .122, -.153, .072 if arriere else .117)]
        rayons = [(.060, .055), (.045, .042), (.026, .030), (.024, .020)]
        pied = (cote * .126, -.158, .096 if arriere else .139)
        taille = (.050, .025, .068)
    else:
        if arriere:
            points = [(0, 0, 0), (cote * .026, -.102, .047),
                      (cote * .029, -.199, -.012), (cote * .030, -.268, .036)]
            rayons = [(.058, .069), (.042, .046), (.025, .029), (.027, .025)]
            pied = (cote * .030, -.275, .064)
        else:
            points = [(0, 0, 0), (cote * .020, -.124, .008),
                      (cote * .025, -.236, .014), (cote * .027, -.301, .036)]
            rayons = [(.044, .052), (.032, .035), (.025, .027), (.027, .025)]
            pied = (cote * .027, -.308, .065)
        taille = (.052, .024, .067)
    membre = h.tube(pivot, 'Jambe', points, rayons, couleur, facettes=10)
    patte = h.ellipsoide(pivot, 'Appui', pied, taille, couleur)
    h.fusionner(pivot, 'Patte_continue', [membre, patte], couleur,
                ventre=ventre, voxel=.008, triangles=420)
    if style == 'salamandre':
        # Les doigts suivent l'appui reptilien ; les griffes restent minuscules.
        for doigt in range(3):
            x = pied[0] + (doigt - 1) * .029
            fin = (x + (doigt - 1) * .008, pied[1] - .004, pied[2] + .069)
            h.tube(pivot, 'Doigt_' + str(doigt),
                   [(x, pied[1], pied[2] + .034),
                    (fin[0], fin[1] + .004, fin[2] - .012), fin],
                   [(.012, .011), (.009, .007), (.002, .003)], ventre,
                   facettes=7)
    elif style == 'ondine':
        for doigt in range(3):
            x = pied[0] + (doigt - 1) * .024
            h.tube(pivot, 'Orteil_' + str(doigt),
                   [(x, pied[1] + .006, pied[2] + .032),
                    (x + (doigt - 1) * .004, pied[1] + .001, pied[2] + .066)],
                   [(.012, .009), (.008, .006)], ventre, facettes=7)
    return pivot


def _renard(h, racine):
    violet = '66518f'
    clair = 'e6dced'
    lilas = 'a894d0'
    nuit = '342b56'
    parties = [((0, .374, -.075), (.142, .151, .253)),
               ((0, .429, .114), (.133, .164, .140)),
               ((0, .512, .157), (.106, .147, .111)),
               ((0, .616, .218), (.116, .100, .141)),
               ((0, .588, .304), (.092, .066, .103))]
    corps = [h.ellipsoide(racine, 'Anatomie_' + str(index), p, r, violet)
             for index, (p, r) in enumerate(parties)]
    corps.append(h.tube(racine, 'Museau_effile',
                        [(0, .592, .283), (0, .573, .372), (0, .564, .446)],
                        [(.079, .055), (.049, .033), (.020, .017)], violet))
    h.fusionner(racine, 'Peau_renard', corps, violet, ventre=clair,
                voxel=.009, triangles=2700)
    for cote in (-1, 1):
        _patte(h, racine, cote, (cote * .102, .390, .117), False,
               violet, lilas, 'renard')
        _patte(h, racine, cote, (cote * .111, .359, -.239), True,
               violet, lilas, 'renard')
        # Une seule lame epaisse prolonge le crane, puis se couche vers l'arriere.
        h.feuille(racine, 'Oreille',
                  [(cote * .073, .670, .180), (cote * .107, .742, .157),
                   (cote * .147, .800, .126), (cote * .169, .846, .091)],
                  [.065, .104, .060, .0], violet, epaisseur=.026)
        h.oeil(racine, (cote * .095, .626, .312),
                (cote * .65, .26, .72), .056, .030, '9e81cb')
        for rang in range(2):
            h.feuille(racine, 'Joue_fine',
                      [(cote * .098, .600 - rang * .018, .258),
                       (cote * .153, .598 - rang * .024, .207),
                       (cote * .185, .621 - rang * .034, .173)],
                      [.024, .056 - rang * .009, .0], clair,
                      epaisseur=.015)
    h.ellipsoide(racine, 'Truffe', (0, .565, .453), (.022, .015, .014), nuit)
    h.tube(racine, 'Bouche', [(-.026, .551, .420), (0, .548, .443),
                             (.026, .551, .420)],
           [(.0027, .0025)] * 3, nuit, facettes=6)
    queue = h.pivot(racine, 'queue', (0, .377, -.325))
    pan = h.tube(queue, 'Queue_encre',
                 [(0, 0, 0), (-.064, .060, -.102), (-.213, .153, -.150),
                  (-.362, .263, -.082), (-.397, .354, .037),
                  (-.315, .414, .116), (-.187, .422, .096)],
                 [(.050, .055), (.077, .083), (.098, .108),
                  (.092, .098), (.065, .076), (.035, .046), (.003, .006)], violet,
                 facettes=12)
    h.peindre(pan, violet, ventre=lilas)
    for rang in range(3):
        x = -.208 - rang * .040
        h.feuille(queue, 'Flamme_encre_' + str(rang),
                  [(x, .185 + rang * .044, -.090 + rang * .012),
                   (x - .141, .308 + rang * .024, .007),
                   (x - .139, .413 + rang * .016, .115),
                   (x + .026, .445 - rang * .008, .133 + rang * .019)],
                  [.018, .078 - rang * .013, .052 - rang * .009, .0],
                  lilas if rang != 1 else clair, epaisseur=.011)


def _salamandre(h, racine):
    ambre = 'ca8647'
    dore = 'f0c578'
    creme = 'f5dfab'
    nuit = '564034'
    parties = [((0, .247, -.083), (.150, .116, .270)),
               ((0, .255, .129), (.153, .123, .147)),
               ((0, .274, .247), (.133, .079, .156)),
               ((0, .252, .361), (.098, .054, .128)),
               ((0, .228, .337), (.119, .032, .143))]
    corps = [h.ellipsoide(racine, 'Anatomie_' + str(index), p, r, ambre)
             for index, (p, r) in enumerate(parties)]
    corps.append(h.tube(racine, 'Museau_reptile',
                        [(0, .252, .340), (0, .251, .442), (0, .246, .520)],
                        [(.098, .046), (.064, .031), (.027, .020)], ambre))
    h.fusionner(racine, 'Peau_salamandre', corps, ambre, ventre=creme,
                voxel=.009, triangles=2700)
    for cote in (-1, 1):
        _patte(h, racine, cote, (cote * .123, .231, .137), False,
               ambre, dore, 'salamandre')
        _patte(h, racine, cote, (cote * .123, .231, -.238), True,
               ambre, dore, 'salamandre')
        h.oeil(racine, (cote * .111, .298, .363),
                (cote * .65, .53, .61), .056, .027, 'a96c24')
        h.feuille(racine, 'Arcade',
                  [(cote * .086, .324, .357), (cote * .153, .332, .309),
                   (cote * .173, .344, .249)], [.026, .046, .0], dore,
                  epaisseur=.016)
        for rang in range(3):
            h.feuille(racine, 'Corolle_temporale',
                      [(cote * .118, .278 + rang * .019, .256 - rang * .025),
                       (cote * (.174 + rang * .009), .311 + rang * .025, .211 - rang * .045),
                       (cote * (.232 - rang * .011), .342 + rang * .022, .145 - rang * .044),
                       (cote * (.217 - rang * .018), .373 + rang * .022, .074 - rang * .044)],
                      [.019, .043 - rang * .004, .025 - rang * .003, .0],
                      dore if rang != 1 else creme, epaisseur=.015)
        h.ellipsoide(racine, 'Narine', (cote * .033, .258, .496),
                     (.006, .0045, .0045), nuit)
    h.tube(racine, 'Bouche', [(-.049, .232, .451), (0, .227, .503),
                             (.049, .232, .451)],
           [(.0028, .0025)] * 3, nuit, facettes=6)
    for rang, z in enumerate([-.241, -.090, .056]):
        h.feuille(racine, 'Crete_dorsale',
                  [(0, .339 + rang * .016, z + .044),
                   (0, .413 + rang * .012, z + .016),
                   (-.016, .468 + rang * .008, z - .043),
                   (-.021, .497 - rang * .025, z - .118)],
                  [.041, .079 - rang * .006, .057 - rang * .005, .0],
                  dore, epaisseur=.021)
    h.feuille(racine, 'Crete_frontale',
              [(0, .322, .300), (0, .390, .252), (0, .449, .176)],
              [.040, .061, .0], dore, epaisseur=.019)
    queue = h.pivot(racine, 'queue', (0, .253, -.317))
    pan = h.tube(queue, 'Queue_braise',
                 [(0, 0, 0), (-.064, .016, -.113), (-.222, .067, -.209),
                  (-.393, .170, -.194), (-.430, .278, -.093),
                  (-.338, .368, -.022), (-.204, .410, -.062)],
                 [(.084, .065), (.074, .057), (.057, .048), (.043, .037),
                  (.028, .026), (.014, .016), (.002, .004)], ambre,
                 facettes=12)
    h.peindre(pan, ambre, ventre=dore)
    for rang in range(3):
        h.feuille(queue, 'Flamme_braise',
                  [(-.365 + rang * .026, .246 + rang * .038, -.092),
                   (-.420 + rang * .037, .352 + rang * .023, -.024),
                   (-.357 + rang * .036, .428 + rang * .009, .001),
                   (-.213 + rang * .013, .443 - rang * .009, -.039)],
                  [.015, .067 - rang * .010, .047 - rang * .009, .0],
                  dore if rang != 1 else creme, epaisseur=.013)


def _ondine(h, racine):
    turquoise = '579baf'
    ivoire = 'e3eeeb'
    clair = 'afdce0'
    lilas = 'b5a8d1'
    nuit = '3d6479'
    parties = [((0, .350, -.086), (.145, .158, .257)),
               ((0, .426, .108), (.144, .175, .152)),
               ((0, .517, .161), (.119, .149, .120)),
               ((0, .607, .243), (.129, .104, .146)),
               ((0, .571, .342), (.101, .057, .101))]
    corps = [h.ellipsoide(racine, 'Anatomie_' + str(index), p, r, turquoise)
             for index, (p, r) in enumerate(parties)]
    corps.append(h.tube(racine, 'Museau_aquatique',
                        [(0, .580, .319), (0, .565, .391), (0, .562, .447)],
                        [(.080, .047), (.051, .032), (.024, .019)], turquoise))
    h.fusionner(racine, 'Peau_ondine', corps, turquoise, ventre=ivoire,
                voxel=.009, triangles=2750)
    for cote in (-1, 1):
        _patte(h, racine, cote, (cote * .107, .386, .137), False,
               turquoise, ivoire, 'ondine')
        _patte(h, racine, cote, (cote * .114, .354, -.243), True,
               turquoise, ivoire, 'ondine')
        h.oeil(racine, (cote * .105, .611, .341),
                (cote * .65, .30, .70), .058, .030, '487b89')
        # Les branchies ont trois rayons fins, avec des membranes soutenues.
        for rang in range(3):
            base = (cote * .121, .617 - rang * .027, .184)
            coude = (cote * (.191 + rang * .017), .667 - rang * .050, .156)
            penche = (cote * (.270 + rang * .010), .697 - rang * .069, .091)
            pointe = (cote * (.291 + rang * .001), .717 - rang * .087, .017)
            h.feuille(racine, 'Branchie_' + str(rang), [base, coude, penche, pointe],
                      [.019, .048 - rang * .003, .036 - rang * .005, .0],
                      clair if rang != 1 else lilas, epaisseur=.011)
            h.tube(racine, 'Rayon_branchial_' + str(rang),
                   [base, coude, penche, pointe],
                   [(.0055, .0055), (.0045, .0045), (.0035, .0035), (.001, .001)],
                   ivoire, facettes=6)
    h.ellipsoide(racine, 'Nez', (0, .566, .450), (.016, .009, .009), nuit)
    h.tube(racine, 'Bouche', [(-.026, .549, .427), (0, .546, .442),
                             (.026, .549, .427)],
           [(.0025, .0024)] * 3, nuit, facettes=6)
    h.feuille(racine, 'Nageoire_frontale',
              [(0, .677, .180), (-.012, .730, .157), (.022, .779, .140)],
              [.030, .051, .0], clair, epaisseur=.014)
    queue = h.pivot(racine, 'queue', (0, .378, -.330))
    pan = h.tube(queue, 'Queue_ondine',
                 [(0, 0, 0), (.068, .051, -.110), (.222, .131, -.178),
                  (.355, .229, -.140), (.367, .330, -.042),
                  (.285, .387, .040), (.161, .390, .043)],
                 [(.056, .057), (.061, .064), (.052, .055), (.038, .042),
                  (.024, .031), (.013, .022), (.004, .010)], turquoise, facettes=12)
    h.peindre(pan, turquoise, ventre=clair)
    for cote in (-1, 1):
        h.feuille(queue, 'Eventail_caudal',
                  [(.316, .302, -.058), (.342 + cote * .035, .378, .032),
                   (.252 + cote * .068, .433, .130),
                   (.125 + cote * .072, .421, .143)],
                  [.019, .095, .077, .0], clair, epaisseur=.013)
        h.feuille(queue, 'Nervure_caudale',
                  [(.243, .172, -.125), (.372 + cote * .024, .280, -.064),
                   (.314 + cote * .043, .382, .061),
                   (.188 + cote * .054, .413, .127)],
                  [.014, .041, .047, .0], ivoire if cote < 0 else lilas,
                  epaisseur=.010)
