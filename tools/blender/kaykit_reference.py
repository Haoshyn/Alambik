"""Adapte la DA du mage KayKit en conservant le rig et les clips du pack."""
import bpy
import bmesh
import math
from pathlib import Path
from mathutils import Vector


def matiere(nom,couleur,metal=0,rugosite=.5):
    m=bpy.data.materials.new(nom);m.use_nodes=True
    p=m.node_tree.nodes.get('Principled BSDF')
    p.inputs['Base Color'].default_value=(*couleur,1)
    p.inputs['Metallic'].default_value=metal;p.inputs['Roughness'].default_value=rugosite
    return m


def styliser(source,sortie):
    bpy.ops.wm.read_factory_settings(use_empty=True)
    bpy.ops.import_scene.gltf(filepath=str(source))
    rig=next(o for o in bpy.context.scene.objects if o.type=='ARMATURE')
    for piste in rig.animation_data.nla_tracks:piste.mute=True
    rig.animation_data.action=None
    for os in rig.pose.bones:
        os.location=(0,0,0);os.rotation_mode='QUATERNION';os.rotation_quaternion=(1,0,0,0);os.scale=(1,1,1)
    originaux=[o for o in bpy.context.scene.objects if o.name.startswith('Mage_') and o.type=='MESH']
    ajouts=[]
    # Chaque case du nuancier KayKit est une matiere semantique distincte.
    teintes={(0,1):(146,50,229),(1,1):(146,50,229),(7,1):(116,33,191),
             (1,0):(100,48,27),(2,0):(39,16,9),(2,1):(14,154,186),
             (3,0):(246,174,56),(4,0):(127,69,43),(5,0):(133,70,40),
             (3,2):(131,73,45),(2,2):(25,161,189)}
    images={n.image for o in originaux for m in o.data.materials if m and m.use_nodes
            for n in m.node_tree.nodes if n.type=='TEX_IMAGE' and n.image}
    import numpy as np
    for image in images:
        largeur,hauteur=image.size
        pixels=np.array(image.pixels[:],dtype=np.float32).reshape((hauteur,largeur,4))
        for (col,ligne),couleur in teintes.items():
            xa,xb=col*largeur//8,(col+1)*largeur//8
            ya,yb=(3-ligne)*hauteur//4,(4-ligne)*hauteur//4
            bloc=pixels[ya:yb,xa:xb,:3]
            centre=bloc[bloc.shape[0]//2,bloc.shape[1]//2].copy()
            # Garder le degrade de volume de chaque case, pas son ancienne teinte.
            intensite=np.mean(bloc,axis=2,keepdims=True)/max(.02,float(np.mean(centre)))
            cible=np.array(couleur,dtype=np.float32)/255
            bloc[:]=np.clip(cible*intensite,0,1)
        image.pixels.foreach_set(pixels.ravel());image.update();image.pack()
    or_mat=matiere('Or_chaud',(.95,.45,.045),.65,.27)
    cuir=matiere('Cuir_chataigne',(.24,.075,.034),0,.65)
    turquoise=matiere('Echarpe_turquoise',(.008,.39,.54),0,.7)
    verre=matiere('Potion_turquoise',(.008,.44,.65),.25,.16)
    blanc=matiere('Blanc_yeux',(.97,.91,.79),0,.3)
    iris=matiere('Iris_noisette',(.22,.067,.022),0,.27)
    pupille=matiere('Pupille',(.009,.003,.002),0,.2)
    reflet=matiere('Reflet_yeux',(1,1,1),0,.16)
    def case(o,face):
        uv=o.data.uv_layers.active
        u=sum(uv.data[i].uv.x for i in face.loop_indices)/len(face.loop_indices)
        v=sum(uv.data[i].uv.y for i in face.loop_indices)/len(face.loop_indices)
        return (int(u*8),int((1-v)*4))
    for o in originaux:
        supprimer=[]
        for face in o.data.polygons:
            c=case(o,face)
            if o.name=='Mage_Hat' and c==(3,0):supprimer.append(face.index)
            if o.name=='Mage_Body' and c==(3,0) and face.center.z<.81 and abs(face.center.x)<.17:
                supprimer.append(face.index)
        if supprimer:
            bm=bmesh.new();bm.from_mesh(o.data);bm.faces.ensure_lookup_table()
            bmesh.ops.delete(bm,geom=[bm.faces[i] for i in supprimer],context='FACES')
            bm.to_mesh(o.data);bm.free()
        if o.name=='Mage_Head':
            cheveux=set()
            for face in o.data.polygons:
                if case(o,face)==(1,0):cheveux.update(face.vertices)
            for index in cheveux:
                v=o.data.vertices[index]
                if v.co.z<1.49:v.co.z=1.49+(v.co.z-1.49)*.28
                if v.co.z>1.985:v.co.z=1.985+(v.co.z-1.985)*.03
                if v.co.y<-.30 and 1.69<v.co.z<1.82 and abs(v.co.x)<.35:
                    v.co.z=1.745+(v.co.z-1.745)*.58
        if o.name in ['Mage_Head','Mage_Hat']:
            for face in o.data.polygons:face.use_smooth=True
    for nom in ['Mage_Cape','Mage_Hat']:
        ancien=next(o for o in originaux if o.name==nom)
        originaux.remove(ancien);bpy.data.objects.remove(ancien,do_unlink=True)
    def attacher(o,nom,mat,os):
        o.name=nom;o.data.materials.clear();o.data.materials.append(mat)
        bpy.ops.object.select_all(action='DESELECT');o.select_set(True)
        bpy.context.view_layer.objects.active=o
        bpy.ops.object.transform_apply(location=True,rotation=True,scale=True)
        o.parent=rig;o.matrix_parent_inverse.identity()
        o.vertex_groups.new(name=os).add(list(range(len(o.data.vertices))),1,'REPLACE')
        o.modifiers.new('Articulation','ARMATURE').object=rig
        for f in o.data.polygons:f.use_smooth=True
        ajouts.append(o)
        return o
    def boule(nom,pos,taille,mat,os):
        bpy.ops.mesh.primitive_uv_sphere_add(segments=24,ring_count=16,location=pos)
        o=bpy.context.object;o.scale=taille
        return attacher(o,nom,mat,os)
    def anneau(nom,pos,rayon,tube,mat,os,rotation=(math.pi/2,0,0),echelle=(1,1,1)):
        bpy.ops.mesh.primitive_torus_add(major_segments=40,minor_segments=12,location=pos,
            major_radius=rayon,minor_radius=tube,rotation=rotation)
        o=bpy.context.object;o.scale=echelle
        return attacher(o,nom,mat,os)
    violet=matiere('Feutre_violet',(.39,.025,.72),0,.72)
    def surface(nom,verts,faces,mat):
        data=bpy.data.meshes.new(nom);data.from_pydata(verts,[],faces);data.update()
        o=bpy.data.objects.new(nom,data);bpy.context.collection.objects.link(o)
        return attacher(o,nom,mat,'head')
    # Un vrai chapeau recourbe evite les cassures des faces triangulees du cone.
    segments=64;anneaux=32;verts=[];faces=[]
    def centre(t):return Vector((-.58*t**2.3,0,2.02+.61*math.sin(t*math.pi*.8)))
    for j in range(anneaux+1):
        t=j/anneaux;c=centre(t)
        tangent=(centre(min(1,t+.001))-centre(max(0,t-.001))).normalized()
        u=Vector((0,1,0)).cross(tangent).normalized()
        rayon=.455*(1-t)**.8+.006
        for i in range(segments):
            angle=i*math.tau/segments
            verts.append(c+rayon*math.cos(angle)*u+Vector((0,.85*rayon*math.sin(angle),0)))
    for j in range(anneaux):
        for i in range(segments):
            k=j*segments+i;n=j*segments+(i+1)%segments
            faces.append((k,n,n+segments,k+segments))
    surface('Chapeau_calotte',verts,faces,violet)
    verts=[];faces=[]
    for j in range(7):
        t=j/6;r=.41+.52*t
        for i in range(segments):
            angle=i*math.tau/segments
            z=2.02-.075*t+.065*t*math.sin(angle)+.025*t*math.cos(2*angle)
            verts.append((r*math.cos(angle),.85*r*math.sin(angle),z))
    for j in range(6):
        for i in range(segments):
            k=j*segments+i;n=j*segments+(i+1)%segments
            faces.append((k,n,n+segments,k+segments))
    bord=surface('Chapeau_bord',verts,faces,violet)
    bpy.context.view_layer.objects.active=bord
    epaisseur=bord.modifiers.new('Bord_epais','SOLIDIFY');epaisseur.thickness=.035
    bpy.ops.object.modifier_apply(modifier=epaisseur.name)
    verts=[];faces=[]
    for j in range(3):
        z=2.025+j*.075;r=.472-j*.028
        for i in range(segments):
            angle=i*math.tau/segments
            verts.append((r*math.cos(angle),.85*r*math.sin(angle),z))
    for j in range(2):
        for i in range(segments):
            k=j*segments+i;n=j*segments+(i+1)%segments
            faces.append((k,n,n+segments,k+segments))
    surface('Chapeau_bande_cuir',verts,faces,cuir)
    # Les nouveaux accessoires utilisent les os natifs : aucune retouche des clips.
    for signe in [-1,1]:
        x=signe*.183
        boule('Oeil_blanc',(x,-.421,1.602),(.086,.044,.107),blanc,'head')
        boule('Oeil_iris',(x,-.459,1.599),(.073,.024,.094),iris,'head')
        boule('Oeil_pupille',(x,-.478,1.612),(.043,.013,.067),pupille,'head')
        boule('Oeil_reflet',(x-.019,-.490,1.642),(.017,.008,.020),reflet,'head')
        boule('Oeil_reflet_petit',(x+.021,-.484,1.568),(.008,.006,.010),reflet,'head')
    for z,rayon in [(1.205,.295),(1.145,.31)]:
        anneau('Echarpe_col',(0,0,z),rayon,.075,turquoise,'chest',rotation=(0,0,0),echelle=(1,.95,.7))
    boule('Echarpe_noeud',(-.10,-.299,1.17),(.086,.078,.12),turquoise,'chest')
    # Ruban epais flottant vers la gauche, comme sur l'illustration.
    points=[(-.12,.15,1.20),(-.29,.20,1.10),(-.44,.28,.98),(-.64,.27,.92),(-.77,.30,.82)]
    verts=[]
    for i,(x,y,z) in enumerate(points):
        largeur=.085+.012*i
        verts.extend([(x,y-.025,z+largeur),(x,y+.025,z-largeur)])
    faces=[(2*i,2*i+1,2*i+3,2*i+2) for i in range(len(points)-1)]
    data=bpy.data.meshes.new('Ruban');data.from_pydata(verts,[],faces);data.update()
    ruban=bpy.data.objects.new('Echarpe_pan',data);bpy.context.collection.objects.link(ruban)
    bpy.context.view_layer.objects.active=ruban
    sub=ruban.modifiers.new('Tissu_arrondi','SUBSURF');sub.levels=2;bpy.ops.object.modifier_apply(modifier=sub.name)
    sol=ruban.modifiers.new('Epaisseur','SOLIDIFY');sol.thickness=.025;bpy.ops.object.modifier_apply(modifier=sol.name)
    attacher(ruban,'Echarpe_pan',turquoise,'chest')
    anneau('Boucle_chapeau',(0,-.427,2.17),.116,.026,or_mat,'head')
    anneau('Boucle_ceinture',(0,-.375,.701),.080,.020,or_mat,'hips')
    boule('Ardillon',(0,-.401,.701),(.057,.012,.012),or_mat,'hips')
    boule('Fiole',(-.34,-.351,.537),(.11,.10,.13),verre,'hips')
    anneau('Fiole_cerclage',(-.34,-.351,.52),.104,.014,or_mat,'hips',rotation=(0,0,0))
    boule('Fiole_goulot',(-.34,-.351,.657),(.040,.038,.055),verre,'hips')
    boule('Fiole_bouchon',(-.34,-.351,.712),(.038,.036,.032),cuir,'hips')
    for signe,cote in [(-1,'r'),(1,'l')]:
        anneau('Boucle_botte',(signe*.172,-.19,.245),.046,.012,or_mat,'lowerleg.'+cote)
    # L'import garde chaque clip dans sa piste NLA ; les exporter tels quels.
    bpy.ops.object.select_all(action='DESELECT')
    for o in originaux+ajouts+[rig]:o.select_set(True)
    # Le parent commun porte l'echelle de comparaison avec Basic et v2.
    parent=rig.parent
    while parent:
        parent.select_set(True);parent=parent.parent
    bpy.context.view_layer.objects.active=rig
    bpy.ops.export_scene.gltf(filepath=str(sortie),export_format='GLB',use_selection=True,
        export_animations=True,export_animation_mode='NLA_TRACKS',export_force_sampling=True,
        export_skins=True,export_def_bones=True)


if __name__=='__main__':
    racine=Path(__file__).resolve().parents[2]
    styliser(racine/'assets/3d/sources/characters/kaykit_reference/mage_animations_source.glb',
             racine/'assets/3d/characters/mage_kaykit.glb')
