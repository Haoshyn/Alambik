"""Atlas peint partage, plis et modeles de couleur conserves dans les sources GLB."""
import math

import bpy
from mathutils import Vector, noise
from mathutils.bvhtree import BVHTree
import build_all as b

ATLAS = b.SORTIE / 'textures/bestiaire_matieres_peintes.png'
TISSUS = ('Manteau', 'Capuche', 'Manche', 'Pan_de_parchemin', 'Signet')
OCCLUSION = None


def sculpter(objets):
    global OCCLUSION
    for obj in objets:
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
                pli = math.cos(angle*7+.6*z)*.014 + math.sin(angle*3-z*4)*.006
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
    return 1.0 - .46*cache/8


def preparer():
    mat = bpy.data.materials.new('MatieresPeintesBestiaire')
    mat.use_nodes = True
    noeuds, liens = mat.node_tree.nodes, mat.node_tree.links
    bsdf = noeuds.get('Principled BSDF')
    bsdf.inputs['Roughness'].default_value = .84
    bsdf.inputs['Metallic'].default_value = .0
    bsdf.inputs['Specular IOR Level'].default_value = .22
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
    role = .2 if nom in ('violet','cuir','pierre','pierre_claire') else .8 if nom in ('magie','cristal') else 0
    teinte = obj.data.color_attributes.new(name='Teinte', type='FLOAT_COLOR', domain='CORNER')
    uv = obj.data.uv_layers.get('UVMap') or obj.data.uv_layers.new(name='UVMap')
    roles = obj.data.uv_layers.new(name='RoleMatiere')
    ombres = [occlusion(obj.matrix_world @ sommet.co, obj.matrix_world.to_3x3() @ sommet.normal)
              if nom not in ('magie','cristal','feu','venin','givre') else 1.0
              for sommet in obj.data.vertices]
    # Les quatre cases utilisent une marge pour les mipmaps du rendu mobile.
    tuile = (1,1) if tissu or nom == 'cuir' else (0,0) if nom == 'papier' else (1,0) if nom in ('cuivre','metal','bois') else (0,1)
    for face in obj.data.polygons:
        # Projection par face : les tubes construits a la main ont aussi des UV.
        axe = max(range(3), key=lambda i:abs(face.normal[i]))
        u, v = [(1,2),(0,2),(0,1)][axe]
        for i in face.loop_indices:
            sommet = obj.data.vertices[obj.data.loops[i].vertex_index]
            p = sommet.co
            coords = [(p[k]-mini[k])/max(taille[k],.001) for k in range(3)]
            uv.data[i].uv = ((tuile[0]+.035+.93*coords[u])*.5,
                             (tuile[1]+.035+.93*coords[v])*.5)
            n = obj.matrix_world.to_3x3() @ sommet.normal
            hauteur = coords[2]
            grain = noise.noise_vector(p*13 + Vector((1.1,2.7,4.2)))[0]
            # Lavis sous les volumes, lumieres peintes sur les aretes et les sommets.
            valeur = .78 + hauteur*.18 + max(0,n.z)*.18 + grain*.030
            if tissu:
                angle = math.atan2(p.y,p.x)
                valeur *= .88 + .13*math.cos(angle*7+.6*p.z)
            elif nom in ('cuivre','metal'):
                valeur = .60 + .29*hauteur + .30*max(0,n.z) + grain*.07
            elif nom in ('magie','cristal','feu','givre','venin'):
                valeur = .82 + .24*hauteur
            valeur *= ombres[sommet.index]
            nuance = rgb * valeur
            # Un reflet colore tres discret garde les ombres lisibles sur l'encre.
            if nom == 'encre': nuance += Vector((.010,.012,.018))*max(0,n.z)
            teinte.data[i].color = (*nuance,1)
            roles.data[i].uv = (role,valeur)
