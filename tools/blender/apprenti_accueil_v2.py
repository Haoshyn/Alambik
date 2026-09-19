"""Silhouette articulee et finition de l'apprenti ; variantes precedentes intactes."""
import importlib.util
import math
import shutil
import sys
from pathlib import Path

import bpy
from mathutils import Vector

RACINE = Path(__file__).resolve().parents[2]
DOSSIER = RACINE/'tmp/apprenti-accueil-v2'
spec = importlib.util.spec_from_file_location('atelier',Path(__file__).with_name('apprenti_accueil.py'))
atelier = importlib.util.module_from_spec(spec)
spec.loader.exec_module(atelier)
socle = atelier.socle


def proportions(point):
    x,y,z = point
    # Davantage de jambe et de buste sous la tete : les bras peuvent se plier
    # sans coincer les poignets entre les joues et la ceinture.
    if z < .36:
        hauteur = z*.90
    elif z < .64:
        hauteur = .324+(z-.36)*.95
    elif z < 1.30:
        hauteur = .590+(z-.64)*.88
    else:
        hauteur = 1.1708+(z-1.30)
    return Vector((x*1.12,y*1.10,hauteur))*.85


def maillage(nom, points, faces, matiere, os):
    donnees=bpy.data.meshes.new(nom)
    donnees.from_pydata(points,[],faces)
    donnees.update()
    objet=bpy.data.objects.new(nom,donnees)
    bpy.context.collection.objects.link(objet)
    socle.finir(objet,nom,matiere,os)
    return objet


def manche(signe, cote):
    centres=[Vector((signe*.29,0,1.145)),Vector((signe*.35,-.005,1.12)),
             Vector((signe*.415,-.025,1.07)),Vector((signe*.47,-.055,1.015)),
             Vector((signe*.515,-.085,.969)),Vector((signe*.551,-.11,.936))]
    rayons=[.093,.101,.098,.089,.085,.077]
    points,faces=[],[]
    n=24
    for j,(centre,rayon) in enumerate(zip(centres,rayons)):
        axe=(centres[min(j+1,5)]-centres[max(j-1,0)]).normalized()
        u=axe.cross(Vector((0,1,0))).normalized()
        v=axe.cross(u)
        for i in range(n):
            angle=math.tau*i/n
            # Un pli doux a l'interieur du coude donne une manche de tissu.
            pli=1+.045*math.cos(angle*3+j*.6)
            points.append(proportions(centre+rayon*pli*(u*math.cos(angle)+v*math.sin(angle))))
    for j in range(5):
        for i in range(n):
            a=j*n+i;b=j*n+(i+1)%n
            faces.append((a,b,b+n,a+n))
    faces.extend([tuple(reversed(range(n))),tuple(range(5*n,6*n))])
    objet=maillage('Manche_taillee_'+cote,points,faces,'violet_clair',None)
    objet.parent=socle.RIG
    objet['compacte']=True
    haut=objet.vertex_groups.new(name='bras_'+cote)
    bas=objet.vertex_groups.new(name='avant_bras_'+cote)
    for j,poids in enumerate([1,.95,.70,.25,.04,0]):
        indices=list(range(j*n,(j+1)*n))
        if poids: haut.add(indices,poids,'REPLACE')
        if poids<1: bas.add(indices,1-poids,'REPLACE')
    mod=objet.modifiers.new('Articulation','ARMATURE');mod.object=socle.RIG
    socle.galber(objet)
    poignet=centres[-1]
    axe=(centres[-1]-centres[-2]).normalized()
    u=axe.cross(Vector((0,1,0))).normalized();v=axe.cross(u)
    points=[];faces=[]
    for pas,rayon in [(-.025,.080),(-.019,.085),(.018,.082),(.023,.076)]:
        for i in range(n):
            angle=math.tau*i/n
            points.append(proportions(poignet+axe*pas+rayon*(u*math.cos(angle)+v*math.sin(angle))))
    for j in range(3):
        for i in range(n):
            a=j*n+i;b=j*n+(i+1)%n;faces.append((a,b,b+n,a+n))
    objet=maillage('Poignet_tissu_'+cote,points,faces,'violet','avant_bras_'+cote)
    objet['compacte']=True


