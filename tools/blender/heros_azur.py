"""Mage humain stylise : surfaces lissees et deformation autour des articulations."""
import bpy, math, sys, json
from pathlib import Path
from mathutils import Vector
sys.path.insert(0,str(Path(__file__).resolve().parent))
import build_all as b
SQUELETTE=None

def lier(obj, os='racine', joint=None, subdivisions=0):
    bpy.ops.object.select_all(action='DESELECT');obj.select_set(True);bpy.context.view_layer.objects.active=obj
    bpy.ops.object.transform_apply(location=True,rotation=True,scale=True)
    if subdivisions:
        mod=obj.modifiers.new('Surface_lissee','SUBSURF');mod.levels=subdivisions
        bpy.ops.object.modifier_apply(modifier=mod.name)
    for face in obj.data.polygons:face.use_smooth=True
    obj.parent=SQUELETTE
    groupes={os:obj.vertex_groups.new(name=os)}
    if joint:groupes[joint[0]]=obj.vertex_groups.new(name=joint[0])
    for sommet in obj.data.vertices:
        part=0.
        if joint:
            part=max(0.,min(1.,(joint[1]+joint[2]-sommet.co.z)/(2*joint[2])))
            part=part*part*(3-2*part)
        if part<1:groupes[os].add([sommet.index],1-part,'REPLACE')
        if part>0:groupes[joint[0]].add([sommet.index],part,'REPLACE')
    mod=obj.modifiers.new('Deformation','ARMATURE');mod.object=SQUELETTE
    return obj

def volume(nom,pos,taille,mat,os='racine'):
    return lier(b.boule(nom,pos,taille,mat,24),os,subdivisions=1)

def tissu(nom,anneaux,mat,os='racine',joint=None):
    return lier(b.surface(nom,anneaux,mat,24),os,joint,2 if nom in ('Visage','Chapeau') else 1)

def courbe(nom,points,rayon,mat,os='racine'):
    c=bpy.data.curves.new(nom,'CURVE');c.dimensions='3D';c.resolution_u=12;c.bevel_depth=rayon;c.bevel_resolution=3
    s=c.splines.new('BEZIER');s.bezier_points.add(len(points)-1)
    for i,(p,co) in enumerate(zip(s.bezier_points,points)):
        p.co=co;p.handle_left_type='AUTO';p.handle_right_type='AUTO';p.radius=.18 if i==len(points)-1 else 1.
    obj=bpy.data.objects.new(nom,c);bpy.context.collection.objects.link(obj)
    bpy.ops.object.select_all(action='DESELECT');obj.select_set(True);bpy.context.view_layer.objects.active=obj
    bpy.ops.object.convert(target='MESH')
    return lier(b.finir(bpy.context.object,nom,mat),os)

