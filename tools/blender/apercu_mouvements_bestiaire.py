"""Rendre les poses Godot : blender --background --python CE_FICHIER -- DOSSIER [IMAGE]."""
import json
import sys
from pathlib import Path

import bpy
from mathutils import Quaternion

sys.path.insert(0, str(Path(__file__).resolve().parent))
from apercu_bestiaire import construire_vue

arguments = sys.argv[sys.argv.index('--')+1:]
dossier = Path(arguments[0]).resolve()
donnees = json.loads((dossier/'poses.json').read_text(encoding='utf-8'))
scene = construire_vue(dossier, 'mouvements', donnees['legendes'], animer=True)
scene.render.fps = donnees['fps']
sortie = dossier/'images'
sortie.mkdir(exist_ok=True)
images = [int(arguments[1])] if len(arguments) > 1 else range(len(donnees['images']))
for frame in images:
    for index, pose in enumerate(donnees['images'][frame]):
        obj = bpy.data.objects.get('Pose_%03d' % index)
        if obj is None: raise RuntimeError('Noeud exporte introuvable : %d' % index)
        # Conversion exacte de Godot (Y haut) vers Blender (Z haut).
        obj.location = (pose[0], -pose[2], pose[1])
        obj.rotation_mode = 'QUATERNION'
        obj.rotation_quaternion = Quaternion((pose[6],pose[3],-pose[5],pose[4]))
        obj.scale = (pose[7],pose[9],pose[8])
    scene.render.filepath = str(sortie/('%03d.png' % frame))
    bpy.ops.render.render(write_still=True)
    print('POSE_RENDUE', frame, flush=True)
