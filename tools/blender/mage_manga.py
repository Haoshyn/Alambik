"""Mage de la reference validee : volumes articules, UV et textures peintes."""
import bpy, bmesh, math, sys, json
from pathlib import Path
from mathutils import Vector
sys.path.insert(0,str(Path(__file__).resolve().parent))
import build_all as b
SQUELETTE=None
ZONE='corps'

def hauteur(z):
    if z<=.12:return z
    if z<=.83:return .12+(z-.12)*.62
    if z<=1.315:return .5602+(z-.83)*.70
    if z<=1.84:return .8997+(z-1.315)*.95
    return 1.39845+(z-1.84)*.72

def proportion(point,zone='corps'):
    x,y,z=point
    x*=.94 if zone=='tete' else (.96 if zone=='chapeau' else 1.06)
    y*=1.08;z=hauteur(z)
    if zone=='tete':
        y*=.92;z=hauteur(1.315)+(z-hauteur(1.315))*.90
    elif zone=='chapeau':
        z-=(hauteur(1.84)-hauteur(1.315))*.10
    if zone in ('tete','chapeau'):
        pivot=hauteur(1.55);angle=math.radians(2)
        y,z=y*math.cos(angle)-(z-pivot)*math.sin(angle),pivot+y*math.sin(angle)+(z-pivot)*math.cos(angle)
    return Vector((x,y,z))

TUILES={'violet':(0,.5),'turquoise':(.5,.5),'cuir':(0,0),'cheveux':(.5,0)}

def maillage(nom,points,faces,mat,uv=None):
    m=bpy.data.meshes.new(nom);m.from_pydata(points,[],faces);m.update()
    o=bpy.data.objects.new(nom,m);bpy.context.collection.objects.link(o);b.finir(o,nom,mat)
    if uv:
        couche=m.uv_layers.new(name='UVMap')
        for boucle in m.loops:couche.data[boucle.index].uv=uv[boucle.vertex_index]
    bm=bmesh.new();bm.from_mesh(m)
    bmesh.ops.remove_doubles(bm,verts=list(bm.verts),dist=.00001)
    bm.to_mesh(m);bm.free();m.update()
    return o

def lier(o,os='racine',joint=None,subdivisions=0):
    bpy.ops.object.select_all(action='DESELECT');o.select_set(True);bpy.context.view_layer.objects.active=o
    bpy.ops.object.transform_apply(location=True,rotation=True,scale=True)
    if subdivisions:
        mod=o.modifiers.new('Surface','SUBSURF');mod.levels=subdivisions;bpy.ops.object.modifier_apply(modifier=mod.name)
    for f in o.data.polygons:f.use_smooth=True
    mat=o.data.materials[0].get('alambik_matiere',o.data.materials[0].name)
    if mat in TUILES:
        if not o.data.uv_layers:
            couche=o.data.uv_layers.new(name='UVMap')
            xs=[v.co.x for v in o.data.vertices];zs=[v.co.z for v in o.data.vertices]
            for l in o.data.loops:
                p=o.data.vertices[l.vertex_index].co
                couche.data[l.index].uv=((p.x-min(xs))/max(.01,max(xs)-min(xs)),(p.z-min(zs))/max(.01,max(zs)-min(zs)))
        tuile=TUILES[mat]
        for u in o.data.uv_layers.active.data:u.uv=(tuile[0]+.015+u.uv.x*.47,tuile[1]+.015+u.uv.y*.47)
    o.parent=SQUELETTE
    g=o.vertex_groups.new(name=os);j=o.vertex_groups.new(name=joint[0]) if joint else None
    for v in o.data.vertices:
        part=max(0.,min(1.,(joint[1]+joint[2]-v.co.z)/(2*joint[2]))) if joint else 0
        part=part*part*(3-2*part)
        if part<1:g.add([v.index],1-part,'REPLACE')
        if part>0:j.add([v.index],part,'REPLACE')
    for v in o.data.vertices:v.co=proportion(v.co,ZONE)
    mod=o.modifiers.new('Articulation','ARMATURE');mod.object=SQUELETTE
    return o

