"""Chapeau en volumes distincts : bord, calotte et ruban sans projection photo."""
import math
import bpy
import bmesh
from mathutils import Vector
from texturer_mage_reference import position_corrigee


def altitude(x,y):
    return 1.32+.22*x-.24*y


def retirer_ancien(objet):
    maillage=bmesh.new();maillage.from_mesh(objet.data)
    faces=[]
    for face in maillage.faces:
        x,y,z=face.calc_center_median()
        exterieur=(x/.45)**2+(y/.47)**2>1.
        if exterieur and z>1.12+.20*x-.23*y:
            faces.append(face)
    bmesh.ops.delete(maillage,geom=faces,context='FACES')
    # Une coupe plane remplace la suppression par triangles, qui laissait des pointes.
    coupe=bmesh.ops.bisect_plane(maillage,
        geom=list(maillage.verts)+list(maillage.edges)+list(maillage.faces),
        plane_co=Vector((0,0,1.27)),plane_no=Vector((-.22,.24,1)),
        clear_outer=True,clear_inner=False,dist=.00001)
    # Refermer la tete par une calotte qui entre dans le chapeau, sans etirer les meches.
    marque=maillage.faces.layers.int.new('fermeture_crane')
    bord=[e for e in coupe['geom_cut'] if isinstance(e,bmesh.types.BMEdge) and e.is_boundary]
    for retrait,montee in [(.87,.055),(.72,.06)]:
        ajout=bmesh.ops.extrude_edge_only(maillage,edges=bord)['geom']
        sommets={v for v in ajout if isinstance(v,bmesh.types.BMVert)}
        for v in sommets:
            v.co.x*=retrait;v.co.y*=retrait;v.co.z+=montee
        for f in ajout:
            if isinstance(f,bmesh.types.BMFace):f[marque]=1
        bord=[e for e in ajout if isinstance(e,bmesh.types.BMEdge) and all(v in sommets for v in e.verts)]
    fermeture=bmesh.ops.holes_fill(maillage,edges=bord,sides=0)
    for f in fermeture['faces']:f[marque]=1
    bmesh.ops.recalc_face_normals(maillage,faces=list(maillage.faces))
    maillage.to_mesh(objet.data);maillage.free();objet.data.update()


def matiere(nom,couleur,rugosite,metal=0.):
    mat=bpy.data.materials.new(nom);mat.diffuse_color=(*couleur,1);mat.use_nodes=True
    p=mat.node_tree.nodes.get('Principled BSDF')
    p.inputs['Base Color'].default_value=mat.diffuse_color
    p.inputs['Roughness'].default_value=rugosite;p.inputs['Metallic'].default_value=metal
    return mat


