"""Squelette et clips du heros B utilise en combat."""
import bpy
import json
import math
import sys
from pathlib import Path
from mathutils import Vector
sys.path.insert(0, str(Path(__file__).resolve().parent))
from baton_heros_meshy import fermer_main, creer_baton

RACINE = Path(__file__).resolve().parents[2]
SOURCE = RACINE / 'assets/3d/sources/characters/heros_b'
SORTIE = RACINE / 'assets/3d/characters/heros_b_anime.glb'
APERCUS = RACINE / 'tmp/meshy-heros'
FPS = 60
CLIPS = {'repos': 181, 'course': 33, 'attaque': 31, 'touche': 25, 'mort': 73, 'victoire': 121}


def rampe(a, b, x):
    t = max(0., min(1., (x-a)/(b-a)))
    return t*t*(3-2*t)


def creer_rig(objet):
    bpy.ops.object.select_all(action='DESELECT')
    data = bpy.data.armatures.new('Squelette_Heros_B')
    rig = bpy.data.objects.new('Heros_B', data)
    bpy.context.collection.objects.link(rig)
    rig.select_set(True)
    bpy.context.view_layer.objects.active = rig
    bpy.ops.object.mode_set(mode='EDIT')
    def os(nom, pos, parent=None):
        o = data.edit_bones.new(nom)
        o.head = pos
        # Axes communs : X lateral, Y vertical, Z vers l'avant.
        o.tail = Vector(pos)+Vector((0,0,.09))
        if parent:
            o.parent = data.edit_bones[parent]
    os('racine', (0,0,0))
    os('bassin', (0,-.08,.86), 'racine')
    os('torse', (0,-.08,1.04), 'bassin')
    os('tete', (0,-.015,1.34), 'torse')
    os('chapeau', (-.02,.015,1.59), 'tete')
    for signe, cote in [(-1,'droite'), (1,'gauche')]:
        os('cuisse_'+cote, (signe*.145,-.08,.83), 'bassin')
        os('tibia_'+cote, (signe*.145,-.08,.53), 'cuisse_'+cote)
        os('pied_'+cote, (signe*.145,-.08,.12), 'tibia_'+cote)
        os('bras_'+cote, (signe*.195,-.07,1.235), 'torse')
        os('avant_bras_'+cote, (signe*.31,-.07,1.035), 'bras_'+cote)
        os('main_'+cote, (signe*.405,-.07,.895), 'avant_bras_'+cote)
        os('pan_'+cote, (signe*.16,.07,.89), 'bassin')
    os('pan_dos', (0,.10,.88), 'bassin')
    bpy.ops.object.mode_set(mode='OBJECT')
    rig.show_in_front = True
    objet.parent = rig
    mod = objet.modifiers.new('Articulation', 'ARMATURE')
    mod.object = rig
    # La deformation lineaire correspond au skinning importe dans Godot.
    mod.use_deform_preserve_volume = False
    return rig


