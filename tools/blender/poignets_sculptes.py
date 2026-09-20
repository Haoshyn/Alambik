"""Mains proportionnees, bracelets centres et retrait de la fiole de ceinture."""
import math

import bpy
import bmesh
from mathutils import Vector

from texturer_mage_reference import position_corrigee


def altitude(z):
    return position_corrigee((0,0,z)).z


def rampe(a,b,x):
    t=max(0.,min(1.,(x-a)/(b-a)))
    return t*t*(3-2*t)


def matiere(nom, couleur, rugosite):
    mat=bpy.data.materials.new(nom);mat.use_nodes=True
    p=mat.node_tree.nodes.get('Principled BSDF')
    p.inputs['Base Color'].default_value=(*couleur,1)
    p.inputs['Roughness'].default_value=rugosite
    p.inputs['Specular IOR Level'].default_value=.18
    return mat


def retirer_potion(objet):
    bm=bmesh.new();bm.from_mesh(objet.data)
    # Le cote oppose donne le drape reel sous la fiole, plutot qu'une plaque
    # de rebouchage. Les UV et les plis sont conserves dans cette greffe locale.
    for point,normale in (((-.095,0,0),(1,0,0)),((.095,0,0),(1,0,0)),
                          ((0,-.055,0),(0,1,0)),((0,-.21,0),(0,1,0)),
                          ((0,0,.37),(0,0,1)),((0,0,.48),(0,0,1)),((0,0,.83),(0,0,1))):
        zone=[f for f in bm.faces if f.material_index==0 and .34<f.calc_center_median().z<.86]
        geom=set(zone)
        for f in zone:geom.update(f.edges);geom.update(f.verts)
        bmesh.ops.bisect_plane(bm,geom=list(geom),dist=.000001,plane_co=point,plane_no=normale)
    donneuses=[f for f in bm.faces if f.material_index==0 and
               f.calc_center_median().x>.095 and f.calc_center_median().y<-.055 and
               .48<f.calc_center_median().z<.83]
    retrait=[]
    for f in bm.faces:
        x,y,z=f.calc_center_median()
        if f.material_index==0 and x<-.095 and ((y<-.055 and .48<z<.83) or (y<-.21 and .37<z<=.48)):
            retrait.append(f)
    bmesh.ops.delete(bm,geom=retrait,context='FACES')
    geom=set(donneuses)
    for f in donneuses:geom.update(f.edges);geom.update(f.verts)
    copie=bmesh.ops.duplicate(bm,geom=list(geom))['geom']
    nouveaux_sommets=[v for v in copie if isinstance(v,bmesh.types.BMVert)]
    nouvelles_faces=[f for f in copie if isinstance(f,bmesh.types.BMFace)]
    groupes={g.name:g.index for g in objet.vertex_groups}
    deformation=bm.verts.layers.deform.active
    for v in nouveaux_sommets:
        v.co.x=-v.co.x
        if deformation:
            poids=dict(v[deformation]);v[deformation].clear()
            for indice,w in poids.items():
                nom=objet.vertex_groups[indice].name
                autre=nom.replace('droite','gauche') if 'droite' in nom else nom.replace('gauche','droite')
                v[deformation][groupes.get(autre,indice)]=w
    bmesh.ops.reverse_faces(bm,faces=nouvelles_faces)
    violet=len(objet.data.materials)
    objet.data.materials.append(matiere('Pantalon_sans_reflet_fiole',(.31,.026,.67),.78))
    for f in bm.faces:
        x,y,z=f.calc_center_median()
        if f.material_index==0 and x<-.095 and y<-.07 and .37<z<=.48:f.material_index=violet
    orphelins=[v for v in bm.verts if not v.link_faces]
    bmesh.ops.delete(bm,geom=orphelins,context='VERTS')
    bm.to_mesh(objet.data);bm.free()