def volume(nom,pos,taille,mat,os='racine'):
    return lier(b.boule(nom,pos,taille,mat,24),os,subdivisions=1)

def tissu(nom,anneaux,mat,os='racine',joint=None,n=32):
    debut=list(anneaux[0]);fin=list(anneaux[-1])
    debut[2]+=.002 if anneaux[1][2]>debut[2] else -.002
    fin[2]-=.002 if fin[2]>anneaux[-2][2] else -.002
    anneaux=[anneaux[0],tuple(debut)]+anneaux[1:-1]+[tuple(fin),anneaux[-1]]
    points=[];uv=[];faces=[]
    for k,(x,y,z,rx,ry) in enumerate(anneaux):
        for i in range(n+1):
            a=math.tau*i/n+math.pi;points.append((x+rx*math.sin(a),y-ry*math.cos(a),z));uv.append((i/n,k/(len(anneaux)-1)))
    for j in range(len(anneaux)-1):
        for i in range(n):
            q=j*(n+1)+i;faces.append((q,q+1,q+n+2,q+n+1))
    faces.extend([tuple(reversed(range(n))),tuple(range((len(anneaux)-1)*(n+1),(len(anneaux)-1)*(n+1)+n))])
    return lier(maillage(nom,points,faces,mat,uv),os,joint,1)

def courbe(nom,points,rayon,mat,os='racine',joint=None):
    c=bpy.data.curves.new(nom,'CURVE');c.dimensions='3D';c.resolution_u=10;c.bevel_depth=rayon;c.bevel_resolution=3
    s=c.splines.new('BEZIER');s.bezier_points.add(len(points)-1)
    for p,co in zip(s.bezier_points,points):p.co=co;p.handle_left_type='AUTO';p.handle_right_type='AUTO'
    o=bpy.data.objects.new(nom,c);bpy.context.collection.objects.link(o)
    bpy.ops.object.select_all(action='DESELECT');o.select_set(True);bpy.context.view_layer.objects.active=o;bpy.ops.object.convert(target='MESH')
    return lier(b.finir(bpy.context.object,nom,mat),os,joint)

def lame(nom,controles,largeur,mat,os='racine',epaisseur=.015,normale=(0,-1,0)):
    # Une meche est un ruban bombe qui se termine en pointe, pas un tube.
    controles=[Vector(p) for p in controles];points=[];uv=[];faces=[]
    for i in range(17):
        t=i/16;p=(1-t)**3*controles[0]+3*(1-t)**2*t*controles[1]+3*(1-t)*t*t*controles[2]+t**3*controles[3]
        tangente=(3*(1-t)**2*(controles[1]-controles[0])+6*(1-t)*t*(controles[2]-controles[1])+3*t*t*(controles[3]-controles[2])).normalized()
        cote=tangente.cross(Vector(normale)).normalized()
        if cote.length<.1:cote=Vector((1,0,0))
        normal=cote.cross(tangente).normalized()
        rayon=largeur*(.65+.4*math.sin(t*math.pi))*(1-t)**.6+.0003
        for j in range(8):
            a=math.tau*j/8;points.append(p+cote*math.cos(a)*rayon+normal*math.sin(a)*epaisseur*(1-t))
            uv.append((.5+.5*math.cos(a),1-t))
    for i in range(16):
        for j in range(8):
            q=i*8+j;faces.append((q,i*8+(j+1)%8,(i+1)*8+(j+1)%8,q+8))
    return lier(maillage(nom,points,faces,mat,uv),os,subdivisions=1)

