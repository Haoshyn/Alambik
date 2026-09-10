"""Preparation et cuisson de l'etude Meshy du heros B, hors scene de combat."""
import bpy
import bmesh
import json
import math
import sys
from pathlib import Path
from mathutils import Matrix, Vector
from mathutils.bvhtree import BVHTree

RACINE = Path(__file__).resolve().parents[2]
SOURCE = RACINE / 'assets/3d/sources/characters/heros_b'
TEXTURES = RACINE / 'assets/3d/textures/heros_b'
APERCUS = RACINE / 'tmp/meshy-heros'
HAUTEUR = 1.8
TRIANGLES_CIBLES = 36000
TAILLE_TEXTURE = 2048
CADRE_VERTICAL = 2.10
CADRE_HORIZONTAL = CADRE_VERTICAL * 2 / 3
VUES = {'face': (0, -5, .90), 'dos': (0, 5, .90),
        'gauche': (-5, 0, .90), 'droite': (5, 0, .90)}


def activer(objet):
    bpy.ops.object.select_all(action='DESELECT')
    objet.select_set(True)
    bpy.context.view_layer.objects.active = objet


def compte(objet):
    objet.data.calc_loop_triangles()
    return len(objet.data.loop_triangles)


def verifier_maillage(objet):
    bm = bmesh.new()
    bm.from_mesh(objet.data)
    resultat = {'sommets': len(bm.verts), 'triangles': compte(objet),
                'aretes_ouvertes': sum(e.is_boundary for e in bm.edges),
                'aretes_non_manifold': sum(not e.is_manifold for e in bm.edges)}
    bm.free()
    return resultat


def materiau_argile():
    mat = bpy.data.materials.new('Argile_controle')
    mat.use_nodes = True
    bsdf = mat.node_tree.nodes.get('Principled BSDF')
    bsdf.inputs['Base Color'].default_value = (.47, .43, .38, 1)
    bsdf.inputs['Roughness'].default_value = .85
    return mat


def studio():
    scene = bpy.context.scene
    scene.render.engine = 'CYCLES'
    scene.cycles.samples = 24
    scene.render.resolution_x = 1024
    scene.render.resolution_y = 1536
    scene.render.resolution_percentage = 100
    scene.render.image_settings.file_format = 'PNG'
    scene.render.film_transparent = False
    scene.view_settings.view_transform = 'AgX'
    scene.world = bpy.data.worlds.new('Fond_studio')
    scene.world.use_nodes = True
    fond = scene.world.node_tree.nodes.get('Background')
    fond.inputs['Color'].default_value = (.8, .8, .8, 1)
    fond.inputs['Strength'].default_value = .65
    for nom, pos, energie, taille in [('Principale',(-3,-4,6),300,5),
            ('Remplissage',(4,2,4),250,5),('Arriere',(-3,4,3),200,4)]:
        data = bpy.data.lights.new(nom, 'AREA')
        data.energy = energie
        data.size = taille
        obj = bpy.data.objects.new(nom, data)
        scene.collection.objects.link(obj)
        obj.location = pos
        obj.rotation_euler = (Vector((0,0,.9))-obj.location).to_track_quat('-Z','Y').to_euler()
    data = bpy.data.cameras.new('Camera_controle')
    camera = bpy.data.objects.new('Camera_controle',data)
    scene.collection.objects.link(camera)
    scene.camera = camera
    data.type = 'ORTHO'
    data.ortho_scale = CADRE_VERTICAL
    return camera


