"""Atlas peint partage, plis et modeles de couleur conserves dans les sources GLB."""
import ast
import math
import re

import bpy
from mathutils import Vector, noise
from mathutils.bvhtree import BVHTree
import build_all as b

ATLAS = b.SORTIE / 'textures/bestiaire_matieres_peintes.png'
TISSUS = ('Manteau', 'Capuche', 'Manche', 'Pan_de_parchemin', 'Signet')
OCCLUSION = None


def profil_surfaces():
    """Lire les constantes litterales partagees avec le rendu Godot."""
    source = (b.RACINE / 'data/presentation/matieres_bestiaire.gd').read_text(encoding='utf-8')
    profil = {nom: ast.literal_eval(valeur) for nom, valeur in
              re.findall(r'^const ([A-Z_]+) := (.+)$', source, re.MULTILINE)}
    if len(profil['SURFACES']) != 4:
        raise ValueError('Le bestiaire attend quatre matieres dans son atlas.')
    return profil


def sculpter(objets):
    global OCCLUSION
    for obj in objets:
        if obj.data.name.startswith('Torus'):
            for face in obj.data.polygons:
                face.use_smooth = True
        if not obj.name.startswith(('Manteau', 'Capuche', 'Ventre', 'Chaudron', 'Poignee')): continue
        bpy.ops.object.select_all(action='DESELECT')
        obj.select_set(True)
        bpy.context.view_layer.objects.active = obj
        lissage = obj.modifiers.new('Volumes_souples', 'SUBSURF')
        lissage.levels = 1 if obj.name.startswith(('Ventre','Chaudron','Poignee')) else 2
        bpy.ops.object.modifier_apply(modifier=lissage.name)
        if obj.name.startswith(('Manteau','Capuche')):
            for sommet in obj.data.vertices:
                x, y, z = sommet.co
                angle = math.atan2(y, x)
                pli = math.cos(angle*7+.6*z)*.008 + math.sin(angle*3-z*4)*.004
                sommet.co.x += math.cos(angle)*pli
                sommet.co.y += math.sin(angle)*pli
        for face in obj.data.polygons: face.use_smooth = True
        obj.data.update()
    bpy.context.view_layer.update()
    sommets, faces = [], []
    for obj in objets:
        debut = len(sommets)
        sommets.extend(obj.matrix_world @ v.co for v in obj.data.vertices)
        faces.extend(tuple(debut+i for i in p.vertices) for p in obj.data.polygons)
    OCCLUSION = BVHTree.FromPolygons(sommets, faces)


def occlusion(point, normale):
    normale = normale.normalized()
    tangent = normale.cross(Vector((.31,.73,.61))).normalized()
    second = normale.cross(tangent)
    cache = 0.0
    for i in range(8):
        angle = i * 2.399963
        rayon = math.sqrt((i+.5)/8)
        direction = normale*math.sqrt(1-rayon*rayon) + rayon*(tangent*math.cos(angle)+second*math.sin(angle))
        touche, _, _, distance = OCCLUSION.ray_cast(point+normale*.0025, direction, .11)
        if touche is not None: cache += 1.0 - .5*min(distance/.11,1)
    return 1.0 - .30*cache/8


