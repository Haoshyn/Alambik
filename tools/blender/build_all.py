"""Volumes Alambik reproductibles : blender --background --python tools/blender/build_all.py.

Sources modifiables. Le mage utilise des maillages articules avec des textures
peintes ; les autres objets conservent leurs materiaux proceduraux.
"""
import bpy
import math
import json
from pathlib import Path
from mathutils import Vector

RACINE = Path(__file__).resolve().parents[2]
SORTIE = RACINE / 'assets/3d'
MAT = {}
RAPPORT = []
ACTEUR = None
RIG = None


def materiaux():
    palette = {
        'violet': ((.19, .135, .30), .78, 0), 'turquoise': ((.065, .36, .37), .72, 0),
        'cuivre': ((.48, .32, .15), .4, .65), 'peau': ((.73, .52, .36), .82, 0),
        'cheveux': ((.76, .69, .54), .85, 0), 'cuir': ((.18, .105, .065), .87, 0),
        'papier': ((.64, .59, .46), .9, 0), 'encre': ((.045, .025, .085), .31, .05),
        'pierre': ((.47, .50, .46), .95, 0), 'pierre_claire': ((.60, .62, .54), .95, 0),
        'mousse': ((.14, .255, .17), .95, 0), 'bois': ((.25, .16, .105), .9, 0),
        'magie': ((.54, .16, .9), .3, .1), 'cristal': ((.13, .60, .60), .29, .2),
        'feu': ((.94, .25, .035), .45, .1), 'givre': ((.28, .65, .8), .35, .15),
        'venin': ((.38, .64, .12), .38, .1), 'sang': ((.40, .055, .07), .76, 0),
        'eau': ((.085, .32, .36), .3, .25), 'metal': ((.16, .20, .23), .5, .6),
    }
    for nom, (couleur, rugosite, metal) in palette.items():
        mat = bpy.data.materials.new(nom)
        mat.diffuse_color = (*couleur, 1)
        mat.use_nodes = True
        bsdf = mat.node_tree.nodes.get('Principled BSDF')
        bsdf.inputs['Base Color'].default_value = (*couleur, 1)
        bsdf.inputs['Roughness'].default_value = rugosite
        bsdf.inputs['Metallic'].default_value = metal
        if nom in ('magie', 'feu', 'givre', 'venin', 'cristal'):
            bsdf.inputs['Emission Color'].default_value = (*couleur, 1)
            bsdf.inputs['Emission Strength'].default_value = .25
        MAT[nom] = mat


def finir(obj, nom, mat):
    obj.name = nom
    obj.data.materials.clear()
    obj.data.materials.append(MAT[mat])
    if ACTEUR:
        obj.parent = ACTEUR
    if RIG:
        obj.parent = RIG
        groupe = 'racine'
        if nom in ('Botte','Jambe'):
            groupe = 'jambe_gauche' if obj.location.x < 0 else 'jambe_droite'
        elif nom in ('Manche','Gant'):
            groupe = 'bras_gauche' if obj.location.x < 0 else 'bras_droit'
        elif nom in ('Baguette','Fiole','Fiole_col','Fiole_monture') and obj.location.x > .30:
            groupe = 'bras_droit'
        elif nom=='Pan_echarpe': groupe='echarpe'
        poids=obj.vertex_groups.new(name=groupe)
        poids.add(list(range(len(obj.data.vertices))),1.0,'REPLACE')
        mod=obj.modifiers.new('Squelette','ARMATURE')
        mod.object=RIG
    return obj


def boule(nom, pos, taille, mat, segments=16):
    bpy.ops.mesh.primitive_uv_sphere_add(segments=segments, ring_count=8, location=pos)
    obj = bpy.context.object
    obj.scale = taille
    bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)
    for face in obj.data.polygons:
        face.use_smooth = True
    return finir(obj, nom, mat)


def boite(nom, pos, taille, mat, biseau=.025):
    bpy.ops.mesh.primitive_cube_add(size=1, location=pos)
    obj = bpy.context.object
    obj.scale = taille
    bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)
    if biseau:
        mod = obj.modifiers.new('Aretes_douces', 'BEVEL')
        mod.width = biseau
        mod.segments = 2
        bpy.ops.object.modifier_apply(modifier=mod.name)
        mod = obj.modifiers.new('Normales', 'WEIGHTED_NORMAL')
        bpy.ops.object.modifier_apply(modifier=mod.name)
    return finir(obj, nom, mat)


