"""Vues de controle des GLB produits par verifier_decors.tscn -- --exporter=...

Blender --background --python tools/blender/apercu_decors.py -- DOSSIER [MONDE] [--rapproche]
--etages compare trois salles d'Encre ; --planche compare les cinq mondes.
--etages --rapproche cadre la matiere du bas des trois salles a la meme echelle.
--formes compare une galerie etroite, une salle longue et deux parois creusees.
--flaques cadre de pres les nappes d'Encre, Terre, Eau et Feu avec le heros.
La geometrie vient du jeu. L'eclairage Blender ne remplace pas un essai Godot.
"""
import math
import sys
from pathlib import Path

import bpy
from mathutils import Vector


def construire_vue(fichier, ecrire=True, rapproche=False, flaque=False):
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
    # Le glTF ne transmet pas SHADOW_CASTING_SETTING_OFF : conserver ce choix du jeu.
    for obj in sol.children_recursive:
        if obj.type == 'MESH':
            obj.visible_shadow = False
    points = [obj.matrix_world @ Vector(coin)
              for obj in sol.children_recursive if obj.type == 'MESH'
              for coin in obj.bound_box]
    mini = Vector(tuple(min(p[axe] for p in points) for axe in range(3)))
    maxi = Vector(tuple(max(p[axe] for p in points) for axe in range(3)))
    centre = (mini + maxi) * .5
    centre.y += .8
    if rapproche:
        centre.y -= 5
        scene.render.resolution_x = 768
        scene.render.resolution_y = 1080
    if flaque:
        nappe = next(obj for obj in scene.objects if obj.name.startswith('SurfaceNappe'))
        points = [nappe.matrix_world @ Vector(coin) for coin in nappe.bound_box]
        centre = Vector(((min(p.x for p in points) + max(p.x for p in points)) * .5,
                         (min(p.y for p in points) + max(p.y for p in points)) * .5, .25))
        heros = next(obj for obj in scene.objects if obj.name == 'mage_sculpte')
        sens = 1 if centre.x < (mini.x + maxi.x) * .5 else -1
        cible_heros = Vector((centre.x + sens * 2.3, centre.y - 2.8, 0))
        heros.location = heros.parent.matrix_world.inverted() @ cible_heros if heros.parent else cible_heros
        scene.render.resolution_x = 768
        scene.render.resolution_y = 1080
    camera = bpy.data.cameras.new('Camera')
    camera.type = 'ORTHO'
    camera.ortho_scale = 9.0 if flaque else 20.5 if rapproche else 30.5
    objet = bpy.data.objects.new('Camera', camera)
    scene.collection.objects.link(objet)
    angle = math.radians(48)
    objet.location = centre + Vector((0, -math.cos(angle) * 40, math.sin(angle) * 40))
    objet.rotation_euler = (centre - objet.location).to_track_quat('-Z', 'Y').to_euler()
    scene.camera = objet
    nom = fichier.stem + ('_flaque' if flaque else '_rapproche' if rapproche else '') + '.png'
    scene.render.filepath = str(fichier.with_name(nom))
    if ecrire:
        bpy.ops.render.render(write_still=True)