def preparer():
    bpy.ops.wm.read_factory_settings(use_empty=True)
    bpy.context.preferences.filepaths.save_version = 0
    bpy.ops.import_scene.gltf(filepath=str(SOURCE/'meshy_original.glb'))
    objet = next(o for o in bpy.context.scene.objects if o.type=='MESH')
    objet.name = 'Heros_B_haute_definition'
    activer(objet)
    bpy.ops.object.transform_apply(location=True,rotation=True,scale=True)
    bas = Vector(tuple(min(v.co[i] for v in objet.data.vertices) for i in range(3)))
    haut = Vector(tuple(max(v.co[i] for v in objet.data.vertices) for i in range(3)))
    centre = Vector(((bas.x+haut.x)/2,(bas.y+haut.y)/2,bas.z))
    for v in objet.data.vertices:
        v.co = (v.co-centre)*HAUTEUR/(haut.z-bas.z)
    bm = bmesh.new()
    bm.from_mesh(objet.data)
    # Une tolerance minuscule preserve les details des doigts et des bordures.
    bmesh.ops.remove_doubles(bm,verts=list(bm.verts),dist=.000001)
    bmesh.ops.dissolve_degenerate(bm,edges=list(bm.edges),dist=.000001)
    bmesh.ops.recalc_face_normals(bm,faces=list(bm.faces))
    bm.to_mesh(objet.data)
    bm.free()
    objet.data.materials.clear()
    objet.data.materials.append(materiau_argile())
    for face in objet.data.polygons:
        face.use_smooth = True
    rapport = {'source':verifier_maillage(objet)}
    bas_poly = objet.copy()
    bas_poly.data = objet.data.copy()
    bpy.context.collection.objects.link(bas_poly)
    bas_poly.name = 'Heros_B_etude'
    activer(bas_poly)
    mod = bas_poly.modifiers.new('Reduction_silhouette','DECIMATE')
    mod.ratio = TRIANGLES_CIBLES/compte(bas_poly)
    mod.use_collapse_triangulate = True
    bpy.ops.object.modifier_apply(modifier=mod.name)
    rapport['allege'] = verifier_maillage(bas_poly)
    # La mesure dans les deux sens detecte aussi les details qui ont disparu.
    def ecart(a,b):
        bm = bmesh.new();bm.from_mesh(b.data)
        arbre = BVHTree.FromBMesh(bm)
        valeurs = [arbre.find_nearest(v.co)[3] for v in list(a.data.vertices)[::max(1,len(a.data.vertices)//5000)]]
        bm.free()
        return {'maximum':max(valeurs),'moyenne':sum(valeurs)/len(valeurs)}
    rapport['ecart_source_vers_allege'] = ecart(objet,bas_poly)
    rapport['ecart_allege_vers_source'] = ecart(bas_poly,objet)
    bpy.ops.object.mode_set(mode='EDIT')
    bpy.ops.mesh.select_all(action='SELECT')
    bpy.ops.uv.smart_project(angle_limit=math.radians(66),island_margin=.006)
    bpy.ops.object.mode_set(mode='OBJECT')
    objet.hide_render = True
    objet.hide_set(True)
    SOURCE.mkdir(parents=True,exist_ok=True)
    TEXTURES.mkdir(parents=True,exist_ok=True)
    APERCUS.mkdir(parents=True,exist_ok=True)
    (APERCUS/'.gdignore').touch()
    (SOURCE/'rapport.json').write_text(json.dumps(rapport,indent=2))
    bpy.ops.wm.save_as_mainfile(filepath=str(SOURCE/'preparation.blend'))
    camera = studio()
    for nom,position in VUES.items():
        camera.location = position
        camera.rotation_euler = (Vector((0,0,.9))-camera.location).to_track_quat('-Z','Y').to_euler()
        bpy.context.scene.render.filepath = str(APERCUS/(nom+'_argile.png'))
        bpy.ops.render.render(write_still=True)
    print('RAPPORT',json.dumps(rapport))


def deplier_etude(objet):
    # Une marge proportionnee a la texture evite de gaspiller l'atlas
    # autour des petits ilots des accessoires et des doigts.
    activer(objet)
    bpy.ops.object.mode_set(mode='EDIT')
    bpy.ops.mesh.select_all(action='SELECT')
    bpy.ops.uv.smart_project(angle_limit=math.radians(89),island_margin=.0008)
    bpy.ops.object.mode_set(mode='OBJECT')


def poids_projections(objet):
    bm = bmesh.new();bm.from_mesh(objet.data)
    arbre = BVHTree.FromBMesh(bm)
    directions = [Vector((0,-1,0)),Vector((0,1,0)),Vector((-1,0,0)),Vector((1,0,0))]
    couche = objet.data.color_attributes.new(name='Poids_projections',type='FLOAT_COLOR',domain='POINT')
    for sommet in objet.data.vertices:
        poids = []
        secours = []
        for direction in directions:
            incidence = max(.015,sommet.normal.dot(direction))**4
            secours.append(incidence)
            depart = sommet.co+sommet.normal*.0003+direction*.0001
            touche = arbre.ray_cast(depart,direction,5)[0]
            poids.append(incidence if touche is None else 0.)
        if sum(poids)<1e-8:
            poids = secours
        total = sum(poids)
        couche.data[sommet.index].color = [p/total for p in poids]
    bm.free()


def materiau_projection(objet):
    mat = bpy.data.materials.new('Projection_peinture')
    mat.use_nodes = True
    noeuds = mat.node_tree.nodes
    liens = mat.node_tree.links
    noeuds.clear()
    sortie = noeuds.new('ShaderNodeOutputMaterial')
    emission = noeuds.new('ShaderNodeEmission')
    liens.new(emission.outputs[0],sortie.inputs['Surface'])
    geometrie = noeuds.new('ShaderNodeNewGeometry')
    axes = noeuds.new('ShaderNodeSeparateXYZ')
    liens.new(geometrie.outputs['Position'],axes.inputs[0])
    attribut = noeuds.new('ShaderNodeVertexColor');attribut.layer_name='Poids_projections'
    separer = noeuds.new('ShaderNodeSeparateColor')
    liens.new(attribut.outputs['Color'],separer.inputs[0])
    facteurs = [separer.outputs['Red'],separer.outputs['Green'],separer.outputs['Blue'],attribut.outputs['Alpha']]
    total = None
    for i,(nom,axe,signe) in enumerate([('face','X',1),('dos','X',-1),('gauche','Y',-1),('droite','Y',1)]):
        u = noeuds.new('ShaderNodeMath');u.operation='MULTIPLY_ADD'
        liens.new(axes.outputs[axe],u.inputs[0]);u.inputs[1].default_value=signe/CADRE_HORIZONTAL;u.inputs[2].default_value=.5
        v = noeuds.new('ShaderNodeMath');v.operation='MULTIPLY_ADD'
        liens.new(axes.outputs['Z'],v.inputs[0]);v.inputs[1].default_value=1/CADRE_VERTICAL;v.inputs[2].default_value=.5-.9/CADRE_VERTICAL
        coord = noeuds.new('ShaderNodeCombineXYZ');liens.new(u.outputs[0],coord.inputs['X']);liens.new(v.outputs[0],coord.inputs['Y'])
        image = noeuds.new('ShaderNodeTexImage');image.image=bpy.data.images.load(str(SOURCE/'peintures'/(nom+'.png')))
        image.extension='EXTEND';liens.new(coord.outputs[0],image.inputs['Vector'])
        couleur = noeuds.new('ShaderNodeVectorMath');couleur.operation='SCALE'
        liens.new(image.outputs['Color'],couleur.inputs[0]);liens.new(facteurs[i],couleur.inputs[3])
        if total is None:
            total = couleur.outputs['Vector']
        else:
            addition = noeuds.new('ShaderNodeVectorMath');addition.operation='ADD'
            liens.new(total,addition.inputs[0]);liens.new(couleur.outputs['Vector'],addition.inputs[1]);total=addition.outputs['Vector']
    liens.new(total,emission.inputs['Color'])
    objet.data.materials.clear();objet.data.materials.append(mat)
    return mat


def image_cuisson(mat,nom,non_couleur=False):
    image = bpy.data.images.new(nom,width=TAILLE_TEXTURE,height=TAILLE_TEXTURE,alpha=False)
    if non_couleur:image.colorspace_settings.name='Non-Color'
    noeud = mat.node_tree.nodes.new('ShaderNodeTexImage');noeud.image=image
    mat.node_tree.nodes.active=noeud
    for n in mat.node_tree.nodes:n.select=False
    noeud.select=True
    return image


def sauver_texture(image,nom):
    image.filepath_raw=str(TEXTURES/nom);image.file_format='PNG';image.save()
    image.pack()


def cuire():
    bpy.ops.wm.open_mainfile(filepath=str(SOURCE/'preparation.blend'))
    scene=bpy.context.scene;scene.render.engine='CYCLES';scene.cycles.samples=16
    scene.render.bake.margin=12
    objet=bpy.data.objects['Heros_B_etude'];haute=bpy.data.objects['Heros_B_haute_definition']
    activer(objet)
    deplier_etude(objet)
    poids_projections(objet)
    mat=materiau_projection(objet)
    couleur=image_cuisson(mat,'Heros_B_couleur')
    bpy.ops.object.bake(type='EMIT',use_selected_to_active=False)
    sauver_texture(couleur,'heros_b_couleur.png')
    normales=image_cuisson(mat,'Heros_B_normales',True)
    haute.hide_set(False);haute.hide_render=False;haute.select_set(True)
    scene.render.bake.use_selected_to_active=True
    scene.render.bake.cage_extrusion=.002
    scene.render.bake.max_ray_distance=.008
    bpy.ops.object.bake(type='NORMAL')
    sauver_texture(normales,'heros_b_normales.png')
    haute.hide_set(True);haute.hide_render=True;haute.select_set(False)
    # Les projections sont cuites dans l'UV pour rester stables en animation.
    final=bpy.data.materials.new('Heros_B_peint');final.use_nodes=True
    noeuds=final.node_tree.nodes;liens=final.node_tree.links
    bsdf=noeuds.get('Principled BSDF');bsdf.inputs['Roughness'].default_value=.78
    bsdf.inputs['Specular IOR Level'].default_value=.2
    tex=noeuds.new('ShaderNodeTexImage');tex.image=couleur
    liens.new(tex.outputs['Color'],bsdf.inputs['Base Color'])
    tex_norm=noeuds.new('ShaderNodeTexImage');tex_norm.image=normales
    normal=noeuds.new('ShaderNodeNormalMap');normal.inputs['Strength'].default_value=.45;liens.new(tex_norm.outputs['Color'],normal.inputs['Color']);liens.new(normal.outputs['Normal'],bsdf.inputs['Normal'])
    objet.data.materials.clear();objet.data.materials.append(final)
    objet.data.color_attributes.remove(objet.data.color_attributes['Poids_projections'])
    activer(objet)
    bpy.context.preferences.filepaths.save_version=0
    bpy.ops.file.pack_all()
    for ecran in bpy.data.screens:
        for zone in ecran.areas:
            if zone.type=='VIEW_3D':
                zone.spaces.active.shading.type='MATERIAL'
                zone.spaces.active.region_3d.view_location=(0,0,.9)
                zone.spaces.active.region_3d.view_distance=3.3
    bpy.ops.wm.save_as_mainfile(filepath=str(SOURCE/'heros_b_texture.blend'))
    export=RACINE/'assets/3d/characters/heros_b_etude.glb'
    bpy.ops.export_scene.gltf(filepath=str(export),export_format='GLB',use_selection=True,export_animations=False,export_cameras=False,export_lights=False)
    rapport=json.loads((SOURCE/'rapport.json').read_text())
    rapport['export']={'fichier':str(export.relative_to(RACINE)),'octets':export.stat().st_size,'textures':TAILLE_TEXTURE,'animations':0}
    (SOURCE/'rapport.json').write_text(json.dumps(rapport,indent=2))
    camera=studio()
    for nom,pos in [('trois_quarts',(2.7,-5,2.6)),('face',(0,-5,.9)),('dos',(0,5,.9)),('jeu',(0,-5,.9+5*math.tan(math.radians(48))))]:
        camera.location=pos;camera.rotation_euler=(Vector((0,0,.9))-camera.location).to_track_quat('-Z','Y').to_euler()
        scene.render.filepath=str(APERCUS/(nom+'_texture.png'))
        bpy.ops.render.render(write_still=True)


if __name__ == '__main__':
    commande=sys.argv[sys.argv.index('--')+1] if '--' in sys.argv else 'preparer'
    if commande=='preparer':preparer()
    elif commande=='cuire':cuire()
    else:raise ValueError('Commande attendue : preparer ou cuire')
