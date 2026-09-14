"""Variante de l'accueil : sculpture separee, rig et gestes de l'apprenti conserves."""
import importlib.util
import json
import math
import shutil
from pathlib import Path

import bpy
from mathutils import Vector

RACINE = Path(__file__).resolve().parents[2]
DOSSIER = RACINE / 'tmp/apprenti-accueil'
spec = importlib.util.spec_from_file_location('socle_apprenti', Path(__file__).with_name('apprenti_a.py'))
socle = importlib.util.module_from_spec(spec)
spec.loader.exec_module(socle)


def retirer(prefixes):
    for objet in list(bpy.context.scene.objects):
        if objet.type == 'MESH' and objet.name.startswith(prefixes):
            bpy.data.objects.remove(objet, do_unlink=True)


def couleur(nom, teinte, rugosite=.65):
    mat = socle.MAT[nom]
    mat.diffuse_color = (*teinte, 1)
    shader = mat.node_tree.nodes.get('Principled BSDF')
    shader.inputs['Base Color'].default_value = (*teinte, 1)
    shader.inputs['Roughness'].default_value = rugosite


def surface_visage(x, z, relief=.003):
    hauteur = (z-1.66)/.435
    if hauteur < -.25:
        hauteur = -.25+(hauteur+.25)/.77
    profondeur = .475*1.12/1.10
    return -.018-profondeur*math.sqrt(max(.01,1-(x/.475)**2-hauteur**2))-relief


def pastille(nom, x, z, largeur, hauteur, matiere, relief):
    # Une surface courbe plaque les yeux sur la peau, sans empiler des billes.
    n = 40
    points = [(x,surface_visage(x,z,relief),z)]
    faces = []
    for anneau in range(1,7):
        rayon = anneau/6
        for i in range(n):
            angle = math.tau*i/n
            px,pz = x+largeur*rayon*math.cos(angle),z+hauteur*rayon*math.sin(angle)
            points.append((px,surface_visage(px,pz,relief),pz))
    for i in range(n):
        faces.append((0,1+i,1+(i+1)%n))
    for anneau in range(5):
        for i in range(n):
            a=1+anneau*n+i
            b=1+anneau*n+(i+1)%n
            faces.append((a,a+n,b+n,b))
    maillage = bpy.data.meshes.new(nom)
    maillage.from_pydata(points,[],faces)
    maillage.update()
    objet=bpy.data.objects.new(nom,maillage)
    bpy.context.collection.objects.link(objet)
    socle.finir(objet,nom,matiere,'tete')


def sculpter():
    socle.construire()
    socle.resculpter()
    for nom, teinte in {
        'violet': (.32,.085,.52), 'violet_clair': (.43,.14,.62),
        'turquoise': (.025,.48,.60), 'turquoise_clair': (.10,.64,.70),
        'peau': (.96,.66,.43), 'cheveux': (.105,.049,.029),
        'cheveux_clair': (.17,.074,.044), 'cuir': (.16,.073,.042),
        'cuivre': (.83,.45,.15), 'orbe': (.47,.08,.80),
    }.items():
        couleur(nom, teinte)
    socle.matiere('blanc_oeil', (.97,.89,.78), 0, .34)
    socle.matiere('iris', (.18,.068,.033), 0, .27)
    socle.matiere('sourire', (.28,.085,.052), 0, .72)
    retirer(('Oeil', 'Reflet_oeil', 'Meche_', 'Patte', 'Pan_echarpe'))

    # Les yeux suivent la courbure du visage ; le blanc reste un liseret,
    # avec une iris brune et deux reflets plutot que des points noirs.
    for signe in [-1, 1]:
        x = signe*.175
        pastille('Contour_oeil',x,1.645,.078,.109,'cheveux',.004)
        pastille('Blanc_oeil',x,1.643,.071,.100,'blanc_oeil',.007)
        pastille('Iris',x+.008,1.641,.059,.090,'iris',.010)
        pastille('Pupille',x+.011,1.659,.039,.065,'yeux',.013)
        pastille('Reflet_grand',x-.011,1.69,.018,.023,'reflet',.016)
        pastille('Reflet_petit',x+.028,1.611,.007,.009,'reflet',.016)
        socle.courbe('Sourcil', [(px,surface_visage(px,pz,.003),pz) for px,pz in [(x-.056,1.812),(x-.005,1.829),(x+.049,1.818)]], .010, 'cheveux', 'tete')
    socle.boule('Nez', (0,-.489,1.555), (.037,.036,.027), 'peau', 'tete')
    socle.courbe('Sourire', [(px,surface_visage(px,pz,.003),pz) for px,pz in [(-.064,1.484),(-.031,1.467),(.013,1.466),(.061,1.491)]], .005, 'sourire', 'tete')
    for nom, points, largeur in [
        ('Frange_centrale',[(-.29,-.29,2.03),(-.16,-.425,1.982),(.005,-.485,1.925),(.102,-.449,1.818)],.14),
        ('Frange_droite',[(-.04,-.33,2.065),(.15,-.397,2.023),(.31,-.354,1.974),(.39,-.279,1.878)],.13),
        ('Frange_gauche',[(-.26,-.225,2.03),(-.38,-.31,1.947),(-.415,-.30,1.825),(-.38,-.29,1.765)],.115),
        ('Tempe_gauche',[(-.40,-.03,1.95),(-.46,-.13,1.79),(-.43,-.22,1.61),(-.35,-.25,1.53)],.087),
        ('Tempe_droite',[(.40,-.03,1.95),(.46,-.13,1.79),(.43,-.22,1.61),(.35,-.25,1.53)],.087),
    ]:
        socle.meche(nom, points, largeur)

    for objet in bpy.context.scene.objects:
        if objet.type != 'MESH':
            continue
        if objet.name.startswith(('Bord_chapeau','Chapeau_souple','Ruban_chapeau','Boucle_chapeau','Fond_boucle_chapeau')):
            for sommet in objet.data.vertices:
                x,y,z = sommet.co
                sommet.co.z += .115*x-.06*(y-.035)
                if objet.name.startswith('Chapeau_souple') and z > 2.28:
                    sommet.co.x -= .11*min(1, (z-2.28)/.25)

    # Un pan volumique qui s'ouvre sur le cote rappelle le tissu de l'affiche.
    profils = [(-.255,.085,1.245,.06),(-.36,.17,1.22,.085),
               (-.52,.22,1.24,.115),(-.70,.20,1.29,.105),(-.81,.17,1.27,.085)]
    points, faces = [], []
    for x,y,z,largeur in profils:
        points.extend([(x,y-.022,z-largeur),(x,y-.022,z+largeur),
                       (x,y+.022,z+largeur),(x,y+.022,z-largeur)])
    for j in range(len(profils)-1):
        for i in range(4):
            faces.append((j*4+i,j*4+(i+1)%4,(j+1)*4+(i+1)%4,(j+1)*4+i))
    faces.extend([(3,2,1,0),(16,17,18,19)])
    maillage = bpy.data.meshes.new('Pan_accueil')
    maillage.from_pydata(points, [], faces)
    maillage.update()
    objet = bpy.data.objects.new('Pan_echarpe_accueil', maillage)
    bpy.context.collection.objects.link(objet)
    socle.finir(objet, objet.name, 'turquoise', 'echarpe')
    socle.galber(objet)
    for i in range(4):
        z = 1.21+i*.037
        socle.courbe('Frange_echarpe', [(-.765,.17,z),(-.81,.15,z+.01),(-.86,.14,z+.005)], .012, 'turquoise', 'echarpe')


