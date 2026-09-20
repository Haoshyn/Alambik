"""Reprise de la geometrie sculptee, dans des fichiers entierement separes."""
import math
import sys
from pathlib import Path

import bpy
from mathutils import Vector

sys.path.insert(0,str(Path(__file__).resolve().parent))
import variantes_mage as base
import texturer_mage_reference as projection
from texturer_mage_reference import texturer, ajuster_proportions, position_corrigee, rampe
from animer_mage_v2 import animer
import chapeau_sculpte
import tete_sculptee
import sans_echarpe
import vetement_sculpte
import bottes_sculptees
import raccord_tunique
import gestes_baguette

RACINE=Path(__file__).resolve().parents[2]
SOURCE=RACINE/'assets/3d/sources/characters/mage_sculpte'
TRAVAIL=RACINE/'tmp/mage-sculpte'


def surface_echarpe(x,y,z):
    # Inclure l'epaisseur et l'attache dorsale dans le tissu et dans son articulation.
    return .43<z<1.025 and ((x<-.12 and y>.105 and z>.72) or
                          (x<-.12 and y>.20) or (x<-.28 and y>.035))


def texturer_copie(objet,reference,sortie):
    sans_echarpe.preparer(objet,surface_echarpe)
    tete_sculptee.preparer_oreilles(objet)
    chapeau_sculpte.retirer_ancien(objet)
    ancien_masque=projection.surface_chapeau
    # Le chapeau neuf sera ajoute apres la projection ; ne plus teinter les cheveux.
    projection.surface_chapeau=lambda x,y,z,normale=None: False
    try:
        texturer(objet,reference,TRAVAIL/'projection.png',marge_uv=.0015,marge_cuisson=8,corriger_cheveux=True,yeux_stylises=True,sans_echarpe=True)
    finally:
        projection.surface_chapeau=ancien_masque
    sans_echarpe.habiller(objet)


def ajouter_accessoires(objet):
    tete_sculptee.ajouter(objet)
    chapeau_sculpte.ajouter(objet)


def proportions(objet,rig):
    debut=int(objet['debut_chapeau'])
    chapeau=[v.co.copy() for v in list(objet.data.vertices)[debut:]]
    # Les mains doivent rester lisibles une fois les bras abaisses.
    for v in objet.data.vertices:
        x,y,z=v.co
        poids=rampe(.52,.60,abs(x))*(1-rampe(.98,1.04,z))*rampe(.74,.80,z)
        pivot=Vector((math.copysign(.56,x),0,.875))
        v.co=pivot+(v.co-pivot)*(1+.28*poids)
        tete=rampe(1.025,1.09,z)*(1-rampe(1.32,1.39,z))
        v.co.x*=1+.09*tete
        # Arrondir la machoire apres la projection conserve le dessin du visage.
        visage=(1-rampe(-.14,-.035,y))*rampe(.995,1.025,z)
        menton=visage*(1-rampe(1.055,1.14,z))
        cote=rampe(.075,.26,abs(x))
        v.co.x*=1-.10*menton*cote
        v.co.z+=.022*menton*cote
        joue=visage*rampe(1.04,1.10,z)*(1-rampe(1.14,1.22,z))*rampe(.06,.15,abs(x))
        v.co.y-=.013*joue
    ajuster_proportions(objet,rig)
    # Le plafond se calcule apres l'elargissement de la tete, sous le bord reel.
    for v in list(objet.data.vertices)[:debut]:
        plafond=chapeau_sculpte.plafond_cheveux(v.co.x,v.co.y)
        v.co.z=min(v.co.z,plafond)
    # Le bord est deja construit aux proportions finales pour garder son epaisseur.
    for v,point in zip(list(objet.data.vertices)[debut:],chapeau):v.co=point
    indices=list(range(debut,len(objet.data.vertices)))
    for groupe in objet.vertex_groups:groupe.remove(indices)
    # Le bord suit la tete ; seule la pointe conserve le mouvement secondaire.
    for indice in indices:
        point=objet.data.vertices[indice].co
        bord=position_corrigee(Vector((point.x,point.y,chapeau_sculpte.altitude(point.x,point.y)))).z
        souplesse=rampe(.28,.55,point.z-bord)
        objet.vertex_groups['tete'].add([indice],1-souplesse,'REPLACE')
        objet.vertex_groups['chapeau'].add([indice],souplesse,'REPLACE')
    indices_tete=set()
    for face in objet.data.polygons:
        if objet.data.materials[face.material_index].name.startswith(('Tete_','Oreille_')):
            indices_tete.update(face.vertices)
    for groupe in objet.vertex_groups:groupe.remove(list(indices_tete))
    objet.vertex_groups['tete'].add(list(indices_tete),1.,'REPLACE')