def construire(base=None):
    global b,SQUELETTE
    if base is not None:b=base
    SQUELETTE=b.RIG;b.RIG=None
    couleurs={'violet':(.035,.055,.13),'turquoise':(.008,.12,.15),'peau':(.58,.31,.16),
              'cuir':(.060,.035,.029),'cheveux':(.055,.025,.016),'cuivre':(.52,.29,.10),
              'papier':(.72,.65,.48),'encre':(.012,.014,.028),'bois':(.11,.05,.025)}
    for nom,couleur in couleurs.items():
        mat=b.MAT[nom];mat.diffuse_color=(*couleur,1)
        bsdf=mat.node_tree.nodes.get('Principled BSDF');bsdf.inputs['Base Color'].default_value=(*couleur,1)
        bsdf.inputs['Roughness'].default_value=.72 if nom!='cuivre' else .34
    # Des jambes courtes et espacees portent un vrai bassin volumetrique.
    for cote,nom in [(-1,'gauche'),(1,'droite')]:
        x=cote*.155;hanche='jambe_'+nom;tibia='tibia_'+nom;pied='pied_'+nom
        tissu('Braies',[(x,0,.23,.087,.097),(x,0,.35,.096,.11),(x,0,.45,.104,.12),
              (x,0,.57,.12,.14),(x,0,.76,.128,.145),(x,0,.84,.10,.12)],'cuir',hanche,(tibia,.43,.095))
        volume('Soulier',(x,-.07,.13),(.116,.19,.112),'cuir',pied)
        volume('Semelle',(x,-.067,.050),(.119,.185,.035),'encre',pied)
        tissu('Guetre',[(x,0,.15,.11,.12),(x,0,.23,.114,.125),(x,0,.34,.115,.124),
              (x,0,.37,.116,.125)],'violet',tibia)
        for z in [.24,.31]:
            lier(b.anneau('Sangle_botte',(x,0,z),.122,.009,'cuivre'),tibia)
    tissu('Pourpoint',[(0,.01,.72,.215,.187),(0,.01,.81,.265,.218),(0,0,.94,.253,.212),
          (0,0,1.05,.237,.197),(0,0,1.19,.277,.22),(0,0,1.32,.29,.22),
          (0,.015,1.39,.19,.165)],'violet')
    tissu('Ceinturon',[(0,0,.91,.265,.222),(0,0,.935,.266,.224),(0,0,.99,.251,.213),
          (0,0,1.01,.245,.205)],'cuir')
    lier(b.boite('Boucle',(0,-.228,.956),(.108,.035,.088),'cuivre',.024))
    volume('Pierre_boucle',(0,-.253,.956),(.026,.012,.030),'cristal')
    # Cape ouverte : un seul tissu epais couvre les flancs et le dos.
    sommets=[];faces=[];nombre=40
    for z,rx,ry,cy in [(.58,.33,.27,.025),(.615,.34,.282,.028),(.83,.323,.268,.020),
                       (1.06,.308,.25,.015),(1.25,.33,.25,.008),(1.37,.30,.235,0),
                       (1.435,.17,.165,0)]:
        for i in range(nombre+1):
            a=-math.pi/2+.56+(math.tau-1.12)*i/nombre
            ondulation=1+.018*math.cos(a*7)*(1-(z-.58)/.855)
            sommets.append((rx*math.cos(a)*ondulation,cy+ry*math.sin(a)*ondulation,z))
    for j in range(6):
        for i in range(nombre):
            n=j*(nombre+1)+i;faces.append((n,n+1,n+nombre+2,n+nombre+1))
    m=bpy.data.meshes.new('Cape');m.from_pydata(sommets,[],faces);m.update()
    o=bpy.data.objects.new('Cape',m);bpy.context.collection.objects.link(o);o=b.finir(o,'Cape','turquoise')
    bpy.ops.object.select_all(action='DESELECT');o.select_set(True);bpy.context.view_layer.objects.active=o
    mod=o.modifiers.new('Epaisseur','SOLIDIFY');mod.thickness=.018;bpy.ops.object.modifier_apply(modifier=mod.name)
    lier(o,subdivisions=2)
    g=o.vertex_groups.new(name='jambe_gauche');d=o.vertex_groups.new(name='jambe_droite')
    for v in o.data.vertices:
        part=max(0.,min(.35,(.90-v.co.z)*1.3));droite=max(0.,min(1.,(v.co.x+.10)/.20))
        o.vertex_groups['racine'].add([v.index],1-part,'REPLACE');g.add([v.index],part*(1-droite),'REPLACE');d.add([v.index],part*droite,'REPLACE')
    for cote,nom in [(-1,'gauche'),(1,'droite')]:
        courbe('Bord_cape',[(cote*.10,-.135,1.43),(cote*.17,-.213,1.23),
               (cote*.164,-.208,1.0),(cote*.177,-.215,.79),(cote*.179,-.209,.61)],.008,'cuivre')
        bras='bras_'+('droit' if nom=='droite' else nom);avant='avant_'+bras
        tissu('Manche',[(cote*.40,-.02,.875,.073,.082),(cote*.405,0,.95,.11,.121),
              (cote*.38,0,1.10,.125,.143),(cote*.33,0,1.25,.153,.152),
              (cote*.285,0,1.32,.112,.12)],'violet',bras,(avant,1.075,.10))
        volume('Revers',(cote*.405,-.02,.91),(.088,.099,.055),'papier',avant)
        volume('Gant',(cote*.405,-.047,.82),(.084,.078,.094),'cuir',avant)
        volume('Pouce',(cote*.355,-.092,.835),(.03,.04,.045),'cuir',avant)
    volume('Bourse',(-.245,-.09,.865),(.102,.09,.12),'cuir')
    volume('Rabat_bourse',(-.24,-.163,.91),(.090,.026,.066),'violet')
    volume('Bouton_bourse',(-.24,-.191,.89),(.017,.012,.017),'cuivre')
    # Visage large avec des joues, un menton et un crane profonds.
    tissu('Visage',[(0,-.012,1.35,.08,.103),(0,-.035,1.39,.154,.15),(0,-.025,1.49,.199,.18),
          (0,-.006,1.61,.212,.19),(0,.018,1.73,.182,.169),(0,.03,1.79,.10,.104)],'peau')
    for cote in [-1,1]:
        volume('Oeil',(cote*.079,-.184,1.595),(.048,.018,.032),'papier')
        volume('Iris',(cote*.079,-.2,1.594),(.025,.008,.028),'turquoise')
        volume('Pupille',(cote*.079,-.206,1.594),(.012,.004,.021),'encre')
        volume('Reflet',(cote*.079-.006,-.21,1.606),(.005,.003,.007),'papier')
        courbe('Sourcil',[(cote*.032,-.178,1.637),(cote*.075,-.189,1.650),(cote*.124,-.163,1.642)],.011,'cheveux')
    volume('Nez',(0,-.189,1.548),(.028,.027,.034),'peau')
    # La capuche enveloppe le crane jusque derriere la nuque, avec une ouverture reelle.
    sommets=[];faces=[];nombre=48
    for y,rx,rz,cz in [(-.225,.234,.266,1.607),(-.24,.245,.28,1.61),(-.207,.282,.307,1.616),
                       (-.04,.314,.335,1.616),(.16,.285,.315,1.615),(.265,.195,.244,1.605),
                       (.315,.085,.13,1.60),(.326,.012,.025,1.59)]:
        for i in range(nombre):
            a=math.tau*i/nombre
            sommets.append((rx*math.cos(a)*(1-.12*max(0,math.sin(a))),y,cz+rz*math.sin(a)+.055*max(0,math.sin(a))**6))
    for j in range(7):
        for i in range(nombre):
            n=j*nombre+i;suivant=j*nombre+(i+1)%nombre
            faces.append((n,suivant,suivant+nombre,n+nombre))
    faces.append(tuple(range(7*nombre,8*nombre)))
    m=bpy.data.meshes.new('Capuche');m.from_pydata(sommets,[],faces);m.update()
    o=bpy.data.objects.new('Capuche',m);bpy.context.collection.objects.link(o);o=b.finir(o,'Capuche','turquoise')
    bpy.ops.object.select_all(action='DESELECT');o.select_set(True);bpy.context.view_layer.objects.active=o
    mod=o.modifiers.new('Doublure','SOLIDIFY');mod.thickness=.015;bpy.ops.object.modifier_apply(modifier=mod.name)
    lier(o,subdivisions=2)
    points=[]
    for i in range(49):
        a=math.tau*i/48;points.append((.24*math.cos(a)*(1-.12*max(0,math.sin(a))),-.244,1.61+.273*math.sin(a)+.055*max(0,math.sin(a))**6))
    courbe('Bord_capuche',points,.016,'violet')
    volume('Chevelure',(0,.015,1.73),(.185,.155,.11),'cheveux')
    for i in range(4):
        x=-.12+i*.065
        courbe('Frange',[(x+.025,-.035,1.815),(x+.050,-.14,1.775),(x+.013,-.184,1.693)],.035,'cheveux')
    volume('Col', (0,-.008,1.35),(.207,.178,.066),'violet')
    courbe('Chaine',[(-.14,-.175,1.34),(-.10,-.233,1.26),(0,-.25,1.215),(.10,-.233,1.26),(.14,-.175,1.34)],.008,'cuivre')
    volume('Amulette',(0,-.253,1.208),(.047,.019,.061),'cuivre')
    volume('Cristal_amulette',(0,-.271,1.213),(.027,.009,.036),'cristal')
    # Un baton plus court et epais ; le cristal est maintenu par deux branches.
    os='avant_bras_droit'
    courbe('Baton',[(.435,-.1,.24),(.435,-.1,.84),(.432,-.1,1.32),(.435,-.1,1.43)],.029,'bois',os)
    for z in [.755,.81,.865,1.35]:lier(b.anneau('Bague_baton',(.435,-.1,z),.032,.01,'cuivre'),os)
    for cote in [-1,1]:
        courbe('Fourche',[(.435,-.1,1.32),(.435+cote*.115,-.1,1.43),(.435+cote*.10,-.1,1.59),(.435+cote*.035,-.1,1.69)],.022,'cuivre',os)
    gemme=b.boule('Cristal_baton',(.435,-.1,1.53),(.083,.078,.137),'cristal',12);lier(gemme,os)
    volume('Pointe_baton',(.435,-.1,.26),(.034,.034,.054),'cuivre',os)
    b.RIG=SQUELETTE