def construire_planche(dossier, etages=False, formes=False, rapproche=False):
    # Reutiliser les lumieres de la derniere vue, avec les geometries
    # cote a cote. La planche est un rendu 3D, pas une capture de gameplay.
    scene = bpy.context.scene
    for obj in list(scene.objects):
        if obj.type not in {'CAMERA', 'LIGHT'}:
            bpy.data.objects.remove(obj, do_unlink=True)
    noms = ['ENCRE', 'TERRE', 'EAU', 'AIR', 'FEU']
    fichiers = [dossier / f'monde_{monde}.glb' for monde in range(5)]
    sortie = 'cinq_mondes.png'
    if formes:
        noms = ['GALERIE ÉTROITE', 'SALLE ALLONGÉE', 'ALCÔVES ARRONDIES', 'RENFONCEMENT']
        fichiers = [dossier / f'encre_etage_{etage}.glb' for etage in [5, 9, 7, 2]]
        sortie = 'formes_salles.png'
    elif etages:
        noms = ['ENCRE - ETAGE 2', 'ENCRE - ETAGE 8', 'ENCRE - ETAGE 14']
        fichiers = [dossier / 'encre_etage_2.glb', dossier / 'monde_0.glb', dossier / 'encre_etage_14.glb']
        sortie = 'trois_etages_encre.png'
    ecart = 16 if rapproche else 19
    if rapproche:
        sortie = Path(sortie).stem + '_rapproche.png'
    texte_mat = bpy.data.materials.new('Legendes')
    texte_mat.diffuse_color = (.87, .89, .96, 1)
    texte_mat.use_nodes = True
    bsdf = texte_mat.node_tree.nodes.get('Principled BSDF')
    bsdf.inputs['Base Color'].default_value = texte_mat.diffuse_color
    bsdf.inputs['Emission Color'].default_value = texte_mat.diffuse_color
    bsdf.inputs['Emission Strength'].default_value = .4
    bas_salles = 0
    legendes = []
    for monde, nom in enumerate(noms):
        avant = set(scene.objects)
        bpy.ops.import_scene.gltf(filepath=str(fichiers[monde]))
        objets = set(scene.objects) - avant
        sol = next(obj for obj in objets if obj.name.startswith('SolJouable'))
        for obj in sol.children_recursive:
            if obj.type == 'MESH':
                obj.visible_shadow = False
        points = [obj.matrix_world @ Vector(coin)
                  for obj in sol.children_recursive if obj.type == 'MESH'
                  for coin in obj.bound_box]
        cx = (min(p.x for p in points) + max(p.x for p in points)) * .5
        cy = (min(p.y for p in points) + max(p.y for p in points)) * .5
        if rapproche:
            cy = min(p.y for p in points) + 8.5
        bas_salles = min(bas_salles, min(p.y for p in points) - cy)
        for obj in objets:
            if obj.type == 'MESH' and obj.dimensions.x > 30:
                obj.hide_render = True
            if obj.parent not in objets:
                obj.location += Vector((monde * ecart - cx, -cy, 0))
        texte = bpy.data.curves.new(nom, 'FONT')
        texte.body = nom
        texte.align_x = 'CENTER'
        texte.size = .8
        objet = bpy.data.objects.new(nom, texte)
        scene.collection.objects.link(objet)
        objet.location = (monde * ecart, -12.3 if rapproche else -21.0 if formes else -17.2, 0)
        objet.rotation_euler = (math.radians(48), 0, 0)
        objet.visible_shadow = False
        objet.data.materials.append(texte_mat)
        legendes.append(objet)
    if not rapproche:
        # Les salles longues ne doivent pas recouvrir leur legende.
        for legende in legendes:
            legende.location.y = bas_salles - 2.2
    milieu = (len(noms) - 1) * ecart * .5
    bpy.ops.mesh.primitive_plane_add(size=2, location=(milieu, 0, -1.12))
    fond = bpy.context.object
    fond.scale = (70, 40, 1)
    mat = bpy.data.materials.new('FondPlanche')
    mat.diffuse_color = (.075, .09, .13, 1)
    mat.use_nodes = True
    mat.node_tree.nodes.get('Principled BSDF').inputs['Base Color'].default_value = mat.diffuse_color
    mat.node_tree.nodes.get('Principled BSDF').inputs['Roughness'].default_value = .95
    fond.data.materials.append(mat)
    cible = Vector((milieu, -1.5 if rapproche else 0, 0))
    angle = math.radians(48)
    scene.camera.location = cible + Vector((0, -math.cos(angle) * 60, math.sin(angle) * 60))
    scene.camera.rotation_euler = (cible - scene.camera.location).to_track_quat('-Z', 'Y').to_euler()
    scene.camera.data.ortho_scale = len(noms) * ecart + (1 if rapproche else 4)
    scene.render.resolution_x = (768 if rapproche else 400) * len(noms)
    scene.render.resolution_y = 1080 if rapproche else 760
    scene.render.filepath = str(dossier / sortie)
    bpy.ops.render.render(write_still=True)


arguments = sys.argv[sys.argv.index('--') + 1:]
dossier = Path(arguments[0]).resolve()
if '--planche' in arguments or '--etages' in arguments or '--formes' in arguments:
    construire_vue(dossier / 'monde_0.glb', ecrire=False)
    construire_planche(dossier, etages='--etages' in arguments, formes='--formes' in arguments,
                      rapproche='--rapproche' in arguments)
else:
    choisis = [int(argument) for argument in arguments[1:] if argument.isdigit()]
    mondes = choisis if choisis else [0, 1, 2, 4] if '--flaques' in arguments else range(5)
    for monde in mondes:
        construire_vue(dossier / f'monde_{monde}.glb', rapproche='--rapproche' in arguments, flaque='--flaques' in arguments)
    if not choisis and '--rapproche' not in arguments and '--flaques' not in arguments:
        construire_planche(dossier)
