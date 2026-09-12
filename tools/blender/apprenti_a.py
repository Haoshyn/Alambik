"""Apprenti A : geometrie originale, rig arcade et export reproductible."""
import bpy
import math
import json
import bmesh
from pathlib import Path
from mathutils import Vector

RACINE = Path(__file__).resolve().parents[2]
SORTIE = RACINE / 'assets/3d'
APERCU = RACINE / 'tmp/apprenti-a'
MAT = {}
RIG = None


def compacter(point):
    x,y,z=point
    if z < .36:
        h=z*.90
    elif z < .64:
        h=.324+(z-.36)*.45
    elif z < 1.30:
        h=.450+(z-.64)*.52
    else:
        h=.7932+(z-1.30)*1.04
    largeur=1.12
    return Vector((x*largeur,y*1.10,h))*.83


def matiere(nom, couleur, metal=0, rugosite=.65):
    m = bpy.data.materials.new(nom)
    m.diffuse_color = (*couleur, 1)
    m.use_nodes = True
    p = m.node_tree.nodes.get('Principled BSDF')
    p.inputs['Base Color'].default_value = (*couleur, 1)
    p.inputs['Metallic'].default_value = metal
    p.inputs['Roughness'].default_value = rugosite
    MAT[nom] = m


def finir(o, nom, mat, os):
    o.name = nom
    o.data.materials.append(MAT[mat])
    bpy.ops.object.select_all(action='DESELECT')
    o.select_set(True)
    bpy.context.view_layer.objects.active = o
    bpy.ops.object.transform_apply(location=True, rotation=True, scale=True)
    for p in o.data.polygons:
        p.use_smooth = True
    if os:
        o.parent = RIG
        g = o.vertex_groups.new(name=os)
        g.add(list(range(len(o.data.vertices))), 1, 'REPLACE')
        mod = o.modifiers.new('Articulation', 'ARMATURE')
        mod.object = RIG
    return o


def boule(nom, pos, taille, mat, os='torse'):
    bpy.ops.mesh.primitive_uv_sphere_add(segments=32, ring_count=20, location=pos)
    o = bpy.context.object
    o.scale = taille
    return finir(o, nom, mat, os)


def anneaux(nom, profils, mat, os='torse', n=48, vague=0):
    points, faces = [], []
    for x, y, z, rx, ry in profils:
        for i in range(n):
            a = math.tau*i/n
            points.append((x+rx*math.cos(a), y+ry*math.sin(a), z+vague*math.cos(a+.4)*rx))
    for j in range(len(profils)-1):
        for i in range(n):
            a = j*n+i
            b = j*n+(i+1)%n
            faces.append((a,b,b+n,a+n))
    faces += [tuple(reversed(range(n))), tuple(range((len(profils)-1)*n,len(profils)*n))]
    mesh = bpy.data.meshes.new(nom)
    mesh.from_pydata(points, [], faces)
    mesh.update()
    o = bpy.data.objects.new(nom, mesh)
    bpy.context.collection.objects.link(o)
    return finir(o, nom, mat, os)


def courbe(nom, points, rayon, mat, os='torse'):
    c = bpy.data.curves.new(nom, 'CURVE')
    c.dimensions = '3D'
    c.resolution_u = 12
    c.bevel_depth = rayon
    c.bevel_resolution = 3
    s = c.splines.new('BEZIER')
    s.bezier_points.add(len(points)-1)
    for p, co in zip(s.bezier_points, points):
        p.co = co
        p.handle_left_type = p.handle_right_type = 'AUTO'
    o = bpy.data.objects.new(nom, c)
    bpy.context.collection.objects.link(o)
    bpy.ops.object.select_all(action='DESELECT')
    o.select_set(True)
    bpy.context.view_layer.objects.active = o
    bpy.ops.object.convert(target='MESH')
    return finir(bpy.context.object, nom, mat, os)


