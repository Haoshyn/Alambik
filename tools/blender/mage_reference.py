"""Mage de travail separe, sculpte d'apres direction.png ; aucun ancien export ecrase."""
import importlib.util
import math
import shutil
from pathlib import Path

import bpy
import numpy as np
from mathutils import Vector

RACINE = Path(__file__).resolve().parents[2]
DOSSIER = RACINE/'tmp/mage-reference'
SOURCE = RACINE/'assets/3d/sources/characters/mage_reference'
spec = importlib.util.spec_from_file_location('base_reference', Path(__file__).with_name('apprenti_accueil_v2.py'))
base = importlib.util.module_from_spec(spec)
spec.loader.exec_module(base)
socle = base.socle
atelier = base.atelier


def interpolation(points, t):
    segment = min(len(points)-2, int(t))
    u = t-segment
    a,b,c,d = [Vector(points[max(0,min(len(points)-1,i))]) for i in
               (segment-1,segment,segment+1,segment+2)]
    return .5*((2*b)+(-a+c)*u+(2*a-5*b+4*c-d)*u*u+(-a+3*b-3*c+d)*u*u*u)


def surface(nom, points, faces, matiere, os):
    objet = base.maillage(nom,points,faces,matiere,os)
    # Parametrage continu : les textures suivent chaque morceau de tissu.
    return objet


def chapeau():
    atelier.retirer(('Bord_chapeau','Chapeau_souple','Ruban_chapeau','Boucle_chapeau',
                     'Fond_boucle_chapeau','Ourlet_chapeau'))
    n = 80
    profil = [(.335,2.005),(.49,1.98),(.66,1.958),(.765,1.962),
              (.783,1.978),(.765,2.009),(.66,2.023),(.49,2.042),(.335,2.055)]
    points=[];faces=[]
    for r,z in profil:
        for i in range(n):
            a=math.tau*i/n
            # Bord qui retombe sur les cotes et se releve devant les yeux.
            hauteur = .066*math.sin(a+.2)*(r/.78)**2+.035*math.sin(2*a-.6)*(r/.78)**3
            points.append((r*math.cos(a),.035+r*.78*math.sin(a),z+hauteur))
    for j in range(len(profil)):
        for i in range(n):
            faces.append((j*n+i,j*n+(i+1)%n,((j+1)%len(profil))*n+(i+1)%n,((j+1)%len(profil))*n+i))
    socle.galber(surface('Bord_feutre',points,faces,'feutre','tete'))
    centres=[(0,.045,2.035),(-.015,.06,2.16),(-.075,.075,2.35),
             (-.19,.08,2.52),(-.35,.07,2.60),(-.50,.035,2.53),(-.57,.0,2.42)]
    rayons=[(.423,.33),(.389,.303),(.30,.238),(.214,.175),(.125,.107),(.062,.055),(.007,.008)]
    points=[];faces=[];anneaux=57
    for j in range(anneaux):
        t=j/(anneaux-1)*(len(centres)-1)
        centre=interpolation(centres,t)
        avant=interpolation(centres,max(0,t-.01));apres=interpolation(centres,min(6,t+.01))
        axe=(apres-avant).normalized()
        if t<1.0:
            axe=Vector((0,0,1))
        u=Vector((axe.z,0,-axe.x)).normalized();v=axe.cross(u).normalized()
        rayon=interpolation(rayons,t)
        for i in range(n):
            a=math.tau*i/n
            # Plis amortis dans le creux de la pointe, au lieu d'un cone facette.
            plis=1+.04*math.sin(5*a+t*.8)*math.exp(-((t-3.7)/1.25)**2)
            points.append(centre+u*math.cos(a)*rayon.x*plis+v*math.sin(a)*rayon.y*plis)
    for j in range(anneaux-1):
        for i in range(n):
            a=j*n+i;b=j*n+(i+1)%n;faces.append((a,b,b+n,a+n))
    faces.extend([tuple(reversed(range(n))),tuple(range((anneaux-1)*n,anneaux*n))])
    surface('Pointe_feutre',points,faces,'feutre','chapeau')
    socle.galber(socle.anneaux('Ruban_cuir',[(0,.045,2.06,.435,.345),
        (-.006,.052,2.08,.433,.343),(-.02,.058,2.20,.385,.31),(-.023,.06,2.215,.378,.305)],'cuir','chapeau',n=64))
    socle.cercle('Boucle_chapeau',(.11,-.283,2.177),.075,.021,'cuivre','chapeau',face=True)
    socle.boule('Fond_boucle_chapeau',(.11,-.276,2.177),(.064,.012,.064),'cuir','chapeau')