def cone(nom, pos, bas, haut, hauteur, mat, sommets=20):
    bpy.ops.mesh.primitive_cone_add(vertices=sommets, radius1=bas, radius2=haut, depth=hauteur, location=pos)
    obj = bpy.context.object
    for face in obj.data.polygons:
        face.use_smooth = len(face.vertices) == 4
    return finir(obj, nom, mat)


def anneau(nom, pos, rayon, tube, mat, rotation=(0, 0, 0)):
    bpy.ops.mesh.primitive_torus_add(major_segments=24, minor_segments=6, location=pos,
                                   major_radius=rayon, minor_radius=tube, rotation=rotation)
    return finir(bpy.context.object, nom, mat)


def tige(nom, debut, fin, rayon, mat):
    d = Vector(fin) - Vector(debut)
    obj = cone(nom, (Vector(debut)+Vector(fin))*.5, rayon, rayon*.85, d.length, mat, 10)
    obj.rotation_euler = d.to_track_quat('Z', 'Y').to_euler()
    return obj


def surface(nom, anneaux, mat, n=24):
    # Chaque anneau : centre x,y,z, rayons x,y ; tissu ferme et volumetrique.
    verts = []
    for x, y, z, rx, ry in anneaux:
        for i in range(n):
            a = i * math.tau / n
            verts.append((x+rx*math.cos(a), y+ry*math.sin(a), z))
    faces = []
    for j in range(len(anneaux)-1):
        for i in range(n):
            a = j*n+i
            b = j*n+(i+1)%n
            faces.append((a,b,b+n,a+n))
    faces.extend([tuple(reversed(range(n))), tuple(range((len(anneaux)-1)*n,len(verts)))])
    mesh = bpy.data.meshes.new(nom)
    mesh.from_pydata(verts, [], faces)
    mesh.update()
    obj = bpy.data.objects.new(nom,mesh)
    bpy.context.collection.objects.link(obj)
    for p in mesh.polygons:
        p.use_smooth = len(p.vertices)==4
    return finir(obj,nom,mat)


def fiole(pos, r=.12, mat='magie', nom='Fiole'):
    x,y,z = pos
    boule(nom, (x,y,z+r), (r,r,r*1.2), mat)
    cone(nom+'_col', (x,y,z+r*2.2), r*.4, r*.4, r*.6, 'cuivre', 12)
    anneau(nom+'_monture', (x,y,z+r*.75), r*.99, r*.075, 'cuivre')


def yeux(y=-.23,z=.48,ecart=.13,mat='magie'):
    for cote in [-1,1]:
        boule('Oeil', (ecart*cote,y,z),(.055,.035,.075),mat,12)


def heros():
    import sys
    sys.path.insert(0,str(Path(__file__).resolve().parent))
    from heros_azur import construire
    construire(sys.modules[__name__])


def encrier():
    boule('Ventre_encre',(0,0,.29),(.27,.24,.23),'encre')
    cone('Pot',(0,0,.38),.23,.21,.19,'encre')
    anneau('Collier',(0,0,.48),.205,.035,'cuivre')
    cone('Encre_visible',(0,0,.49),.18,.18,.012,'encre')
    couvercle = cone('Couvercle',(0,.17,.61),.205,.205,.035,'cuivre')
    couvercle.rotation_euler.x=math.radians(48)
    for cote in [-1,1]:
        for i in range(3):
            y=(i-1)*.19
            tige('Patte',(.18*cote,y,.29),(.34*cote,y,.17),.047,'encre')
            tige('Patte',(.34*cote,y,.17),(.39*cote,y-.02,.055),.034,'encre')
            boule('Pied',(.39*cote,y-.02,.04),(.075,.07,.035),'encre',12)
    yeux(-.22,.30)


def plume():
    surface('Plume',[(0,0,.08,.025,.02),(.03,0,.25,.09,.03),(.10,0,.50,.15,.035),(.15,0,.77,.09,.02),(.18,0,.93,.002,.002)],'papier',12)
    tige('Rachis',(0,-.035,.12),(.18,-.035,.9),.012,'cuivre')
    boule('Masque',(0,-.03,.24),(.12,.095,.12),'encre')
    yeux(-.12,.25,.055)


