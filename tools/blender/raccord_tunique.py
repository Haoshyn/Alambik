"""Maintient le bas de tunique dans la ceinture pendant la course."""
import sys
from pathlib import Path

import bpy

sys.path.insert(0,str(Path(__file__).resolve().parent))
from variantes_mage import lire_glb,ecrire_glb


def rampe(a,b,x):
    t=max(0.,min(1.,(x-a)/(b-a)))
    return t*t*(3-2*t)


def finaliser(chemin):
    doc,_=lire_glb(chemin)
    if doc.get('extras',{}).get('raccord_taille_revision')==1:return
    marqueurs=dict(doc.get('extras',{}))
    bpy.ops.wm.read_factory_settings(use_empty=True)
    bpy.ops.import_scene.gltf(filepath=str(chemin))
    objet=bpy.data.objects['Mage_sculpte']
    rig=next(o for o in bpy.context.scene.objects if o.type=='ARMATURE')
    tissu={v for f in objet.data.polygons
        if objet.data.materials[f.material_index].name.startswith('Tunique_violet_uni')
        for v in f.vertices}
    for v in objet.data.vertices:
        x,y,z=v.co
        if not .59<z<.90:continue
        if v.index in tissu and z>.60:
            # Le haut reconstruit etait moins profond que la ceinture du scan.
            # Retablir leur recouvrement avant de leur donner le meme ancrage.
            v.co.y-=.060*(1-rampe(.70,.84,z))*rampe(.06,-.20,y)
            v.co.z-=.025*(1-rampe(.66,.72,z))
        # La ceinture et le bas de tunique suivent ensemble le bassin ; le
        # buste retrouve progressivement sa liberte au-dessus de la taille.
        anciens={objet.vertex_groups[g.group].name:g.weight for g in v.groups}
        if sum(w for n,w in anciens.items() if n not in ('bassin','torse'))>.02:continue
        haut=rampe(.72,.90,z)
        for groupe in objet.vertex_groups:groupe.remove([v.index])
        objet.vertex_groups['bassin'].add([v.index],1-haut,'REPLACE')
        objet.vertex_groups['torse'].add([v.index],haut,'REPLACE')
    objet.data.update()
    bpy.ops.object.select_all(action='DESELECT');objet.select_set(True);rig.select_set(True)
    bpy.context.view_layer.objects.active=rig
    bpy.ops.export_scene.gltf(filepath=str(chemin),export_format='GLB',use_selection=True,
        export_animations=True,export_animation_mode='NLA_TRACKS',export_force_sampling=True,export_skins=True)
    doc,brut=lire_glb(chemin)
    doc.setdefault('extras',{}).update(marqueurs)
    doc['extras']['raccord_taille_revision']=1
    ecrire_glb(chemin,doc,brut)
