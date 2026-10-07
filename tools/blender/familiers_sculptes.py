"""Sculptures originales des compagnons, avec pivots conserves pour Godot.

Blender --background --python tools/blender/familiers_sculptes.py -- [ID ...]
Les points des modules sont locaux au parent, en reperes Godot (Y vertical).
"""
import math
import sys
from pathlib import Path

import bpy
from mathutils import Matrix, Vector

RACINE = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(Path(__file__).parent))


def V(point):
    x, y, z = point
    return Vector((x, -z, y))


def _lineaire(v):
    return v / 12.92 if v <= .04045 else ((v + .055) / 1.055) ** 2.4


def _couleur(hexadecimal):
    valeur = hexadecimal.lstrip('#')
    return tuple(_lineaire(int(valeur[i:i+2], 16) / 255) for i in (0, 2, 4))


def _matiere():
    nom = 'Familiers_Peinture'
    mat = bpy.data.materials.get(nom)
    if mat:
        return mat
    mat = bpy.data.materials.new(nom)
    mat.use_nodes = True
    bsdf = mat.node_tree.nodes.get('Principled BSDF')
    attribut = mat.node_tree.nodes.new('ShaderNodeVertexColor')
    attribut.layer_name = 'Couleur'
    mat.node_tree.links.new(attribut.outputs['Color'], bsdf.inputs['Base Color'])
    bsdf.inputs['Roughness'].default_value = .72
    bsdf.inputs['Specular IOR Level'].default_value = .26
    return mat


def _lier(objet, parent):
    objet.parent = parent
    objet.matrix_parent_inverse = Matrix.Identity(4)
    return objet


def racine(identifiant):
    objet = bpy.data.objects.new(identifiant, None)
    bpy.context.collection.objects.link(objet)
    return objet


def pivot(parent, role, point, cote=1):
    numero = len([o for o in bpy.data.objects if o.name.startswith('Art_')])
    objet = bpy.data.objects.new('Art_%s_%s_%d' % (role, 'G' if cote < 0 else 'D', numero), None)
    bpy.context.collection.objects.link(objet)
    _lier(objet, parent)
    objet.location = V(point)
    return objet


def _fondu(a, b, valeur):
    t = max(0, min(1, (valeur-a)/(b-a)))
    return t*t*(3-2*t)


def _peinture_anatomique(objet, sommet, teinte, clair):
    point = objet.matrix_basis @ sommet.co
    x, y, z = point.x, point.z, -point.y
    nom = objet.name
    if nom == 'Peau_renard':
        museau = _fondu(.273, .344, z)*_fondu(.495, .55, y)
        gorge = _fondu(.182, .228, z)*(1-_fondu(.50, .57, y))*_fondu(.29, .37, y)
        teinte = teinte.lerp(clair, max(museau, gorge)*.98)
        raie = (1-_fondu(.020, .072, abs(x)))*_fondu(.43, .51, y)
        raie *= (1-_fondu(.08, .17, z))*_fondu(-.28, -.19, z)
        teinte = teinte.lerp(Vector(_couleur('a999cf')), raie*.32)
    elif nom == 'Peau_ondine':
        museau = _fondu(.275, .343, z)*_fondu(.496, .55, y)
        gorge = _fondu(.174, .234, z)*(1-_fondu(.515, .571, y))*_fondu(.27, .34, y)
        teinte = teinte.lerp(clair, max(museau, gorge)*.97)
        vague = math.sin(z*39+abs(x)*28+y*11)
        ecailles = _fondu(.75, .98, vague)*_fondu(.44, .48, y)*(1-_fondu(.11, .25, z))
        teinte = teinte.lerp(Vector(_couleur('a2cfd1')), ecailles*.20)
    elif nom == 'Peau_salamandre':
        museau = _fondu(.31, .41, z)*(1-_fondu(.28, .33, y))
        teinte = teinte.lerp(clair, museau*.90)
        dorsal = _fondu(.265, .33, y)*(1-_fondu(.16, .24, z))
        teinte *= 1-dorsal*.13
        ecailles = _fondu(.77, .99, math.cos(z*53+abs(x)*32))*dorsal
        teinte = teinte.lerp(Vector(_couleur('e4b76d')), ecailles*.26)
    elif nom == 'Anatomie_sylphe':
        face = _fondu(.068, .115, z)*_fondu(.48, .535, y)
        gorge = _fondu(.065, .11, z)*(1-_fondu(.485, .52, y))*_fondu(.26, .33, y)
        teinte = teinte.lerp(clair, max(face, gorge)*.95)
    elif nom == 'Anatomie_gardien':
        masque = _fondu(.158, .235, z)*_fondu(.542, .607, y)
        teinte = teinte.lerp(Vector(_couleur('b8bea8')), masque*.85)
    return teinte


