"""Base de construction du mage sculpte depuis sa geometrie source."""
import bpy
import json
import math
import struct
import sys
from pathlib import Path
from mathutils import Vector

RACINE = Path(__file__).resolve().parents[2]
SORTIE = RACINE / 'assets/3d/characters'
HAUTEUR = 2.14284
ALLEGEMENT = .24
sys.path.insert(0,str(Path(__file__).resolve().parent))
from texturer_mage_reference import texturer, ajuster_proportions, accessoires_chapeau, surface_pan
from animer_mage_v2 import animer


def lire_glb(path):
    brut = path.read_bytes()
    taille = struct.unpack_from('<I', brut, 12)[0]
    return json.loads(brut[20:20+taille]), brut[28+taille:]


def ecrire_glb(path, doc, binaire):
    binaire += b'\0' * (-len(binaire) % 4)
    doc['buffers'] = [{'byteLength': len(binaire)}]
    texte = json.dumps(doc, separators=(',', ':')).encode()
    texte += b' ' * (-len(texte) % 4)
    path.write_bytes(struct.pack('<III', 0x46546c67, 2, 28+len(texte)+len(binaire))
                    + struct.pack('<II', len(texte), 0x4e4f534a) + texte
                    + struct.pack('<II', len(binaire), 0x004e4942) + binaire)