def livre(taille=1):
    boite('Pages',(0,0,.40),(.42,.19,.57),'papier')
    for y in [-.12,.12]:
        boite('Couverture',(0,y,.40),(.48,.035,.63),'cuir')
    boite('Dos',(-.23,0,.40),(.04,.25,.63),'violet')
    anneau('Sceau',(0,-.15,.41),.085,.018,'cuivre',(math.pi/2,0,0))
    boule('Gemme',(0,-.158,.41),(.057,.028,.07),'magie')


def robe(mat='papier'):
    surface('Robe',[(0,0,.07,.30,.23),(0,0,.33,.24,.17),(0,0,.63,.16,.13),(0,0,.79,.24,.17)],mat)
    surface('Capuche',[(0,0,.72,.22,.17),(0,.02,.97,.19,.15),(0,.07,1.14,.015,.02)],mat)
    boule('Ombre_visage',(0,-.155,.88),(.135,.055,.16),'encre')
    yeux(-.204,.89,.065)
    for c in [-1,1]:
        tige('Bras',(.18*c,0,.74),(.31*c,-.06,.5),.075,mat)


def commun(nom):
    if nom=='encrier_rampant': encrier()
    elif nom=='plume_sentinelle': plume()
    elif nom=='tache_veloce':
        boule('Tache',(0,0,.22),(.26,.30,.20),'encre')
        for i in range(3):
            boule('Queue',(0,.25+i*.1,.2+i*.035),(.17-i*.04,.15,.095-i*.02),'encre')
        yeux(-.28,.26)
    elif nom=='folio_orbiteur': livre()
    elif nom in ('scribe_essaimeur','marge_harceleuse'):
        robe()
        if nom=='scribe_essaimeur':
            for c in [-1,1]:
                cone('Rouleau',(.16*c,.18,.65),.065,.065,.65,'papier')
        else:
            for c in [-1,1]:
                tige('Griffe',(.30*c,0,.5),(.41*c,-.12,.24),.025,'encre')
    elif nom=='sceau_belier':
        boule('Corps',(0,0,.28),(.29,.31,.23),'papier')
        for c in [-1,1]:
            for y in [-.19,.19]: tige('Patte',(.22*c,y,.2),(.28*c,y,.045),.06,'encre')
            anneau('Corne',(.24*c,-.19,.4),.105,.033,'cuivre',(math.pi/2,0,0))
        obj=cone('Cachet',(0,-.29,.25),.16,.16,.055,'sang')
        obj.rotation_euler.x=math.pi/2
    elif nom=='miroir_encre':
        obj=boule('Miroir',(0,0,.46),(.22,.06,.35),'encre')
        anneau('Cadre',(0,0,.46),.26,.034,'cuivre',(math.pi/2,0,0)).scale.y=1.35
        yeux(-.065,.46,.09)
        for c in [-1,1]: tige('Appui',(.11*c,0,.2),(.21*c,-.02,.03),.045,'encre')
    elif nom=='cachet_phaseur':
        cone('Base',(0,0,.13),.28,.24,.12,'cuivre')
        cone('Poignee',(0,0,.36),.095,.07,.36,'bois')
        boule('Pommeau',(0,0,.57),(.14,.13,.16),'bois')
        anneau('Sceau',(0,0,.065),.24,.025,'magie')
    elif nom=='fuseau_tisseur':
        boule('Fuseau',(0,0,.29),(.15,.23,.14),'violet')
        for c in [-1,1]:
            for y in [-.2,0,.2]:
                tige('Patte',(.10*c,y*.5,.32),(.32*c,y,.35),.027,'cuivre')
                tige('Patte',(.32*c,y,.35),(.39*c,y*1.4,.035),.023,'cuivre')
        yeux(-.21,.3,.065)
    elif nom=='fiole_volatile':
        fiole((0,0,.06),.25)
        yeux(-.24,.32)