def main(signe, cote):
    pivot=Vector((signe*.572,-.13,.91))
    os='main_'+cote
    objets=[socle.boule('Paume_souple',pivot,(.071,.068,.081),'peau',os)]
    if cote=='droite':
        # Doigts autour du manche, mais dos de main plein et jointures souples.
        for j in range(4):
            y=-.083-j*.033
            objets.append(socle.courbe('Doigt_prise',[(.591,y,.966),(.536,y,.967),(.512,y,.926),(.531,y,.879),(.579,y,.873)],.022,'peau',os))
        objets.append(socle.courbe('Pouce_prise',[(.623,-.07,.94),(.573,-.085,.987),(.532,-.129,.959)],.028,'peau',os))
    else:
        # La main libre est entrouverte ; elle ne garde plus le trou de prise
        # de la baguette alors qu'elle ne tient aucun objet.
        for j in range(4):
            x=-.634+j*.039
            bout=.805+abs(j-1.5)*.020
            objets.append(socle.courbe('Doigt_libre',[(x,-.151,.908),(x+(j-1.5)*.004,-.17,.857),(x+(j-1.5)*.007,-.18,bout)],.015,'peau',os))
        objets.append(socle.courbe('Pouce_libre',[(-.518,-.112,.952),(-.486,-.157,.917),(-.49,-.185,.882)],.022,'peau',os))
    bpy.ops.object.select_all(action='DESELECT')
    for objet in objets: objet.select_set(True)
    bpy.context.view_layer.objects.active=objets[0]
    bpy.ops.object.join()
    objet=objets[0]
    for mod in list(objet.modifiers): objet.modifiers.remove(mod)
    mod=objet.modifiers.new('Peau_continue','REMESH');mod.mode='VOXEL';mod.voxel_size=.004;mod.use_smooth_shade=True
    bpy.ops.object.modifier_apply(modifier=mod.name)
    mod=objet.modifiers.new('Lisser_jointures','SMOOTH');mod.factor=.4;mod.iterations=2
    bpy.ops.object.modifier_apply(modifier=mod.name)
    mod=objet.modifiers.new('Alleger','DECIMATE');mod.ratio=.38
    bpy.ops.object.modifier_apply(modifier=mod.name)
    objet.vertex_groups.clear()
    groupe=objet.vertex_groups.new(name=os);groupe.add(list(range(len(objet.data.vertices))),1,'REPLACE')
    for sommet in objet.data.vertices:
        sommet.co=proportions(pivot)+(sommet.co-pivot)*.90

    # Le dos de la main s'amincit dans le poignet : aucune peau ne traverse
    # le revers quand l'avant-bras tourne pendant le lancer.
    poignet=proportions((signe*.551,-.11,.936))
    axe=(proportions(pivot)-poignet).normalized()
    for sommet in objet.data.vertices:
        distance=(sommet.co-poignet).dot(axe)
        if distance < .032:
            radial=sommet.co-poignet-axe*distance
            limite=.046+.023*max(0,min(1,(distance+.01)/.042))
            if radial.length > limite:
                sommet.co=poignet+axe*distance+radial.normalized()*limite
    objet['compacte']=True
    objet.name='Main_naturelle_'+cote
    mod=objet.modifiers.new('Articulation','ARMATURE');mod.object=socle.RIG