def peindre(objet, couleur, ventre=None):
    _normales(objet)
    base = Vector(_couleur(couleur))
    clair = Vector(_couleur(ventre)) if ventre else base
    attribut = objet.data.color_attributes.get('Couleur')
    if not attribut:
        attribut = objet.data.color_attributes.new(name='Couleur', type='FLOAT_COLOR', domain='CORNER')
    valeurs = [v.co.z for v in objet.data.vertices]
    bas, haut = min(valeurs), max(valeurs)
    for boucle in objet.data.loops:
        sommet = objet.data.vertices[boucle.vertex_index]
        t = (sommet.co.z - bas) / max(.001, haut - bas)
        # Le ventre se lit sur les surfaces basses et les plans tournant vers l'avant.
        ventral = max(0, min(1, (-sommet.normal.z + .18) * 1.2))
        ventral = max(ventral, max(0, min(1, -sommet.normal.y * 1.6 - .3)) * max(0, 1 - t * 1.05))
        teinte = base.lerp(clair, ventral * .94)
        teinte = _peinture_anatomique(objet, sommet, teinte, clair)
        grain = math.sin(sommet.co.x * 45 + sommet.co.z * 11) * math.sin(sommet.co.y * 37) * .022
        lumiere = .86 + t * .16 + max(0, sommet.normal.z) * .055 + grain
        teinte *= lumiere
        attribut.data[boucle.index].color = (*teinte, 1)
    objet.data.materials.clear()
    objet.data.materials.append(_matiere())
    objet['couleur_source'] = couleur
    return objet


def ellipsoide(parent, nom, point, rayons, couleur, rotation=(0, 0, 0)):
    petit = max(rayons) <= .07
    bpy.ops.mesh.primitive_uv_sphere_add(segments=12 if petit else 20, ring_count=8 if petit else 12)
    objet = bpy.context.object
    objet.name = nom
    objet.location = V(point)
    objet.scale = (rayons[0], rayons[2], rayons[1])
    changement = Matrix(((1,0,0),(0,0,-1),(0,1,0)))
    from mathutils import Euler
    objet.rotation_euler = (changement @ Euler(rotation, 'XYZ').to_matrix() @ changement.transposed()).to_euler()
    bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)
    _lier(objet, parent)
    for polygone in objet.data.polygons:
        polygone.use_smooth = True
    return peindre(objet, couleur)


def _maillage(parent, nom, sommets, faces, couleur, lisse=True):
    maillage = bpy.data.meshes.new(nom)
    maillage.from_pydata(sommets, [], faces)
    maillage.update()
    objet = bpy.data.objects.new(nom, maillage)
    bpy.context.collection.objects.link(objet)
    _lier(objet, parent)
    for polygone in maillage.polygons:
        polygone.use_smooth = lisse
    return peindre(objet, couleur)


def _interpoler(points, valeurs, subdivisions=4):
    lignes, tailles = [], []
    points = [Vector(p) for p in points]
    for i in range(len(points)-1):
        a, b = points[max(0,i-1)], points[i]
        c, d = points[i+1], points[min(len(points)-1,i+2)]
        for j in range(subdivisions):
            t = j / subdivisions
            lignes.append((b*2 + (c-a)*t + (a*2-b*5+c*4-d)*t*t + (-a+b*3-c*3+d)*t*t*t)*.5)
            tailles.append(tuple(valeurs[i][k]*(1-t)+valeurs[i+1][k]*t for k in range(len(valeurs[i]))))
    lignes.append(points[-1])
    tailles.append(valeurs[-1])
    return lignes, tailles