def studio():
    scene = bpy.context.scene
    scene.render.engine = 'CYCLES'
    scene.cycles.samples = 32
    scene.cycles.use_denoising = True
    scene.render.resolution_x = 900
    scene.render.resolution_y = 1100
    scene.render.resolution_percentage = 100
    scene.world = bpy.data.worlds.new('Studio_accueil')
    scene.world.use_nodes = True
    scene.world.node_tree.nodes['Background'].inputs[0].default_value = (.18,.15,.28,1)
    scene.world.node_tree.nodes['Background'].inputs[1].default_value = .5
    socle.matiere('studio', (.115,.085,.17), 0, .95)
    bpy.ops.mesh.primitive_plane_add(size=200, location=(0,0,-.015))
    socle.finir(bpy.context.object, 'Sol_studio', 'studio', None)
    for nom, position, energie, teinte in [
        ('Cle',(-3,-4,6),550,(1,.88,.77)),
        ('Remplissage',(3,-2,3),300,(.76,.88,1)),
        ('Contour',(0,3,4),600,(.80,.65,1)),
    ]:
        lumiere = bpy.data.lights.new(nom, 'AREA')
        lumiere.energy = energie
        lumiere.shape = 'DISK'
        lumiere.size = 4
        lumiere.color = teinte
        objet = bpy.data.objects.new(nom, lumiere)
        scene.collection.objects.link(objet)
        objet.location = position
        objet.rotation_euler = (Vector((0,0,1))-objet.location).to_track_quat('-Z','Y').to_euler()
    camera = bpy.data.cameras.new('Camera_accueil')
    objet = bpy.data.objects.new('Camera_accueil', camera)
    scene.collection.objects.link(objet)
    camera.type = 'ORTHO'
    camera.ortho_scale = 2.7
    scene.camera = objet
    scene.view_settings.view_transform = 'AgX'
    socle.RIG.animation_data.action = None
    for piste in socle.RIG.animation_data.nla_tracks:
        piste.mute = True
    for os in socle.RIG.pose.bones:
        os.rotation_euler = (0,0,0)
        os.location = (0,0,0)
        os.scale = (1,1,1)
    for nom, position in [('trois-quarts',(2.3,-6,3)),('face',(0,-6,2.2)),('combat',(0,-5,6))]:
        objet.location = position
        objet.rotation_euler = (Vector((0,0,1.02))-objet.location).to_track_quat('-Z','Y').to_euler()
        scene.render.filepath = str(DOSSIER/(nom+'.png'))
        bpy.ops.render.render(write_still=True)


if __name__ == '__main__':
    bpy.ops.wm.read_factory_settings(use_empty=True)
    bpy.context.preferences.filepaths.save_version = 0
    DOSSIER.mkdir(parents=True, exist_ok=True)
    (DOSSIER/'.gdignore').touch()
    # L'exporteur historique ecrit exclusivement dans un dossier temporaire.
    # Les fichiers apprenti_a.blend et apprenti_a.glb du projet restent intacts.
    socle.SORTIE = DOSSIER/'export'
    socle.APERCU = DOSSIER
    (socle.SORTIE/'characters').mkdir(parents=True, exist_ok=True)
    sculpter()
    socle.exporter()
    for source, destination in [
        ('characters/apprenti_a.glb','characters/apprenti_accueil.glb'),
        ('sources/characters/apprenti_a.blend','sources/characters/apprenti_accueil.blend'),
    ]:
        shutil.copy2(socle.SORTIE/source, RACINE/'assets/3d'/destination)
    studio()