def preparer_matieres():
    dossier=b.SORTIE/'textures'/'mage'
    atlas=bpy.data.images.load(str(dossier/'matieres.png'),check_existing=True)
    for nom in TUILES:
        if nom=='cheveux':continue
        mat=b.MAT[nom];bsdf=mat.node_tree.nodes.get('Principled BSDF')
        tex=mat.node_tree.nodes.new('ShaderNodeTexImage');tex.image=atlas;tex.interpolation='Linear';tex.extension='EXTEND'
        mat.node_tree.links.new(tex.outputs['Color'],bsdf.inputs['Base Color']);bsdf.inputs['Roughness'].default_value=.88
    peau=(.50,.27,.15,1)
    b.MAT['peau'].node_tree.nodes.get('Principled BSDF').inputs['Base Color'].default_value=peau
    b.MAT['peau'].diffuse_color=peau
    blanc=b.MAT['peau'].copy();blanc.name='blanc_oeil';b.MAT['blanc_oeil']=blanc
    blanc.node_tree.nodes.get('Principled BSDF').inputs['Base Color'].default_value=(.65,.57,.42,1)
    for nom,col in [('cheveux',(.095,.034,.015,1)),('encre',(.025,.012,.038,1))]:
        bsdf=b.MAT[nom].node_tree.nodes.get('Principled BSDF')
        bsdf.inputs['Base Color'].default_value=col;bsdf.inputs['Roughness'].default_value=.95
    mat=b.MAT['peau'].copy();mat.name='visage';b.MAT['visage']=mat
    tex=mat.node_tree.nodes.new('ShaderNodeTexImage');tex.image=bpy.data.images.load(str(dossier/'visage.png'),check_existing=True);tex.extension='EXTEND'
    mat.node_tree.links.new(tex.outputs['Color'],mat.node_tree.nodes.get('Principled BSDF').inputs['Base Color'])
    for nom,col in [('cuivre',(.56,.32,.13,1)),('papier',(.53,.36,.62,1)),('magie',(.43,.09,.8,1))]:
        mat=b.MAT[nom];mat.diffuse_color=col;mat.node_tree.nodes.get('Principled BSDF').inputs['Base Color'].default_value=col

def visage():
    # Machoire courte, joues distinctes et plan facial aplati sous le bord du chapeau.
    anneaux=[(1.40,.070,.07),(1.425,.106,.095),(1.45,.140,.119),(1.49,.165,.138),(1.56,.181,.151),(1.66,.18,.151),(1.75,.157,.145),(1.80,.115,.10),(1.82,.04,.04)]
    points=[];uv=[];faces=[];n=64
    for z,rx,ry in anneaux:
        for i in range(n):
            a=math.tau*i/n+math.pi;x=rx*math.sin(a);c=math.cos(a)
            y=.012-ry*(math.copysign(abs(c)**.45,c))
            if c>0:y-=.020*math.exp(-(x/.027)**2-((z-1.52)/.042)**2)
            points.append((x,y,z));uv.append((max(.005,min(.995,.5+x/.45)),max(.005,min(.995,(z-1.35)/.45))))
    for j in range(len(anneaux)-1):
        for i in range(n):
            q=j*n+i;faces.append((q,j*n+(i+1)%n,(j+1)*n+(i+1)%n,q+n))
    o=maillage('Visage_sculpte',points,faces,'peau',uv)
    lier(o,subdivisions=1)
    for cote in [-1,1]:
        volume('Oreille',(cote*.172,.030,1.56),(.017,.024,.029),'peau')
        # Petits yeux en volume : aucune illustration etiree sur le crane.
        x=cote*.071
        volume('Oeil_sombre',(x,-.142,1.602),(.043,.008,.018),'encre')
        volume('Blanc_oeil',(x,-.149,1.602),(.036,.005,.013),'blanc_oeil')
        volume('Regard',(x,-.153,1.602),(.014,.004,.013),'papier')
        volume('Pupille',(x,-.157,1.602),(.007,.002,.010),'encre')
    courbe('Bouche',[(-.019,-.119,1.461),(0,-.122,1.458),(.019,-.119,1.461)],.002,'cuir')

