"""Habillage du vrai maillage Meshy depuis la reference du proprietaire.
La projection est cuite dans des UV : elle suit le squelette et non la camera.
"""
import bpy
import math
from mathutils import Vector

HAUTEUR = 2.14284
# Landmarks de la geometrie brute -> lignes correspondantes de la reference.
REPERES = [(0,1497),(.285,1276),(.47,1170),(.615,1080),(.69,1027),
           (.88,906),(1.015,814),(1.08,781),(1.17,701),(1.25,634),
           (1.35,541),(1.54,428),(HAUTEUR,161)]


def rampe(a,b,x):
    t=max(0,min(1,(x-a)/(b-a)))
    return t*t*(3-2*t)


def ligne_reference(z):
    for (a,ya),(b,yb) in zip(REPERES,REPERES[1:]):
        if z<=b:
            return ya+(yb-ya)*(z-a)/(b-a)
    return 161


def position_corrigee(point):
    x,y,z=point
    # Redonner de la place au visage sous le chapeau, selon la reference.
    return Vector((x,y,(1497-ligne_reference(z))*HAUTEUR/1336))


def surface_chapeau(x,y,z,normale=None):
    return (z>1.385-.20*y-.075*abs(x) or
            (y>.35 and z>1.12) or (abs(x)>.46 and z>1.16) or
            (y<-.50 and z>1.18) or (y<-.40 and abs(x)>.34 and z>1.30))


def surface_pan(x,y,z):
    return .43<z<.94 and ((x<-.12 and y>.20) or (x<-.28 and y>.065))