def cercle(nom, pos, rayon, tube, mat, os='torse', echelle=(1,1,1), face=False):
    bpy.ops.mesh.primitive_torus_add(major_segments=48, minor_segments=10,
        location=pos, major_radius=rayon, minor_radius=tube,
        rotation=(math.pi/2,0,0) if face else (0,0,0))
    o = bpy.context.object
    o.scale = echelle
    return finir(o, nom, mat, os)


def boite_arrondie(nom, pos, dimensions, rayon, mat, os):
    bpy.ops.mesh.primitive_cube_add(size=1, location=pos)
    o=bpy.context.object;o.scale=dimensions
    finir(o,nom,mat,os)
    mod=o.modifiers.new('Angles_doux','BEVEL');mod.width=rayon;mod.segments=4
    bpy.ops.object.modifier_move_up(modifier=mod.name)
    bpy.ops.object.modifier_apply(modifier=mod.name)
    return o


def bras_souple(s,c):
    # Une surface continue et des poids progressifs remplacent les coques superposees.
    epaule=compacter((s*.30,0,1.12));coude=compacter((s*.42,-.02,.99));main=compacter((s*.48,-.11,.89))
    centres=[epaule,epaule.lerp(coude,.65),coude,coude.lerp(main,.45),coude.lerp(main,.78),main]
    rayons=[.056,.052,.047,.043,.039,.033]
    points=[];faces=[];n=16
    for j,(centre,rayon) in enumerate(zip(centres,rayons)):
        axe=(centres[min(j+1,len(centres)-1)]-centres[max(0,j-1)]).normalized()
        u=axe.cross(Vector((0,1,0))).normalized();v=axe.cross(u).normalized()
        for i in range(n):points.append(centre+rayon*(u*math.cos(i*math.tau/n)+v*math.sin(i*math.tau/n)))
    for j in range(len(centres)-1):
        for i in range(n):
            a=j*n+i;b=j*n+(i+1)%n;faces.append((a,b,b+n,a+n))
    faces += [tuple(reversed(range(n))),tuple(range((len(centres)-1)*n,len(centres)*n))]
    mesh=bpy.data.meshes.new('Manche_continue');mesh.from_pydata(points,[],faces);mesh.update()
    o=bpy.data.objects.new('Manche_continue_'+c,mesh);bpy.context.collection.objects.link(o)
    finir(o,'Manche_continue_'+c,'violet',None);o.parent=RIG;o['compacte']=True
    haut=o.vertex_groups.new(name='bras_'+c);bas=o.vertex_groups.new(name='avant_bras_'+c)
    for j,poids in enumerate([1.,.85,.5,.1,0.,0.]):
        indices=list(range(j*n,(j+1)*n))
        if poids:haut.add(indices,poids,'REPLACE')
        if poids<1:bas.add(indices,1-poids,'REPLACE')
    mod=o.modifiers.new('Articulation','ARMATURE');mod.object=RIG
    galber(o)


def moufle(s,c):
    os='main_'+c
    objets=[boite_arrondie('Paume', (s*.51,-.13,.89),(.09,.115,.13),.032,'peau',os)]
    for y in [-.10,-.14,-.18]:
        objets.append(courbe('Doigt_replie',[(s*.515,y,.941),(s*.459,y,.95),(s*.423,y,.912),(s*.437,y,.864),(s*.489,y,.854)],.018,'peau',os))
    objets.append(courbe('Pouce_replie',[(s*.51,-.076,.935),(s*.457,-.076,.960),(s*.43,-.128,.945)],.025,'peau',os))
    bpy.ops.object.select_all(action='DESELECT')
    for o in objets:o.select_set(True)
    bpy.context.view_layer.objects.active=objets[0];bpy.ops.object.join()
    o=objets[0]
    for mod in list(o.modifiers):o.modifiers.remove(mod)
    mod=o.modifiers.new('Main_continue','REMESH');mod.mode='VOXEL';mod.voxel_size=.005;mod.use_smooth_shade=True
    bpy.ops.object.modifier_apply(modifier=mod.name)
    mod=o.modifiers.new('Alleger_main','DECIMATE');mod.ratio=.45
    bpy.ops.object.modifier_apply(modifier=mod.name)
    mod=o.modifiers.new('Adoucir','SMOOTH');mod.factor=.65;mod.iterations=3
    bpy.ops.object.modifier_apply(modifier=mod.name)
    o.vertex_groups.clear();g=o.vertex_groups.new(name=os);g.add(list(range(len(o.data.vertices))),1,'REPLACE')
    mod=o.modifiers.new('Articulation','ARMATURE');mod.object=RIG
    o.name='Main_moufle_'+c
    o['pivot_main']=s


