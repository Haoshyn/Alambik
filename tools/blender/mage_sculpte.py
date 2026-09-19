"""Reprise de la geometrie sculptee, dans des fichiers entierement separes."""
import math
import sys
from pathlib import Path

import bpy
from mathutils import Vector

sys.path.insert(0,str(Path(__file__).resolve().parent))
import variantes_mage as base
import texturer_mage_reference as projection
from texturer_mage_reference import texturer, ajuster_proportions, position_corrigee
from animer_heros_meshy import rampe
from animer_mage_v2 import animer

RACINE=Path(__file__).resolve().parents[2]
SOURCE=RACINE/'assets/3d/sources/characters/mage_sculpte'
TRAVAIL=RACINE/'tmp/mage-sculpte'


def texturer_copie(objet,reference,sortie):
    ancien_masque=projection.surface_chapeau
    # Le bord est incline : un seuil symetrique peignait les meches de droite en violet.
    def chapeau(x,y,z,normale=None):
        if z>1.52+.30*x-.12*y:
            return True
        exterieur=(x/.46)**2+(y/.49)**2>1.
        bord=exterieur and z>1.18+.24*x-.23*y
        arriere=y>.28 and z>1.32+.20*x-.36*y
        return bord or arriere
    projection.surface_chapeau=chapeau
    try:
        texturer(objet,reference,TRAVAIL/'projection.png',marge_uv=.0015,marge_cuisson=8,corriger_cheveux=True)
    finally:
        projection.surface_chapeau=ancien_masque


def proportions(objet,rig):
    # Les mains doivent rester lisibles une fois les bras abaisses.
    for v in objet.data.vertices:
        x,y,z=v.co
        poids=rampe(.52,.60,abs(x))*(1-rampe(.98,1.04,z))*rampe(.74,.80,z)
        pivot=Vector((math.copysign(.56,x),0,.875))
        v.co=pivot+(v.co-pivot)*(1+.28*poids)
        tete=rampe(1.025,1.09,z)*(1-rampe(1.32,1.39,z))
        v.co.x*=1+.09*tete
    ajuster_proportions(objet,rig)


def matieres(objet):
    for mat in objet.data.materials:
        nodes=mat.node_tree.nodes;liens=mat.node_tree.links
        p=nodes.get('Principled BSDF')
        if mat.name.startswith('Boucle_or'):
            p.inputs['Roughness'].default_value=.30
            p.inputs['Specular IOR Level'].default_value=.5
            continue
        if mat.name.startswith('Ruban_cuir'):
            p.inputs['Roughness'].default_value=.76
            p.inputs['Specular IOR Level'].default_value=.18
            continue
        p.inputs['Specular IOR Level'].default_value=.20
        if mat.name.startswith('Chapeau_violet'):
            couleur=(.32,.061,.65,1);rugosite=.82
        elif mat.name.startswith('Echarpe_turquoise'):
            couleur=(.012,.34,.46,1);rugosite=.83
        else:
            p.inputs['Roughness'].default_value=.63
            continue
        coord=nodes.new('ShaderNodeTexCoord')
        grain=nodes.new('ShaderNodeTexNoise');grain.inputs['Scale'].default_value=180
        grain.inputs['Detail'].default_value=2.;grain.inputs['Roughness'].default_value=.65
        liens.new(coord.outputs['Generated'],grain.inputs['Vector'])
        teinte=nodes.new('ShaderNodeValToRGB')
        teinte.color_ramp.elements[0].position=.15;teinte.color_ramp.elements[1].position=.85
        teinte.color_ramp.elements[0].color=tuple(c*.91 for c in couleur[:3])+(1,)
        teinte.color_ramp.elements[1].color=tuple(c*1.055 for c in couleur[:3])+(1,)
        liens.new(grain.outputs['Fac'],teinte.inputs[0]);liens.new(teinte.outputs['Color'],p.inputs['Base Color'])
        relief=nodes.new('ShaderNodeBump');relief.inputs['Strength'].default_value=.12;relief.inputs['Distance'].default_value=.0018
        liens.new(grain.outputs['Fac'],relief.inputs['Height']);liens.new(relief.outputs['Normal'],p.inputs['Normal'])
        p.inputs['Roughness'].default_value=rugosite


