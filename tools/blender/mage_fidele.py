"""Sculpture independante et textures reprojetees depuis la reference du proprietaire.

Blender --background --python tools/blender/mage_fidele.py
"""
import math
import struct
import zlib
from pathlib import Path

import bpy
import bmesh
import numpy as np
from mathutils import Vector

RACINE=Path(__file__).resolve().parents[2]
TRAVAIL=RACINE/'tmp/mage-fidele'
SOURCE=RACINE/'assets/3d/sources/characters/mage_fidele'
SORTIE=RACINE/'assets/3d/characters/mage_fidele.glb'
REFERENCE=np.frombuffer((TRAVAIL/'reference.rgba').read_bytes(),dtype=np.uint8).reshape(1672,941,4)/255.
ECHELLE=.80
TAILLE=512
OBJETS=[]
RIG=None
# Echantillons pris dans la matiere correspondante, pour completer le dos.
PALETTES={'feutre':(510,285),'tunique':(500,973),'pantalon':(537,1215),
          'echarpe':(530,884),'cheveux':(444,581),'peau':(527,762),
          'visage':(527,762),'cuir':(590,1398),'ceinture':(574,1062),
          'or':(489,1047),'semelle':(575,1486),'potion':(300,1200)}


def point(x,z,y=0.):
    return ((x-470.5)/500.,y,(1510.-z)/500.)


def png(chemin,pixels):
    donnees=np.uint8(np.clip(pixels,0,1)*255)
    h,w=donnees.shape[:2]
    brut=b''.join(b'\0'+ligne.tobytes() for ligne in donnees)
    def bloc(nom,contenu):
        return struct.pack('>I',len(contenu))+nom+contenu+struct.pack('>I',zlib.crc32(nom+contenu)&0xffffffff)
    chemin.write_bytes(b'\x89PNG\r\n\x1a\n'+bloc(b'IHDR',struct.pack('>IIBBBBB',w,h,8,6,0,0,0))+
                      bloc(b'IDAT',zlib.compress(brut,7))+bloc(b'IEND',b''))


def echantillon(x,y):
    x=np.clip(x,0,940);y=np.clip(y,0,1671)
    ix=x.astype(int);iy=y.astype(int);fx=(x-ix)[...,None];fy=(y-iy)[...,None]
    a=REFERENCE[iy,ix]*(1-fx)+REFERENCE[iy,np.minimum(ix+1,940)]*fx
    b=REFERENCE[np.minimum(iy+1,1671),ix]*(1-fx)+REFERENCE[np.minimum(iy+1,1671),np.minimum(ix+1,940)]*fx
    return a*(1-fy)+b*fy


