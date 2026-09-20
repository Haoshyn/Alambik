"""Raccord de tunique, doigts detendus et flexion anatomique du mage sculpte."""
import math
import struct
import sys
from pathlib import Path

import bpy
import bmesh

sys.path.insert(0, str(Path(__file__).resolve().parent))
from texturer_mage_reference import position_corrigee
from variantes_mage import lire_glb, ecrire_glb
from poignets_sculptes import retirer_potion, reprendre_poignets


def rampe(a, b, valeur):
    t = max(0., min(1., (valeur-a)/(b-a)))
    return t*t*(3-2*t)


def altitude(z):
    return position_corrigee((0, 0, z)).z


def reprendre_tunique(objet):
    bm = bmesh.new()
    bm.from_mesh(objet.data)
    # Couper les triangles sur le raccord, pas selon leur seul centre : sinon
    # les anciens bords restent en dents de scie sur la ceinture et les poignets.
    for point, normale in (((0,0,altitude(.66)),(0,0,1)),
                           ((0,0,altitude(1.007)),(0,0,1)),
                           ((.505,0,0),(1,0,0)),((-.505,0,0),(1,0,0))):
        region = [f for f in bm.faces if f.material_index == 0 and
                  altitude(.60) < f.calc_center_median().z < altitude(1.04)]
        geometrie = set(region)
        for f in region:
            geometrie.update(f.edges); geometrie.update(f.verts)
        bmesh.ops.bisect_plane(bm, geom=list(geometrie), dist=.000001,
                              plane_co=point, plane_no=normale)
    # Le raccord et les restes de l'echarpe se superposaient aux manches.
    # La coupe basse est cachee sous la ceinture, la coupe laterale sous le cuir.
    retrait = []
    for face in bm.faces:
        x, y, z = face.calc_center_median()
        haut = altitude(.66) < z < altitude(1.007) and abs(x) < .505
        if face.material_index == 0 and haut:
            retrait.append(face)
    bmesh.ops.delete(bm, geom=retrait, context='FACES')
    # Le pan retire laissait un petit ilot derriere la taille. Rassembler
    # virtuellement les coutures UV permet de le distinguer du bas de tunique.
    sommets_par_position = {}
    for v in bm.verts:
        sommets_par_position.setdefault(tuple(round(c,5) for c in v.co), []).append(v)
    restants = set(bm.verts)
    ilots_retires = []
    while restants:
        pile = [restants.pop()]; ilot = set(pile)
        while pile:
            v = pile.pop()
            voisins = [e.other_vert(v) for e in v.link_edges]
            voisins += sommets_par_position[tuple(round(c,5) for c in v.co)]
            for voisin in voisins:
                if voisin in restants:
                    restants.remove(voisin); ilot.add(voisin); pile.append(voisin)
        if len(ilot) < 200 and all(v.co.x < -.20 and v.co.y > .10 and
                                  altitude(.48) < v.co.z < altitude(.661) for v in ilot):
            ilots_retires.extend(ilot)
    bmesh.ops.delete(bm, geom=ilots_retires, context='VERTS')
    orphelins = [v for v in bm.verts if not v.link_faces]
    bmesh.ops.delete(bm, geom=orphelins, context='VERTS')
    bm.to_mesh(objet.data)
    bm.free()

    sommets, faces = [], []

    def anneaux(profils, manche=0):
        debut = len(sommets)
        n = 64
        for i, (position, rayon_x, rayon_y) in enumerate(profils):
            for j in range(n):
                a = math.tau*j/n
                if manche:
                    pli = .0015*math.sin(position*70+2*a)*math.sin(math.pi*i/(len(profils)-1))
                    point = (manche*position, (rayon_x+pli)*math.cos(a),
                             altitude(.878)+(rayon_y+pli)*math.sin(a))
                else:
                    # De petits plis de volume suffisent ; pas d'ombres peintes aux raccords.
                    pli = .003*math.sin(5*a+position*13)*math.sin(math.pi*i/(len(profils)-1))
                    point = ((rayon_x+pli)*math.cos(a), -.035+(rayon_y+pli)*math.sin(a), altitude(position))
                sommets.append(point)
        for i in range(len(profils)-1):
            for j in range(n):
                k = debut+i*n+j
                suivant = debut+i*n+(j+1)%n
                faces.append((k, suivant, suivant+n, k+n))
        faces.append(tuple(debut+j for j in reversed(range(n))))
        faces.append(tuple(debut+(len(profils)-1)*n+j for j in range(n)))

    anneaux(((.615,.226,.177),(.65,.235,.185),(.68,.239,.177),(.73,.246,.177),(.78,.254,.179),
             (.83,.263,.178),(.865,.266,.175),(.89,.260,.165),(.915,.240,.149),
             (.94,.196,.129),(.975,.133,.108),(1.012,.113,.096)))
    for signe in (-1, 1):
        anneaux(((.17,.087,.082),(.22,.089,.084),(.27,.088,.083),(.32,.084,.080),
                 (.37,.081,.078),(.42,.079,.076),(.47,.073,.067),(.51,.060,.053),(.535,.043,.040)), signe)
    mesh = bpy.data.meshes.new('Tunique_continue')
    mesh.from_pydata(sommets, [], faces)
    mesh.update()
    tunique = bpy.data.objects.new('Tunique_continue', mesh)
    bpy.context.collection.objects.link(tunique)
    bm = bmesh.new(); bm.from_mesh(mesh)
    bmesh.ops.recalc_face_normals(bm, faces=list(bm.faces))
    bm.to_mesh(mesh); bm.free()
    bpy.ops.object.select_all(action='DESELECT')
    tunique.select_set(True)
    bpy.context.view_layer.objects.active = tunique
    union = tunique.modifiers.new('Couture_epaules', 'REMESH')
    union.mode = 'VOXEL'; union.voxel_size = .0035; union.use_smooth_shade = True
    bpy.ops.object.modifier_apply(modifier=union.name)
    lissage = tunique.modifiers.new('Souplesse_tissu', 'SMOOTH')
    lissage.factor = .6; lissage.iterations = 6
    bpy.ops.object.modifier_apply(modifier=lissage.name)
    mat = bpy.data.materials.new('Tunique_violet_uni')
    mat.use_nodes = True
    p = mat.node_tree.nodes.get('Principled BSDF')
    p.inputs['Base Color'].default_value = (.31,.026,.67,1)
    p.inputs['Roughness'].default_value = .78
    p.inputs['Specular IOR Level'].default_value = .18
    tunique.data.materials.append(mat)
    groupes = {nom: tunique.vertex_groups.new(name=nom) for nom in
               ('bassin','torse','tete','bras_droite','avant_bras_droite','bras_gauche','avant_bras_gauche')}
    for v in tunique.data.vertices:
        x,y,z = v.co
        cote = 'gauche' if x > 0 else 'droite'
        # Un fondu continu remplace la coupure en hauteur qui tirait des pointes.
        bras = rampe(.185,.315,abs(x))*rampe(altitude(.735),altitude(.80),z)
        avant = rampe(.355,.495,abs(x))
        bassin = (1-rampe(altitude(.56),altitude(.82),z))*(1-bras)
        tete = rampe(altitude(.97),altitude(1.035),z)*(1-bras)
        poids = {'bras_'+cote: bras*(1-avant), 'avant_bras_'+cote:bras*avant,
                 'bassin':bassin, 'tete':tete, 'torse':max(0.,1-bras-bassin-tete)}
        for nom, valeur in poids.items():
            if valeur > 0: groupes[nom].add([v.index],valeur,'REPLACE')
    for face in tunique.data.polygons: face.use_smooth = True
    objet.select_set(True)
    bpy.context.view_layer.objects.active = objet
    bpy.ops.object.join()