def meche(nom, points, largeur, mat='cheveux', os='tete'):
    profils=[]
    for i,p in enumerate(points):
        r=largeur*[.65,1,.72,.03][i]
        profils.append((*p,r,r*.46))
    o=anneaux(nom,profils,mat,os,n=20)
    bpy.context.view_layer.objects.active=o
    mod=o.modifiers.new('Galbe','SUBSURF');mod.levels=2
    bpy.ops.object.modifier_move_up(modifier=mod.name)
    bpy.ops.object.modifier_apply(modifier=mod.name)


def galber(o):
    bpy.context.view_layer.objects.active=o
    mod=o.modifiers.new('Galbe','SUBSURF');mod.levels=2
    bpy.ops.object.modifier_move_up(modifier=mod.name)
    bpy.ops.object.modifier_apply(modifier=mod.name)


def squelette():
    global RIG
    a=bpy.data.armatures.new('Squelette_apprenti')
    RIG=bpy.data.objects.new('Squelette',a)
    bpy.context.collection.objects.link(RIG)
    bpy.context.view_layer.objects.active=RIG;RIG.select_set(True)
    bpy.ops.object.mode_set(mode='EDIT')
    def os(nom,pos,parent=None):
        b=a.edit_bones.new(nom);b.head=pos;b.tail=Vector(pos)+Vector((0,0,.12))
        if parent:b.parent=a.edit_bones[parent]
    os('racine',(0,0,0));os('bassin',(0,0,.60),'racine')
    os('torse',(0,0,.72),'bassin');os('tete',(0,0,1.28),'torse')
    os('chapeau',(0,.06,2.02),'tete');os('echarpe',(-.24,.10,1.21),'torse')
    for s,c in [(-1,'gauche'),(1,'droite')]:
        os('cuisse_'+c,(s*.205,0,.64),'bassin')
        os('tibia_'+c,(s*.205,0,.40),'cuisse_'+c)
        os('pied_'+c,(s*.205,-.04,.17),'tibia_'+c)
        os('bras_'+c,(s*.29,0,1.12),'torse')
        os('avant_bras_'+c,(s*.42,-.02,.99),'bras_'+c)
        os('main_'+c,(s*.48,-.11,.89),'avant_bras_'+c)
    bpy.ops.object.mode_set(mode='OBJECT')