def peindre_poids(objet, rig):
    noms = [o.name for o in rig.data.bones]
    for groupe in list(objet.vertex_groups):
        objet.vertex_groups.remove(groupe)
    groupes = {n: objet.vertex_groups.new(name=n) for n in noms}
    poids = []
    for v in objet.data.vertices:
        x,y,z = v.co
        ax = abs(x)
        cote = 'gauche' if x>0 else 'droite'
        w = {}
        def ajouter(n,p):
            w[n] = w.get(n,0)+p
        bras = rampe(.16+(1.20-z)*.35, .195+(1.20-z)*.35, ax)
        bras *= rampe(.66,.70,z)*(1-rampe(1.29,1.33,z))
        if bras > 0:
            main = 1-rampe(.875,.935,z)
            avant = (1-rampe(1.00,1.095,z))*(1-main)
            ajouter('main_'+cote,bras*main)
            ajouter('avant_bras_'+cote,bras*avant)
            ajouter('bras_'+cote,bras*(1-main-avant))
        corps = 1-bras
        tete = rampe(1.295,1.37,z)
        torse = rampe(.96,1.14,z)*(1-tete)
        ajouter('tete',corps*tete)
        ajouter('torse',corps*torse)
        bas = corps*(1-tete-torse)
        if z >= .93:
            ajouter('bassin',bas)
        else:
            # Les pans exterieurs et arriere ne doivent pas suivre le genou.
            bord = .185 + max(0,.82-z)*.12
            manteau = max(rampe(bord,bord+.055,ax),rampe(.035,.12,y),
                          1-rampe(-.215,-.17,y))
            manteau *= rampe(.25,.35,z)*(1-rampe(.84,.94,z))
            arriere = rampe(.07,.15,y)*(1-rampe(.08,.20,ax))
            ajouter('pan_dos',bas*manteau*arriere)
            ajouter('pan_'+cote,bas*manteau*(1-arriere))
            jambe = bas*(1-manteau)
            bassin = rampe(.75,.91,z)
            pied = (1-rampe(.14,.23,z))*(1-bassin)
            tibia = (1-rampe(.48,.58,z))*(1-bassin-pied)
            ajouter('bassin',jambe*bassin)
            ajouter('pied_'+cote,jambe*pied)
            ajouter('tibia_'+cote,jambe*tibia)
            ajouter('cuisse_'+cote,jambe*(1-bassin-pied-tibia))
        poids.append(w)
    voisins = [set() for v in objet.data.vertices]
    for e in objet.data.edges:
        a,b = e.vertices
        voisins[a].add(b)
        voisins[b].add(a)
    # Lisser sur les aretes preserve les separations physiques bras/torse.
    for _ in range(5):
        suivant = []
        for i,w in enumerate(poids):
            if not voisins[i]:
                suivant.append(w)
                continue
            nouveau = {n:p*.65 for n,p in w.items()}
            for j in voisins[i]:
                for n,p in poids[j].items():
                    nouveau[n] = nouveau.get(n,0)+p*.35/len(voisins[i])
            suivant.append(nouveau)
        poids = suivant
    for i,w in enumerate(poids):
        retenus = sorted(((n,p) for n,p in w.items() if p>1e-5),key=lambda e:e[1],reverse=True)[:4]
        total = sum(p for n,p in retenus)
        assert total>0
        for n,p in retenus:
            groupes[n].add([i],p/total,'REPLACE')
    # Le bord reste rigide ; seule la calotte souple prolonge le geste de tete.
    for v in objet.data.vertices:
        part = rampe(1.57,1.75,v.co.z)
        if part <= 0:
            continue
        for groupe in list(v.groups):
            if objet.vertex_groups[groupe.group].name == 'tete':
                poids_tete = groupe.weight
                groupes['tete'].add([v.index],poids_tete*(1-part),'REPLACE')
                groupes['chapeau'].add([v.index],poids_tete*part,'REPLACE')
                break


def repos_pose(rig):
    for os in rig.pose.bones:
        os.rotation_mode = 'XYZ'
        os.rotation_euler = (0,0,0)
        os.location = (0,0,0)
        os.scale = (1,1,1)