def detendre_mains(objet):
    peau = next(i for i,m in enumerate(objet.data.materials) if m.name.startswith('Peau_cou'))
    for face in objet.data.polygons:
        x,y,z = face.center
        if abs(x) > .55 and altitude(.74) < z < altitude(1.04):
            # La projection du vetement debordait en violet sur les poignets.
            face.material_index = peau
    for v in objet.data.vertices:
        x,y,z = v.co
        if abs(x) < .595 or not altitude(.74) < z < altitude(1.04):
            continue
        # La paume est dans le plan XY ; les doigts se replient vers sa face -Z.
        # Le pouce, deja plus bas, garde une flexion plus legere.
        pouce = 1-rampe(altitude(.845),altitude(.875),z)
        depart = .662-.025*pouce
        longueur = max(0.,abs(x)-depart)
        rayon = .068+.055*pouce
        angle = longueur/rayon
        centre = altitude(.884)-.045*pouce
        epaisseur = z-centre
        v.co.x = math.copysign(depart+(rayon+epaisseur)*math.sin(angle),x) if longueur else x
        if longueur:
            v.co.z = centre+(rayon+epaisseur)*math.cos(angle)-rayon
        # Les doigts et la paume suivent le poignet ensemble, sans etirement individuel.
        cote = 'gauche' if x>0 else 'droite'
        main = rampe(.585,.635,abs(x))
        for groupe in objet.vertex_groups: groupe.remove([v.index])
        objet.vertex_groups['main_'+cote].add([v.index],main,'REPLACE')
        objet.vertex_groups['avant_bras_'+cote].add([v.index],1-main,'REPLACE')