def construire():
    for nom,col,met,rug in [
        ('violet',(.20,.052,.31),0,.76),('violet_clair',(.31,.085,.40),0,.7),
        ('turquoise',(.025,.43,.48),0,.65),('turquoise_clair',(.055,.56,.58),0,.58),
        ('cuivre',(.63,.29,.12),.58,.3),('cuir',(.13,.063,.039),0,.75),
        ('semelle',(.066,.034,.026),0,.9),('peau',(.91,.53,.30),0,.8),
        ('joues',(.85,.30,.20),0,.85),('yeux',(.036,.020,.025),0,.5),
        ('cheveux',(.095,.044,.024),0,.75),('cheveux_clair',(.14,.064,.034),0,.68),
        ('potion',(.012,.48,.57),.2,.19),('orbe',(.36,.045,.62),.32,.19),
        ('reflet',(.73,.91,.88),.1,.22)]:
        matiere(nom,col,met,rug)
    squelette()
    avant_tete=set(bpy.context.scene.objects)
    # Tete large et joues basses : la silhouette reste lisible sans nez realiste.
    tete=boule('Visage',(0,-.018,1.66),(.475,.375,.435),'peau','tete')
    for v in tete.data.vertices:
        z=(v.co.z-1.66)/.435
        if z<-.25:
            v.co.z=1.66+.435*(-.25+(z+.25)*.77)
    boule('Chevelure_arriere',(0,.092,1.82),(.485,.326,.34),'cheveux','tete')
    for s in [-1,1]:
        boule('Oreille',(s*.448,-.014,1.54),(.081,.095,.112),'peau','tete')
        boule('Oeil',(s*.175,-.367,1.64),(.040,.016,.087),'yeux','tete')
        boule('Joue',(s*.292,-.325,1.515),(.049,.012,.027),'joues','tete')
        meche('Patte',[(s*.40,-.045,1.92),(s*.455,-.12,1.78),(s*.46,-.11,1.60),(s*.39,-.15,1.47)],.09)
    meche('Meche_centrale',[(-.17,-.28,2.01),(-.07,-.37,1.95),(.08,-.393,1.86),(.08,-.375,1.73)],.145)
    meche('Meche_balaye',[(-.23,-.22,2.01),(-.35,-.30,1.91),(-.40,-.28,1.77),(-.48,-.19,1.72)],.14)
    meche('Meche_droite',[(.15,-.28,2.02),(.32,-.30,1.97),(.38,-.25,1.88),(.47,-.20,1.86)],.13)
    # Toute la tete, visage et cheveux compris, gagne la profondeur manquante.
    for o in set(bpy.context.scene.objects)-avant_tete:
        for v in o.data.vertices:v.co.y=-.018+(v.co.y+.018)*(.475*1.12)/(.375*1.10)
    # Bord releve devant pour que les yeux restent visibles depuis la camera haute.
    profils=[]
    for r,z in [(.0,2.01),(.36,2.00),(.57,1.985),(.70,1.965),(.72,1.985),(.70,2.015),(.57,2.035),(.36,2.04)]:
        profils.append((0,.035,z,r,r*1.12/1.10))
    bord=anneaux('Bord_chapeau',profils,'violet','tete',n=64)
    galber(bord)
    galber(anneaux('Chapeau_souple',[(0,.06,2.01,.40,.34),(0,.07,2.07,.405,.34),(-.015,.095,2.22,.35,.29),(-.09,.11,2.40,.28,.235),(-.20,.10,2.55,.19,.17),(-.34,.08,2.57,.13,.12),(-.43,.04,2.48,.085,.075),(-.45,.00,2.39,.018,.018)],'violet','chapeau',n=32))
    anneaux('Ruban_chapeau',[(0,.07,2.075,.419,.356),(-.007,.077,2.09,.414,.352),(-.024,.09,2.18,.385,.328),(-.028,.094,2.20,.379,.323)],'cuir','chapeau')
    cercle('Boucle_chapeau',(.11,-.273,2.20),.080,.022,'cuivre','chapeau',face=True)
    boule('Fond_boucle_chapeau',(.11,-.259,2.20),(.068,.018,.068),'cuir','chapeau')
    boule('Cou',(0,0,1.30),(.13,.13,.12),'peau')
    # Le rapport compense la mise a l'echelle finale : section vraiment circulaire.
    galber(anneaux('Tunique',[(0,0,z,r,r*1.12/1.10) for z,r in [(.58,.25),(.61,.31),(.72,.35),(.94,.34),(1.10,.31),(1.20,.225)]],'violet_clair',n=24))
    courbe('Ouverture_tunique',[(0,-.30,.61),(0,-.337,.70),(0,-.344,.85)],.013,'violet')
    anneaux('Ceinture',[(0,0,z,r,r*1.12/1.10) for z,r in [(.79,.351),(.81,.355),(.875,.351),(.89,.35)]],'cuir')
    cercle('Boucle_ceinture',(.04,-.374,.842),.067,.017,'cuivre',face=True)
    courbe('Ardillon',[(.04,-.396,.842),(.103,-.396,.842)],.010,'cuivre')
    cercle('Echarpe_col',(0,0,1.247),.238,.085,'turquoise',echelle=(1.20,.9,.65))
    boule('Echarpe_plastron',(0,-.23,1.17),(.287,.10,.106),'turquoise')
    courbe('Pli_echarpe',[(-.24,-.26,1.20),(0,-.315,1.16),(.25,-.26,1.22)],.019,'turquoise_clair')
    meche('Pan_echarpe',[(-.25,.09,1.23),(-.38,.20,1.14),(-.49,.27,1.00),(-.51,.25,.91)],.10,'turquoise','echarpe')
    boule('Noeud_echarpe',(-.275,.08,1.22),(.10,.09,.09),'turquoise_clair')
    for s,c in [(-1,'gauche'),(1,'droite')]:
        cuisse='cuisse_'+c;tibia='tibia_'+c;pied='pied_'+c;bras='bras_'+c;avant='avant_bras_'+c;main='main_'+c
        boule('Pantalon',(s*.205,0,.49),(.111,.112,.18),'violet',cuisse)
        boule('Botte_tige',(s*.205,0,.285),(.137,.135,.15),'cuir',tibia)
        boule('Chaussure',(s*.205,-.081,.142),(.163,.234,.13),'cuir',pied)
        boule('Semelle',(s*.205,-.075,.06),(.17,.24,.041),'semelle',pied)
        cercle('Revers_botte',(s*.205,0,.356),.123,.025,'cuir',tibia,echelle=(1,1,.7))
        courbe('Couture_botte',[(s*.205-.11,-.19,.15),(s*.205,-.278,.20),(s*.205+.11,-.19,.15)],.006,'cuivre',pied)
        cercle('Boucle_botte',(s*.205,-.14,.29),.036,.010,'cuivre',tibia,face=True)
        bras_souple(s,c)
        moufle(s,c)
    # Le manche traverse la prise fermee et partage exactement le repere du poing.
    avant=set(bpy.context.scene.objects)
    main='main_droite'
    courbe('Baguette',[(0,0,-.13),(0,0,.30)],.026,'cuir',main)
    cercle('Sertissage',(0,0,.30),.075,.016,'cuivre',main)
    boule('Orbe',(0,0,.365),(.084,.084,.084),'orbe',main)
    for dx in [-1,1]:
        courbe('Griffe_orbe',[(0,0,.27),(dx*.074,0,.31),(dx*.077,0,.36)],.011,'cuivre',main)
    orientation=Vector((0,-1,0)).to_track_quat('Z','Y')
    for o in set(bpy.context.scene.objects)-avant:
        o['prise']=True
        for v in o.data.vertices:v.co=Vector((.48,-.15,.89))+orientation@v.co
    x=-.28;y=-.36
    boule('Fiole',(x,y,.70),(.117,.093,.128),'potion')
    cercle('Monture_fiole',(x,y,.69),.114,.014,'cuivre',echelle=(1,.79,1))
    anneaux('Goulot_fiole',[(x,y,.79,.045,.045),(x,y,.86,.045,.045),(x,y,.865,.049,.049)],'cuivre')
    anneaux('Bouchon_fiole',[(x,y,.858,.034,.034),(x,y,.906,.036,.036)],'cuir')
    courbe('Reflet_fiole',[(x-.065,y-.068,.74),(x-.073,y-.066,.69)],.008,'reflet')