def creer_squelette(rig):
    bpy.context.view_layer.objects.active=rig;rig.select_set(True);bpy.ops.object.mode_set(mode='EDIT')
    def os(nom,pos,parent=None):
        o=rig.data.edit_bones.new(nom);o.head=pos;o.tail=Vector(pos)+Vector((0,0,.12))
        if parent:o.parent=rig.data.edit_bones[parent]
    os('racine',(0,0,0))
    for cote,nom in [(-1,'gauche'),(1,'droite')]:
        os('jambe_'+nom,(cote*.155,0,.79),'racine')
        os('tibia_'+nom,(cote*.155,0,.43),'jambe_'+nom)
        os('pied_'+nom,(cote*.155,0,.11),'tibia_'+nom)
        bras='bras_'+('droit' if nom=='droite' else nom)
        os(bras,(cote*.285,0,1.30),'racine')
        os('avant_'+bras,(cote*.38,0,1.075),bras)
    os('echarpe',(.10,.115,1.37),'racine')
    bpy.ops.object.mode_set(mode='OBJECT')

def animer():
    rig=b.RIG
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
                    y=.20*math.cos(p);z=.11+.11*max(0,math.sin(p))
                    distance=math.sqrt(y*y+(.755-z)**2);distance=min(.679,distance)
                    flexion=-math.acos(max(-1,min(1,(distance*distance-.36**2-.32**2)/(2*.36*.32))))
                    angle=math.atan2(y,.755-z)-math.atan2(.32*math.sin(flexion),.36+.32*math.cos(flexion))
                    hanche.rotation_euler.x=angle;tibia.rotation_euler.x=flexion;pied.rotation_euler.x=-angle-flexion
                    bras.rotation_euler.x=-math.cos(p)*.23
                    avant.rotation_euler.x=-.10-max(0,math.sin(p))*.16
                elif nom=='attaque' and cote==1:
                    geste=math.sin(math.pi*t)**.7
                    bras.rotation_euler.x=.34*geste;avant.rotation_euler.x=.58*geste
                elif nom=='victoire':
                    bras.rotation_euler.y=cote*math.sin(math.pi*t)*1.2
            if nom=='course':rig.pose.bones['racine'].location.y=-.035
            if nom=='repos':rig.pose.bones['racine'].location.y=math.sin(phase)*.003
            if nom=='touche':rig.pose.bones['racine'].rotation_euler.x=-math.sin(math.pi*t)*.12
            if nom=='mort':rig.pose.bones['racine'].rotation_euler.x=t*1.45
            rig.pose.bones['echarpe'].rotation_euler.x=math.sin(phase)*(.09 if nom=='course' else .025)
            for o in rig.pose.bones:
                o.keyframe_insert(data_path='rotation_euler',frame=f);o.keyframe_insert(data_path='location',frame=f)
        piste=rig.animation_data.nla_tracks.new();piste.name=nom;piste.strips.new(nom,1,action);piste.mute=True
    rig.animation_data.action=None
    for o in rig.pose.bones:o.rotation_euler=(0,0,0);o.location=(0,0,0)

if __name__=='__main__':
    bpy.ops.wm.read_factory_settings(use_empty=True)
    bpy.context.preferences.filepaths.save_version=0;bpy.context.preferences.filepaths.file_preview_type='NONE'
    b.materiaux();b.exporter('heros','characters',construire,True)
    (b.SORTIE/'heros_azur_rapport.json').write_text(json.dumps(b.RAPPORT,indent=2),encoding='utf-8')