def texturer(objet,reference,sortie,marge_uv=.0008,marge_cuisson=12,corriger_cheveux=False,yeux_stylises=False,sans_echarpe=False):
    bpy.context.view_layer.objects.active=objet
    bpy.ops.object.select_all(action='DESELECT');objet.select_set(True)
    image=bpy.data.images.load(str(reference),check_existing=True)
    largeur,hauteur=image.size
    uv=objet.data.uv_layers.new(name='Projection_reference')
    fond=objet.data.color_attributes.new(name='Fond_reference',type='FLOAT_COLOR',domain='CORNER')
    masque=objet.data.color_attributes.new(name='Masque_reference',type='FLOAT_COLOR',domain='CORNER')
    cheveux_seuls=objet.data.color_attributes.new(name='Zone_cheveux',type='FLOAT_COLOR',domain='CORNER') if corriger_cheveux else None
    positions=[v.co.copy() for v in objet.data.vertices]
    normales=[v.normal.copy() for v in objet.data.vertices]
    print('Projection de la reference',flush=True)
    for boucle in objet.data.loops:
        x,y,z=positions[boucle.vertex_index]
        ligne=ligne_reference(z)
        ligne+=42*rampe(1.35,1.49,z)*(1-rampe(1.65,1.85,z))
        # La boucle de chapeau est decalee sur la reference par rapport au scan.
        centre=480+15*rampe(1.34,1.52,z)
        u=(centre+x*630)/largeur
        uv.data[boucle.index].uv=(u,1-ligne/hauteur)
        violet=Vector((.31,.026,.67));cuir=Vector((.24,.085,.038))
        cheveux=Vector((.16,.057,.027));peau=Vector((.82,.43,.23))
        cyan=Vector((.012,.37,.52))
        c=violet.copy()
        if z>1.015:
            c=cheveux.copy()
            visage=(1-rampe(-.14,.02,y))*(1-rampe(1.23,1.31,z))
            c=c.lerp(peau,visage)

        else:
            echarpe=rampe(.90,.93,z)*(1-rampe(.25,.30,abs(x)))
            # Le pan flottant est du tissu turquoise, pas une cape violette.
            pan=(1-rampe(-.24,-.18,x))*rampe(.45,.52,z)*(1-rampe(.80,.86,z))*rampe(.01,.09,y)
            if not sans_echarpe:c=c.lerp(cyan,max(echarpe,pan))
            c=c.lerp(peau,rampe(.55,.59,abs(x))*rampe(.78,.82,z))
            poignet=rampe(.48,.50,abs(x))*(1-rampe(.55,.57,abs(x)))*rampe(.78,.82,z)
            ceinture=rampe(.60,.615,z)*(1-rampe(.66,.68,z))*(1-rampe(.26,.30,abs(x)))
            c=c.lerp(cuir,max(poignet,ceinture))
            c=c.lerp(cuir,1-rampe(.285,.31,z))
        # Exclure les tissus de la projection photographique, sur toute leur surface.
        est_chapeau=surface_chapeau(x,y,z,normales[boucle.vertex_index])
        col=not sans_echarpe and (.87+.12*abs(x)<z<1.035 and abs(x)<.265)
        pan=surface_pan(x,y,z)
        face=(1-rampe(-.03,.17,y))*rampe(-.25,.30,-normales[boucle.vertex_index].y)
        if z>1.23:
            face*=1-rampe(-.16,-.04,y)
        if est_chapeau:
            c=violet.copy();face=0
        if .78<z<.99 and .265<abs(x)<.43:
            face=0
        if col or pan:
            c=cyan.copy();face=0
        fond.data[boucle.index].color=(*c,1)
        masque.data[boucle.index].color=(face,face,face,1)
        if cheveux_seuls:
            # Un rejet partiel laissait encore du violet sur les racines aux tempes.
            poids=1.0 if z>1.23 and not est_chapeau else 0.0
            cheveux_seuls.data[boucle.index].color=(poids,poids,poids,1)
    print('Projection terminee',flush=True)
    mat=bpy.data.materials.new('Projection_reference_v2');mat.use_nodes=True
    n=mat.node_tree.nodes;l=mat.node_tree.links;n.clear()
    out=n.new('ShaderNodeOutputMaterial');em=n.new('ShaderNodeEmission')
    tex=n.new('ShaderNodeTexImage');tex.image=image;tex.extension='EXTEND'
    coord=n.new('ShaderNodeUVMap');coord.uv_map=uv.name;l.new(coord.outputs['UV'],tex.inputs['Vector'])
    couleur=n.new('ShaderNodeVertexColor');couleur.layer_name=fond.name
    force=n.new('ShaderNodeVertexColor');force.layer_name=masque.name
    alpha=n.new('ShaderNodeMath');alpha.operation='MULTIPLY';l.new(force.outputs['Color'],alpha.inputs[0]);l.new(tex.outputs['Alpha'],alpha.inputs[1])
    if cheveux_seuls:
        # Le bord violet de l'illustration ne doit pas etre projete sur les meches.
        rgb=n.new('ShaderNodeSeparateColor');rgb.mode='RGB';l.new(tex.outputs['Color'],rgb.inputs[0])
        ecart=n.new('ShaderNodeMath');ecart.operation='SUBTRACT';l.new(rgb.outputs['Blue'],ecart.inputs[0]);l.new(rgb.outputs['Red'],ecart.inputs[1])
        violet=n.new('ShaderNodeMapRange');l.new(ecart.outputs[0],violet.inputs['Value'])
        violet.inputs['From Min'].default_value=.02;violet.inputs['From Max'].default_value=.12
        zone=n.new('ShaderNodeVertexColor');zone.layer_name=cheveux_seuls.name
        rejet=n.new('ShaderNodeMath');rejet.operation='MULTIPLY';l.new(violet.outputs[0],rejet.inputs[0]);l.new(zone.outputs['Color'],rejet.inputs[1])
        maintien=n.new('ShaderNodeMath');maintien.operation='SUBTRACT';maintien.inputs[0].default_value=1.;l.new(rejet.outputs[0],maintien.inputs[1])
        filtre=n.new('ShaderNodeMath');filtre.operation='MULTIPLY';l.new(alpha.outputs[0],filtre.inputs[0]);l.new(maintien.outputs[0],filtre.inputs[1])
        alpha=filtre
    teinte=tex.outputs['Color']
    if yeux_stylises:
        from yeux_sculptes import styliser
        teinte=styliser(n,l,coord.outputs['UV'],teinte,largeur,hauteur)
    mix=n.new('ShaderNodeMixRGB');l.new(alpha.outputs[0],mix.inputs[0]);l.new(couleur.outputs['Color'],mix.inputs[1]);l.new(teinte,mix.inputs[2])
    l.new(mix.outputs[0],em.inputs['Color']);l.new(em.outputs[0],out.inputs['Surface'])
    objet.data.materials.clear();objet.data.materials.append(mat)
    for face in objet.data.polygons:face.material_index=0
    # Petites marges pour conserver la resolution du visage sur ce scan detaille.
    atlas=objet.data.uv_layers.new(name='Atlas_v2')
    objet.data.uv_layers.active=atlas;atlas.active_render=True
    bpy.ops.object.mode_set(mode='EDIT');bpy.ops.mesh.select_all(action='SELECT')
    bpy.ops.uv.smart_project(angle_limit=math.radians(80),island_margin=marge_uv)
    bpy.ops.object.mode_set(mode='OBJECT')
    cuisson=bpy.data.images.new('Mage_v2_couleur',width=4096,height=4096,alpha=False)
    cible=n.new('ShaderNodeTexImage');cible.image=cuisson;n.active=cible
    scene=bpy.context.scene;scene.render.engine='CYCLES';scene.cycles.samples=1
    scene.render.bake.margin=marge_cuisson
    print('Cuisson couleur',flush=True)
    bpy.ops.object.bake(type='EMIT')
    cuisson.filepath_raw=str(sortie);cuisson.file_format='PNG';cuisson.save();cuisson.pack()
    final=bpy.data.materials.new('Mage_v2_reference');final.use_nodes=True
    p=final.node_tree.nodes.get('Principled BSDF');p.inputs['Roughness'].default_value=.63
    p.inputs['Specular IOR Level'].default_value=.25
    texture=final.node_tree.nodes.new('ShaderNodeTexImage');texture.image=cuisson
    coord=final.node_tree.nodes.new('ShaderNodeUVMap');coord.uv_map='Atlas_v2'
    final.node_tree.links.new(coord.outputs['UV'],texture.inputs['Vector'])
    final.node_tree.links.new(texture.outputs['Color'],p.inputs['Base Color'])
    objet.data.materials.clear();objet.data.materials.append(final)
    # Les tissus ont leurs propres materiaux : aucun ilot UV voisin ne peut les salir.
    for nom,couleur in [('Chapeau_violet',(.31,.026,.67,1)),('Echarpe_turquoise',(.012,.37,.52,1))]:
        tissu=bpy.data.materials.new(nom);tissu.use_nodes=True
        shader=tissu.node_tree.nodes.get('Principled BSDF')
        shader.inputs['Base Color'].default_value=couleur
        shader.inputs['Roughness'].default_value=.72
        objet.data.materials.append(tissu)
    for polygone in objet.data.polygons:
        x,y,z=polygone.center
        if surface_chapeau(x,y,z,polygone.normal):
            polygone.material_index=1
        elif not sans_echarpe and ((.87+.12*abs(x)<z<1.035 and abs(x)<.265) or surface_pan(x,y,z)):
            polygone.material_index=2
    # Eviter que l'ancien attribut de couleur soit multiplie par l'albedo glTF.
    for attr in list(objet.data.color_attributes):objet.data.color_attributes.remove(attr)
    for nom in [c.name for c in objet.data.uv_layers if c.name != 'Atlas_v2']:
        objet.data.uv_layers.remove(objet.data.uv_layers[nom])
    objet.data.uv_layers.active_index=0;objet.data.uv_layers[0].active_render=True