def animer():
    scene=bpy.context.scene;scene.render.fps=60
    # Poses de sprint : contact, passage, poussee, talon ramene, genou lance.
    poses=[(0.,-.65,.35,.20),(.18,.05,.45,-.50),(.35,.78,.20,-.10),
           (.50,.60,1.80,-.40),(.72,-1.10,1.80,-.60),(1.,-.65,.35,.20)]
    def pose_course(cycle):
        for a,b in zip(poses,poses[1:]):
            if a[0]<=cycle<=b[0]:
                u=(cycle-a[0])/(b[0]-a[0]);u=u*u*(3-2*u)
                return tuple(a[i]+(b[i]-a[i])*u for i in range(1,4))
        return poses[0][1:]
    for nom,duree in [('repos',120),('course',24),('attaque',12),('touche',20),('mort',60),('victoire',90)]:
        action=bpy.data.actions.new(nom);RIG.animation_data_create();RIG.animation_data.action=action
        for f in range(duree+1):
            t=f/duree;p=t*math.tau
            for o in RIG.pose.bones:
                o.rotation_mode='XYZ';o.rotation_euler=(0,0,0);o.location=(0,0,0);o.scale=(1,1,1)
            rac=RIG.pose.bones['racine'];torse=RIG.pose.bones['torse'];tete=RIG.pose.bones['tete']
            if nom=='repos':
                torse.scale=(1+math.sin(p)*.008,1+math.sin(p)*.012,1+math.sin(p)*.008)
                tete.rotation_euler.x=math.sin(p)*.016
                RIG.pose.bones['bras_droite'].rotation_euler.x=0.0
            if nom=='course':
                rac.location.y=.012+.010*math.sin(p*2-.4)
                rac.location.x=.008*math.sin(p)
                torse.rotation_euler.x=.40+.025*math.sin(p*2)
                torse.rotation_euler.z=.065*math.sin(p)
                torse.rotation_euler.y=.11*math.sin(p)
                tete.rotation_euler.x=-.12
                tete.rotation_euler.z=-.025*math.sin(p-.35)
            for s,c in [(-1,'gauche'),(1,'droite')]:
                phase=p+(math.pi if s==1 else 0)
                if nom=='course':
                    cycle=(phase/math.tau)%1
                    angle,flexion,inclinaison=pose_course(cycle)
                    RIG.pose.bones['cuisse_'+c].rotation_euler.x=angle
                    RIG.pose.bones['tibia_'+c].rotation_euler.x=flexion
                    RIG.pose.bones['pied_'+c].rotation_euler.x=inclinaison
                    RIG.pose.bones['bras_'+c].rotation_euler.x=.95*math.cos(phase)
                    RIG.pose.bones['bras_'+c].rotation_euler.z=-s*.16
                    RIG.pose.bones['avant_bras_'+c].rotation_euler.x=-.70-.20*math.sin(phase)
                if nom=='victoire':
                    RIG.pose.bones['bras_'+c].rotation_euler.z=-s*.8*math.sin(math.pi*t)
            if nom=='attaque':
                # Le coude arme puis se deplie ; le poignet ramene le baton a plat au lancer.
                cles=[(0.,0.,0.,0.,0.,0.),(.10,.28,-.95,.22,.45,-.008),
                      (.25,-1.12,.18,.93,-.55,.012),(.45,-.92,.10,.81,-.30,.008),
                      (1.,0.,0.,0.,0.,0.)]
                for a,b in zip(cles,cles[1:]):
                    if a[0]<=t<=b[0]:
                        u=(t-a[0])/(b[0]-a[0]);u=u*u*(3-2*u)
                        bras,coude,poignet,ouverture,penche=[a[i]+(b[i]-a[i])*u for i in range(1,6)]
                        break
                RIG.pose.bones['bras_droite'].rotation_euler.x=bras
                RIG.pose.bones['bras_droite'].rotation_euler.y=ouverture
                RIG.pose.bones['bras_droite'].rotation_euler.z=-.32*math.sin(math.pi*t)
                RIG.pose.bones['avant_bras_droite'].rotation_euler.x=coude
                RIG.pose.bones['main_droite'].rotation_euler.x=poignet
                RIG.pose.bones['bras_gauche'].rotation_euler.x=.06*math.sin(math.pi*t)
                torse.rotation_euler.x=penche
                torse.rotation_euler.y=-ouverture*.04
                torse.rotation_euler.z=-.008*math.sin(math.pi*t)
                tete.rotation_euler.y=ouverture*.018
                tete.rotation_euler.x=-penche*.25
            if nom=='touche':
                choc=math.sin(math.pi*t)
                torse.rotation_euler.x=-.26*choc
                torse.rotation_euler.y=.15*choc
                tete.rotation_euler.x=.10*choc
                RIG.pose.bones['bras_gauche'].rotation_euler.z=.22*choc
                RIG.pose.bones['bras_droite'].rotation_euler.x=-.25*choc
            if nom=='mort':rac.rotation_euler.x=-1.48*(t*t*(3-2*t))
            RIG.pose.bones['echarpe'].rotation_euler.x=(.30+math.sin(p+.8)*.09) if nom=='course' else math.sin(p)*.035
            RIG.pose.bones['chapeau'].rotation_euler.x=(.06+math.sin(p-.9)*.025) if nom=='course' else math.sin(p)*.009
            for o in RIG.pose.bones:
                for prop in ['rotation_euler','location','scale']:o.keyframe_insert(data_path=prop,frame=f+1)
        piste=RIG.animation_data.nla_tracks.new();piste.name=nom;piste.strips.new(nom,1,action);piste.mute=True
    RIG.animation_data.action=None
    for o in RIG.pose.bones:o.rotation_euler=(0,0,0);o.location=(0,0,0);o.scale=(1,1,1)