def matiere_texture(nom,grille,genre,projection=True):
    # L'atlas est parametrise sur la surface, pas colle sur une carte devant le modele.
    hauteur,largeur=grille.shape[:2]
    v,u=np.mgrid[0:TAILLE,0:TAILLE].astype(float)/(TAILLE-1)
    gu=u*(largeur-1);gv=(1-v)*(hauteur-1)
    iu=np.minimum(gu.astype(int),largeur-2);iv=np.minimum(gv.astype(int),hauteur-2)
    fu=(gu-iu)[...,None];fv=(gv-iv)[...,None]
    p=(grille[iv,iu]*(1-fu)+grille[iv,iu+1]*fu)*(1-fv)+(grille[iv+1,iu]*(1-fu)+grille[iv+1,iu+1]*fu)*fv
    du=np.gradient(p,axis=1);dv=-np.gradient(p,axis=0)
    normale=np.cross(du,dv);normale/=np.maximum(np.linalg.norm(normale,axis=2,keepdims=True),1e-8)
    poids=np.clip((-normale[:,:,1]-.05)/.70,0,1)
    poids=poids*poids*(3-2*poids)
    couleur=echantillon(p[:,:,0]*500+470.5,1510-p[:,:,2]*500)
    x,y=PALETTES[genre]
    fond=echantillon(x+13*np.sin(u*math.tau*7)+9*np.sin(v*math.tau*3),
                     y+13*np.cos(v*math.tau*8)+7*np.sin(u*math.tau*5))
    r,g,b=couleur[:,:,0],couleur[:,:,1],couleur[:,:,2]
    valide=couleur[:,:,3]>.95
    if genre in ('feutre','tunique','pantalon'): valide &= (b>g*1.35)&(r>g*1.15)
    elif genre=='echarpe': valide &= (g>r*1.3)&(b>r*1.35)
    elif genre in ('cuir','ceinture','cheveux'): valide &= (r>g*1.08)&(g>b*.95)
    elif genre in ('peau',): valide &= (r>.5)&(r>g*1.05)
    elif genre=='or': valide &= (r>.5)&(g>.25)&(r>b*1.3)
    poids*=valide*float(projection)
    rgb=couleur[:,:,:3]*poids[:,:,None]+fond[:,:,:3]*(1-poids[:,:,None])
    rgba=np.ones((TAILLE,TAILLE,4));rgba[:,:,:3]=rgb
    fichier=SOURCE/'textures'/(nom+'.png');png(fichier,rgba)
    image=bpy.data.images.load(str(fichier));image.pack()
    mat=bpy.data.materials.new(nom);mat.use_nodes=True
    nodes=mat.node_tree.nodes;liens=mat.node_tree.links;shader=nodes.get('Principled BSDF')
    tex=nodes.new('ShaderNodeTexImage');tex.image=image
    liens.new(tex.outputs['Color'],shader.inputs['Base Color'])
    # La reference contient deja une lumiere peinte : conserver cette richesse sans la doubler.
    liens.new(tex.outputs['Color'],shader.inputs['Emission Color'])
    shader.inputs['Emission Strength'].default_value=.48 if genre in ('visage','peau') else .32
    shader.inputs['Roughness'].default_value={'or':.24,'potion':.15,'visage':.57,'peau':.62,'cheveux':.55}.get(genre,.80)
    shader.inputs['Metallic'].default_value=.48 if genre=='or' else 0.
    return mat