def tube(parent, nom, points, rayons, couleur, facettes=12):
    lignes, tailles = _interpoler(points, rayons)
    sommets, faces = [], []
    for i, point in enumerate(lignes):
        tangente = lignes[min(i+1,len(lignes)-1)] - lignes[max(i-1,0)]
        tangente.normalize()
        cote = tangente.cross(Vector((0,1,0)))
        if cote.length < .01:
            cote = Vector((1,0,0))
        cote.normalize()
        dessus = cote.cross(tangente).normalized()
        for j in range(facettes):
            angle = math.tau*j/facettes
            q = point + cote*math.cos(angle)*max(.0004,tailles[i][0]) + dessus*math.sin(angle)*max(.0004,tailles[i][1])
            sommets.append(V(q))
        if i:
            for j in range(facettes):
                a = (i-1)*facettes+j
                b = (i-1)*facettes+(j+1)%facettes
                c = i*facettes+(j+1)%facettes
                d = i*facettes+j
                faces.append((a,b,c,d))
    faces.append(tuple(reversed(range(facettes))))
    faces.append(tuple((len(lignes)-1)*facettes+j for j in range(facettes)))
    objet = _maillage(parent,nom,sommets,faces,couleur)
    _normales(objet)
    return objet


def feuille(parent, nom, points, largeurs, couleur, epaisseur=.015):
    lignes, tailles = _interpoler(points, [(l,) for l in largeurs], 3)
    sommets, faces = [], []
    for i, point in enumerate(lignes):
        tangente = (lignes[min(i+1,len(lignes)-1)]-lignes[max(i-1,0)]).normalized()
        cote = tangente.cross(Vector((0,1,0)))
        if cote.length < .02:
            # Les oreilles verticales s'etalent sur X ; le relief avance vers la camera.
            cote = Vector((1,0,0))
        cote.normalize()
        normale = cote.cross(tangente).normalized()
        if normale.y < 0:
            normale = -normale
        largeur = max(.0004, tailles[i][0]) * .5
        for lat, relief in [(-1,0),(0,1),(1,0),(0,-.5)]:
            sommets.append(V(point+cote*largeur*lat+normale*epaisseur*relief))
        if i:
            for j in range(4):
                faces.append(((i-1)*4+j,(i-1)*4+(j+1)%4,i*4+(j+1)%4,i*4+j))
    faces.append((3,2,1,0))
    a = (len(lignes)-1)*4
    faces.append((a,a+1,a+2,a+3))
    objet = _maillage(parent,nom,sommets,faces,couleur)
    _normales(objet)
    return objet


def _activer(objet):
    bpy.ops.object.select_all(action='DESELECT')
    objet.select_set(True)
    bpy.context.view_layer.objects.active = objet


def _normales(objet):
    _activer(objet)
    bpy.ops.object.mode_set(mode='EDIT')
    bpy.ops.mesh.select_all(action='SELECT')
    bpy.ops.mesh.normals_make_consistent(inside=False)
    bpy.ops.object.mode_set(mode='OBJECT')


def fusionner(parent, nom, objets, couleur, ventre=None, voxel=.012, triangles=2600):
    # La fusion retire les intersections de primitives avant la peinture finale.
    bpy.ops.object.select_all(action='DESELECT')
    for objet in objets:
        objet.select_set(True)
    bpy.context.view_layer.objects.active = objets[0]
    bpy.ops.object.join()
    objet = bpy.context.object
    objet.name = nom
    bpy.ops.object.transform_apply(location=False,rotation=True,scale=True)
    remesh = objet.modifiers.new('Sculpture_continue', 'REMESH')
    remesh.mode = 'VOXEL'
    remesh.voxel_size = voxel
    remesh.use_smooth_shade = True
    bpy.ops.object.modifier_apply(modifier=remesh.name)
    lisse = objet.modifiers.new('Plans_souples', 'SMOOTH')
    lisse.factor = .85
    lisse.iterations = 4
    bpy.ops.object.modifier_apply(modifier=lisse.name)
    objet.data.calc_loop_triangles()
    compte = len(objet.data.loop_triangles)
    if compte > triangles:
        reduction = objet.modifiers.new('Maillage_mobile', 'DECIMATE')
        reduction.ratio = triangles/compte
        bpy.ops.object.modifier_apply(modifier=reduction.name)
    for polygone in objet.data.polygons:
        polygone.use_smooth = True
    return peindre(objet,couleur,ventre)