def matieres(objet):
    for mat in objet.data.materials:
        nodes=mat.node_tree.nodes;liens=mat.node_tree.links
        p=nodes.get('Principled BSDF')
        if mat.name.startswith(('Chapeau_reconstruit','Tunique_raccord_col')):
            continue
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
    objet.data.uv_layers.active_index=objet.data.uv_layers.find('Atlas_v2')
    objet.data.uv_layers['Atlas_v2'].active_render=True
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
        cheveux=anciennes_matieres[indice].name.startswith(('Tete_cheveux_','Tunique_raccord_col'))
        face.material_index=0 if indice<3 or cheveux else indice-2



if __name__=='__main__':
    SOURCE.mkdir(parents=True,exist_ok=True);TRAVAIL.mkdir(parents=True,exist_ok=True)
    bpy.ops.wm.read_factory_settings(use_empty=True);bpy.context.preferences.filepaths.save_version=0
    base.SORTIE=TRAVAIL;base.ALLEGEMENT=.42;base.texturer=texturer_copie;base.ajuster_proportions=proportions
    projection.surface_pan=lambda x,y,z: False
    base.surface_pan=projection.surface_pan
    base.accessoires_chapeau=ajouter_accessoires
    base.meshy()
    objet=bpy.data.objects['Mage_v2'];objet.name='Mage_sculpte'
    rig=bpy.data.objects['Squelette']
    matieres(objet);cuire(objet)
    bpy.context.view_layer.objects.active=rig;bpy.ops.object.mode_set(mode='EDIT')
    rig.data.edit_bones.remove(rig.data.edit_bones['echarpe'])
    bpy.ops.object.mode_set(mode='OBJECT')
    objet.vertex_groups.remove(objet.vertex_groups['echarpe'])
    bpy.ops.wm.save_as_mainfile(filepath=str(SOURCE/'mage_sculpte.blend'))
    bpy.ops.object.select_all(action='SELECT')
    chemin=TRAVAIL/'mage_sculpte.glb'
    bpy.ops.export_scene.gltf(filepath=str(chemin),export_format='GLB',use_selection=True,
        export_animations=True,export_animation_mode='NLA_TRACKS',export_force_sampling=True,export_skins=True)
    animer(chemin)
    vetement_sculpte.finaliser(chemin)
    bottes_sculptees.finaliser(chemin)
    raccord_tunique.finaliser(chemin)
    gestes_baguette.finaliser(chemin)
    # La source de consultation doit montrer les memes clips que le modele livre.
    bpy.ops.wm.read_factory_settings(use_empty=True)
    bpy.ops.import_scene.gltf(filepath=str(chemin))
    bpy.ops.file.pack_all()
    bpy.context.preferences.filepaths.save_version=0
    source_finale=TRAVAIL/'mage_sculpte.blend'
    bpy.ops.wm.save_as_mainfile(filepath=str(source_finale))
    source_finale.replace(SOURCE/'mage_sculpte.blend')
    destination=RACINE/'assets/3d/characters/mage_sculpte.glb'
    chemin.replace(destination)
    print('MAGE_SCULPTE exporte independamment',destination,flush=True)