def preparer():
    profil = profil_surfaces()
    mat = bpy.data.materials.new('MatieresPeintesBestiaire')
    mat.use_nodes = True
    noeuds, liens = mat.node_tree.nodes, mat.node_tree.links
    bsdf = noeuds.get('Principled BSDF')
    bsdf.inputs['Roughness'].default_value = 1.0
    bsdf.inputs['Metallic'].default_value = .0
    bsdf.inputs['Specular IOR Level'].default_value = profil['SPECULAIRE']
    couleur = noeuds.new('ShaderNodeVertexColor')
    couleur.layer_name = 'Teinte'
    image = noeuds.new('ShaderNodeTexImage')
    image.image = bpy.data.images.load(str(ATLAS), check_existing=True)
    image.interpolation = 'Linear'
    produit = noeuds.new('ShaderNodeMixRGB')
    produit.blend_type = 'MULTIPLY'
    produit.inputs[0].default_value = 1
    liens.new(couleur.outputs['Color'], produit.inputs[1])
    liens.new(image.outputs['Color'], produit.inputs[2])
    liens.new(produit.outputs[0], bsdf.inputs['Base Color'])
    # La meme carte technique donne les reflets dans Blender et dans Godot.
    taille = profil['CARTE_TAILLE']
    carte = bpy.data.images.new('ReponseSurfacesBestiaire', taille, taille)
    carte.colorspace_settings.name = 'Non-Color'
    pixels = []
    for y in range(taille):
        for x in range(taille):
            case = (0 if y >= taille//2 else 2) + (1 if x >= taille//2 else 0)
            metal, rugosite = profil['SURFACES'][case]
            pixels.extend((metal, rugosite, 0.0, 1.0))
    carte.pixels[:] = pixels
    carte.pack()
    texture = noeuds.new('ShaderNodeTexImage')
    texture.image = carte
    texture.interpolation = 'Linear'
    canaux = noeuds.new('ShaderNodeSeparateColor')
    liens.new(texture.outputs['Color'], canaux.inputs['Color'])
    liens.new(canaux.outputs['Red'], bsdf.inputs['Metallic'])
    liens.new(canaux.outputs['Green'], bsdf.inputs['Roughness'])
    return mat


def peindre(obj):
    nom = obj.data.materials[0].name.split('.')[0]
    rgb = Vector(obj.data.materials[0].diffuse_color[:3])
    tissu = obj.name.startswith(TISSUS)
    bpy.context.view_layer.update()
    points = [v.co for v in obj.data.vertices]
    mini = Vector(tuple(min(p[i] for p in points) for i in range(3)))
    maxi = Vector(tuple(max(p[i] for p in points) for i in range(3)))
    taille = maxi-mini
    role = .2 if nom in ('violet','cuir','pierre','pierre_claire') else .8 if nom in ('magie','cristal','feu','givre','venin') else 0
    teinte = obj.data.color_attributes.new(name='Teinte', type='FLOAT_COLOR', domain='CORNER')
    uv = obj.data.uv_layers.get('UVMap')
    origine_uv = [tuple(point.uv) for point in uv.data] if uv is not None else None
    uv = uv or obj.data.uv_layers.new(name='UVMap')
    uv.active_render = True
    roles = obj.data.uv_layers.new(name='RoleMatiere')
    normales = obj.matrix_world.to_3x3().inverted().transposed()
    ombres = [occlusion(obj.matrix_world @ sommet.co, normales @ sommet.normal)
              if nom not in ('magie','cristal','feu','venin','givre') else 1.0
              for sommet in obj.data.vertices]
    # Les quatre cases utilisent une marge pour les mipmaps du rendu mobile.
    tuile = (1,1) if tissu or nom == 'cuir' else (0,0) if nom == 'papier' else (1,0) if nom in ('cuivre','metal','bois') else (0,1)
    for face in obj.data.polygons:
        # Garder les UV continus des volumes et des tubes ; projeter seulement le reste.
        axe = max(range(3), key=lambda i:abs(face.normal[i]))
        u, v = [(1,2),(0,2),(0,1)][axe]
        for i in face.loop_indices:
            sommet = obj.data.vertices[obj.data.loops[i].vertex_index]
            p = sommet.co
            coords = [(p[k]-mini[k])/max(taille[k],.001) for k in range(3)]
            tex_u, tex_v = origine_uv[i] if origine_uv is not None else (coords[u], coords[v])
            uv.data[i].uv = ((tuile[0]+.035+.93*tex_u)*.5,
                             (tuile[1]+.035+.93*tex_v)*.5)
            n = (normales @ sommet.normal).normalized()
            hauteur = coords[2]
            grain = noise.noise_vector(p*13 + Vector((1.1,2.7,4.2)))[0]
            # Lavis sous les volumes, lumieres peintes sur les aretes et les sommets.
            valeur = .90 + hauteur*.12 + max(0,n.z)*.12 + grain*.022
            if tissu:
                angle = math.atan2(p.y,p.x)
                valeur *= .94 + .07*math.cos(angle*7+.6*p.z)
            elif nom in ('cuivre','metal'):
                valeur = .79 + .16*hauteur + .18*max(0,n.z) + grain*.035
            elif nom in ('magie','cristal','feu','givre','venin'):
                valeur = .82 + .24*hauteur
            valeur *= ombres[sommet.index]
            nuance = rgb * valeur
            # Un reflet colore tres discret garde les ombres lisibles sur l'encre.
            if nom == 'encre': nuance += Vector((.010,.012,.018))*max(0,n.z)
            teinte.data[i].color = (*(min(max(v,0.0),1.0) for v in nuance),1)
            roles.data[i].uv = (role,valeur)
