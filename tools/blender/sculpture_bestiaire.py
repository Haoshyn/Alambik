"""Volumes et assemblages du bestiaire, en coordonnees Blender (Z en haut)."""
import math
from contextlib import contextmanager

import bpy
from mathutils import Vector
import build_all as b


def palette():
    b.materiaux()
    couleurs = {'encre': '303241', 'violet': '746698', 'papier': 'eee0be',
                'cuivre': 'c79d69', 'metal': '526270', 'bois': '71534c',
                'cuir': '78505b', 'magie': 'e7b9f0', 'cristal': '88dfdb',
                'feu': 'ff953f', 'givre': 'a4e9f5', 'venin': 'b9e16d',
                'sang': 'b54165', 'pierre': '69958c', 'pierre_claire': 'c5dbb4'}
    for nom, hexad in couleurs.items():
        rgb = [int(hexad[i:i+2], 16) / 255 for i in (0, 2, 4)]
        rgb = [x / 12.92 if x <= .04045 else ((x + .055) / 1.055) ** 2.4 for x in rgb]
        mat = b.MAT[nom]
        mat.diffuse_color = (*rgb, 1)
        mat.node_tree.nodes['Principled BSDF'].inputs['Base Color'].default_value = (*rgb, 1)


@contextmanager
def articulation(nom, point):
    parent = b.ACTEUR
    pivot = bpy.data.objects.new('Art_' + nom, None)
    bpy.context.collection.objects.link(pivot)
    pivot.parent = parent
    b.ACTEUR = pivot
    try:
        yield pivot
    finally:
        # Construire dans le repere commun, puis placer l'origine a l'articulation.
        for enfant in list(pivot.children):
            enfant.location -= Vector(point)
        pivot.location = point
        b.ACTEUR = parent


def courbe(nom, points, rayons, mat, faces=8):
    sommets, polygones = [], []
    for i, p in enumerate(points):
        tangente = Vector(points[min(i+1, len(points)-1)]) - Vector(points[max(0, i-1)])
        axe = tangente.normalized()
        u = axe.cross(Vector((0, 1, 0))).normalized()
        if u.length < .01:
            u = axe.cross(Vector((1, 0, 0))).normalized()
        v = axe.cross(u).normalized()
        for j in range(faces):
            a = math.tau * j / faces
            sommets.append(Vector(p) + rayons[i] * (u * math.cos(a) + v * math.sin(a)))
    for i in range(len(points)-1):
        for j in range(faces):
            a, c = i*faces+j, i*faces+(j+1) % faces
            polygones.append((a, c, c+faces, a+faces))
    polygones += [tuple(reversed(range(faces))), tuple(range(len(sommets)-faces, len(sommets)))]
    mesh = bpy.data.meshes.new(nom)
    mesh.from_pydata(sommets, [], polygones)
    mesh.update()
    obj = bpy.data.objects.new(nom, mesh)
    bpy.context.collection.objects.link(obj)
    for p in mesh.polygons:
        p.use_smooth = len(p.vertices) == 4
    return b.finir(obj, nom, mat)


def regard(y, z, ecart=.11, taille=.055, mat='magie'):
    for c in (-1, 1):
        # Une paupiere sculptee enchasse le regard au lieu de coller un oeil rond.
        b.boule('Orbite', (c*ecart, y+.012, z), (taille*1.40, taille*.62, taille), 'encre', 12)
        iris = b.boule('Iris', (c*ecart, y-.020, z), (taille*1.05, taille*.27, taille*.51), mat, 12)
        iris.rotation_euler.y = -c*.16
        b.boule('Pupille', (c*ecart, y-.035, z-.004), (taille*.20, taille*.12, taille*.42), 'encre', 8)
        courbe('Paupiere', [(c*(ecart-taille*1.18),y-.012,z+taille*.21),
                           (c*ecart,y-.022,z+taille*.70),
                           (c*(ecart+taille*1.20),y,z+taille*.91)],
               [taille*.15,taille*.24,taille*.09], 'encre', 6)