def chapeau():
    points=[];uv=[];faces=[];n=64
    for j,r in enumerate([.22,.25,.34,.46,.474]):
        for i in range(n+1):
            a=math.tau*i/n+math.pi
            z=1.79+(r-.22)*(.10*math.sin(2*a)+.08*math.cos(3*a))-.035*max(0,math.cos(a))*(r/.474)
            points.append((r*math.sin(a),-.84*r*math.cos(a)*(1-.39*max(0,math.cos(a))**2),z));uv.append((i/n,j/4))
    for j in range(4):
        for i in range(n):q=j*(n+1)+i;faces.append((q,q+1,q+n+2,q+n+1))
    o=maillage('Bord_du_chapeau',points,faces,'violet',uv)
    bpy.ops.object.select_all(action='DESELECT');o.select_set(True);bpy.context.view_layer.objects.active=o
    mod=o.modifiers.new('Epaisseur','SOLIDIFY');mod.thickness=.016;bpy.ops.object.modifier_apply(modifier=mod.name);lier(o,subdivisions=1)
    tissu('Pointe_du_chapeau',[(0,0,1.835,.244,.209),(0,.006,1.89,.235,.206),(-.014,.012,2.015,.188,.164),
          (.018,.018,2.15,.142,.125),(.10,.02,2.245,.101,.090),(.23,.012,2.252,.062,.060),
          (.335,-.002,2.175,.045,.043),(.38,-.015,2.07,.020,.022),(.35,-.028,2.01,.002,.003)],'violet')
    tissu('Ruban_du_chapeau',[(0,0,1.855,.247,.214),(0,.004,1.885,.24,.211),(0,.008,1.936,.218,.197)],'turquoise')
    lier(b.anneau('Embleme',( .13,-.193,1.914),.054,.009,'cuivre',(math.pi/2,0,0)))
    courbe('Signe_alchimique',[(.117,-.206,1.945),(.117,-.211,1.91),(.098,-.212,1.885),(.148,-.212,1.885),(.135,-.211,1.91),(.135,-.206,1.945)],.005,'cuivre')

def cheveux():
    volume('Chevelure',(0,.065,1.70),(.180,.153,.135),'cheveux')
    # Quelques masses asymetriques remplacent les fines bandes repetees.
    for x,fin,largeur in [(-.10,-.145,.055),(.005,-.055,.065),(.10,.05,.057)]:
        lame('Frange',[(x+.055,-.035,1.80),(x+.07,-.12,1.77),(x,-.164,1.70),(fin,-.158,1.665)],largeur,'cheveux',epaisseur=.011)
    for cote in [-1,1]:
        lame('Tempe',[(cote*.14,.01,1.78),(cote*.196,-.025,1.72),(cote*.187,-.04,1.62),(cote*.169,-.026,1.565)],.042,'cheveux',epaisseur=.015,normale=(cote,0,0))
        lame('Nuque',[(cote*.07,.15,1.76),(cote*.11,.19,1.68),(cote*.13,.17,1.61),(cote*.115,.15,1.57)],.069,'cheveux',epaisseur=.015,normale=(0,1,0))

