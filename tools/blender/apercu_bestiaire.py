"""Planches des poses exportees par Godot, rendues hors ecran dans Blender.

blender --background --python tools/blender/apercu_bestiaire.py -- DOSSIER [PLANCHE]
L'eclairage de controle ne remplace pas une capture du moteur sur appareil.
"""
import json
import math
import sys
from pathlib import Path

import bpy
from mathutils import Vector


def matiere(nom, rgb):
    mat = bpy.data.materials.new(nom)
    mat.diffuse_color = (*rgb, 1)
    mat.use_nodes = True
    bsdf = mat.node_tree.nodes.get('Principled BSDF')
    bsdf.inputs['Base Color'].default_value = (*rgb,1)
    bsdf.inputs['Roughness'].default_value = .82
    return mat


def construire_vue(dossier, categorie, legendes, animer=False):
    bpy.ops.wm.read_factory_settings(use_empty=True)
    bpy.ops.import_scene.gltf(filepath=str(dossier / (categorie + '.glb')))
    scene = bpy.context.scene
    scene.render.engine = 'BLENDER_EEVEE' if animer else 'CYCLES'
    scene.cycles.samples = 12 if animer else 24
    scene.cycles.use_denoising = True
    scene.cycles.max_bounces = 3
    scene.render.resolution_x = 1200 if animer else 1600
    scene.render.resolution_y = 640 if animer else 1100 if categorie != 'projectiles' else 1450
    scene.render.resolution_percentage = 100
    scene.render.image_settings.file_format = 'PNG'
    scene.view_settings.view_transform = 'Standard'
    scene.view_settings.look = 'None'
    scene.world = bpy.data.worlds.new('Ambiance')
    scene.world.use_nodes = True
    fond = scene.world.node_tree.nodes.get('Background')
    fond.inputs['Color'].default_value = (.36, .42, .58, 1)
    fond.inputs['Strength'].default_value = .5
    lumiere = bpy.data.lights.new('Soleil', 'SUN')
    lumiere.energy = 2.0
    lumiere.angle = .15
    soleil = bpy.data.objects.new('Soleil', lumiere)
    scene.collection.objects.link(soleil)
    soleil.rotation_euler = (math.radians(28), math.radians(-22), math.radians(-32))
    points = [obj.matrix_world @ Vector(coin) for obj in scene.objects if obj.type == 'MESH' for coin in obj.bound_box]
    mini = Vector(tuple(min(p[axe] for p in points) for axe in range(3)))
    maxi = Vector(tuple(max(p[axe] for p in points) for axe in range(3)))
    centre = (mini + maxi) * .5
    centre.z = 0
    blanc = matiere('Legende', (.67,.74,.88))
    for legende in legendes:
        texte = bpy.data.curves.new('Nom', 'FONT')
        texte.body = legende['nom']
        texte.align_x = 'CENTER'
        texte.size = .105 if categorie != 'projectiles' else .16
        texte.extrude = 0
        objet = bpy.data.objects.new('Legende', texte)
        scene.collection.objects.link(objet)
        objet.location = (legende['point'][0], -legende['point'][1]-(1.95 if animer else 1.32 if categorie == 'projectiles' else .70), .018)
        objet.data.materials.append(blanc)
    bpy.ops.mesh.primitive_plane_add(size=200, location=(centre.x,centre.y,-.035))
    bpy.context.object.data.materials.append(matiere('Fond',(.045,.061,.102)))
    camera = bpy.data.cameras.new('Camera')
    camera.type = 'ORTHO'
    rapport = scene.render.resolution_x/scene.render.resolution_y
    largeur = maxi.x-mini.x+1.1
    hauteur = (maxi.y-mini.y)*math.sin(math.radians(48))+(maxi.z-mini.z)*math.cos(math.radians(48))+(2.15 if animer else 1.6)
    camera.ortho_scale = max(largeur, hauteur*rapport)
    objet = bpy.data.objects.new('Camera',camera)
    scene.collection.objects.link(objet)
    angle = math.radians(48)
    centre.y -= .65 if animer else .10
    objet.location = centre+Vector((0,-math.cos(angle)*40,math.sin(angle)*40))
    objet.rotation_euler = (centre-objet.location).to_track_quat('-Z','Y').to_euler()
    scene.camera = objet
    if animer: return scene
    scene.render.filepath = str(dossier/(categorie+'.png'))
    bpy.ops.render.render(write_still=True)
    print('APERCU_OK', categorie, flush=True)


if __name__ == '__main__':
    arguments = sys.argv[sys.argv.index('--')+1:]
    dossier = Path(arguments[0]).resolve()
    legendes = json.loads((dossier/'legendes.json').read_text(encoding='utf-8'))
    for categorie in ([arguments[1]] if len(arguments) > 1 else legendes):
        construire_vue(dossier,categorie,legendes[categorie])