def corriger_coudes(chemin):
    doc, binaire = lire_glb(chemin)
    binaire = bytearray(binaire)
    corriges = set()
    for animation in doc.get('animations',[]):
        for canal in animation['channels']:
            cible = canal['target']
            nom = doc['nodes'][cible['node']].get('name','')
            if cible['path'] != 'rotation' or not nom.startswith('avant_bras_'): continue
            index = animation['samplers'][canal['sampler']]['output']
            if index in corriges: continue
            corriges.add(index)
            acc = doc['accessors'][index]
            vue = doc['bufferViews'][acc['bufferView']]
            depart = vue.get('byteOffset',0)+acc.get('byteOffset',0)
            pas = vue.get('byteStride',16)
            # Les bras de liaison pointent vers +/-X : le signe de Y etait inverse.
            for i in range(acc['count']):
                adresse = depart+i*pas+4
                valeur = struct.unpack_from('<f',binaire,adresse)[0]
                struct.pack_into('<f',binaire,adresse,-valeur)
            if 'min' in acc and 'max' in acc:
                acc['min'][1], acc['max'][1] = -acc['max'][1], -acc['min'][1]
    doc.setdefault('extras', {})['vetement_sculpte_revision'] = 2
    ecrire_glb(chemin, doc, binaire)


def finaliser(chemin):
    doc, _ = lire_glb(chemin)
    if doc.get('extras', {}).get('vetement_sculpte_revision') == 2:
        return
    if doc.get('extras', {}).get('vetement_sculpte_revision'):
        raise ValueError('Repartir du GLB avant retouches, pas d une revision deja deformee.')
    bpy.ops.wm.read_factory_settings(use_empty=True)
    bpy.ops.import_scene.gltf(filepath=str(chemin))
    objet = bpy.data.objects['Mage_sculpte']
    rig = next(o for o in bpy.context.scene.objects if o.type == 'ARMATURE')
    retirer_potion(objet)
    reprendre_tunique(objet)
    detendre_mains(objet)
    reprendre_poignets(objet,rig)
    bpy.ops.object.select_all(action='DESELECT')
    objet.select_set(True); rig.select_set(True)
    bpy.context.view_layer.objects.active = rig
    bpy.ops.export_scene.gltf(filepath=str(chemin),export_format='GLB',use_selection=True,
        export_animations=True,export_animation_mode='NLA_TRACKS',export_force_sampling=True,export_skins=True)
    corriger_coudes(chemin)


if __name__ == '__main__':
    chemin = Path(sys.argv[sys.argv.index('--')+1]).resolve()
    finaliser(chemin)