def manteau():
    tissu('Gilet',[(0,0,.78,.20,.161),(0,0,.89,.175,.146),(0,0,1.025,.17,.15),(0,0,1.19,.232,.181),(0,0,1.28,.227,.17),(0,0,1.315,.13,.12)],'violet')
    for cote in [-1,1]:
        courbe('Revers_veste',[(cote*.12,-.12,1.285),(cote*.075,-.184,1.18),(cote*.12,-.154,1.01),(cote*.14,-.15,.88)],.009,'cuivre')
        # Pans de manteau ouverts et asymetriques, ourlets en relief.
        points=[];uv=[];faces=[]
        for j in range(7):
            t=j/6;z=.85-t*.43
            for i in range(9):
                u=i/8;a=-.90+u*2.30;rx=.205+t*.13;ry=.16+t*.10
                points.append((cote*rx*math.cos(a),.015+ry*math.sin(a)+t*t*.04,z+.07*u));uv.append((u,1-t))
        for j in range(6):
            for i in range(8):q=j*9+i;faces.append((q,q+1,q+10,q+9))
        o=maillage('Pan_veste',points,faces,'violet',uv)
        bpy.ops.object.select_all(action='DESELECT');o.select_set(True);bpy.context.view_layer.objects.active=o
        mod=o.modifiers.new('Doublure','SOLIDIFY');mod.thickness=.012;bpy.ops.object.modifier_apply(modifier=mod.name)
        lier(o,'racine',('jambe_gauche' if cote<0 else 'jambe_droite',.64,.25),1)
        bord=[];bord_faces=[]
        indices=[j*9 for j in range(7)]+list(range(55,63))
        for k,indice in enumerate(indices):
            voisin=indice+1 if indice%9==0 else indice-9
            externe=Vector(points[indice]);interne=externe.lerp(Vector(points[voisin]),.16)
            decalage=Vector((externe.x,externe.y,0)).normalized()*.002
            bord.extend([externe+decalage,interne+decalage])
            if k:bord_faces.append((2*k-2,2*k-1,2*k+1,2*k))
        lier(maillage('Ourlet',bord,bord_faces,'cuivre'),'racine',('jambe_gauche' if cote<0 else 'jambe_droite',.64,.25),1)
    tissu('Ceinture',[(0,0,.837,.205,.175),(0,0,.85,.208,.178),(0,0,.908,.181,.157),(0,0,.92,.178,.151)],'cuir')
    lier(b.anneau('Boucle',(0,-.183,.873),.044,.011,'cuivre',(math.pi/2,0,0)))
    courbe('Sceau_boucle',[(-.027,-.195,.873),(0,-.199,.895),(.027,-.195,.873),(0,-.199,.851),(-.027,-.195,.873)],.005,'cuivre')
    lier(b.anneau('Fiole_ceinture',(-.17,-.16,.765),.052,.011,'cuivre',(math.pi/2,0,0)))
    volume('Verre_fiole',(-.17,-.164,.765),(.043,.025,.043),'cristal')

def echarpe():
    points=[];uv=[];faces=[];n=48
    for j in range(5):
        t=j/4
        for i in range(n+1):
            a=math.tau*i/n+math.pi;devant=max(0,math.cos(a));rx=.15+t*.095;ry=.177+t*.085
            points.append((rx*math.sin(a),-ry*math.cos(a),1.315-t*(.04+.145*devant)+.012*math.sin(a*3)))
            uv.append((i/n,t))
    for j in range(4):
        for i in range(n):q=j*(n+1)+i;faces.append((q,q+1,q+n+2,q+n+1))
    o=maillage('Foulard',points,[tuple(reversed(f)) for f in faces],'turquoise',uv)
    bpy.ops.object.select_all(action='DESELECT');o.select_set(True);bpy.context.view_layer.objects.active=o
    mod=o.modifiers.new('Epaisseur','SOLIDIFY');mod.thickness=.012;bpy.ops.object.modifier_apply(modifier=mod.name);lier(o,subdivisions=1)
    lame('Ruban_flottant',[(.13,.085,1.29),(.28,.32,1.15),(.29,.45,.98),(.34,.43,.82)],.075,'turquoise','echarpe',.009)
    volume('Embout_echarpe',(.335,.43,.86),(.036,.02,.025),'cuivre','echarpe')
    for i in range(4):courbe('Frange_echarpe',[(.315+i*.012,.429,.85),(.323+i*.012,.44,.78)],.004,'turquoise','echarpe')