def creer_animations(objet,rig):
    rig.animation_data_create()
    scene = bpy.context.scene
    scene.render.fps = FPS
    controles = {}
    for nom,duree in CLIPS.items():
        action = bpy.data.actions.new(nom)
        rig.animation_data.action = action
        minima = []
        for f in range(1,duree+1):
            scene.frame_set(f)
            repos_pose(rig)
            t = (f-1)/(duree-1)
            phase = t*math.tau
            p = rig.pose.bones
            # La pose de reference ecarte les bras ; la pose animee les relache.
            for signe,cote in [(-1,'droite'),(1,'gauche')]:
                p['bras_'+cote].rotation_euler.z = .18 if cote == 'droite' else -.36
                p['avant_bras_'+cote].rotation_euler.x = -.20
            if nom == 'repos':
                p['torse'].rotation_euler.x = math.sin(phase)*.022
                p['torse'].rotation_euler.z = math.sin(phase)*.012
                p['tete'].rotation_euler.x = -math.sin(phase-.25)*.015
                p['chapeau'].rotation_euler.z = .024*math.sin(phase-.7)
                p['pan_dos'].rotation_euler.x = .018*math.sin(phase-.6)
                p['bras_gauche'].rotation_euler.x = .025*math.sin(phase-.3)
                p['avant_bras_droite'].rotation_euler.x = -.26
                p['main_droite'].rotation_euler.x = .06
            if nom == 'course':
                rebond = .035*math.cos(phase*2)
                p['bassin'].location.y = -.08+rebond
                p['bassin'].location.x = .012*math.sin(phase)
                p['bassin'].rotation_euler.y = .035*math.sin(phase)
                p['torse'].rotation_euler.y = -.075*math.sin(phase)
                p['torse'].rotation_euler.z = -.022*math.sin(phase)
                p['torse'].rotation_euler.x = .18+.02*math.cos(phase*2)
                ressort = math.cos(phase*2)
                p['torse'].scale = (1-.012*ressort,1+.025*ressort,1-.012*ressort)
                p['tete'].rotation_euler.x = -.15-.012*math.cos(phase*2-.3)
                p['tete'].rotation_euler.y = .028*math.sin(phase)
                p['chapeau'].rotation_euler.x = .025*math.cos(phase*2-.8)
                p['chapeau'].rotation_euler.z = .055*math.sin(phase-.7)
                for signe,cote in [(-1,'droite'),(1,'gauche')]:
                    cycle = (t+(0.5 if signe>0 else 0))%1
                    appui = .34
                    if cycle < appui:
                        y = -.20 + .40*cycle/appui
                        z = .12
                    else:
                        u = (cycle-appui)/(1-appui)
                        # Retour C2 : vitesse ET acceleration raccordees a l'appui.
                        pente = (1-appui)/appui
                        y = .20+.40*(pente*u-(1+pente)*(6*u**5-15*u**4+10*u**3))
                        z = .12+.29*math.sin(math.pi*u)**2
                    h = .83-.08+rebond-z
                    d2 = y*y+h*h
                    genou = math.acos(max(-1,min(1,(d2-.30**2-.41**2)/(2*.30*.41))))
                    hanche = math.atan2(y,h)-math.atan2(.41*math.sin(genou),.30+.41*math.cos(genou))
                    p['cuisse_'+cote].rotation_euler.x = hanche
                    p['tibia_'+cote].rotation_euler.x = genou
                    p['pied_'+cote].rotation_euler.x = -hanche-genou
                    p['bras_'+cote].rotation_euler.x = .46*math.cos(cycle*math.tau)
                    p['avant_bras_'+cote].rotation_euler.x = -.46-.12*math.sin(cycle*math.tau-.3)
                    p['pan_'+cote].rotation_euler.x = hanche*.42+.055*math.cos(cycle*math.tau-.65)
                    p['pan_'+cote].rotation_euler.z = signe*.035*(1+math.sin(cycle*math.tau-.8))
                    if cote == 'droite':
                        p['bras_droite'].rotation_euler.x = -.20+.06*math.cos(cycle*math.tau)
                        p['avant_bras_droite'].rotation_euler.x = -.55-.025*math.sin(phase-.4)
                        p['main_droite'].rotation_euler.x = .57-.06*math.cos(cycle*math.tau)
                p['pan_dos'].rotation_euler.x = .24+.065*math.sin(phase*2-.7)
            if nom == 'attaque':
                # L'impulsion precede une recuperation longue, sans sinus mecanique.
                geste = rampe(0,.22,t)*(1-rampe(.28,1,t))
                retard = rampe(.06,.30,t)*(1-rampe(.34,1,t))
                p['torse'].rotation_euler.y = -.12*geste
                p['torse'].rotation_euler.x = .055*geste
                p['bras_droite'].rotation_euler.x = -.20*geste
                p['bras_droite'].rotation_euler.z -= .12*geste
                p['avant_bras_droite'].rotation_euler.x = -.26-.18*geste
                p['main_droite'].rotation_euler.x = .06+.40*geste
                p['tete'].rotation_euler.y = .10*geste
                p['bras_gauche'].rotation_euler.x = .18*retard
                p['chapeau'].rotation_euler.x = -.045*retard
            if nom == 'touche':
                choc = rampe(0,.18,t)*(1-rampe(.2,1,t))
                p['torse'].rotation_euler.x = -.22*choc
                p['tete'].rotation_euler.x = -.09*choc
                p['bras_gauche'].rotation_euler.x = -.2*choc
                p['bras_droite'].rotation_euler.x = -.2*choc
                p['avant_bras_droite'].rotation_euler.x = -.26
                p['main_droite'].rotation_euler.x = .06
                p['chapeau'].rotation_euler.x = -.07*choc
            if nom == 'mort':
                chute = rampe(.12,.85,t)
                p['racine'].rotation_euler.x = -1.48*chute
                p['racine'].location.z = .8*math.sin(1.48*chute)
                p['torse'].rotation_euler.x = .20*chute
                for cote in ['gauche','droite']:
                    p['bras_'+cote].rotation_euler.x = -.30*chute
                    p['avant_bras_'+cote].rotation_euler.x = -.35*chute
            if nom == 'victoire':
                levee = rampe(0,.32,t)*(1-rampe(.75,1,t))
                p['bras_droite'].rotation_euler.z = .18-.55*levee
                p['main_droite'].rotation_euler.z = .55*levee
                p['bras_droite'].rotation_euler.x = -.12*levee
                p['avant_bras_droite'].rotation_euler.x = -.26-.15*levee
                p['main_droite'].rotation_euler.x = .06+.27*levee
                p['torse'].rotation_euler.z = .04*math.sin(phase)*levee
                p['tete'].rotation_euler.x = -.06*levee
            bpy.context.view_layer.update()
            evalue = objet.evaluated_get(bpy.context.evaluated_depsgraph_get())
            sol = min(v.co.z for v in evalue.data.vertices)
            # Les pieds portent la course : le minimum du manteau ne pilote plus
            # la hauteur du corps image par image (cela effacait le rebond).
            if nom != 'course':
                p['racine'].location.y = -sol
            minima.append(sol)
            for os in p:
                os.keyframe_insert('rotation_euler',frame=f,group=os.name)
                os.keyframe_insert('location',frame=f,group=os.name)
                if os.name == 'torse':
                    os.keyframe_insert('scale',frame=f,group=os.name)
        action.use_fake_user = True
        if nom == 'course':
            correction = -min(minima)
            for f in range(1,duree+1):
                scene.frame_set(f)
                rig.pose.bones['racine'].location.y = correction
                rig.pose.bones['racine'].keyframe_insert('location',frame=f,group='racine')
        piste = rig.animation_data.nla_tracks.new()
        piste.name = nom
        piste.strips.new(nom,1,action)
        piste.mute = True
        controles[nom] = {'images':duree,'secondes':(duree-1)/FPS,'correction_sol_max':max(abs(v) for v in minima)}
    rig.animation_data.action = None
    repos_pose(rig)
    return controles



