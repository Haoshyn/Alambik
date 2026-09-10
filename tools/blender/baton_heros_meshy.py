"""Baton du concept B : bois, monture cuivre et orbe violet, lie a la main."""
import bpy
import bmesh
import math
from mathutils import Vector


def fermer_main(objet):
    # Les doigts ouverts du Meshy ne forment pas une prise : les remplacer
    # par un gant ferme, construit autour du manche, en conservant le poignet.
    maillage = bmesh.new()
    maillage.from_mesh(objet.data)
    doigts = [v for v in maillage.verts if v.co.x < -.365 and .68 < v.co.z < .88]
    bmesh.ops.delete(maillage,geom=doigts,context='VERTS')
    maillage.to_mesh(objet.data)
    maillage.free()
    objet.data.update()


def creer_baton(rig):
    morceaux = []
    def mat(nom,couleur,metal=0,brillance=.5):
        m=bpy.data.materials.new(nom);m.diffuse_color=(*couleur,1);m.use_nodes=True
        p=m.node_tree.nodes.get('Principled BSDF')
        p.inputs['Base Color'].default_value=(*couleur,1)
        p.inputs['Metallic'].default_value=metal;p.inputs['Roughness'].default_value=brillance
        return m
    bois=mat('Baton_noyer',(.095,.032,.014),0,.62)
    cuivre=mat('Baton_cuivre',(.55,.235,.06),.72,.28)
    cuir=mat('Baton_prise',(.042,.016,.009),0,.75)
    gemme=mat('Baton_amethyste',(.23,.015,.48),.2,.19)
    p=gemme.node_tree.nodes.get('Principled BSDF')
    p.inputs['Emission Color'].default_value=(.19,.008,.45,1)
    p.inputs['Emission Strength'].default_value=.28
    def ajouter(obj,m):
        obj.data.materials.append(m);morceaux.append(obj)
        for face in obj.data.polygons:face.use_smooth=True
        return obj
    def tour(nom,profil,m):
        verts=[];faces=[];n=24
        for z,r in profil:
            verts.extend((r*math.cos(i*math.tau/n),r*math.sin(i*math.tau/n),z) for i in range(n))
        for j in range(len(profil)-1):
            for i in range(n):
                k=j*n+i;l=j*n+(i+1)%n
                faces.append((k,l,l+n,k+n))
        faces.extend([tuple(reversed(range(n))),tuple((len(profil)-1)*n+i for i in range(n))])
        mesh=bpy.data.meshes.new(nom);mesh.from_pydata(verts,[],faces);mesh.update()
        obj=bpy.data.objects.new(nom,mesh);bpy.context.collection.objects.link(obj)
        return ajouter(obj,m)
    tour('Fut',[(-.64,.012),(-.59,.017),(.46,.017),(.51,.023)],bois)
    tour('Poignee',[(-.12,.019),(.065,.019)],cuir)
    for z in [-.57,-.46,-.13,.07,.39,.48]:
        tour('Bague',[(z-.016,.018),(z-.010,.025),(z+.010,.025),(z+.016,.018)],cuivre)
    tour('Talon',[(-.72,.001),(-.65,.025),(-.635,.022),(-.63,.014)],cuivre)
    tour('Chapiteau',[(.47,.019),(.50,.037),(.52,.029),(.54,.040),(.56,.024),(.59,.018)],cuivre)
    bpy.ops.mesh.primitive_torus_add(major_radius=.116,minor_radius=.012,major_segments=40,minor_segments=8,location=(0,0,.665),rotation=(math.pi/2,0,0))
    ajouter(bpy.context.object,cuivre)
    bpy.ops.mesh.primitive_uv_sphere_add(segments=24,ring_count=12,radius=.091,location=(0,0,.665))
    ajouter(bpy.context.object,gemme)
    for x in [-.12,.12]:
        bpy.ops.mesh.primitive_uv_sphere_add(segments=12,ring_count=8,radius=.023,location=(x,0,.665))
        ajouter(bpy.context.object,cuivre)
    tour('Fleuron',[(.765,.016),(.78,.027),(.79,.014),(.855,.001)],cuivre)
    # Construire vertical dans la pose repos, puis revenir a l'espace de liaison.
    rig.animation_data.action=bpy.data.actions['repos']
    bpy.context.scene.frame_set(1);bpy.context.view_layer.update()
    deformation=rig.pose.bones['main_droite'].matrix @ rig.data.bones['main_droite'].matrix_local.inverted()
    poignet=deformation @ Vector((-.405,-.07,.895))
    prise=poignet+Vector((-.015,-.055,-.068))
    axe=Vector((-.12,-.48,1)).normalized()
    orientation=Vector((0,0,1)).rotation_difference(axe).to_matrix()
    bpy.ops.object.select_all(action='DESELECT')
    for obj in morceaux:obj.select_set(True)
    bpy.context.view_layer.objects.active=morceaux[0]
    bpy.ops.object.join()
    baton=bpy.context.object;baton.name='Baton_heros_B'
    bpy.ops.object.transform_apply(location=True,rotation=True,scale=True)
    # L'orbe s'ecarte de la tete ; le manche passe devant la paume et le poignet.
    for v in baton.data.vertices:v.co=deformation.inverted() @ (orientation @ (v.co+Vector((0,0,.055)))+prise)
    groupe=baton.vertex_groups.new(name='main_droite')
    groupe.add(list(range(len(baton.data.vertices))),1,'REPLACE')
    baton.parent=rig;mod=baton.modifiers.new('Prise_main','ARMATURE');mod.object=rig
    main=creer_main(rig,deformation,prise,orientation,poignet,cuir,cuivre)
    rig.animation_data.action=None
    return baton,main


