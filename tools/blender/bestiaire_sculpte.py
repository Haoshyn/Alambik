"""Regenerer uniquement les ennemis : blender --background --python .../bestiaire_sculpte.py.

Sources originales, pieces rigides articulees par animation_membres_ennemis.gd.
Les sources .blend et les chemins GLB du jeu sont conserves.
"""
import json
import sys
import time
from pathlib import Path

import bpy

sys.path.insert(0, str(Path(__file__).resolve().parent))
import build_all as b
import sculpture_bestiaire as s
import creatures_bestiaire as c
import souverains_bestiaire as rois


def exporter(nom, dossier, construire):
    bpy.ops.wm.read_factory_settings(use_empty=True)
    bpy.context.preferences.filepaths.save_version = 0
    bpy.context.preferences.filepaths.file_preview_type = 'NONE'
    b.MAT.clear()
    s.palette()
    b.ACTEUR = bpy.data.objects.new('BestiaireSculpte', None)
    bpy.context.collection.objects.link(b.ACTEUR)
    construire()
    s.regrouper()
    meshes = [o for o in bpy.context.scene.objects if o.type == 'MESH']
    triangles = sum(sum(len(p.vertices)-2 for p in o.data.polygons) for o in meshes)
    source = b.SORTIE / 'sources' / dossier / (nom + '.blend')
    sortie = b.SORTIE / dossier / (nom + '.glb')
    bpy.context.scene.render.fps = 24
    for image in bpy.data.images:
        if image.filepath.endswith('bestiaire_matieres_peintes.png'):
            image.filepath = '//../../textures/bestiaire_matieres_peintes.png'
    bpy.ops.wm.save_as_mainfile(filepath=str(source))
    # Le jeu reutilise un seul atlas externe, au lieu de l'embarquer 31 fois.
    for mat in bpy.data.materials:
        if mat.name == 'MatieresPeintesBestiaire':
            noeuds = mat.node_tree.nodes
            couleur = next(n for n in noeuds if n.bl_idname == 'ShaderNodeVertexColor')
            mat.node_tree.links.new(couleur.outputs['Color'],
                                    noeuds.get('Principled BSDF').inputs['Base Color'])
    temporaire = b.RACINE / 'tmp/verification_matieres' / (nom + '.glb')
    temporaire.parent.mkdir(parents=True, exist_ok=True)
    bpy.ops.export_scene.gltf(filepath=str(temporaire), export_format='GLB', export_yup=True,
                              export_animations=False, export_materials='EXPORT',
                              export_cameras=False, export_lights=False)
    # Remplacement atomique : l'editeur ne doit pas importer un GLB incomplet.
    for essai in range(20):
        try:
            temporaire.replace(sortie)
            break
        except OSError:
            if essai == 19: raise
            time.sleep(.2)
    resultat = {'nom': nom, 'glb': sortie.relative_to(b.RACINE).as_posix(),
                'animations': [], 'animation_procedurale': True, 'triangles': triangles, 'surfaces': len(meshes),
                'octets': sortie.stat().st_size}
    print('BESTIAIRE', json.dumps(resultat), flush=True)
    return resultat


def main():
    rapport = []
    for nom in c.NOMS:
        rapport.append(exporter(nom, 'enemies', lambda n=nom:c.construire(n)))
    for i in range(10):
        rapport.append(exporter('miniboss_'+str(i), 'bosses', lambda n=i:rois.miniature(n)))
        rapport.append(exporter('boss_'+str(i), 'bosses', lambda n=i:rois.signature(n)))
    dossier = b.RACINE / 'tmp/verification_monstres'
    dossier.mkdir(parents=True, exist_ok=True)
    (dossier / 'geometrie.json').write_text(json.dumps(rapport,indent=2),encoding='utf-8')
    print('BESTIAIRE_OK', len(rapport), flush=True)
    return rapport


if __name__ == '__main__':
    main()