def reprendre_poignets(objet,rig):
    bm=bmesh.new();bm.from_mesh(objet.data)
    for signe in (-1,1):
        region=[f for f in bm.faces if f.calc_center_median().x*signe>.50 and
                .80<f.calc_center_median().z<1.06]
        geom=set(region)
        for f in region:geom.update(f.edges);geom.update(f.verts)
        bmesh.ops.bisect_plane(bm,geom=list(geom),dist=.000001,
                              plane_co=(signe*.565,0,0),plane_no=(1,0,0))
    retrait=[]
    for f in bm.faces:
        x,y,z=f.calc_center_median()
        mat=objet.data.materials[f.material_index]
        if .5049<abs(x)<.565 and .80<z<1.06 and mat.name!='Tunique_violet_uni':
            retrait.append(f)
    bmesh.ops.delete(bm,geom=retrait,context='FACES')
    orphelins=[v for v in bm.verts if not v.link_faces]
    bmesh.ops.delete(bm,geom=orphelins,context='VERTS')
    bm.to_mesh(objet.data);bm.free();objet.data.update()
    z_poignet=altitude(.878)
    for v in objet.data.vertices:
        x,y,z=v.co
        if abs(x)<.56499 or not .78<z<1.06:continue
        signe=1 if x>0 else -1
        # L'ancien scan decale le centre du poignet de huit centimetres en Y.
        # Retrouver l'axe du bras avant de reduire la paume conserve un raccord droit.
        largeur=.46+.24*rampe(.565,.62,abs(x))
        v.co=(signe*(.525+.74*(abs(x)-.565)), (y+.080)*largeur,
              z_poignet+(z-z_poignet)*(.65+.09*rampe(.565,.62,abs(x))))
        cote='gauche' if signe>0 else 'droite'
        main=rampe(.525,.565,abs(v.co.x))
        for g in objet.vertex_groups:g.remove([v.index])
        objet.vertex_groups['main_'+cote].add([v.index],main,'REPLACE')
        objet.vertex_groups['avant_bras_'+cote].add([v.index],1-main,'REPLACE')
    bpy.ops.object.select_all(action='DESELECT');rig.select_set(True)
    bpy.context.view_layer.objects.active=rig;bpy.ops.object.mode_set(mode='EDIT')
    for signe,cote in ((-1,'droite'),(1,'gauche')):
        os=rig.data.edit_bones['main_'+cote]
        deplacement=Vector((signe*.535,0,z_poignet))-os.head
        os.head+=deplacement;os.tail+=deplacement
    bpy.ops.object.mode_set(mode='OBJECT')
    cuir=matiere('Bracelets_cuir_uni',(.24,.085,.038),.75)
    for signe,cote in ((-1,'droite'),(1,'gauche')):
        sommets=[];faces=[];n=48
        profils=((.485,.057,.052),(.491,.069,.061),(.518,.064,.056),(.532,.056,.049),(.535,.052,.045))
        for x,ry,rz in profils:
            for j in range(n):
                a=j*math.tau/n
                sommets.append((signe*x,ry*math.cos(a),z_poignet+rz*math.sin(a)))
        for i in range(len(profils)-1):
            for j in range(n):
                a=i*n+j;b=i*n+(j+1)%n
                faces.append((a,b,b+n,a+n))
        faces.extend((tuple(reversed(range(n))),tuple((len(profils)-1)*n+j for j in range(n))))
        mesh=bpy.data.meshes.new('Bracelet_'+cote);mesh.from_pydata(sommets,[],faces);mesh.update()
        bm=bmesh.new();bm.from_mesh(mesh);bmesh.ops.recalc_face_normals(bm,faces=list(bm.faces));bm.to_mesh(mesh);bm.free()
        bracelet=bpy.data.objects.new('Bracelet_'+cote,mesh);bpy.context.collection.objects.link(bracelet)
        bracelet.data.materials.append(cuir)
        for f in bracelet.data.polygons:f.use_smooth=True
        g=bracelet.vertex_groups.new(name='avant_bras_'+cote);g.add(list(range(len(sommets))),1,'REPLACE')
        bpy.ops.object.select_all(action='DESELECT');objet.select_set(True);bracelet.select_set(True)
        bpy.context.view_layer.objects.active=objet;bpy.ops.object.join()