def oeil(parent, centre, normale, largeur, hauteur, iris):
    centre, normale = Vector(centre), Vector(normale).normalized()
    droite = Vector((0,1,0)).cross(normale).normalized()
    haut = normale.cross(droite).normalized()
    sommets, faces = [], []
    # Lentille en amande, avec extremites affinees dans le crane.
    for couche, echelle, avance in [(0,1.14,0),(1,1,.003),(2,0,.011)]:
        if couche == 2:
            sommets.append(V(centre+normale*avance))
            continue
        for i in range(20):
            angle = math.tau*i/20
            x = math.cos(angle)*largeur*.5*echelle
            y = math.sin(angle)*hauteur*.5*echelle*(.65+.35*abs(math.sin(angle)))
            sommets.append(V(centre+droite*x+haut*y+normale*avance))
    for i in range(20):
        j = (i+1)%20
        faces.append((i,j,20+j,20+i))
        faces.append((20+i,20+j,40))
    lentille = _maillage(parent,'Regard',sommets,faces,'e8e6d7')
    attribut = lentille.data.color_attributes['Couleur']
    sombre = _couleur('202331')
    for polygon in lentille.data.polygons:
        if len(polygon.vertices) == 4:
            for boucle in polygon.loop_indices:
                attribut.data[boucle].color = (*sombre,1)
    # Petits iris bombes dans la lentille, sans grands globes detaches du visage.
    position = centre+normale*.011
    pupille = ellipsoide(parent,'Iris',position,(largeur*.225,hauteur*.38,.008),iris)
    quat = V(normale).to_track_quat('Y','Z')
    pupille.rotation_euler = quat.to_euler()
    noir = ellipsoide(parent,'Pupille',centre+normale*.018,(largeur*.095,hauteur*.265,.006),'172530')
    noir.rotation_euler = quat.to_euler()
    reflet = ellipsoide(parent,'Reflet',centre+normale*.024+haut*hauteur*.16-droite*largeur*.10,(largeur*.04,hauteur*.07,.003),'fff8e1')
    reflet.rotation_euler = quat.to_euler()
    return lentille


def finaliser(root, identifiant):
    # Un seul materiau peint par pivot : la palette ne multiplie pas les surfaces.
    parents = [root] + [o for o in root.children_recursive if o.type == 'EMPTY']
    for parent in parents:
        maillages = [o for o in parent.children if o.type == 'MESH']
        if not maillages:
            continue
        bpy.ops.object.select_all(action='DESELECT')
        for objet in maillages:
            objet.select_set(True)
        bpy.context.view_layer.objects.active = maillages[0]
        if len(maillages) > 1:
            bpy.ops.object.join()
        objet = bpy.context.object
        objet.name = 'Peint_' + parent.name
        _normales(objet)
        for polygone in objet.data.polygons:
            polygone.material_index = 0
        objet.data.materials.clear()
        objet.data.materials.append(_matiere())
    dossier = RACINE/'assets/3d/familiers'
    sources = RACINE/'assets/3d/sources/familiers'
    dossier.mkdir(parents=True,exist_ok=True)
    sources.mkdir(parents=True,exist_ok=True)
    bpy.context.preferences.filepaths.save_version = 0
    bpy.ops.wm.save_as_mainfile(filepath=str(sources/(identifiant+'.blend')))
    bpy.ops.object.select_all(action='SELECT')
    bpy.ops.export_scene.gltf(filepath=str(dossier/(identifiant+'.glb')),export_format='GLB',use_selection=True,export_yup=True,export_all_vertex_colors=True,export_attributes=False,export_animations=False,export_extras=False)
    triangles = 0
    for objet in root.children_recursive:
        if objet.type == 'MESH':
            objet.data.calc_loop_triangles()
            triangles += len(objet.data.loop_triangles)
    print('FAMILIER_OK',identifiant,'triangles',triangles,flush=True)


def construire(identifiant):
    bpy.ops.wm.read_factory_settings(use_empty=True)
    if identifiant in ['homoncule_encre','salamandre','ondine']:
        from familiers_quadrupedes import construire as fabriquer
    else:
        from familiers_aerien_mineral import construire as fabriquer
    root = fabriquer(sys.modules[__name__],identifiant)
    finaliser(root,identifiant)


if __name__ == '__main__':
    arguments = sys.argv[sys.argv.index('--')+1:] if '--' in sys.argv else []
    for identifiant in arguments or ['homoncule_encre','salamandre','ondine','sylphe','golem']:
        construire(identifiant)