def exporter():
    sections={}
    for o in [o for o in bpy.context.scene.objects if o.type=='MESH']:
        pivot=None
        if 'pivot_main' in o:
            pivot=Vector((o['pivot_main']*.48,-.15,.89))
        elif o.get('prise',False):
            pivot=Vector((.48,-.15,.89))
        elif o.name.startswith(('Fiole','Monture_fiole','Goulot_fiole','Bouchon_fiole','Reflet_fiole')):
            pivot=Vector((-.28,-.36,.75))
        elif o.name.startswith(('Main','Pouce','Boucle_ceinture','Ardillon')):
            pivot=sum((v.co for v in o.data.vertices),Vector())/len(o.data.vertices)
        if not o.get('compacte',False):
            for v in o.data.vertices:
                v.co=compacter(pivot)+(v.co-pivot)*.80 if pivot is not None else compacter(v.co)
        bm=bmesh.new();bm.from_mesh(o.data)
        bmesh.ops.recalc_face_normals(bm,faces=list(bm.faces));bm.to_mesh(o.data);bm.free()
        o.data.update()
        if o.name in ['Tunique','Bord_chapeau','Visage']:
            largeur=max(v.co.x for v in o.data.vertices)-min(v.co.x for v in o.data.vertices)
            profondeur=max(v.co.y for v in o.data.vertices)-min(v.co.y for v in o.data.vertices)
            sections[o.name]={'largeur':round(largeur,5),'profondeur':round(profondeur,5)}
            assert abs(largeur/profondeur-1)<.01, 'Section non circulaire : '+o.name
    # Fusion par matiere pour limiter les appels de dessin sur mobile.
    for m in MAT.values():
        objets=[o for o in bpy.context.scene.objects if o.type=='MESH' and o.data.materials[0]==m]
        if not objets:continue
        bpy.ops.object.select_all(action='DESELECT')
        for o in objets:o.select_set(True)
        bpy.context.view_layer.objects.active=objets[0]
        if len(objets)>1:bpy.ops.object.join()
        objets[0].name='Apprenti_'+m.name
        objets[0].data.validate(clean_customdata=True)
        for polygone in objets[0].data.polygons:polygone.use_smooth=True
    # Les os suivent les proportions, les petits accessoires gardent leur rondeur.
    bpy.context.view_layer.objects.active=RIG
    bpy.ops.object.select_all(action='DESELECT');RIG.select_set(True)
    bpy.ops.object.mode_set(mode='EDIT')
    for o in RIG.data.edit_bones:o.head=compacter(o.head);o.tail=compacter(o.tail)
    bpy.ops.object.mode_set(mode='OBJECT')
    animer()
    source=SORTIE/'sources/characters/apprenti_a.blend';source.parent.mkdir(parents=True,exist_ok=True)
    bpy.context.scene.frame_set(1)
    bpy.ops.wm.save_as_mainfile(filepath=str(source))
    glb=SORTIE/'characters/apprenti_a.glb'
    bpy.ops.export_scene.gltf(filepath=str(glb),export_format='GLB',export_yup=True,
        export_animations=True,export_animation_mode='NLA_TRACKS',export_nla_strips=True,
        export_force_sampling=True,export_cameras=False,export_lights=False)
    meshes=[o for o in bpy.context.scene.objects if o.type=='MESH']
    rapport={'triangles':sum(sum(len(p.vertices)-2 for p in o.data.polygons) for o in meshes),
        'surfaces':len(meshes),'os':len(RIG.data.bones),'octets':glb.stat().st_size,
        'animations':['repos','course','attaque','touche','mort','victoire'],'sections_vue_du_dessus':sections}
    (APERCU/'rapport.json').write_text(json.dumps(rapport,indent=2))
    print('APPRENTI_A',json.dumps(rapport))


