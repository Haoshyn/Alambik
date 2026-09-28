"""Vues de controle des GLB produits par verifier_decors.tscn -- --exporter=...

Blender --background --python tools/blender/apercu_decors.py -- DOSSIER [MONDE]
La geometrie vient du jeu. L'eclairage Blender ne remplace pas un essai Godot.
"""
import math
import sys
from pathlib import Path

import bpy
from mathutils import Vector


def construire_vue(fichier, ecrire=True):
    bpy.ops.wm.read_factory_settings(use_empty=True)
    bpy.ops.import_scene.gltf(filepath=str(fichier))
    scene = bpy.context.scene
    scene.render.engine = 'CYCLES'
    scene.cycles.samples = 20
    scene.cycles.use_denoising = True
    scene.cycles.max_bounces = 3
    scene.render.resolution_x = 640
    scene.render.resolution_y = 1000
    scene.render.resolution_percentage = 100
    scene.render.image_settings.file_format = 'PNG'
    scene.view_settings.view_transform = 'Standard'
    scene.view_settings.look = 'None'
    scene.view_settings.exposure = 0
    scene.world = bpy.data.worlds.new('Ambiance')
    scene.world.use_nodes = True
    fond = scene.world.node_tree.nodes.get('Background')
    fond.inputs['Color'].default_value = (.49, .55, .68, 1)
    fond.inputs['Strength'].default_value = .55
    lumiere = bpy.data.lights.new('Soleil', 'SUN')
    lumiere.energy = 2.0
    lumiere.angle = .10
    soleil = bpy.data.objects.new('Soleil', lumiere)
    scene.collection.objects.link(soleil)
    soleil.rotation_euler = (math.radians(28), math.radians(-22), math.radians(-32))
    # Les maillages du sol donnent le cadrage, sans inclure le grand fond.
    sol = next(obj for obj in scene.objects if obj.name == 'SolJouable')
    points = [obj.matrix_world @ Vector(coin)
              for obj in sol.children_recursive if obj.type == 'MESH'
              for coin in obj.bound_box]
    mini = Vector(tuple(min(p[axe] for p in points) for axe in range(3)))
    maxi = Vector(tuple(max(p[axe] for p in points) for axe in range(3)))
    centre = (mini + maxi) * .5
    centre.y += .8
    camera = bpy.data.cameras.new('Camera')
    camera.type = 'ORTHO'
    camera.ortho_scale = 30.5
    objet = bpy.data.objects.new('Camera', camera)
    scene.collection.objects.link(objet)
    angle = math.radians(48)
    objet.location = centre + Vector((0, -math.cos(angle) * 40, math.sin(angle) * 40))
    objet.rotation_euler = (centre - objet.location).to_track_quat('-Z', 'Y').to_euler()
    scene.camera = objet
    scene.render.filepath = str(fichier.with_suffix('.png'))
    if ecrire:
        bpy.ops.render.render(write_still=True)


def construire_planche(dossier):
    # Reutiliser les lumieres de la derniere vue, avec les cinq geometries
    # cote a cote. La planche est un rendu 3D, pas une capture de gameplay.
    scene = bpy.context.scene
    for obj in list(scene.objects):
        if obj.type not in {'CAMERA', 'LIGHT'}:
            bpy.data.objects.remove(obj, do_unlink=True)
    noms = ['ENCRE', 'TERRE', 'EAU', 'AIR', 'FEU']
    texte_mat = bpy.data.materials.new('Legendes')
    texte_mat.diffuse_color = (.87, .89, .96, 1)
    texte_mat.use_nodes = True
    bsdf = texte_mat.node_tree.nodes.get('Principled BSDF')
    bsdf.inputs['Base Color'].default_value = texte_mat.diffuse_color
    bsdf.inputs['Emission Color'].default_value = texte_mat.diffuse_color
    bsdf.inputs['Emission Strength'].default_value = .4
    for monde, nom in enumerate(noms):
        avant = set(scene.objects)
        bpy.ops.import_scene.gltf(filepath=str(dossier / f'monde_{monde}.glb'))
        objets = set(scene.objects) - avant
        sol = next(obj for obj in objets if obj.name.startswith('SolJouable'))
        points = [obj.matrix_world @ Vector(coin)
                  for obj in sol.children_recursive if obj.type == 'MESH'
                  for coin in obj.bound_box]
        cx = (min(p.x for p in points) + max(p.x for p in points)) * .5
        cy = (min(p.y for p in points) + max(p.y for p in points)) * .5
        for obj in objets:
            if obj.type == 'MESH' and obj.dimensions.x > 30:
                obj.hide_render = True
            if obj.parent not in objets:
                obj.location += Vector((monde * 19 - cx, -cy, 0))
        texte = bpy.data.curves.new(nom, 'FONT')
        texte.body = nom
        texte.align_x = 'CENTER'
        texte.size = .8
        objet = bpy.data.objects.new(nom, texte)
        scene.collection.objects.link(objet)
        objet.location = (monde * 19, -17.2, 0)
        objet.rotation_euler = (math.radians(48), 0, 0)
        objet.visible_shadow = False
        objet.data.materials.append(texte_mat)
    bpy.ops.mesh.primitive_plane_add(size=2, location=(38, 0, -1.12))
    fond = bpy.context.object
    fond.scale = (70, 40, 1)
    mat = bpy.data.materials.new('FondPlanche')
    mat.diffuse_color = (.075, .09, .13, 1)
    mat.use_nodes = True
    mat.node_tree.nodes.get('Principled BSDF').inputs['Base Color'].default_value = mat.diffuse_color
    mat.node_tree.nodes.get('Principled BSDF').inputs['Roughness'].default_value = .95
    fond.data.materials.append(mat)
    cible = Vector((38, 0, 0))
    angle = math.radians(48)
    scene.camera.location = cible + Vector((0, -math.cos(angle) * 60, math.sin(angle) * 60))
    scene.camera.rotation_euler = (cible - scene.camera.location).to_track_quat('-Z', 'Y').to_euler()
    scene.camera.data.ortho_scale = 99
    scene.render.resolution_x = 2000
    scene.render.resolution_y = 760
    scene.render.filepath = str(dossier / 'cinq_mondes.png')
    bpy.ops.render.render(write_still=True)


arguments = sys.argv[sys.argv.index('--') + 1:]
dossier = Path(arguments[0]).resolve()
if len(arguments) > 1 and arguments[1] == '--planche':
    construire_vue(dossier / 'monde_0.glb', ecrire=False)
    construire_planche(dossier)
else:
    mondes = [int(arguments[1])] if len(arguments) > 1 else range(5)
    for monde in mondes:
        construire_vue(dossier / f'monde_{monde}.glb')
    if len(arguments) == 1:
        construire_planche(dossier)
