"""Retrait local de l'echarpe ; conserver la tunique et les manches sculptees."""
import math
from pathlib import Path
import bpy
import bmesh
from chapeau_sculpte import matiere
from texturer_mage_reference import position_corrigee


def preparer(objet, surface_pan):
    bm=bmesh.new();bm.from_mesh(objet.data)
    zone=bm.faces.layers.int.new('raccord_sans_echarpe')
    supprimer=[]
    for f in bm.faces:
        x,y,z=f.calc_center_median()
        pan=(.43<z<1.015 and y>.175 and x<.10) or (.43<z<.89 and y>.15 and x<-.12) or (.43<z<.75 and x<-.28 and y>-.025)
        bras=abs(x)>.24 and .76<z<1.035
        if pan and not bras:supprimer.append(f)
    bmesh.ops.delete(bm,geom=supprimer,context='FACES')
    bords=[e for e in bm.edges if e.is_boundary]
    if bords:
        faces=bmesh.ops.holes_fill(bm,edges=bords,sides=0)['faces']
        for f in faces:f[zone]=1
        bmesh.ops.triangulate(bm,faces=faces)
    enlever=[f for f in bm.faces if .86<f.calc_center_median().z<1.035 and abs(f.calc_center_median().x)<.29]
    bmesh.ops.delete(bm,geom=enlever,context='FACES')
    bm.to_mesh(objet.data);bm.free();objet.data.update()
    # Reconstruire seulement le raccord, avec un chevauchement interieur sous la tunique.
    bm=bmesh.new()
    profils=((.80,.22,.17),(.815,.235,.185),(.84,.26,.20),(.88,.275,.20),(.91,.26,.19),(.93,.235,.165),
             (.965,.16,.125),(1.005,.12,.105),(1.055,.115,.10))
    anneaux=[]
    for z,rx,ry in profils:
        anneaux.append([bm.verts.new((rx*math.cos(math.tau*i/64),-.065+ry*math.sin(math.tau*i/64),z)) for i in range(64)])
    for bas,haut in zip(anneaux,anneaux[1:]):
        for i in range(64):bm.faces.new((bas[i],bas[(i+1)%64],haut[(i+1)%64],haut[i]))
    bm.faces.new(tuple(reversed(anneaux[0])));bm.faces.new(tuple(anneaux[-1]))
    for signe in (-1,1):
        anneaux=[]
        for x,rayon in ((.19,.08),(.26,.08),(.335,.078)):
            anneaux.append([bm.verts.new((signe*x,-.075+rayon*math.cos(math.tau*i/48),.867+.069*math.sin(math.tau*i/48))) for i in range(48)])
        for bas,haut in zip(anneaux,anneaux[1:]):
            for i in range(48):bm.faces.new((bas[i],bas[(i+1)%48],haut[(i+1)%48],haut[i]))
        bm.faces.new(tuple(reversed(anneaux[0])));bm.faces.new(tuple(anneaux[-1]))
    bmesh.ops.recalc_face_normals(bm,faces=list(bm.faces))
    mesh=bpy.data.meshes.new('Raccord_local');bm.to_mesh(mesh);bm.free()
    raccord=bpy.data.objects.new('Raccord_local',mesh);bpy.context.collection.objects.link(raccord)
    bpy.ops.object.select_all(action='DESELECT');raccord.select_set(True);bpy.context.view_layer.objects.active=raccord
    union=raccord.modifiers.new('Liaison_epaules','REMESH');union.mode='VOXEL';union.voxel_size=.004
    union.use_smooth_shade=True;bpy.ops.object.modifier_apply(modifier=union.name)
    lissage=raccord.modifiers.new('Arrondi_local','SMOOTH');lissage.factor=.5;lissage.iterations=3
    bpy.ops.object.modifier_apply(modifier=lissage.name)
    zone=raccord.data.attributes.new('raccord_sans_echarpe','INT','FACE')
    for valeur in zone.data:valeur.value=1
    objet.select_set(True);bpy.context.view_layer.objects.active=objet;bpy.ops.object.join()


def habiller(objet):
    mat=matiere('Tunique_raccord_col',(.31,.026,.67),.63)
    peau=matiere('Peau_cou',(.82,.43,.23),.63)
    # Reprendre le tissu de la reference pour le seul raccord nouvellement cree.
    n=mat.node_tree.nodes;l=mat.node_tree.links
    coord=n.new('ShaderNodeTexCoord');mapping=n.new('ShaderNodeVectorMath');mapping.operation='MULTIPLY_ADD'
    # Prolonger les memes colonnes de tissu que le torse, sans les pixels turquoise.
    l.new(coord.outputs['Object'],mapping.inputs[0])
    mapping.inputs[1].default_value=(630/941,0,0)
    mapping.inputs[2].default_value=(480/941,1-950/1672,0)
    tex=n.new('ShaderNodeTexImage')
    tex.image=bpy.data.images.load(str(Path(__file__).resolve().parents[2]/'assets/3d/sources/characters/mage_v2/reference.png'),check_existing=True)
    l.new(mapping.outputs[0],tex.inputs['Vector'])
    original=next(noeud.image for noeud in objet.data.materials[0].node_tree.nodes if noeud.type=='TEX_IMAGE' and noeud.image)
    ancien=n.new('ShaderNodeTexImage');ancien.image=original
    uv=n.new('ShaderNodeUVMap');uv.uv_map='Atlas_v2';l.new(uv.outputs[0],ancien.inputs['Vector'])
    position=n.new('ShaderNodeSeparateXYZ');l.new(coord.outputs['Object'],position.inputs[0])
    raccord=n.new('ShaderNodeMapRange');raccord.clamp=True
    l.new(position.outputs['Z'],raccord.inputs['Value'])
    raccord.inputs['From Min'].default_value=position_corrigee((0,0,.79)).z
    raccord.inputs['From Max'].default_value=position_corrigee((0,0,.825)).z
    rgb=n.new('ShaderNodeSeparateColor');l.new(ancien.outputs['Color'],rgb.inputs[0])
    cyan=n.new('ShaderNodeMath');cyan.operation='GREATER_THAN'
    l.new(rgb.outputs['Green'],cyan.inputs[0]);l.new(rgb.outputs['Red'],cyan.inputs[1])
    couverture=n.new('ShaderNodeMath');couverture.operation='MAXIMUM'
    l.new(raccord.outputs[0],couverture.inputs[0]);l.new(cyan.outputs[0],couverture.inputs[1])
    mix=n.new('ShaderNodeMixRGB');l.new(couverture.outputs[0],mix.inputs[0])
    l.new(ancien.outputs['Color'],mix.inputs[1]);l.new(tex.outputs['Color'],mix.inputs[2])
    l.new(mix.outputs[0],n['Principled BSDF'].inputs['Base Color'])
    indice=len(objet.data.materials);objet.data.materials.append(mat);objet.data.materials.append(peau)
    zone=objet.data.attributes['raccord_sans_echarpe']
    for face in objet.data.polygons:
        if zone.data[face.index].value or (.83<face.center.z<1.035 and abs(face.center.x)<.27):
            face.material_index=indice+int(face.center.z>.995)
            face.use_smooth=True