def surface(nom,fonction,genre,os,n=64,m=40,fermer=False,projection=True):
    u,v=np.meshgrid(np.linspace(0,1,n+1),np.linspace(0,1,m+1))
    grille=np.stack(fonction(u,v),axis=-1)
    faces=[]
    for j in range(m):
        for i in range(n):
            a=j*(n+1)+i;faces.append((a,a+1,a+n+2,a+n+1))
    if fermer:
        faces.extend([tuple(reversed(range(n+1))),tuple(range(m*(n+1),(m+1)*(n+1)))])
    data=bpy.data.meshes.new(nom);data.from_pydata(grille.reshape(-1,3).tolist(),[],faces);data.update()
    objet=bpy.data.objects.new(nom,data);bpy.context.collection.objects.link(objet)
    uv=data.uv_layers.new(name='Matiere')
    for face in data.polygons:
        face.use_smooth=True
        for boucle in face.loop_indices:
            indice=data.loops[boucle].vertex_index
            uv.data[boucle].uv=(indice%(n+1)/n,indice//(n+1)/m)
    data.materials.append(matiere_texture(nom,grille,genre,projection))
    objet.parent=RIG
    groupe=objet.vertex_groups.new(name=os);groupe.add(list(range(len(data.vertices))),1.,'REPLACE')
    mod=objet.modifiers.new('Articulation','ARMATURE');mod.object=RIG
    OBJETS.append(objet)
    return objet


def anneaux(nom,profils,genre,os,n=64,m=48,plis=0.):
    profils=np.array(profils,float)
    def forme(u,v):
        t=v*(len(profils)-1);a=(u-.5)*math.tau
        x,y,z,rx,ry=[np.interp(t,np.arange(len(profils)),profils[:,i]) for i in range(5)]
        variation=1+plis*np.sin(a*5+v*4)*np.sin(v*math.pi)
        return x+rx*np.sin(a)*variation,y-ry*np.cos(a)*variation,z
    return surface(nom,forme,genre,os,n,m,True)


def ellipsoide(nom,centre,rayons,genre,os,n=64,m=40):
    def forme(u,v):
        a=(u-.5)*math.tau;b=(v-.5)*math.pi
        return (centre[0]+rayons[0]*np.sin(a)*np.cos(b),
                centre[1]-rayons[1]*np.cos(a)*np.cos(b),centre[2]+rayons[2]*np.sin(b))
    return surface(nom,forme,genre,os,n,m)


def courbe(cles,t):
    cles=np.array(cles,float);s=np.minimum((t*(len(cles)-1)).astype(int),len(cles)-2)
    u=(t*(len(cles)-1)-s)[...,None]
    a,b,c,d=[cles[np.clip(s+k,0,len(cles)-1)] for k in (-1,0,1,2)]
    return .5*(2*b+(-a+c)*u+(2*a-5*b+4*c-d)*u*u+(-a+3*b-3*c+d)*u*u*u)


def meche(nom,cles,largeurs,genre='cheveux',os='tete',profondeur=.50):
    def forme(u,v):
        c=courbe(cles,v);r=np.interp(v,np.linspace(0,1,len(largeurs)),largeurs)
        a=(u-.5)*math.tau
        return c[:,:,0]+r*np.sin(a),c[:,:,1]-r*profondeur*np.cos(a),c[:,:,2]
    return surface(nom,forme,genre,os,32,48,True)


def squelette():
    global RIG
    data=bpy.data.armatures.new('Squelette_mage_fidele');RIG=bpy.data.objects.new('Squelette',data)
    bpy.context.collection.objects.link(RIG);bpy.context.view_layer.objects.active=RIG;RIG.select_set(True)
    bpy.ops.object.mode_set(mode='EDIT')
    def os(nom,p,parent=None):
        b=data.edit_bones.new(nom);b.head=p;b.tail=Vector(p)+Vector((0,0,.10))
        if parent: b.parent=data.edit_bones[parent]
    os('racine',(0,0,0));os('bassin',point(470,1125),'racine');os('torse',point(470,1010),'bassin')
    os('tete',point(470,840),'torse');os('chapeau',point(480,500),'tete')
    os('echarpe',point(353,890,.075),'torse');os('echarpe_milieu',point(260,979,.10),'echarpe')
    os('echarpe_bout',point(158,1044,.11),'echarpe_milieu')
    for signe,cote in [(-1,'gauche'),(1,'droite')]:
        os('cuisse_'+cote,point(470+signe*89,1136),'bassin')
        os('tibia_'+cote,point(470+signe*89,1284),'cuisse_'+cote)
        os('pied_'+cote,point(470+signe*89,1400,-.025),'tibia_'+cote)
        os('bras_'+cote,point(470+signe*176,901),'torse')
        os('avant_bras_'+cote,point(470+signe*266,904),'bras_'+cote)
        os('main_'+cote,point(470+signe*342,907),'avant_bras_'+cote)
    bpy.ops.object.mode_set(mode='OBJECT')


def tete():
    profils=[]
    for py,rx,ry in [(826,25,.065),(821,93,.17),(807,137,.235),(783,169,.29),(748,185,.325),
                      (705,186,.337),(661,181,.326),(617,162,.30),(574,129,.225),(548,65,.12),(540,4,.01)]:
        x,y,z=point(483,py)
        profils.append((x,y,z,rx/500,ry))
    anneaux('Visage_peint',profils,'visage','tete',96,80)
    for px in (262,700):
        ellipsoide('Oreille_'+str(px),point(px,730,.015),(.075,.053,.083),'peau','tete',40,32)
    ellipsoide('Chevelure_arriere',point(477,670,.09),(.422,.306,.274),'cheveux','tete')
    for nom,coords,rayons in [
        ('Frange_centrale',[(380,544,-.20),(442,564,-.315),(490,606,-.348),(507,655,-.305)],[.083,.13,.095,.002]),
        ('Frange_gauche',[(330,548,-.16),(316,584,-.28),(276,625,-.272),(222,639,-.17)],[.08,.10,.078,.001]),
        ('Frange_droite',[(499,539,-.18),(568,564,-.30),(613,599,-.30),(656,626,-.22)],[.085,.12,.085,.002]),
        ('Meche_exterieure',[(590,549,-.06),(644,564,-.19),(691,580,-.19),(730,565,-.105)],[.066,.085,.064,.002]),
        ('Tempe_gauche',[(296,605,-.18),(284,671,-.22),(302,735,-.225),(326,788,-.13)],[.045,.052,.035,.001]),
        ('Tempe_droite',[(654,604,-.14),(676,671,-.20),(657,743,-.23),(623,792,-.12)],[.046,.051,.033,.001])]:
        meche(nom,[point(x,z,y) for x,z,y in coords],rayons,profondeur=.43)


def chapeau():
    # Chaque section suit la courbure de la pointe au lieu d'empiler des cones.
    cles=[point(505,519,.05),point(510,437,.06),point(457,312,.06),
          point(362,237,.05),point(260,251,.025),point(189,290,0),point(146,339,-.02)]
    rayons=[(.428,.317),(.405,.30),(.334,.26),(.225,.19),(.112,.105),(.048,.045),(.002,.002)]
    def forme(u,v):
        c=courbe(cles,v);avant=courbe(cles,np.maximum(0,v-.001));apres=courbe(cles,np.minimum(1,v+.001))
        axe=apres-avant;axe/=np.maximum(np.linalg.norm(axe,axis=2,keepdims=True),1e-8)
        lateral=np.stack([axe[:,:,2],np.zeros_like(u),-axe[:,:,0]],axis=-1)
        lateral/=np.maximum(np.linalg.norm(lateral,axis=2,keepdims=True),1e-8)
        a=(u-.5)*math.tau
        rx=np.interp(v,np.linspace(0,1,7),[r[0] for r in rayons]);ry=np.interp(v,np.linspace(0,1,7),[r[1] for r in rayons])
        plis=1+.055*np.sin(a*5+v*4)*np.exp(-((v-.65)/.16)**2)
        p=c+lateral*(np.sin(a)*rx*plis)[:,:,None]
        p[:,:,1]-=np.cos(a)*ry*plis
        return p[:,:,0],p[:,:,1],p[:,:,2]
    surface('Chapeau_feutre',forme,'feutre','chapeau',96,80,True)
    # Bord en selle : ellipse large, descend derriere et laisse le visage degage.
    def bord(u,v):
        a=(u-.5)*math.tau
        r=.34+.52*np.sin(v*math.pi)
        x=.01+r*np.sin(a);y=.065-r*.65*np.cos(a)
        z=1.882+.125*np.cos(a)+.072*np.sin(a)+.024*np.cos(2*a)+.014*np.cos(v*math.pi)
        return x,y,z
    surface('Bord_chapeau',bord,'feutre','tete',112,24)
    profils=[]
    for py,rx,ry in [(522,.437,.332),(516,.441,.335),(438,.400,.295),(429,.394,.288)]:
        x,y,z=point(506,py,.055);profils.append((x,y,z,rx,ry))
    anneaux('Ruban_chapeau',profils,'ceinture','chapeau',80,32)
    boucle('Boucle_chapeau',point(540,444,-.263),.083,.020,'chapeau')


def boucle(nom,centre,rayon,tube,os):
    def forme(u,v):
        a=(u-.5)*math.tau;b=v*math.tau
        return (centre[0]+(rayon+tube*np.cos(b))*np.sin(a),
                centre[1]-tube*np.sin(b),centre[2]+(rayon+tube*np.cos(b))*np.cos(a))
    surface(nom,forme,'or',os,64,18)


def corps():
    profils=[]
    for py,rx,ry in [(1165,.315,.173),(1153,.37,.206),(1113,.348,.204),
                     (1050,.29,.168),(981,.287,.171),(913,.325,.19),(867,.30,.165),(847,.23,.13)]:
        x,y,z=point(474,py);profils.append((x,y,z,rx,ry))
    objet=anneaux('Tunique_cousue',profils,'tunique','torse',80,70,.018)
    # L'ourlet accompagne les cuisses, sans modifier la partie ceinture.
    objet.vertex_groups.clear()
    groupes={nom:objet.vertex_groups.new(name=nom) for nom in ('torse','cuisse_gauche','cuisse_droite')}
    for v in objet.data.vertices:
        poids=.32*max(0,min(1,(.90-v.co.z)/.23))
        groupes['torse'].add([v.index],1-poids,'REPLACE')
        groupes['cuisse_gauche' if v.co.x<0 else 'cuisse_droite'].add([v.index],poids,'REPLACE')
    anneaux('Ceinture_cuir',[(.008,0,z,rx,ry) for z,rx,ry in [(.826,.302,.184),(.84,.307,.19),(.939,.299,.185),(.951,.293,.181)]],
            'ceinture','bassin',80,24)
    boucle('Boucle_ceinture',point(479,1080,-.195),.073,.020,'bassin')
    for s,cote in [(-1,'gauche'),(1,'droite')]:
        px=470+s*89
        anneaux('Pantalon_'+cote,[(point(px,py)[0],0,point(px,py)[2],rx,ry) for py,rx,ry in [
            (1296,.125,.123),(1280,.128,.13),(1192,.142,.149),(1130,.148,.157)]],
            'pantalon','cuisse_'+cote,48,40,.026)
        anneaux('Botte_'+cote,[(point(px,py)[0],y,point(px,py)[2],rx,ry) for py,y,rx,ry in [
            (1499,-.07,.191,.229),(1482,-.075,.2,.241),(1449,-.079,.196,.239),
            (1409,-.051,.18,.212),(1370,-.018,.146,.15),(1305,0,.138,.139)]],
            'cuir','pied_'+cote,64,48)
        anneaux('Revers_botte_'+cote,[(point(px,py)[0],0,point(px,py)[2],rx,ry) for py,rx,ry in [
            (1362,.139,.142),(1336,.147,.151),(1300,.165,.16),(1288,.168,.162),(1282,.148,.145)]],
            'cuir','tibia_'+cote,64,32)
        anneaux('Semelle_'+cote,[(point(px,py)[0],-.073,point(px,py)[2],rx,ry) for py,rx,ry in [
            (1508,.19,.232),(1501,.209,.248),(1482,.210,.247),(1477,.195,.234)]],
            'semelle','pied_'+cote,64,20)
        boucle('Boucle_botte_'+cote,point(px,1342,-.155),.046,.012,'tibia_'+cote)
        bras(s,cote)


def bras(s,cote):
    def manche(u,v):
        a=(u-.5)*math.tau;x=s*(.286+v*.383)
        rayon=.070+.018*np.sin(v*math.pi)+.008*np.cos(v*math.tau*2)
        z=1.211-.015*v
        return x,-rayon*np.cos(a),z+rayon*np.sin(a)
    objet=surface('Manche_'+cote,manche,'tunique','bras_'+cote,48,48,True)
    objet.vertex_groups.clear();haut=objet.vertex_groups.new(name='bras_'+cote);bas=objet.vertex_groups.new(name='avant_bras_'+cote)
    for sommet in objet.data.vertices:
        t=max(0,min(1,(abs(sommet.co.x)-.48)/.13));t=t*t*(3-2*t)
        haut.add([sommet.index],1-t,'REPLACE');bas.add([sommet.index],t,'REPLACE')
    def revers(u,v):
        a=(u-.5)*math.tau;r=.078+.012*np.sin(v*math.pi)
        return s*(.64+v*.054),-r*np.cos(a),1.197+r*np.sin(a)
    surface('Poignet_cuir_'+cote,revers,'cuir','avant_bras_'+cote,48,18,True)
    ellipsoide('Paume_'+cote,(s*.74,-.002,1.20),(.073,.032,.04),'peau','main_'+cote,40,24)
    # La pose de construction suit l'image ; les clips abaissent ensuite les bras.
    for j in range(4):
        y=-.023+j*.015
        ellipsoide('Doigt_'+cote+str(j),(s*(.816-(abs(j-1.3)*.006)),y,1.215),(.071,.010,.014),'peau','main_'+cote,28,16)
    ellipsoide('Pouce_'+cote,(s*.77,-.029,1.165),(.036,.017,.016),'peau','main_'+cote,28,16)


def echarpe():
    profils=[]
    for py,rx,ry in [(919,.21,.154),(909,.26,.206),(889,.285,.231),(873,.277,.23),
                     (858,.268,.217),(836,.253,.207),(817,.221,.172),(811,.179,.139)]:
        x,y,z=point(477,py,-.004);profils.append((x,y,z,rx,ry))
    anneaux('Echarpe_enroulee',profils,'echarpe','torse',80,48,.025)
    meche('Noeud_echarpe',[point(398,836,-.19),point(399,859,-.22),point(395,896,-.225),point(414,913,-.185)],
          [.034,.043,.039,.018],'echarpe','torse',.68)
    cles=[point(350,882,.03),point(302,946,.095),point(224,1008,.12),point(125,1051,.13)]
    def pan(u,v):
        c=courbe(cles,v);a=(u-.5)*math.tau
        rayon=.073+.033*np.sin(v*math.pi*.8)
        return c[:,:,0]+.021*np.sin(a),c[:,:,1]-.023*np.cos(a),c[:,:,2]+rayon*np.sin(a)
    objet=surface('Echarpe_pan',pan,'echarpe','echarpe',32,64,True)
    objet.vertex_groups.clear();groupes=[objet.vertex_groups.new(name=n) for n in ('echarpe','echarpe_milieu','echarpe_bout')]
    for sommet in objet.data.vertices:
        v=sommet.index//33/64;t=v*2;k=min(1,int(t));poids=t-k;poids=poids*poids*(3-2*poids)
        groupes[k].add([sommet.index],1-poids,'REPLACE');groupes[k+1].add([sommet.index],poids,'REPLACE')


def fiole():
    centre=point(302,1191,-.235)
    ellipsoide('Potion',centre,(.117,.084,.113),'potion','bassin',64,48)
    anneaux('Col_fiole',[(centre[0],centre[1],z,rx,ry) for z,rx,ry in [(.692,.037,.031),(.801,.034,.03),(.81,.039,.034)]],
            'or','bassin',40,20)
    anneaux('Bouchon',[(centre[0],centre[1],z,.031,.028) for z in [.795,.843]],'cuir','bassin',32,16)
    def monture(u,v):
        a=(u-.5)*math.tau;b=v*math.tau
        return centre[0]+(.119+.009*np.cos(b))*np.sin(a),centre[1]-(.087+.009*np.cos(b))*np.cos(a),centre[2]+.009*np.sin(b)
    surface('Monture_fiole',monture,'or','bassin',64,12)
    meche('Attache_fiole',[point(318,1048,-.125),point(316,1081,-.195),point(306,1110,-.232),point(304,1142,-.235)],
          [.023,.022,.024,.022],'ceinture','bassin',.40)


def animer():
    scene=bpy.context.scene;scene.render.fps=60
    for nom,duree in [('repos',2.4),('course',.60),('attaque',.32),('touche',.3),('mort',.9),('victoire',1.6)]:
        action=bpy.data.actions.new(nom);RIG.animation_data_create();RIG.animation_data.action=action
        frames=round(duree*60)
        for f in range(frames+1):
            t=f/frames;p=t*math.tau
            for os in RIG.pose.bones:
                os.rotation_mode='XYZ';os.rotation_euler=(0,0,0);os.location=(0,0,0)
            for s,c in [(-1,'gauche'),(1,'droite')]:
                RIG.pose.bones['bras_'+c].rotation_euler.z=-s*1.03
                RIG.pose.bones['avant_bras_'+c].rotation_euler.y=-s*.12
            RIG.pose.bones['torse'].rotation_euler.x=.009*math.sin(p)
            if nom=='course':
                RIG.pose.bones['bassin'].location.y=.010+.013*math.sin(2*p-.4)
                RIG.pose.bones['torse'].rotation_euler=(.16,.07*math.sin(p),.025*math.cos(p))
                RIG.pose.bones['tete'].rotation_euler.x=-.07
                for s,c in [(-1,'gauche'),(1,'droite')]:
                    q=p+(math.pi if s>0 else 0)
                    RIG.pose.bones['cuisse_'+c].rotation_euler.x=.62*math.cos(q)-.13
                    RIG.pose.bones['tibia_'+c].rotation_euler.x=.32+.72*((1+math.sin(q-.6))*.5)**2
                    RIG.pose.bones['pied_'+c].rotation_euler.x=-.2-.24*math.sin(q)
                    RIG.pose.bones['bras_'+c].rotation_euler.y=-s*.39*math.cos(q)
                    RIG.pose.bones['avant_bras_'+c].rotation_euler.y=-s*(.28+.08*math.sin(q))
            elif nom=='attaque':
                secondes=t*duree
                geste=math.sin(min(1,secondes/.05)*math.pi*.5)*(1-max(0,(secondes-.08)/.24)**2)
                RIG.pose.bones['bras_droite'].rotation_euler.y=-1.0*geste
                RIG.pose.bones['bras_droite'].rotation_euler.z=-1.03+.40*geste
                RIG.pose.bones['avant_bras_droite'].rotation_euler.y=-.12-.30*geste
                RIG.pose.bones['torse'].rotation_euler.y=-.13*geste
            elif nom=='touche': RIG.pose.bones['torse'].rotation_euler.x=-.22*math.sin(math.pi*t)
            elif nom=='mort': RIG.pose.bones['racine'].rotation_euler.x=-1.48*t*t*(3-2*t)
            elif nom=='victoire':
                for s,c in [(-1,'gauche'),(1,'droite')]: RIG.pose.bones['bras_'+c].rotation_euler.z=-s*(1.03-2*math.sin(math.pi*t))
            for i,n in enumerate(('echarpe','echarpe_milieu','echarpe_bout')):
                amplitude=.11 if nom=='course' else .024
                RIG.pose.bones[n].rotation_euler=(amplitude*math.sin(p-.5-i*.6),.035*math.sin(p-i*.4),.05*math.sin(p-.7-i*.5))
            RIG.pose.bones['chapeau'].rotation_euler.x=.025*math.sin(p-.7)
            for os in RIG.pose.bones:
                os.keyframe_insert('rotation_euler',frame=f+1,group=os.name);os.keyframe_insert('location',frame=f+1,group=os.name)
        piste=RIG.animation_data.nla_tracks.new();piste.name=nom;piste.strips.new(nom,1,action);piste.mute=True
    RIG.animation_data.action=None
    for os in RIG.pose.bones: os.rotation_euler=(0,0,0);os.location=(0,0,0)


def exporter():
    for objet in OBJETS:
        for v in objet.data.vertices:v.co*=ECHELLE
        bm=bmesh.new();bm.from_mesh(objet.data)
        bmesh.ops.recalc_face_normals(bm,faces=list(bm.faces));bm.to_mesh(objet.data);bm.free();objet.data.update()
    bpy.context.view_layer.objects.active=RIG;bpy.ops.object.mode_set(mode='EDIT')
    for os in RIG.data.edit_bones:os.head*=ECHELLE;os.tail*=ECHELLE
    bpy.ops.object.mode_set(mode='OBJECT')
    animer()
    bpy.context.scene.frame_set(1)
    bpy.ops.wm.save_as_mainfile(filepath=str(SOURCE/'mage_fidele.blend'))
    bpy.ops.export_scene.gltf(filepath=str(SORTIE),export_format='GLB',export_animations=True,
        export_animation_mode='NLA_TRACKS',export_nla_strips=True,export_force_sampling=True,
        export_cameras=False,export_lights=False)
    print('MAGE_FIDELE',len(OBJETS),'surfaces',len(RIG.data.bones),'os',SORTIE.stat().st_size,'octets')


if __name__=='__main__':
    bpy.ops.wm.read_factory_settings(use_empty=True);bpy.context.preferences.filepaths.save_version=0
    SOURCE.mkdir(parents=True,exist_ok=True);(SOURCE/'textures').mkdir(exist_ok=True)
    squelette();tete();chapeau();corps();echarpe();fiole();exporter()