def verifier_course(rig):
    """Controler les articulations evaluees, pas seulement les angles demandes."""
    rig.animation_data.action = bpy.data.actions['course']
    flexions = []
    ecarts_coudes = []
    for f in range(1, CLIPS['course']+1):
        bpy.context.scene.frame_set(f)
        bpy.context.view_layer.update()
        p = rig.pose.bones
        for cote in ['gauche','droite']:
            h = p['cuisse_'+cote].head
            g = p['tibia_'+cote].head
            a = p['pied_'+cote].head
            # Dans le plan sagittal, le genou doit toujours rester vers l'avant.
            orientation = (g.y-h.y)*(a.z-g.z)-(g.z-h.z)*(a.y-g.y)
            assert orientation > .01, ('genou inverse', cote, f)
            flexions.append(math.degrees(p['tibia_'+cote].rotation_euler.x))
            ecart = abs(p['avant_bras_'+cote].head.x-p['bras_'+cote].head.x)
            assert ecart < (.105 if cote == 'droite' else .075), ('bras trop ecarte', cote, f, ecart)
            ecarts_coudes.append(ecart)
    rig.animation_data.action = None
    repos_pose(rig)
    return {'flexion_genoux_degres': [min(flexions),max(flexions)],
            'ecart_lateral_coude_epaule_max': max(ecarts_coudes)}


def main():
    bpy.ops.wm.open_mainfile(filepath=str(SOURCE/'heros_b_texture.blend'))
    bpy.context.preferences.filepaths.save_version = 0
    objet = bpy.data.objects['Heros_B_etude']
    objet.name = 'Heros_B_peau'
    rig = creer_rig(objet)
    fermer_main(objet)
    peindre_poids(objet,rig)
    controles = creer_animations(objet,rig)
    controle_course = verifier_course(rig)
    baton,main = creer_baton(rig)
    bpy.context.scene.frame_set(1)
    bpy.context.scene.frame_end = CLIPS['repos']
    bpy.ops.object.select_all(action='DESELECT')
    rig.select_set(True)
    objet.select_set(True)
    baton.select_set(True)
    main.select_set(True)
    bpy.context.view_layer.objects.active = rig
    bpy.ops.wm.save_as_mainfile(filepath=str(SOURCE/'heros_b_anime.blend'))
    bpy.ops.export_scene.gltf(filepath=str(SORTIE),export_format='GLB',use_selection=True,
        export_animations=True,export_animation_mode='NLA_TRACKS',export_skins=True,
        export_force_sampling=True,export_nla_strips=True,export_def_bones=True,
        export_anim_slide_to_zero=True)
    baton.data.calc_loop_triangles()
    main.data.calc_loop_triangles()
    rapport = {'triangles_main':len(main.data.loop_triangles), 'triangles_baton':len(baton.data.loop_triangles), 'controle_course':controle_course, 'os':len(rig.data.bones),'triangles':len(objet.data.polygons),
        'influences_max':max(len(v.groups) for v in objet.data.vertices),'animations':controles,
        'export_octets':SORTIE.stat().st_size}
    (SOURCE/'rapport_animation.json').write_text(json.dumps(rapport,indent=2)+'\n')
    rig.animation_data.action = bpy.data.actions['repos']
    bpy.context.scene.frame_set(1)
    bpy.ops.wm.save_as_mainfile(filepath=str(SOURCE/'heros_b_anime.blend'))
    print('RAPPORT_ANIMATION',json.dumps(rapport))


if __name__=='__main__':
    main()