def membres():
    for cote,nom in [(-1,'gauche'),(1,'droite')]:
        x=cote*.119;hanche='jambe_'+nom;tibia='tibia_'+nom;pied='pied_'+nom
        tissu('Pantalon',[(x,0,.22,.073,.082),(x,0,.35,.077,.088),(x,-.008,.47,.082,.093),(x,0,.63,.104,.12),(x,0,.81,.11,.123),(x,0,.87,.085,.097)],'cuir',hanche,(tibia,.46,.10))
        volume('Chaussure',(x,-.053,.105),(.10,.167,.096),'cuir',pied)
        volume('Semelle',(x,-.046,.040),(.103,.162,.025),'encre',pied)
        tissu('Botte',[(x,0,.14,.085,.093),(x,0,.20,.084,.09),(x,0,.34,.093,.100),(x,0,.375,.096,.106),(x,0,.385,.096,.106)],'cuir',tibia)
        courbe('Couture_botte',[(x,-.096,.35),(x,-.101,.20),(x,-.17,.09)],.004,'papier',tibia)
        lier(b.anneau('Sangle_botte',(x,0,.30),.096,.015,'cuivre'),tibia)
        courbe('Boucle_botte',[(x-.026,-.113,.30),(x,-.12,.326),(x+.026,-.113,.30),(x,-.12,.274),(x-.026,-.113,.30)],.006,'cuivre',tibia)
        bras='bras_'+('droit' if cote>0 else nom);avant='avant_'+bras
        tissu('Manche',[(cote*.37,-.035,.895,.092,.093),(cote*.37,-.027,.93,.098,.102),(cote*.325,-.008,1.055,.073,.080),(cote*.29,0,1.18,.078,.086),(cote*.235,0,1.25,.082,.085),(cote*.225,0,1.28,.070,.075)],'violet',bras,(avant,1.035,.09))
        tissu('Revers_manche',[(cote*.374,-.036,.88,.094,.10),(cote*.373,-.035,.892,.10,.105),(cote*.37,-.028,.935,.102,.107)],'papier',avant)
        lier(b.anneau('Bracelet',(cote*.38,-.04,.869),.071,.014,'cuivre'),avant)
        main='main_'+nom
        volume('Paume',(cote*.382,-.046,.829),(.063,.057,.070),'cuir',main)
        for i in range(4):
            fx=cote*(.341+i*.025)
            courbe('Doigt',[(fx,-.052,.821),(fx,-.079,.79),(fx,-.096,.805)],.014,'cuir',main)
        courbe('Pouce',[(cote*.331,-.058,.86),(cote*.318,-.092,.834),(cote*.338,-.10,.812)],.020,'cuir',main)

def baguette():
    os='main_droite';x=.407;y=-.099
    courbe('Baguette',[(x,y,.65),(x,y,.84),(x,y,1.08),(x,y,1.22)],.018,'bois',os)
    for z in [.76,.84,1.1,1.2]:lier(b.anneau('Bague_baguette',(x,y,z),.022,.007,'cuivre'),os)
    volume('Pommeau',(x,y,.65),(.025,.025,.028),'cuivre',os)
    for i in range(3):
        a=math.tau*i/3
        courbe('Sertissage',[(x,y,1.18),(x+.065*math.cos(a),y+.065*math.sin(a),1.235),(x+.049*math.cos(a),y+.049*math.sin(a),1.29)],.011,'cuivre',os)
    points=[(x,y,1.215)]
    for i in range(6):a=math.tau*i/6;points.append((x+.059*math.cos(a),y+.059*math.sin(a),1.305))
    points.append((x-.012,y,1.465));faces=[]
    for i in range(6):faces.extend([(0,(i+1)%6+1,i+1),(7,i+1,(i+1)%6+1)])
    o=lier(maillage('Cristal_baguette',points,faces,'magie'),os)
    for f in o.data.polygons:f.use_smooth=False
    courbe('Eclat_cristal',[(x-.045,y-.033,1.31),(x-.01,y-.005,1.445)],.003,'papier',os)

def construire(base=None):
    global b,SQUELETTE,ZONE
    if base is not None:b=base
    SQUELETTE=b.RIG;b.RIG=None
    preparer_matieres()
    ZONE='corps';membres();manteau();echarpe();baguette()
    ZONE='tete';visage();cheveux()
    ZONE='chapeau';chapeau()
    ZONE='corps' 
    b.RIG=SQUELETTE