def ajouter(objet):
    objet['debut_chapeau']=len(objet.data.vertices)
    violet=matiere('Chapeau_reconstruit',(.32,.061,.65),.82)
    cuir=matiere('Ruban_cuir_sculpte',(.24,.085,.038),.76)
    or_mat=matiere('Boucle_or_sculpte',(1.,.49,.045),.30,.65)
    morceaux=[];n=128
    def volume(nom,points,faces,mat):
        mesh=bpy.data.meshes.new(nom);mesh.from_pydata([position_corrigee(Vector(p)) for p in points],[],faces);mesh.materials.append(mat)
        o=bpy.data.objects.new(nom,mesh);bpy.context.collection.objects.link(o)
        for f in mesh.polygons:f.use_smooth=True
        morceaux.append(o)
        return o
    def relier(lignes):
        return [(j*n+i,j*n+(i+1)%n,(j+1)*n+(i+1)%n,(j+1)*n+i)
                for j in range(lignes-1) for i in range(n)]
    # Une seule surface avec Solidify : meme epaisseur sur le dessus et le dessous.
    points=[];lignes=9
    for j in range(lignes):
        t=j/(lignes-1)
        for i in range(n):
            a=i*math.tau/n;x=math.cos(a)*(.355+.37*t);y=math.sin(a)*(.35+.31*t)
            z=altitude(x,y)+.024*t*t*math.cos(a*2+.3)
            points.append((x,y,z))
    bord=volume('Bord_violet',points,relier(lignes),violet)
    bpy.context.view_layer.objects.active=bord
    solid=bord.modifiers.new('Epaisseur_constante','SOLIDIFY');solid.thickness=.026;solid.offset=0;solid.use_even_offset=True
    bpy.ops.object.modifier_apply(modifier=solid.name)
    arrondi=bord.modifiers.new('Tranche_arrondie','BEVEL');arrondi.width=.008;arrondi.segments=3
    bpy.ops.object.modifier_apply(modifier=arrondi.name)
    # La calotte garde une pointe souple inclinee sur le cote.
    reperes=[(0,0,0,.405),(-.015,.015,.20,.34),(-.08,.025,.39,.255),
             (-.22,.025,.53,.165),(-.39,.015,.55,.092),(-.53,0,.48,.045),(-.58,0,.39,.003)]
    def courbe(t):
        p=t*(len(reperes)-1);k=min(len(reperes)-2,int(p));u=p-k
        a=Vector(reperes[max(0,k-1)]);b=Vector(reperes[k]);c=Vector(reperes[k+1]);d=Vector(reperes[min(len(reperes)-1,k+2)])
        return .5*((2*b)+(-a+c)*u+(2*a-5*b+4*c-d)*u*u+(-a+3*b-3*c+d)*u*u*u)
    points=[];lignes=65
    for j in range(lignes):
        t=j/(lignes-1);p=courbe(t)
        avant=courbe(max(0,t-.002));apres=courbe(min(1,t+.002))
        tangent=Vector(apres[:3])-Vector(avant[:3]);tangent.normalize()
        cote=Vector((0,1,0)).cross(tangent).normalized();profondeur=tangent.cross(cote).normalized()
        for i in range(n):
            a=i*math.tau/n;q=Vector(p[:3])+max(.002,p.w)*(math.cos(a)*cote+math.sin(a)*profondeur)
            points.append((q.x,q.y,altitude(q.x,q.y)+q.z+.008))
    faces=relier(lignes);faces.append(tuple(range((lignes-1)*n,lignes*n)))
    volume('Calotte_violette',points,faces,violet)
    # Ruban strictement au-dessus du bord : aucune partie ne suit la lamelle.
    points=[];lignes=7
    for j in range(lignes):
        h=.034+j*.105/(lignes-1);r=.405-.31*h+.009
        for i in range(n):
            a=i*math.tau/n;x=math.cos(a)*r-.075*h;y=math.sin(a)*r+.075*h
            points.append((x,y,altitude(x,y)+h))
    ruban=volume('Ruban_autour_calotte',points,relier(lignes),cuir)
    bpy.context.view_layer.objects.active=ruban
    solid=ruban.modifiers.new('Epaisseur_cuir','SOLIDIFY');solid.thickness=.008;solid.offset=1
    bpy.ops.object.modifier_apply(modifier=solid.name)
    # Boucle rigide posee sur le ruban, sans deformer son cercle par projection.
    h=.09;a=-math.pi/2+.20;r=.405-.31*h+.028
    centre=Vector((math.cos(a)*r-.075*h,math.sin(a)*r+.075*h,0))
    centre.z=altitude(centre.x,centre.y)+h
    centre=position_corrigee(centre)
    normale=Vector((math.cos(a),math.sin(a),.24)).normalized()
    rotation=Vector((0,0,1)).rotation_difference(normale)
    bpy.ops.mesh.primitive_torus_add(major_radius=.063,minor_radius=.012,major_segments=64,minor_segments=16,location=centre)
    boucle=bpy.context.object;boucle.name='Boucle_chapeau';boucle.rotation_mode='QUATERNION';boucle.rotation_quaternion=rotation
    boucle.data.materials.append(or_mat);morceaux.append(boucle)
    bpy.ops.object.select_all(action='DESELECT');objet.select_set(True)
    for morceau in morceaux:morceau.select_set(True)
    bpy.context.view_layer.objects.active=objet;bpy.ops.object.join()
    for face in objet.data.polygons:face.use_smooth=True
