"""Rendu de la baguette effectivement portee, avant fusion des maillages du heros."""
import importlib.util
from pathlib import Path
import bpy
from mathutils import Vector

RACINE = Path(__file__).resolve().parents[2]
spec = importlib.util.spec_from_file_location('apprenti', Path(__file__).with_name('apprenti_accueil_v2.py'))
apprenti = importlib.util.module_from_spec(spec)
spec.loader.exec_module(apprenti)
bpy.ops.wm.read_factory_settings(use_empty=True)
apprenti.sculpter()
baguette = [o for o in bpy.context.scene.objects if o.type == 'MESH' and o.get('prise', False)]
assert baguette, 'La baguette du personnage doit etre presente.'
points = [o.matrix_world @ v.co for o in baguette for v in o.data.vertices]
minimum = Vector(tuple(min(p[i] for p in points) for i in range(3)))
maximum = Vector(tuple(max(p[i] for p in points) for i in range(3)))
centre = (minimum + maximum) / 2
rotation = Vector((0, -1, 0)).rotation_difference(Vector((0.50, 0, 0.866)).normalized())
for objet in list(bpy.context.scene.objects):
    if objet not in baguette:
        bpy.data.objects.remove(objet, do_unlink=True)
        continue
    matrice = objet.matrix_world.copy()
    objet.parent = None
    objet.modifiers.clear()
    objet.matrix_world.identity()
    for sommet in objet.data.vertices:
        sommet.co = rotation @ (matrice @ sommet.co - centre)
scene = bpy.context.scene
scene.render.engine = 'CYCLES'
scene.cycles.samples = 32
scene.render.resolution_x = 512
scene.render.resolution_y = 512
scene.render.resolution_percentage = 100
scene.render.film_transparent = True
scene.world = bpy.data.worlds.new('Studio')
scene.world.use_nodes = True
scene.world.node_tree.nodes['Background'].inputs[0].default_value = (0.75, 0.75, 0.85, 1)
scene.world.node_tree.nodes['Background'].inputs[1].default_value = 0.5
bpy.ops.object.camera_add(location=(0, -2, 0.05))
camera = bpy.context.object
camera.rotation_euler = (-camera.location).to_track_quat('-Z', 'Y').to_euler()
camera.data.type = 'ORTHO'
camera.data.ortho_scale = 0.60
scene.camera = camera
for position, puissance, taille in [((-1, -1, 2), 65, 2), ((1, 0, 1), 45, 1)]:
    bpy.ops.object.light_add(type='AREA', location=position)
    lampe = bpy.context.object
    lampe.data.energy = puissance
    lampe.data.shape = 'DISK'
    lampe.data.size = taille
    lampe.rotation_euler = (-lampe.location).to_track_quat('-Z', 'Y').to_euler()
scene.view_settings.view_transform = 'Standard'
scene.render.image_settings.file_format = 'PNG'
scene.render.image_settings.color_mode = 'RGBA'
scene.render.filepath = str(RACINE / 'assets/visual/manga/baguette_atelier.png')
bpy.ops.render.render(write_still=True)