def meshy():
    bpy.ops.object.select_all(action='SELECT')
    bpy.ops.object.delete(use_global=False)
    source = RACINE/'assets/3d/sources/characters/mage_v2'
    bpy.ops.import_scene.gltf(filepath=str(source/'geometrie_meshy.glb'))
    objet = next(o for o in bpy.context.scene.objects if o.type == 'MESH')
    objet.name = 'Mage_v2'
    bpy.context.view_layer.objects.active = objet
    bas = min(v.co.z for v in objet.data.vertices)
    facteur = HAUTEUR/(max(v.co.z for v in objet.data.vertices)-bas)
    for v in objet.data.vertices:
        v.co.z -= bas
        v.co *= facteur
    bpy.ops.object.mode_set(mode='EDIT')
    bpy.ops.mesh.select_all(action='SELECT')
    bpy.ops.mesh.remove_doubles(threshold=.00001)
    bpy.ops.mesh.normals_make_consistent(inside=False)
    bpy.ops.object.mode_set(mode='OBJECT')
    # Le fichier brut depasse 100 000 sommets ; garder les volumes lisibles en jeu.
    mod = objet.modifiers.new('Allegement_mobile', 'DECIMATE')
    mod.ratio = ALLEGEMENT
    bpy.ops.object.modifier_apply(modifier=mod.name)
    for face in objet.data.polygons:
        face.use_smooth = True
    # Lisser l'ancienne boucle fusionnee avant de poser la boucle independante.
    for v in objet.data.vertices:
        x,y,z=v.co
        if -.05<x<.25 and 1.58<z<1.76 and y<-.31:
            v.co.y=max(y,-.335+(z-1.64)*.35)
    texturer(objet,source/'reference.png',source/'couleur.png')
    accessoires_chapeau(objet)
    data = bpy.data.armatures.new('Squelette_v2')
    rig = bpy.data.objects.new('Squelette', data)
    bpy.context.collection.objects.link(rig)
    bpy.ops.object.select_all(action='DESELECT')
    rig.select_set(True)
    bpy.context.view_layer.objects.active = rig
    bpy.ops.object.mode_set(mode='EDIT')
    def os(nom, point, parent=None):
        b = data.edit_bones.new(nom)
        b.head = point
        b.tail = Vector(point)+Vector((0,0,.08))
        if parent: b.parent = data.edit_bones[parent]
    os('racine',(0,0,0));os('bassin',(0,0,.49),'racine');os('torse',(0,0,.68),'bassin')
    os('tete',(0,0,1.035),'torse');os('chapeau',(0,0,1.40),'tete')
    os('echarpe',(-.20,.12,.90),'torse')
    for signe,cote in [(1,'gauche'),(-1,'droite')]:
        os('bras_'+cote,(signe*.20,0,.89),'torse')
        os('avant_bras_'+cote,(signe*.43,0,.88),'bras_'+cote)
        os('main_'+cote,(signe*.59,0,.875),'avant_bras_'+cote)
        os('cuisse_'+cote,(signe*.14,0,.48),'bassin')
        os('tibia_'+cote,(signe*.14,0,.27),'cuisse_'+cote)
        os('pied_'+cote,(signe*.14,-.04,.11),'tibia_'+cote)
    bpy.ops.object.mode_set(mode='OBJECT')
    objet.parent = rig
    mod = objet.modifiers.new('Articulation', 'ARMATURE');mod.object = rig
    groupes = {b.name: objet.vertex_groups.new(name=b.name) for b in data.bones}
    def rampe(a,b,x):
        t = max(0,min(1,(x-a)/(b-a)))
        return t*t*(3-2*t)
    for v in objet.data.vertices:
        x,y,z = v.co
        cote = 'gauche' if x>0 else 'droite'
        if surface_pan(x,y,z):
            w={'echarpe':1}
        elif x<-.15 and y<-.15 and .34<z<.75:
            # La fiole pend a la ceinture : elle ne doit pas suivre le genou.
            w={'bassin':1}
        elif z > 1.035:
            t = rampe(1.39,1.65,z); w = {'tete':1-t,'chapeau':t}
        elif abs(x) > .22 and .78 < z < .98:
            t = rampe(.35,.50,abs(x));m = rampe(.57,.64,abs(x))
            w = {'bras_'+cote:1-t,'avant_bras_'+cote:t*(1-m),'main_'+cote:t*m}
            b = rampe(.22,.29,abs(x));w = {n:p*b for n,p in w.items()};w['torse']=1-b
        elif z > .51:
            t = rampe(.56,.82,z);h = rampe(.99,1.035,z)
            w = {'bassin':(1-t)*(1-h),'torse':t*(1-h),'tete':h}
        else:
            t = rampe(.23,.32,z);p = 1-rampe(.11,.18,z);b = rampe(.44,.51,z)
            w = {'pied_'+cote:p*(1-b),'tibia_'+cote:(1-t)*(1-p)*(1-b),
                 'cuisse_'+cote:t*(1-p)*(1-b),'bassin':b}
        for nom,poids in w.items():
            if poids>0:groupes[nom].add([v.index],poids,'REPLACE')
    ajuster_proportions(objet,rig)
    rig.animation_data_create()
    scene=bpy.context.scene;scene.render.fps=30
    for nom,duree in [('repos',2.4),('course',.6),('attaque',.4),('touche',.3),('mort',.9),('victoire',1.6)]:
        action=bpy.data.actions.new(nom);rig.animation_data.action=action
        frames=round(duree*30)
        for f in range(frames+1):
            t=f/frames;phase=t*math.tau;p=rig.pose.bones
            for b in p:
                b.rotation_mode='XYZ';b.rotation_euler=(0,0,0);b.location=(0,0,0)
            for signe,cote in [(1,'gauche'),(-1,'droite')]:
                p['bras_'+cote].rotation_euler.z=-signe*.78
                p['avant_bras_'+cote].rotation_euler.y=signe*.16
            p['torse'].rotation_euler.x=.018*math.sin(phase)
            p['chapeau'].rotation_euler.z=.025*math.sin(phase-.4)
            if nom=='course':
                p['bassin'].location.y=.055*(1-math.cos(2*phase))
                p['torse'].rotation_euler.x=.15
                p['torse'].rotation_euler.y=.16*math.sin(phase)
                p['bassin'].rotation_euler.y=-.10*math.sin(phase)
                p['echarpe'].rotation_euler.x=.18+.16*math.sin(phase-.7)
                for signe,cote in [(1,'gauche'),(-1,'droite')]:
                    pas=phase+(math.pi if signe>0 else 0)
                    p['cuisse_'+cote].rotation_euler.x=.85*math.sin(pas)
                    p['cuisse_'+cote].rotation_euler.z=signe*.10
                    p['tibia_'+cote].rotation_euler.x=.95*max(0,math.sin(pas))
                    p['bras_'+cote].rotation_euler.y=signe*.60*math.sin(pas)
                    # Garder les coudes pres des flancs pendant le balancement.
                    p['bras_'+cote].rotation_euler.z=-signe*(1.25+.04*math.cos(pas))
                    p['avant_bras_'+cote].rotation_euler.y=signe*(.30+.35*max(0,math.sin(pas)))
            elif nom=='attaque':
                # Une anticipation courte, une extension franche, puis le retour.
                anticipation=rampe(0,.18,t)*(1-rampe(.18,.36,t))
                geste=rampe(.12,.38,t)*(1-rampe(.60,1,t))
                p['bras_droite'].rotation_euler.z=.78-.65*geste-.15*anticipation
                p['bras_droite'].rotation_euler.y=-.45*anticipation+1.35*geste
                p['avant_bras_droite'].rotation_euler.y= .16+.75*anticipation-.12*geste
                p['bras_gauche'].rotation_euler.z=-.78+.35*geste
                p['bras_gauche'].rotation_euler.y=-.35*geste
                p['torse'].rotation_euler.y=.28*anticipation-.32*geste
                p['torse'].rotation_euler.x=.12*geste
                p['tete'].rotation_euler.y=-.15*anticipation+.18*geste
                p['echarpe'].rotation_euler.x=-.18*geste
            elif nom=='touche':
                p['torse'].rotation_euler.x=-.22*math.sin(math.pi*t)
                p['tete'].rotation_euler.x=.14*math.sin(math.pi*t)
            elif nom=='mort':
                a=rampe(0,.75,t)
                p['racine'].rotation_euler.x=-math.pi*.48*a
                p['racine'].location.y=.22*a
            elif nom=='victoire':
                p['bras_gauche'].rotation_euler.z=-.78+2.0*math.sin(math.pi*t)
                p['bassin'].location.y=.10*abs(math.sin(2*phase))
            for b in p:
                b.keyframe_insert('rotation_euler',frame=f+1,group=b.name)
                b.keyframe_insert('location',frame=f+1,group=b.name)
        piste=rig.animation_data.nla_tracks.new();piste.name=nom
        piste.strips.new(nom,1,action);piste.mute=True
    rig.animation_data.action=None
    for b in rig.pose.bones:b.rotation_euler=(0,0,0);b.location=(0,0,0)
    scene.frame_set(1)
    bpy.ops.object.select_all(action='SELECT')
    bpy.ops.export_scene.gltf(filepath=str(SORTIE/'mage_meshy_v2.glb'),export_format='GLB',
        use_selection=True,export_animations=True,export_animation_mode='NLA_TRACKS',
        export_force_sampling=True,export_skins=True,export_def_bones=True)
    animer(SORTIE/'mage_meshy_v2.glb')