def cuire(objet):
    anciennes_matieres=list(objet.data.materials)
    anciens_indices=[face.material_index for face in objet.data.polygons]
    bpy.ops.object.select_all(action='DESELECT');objet.select_set(True);bpy.context.view_layer.objects.active=objet
    scene=bpy.context.scene;scene.render.engine='CYCLES';scene.cycles.samples=8;scene.render.bake.margin=8
    scene.render.bake.use_pass_direct=False;scene.render.bake.use_pass_indirect=False;scene.render.bake.use_pass_color=True
    images={}
    for nom,type_cuisson in [('couleur','DIFFUSE'),('normales','NORMAL'),('rugosite','ROUGHNESS')]:
        image=bpy.data.images.new('Mage_sculpte_'+nom,4096,4096,alpha=False)
        if nom!='couleur':image.colorspace_settings.name='Non-Color'
        for mat in objet.data.materials:
            nodes=mat.node_tree.nodes;noeud=nodes.new('ShaderNodeTexImage');noeud.image=image
            nodes.active=noeud
        print('Cuisson',nom,flush=True);bpy.ops.object.bake(type=type_cuisson)
        image.filepath_raw=str(SOURCE/(nom+'.png'));image.file_format='PNG';image.save();image.pack()
        images[nom]=image
    mat=bpy.data.materials.new('Mage_sculpte_matiere');mat.use_nodes=True
    n=mat.node_tree.nodes;l=mat.node_tree.links;p=n.get('Principled BSDF')
    p.inputs['Specular IOR Level'].default_value=.22
    for nom,image in images.items():
        tex=n.new('ShaderNodeTexImage');tex.image=image
        if nom=='couleur': l.new(tex.outputs['Color'],p.inputs['Base Color'])
        elif nom=='rugosite': l.new(tex.outputs['Color'],p.inputs['Roughness'])
        else:
            relief=n.new('ShaderNodeNormalMap');relief.inputs['Strength'].default_value=.65
            l.new(tex.outputs['Color'],relief.inputs['Color']);l.new(relief.outputs['Normal'],p.inputs['Normal'])
    objet.data.materials.clear();objet.data.materials.append(mat)
    # Les accessoires ajoutes n'utilisent pas l'atlas de la peau sculptee.
    for ancienne in anciennes_matieres[3:]:objet.data.materials.append(ancienne)
    for face,indice in zip(objet.data.polygons,anciens_indices):
        face.material_index=0 if indice<3 else indice-2


def articuler_echarpe(objet,rig):
    bpy.context.view_layer.objects.active=rig;bpy.ops.object.mode_set(mode='EDIT')
    for nom,p,parent in [('echarpe_milieu',(-.36,.19,.75),'echarpe'),('echarpe_bout',(-.52,.21,.60),'echarpe_milieu')]:
        os=rig.data.edit_bones.new(nom);os.head=position_corrigee(Vector(p))
        os.tail=os.head+Vector((0,0,.08));os.parent=rig.data.edit_bones[parent]
    bpy.ops.object.mode_set(mode='OBJECT')
    original=objet.vertex_groups['echarpe']
    groupes=[original,objet.vertex_groups.new(name='echarpe_milieu'),objet.vertex_groups.new(name='echarpe_bout')]
    for v in objet.data.vertices:
        if not any(g.group==original.index and g.weight>.5 for g in v.groups):continue
        t=max(0,min(2,(-v.co.x-.22)/.30*2));indice=min(1,int(t));fraction=t-indice
        original.remove([v.index]);groupes[indice].add([v.index],1-fraction,'REPLACE');groupes[indice+1].add([v.index],fraction,'REPLACE')


if __name__=='__main__':
    SOURCE.mkdir(parents=True,exist_ok=True);TRAVAIL.mkdir(parents=True,exist_ok=True)
    bpy.ops.wm.read_factory_settings(use_empty=True);bpy.context.preferences.filepaths.save_version=0
    base.SORTIE=TRAVAIL;base.ALLEGEMENT=.42;base.texturer=texturer_copie;base.ajuster_proportions=proportions
    base.meshy()
    objet=bpy.data.objects['Mage_v2'];objet.name='Mage_sculpte'
    rig=bpy.data.objects['Squelette']
    matieres(objet);cuire(objet);articuler_echarpe(objet,rig)
    bpy.ops.wm.save_as_mainfile(filepath=str(SOURCE/'mage_sculpte.blend'))
    bpy.ops.object.select_all(action='SELECT')
    chemin=RACINE/'assets/3d/characters/mage_sculpte.glb'
    bpy.ops.export_scene.gltf(filepath=str(chemin),export_format='GLB',use_selection=True,
        export_animations=True,export_animation_mode='NLA_TRACKS',export_force_sampling=True,export_skins=True)
    animer(chemin)
    # La source de consultation doit montrer les memes clips que le modele livre.
    bpy.ops.wm.read_factory_settings(use_empty=True)
    bpy.ops.import_scene.gltf(filepath=str(chemin))
    bpy.ops.file.pack_all()
    bpy.ops.wm.save_as_mainfile(filepath=str(SOURCE/'mage_sculpte.blend'))
    print('MAGE_SCULPTE exporte independamment',chemin,flush=True)