def creer_squelette(rig):
    bpy.context.view_layer.objects.active=rig;rig.select_set(True);bpy.ops.object.mode_set(mode='EDIT')
    def os(nom,pos,parent=None):
        o=rig.data.edit_bones.new(nom);o.head=proportion(pos);o.tail=o.head+Vector((0,0,.10))
        if parent:o.parent=rig.data.edit_bones[parent]
    os('racine',(0,0,0))
    for cote,nom in [(-1,'gauche'),(1,'droite')]:
        os('jambe_'+nom,(cote*.119,0,.83),'racine')
        os('tibia_'+nom,(cote*.119,0,.46),'jambe_'+nom)
        os('pied_'+nom,(cote*.119,0,.10),'tibia_'+nom)
        bras='bras_'+('droit' if nom=='droite' else nom)
        os(bras,(cote*.225,0,1.245),'racine')
        os('avant_'+bras,(cote*.325,0,1.035),bras)
        os('main_'+nom,(cote*.382,-.046,.829),'avant_'+bras)
    os('echarpe',(.13,.085,1.29),'racine')
    bpy.ops.object.mode_set(mode='OBJECT')

def animer():
    rig=b.RIG
    cuisse=hauteur(.83)-hauteur(.46);tibia_longueur=hauteur(.46)-hauteur(.10)
    hanche_basse=hauteur(.83)-.022
    for nom,duree in [('repos',49),('course',25),('attaque',13),('touche',11),('mort',25),('victoire',41)]:
        action=bpy.data.actions.new(nom);rig.animation_data_create();rig.animation_data.action=action
        for f in range(1,duree+1):
            t=(f-1)/(duree-1);phase=t*math.tau
            for o in rig.pose.bones:o.rotation_mode='XYZ';o.rotation_euler=(0,0,0);o.location=(0,0,0);o.scale=(1,1,1)
            for cote,cote_nom in [(-1,'gauche'),(1,'droite')]:
                hanche=rig.pose.bones['jambe_'+cote_nom];tibia=rig.pose.bones['tibia_'+cote_nom];pied=rig.pose.bones['pied_'+cote_nom]
                nom_bras='bras_'+('droit' if cote_nom=='droite' else cote_nom)
                bras=rig.pose.bones[nom_bras];avant=rig.pose.bones['avant_'+nom_bras]
                if nom=='course':
                    p=phase+(math.pi if cote==1 else 0)
                    y=.13*math.cos(p);z=.10+.085*max(0,math.sin(p))
                    distance=math.sqrt(y*y+(hanche_basse-z)**2);distance=min(cuisse+tibia_longueur-.001,distance)
                    flexion=-math.acos(max(-1,min(1,(distance*distance-cuisse**2-tibia_longueur**2)/(2*cuisse*tibia_longueur))))
                    angle=math.atan2(y,hanche_basse-z)-math.atan2(tibia_longueur*math.sin(flexion),cuisse+tibia_longueur*math.cos(flexion))
                    hanche.rotation_euler.x=angle;tibia.rotation_euler.x=flexion;pied.rotation_euler.x=-angle-flexion
                    bras.rotation_euler.x=-math.cos(p)*.23
                    avant.rotation_euler.x=-.10-max(0,math.sin(p))*.16
                elif nom=='attaque' and cote==1:
                    geste=math.sin(math.pi*t)**.7
                    bras.rotation_euler.x=-.55*geste;avant.rotation_euler.x=-.70*geste
                    rig.pose.bones['main_droite'].rotation_euler.x=1.55*geste
                elif nom=='victoire':
                    bras.rotation_euler.y=cote*math.sin(math.pi*t)*1.2
            if nom=='course':rig.pose.bones['racine'].location.y=-.022
            if nom=='repos':rig.pose.bones['racine'].location.y=math.sin(phase)*.003
            if nom=='touche':rig.pose.bones['racine'].rotation_euler.x=-math.sin(math.pi*t)*.12
            if nom=='mort':rig.pose.bones['racine'].rotation_euler.x=t*1.45
            rig.pose.bones['echarpe'].rotation_euler.x=math.sin(phase)*(.09 if nom=='course' else .025)
            for o in rig.pose.bones:
                o.keyframe_insert(data_path='rotation_euler',frame=f);o.keyframe_insert(data_path='location',frame=f)
        piste=rig.animation_data.nla_tracks.new();piste.name=nom;piste.strips.new(nom,1,action);piste.mute=True
    rig.animation_data.action=None
    for o in rig.pose.bones:o.rotation_euler=(0,0,0);o.location=(0,0,0)