def majeur(index, miniature=False):
    if miniature:
        if index==1:
            encrier(); fiole((0,0,.52),.21)
        elif index==3:
            livre()
            for c in [-1,1]:
                for i in range(5):
                    cone('Dent',(-.17+i*.085,-.18,.17+c*.03+(.42 if c>0 else 0)),.023,0,.095,'papier',6)
            surface('Langue',[(0,-.16,.40,.10,.03),(0,-.32,.26,.08,.03),(.06,-.41,.11,.05,.02)],'sang',10)
        elif index==5:
            for z in range(3):
                for x in [-1,1]:
                    boite('Tiroir',(.16*x,0,.18+z*.24),(.30,.30,.22),'bois')
                    boule('Poignee',(.16*x,-.18,.18+z*.24),(.025,.025,.025),'cuivre',10)
        else:
            robe('violet' if index in [2,7,8,9] else 'papier')
            if index==0:
                for z in [.3,.48,.64]: anneau('Bande',(0,0,z),.235,.025,'papier').scale.y=.8
            elif index==2:
                boite('Bouclier',(-.34,-.12,.48),(.26,.08,.45),'cuivre')
                tige('Sceptre',(.32,0,.1),(.32,0,1.17),.023,'cuivre')
            elif index==4: boule('Orbe',(0,0,1.11),(.24,.22,.24),'encre')
            elif index==6: surface('Cri',[(0,-.19,.70,.075,.025),(0,-.22,.85,.08,.04),(0,-.18,.99,.06,.02)],'encre')
            elif index==7:
                tige('Pinceau',(.31,0,.13),(.31,0,1.15),.027,'bois')
                boule('Peinture',(.31,0,1.12),(.09,.08,.18),'feu')
            elif index==8:
                boite('Signet',(0,-.2,.63),(.12,.027,.75),'sang')
                tige('Epee',(.32,-.1,.1),(.32,-.1,.85),.027,'cuivre')
            elif index==9:
                boite('Pupitre',(0,-.28,.46),(.51,.3,.10),'bois')
                boite('Page',(0,-.29,.52),(.43,.25,.015),'papier',0)
    else:
        famille=index%5
        magie=['magie','feu','givre','givre','venin'][famille] if index<5 else ['sang','magie','cuivre','magie','givre'][famille]
        if famille==0:
            robe('violet')
            for c in [-1,1]:
                boite('Page_flottante',(.36*c,0,.82),(.18,.035,.30),'papier')
            anneau('Aureole',(0,.06,1.12),.24,.022,'cuivre',(math.pi/2,0,0))
        elif famille==1:
            boule('Armure',(0,0,.53),(.32,.22,.39),'metal')
            for c in [-1,1]:
                boite('Jambe',(.18*c,0,.14),(.18,.24,.25),'metal')
                boule('Epaulette',(.31*c,0,.75),(.17,.19,.15),'metal')
                tige('Corne',(.12*c,0,1),(.25*c,0,1.23),.055,'cuivre')
            boule('Casque',(0,0,.94),(.18,.16,.19),'metal')
            boule('Fournaise',(0,-.21,.53),(.16,.07,.17),magie)
            tige('Marteau',(.38,0,.1),(.38,0,.78),.03,'cuivre')
            boite('Masse',(.38,0,.79),(.32,.21,.2),'metal')
        elif famille==2:
            robe('papier')
            for i in range(7):
                a=i*math.tau/7
                cone('Cristal',(math.cos(a)*.28,math.sin(a)*.24,.17),.10,0,.38,magie,5)
            for c in [-1,0,1]: cone('Couronne',(.12*c,0,1.14),.06,0,.32-abs(c)*.1,'cuivre',5)
        elif famille==3:
            robe('metal')
            for c in [-1,1]:
                surface('Aile',[(.2*c,.08,.5,.03,.03),(.46*c,.10,.78,.18,.035),(.57*c,.12,1.14,.10,.015)],magie,8)
            fiole((0,0,1.05),.14,magie)
        else:
            boule('Cuve',(0,0,.40),(.32,.25,.32),'metal')
            for c in [-1,0,1]:
                x=c*.28
                tige('Cou',(x*.6,0,.48),(x,0,.85+(.13 if c==0 else 0)),.06,'cuivre')
                fiole((x,0,.78+(.13 if c==0 else 0)),.15,magie)
        yeux(-.18,.90,.07,magie)