def gemme(point, rayon=.08, mat='magie'):
    x, y, z = point
    chaton = b.boite('Chaton', (x, y+.014, z), (rayon*1.65,.033,rayon*1.65), 'cuivre', .010)
    chaton.rotation_euler.y = math.pi/4
    pierre = b.cone('Gemme_taillee', (x,y-.009,z), rayon, rayon*.54, rayon*.40, mat, 4)
    pierre.rotation_euler = (math.pi/2,0,math.pi/4)


def pan_tissu(nom, points, largeurs, mat='papier'):
    sommets, faces = [], []
    for point, largeur in zip(points, largeurs):
        for cote in (-1,0,1):
            sommets.append((point[0]+cote*largeur, point[1]-.016*(1-abs(cote)), point[2]))
    for i in range(len(points)-1):
        for j in range(2):
            a = i*3+j
            faces.append((a,a+1,a+4,a+3))
    mesh = bpy.data.meshes.new(nom)
    mesh.from_pydata(sommets,[],faces)
    mesh.update()
    objet = bpy.data.objects.new(nom,mesh)
    bpy.context.collection.objects.link(objet)
    bpy.context.view_layer.objects.active = objet
    objet.select_set(True)
    lissage = objet.modifiers.new('Drape','SUBSURF')
    lissage.levels = 2
    bpy.ops.object.modifier_apply(modifier=lissage.name)
    epaisseur = objet.modifiers.new('Ourlet','SOLIDIFY')
    epaisseur.thickness = .012
    bpy.ops.object.modifier_apply(modifier=epaisseur.name)
    for face in objet.data.polygons: face.use_smooth = True
    return b.finir(objet,nom,mat)


def plume(nom, debut, fin, largeur, mat='papier'):
    d, f = Vector(debut), Vector(fin)
    points = [d.lerp(f, t) + Vector((0, -.045*math.sin(t*math.pi), 0)) for t in (0, .28, .58, .82, 1)]
    obj = courbe(nom, points, [.014, largeur*.75, largeur, largeur*.64, .002], mat, 6)
    obj.scale.y = .32
    b.tige('Nervure', debut, fin, .012, 'cuivre')


def pattes(nombre=6, largeur=.38, hauteur=.29, mat='encre'):
    for c in (-1, 1):
        for i in range(nombre//2):
            y = (i-(nombre//2-1)*.5)*.20
            cote = 'g' if c < 0 else 'd'
            genou = (c*largeur,y*1.25,hauteur*.8)
            pied = (c*(largeur+.055),y*1.45-.05,.055)
            with articulation('patte_%s_%d' % (cote, i), (c*.19, y, hauteur)):
                courbe('Cuisse', [(c*.18,y,hauteur), genou], [.046,.035], mat)
                with articulation('tibia_%s_%d' % (cote, i), genou):
                    courbe('Tibia', [genou, pied], [.033,.017], mat)
                    b.boule('Joint', genou, (.038,.041,.039), 'cuivre', 10)
                    b.boule('Griffe', pied, (.042,.075,.034), mat, 12)
                    appui = bpy.data.objects.new('Appui_%s_%d' % (cote, i), None)
                    bpy.context.collection.objects.link(appui)
                    appui.parent = b.ACTEUR
                    appui.location = pied


def regrouper():
    """Une surface peinte par articulation, avec le meme atlas pour toute la horde."""
    from matieres_bestiaire import preparer, peindre, sculpter
    mat = preparer()
    sculpter([o for o in bpy.context.scene.objects if o.type == 'MESH'])
    groupes = {}
    for obj in list(bpy.context.scene.objects):
        if obj.type != 'MESH':
            continue
        peindre(obj)
        obj.data.materials.clear()
        obj.data.materials.append(mat)
        groupes.setdefault(obj.parent, []).append(obj)
    for parent, objets in groupes.items():
        bpy.ops.object.select_all(action='DESELECT')
        for obj in objets:
            obj.select_set(True)
        bpy.context.view_layer.objects.active = objets[0]
        if len(objets) > 1:
            bpy.ops.object.join()
        objets[0].name = 'Email_' + parent.name
    return mat