def ajuster_proportions(objet,rig):
    for v in objet.data.vertices:v.co=position_corrigee(v.co)
    bpy.ops.object.select_all(action='DESELECT');rig.select_set(True)
    bpy.context.view_layer.objects.active=rig
    bpy.ops.object.mode_set(mode='EDIT')
    for os in rig.data.edit_bones:
        os.head=position_corrigee(os.head)
        os.tail=os.head+Vector((0,0,.08))
    bpy.ops.object.mode_set(mode='OBJECT')


def accessoires_chapeau(objet):
    """Un ruban et une boucle en volume evitent les taches de projection."""
    cuir=bpy.data.materials.new('Ruban_cuir_v2');cuir.diffuse_color=(.24,.085,.038,1)
    cuir.use_nodes=True;cuir.node_tree.nodes.get('Principled BSDF').inputs['Base Color'].default_value=cuir.diffuse_color
    cuir.node_tree.nodes.get('Principled BSDF').inputs['Roughness'].default_value=.7
    or_mat=bpy.data.materials.new('Boucle_or_v2');or_mat.use_nodes=True
    p=or_mat.node_tree.nodes.get('Principled BSDF');p.inputs['Base Color'].default_value=(1,.49,.045,1)
    p.inputs['Metallic'].default_value=.65;p.inputs['Roughness'].default_value=.26
    points=[];faces=[];n=128
    for j in range(9):
        z=1.585+j*.135/8
        for i in range(n):
            a=i*math.tau/n
            rayon_x=.37-(z-1.585)*.48
            rayon_y=.385-(z-1.585)*.24
            points.append(Vector((math.cos(a)*(rayon_x+.014),math.sin(a)*(rayon_y+.014),z)))
    for j in range(8):
        for i in range(n):faces.append((j*n+i,j*n+(i+1)%n,(j+1)*n+(i+1)%n,(j+1)*n+i))
    mesh=bpy.data.meshes.new('Ruban');mesh.from_pydata(points,[],faces);mesh.materials.append(cuir)
    ruban=bpy.data.objects.new('Ruban',mesh);bpy.context.collection.objects.link(ruban)
    bpy.ops.mesh.primitive_uv_sphere_add(segments=32,ring_count=16,location=(.085,-.374,1.665))
    fond_boucle=bpy.context.object;fond_boucle.scale=(.087,.020,.084);fond_boucle.data.materials.append(cuir)
    bpy.ops.mesh.primitive_torus_add(major_radius=.071,minor_radius=.018,major_segments=48,minor_segments=12,
        location=(.085,-.388,1.665),rotation=(math.pi/2,0,0))
    boucle=bpy.context.object;boucle.name='Boucle_chapeau';boucle.data.materials.append(or_mat)
    bpy.ops.object.select_all(action='DESELECT')
    for o in (objet,ruban,boucle,fond_boucle):o.select_set(True)
    bpy.context.view_layer.objects.active=objet;bpy.ops.object.join()
    for p in objet.data.polygons:p.use_smooth=True