def visage():
    atelier.retirer(('Visage','Frange','Tempe','Chevelure','Sourcil','Contour_oeil','Blanc_oeil',
                     'Iris','Pupille','Reflet_grand','Reflet_petit','Oreille'))
    tete=socle.boule('Visage',(0,-.018,1.66),(.425,.405,.424),'peau','tete')
    for sommet in tete.data.vertices:
        z=(sommet.co.z-1.66)/.424
        if z<-.25: sommet.co.z=1.66+.424*(-.25+(z+.25)*.83)
    def peau(x,z,relief=.003):
        h=(z-1.66)/.424
        if h<-.25: h=-.25+(h+.25)/.83
        return -.018-.405*math.sqrt(max(.01,1-(x/.425)**2-h*h))-relief
    atelier.surface_visage=peau
    for s in [-1,1]:
        x=s*.157
        socle.boule('Oreille',(s*.408,-.016,1.54),(.066,.061,.083),'peau','tete')
        for nom,largeur,hauteur,matiere,relief in [
            ('Contour_oeil',.073,.103,'yeux',.005),('Blanc_oeil',.067,.097,'blanc_oeil',.009),
            ('Iris',.055,.088,'iris',.014),('Pupille',.034,.065,'yeux',.019)]:
            atelier.pastille(nom,x,1.652,largeur,hauteur,matiere,relief)
        atelier.pastille('Reflet_grand',x-.017,1.696,.015,.019,'reflet',.024)
        atelier.pastille('Reflet_petit',x+.021,1.605,.006,.008,'reflet',.024)
        socle.courbe('Sourcil',[(x-.05,peau(x-.05,1.80,.008),1.80),
            (x,peau(x,1.823,.008),1.823),(x+.05,peau(x+.05,1.806,.008),1.806)],.012,'cheveux','tete')
    socle.boule('Chevelure_arriere',(0,.082,1.745),(.435,.36,.28),'cheveux','tete')
    for nom,cles,largeur in [
        ('Meche_centrale',[(-.22,-.25,2.05),(-.13,-.355,1.995),(.018,-.427,1.92),(.075,-.405,1.802)],.122),
        ('Meche_gauche',[(-.25,-.20,2.035),(-.33,-.305,1.985),(-.37,-.325,1.89),(-.405,-.24,1.84)],.105),
        ('Meche_droite',[(.035,-.28,2.05),(.19,-.35,2.012),(.305,-.345,1.94),(.365,-.28,1.88)],.113),
        ('Tempe_gauche',[(-.365,-.09,1.94),(-.415,-.15,1.81),(-.412,-.175,1.68),(-.366,-.20,1.55)],.067),
        ('Tempe_droite',[(.365,-.09,1.94),(.415,-.15,1.81),(.412,-.175,1.68),(.366,-.20,1.55)],.067)]:
        points=[];faces=[];n=16;longueur=25
        for j in range(longueur):
            t=j/(longueur-1)
            c=interpolation(cles,t*3)
            rayon=largeur*(.76+.3*math.sin(math.pi*t))*(1-t**3)+.001
            for i in range(n):
                a=math.tau*i/n
                points.append((c.x+rayon*math.cos(a),c.y+rayon*.48*math.sin(a),c.z-.075))
        for j in range(longueur-1):
            for i in range(n):
                a=j*n+i;b=j*n+(i+1)%n;faces.append((a,b,b+n,a+n))
        faces.extend([tuple(reversed(range(n))),tuple(range((longueur-1)*n,longueur*n))])
        objet=surface(nom,points,faces,'cheveux','tete')
        uv=objet.data.uv_layers.new(name='Matiere')
        for face in objet.data.polygons:
            for boucle in face.loop_indices:
                indice=objet.data.loops[boucle].vertex_index
                uv.data[boucle].uv=(indice%n/(n-1),indice//n/(longueur-1))


def echarpe():
    atelier.retirer(('Echarpe','Noeud_echarpe','Pan_echarpe','Frange_echarpe'))
    profils=[(0,0,1.105,.205,.177),(0,-.013,1.13,.275,.224),
        (0,-.025,1.165,.29,.237),(0,-.026,1.194,.273,.215),
        (0,-.016,1.226,.285,.226),(0,0,1.262,.265,.21),(0,.014,1.30,.205,.17)]
    socle.galber(socle.anneaux('Echarpe_enroulee',profils,'turquoise','torse',n=64))
    socle.boule('Noeud_echarpe',(-.205,-.18,1.225),(.059,.047,.10),'turquoise','torse')
    bpy.context.view_layer.objects.active=socle.RIG
    bpy.ops.object.mode_set(mode='EDIT')
    for nom,point,parent in [('echarpe_milieu',(-.45,.17,1.09),'echarpe'),
                             ('echarpe_bout',(-.64,.18,.91),'echarpe_milieu')]:
        os=socle.RIG.data.edit_bones.new(nom);os.head=point
        os.tail=Vector(point)+Vector((0,0,.12));os.parent=socle.RIG.data.edit_bones[parent]
    bpy.ops.object.mode_set(mode='OBJECT')
    points=[];faces=[];longueur=25;n=12
    centres=[(-.23,.08,1.23),(-.36,.14,1.17),(-.53,.20,1.045),(-.71,.18,.91)]
    for j in range(longueur):
        t=j/(longueur-1);c=interpolation(centres,t*3)
        largeur=.065+.055*math.sin(t*math.pi*.7)
        for i in range(n):
            a=math.tau*i/n
            points.append((c.x,c.y+.016*math.sin(a)+.009*math.sin(t*math.tau),
                           c.z+largeur*math.cos(a)))
    for j in range(longueur-1):
        for i in range(n):
            a=j*n+i;b=j*n+(i+1)%n;faces.append((a,b,b+n,a+n))
    faces.extend([tuple(reversed(range(n))),tuple(range((longueur-1)*n,longueur*n))])
    objet=surface('Pan_echarpe_articule',points,faces,'turquoise','echarpe')
    objet.vertex_groups.clear()
    groupes=[objet.vertex_groups.new(name=nom) for nom in ('echarpe','echarpe_milieu','echarpe_bout')]
    for j in range(longueur):
        t=j/(longueur-1)*2;segment=min(1,int(t));fraction=t-segment
        fraction=fraction*fraction*(3-2*fraction)
        groupes[segment].add(list(range(j*n,(j+1)*n)),1-fraction,'REPLACE')
        groupes[segment+1].add(list(range(j*n,(j+1)*n)),fraction,'REPLACE')


def textures():
    rng=np.random.default_rng(19092026)
    n=512;y,x=np.mgrid[0:n,0:n].astype(np.float32)/n
    nuage=np.zeros((n,n),np.float32)
    for i in range(1,15):
        nuage+=np.sin(math.tau*(x*rng.integers(1,18)+y*rng.integers(1,18))+rng.random()*math.tau)/i
    nuage/=max(abs(nuage.min()),abs(nuage.max()))
    grain=rng.normal(0,.12,(n,n)).astype(np.float32)
    teintes={'feutre':(.48,.10,.76),'violet':(.40,.095,.64),'violet_clair':(.50,.14,.76),
             'pantalon':(.37,.085,.58),'turquoise':(.025,.56,.66),'turquoise_clair':(.05,.64,.72),
             'cuir':(.30,.145,.075),'cheveux':(.16,.066,.027),'cheveux_clair':(.20,.085,.037)}
    for nom,couleur in teintes.items():
        mat=socle.MAT[nom];nodes=mat.node_tree.nodes;liens=mat.node_tree.links
        shader=nodes.get('Principled BSDF')
        texture=nuage*.035+grain*.06
        if nom.startswith('cheveux'):
            texture=.055*np.sin(x*math.tau*42+.6*np.sin(y*math.tau*2))+.025*nuage
        elif nom=='cuir': texture=nuage*.06+grain*.12
        pixels=np.ones((n,n,4),np.float32)
        pixels[:,:,:3]=np.clip(np.array(couleur)[None,None,:]*(1+texture[:,:,None]),0,1)
        image=bpy.data.images.new('Matiere_'+nom,n,n,alpha=True)
        image.pixels.foreach_set(pixels.ravel());image.pack()
        noeud=nodes.new('ShaderNodeTexImage');noeud.image=image
        liens.new(noeud.outputs['Color'],shader.inputs['Base Color'])
        shader.inputs['Roughness'].default_value=.72 if nom=='cuir' else (.48 if nom.startswith('cheveux') else .88)
        # Un relief faible donne une matiere sous la lumiere, sans motif quadrille.
        normales=np.ones((n,n,4),np.float32)
        dy,dx=np.gradient(texture)
        normales[:,:,0]=.5-dx*.22;normales[:,:,1]=.5-dy*.22;normales[:,:,2]=1.
        normal=bpy.data.images.new('Relief_'+nom,n,n,alpha=True)
        normal.colorspace_settings.name='Non-Color';normal.pixels.foreach_set(normales.ravel());normal.pack()
        tex=nodes.new('ShaderNodeTexImage');tex.image=normal
        relief=nodes.new('ShaderNodeNormalMap');relief.inputs['Strength'].default_value=.35
        liens.new(tex.outputs['Color'],relief.inputs['Color']);liens.new(relief.outputs['Normal'],shader.inputs['Normal'])
    for objet in bpy.context.scene.objects:
        if objet.type!='MESH' or objet.data.uv_layers: continue
        bpy.ops.object.select_all(action='DESELECT');objet.select_set(True);bpy.context.view_layer.objects.active=objet
        bpy.ops.object.mode_set(mode='EDIT');bpy.ops.mesh.select_all(action='SELECT')
        bpy.ops.uv.smart_project(angle_limit=1.15,island_margin=.015)
        bpy.ops.object.mode_set(mode='OBJECT')
    for nom,teinte,metal,rugosite in [('cuivre',(.95,.57,.12),.72,.25),
        ('potion',(.015,.55,.69),.22,.12),('peau',(.95,.65,.47),0,.64),
        ('iris',(.23,.085,.025),0,.27),('yeux',(.022,.008,.007),0,.22),('blanc_oeil',(.98,.93,.84),0,.34)]:
        atelier.couleur(nom,teinte,rugosite)
        socle.MAT[nom].node_tree.nodes.get('Principled BSDF').inputs['Metallic'].default_value=metal


def accessoires():
    atelier.retirer(('Main_naturelle_gauche','Chaussure','Semelle'))
    # Doigts distincts en geometrie, paume ouverte vers l'avant en pose de repos.
    os='main_gauche'
    socle.boule('Paume_gauche',(-.577,-.145,.891),(.062,.043,.073),'peau',os)
    for j in range(4):
        x=-.626+j*.031
        longueur=[.066,.087,.092,.077][j]
        socle.courbe('Doigt_gauche',[(x,-.145,.862),(x+(j-1.5)*.004,-.153,.826),
            (x+(j-1.5)*.008,-.177,.862-longueur)],.014,'peau',os)
    socle.courbe('Pouce_gauche',[(-.527,-.145,.917),(-.503,-.18,.887),(-.507,-.194,.865)],.020,'peau',os)
    for signe,cote in [(-1,'gauche'),(1,'droite')]:
        socle.galber(socle.anneaux('Chaussure_taillee',[(signe*.205,y,z,rx,ry) for y,z,rx,ry in [
            (-.075,.065,.157,.221),(-.075,.084,.164,.228),(-.076,.13,.16,.222),
            (-.055,.19,.15,.197),(-.014,.245,.126,.147),(.0,.285,.111,.12)]],
            'cuir','pied_'+cote,n=48))
        socle.galber(socle.anneaux('Semelle_taillee',[(signe*.205,-.075,z,rx,ry) for z,rx,ry in [
            (.036,.151,.218),(.045,.167,.234),(.071,.167,.234),(.081,.155,.223)]],
            'semelle','pied_'+cote,n=48))
    socle.matiere('verre',(.24,.86,.94),.05,.13)
    verre=socle.MAT['verre']
    shader=verre.node_tree.nodes.get('Principled BSDF')
    shader.inputs['Alpha'].default_value=.24
    verre.surface_render_method='BLENDED'
    # Un liquide distinct sous la paroi evite de lire une boule de plastique.
    for objet in list(bpy.context.scene.objects):
        if objet.type!='MESH' or objet.name!='Fiole': continue
        liquide=objet.copy();liquide.data=objet.data.copy();bpy.context.collection.objects.link(liquide)
        liquide.name='Liquide_fiole'
        centre=sum((v.co for v in liquide.data.vertices),Vector())/len(liquide.data.vertices)
        for v in liquide.data.vertices:
            v.co=centre+(v.co-centre)*.87
            v.co.z=min(v.co.z,centre.z+.028)
        objet.data.materials.clear();objet.data.materials.append(verre)


def animer():
    animation_base()
    for piste in socle.RIG.animation_data.nla_tracks:
        action=piste.strips[0].action;socle.RIG.animation_data.action=action
        if action.slots: socle.RIG.animation_data.action_slot=action.slots[0]
        fin=round(action.frame_range.y)
        for frame in range(1,fin+1):
            phase=math.tau*(frame-1)/(fin-1)
            for i,nom in enumerate(('echarpe_milieu','echarpe_bout')):
                os=socle.RIG.pose.bones[nom]
                os.rotation_euler=(.10*math.sin(phase-.7-i*.6),.045*math.sin(phase-i*.4),
                                   .08*math.sin(phase-.9-i*.5)) if action.name=='course' else (
                                       .018*math.sin(phase-i*.5),0,.015*math.sin(phase-.8-i*.5))
                os.keyframe_insert('rotation_euler',frame=frame,group=nom)
    socle.RIG.animation_data.action=None
    for os in socle.RIG.pose.bones: os.rotation_euler=(0,0,0)


if __name__=='__main__':
    bpy.ops.wm.read_factory_settings(use_empty=True)
    bpy.context.preferences.filepaths.save_version=0
    DOSSIER.mkdir(parents=True,exist_ok=True);(DOSSIER/'.gdignore').touch()
    socle.SORTIE=DOSSIER/'export';socle.APERCU=DOSSIER
    (socle.SORTIE/'characters').mkdir(parents=True,exist_ok=True)
    base.sculpter()
    socle.matiere('feutre',(.48,.10,.76),0,.88)
    chapeau();visage();echarpe();accessoires();textures()
    animation_base=socle.animer;socle.animer=animer
    socle.exporter(sections_circulaires=False)
    shutil.copy2(socle.SORTIE/'characters/apprenti_a.glb',RACINE/'assets/3d/characters/mage_reference.glb')
    SOURCE.mkdir(parents=True,exist_ok=True)
    shutil.copy2(socle.SORTIE/'sources/characters/apprenti_a.blend',SOURCE/'mage_reference.blend')
    print('MAGE_REFERENCE : nouveau modele exporte ; anciens modeles non modifies.')