def sculpter():
    socle.compacter=proportions
    atelier.sculpter()
    atelier.retirer(('Manche_continue','Main_moufle','Tunique','Ceinture','Ouverture_tunique',
                     'Contour_oeil','Blanc_oeil','Iris','Pupille','Reflet_grand','Reflet_petit',
                     'Nez','Sourire','Oreille','Frange_centrale','Frange_droite','Frange_gauche',
                     'Tempe_','Pantalon','Attache_fiole'))
    atelier.couleur('peau',(.92,.56,.40),.84)
    atelier.couleur('violet',(.26,.06,.45),.88)
    atelier.couleur('violet_clair',(.36,.10,.54),.9)
    atelier.couleur('iris',(.17,.067,.028),.5)
    atelier.couleur('blanc_oeil',(.96,.92,.85),.65)
    socle.matiere('iris_miel',(.37,.16,.063),0,.65)
    for signe in [-1,1]:
        x=signe*.173
        atelier.pastille('Contour_oeil',x,1.648,.076,.107,'cheveux',.004)
        atelier.pastille('Blanc_oeil',x,1.646,.071,.101,'blanc_oeil',.007)
        atelier.pastille('Iris',x+.006,1.646,.068,.098,'iris',.010)
        atelier.pastille('Iris_miel',x+.006,1.608,.047,.048,'iris_miel',.012)
        atelier.pastille('Pupille',x+.007,1.663,.038,.063,'yeux',.014)
        atelier.pastille('Reflet_grand',x-.012,1.691,.014,.020,'reflet',.017)
        atelier.pastille('Reflet_petit',x+.027,1.614,.006,.008,'reflet',.017)
    profils=[(0,0,z,largeur,profondeur) for z,largeur,profondeur in [
        (.565,.29,.205),(.585,.315,.22),(.635,.32,.223),(.75,.29,.205),
        (.84,.263,.184),(.96,.285,.20),(1.10,.31,.215),(1.18,.275,.19),(1.205,.235,.175)]]
    objet=socle.anneaux('Tunique',profils,'violet_clair',n=48)
    for sommet in objet.data.vertices:
        x,y,z=sommet.co
        angle=math.atan2(y,x)
        if z<.76:
            sommet.co.z+=.032*math.exp(-((angle+math.pi/2)/.24)**2)*((.76-z)/.20)
    socle.galber(objet)
    # Le bas de la veste accompagne legerement la cuisse levee ; un ourlet
    # fige dans le torse laissait le genou traverser le tissu pendant la course.
    torse=objet.vertex_groups.get('torse')
    gauche=objet.vertex_groups.new(name='cuisse_gauche')
    droite=objet.vertex_groups.new(name='cuisse_droite')
    for sommet in objet.data.vertices:
        poids=.38*max(0,min(1,(.76-sommet.co.z)/.19))
        if poids:
            torse.add([sommet.index],1-poids,'REPLACE')
            (gauche if sommet.co.x < 0 else droite).add([sommet.index],poids,'REPLACE')
    socle.anneaux('Ceinture',[(0,0,z,r,p) for z,r,p in [
        (.80,.28,.20),(.815,.282,.201),(.876,.279,.199),(.891,.277,.197)]],'cuir')
    for objet in bpy.context.scene.objects:
        if objet.type!='MESH': continue
        if objet.name.startswith(('Boucle_ceinture','Ardillon')):
            for sommet in objet.data.vertices: sommet.co.y+=.165
        if objet.get('prise',False):
            origine=Vector((.48,-.15,.89));destination=Vector((.572,-.15,.91))
            for sommet in objet.data.vertices: sommet.co=proportions(destination)+(sommet.co-origine)*.85
            objet['compacte']=True
    # Une couture de revers et deux plis larges suffisent a lire du tissu.
    for signe in [-1,1]:
        socle.courbe('Pli_tunique',[(signe*.22,-.164,.63),(signe*.185,-.17,.71),(signe*.16,-.174,.775)],.005,'violet','torse')
    finitions_organiques()
    for signe,cote in [(-1,'gauche'),(1,'droite')]:
        manche(signe,cote)
        main(signe,cote)
    bpy.context.view_layer.objects.active=socle.RIG
    bpy.ops.object.mode_set(mode='EDIT')
    for signe,cote in [(-1,'gauche'),(1,'droite')]:
        for nom,position in [('bras',(signe*.29,0,1.145)),('avant_bras',(signe*.455,-.045,1.035)),('main',(signe*.572,-.13,.91))]:
            os=socle.RIG.data.edit_bones[nom+'_'+cote]
            os.head=position;os.tail=Vector(position)+Vector((0,0,.12))
    bpy.ops.object.mode_set(mode='OBJECT')