def creer_main(rig,deformation,prise,orientation,poignet,cuir,cuivre):
    morceaux=[]
    def volume(nom,centre,echelle,materiau):
        bpy.ops.mesh.primitive_uv_sphere_add(segments=16,ring_count=10,radius=1,location=centre)
        o=bpy.context.object;o.name=nom;o.scale=echelle
        o.data.materials.append(materiau)
        for face in o.data.polygons:face.use_smooth=True
        morceaux.append(o)
    volume('Paume_gantee',(0,.038,.006),(.037,.026,.055),cuir)
    raccord=orientation.inverted() @ (poignet-prise)
    base=Vector((0,.038,.020))
    volume('Raccord_poignet',(raccord+base)*.5,(.028,.025,(raccord-base).length*.5+.022),cuir)
    morceaux[-1].rotation_mode='QUATERNION'
    morceaux[-1].rotation_quaternion=Vector((0,0,1)).rotation_difference((raccord-base).normalized())
    # Quatre doigts recourbes devant le fut, et un pouce oppose.
    for index,z in enumerate([-.034,-.012,.010,.032]):
        points=[]
        for i in range(13):
            angle=math.radians(135+205*i/12)
            points.append(Vector((.029*math.cos(angle),.029*math.sin(angle),z)))
        vertices=[];faces=[]
        for i,p in enumerate(points):
            normale=Vector((p.x,p.y,0)).normalized()
            for j in range(8):
                a=j*math.tau/8
                vertices.append(p+.010*(math.cos(a)*normale+math.sin(a)*Vector((0,0,1))))
        for i in range(len(points)-1):
            for j in range(8):
                a=i*8+j;b=i*8+(j+1)%8
                faces.append((a,b,b+8,a+8))
        faces.extend([tuple(reversed(range(8))),tuple((len(points)-1)*8+j for j in range(8))])
        mesh=bpy.data.meshes.new('Doigt_ferme');mesh.from_pydata(vertices,[],faces);mesh.update()
        o=bpy.data.objects.new('Doigt_'+str(index),mesh);bpy.context.collection.objects.link(o)
        o.data.materials.append(cuir)
        for face in mesh.polygons:face.use_smooth=True
        morceaux.append(o)
    volume('Pouce_oppose',(.032,.002,.035),(.017,.029,.018),cuir)
    volume('Renfort_gant',(-.027,.035,.015),(.014,.020,.032),cuivre)
    bpy.ops.object.select_all(action='DESELECT')
    for o in morceaux:o.select_set(True)
    bpy.context.view_layer.objects.active=morceaux[0]
    bpy.ops.object.join()
    main=bpy.context.object;main.name='Main_prise_heros_B'
    bpy.ops.object.transform_apply(location=True,rotation=True,scale=True)
    for v in main.data.vertices:v.co=deformation.inverted() @ (orientation @ v.co+prise)
    groupe=main.vertex_groups.new(name='main_droite')
    groupe.add(list(range(len(main.data.vertices))),1,'REPLACE')
    main.parent=rig
    mod=main.modifiers.new('Gant_solidaire','ARMATURE');mod.object=rig
    return main