def obstacle(index):
    if index==0:
        for z in range(2):
            for x in range(3): boite('Pierre',((x-1)*.32,0,.10+z*.19),(.315,.38,.185),'pierre_claire')
        boite('Mousse',(-.30,.025,.40),(.26,.24,.035),'mousse')
    elif index==1:
        boite('Jardiniere',(0,0,.12),(.95,.45,.24),'pierre')
        for i in range(5): boule('Feuillage',((i-2)*.17,0,.33),(.19,.19,.19+(.08 if i==2 else 0)),'mousse',12)
    else:
        for i in range(3):
            boule('Rocher',((i-1)*.25,0,.15),(.24,.21,.20),'pierre',8)
        cone('Cristal',(.05,.05,.43),.12,0,.59,'cristal',5)


def portail():
    import portail_azur
    import sys
    portail_azur.construire(sys.modules[__name__])


def decor():
    boite('Dalle',(0,0,-.095),(1,1,.18),'pierre_claire')


def animations():
    # Animation rigide sur une racine unique ; les membres gardent des meshes editables.
    for nom, duree, amplitudes in [('repos',48,(.018,.012)),('course',20,(.055,.06)),('attaque',12,(.02,-.13)),('touche',10,(.015,.16)),('mort',24,(-.20,.95)),('victoire',40,(.08,.08))]:
        action=bpy.data.actions.new(nom)
        ACTEUR.animation_data_create()
        ACTEUR.animation_data.action=action
        for f,facteur in [(1,0),(duree//2,1),(duree,1 if nom=='mort' else 0)]:
            ACTEUR.location.z=amplitudes[0]*facteur
            ACTEUR.rotation_euler.y=amplitudes[1]*facteur
            ACTEUR.scale=(1+facteur*.025,1+facteur*.025,1-facteur*.025)
            ACTEUR.keyframe_insert(data_path='location',frame=f)
            ACTEUR.keyframe_insert(data_path='rotation_euler',frame=f)
            ACTEUR.keyframe_insert(data_path='scale',frame=f)
        piste=ACTEUR.animation_data.nla_tracks.new()
        piste.name=nom
        piste.strips.new(nom,1,action)
        piste.mute=True
        if RIG:
            action_rig=bpy.data.actions.new(nom+'_articule')
            RIG.animation_data_create()
            RIG.animation_data.action=action_rig
            for f in [1,duree//4,duree//2,duree*3//4,duree]:
                phase=(f-1)/max(1,duree-1)*math.tau
                for os in RIG.pose.bones:
                    os.rotation_mode='XYZ'
                    os.rotation_euler=(0,0,0)
                    if nom=='course':
                        if os.name.startswith('jambe'): os.rotation_euler.x=math.sin(phase)*(.42 if os.name.endswith('gauche') else -.42)
                        if os.name.startswith('bras'): os.rotation_euler.x=math.sin(phase)*(-.22 if os.name.endswith('gauche') else .22)
                    if os.name=='echarpe': os.rotation_euler.x=math.sin(phase)*(.13 if nom=='course' else .045)
                    if nom=='attaque' and os.name=='bras_droit': os.rotation_euler.x=math.sin(phase*.5)**.6*.85
                    if nom=='victoire' and os.name.startswith('bras'): os.rotation_euler.x=-math.sin(phase*.5)*1.3
                    os.keyframe_insert(data_path='rotation_euler',frame=f)
            piste_rig=RIG.animation_data.nla_tracks.new()
            piste_rig.name=nom
            piste_rig.strips.new(nom,1,action_rig)
            piste_rig.mute=True
            RIG.animation_data.action=None
            for os in RIG.pose.bones: os.rotation_euler=(0,0,0)
    ACTEUR.animation_data.action=None
    ACTEUR.location=(0,0,0)
    ACTEUR.rotation_euler=(0,0,0)
    ACTEUR.scale=(1,1,1)


def exporter(nom, dossier, construire, anime=False):
    global ACTEUR, RIG, MAT
    materiaux_avant=MAT
    if nom=='heros':
        MAT={cle:mat.copy() for cle,mat in MAT.items()}
        for cle,mat in MAT.items():mat['alambik_matiere']=cle
    RIG=None
    bpy.ops.object.select_all(action='SELECT')
    bpy.ops.object.delete(use_global=False)
    ACTEUR=bpy.data.objects.new('Volume',None)
    bpy.context.collection.objects.link(ACTEUR)
    if nom=='heros':
        armature=bpy.data.armatures.new('Squelette_heros')
        RIG=bpy.data.objects.new('Squelette',armature)
        bpy.context.collection.objects.link(RIG)
        RIG.parent=ACTEUR
        from heros_azur import creer_squelette
        creer_squelette(RIG)
    construire()
    # Un mesh par materiau au maximum, au lieu d'un draw call par petite piece.
    for mat in MAT.values():
        objets=[o for o in bpy.context.scene.objects if o.type=='MESH' and o.data.materials and o.data.materials[0]==mat]
        if not objets: continue
        bpy.ops.object.select_all(action='DESELECT')
        for obj in objets: obj.select_set(True)
        bpy.context.view_layer.objects.active=objets[0]
        if len(objets)>1: bpy.ops.object.join()
        objets[0].name=mat.name
    meshes=[o for o in bpy.context.scene.objects if o.type=='MESH']
    triangles=sum(sum(len(p.vertices)-2 for p in o.data.polygons) for o in meshes)
    if anime:
        if nom=='heros':
            from heros_azur import animer
            animer()
        else: animations()
    source=SORTIE/'sources'/dossier/(nom+'.blend')
    export=SORTIE/dossier/(nom+'.glb')
    source.parent.mkdir(parents=True,exist_ok=True)
    export.parent.mkdir(parents=True,exist_ok=True)
    bpy.context.scene.render.fps=24
    bpy.context.scene.frame_set(1)
    if nom=='heros': bpy.ops.file.pack_all()
    bpy.ops.wm.save_as_mainfile(filepath=str(source))
    bpy.ops.export_scene.gltf(filepath=str(export),export_format='GLB',export_yup=True,
        export_animations=anime,export_animation_mode='NLA_TRACKS',export_nla_strips=True,
        export_force_sampling=True,export_materials='EXPORT',export_cameras=False,export_lights=False)
    RAPPORT.append({'nom':nom,'glb':str(export.relative_to(RACINE)).replace('\\','/'),
                    'triangles':triangles,'surfaces':len(meshes),'octets':export.stat().st_size,
                    'animations': ['repos','course','attaque','touche','mort','victoire'] if anime else []})
    if nom=='heros':MAT=materiaux_avant


def main():
    bpy.ops.wm.read_factory_settings(use_empty=True)
    bpy.context.preferences.filepaths.save_version=0
    bpy.context.preferences.filepaths.file_preview_type='NONE'
    materiaux()
    exporter('heros','characters',heros,True)
    communs=['encrier_rampant','plume_sentinelle','tache_veloce','scribe_essaimeur','folio_orbiteur','sceau_belier','marge_harceleuse','miroir_encre','cachet_phaseur','fuseau_tisseur','fiole_volatile']
    for nom in communs: exporter(nom,'enemies',lambda n=nom:commun(n),True)
    for i in range(10): exporter('miniboss_'+str(i),'bosses',lambda n=i:majeur(n,True),True)
    for i in range(10): exporter('boss_'+str(i),'bosses',lambda n=i:majeur(n),True)
    exporter('gardien','characters',livre,True)
    exporter('orbe','projectiles',lambda:boule('Coeur',(0,0,0),(.09,.09,.09),'magie',12))
    for i in range(3): exporter('obstacle_'+str(i),'props',lambda n=i:obstacle(n))
    exporter('portail','environment',portail)
    exporter('dalle','environment',decor)
    exporter('colonne','environment',lambda:(cone('Fut',(0,0,.6),.18,.16,1.2,'pierre',12),boite('Chapiteau',(0,0,1.2),(.44,.44,.12),'pierre_claire')))
    (SORTIE/'rapport.json').write_text(json.dumps({'blender':bpy.app.version_string,'assets':RAPPORT},indent=2),encoding='utf-8')
    print('ALAMBIK_EXPORT_OK',len(RAPPORT),sum(x['triangles'] for x in RAPPORT))


if __name__=='__main__': main()