def finitions_organiques():
    # Des meches en rubans bombes suivent le crane au lieu d'anneaux gonfles.
    for nom,centres,largeur in [
        ('Frange_centrale',[(-.26,-.30,2.04),(-.15,-.415,1.98),(.015,-.477,1.90),(.095,-.453,1.82)],.12),
        ('Frange_droite',[(.01,-.32,2.065),(.17,-.40,2.015),(.31,-.365,1.95),(.38,-.29,1.87)],.10),
        ('Frange_gauche',[(-.29,-.22,2.035),(-.375,-.31,1.96),(-.415,-.30,1.84),(-.39,-.28,1.76)],.085),
        ('Tempe_gauche',[(-.40,-.04,1.93),(-.44,-.12,1.81),(-.425,-.20,1.68),(-.38,-.22,1.60)],.06),
        ('Tempe_droite',[(.40,-.04,1.93),(.44,-.12,1.81),(.425,-.20,1.68),(.38,-.22,1.60)],.06)]:
        points=[];faces=[]
        for j,(x,y,z) in enumerate(centres):
            rayon=largeur*[.85,1.,.65,.035][j]
            for cote in range(8):
                a=math.tau*cote/8
                points.append((x+rayon*math.cos(a),y+rayon*.20*math.sin(a),z))
        for j in range(3):
            for i in range(8):
                a=j*8+i;b=j*8+(i+1)%8
                faces.append((a,b,b+8,a+8))
        faces.extend([tuple(reversed(range(8))),tuple(range(24,32))])
        objet=maillage(nom,points,faces,'cheveux','tete')
        socle.galber(objet)
    for signe in [-1,1]:
        socle.boule('Oreille_discrete',(signe*.445,-.008,1.565),(.046,.058,.066),'peau','tete')
    for objet in bpy.context.scene.objects:
        if objet.type!='MESH': continue
        if objet.name.startswith(('Visage','Chevelure','Oreille','Frange','Tempe','Sourcil',
                                 'Contour_oeil','Blanc_oeil','Iris','Pupille','Reflet_grand','Reflet_petit')):
            for sommet in objet.data.vertices:
                sommet.co.x*=.84
                sommet.co.y=-.018+(sommet.co.y+.018)*.94
                sommet.co.z=1.66+(sommet.co.z-1.66)*1.035
        if objet.name.startswith('Chevelure_arriere'):
            for sommet in objet.data.vertices:
                sommet.co.y=.09+(sommet.co.y-.09)*.90
        if objet.name.startswith(('Fiole','Monture_fiole','Goulot_fiole','Bouchon_fiole','Reflet_fiole')):
            origine=Vector((-.28,-.36,.75));destination=Vector((-.22,-.24,.75))
            for sommet in objet.data.vertices:
                sommet.co=proportions(destination)+(sommet.co-origine)*.72
            objet['compacte']=True
            objet.vertex_groups.clear()
            groupe=objet.vertex_groups.new(name='bassin')
            groupe.add(list(range(len(objet.data.vertices))),1.,'REPLACE')
    socle.courbe('Attache_fiole',[(-.22,-.125,.875),(-.22,-.215,.85),(-.22,-.24,.80)],.021,'cuir','bassin')
    # Le haut du pantalon rentre sous la tunique ; les jambes sont taillees, non spheriques.
    socle.matiere('pantalon',(.245,.075,.355),0,.94)
    for signe,cote in [(-1,'gauche'),(1,'droite')]:
        objet=socle.anneaux('Pantalon_taille',[(signe*.205,0,z,rx,ry) for z,rx,ry in [
            (.335,.095,.098),(.36,.104,.11),(.47,.115,.123),(.58,.13,.135),(.66,.134,.139)]],
            'pantalon','cuisse_'+cote,n=32)
        socle.galber(objet)
    atelier.couleur('cheveux',(.10,.045,.028),.96)
    atelier.couleur('cheveux_clair',(.13,.06,.038),.95)
    # Un liseret fin et des irregularites larges font lire du feutre, sans bruit.
    for objet in bpy.context.scene.objects:
        if objet.type!='MESH' or not objet.name.startswith(('Chapeau_souple','Bord_chapeau')): continue
        for sommet in objet.data.vertices:
            x,y,z=sommet.co
            angle=math.atan2(y-.065,x)
            facteur=.008*math.sin(angle*5+z*7)+.004*math.sin(angle*9-z*4)
            sommet.co.x+=x*facteur
            sommet.co.y+=(y-.065)*facteur
    points=[]
    for i in range(97):
        a=math.tau*i/96
        x=.701*math.cos(a);y=.035+.701*1.12/1.10*math.sin(a)
        z=2.037+.022*math.cos(a+.4)*(.701/.725)**2+.115*x-.06*(y-.035)
        points.append((x,y,z))
    socle.courbe('Ourlet_chapeau',points,.006,'violet_clair','tete')


if __name__=='__main__':
    bpy.ops.wm.read_factory_settings(use_empty=True)
    bpy.context.preferences.filepaths.save_version=0
    DOSSIER.mkdir(parents=True,exist_ok=True)
    (DOSSIER/'.gdignore').touch()
    socle.SORTIE=DOSSIER/'export'
    socle.APERCU=DOSSIER
    atelier.DOSSIER=DOSSIER
    (socle.SORTIE/'characters').mkdir(parents=True,exist_ok=True)
    sculpter()
    socle.exporter(sections_circulaires=False)
    for source,destination in [('characters/apprenti_a.glb','characters/apprenti_accueil_v2.glb'),('sources/characters/apprenti_a.blend','sources/characters/apprenti_accueil_v2.blend')]:
        shutil.copy2(socle.SORTIE/source,RACINE/'assets/3d'/destination)
    if '--rendu' in sys.argv:
        atelier.studio()