def rendu():
    scene=bpy.context.scene
    scene.render.engine='CYCLES';scene.cycles.samples=48
    scene.cycles.use_denoising=True
    scene.render.resolution_x=1100;scene.render.resolution_y=1100;scene.render.resolution_percentage=100
    scene.world=bpy.data.worlds.new('Studio');scene.world.use_nodes=True
    scene.world.node_tree.nodes['Background'].inputs[0].default_value=(.65,.72,.80,1)
    scene.world.node_tree.nodes['Background'].inputs[1].default_value=.45
    matiere('studio',(.72,.65,.55),0,.9)
    bpy.ops.mesh.primitive_plane_add(size=200,location=(0,0,-.006))
    finir(bpy.context.object,'Sol','studio',None)
    for nom,pos,energie,taille,col in [('Cle',(-3,-4,6),450,4,(1,.83,.69)),('Remplissage',(4,-2,3),230,3,(.73,.87,1)),('Contour',(1,3,4),380,3,(1,.83,.62))]:
        d=bpy.data.lights.new(nom,'AREA');d.energy=energie;d.shape='DISK';d.size=taille;d.color=col
        o=bpy.data.objects.new(nom,d);scene.collection.objects.link(o);o.location=pos
        o.rotation_euler=(Vector((0,0,.9))-o.location).to_track_quat('-Z','Y').to_euler()
    d=bpy.data.cameras.new('Camera');o=bpy.data.objects.new('Camera',d);scene.collection.objects.link(o)
    o.location=(2.5,-5,2.7);o.rotation_euler=(Vector((0,0,.92))-o.location).to_track_quat('-Z','Y').to_euler()
    d.type='ORTHO';d.ortho_scale=2.25;scene.camera=o
    scene.view_settings.view_transform='AgX'
    scene.render.filepath=str(APERCU/'apprenti-blender.png');bpy.ops.render.render(write_still=True)


if __name__=='__main__':
    bpy.ops.wm.read_factory_settings(use_empty=True)
    bpy.context.preferences.filepaths.save_version=0
    APERCU.mkdir(parents=True,exist_ok=True)
    (APERCU/'.gdignore').touch()
    construire();exporter();rendu()
