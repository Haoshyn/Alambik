"""Aster chibi : nouveau heros original, style jeu mobile, sur le squelette d'Aster.

Reprend le squelette et les huit actions de `assets/3d/sources/characters/aster/aster.blend`,
raccourcit le squelette en proportions chibi, puis construit des volumes originaux
(tete ronde, grands yeux, corps en poire, chapeau, robe) dans une palette vive.

Utilisation (sans fenetre) :
  blender --background assets/3d/sources/characters/aster/aster.blend \
      --python tools/blender/heros_chibi.py -- <dossier_sortie> [--apercu] [--exporter]
"""
import math
import sys
from pathlib import Path

import bpy
import bmesh
from mathutils import Matrix, Vector

RACINE = Path(__file__).resolve().parents[2]
ARGS = sys.argv[sys.argv.index("--") + 1:] if "--" in sys.argv else []
SORTIE = Path(ARGS[0]) if ARGS else RACINE / "tmp/heros_chibi"

# Squelette : echelle d'ensemble depuis la racine, puis membres plus courts.
ECHELLE_CORPS = .56
ECHELLES_OS = {"Thigh.L": .8, "Thigh.R": .8, "UpperArm.L": .82, "UpperArm.R": .82,
               "Spine": .9, "CoatBack.L": .8, "CoatBack.R": .8, "CoatFront.L": .8, "CoatFront.R": .8}

# Palette vive : violet roi, or, turquoise, corail ; peau chaude.
PALETTE = {
    "Peau": (1.0, .84, .72), "Joue": (1.0, .55, .60), "Cheveux": (.70, .86, 1.0),
    "Chapeau": (.42, .20, .95), "Bord": (.30, .13, .78), "Ruban": (1.0, .72, .18),
    "Robe": (.20, .42, 1.0), "Doublure": (1.0, .78, .25), "Col": (.98, .96, 1.0),
    "Ceinture": (.55, .25, .12), "Bottes": (.36, .18, .10), "Gants": (.98, .96, 1.0),
    "Oeil": (.22, .10, .50), "Reflet": (1.0, 1.0, 1.0), "Bouche": (.55, .15, .20),
    "Gem": (.25, 1.0, .95), "Gold": (1.0, .78, .25),
}


def os_actions():
    for action in bpy.data.actions:
        if hasattr(action, "layers") and action.layers:
            for couche in action.layers:
                for bande in couche.strips:
                    for sac in bande.channelbags:
                        yield action, sac.fcurves
        elif hasattr(action, "fcurves"):
            yield action, action.fcurves


def preparer_squelette():
    rig = bpy.data.objects["Aster_Rig"]
    gardes = {"Aster_Wand", "Aster_Grimoire"}
    for objet in list(bpy.data.objects):
        if objet.type == "MESH" and objet.name not in gardes:
            bpy.data.objects.remove(objet, do_unlink=True)
    for objet in list(bpy.data.objects):
        if objet.type in {"CAMERA", "LIGHT"}:
            bpy.data.objects.remove(objet, do_unlink=True)
    # Pose de repos neutre, puis echelles chibi.
    rig.animation_data.action = None
    for piste in rig.animation_data.nla_tracks: piste.mute = True
    for os_ in rig.pose.bones:
        os_.location = (0, 0, 0); os_.rotation_quaternion = (1, 0, 0, 0); os_.scale = (1, 1, 1)
    rig.pose.bones["Root"].scale = Vector((1, 1, 1)) * ECHELLE_CORPS
    for nom, valeur in ECHELLES_OS.items():
        rig.pose.bones[nom].scale = Vector((1, 1, 1)) * valeur
    # Les cuisses raccourcies remontent les pieds : les hanches descendent d'autant.
    cuisse = rig.data.bones["Thigh.L"]; pied = rig.data.bones["Foot.L"]
    perte = (cuisse.head_local.z - pied.head_local.z) * (1 - ECHELLES_OS["Thigh.L"])
    rig.pose.bones["Hips"].location.y = -perte
    bpy.context.view_layer.update()
    # Baguette, grimoire et reperes suivent leur os avant le nouveau repos.
    for nom in gardes:
        objet = bpy.data.objects[nom]
        bpy.context.view_layer.objects.active = objet
        for mod in list(objet.modifiers):
            if mod.type == "ARMATURE": bpy.ops.object.modifier_apply(modifier=mod.name)
    baguette = rig.pose.bones["Wand"]
    passage = rig.matrix_world @ baguette.matrix @ rig.data.bones["Wand"].matrix_local.inverted() @ rig.matrix_world.inverted()
    for nom in ("Aster_PriseArme", "Aster_PointeBaguette"):
        repere = bpy.data.objects[nom]
        repere.matrix_world = passage @ repere.matrix_world
    bpy.ops.object.select_all(action="DESELECT")
    bpy.context.view_layer.objects.active = rig
    rig.select_set(True)
    bpy.ops.object.mode_set(mode="POSE")
    bpy.ops.pose.armature_apply(selected=False)
    bpy.ops.object.mode_set(mode="OBJECT")
    for nom in gardes:
        objet = bpy.data.objects[nom]
        mod = objet.modifiers.new("Armature", "ARMATURE"); mod.object = rig
    # Les deplacements animes etaient exprimes pour le grand squelette.
    for _action, courbes in os_actions():
        for courbe in courbes:
            if courbe.data_path.endswith("location"):
                for cle in courbe.keyframe_points:
                    cle.co[1] *= ECHELLE_CORPS
                    cle.handle_left[1] *= ECHELLE_CORPS
                    cle.handle_right[1] *= ECHELLE_CORPS
    return rig


def lineaire(c):
    # La palette est notee en couleurs affichees ; Blender et glTF attendent du lineaire.
    return tuple(x / 12.92 if x <= .04045 else ((x + .055) / 1.055) ** 2.4 for x in c)


def matiere(nom, couleur, rugosite=.55, emission=0.0):
    # Les matieres d'Aster portent deja certains noms : la nouvelle les remplace.
    ancienne = bpy.data.materials.get(nom)
    if ancienne is not None: ancienne.name = nom + "_ancienne"
    mat = bpy.data.materials.new(nom)
    mat.use_nodes = True
    bsdf = next(n for n in mat.node_tree.nodes if n.type == "BSDF_PRINCIPLED")
    couleur = lineaire(couleur)
    bsdf.inputs["Base Color"].default_value = (*couleur, 1)
    bsdf.inputs["Roughness"].default_value = rugosite
    if emission:
        bsdf.inputs["Emission Color"].default_value = (*couleur, 1)
        bsdf.inputs["Emission Strength"].default_value = emission
    mat.diffuse_color = (*couleur, 1)
    return mat


def tete_os(rig, nom):
    return rig.matrix_world @ rig.data.bones[nom].head_local


def objet_maillage(nom, bm, mat, rig, os_nom, lisse=True):
    maillage = bpy.data.meshes.new(nom)
    # UV cylindriques : Godot en a besoin pour les tangentes, sans texture peinte.
    couche = bm.loops.layers.uv.new("UVMap")
    for face in bm.faces:
        for boucle in face.loops:
            p = boucle.vert.co
            boucle[couche].uv = (math.atan2(p.y, p.x) / (2 * math.pi) + .5, p.z)
    bm.to_mesh(maillage); bm.free()
    objet = bpy.data.objects.new(nom, maillage)
    bpy.context.scene.collection.objects.link(objet)
    maillage.materials.append(mat)
    if lisse:
        for face in maillage.polygons: face.use_smooth = True
    groupe = objet.vertex_groups.new(name=os_nom)
    groupe.add(list(range(len(maillage.vertices))), 1.0, "REPLACE")
    objet.parent = rig
    mod = objet.modifiers.new("Armature", "ARMATURE"); mod.object = rig
    return objet


def sphere(centre, rayons, segments=32, anneaux=16):
    bm = bmesh.new()
    bmesh.ops.create_uvsphere(bm, u_segments=segments, v_segments=anneaux, radius=1.0)
    for v in bm.verts:
        v.co = Vector((v.co.x * rayons[0], v.co.y * rayons[1], v.co.z * rayons[2])) + Vector(centre)
    return bm


def capsule(a, b, rayon, segments=20):
    a, b = Vector(a), Vector(b)
    axe = b - a
    bm = bmesh.new()
    bmesh.ops.create_uvsphere(bm, u_segments=segments, v_segments=12, radius=1.0)
    rotation = Vector((0, 0, 1)).rotation_difference(axe.normalized()).to_matrix()
    for v in bm.verts:
        z = v.co.z
        p = Vector((v.co.x * rayon, v.co.y * rayon, z * rayon))
        p.z += axe.length * (1 if z > 0 else 0)
        v.co = a + rotation @ p
    return bm


def ebauche(rig):
    """Volumes simples pour valider la silhouette et les couleurs."""
    m = {nom: matiere(nom, c) for nom, c in PALETTE.items()}
    tete = tete_os(rig, "Head")
    cou = tete_os(rig, "Neck")
    hanches = tete_os(rig, "Hips")
    rayon_tete = .26
    centre_tete = tete + Vector((0, -.01, rayon_tete * .78))
    objet_maillage("Ebauche_Tete", sphere(centre_tete, (rayon_tete, rayon_tete * .95, rayon_tete * .92)), m["Peau"], rig, "Head")
    objet_maillage("Ebauche_Cheveux", sphere(centre_tete + Vector((0, .03, .05)), (rayon_tete * 1.05, rayon_tete * 1.0, rayon_tete * .86)), m["Cheveux"], rig, "Head")
    for cote in (-1, 1):
        oeil = centre_tete + Vector((cote * .095, -rayon_tete * .9, -.02))
        objet_maillage(f"Ebauche_Oeil_{cote}", sphere(oeil, (.045, .02, .062)), m["Oeil"], rig, "Head")
        objet_maillage(f"Ebauche_Reflet_{cote}", sphere(oeil + Vector((-.012, -.016, .022)), (.014, .008, .016)), m["Reflet"], rig, "Head")
    # Corps en poire, du cou aux chevilles.
    bm = bmesh.new()
    bmesh.ops.create_cone(bm, cap_ends=True, segments=28, radius1=.25, radius2=.13, depth=cou.z - .05)
    for v in bm.verts: v.co.z += (cou.z - .05) * .5 + .05
    objet_maillage("Ebauche_Robe", bm, m["Robe"], rig, "Spine")
    # Chapeau : bord large et pointe recourbee.
    bm = bmesh.new()
    bmesh.ops.create_cone(bm, cap_ends=True, segments=36, radius1=.40, radius2=.40, depth=.03)
    for v in bm.verts: v.co += centre_tete + Vector((0, 0, rayon_tete * .62))
    objet_maillage("Ebauche_Bord", bm, m["Bord"], rig, "Head")
    bm = bmesh.new()
    bmesh.ops.create_cone(bm, cap_ends=True, segments=36, radius1=.22, radius2=.0, depth=.42)
    for v in bm.verts:
        t = (v.co.z + .21) / .42
        v.co.x += t * t * .12
        v.co += centre_tete + Vector((0, 0, rayon_tete * .62 + .21))
    objet_maillage("Ebauche_Chapeau", bm, m["Chapeau"], rig, "Head")
    # Bras et jambes trapus, mains en moufles, grosses bottes.
    for cote, suffixe in ((1, "L"), (-1, "R")):
        epaule = tete_os(rig, f"UpperArm.{suffixe}"); coude = tete_os(rig, f"Forearm.{suffixe}"); main = tete_os(rig, f"Hand.{suffixe}")
        objet_maillage(f"Ebauche_Bras_{suffixe}", capsule(epaule, coude, .055), m["Robe"], rig, f"UpperArm.{suffixe}")
        objet_maillage(f"Ebauche_AvantBras_{suffixe}", capsule(coude, main, .05), m["Robe"], rig, f"Forearm.{suffixe}")
        objet_maillage(f"Ebauche_Main_{suffixe}", sphere(main + Vector((cote * .03, 0, 0)), (.055, .05, .05)), m["Gants"], rig, f"Hand.{suffixe}")
        hanche = tete_os(rig, f"Thigh.{suffixe}"); genou = tete_os(rig, f"Shin.{suffixe}"); cheville = tete_os(rig, f"Foot.{suffixe}")
        objet_maillage(f"Ebauche_Cuisse_{suffixe}", capsule(hanche, genou, .06), m["Robe"], rig, f"Thigh.{suffixe}")
        objet_maillage(f"Ebauche_Jambe_{suffixe}", capsule(genou, cheville, .055), m["Bottes"], rig, f"Shin.{suffixe}")
        objet_maillage(f"Ebauche_Botte_{suffixe}", sphere(cheville + Vector((0, -.04, -.03)), (.07, .1, .055)), m["Bottes"], rig, f"Foot.{suffixe}")


def revolution(profil, segments=32, centre=(0, 0, 0), aplati=1.0, ferme_bas=True, ferme_haut=True):
    """Surface de revolution : profil = [(rayon, z), ...] de bas en haut."""
    bm = bmesh.new()
    anneaux = []
    for rayon, z in profil:
        anneau = []
        for i in range(segments):
            angle = 2 * math.pi * i / segments
            anneau.append(bm.verts.new(Vector((math.cos(angle) * rayon, math.sin(angle) * rayon * aplati, z)) + Vector(centre)))
        anneaux.append(anneau)
    for a, b in zip(anneaux, anneaux[1:]):
        for i in range(segments):
            bm.faces.new((a[i], a[(i + 1) % segments], b[(i + 1) % segments], b[i]))
    if ferme_bas: bm.faces.new(list(reversed(anneaux[0])))
    if ferme_haut: bm.faces.new(anneaux[-1])
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    return bm


def tore(centre, rayon, epaisseur, aplati=1.0, segments=36, cotes=10):
    bm = bmesh.new()
    anneaux = []
    for i in range(segments):
        a = 2 * math.pi * i / segments
        anneau = []
        for j in range(cotes):
            b = 2 * math.pi * j / cotes
            r = rayon + math.cos(b) * epaisseur
            anneau.append(bm.verts.new(Vector((math.cos(a) * r, math.sin(a) * r * aplati, math.sin(b) * epaisseur)) + Vector(centre)))
        anneaux.append(anneau)
    for i in range(segments):
        a, b = anneaux[i], anneaux[(i + 1) % segments]
        for j in range(cotes):
            bm.faces.new((a[j], b[j], b[(j + 1) % cotes], a[(j + 1) % cotes]))
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    return bm


def fusionner(*bms):
    total = bmesh.new()
    for bm in bms:
        maillage = bpy.data.meshes.new("tmp"); bm.to_mesh(maillage); bm.free()
        total.from_mesh(maillage); bpy.data.meshes.remove(maillage)
    return total


def lisser(objet, niveaux=1):
    mod = objet.modifiers.new("Lissage", "SUBSURF"); mod.levels = niveaux; mod.render_levels = niveaux
    # Le lissage passe avant le squelette pour que l'export garde les poids.
    objet.modifiers.move(len(objet.modifiers) - 1, 0)


def ponderer(objet, fonction):
    """fonction(position) -> {os: poids} ; remplace les poids rigides."""
    for groupe in list(objet.vertex_groups): objet.vertex_groups.remove(groupe)
    groupes = {}
    for v in objet.data.vertices:
        poids = fonction(objet.matrix_world @ v.co)
        total = sum(poids.values()) or 1.0
        for nom, valeur in poids.items():
            if valeur <= 0: continue
            if nom not in groupes: groupes[nom] = objet.vertex_groups.new(name=nom)
            groupes[nom].add([v.index], valeur / total, "REPLACE")


def lisse01(a, b, x):
    t = max(0.0, min(1.0, (x - a) / (b - a)))
    return t * t * (3 - 2 * t)


def modele(rig):
    m = {nom: matiere(nom, c) for nom, c in PALETTE.items()}
    m["Face"] = matiere("Face", PALETTE["Oeil"])
    m["Gem"] = matiere("Gem", PALETTE["Gem"], .2, .6)
    m["Gold"] = matiere("Gold", PALETTE["Gold"], .3)
    tete = tete_os(rig, "Head")
    cou = tete_os(rig, "Neck")
    hanches = tete_os(rig, "Hips")
    poitrine = tete_os(rig, "UpperChest")
    rt = .27
    ct = tete + Vector((0, -.005, rt * .80))
    face_y = ct.y - rt * .93

    # Tete ronde, un peu plus large que haute : la silhouette d'un jouet.
    objet_maillage("Aster_Head", sphere(ct, (rt * 1.04, rt * .97, rt * .94), 40, 24), m["Peau"], rig, "Head")
    # Cheveux : calotte arriere et meches avant en pointes arrondies.
    calotte = sphere(ct + Vector((0, .025, .035)), (rt * 1.09, rt * 1.04, rt * .93), 40, 24)
    for v in list(calotte.verts):
        if v.co.z < ct.z - rt * .25 and v.co.y < ct.y + .02: calotte.verts.remove(v)
        elif v.co.y < ct.y - rt * .45 and v.co.z < ct.z + rt * .28: calotte.verts.remove(v)
    meches = []
    for i, (x, longueur, inclinaison) in enumerate([(-.17, .17, -.9), (.0, .15, .35), (.17, .17, .9)]):
        base = Vector((ct.x + x * .8, face_y + .1, ct.z + rt * .62))
        pointe = Vector((ct.x + x + inclinaison * .05, face_y + .035, ct.z + rt * .62 - longueur))
        meches.append(revolution([(.0, 0), (.06, .2), (.1, .5), (.09, .8), (.05, 1.0)], 20, aplati=.45))
        rotation = Vector((0, 0, 1)).rotation_difference((base - pointe).normalized()).to_matrix()
        for v in meches[-1].verts:
            v.co = pointe + rotation @ Vector((v.co.x, v.co.y, v.co.z * (base - pointe).length))
    cheveux = objet_maillage("Aster_Hair", fusionner(calotte, *meches), m["Cheveux"], rig, "Head")
    lisser(cheveux)

    # Visage : grands yeux ovales a double reflet, joues et petite bouche.
    elements = []
    def surface(dx, dz, avance=0.0):
        # Point du devant de la tete (ellipsoide) a un decalage donne du centre.
        rx, ry, rz = rt * 1.04, rt * .97, rt * .94
        reste = max(0.0, 1 - (dx / rx) ** 2 - (dz / rz) ** 2)
        return Vector((ct.x + dx, ct.y - ry * math.sqrt(reste) - avance, ct.z + dz))
    for cote in (-1, 1):
        oeil = surface(cote * .105, -.03, .012)
        elements.append(sphere(oeil, (.064, .03, .09), 24, 12))
        elements.append(sphere(oeil + Vector((-cote * .016 - .008, -.026, .034)), (.022, .008, .026), 12, 6))
        elements.append(sphere(oeil + Vector((cote * .014 + .006, -.026, -.034)), (.011, .006, .012), 10, 5))
        elements.append(sphere(surface(cote * .175, -.115, -.002), (.045, .012, .024), 16, 8))
    elements.append(sphere(surface(0, -.135, -.002), (.024, .008, .012), 16, 8))
    visage = objet_maillage("Aster_Face", fusionner(*elements), m["Face"], rig, "Head")
    attribuer_matieres_visage(visage, m)
    expressions(visage, ct, face_y)

    # Chapeau : bord resserre, pointe recourbee vers l'arriere, ruban et etoile.
    base_chapeau = ct.z + rt * .58
    bord = revolution([(.0, -.012), (.31, -.012), (.335, .0), (.31, .016), (.0, .016)], 48, (ct.x, ct.y + .01, base_chapeau))
    objet_maillage("Aster_Hat_Bord", bord, m["Bord"], rig, "Head")
    cone = revolution([(.205, 0), (.19, .08), (.15, .2), (.10, .32), (.055, .42), (.02, .5), (.0, .53)], 32, (0, 0, 0), ferme_bas=True, ferme_haut=False)
    for v in cone.verts:
        t = v.co.z / .53
        v.co = Vector((ct.x, ct.y + .02, base_chapeau + .01)) + Vector((v.co.x, v.co.y, v.co.z * .95)) + Vector((0, t ** 2 * .22, -t ** 3 * .12))
    chapeau = objet_maillage("Aster_Hat", cone, m["Chapeau"], rig, "Head")
    lisser(chapeau)
    objet_maillage("Aster_Hat_Ruban", tore((ct.x, ct.y + .02, base_chapeau + .05), .19, .028), m["Ruban"], rig, "Head")
    etoile = bmesh.new()
    sommets = []
    for i in range(10):
        angle = math.pi / 2 + i * math.pi / 5
        r = .07 if i % 2 == 0 else .03
        sommets.append(etoile.verts.new(Vector((math.cos(angle) * r, 0, math.sin(angle) * r))))
    face = etoile.faces.new(sommets)
    bmesh.ops.extrude_face_region(etoile, geom=[face])
    etoile.verts.ensure_lookup_table()
    for v in etoile.verts[10:]: v.co.y += .03
    bmesh.ops.recalc_face_normals(etoile, faces=etoile.faces)
    pointe_chapeau = Vector((ct.x, ct.y + .02 + .22, base_chapeau + .01 + .53 * .95 - .12))
    for v in etoile.verts: v.co += pointe_chapeau + Vector((0, -.015, .02))
    objet_maillage("Aster_Hat_Etoile", etoile, m["Gold"], rig, "Head", lisse=False)
    objet_maillage("Aster_Hat_Gem", sphere((ct.x, ct.y + .02 - .215, base_chapeau + .05), (.035, .02, .042), 16, 8), m["Gem"], rig, "Head")

    # Robe en poire : epaules etroites, ventre rond, ourlet evase.
    sol = .045
    profil = [(.235, sol + .06), (.25, sol + .09), (.245, hanches.z - .06), (.215, hanches.z + .04),
              (.165, poitrine.z - .02), (.12, cou.z - .04), (.085, cou.z + .005)]
    robe = objet_maillage("Aster_Body", revolution(profil, 36, (0, 0, 0), .86), m["Robe"], rig, "Spine")
    lisser(robe)
    ponderer(robe, lambda p: poids_robe(p, hanches, poitrine))
    ourlet = objet_maillage("Aster_Ourlet", tore((0, 0, sol + .075), .245, .03, .86), m["Doublure"], rig, "Hips")
    ponderer(ourlet, lambda p: poids_robe(p, hanches, poitrine))
    objet_maillage("Aster_Col", tore((0, 0, cou.z - .03), .125, .045, .9), m["Col"], rig, "UpperChest")
    objet_maillage("Aster_Ceinture", tore((0, 0, hanches.z + .02), .225, .028, .86), m["Ceinture"], rig, "Hips")
    objet_maillage("Aster_Boucle", sphere((0, -.2, hanches.z + .02), (.045, .02, .04), 16, 8), m["Gold"], rig, "Hips")
    # Cape courte en dos, sur les os de cape.
    cape = revolution([(.21, hanches.z - .02), (.19, poitrine.z), (.13, cou.z - .02)], 24, (0, .025, 0), .9, False, False)
    for v in list(cape.verts):
        if v.co.y < .02: cape.verts.remove(v)
    cape_objet = objet_maillage("Aster_Cape", cape, m["Doublure"], rig, "UpperChest")
    ponderer(cape_objet, lambda p: {"UpperChest": lisse01(hanches.z, cou.z, p.z), "Cape.L" if p.x > 0 else "Cape.R": 1 - lisse01(hanches.z, cou.z, p.z)})

    # Bras trapus, grands revers, moufles ; jambes courtes et grosses bottes.
    for cote, s in ((1, "L"), (-1, "R")):
        epaule = tete_os(rig, f"UpperArm.{s}"); coude = tete_os(rig, f"Forearm.{s}"); main = tete_os(rig, f"Hand.{s}")
        bras = objet_maillage(f"Aster_Bras_{s}", fusionner(capsule(epaule, coude, .07), capsule(coude, main - (main - coude) * .15, .066)), m["Robe"], rig, f"UpperArm.{s}")
        ponderer(bras, lambda p, e=epaule, c=coude, s=s: {f"UpperArm.{s}": 1 - lisse01(-.03, .03, (p - c).dot((c - e).normalized())), f"Forearm.{s}": lisse01(-.03, .03, (p - c).dot((c - e).normalized()))})
        # Manche bouffante : l'epaule reste lisible quand les bras pendent.
        objet_maillage(f"Aster_Epaule_{s}", sphere(epaule + Vector((cote * .03, 0, -.01)), (.088, .082, .08), 24, 12), m["Robe"], rig, f"UpperArm.{s}")
        axe = (main - coude).normalized()
        revers = tore(Vector((0, 0, 0)), .062, .028)
        rotation = Vector((0, 0, 1)).rotation_difference(axe).to_matrix()
        for v in revers.verts: v.co = main - axe * .03 + rotation @ v.co
        objet_maillage(f"Aster_Revers_{s}", revers, m["Col"], rig, f"Forearm.{s}")
        objet_maillage(f"Aster_Main_{s}", sphere(main + axe * .04, (.062, .056, .058), 20, 10), m["Gants"], rig, f"Hand.{s}")
        hanche = tete_os(rig, f"Thigh.{s}"); genou = tete_os(rig, f"Shin.{s}"); cheville = tete_os(rig, f"Foot.{s}")
        jambe = objet_maillage(f"Aster_Jambe_{s}", fusionner(capsule(hanche, genou, .07), capsule(genou, cheville, .062)), m["Bottes"], rig, f"Thigh.{s}")
        ponderer(jambe, lambda p, g=genou, s=s: {f"Thigh.{s}": lisse01(g.z - .03, g.z + .03, p.z), f"Shin.{s}": 1 - lisse01(g.z - .03, g.z + .03, p.z)})
        botte = sphere(cheville + Vector((0, -.045, -.04)), (.085, .12, .065), 24, 12)
        for v in botte.verts: v.co.z = max(v.co.z, sol - .04)
        objet_maillage(f"Aster_Botte_{s}", botte, m["Bottes"], rig, f"Foot.{s}")
    for nom in ("Aster_Wand", "Aster_Grimoire"):
        objet = bpy.data.objects.get(nom)
        if objet is not None: objet.parent = rig


def poids_robe(p, hanches, poitrine):
    # Haut sur le buste, taille sur les hanches, bas reparti entre les jambes
    # et les pans : l'ourlet suit le pas sans se dechirer au milieu.
    haut = lisse01(hanches.z + .02, poitrine.z, p.z)
    bas = 1 - lisse01(hanches.z - .18, hanches.z + .02, p.z)
    cote = "L" if p.x > 0 else "R"
    lateral = lisse01(.0, .12, abs(p.x))
    poids = {"Spine": haut, "Hips": (1 - haut) * (1 - bas) + bas * (1 - lateral) * .7}
    pan = "CoatFront" if p.y < 0 else "CoatBack"
    poids[f"Thigh.{cote}"] = bas * lateral * .6
    poids[f"{pan}.{cote}"] = bas * lateral * .4 + bas * (1 - lateral) * .3
    return poids


def attribuer_matieres_visage(visage, m):
    # Ordre de construction : par oeil, iris / grand reflet / petit reflet / joue ; puis bouche.
    maillage = visage.data
    maillage.materials.clear()
    for nom in ("Face", "Reflet", "Joue", "Bouche"): maillage.materials.append(m[nom])
    # Le jeu rend sans ombre ni contour les matieres dont le nom commence par Face.
    for nom in ("Reflet", "Joue", "Bouche"): m[nom].name = "Face_" + nom
    tailles = [24 * 11 + 2, 12 * 5 + 2, 10 * 4 + 2, 16 * 7 + 2] * 2 + [16 * 7 + 2]
    roles = [0, 1, 1, 2, 0, 1, 1, 2, 3]
    bornes = []
    debut = 0
    for taille, role in zip(tailles, roles):
        bornes.append((debut, debut + taille, role)); debut += taille
    for face in maillage.polygons:
        indice = face.vertices[0]
        for a, b, role in bornes:
            if a <= indice < b: face.material_index = role
    for face in maillage.polygons: face.use_smooth = True


def expressions(visage, ct, face_y):
    """Cles de forme attendues par le jeu : Blink, Angry, Sorrow, A."""
    visage.shape_key_add(name="Basis")
    maillage = visage.data
    yeux_z = ct.z - .03
    def est_oeil(v): return abs(v.co.z - yeux_z) < .1 and abs(abs(v.co.x - ct.x) - .105) < .07
    def est_bouche(v): return v.co.z < ct.z - .12 and abs(v.co.x - ct.x) < .04
    for nom in ("Blink", "Angry", "Sorrow", "A"):
        cle = visage.shape_key_add(name=nom)
        for v, point in zip(maillage.vertices, cle.data):
            p = v.co.copy()
            if nom == "Blink" and est_oeil(v):
                p.z = yeux_z - .02 + (p.z - yeux_z) * .08
            elif nom == "Angry" and est_oeil(v):
                cote = 1 if p.x > ct.x else -1
                p.z -= (p.x - ct.x) * cote * .12 - .005
            elif nom == "Sorrow" and est_oeil(v):
                p.z = yeux_z + (p.z - yeux_z) * .7 - .008
            elif nom == "A" and est_bouche(v):
                p.z = ct.z - .14 + (p.z - (ct.z - .14)) * 2.4
            point.co = p
        # Une expression creee reste au repos : le jeu la dose a l'execution.
        cle.value = 0.0


def exporter(rig):
    destination = RACINE / "assets/3d/characters/aster_chibi"
    destination.mkdir(parents=True, exist_ok=True)
    # Le jeu nomme les clips sans suffixe et regle lui-meme leurs boucles.
    for action in bpy.data.actions:
        action.name = action.name.removesuffix("-loop")
    for piste in list(rig.animation_data.nla_tracks): rig.animation_data.nla_tracks.remove(piste)
    rig.animation_data.action = bpy.data.actions["Idle"]
    bpy.context.scene.frame_set(0)
    bpy.ops.object.select_all(action="SELECT")
    bpy.ops.export_scene.gltf(filepath=str(destination / "aster_chibi.glb"), export_format="GLB",
        export_apply=True, export_animations=True, export_animation_mode="ACTIONS",
        export_force_sampling=True, export_skins=True, export_morph=True, export_cameras=False,
        export_lights=False, export_yup=True)
    bpy.ops.wm.save_as_mainfile(filepath=str(RACINE / "assets/3d/sources/characters/aster_chibi/aster_chibi.blend"))
    print("EXPORT_OK", destination / "aster_chibi.glb")


def scene_rendu():
    scene = bpy.context.scene
    scene.render.engine = "BLENDER_WORKBENCH"
    scene.display.shading.light = "STUDIO"
    scene.display.shading.color_type = "MATERIAL"
    scene.display.shading.show_object_outline = True
    scene.display.shading.object_outline_color = (.08, .05, .16)
    scene.display.shading.show_cavity = True
    scene.display.shading.background_type = "VIEWPORT"
    scene.display.shading.background_color = (.62, .58, .78)
    scene.render.resolution_x = 420; scene.render.resolution_y = 520
    # Couleurs sans courbe filmique : la saturation jugee est celle du jeu.
    scene.view_settings.view_transform = "Standard"
    monde = scene.world or bpy.data.worlds.new("Monde"); scene.world = monde
    monde.use_nodes = True
    fond = monde.node_tree.nodes.get("Background")
    fond.inputs[0].default_value = (.78, .76, .88, 1); fond.inputs[1].default_value = 1.1
    soleil = bpy.data.objects.new("Soleil", bpy.data.lights.new("Soleil", "SUN"))
    soleil.data.energy = 3.0; soleil.rotation_euler = (math.radians(50), 0, math.radians(30))
    scene.collection.objects.link(soleil)
    camera = bpy.data.objects.new("Camera", bpy.data.cameras.new("Camera"))
    camera.data.type = "ORTHO"; camera.data.ortho_scale = 1.6
    scene.collection.objects.link(camera); scene.camera = camera
    return scene, camera


def apercu(rig, nom, action="Idle-loop", image=1):
    scene, camera = scene_rendu() if bpy.context.scene.camera is None else (bpy.context.scene, bpy.context.scene.camera)
    rig.animation_data.action = bpy.data.actions[action]
    scene.frame_set(image)
    centre = .62
    vues = {"face": ((0, -8, centre), (90, 0, 0)), "trois_quarts": ((5.4, -5.4, centre + 1.4), (80, 0, 45)),
            "jeu": ((0, -6 * math.cos(math.radians(48)), centre + 6 * math.sin(math.radians(48))), (42, 0, 0))}
    vues["visage"] = ((0, -8, tete_os(rig, "Head").z + .2), (90, 0, 0))
    for vue, (position, rotation) in vues.items():
        camera.data.ortho_scale = .75 if vue == "visage" else 1.6
        camera.location = position
        camera.rotation_euler = tuple(math.radians(r) for r in rotation)
        scene.render.filepath = str(SORTIE / f"{nom}_{vue}.png")
        bpy.ops.render.render(write_still=True)


if __name__ == "__main__":
    SORTIE.mkdir(parents=True, exist_ok=True)
    rig = preparer_squelette()
    modele(rig)
    if "--exporter" in ARGS:
        (RACINE / "assets/3d/sources/characters/aster_chibi").mkdir(parents=True, exist_ok=True)
        exporter(rig)
    elif "--apercu" in ARGS:
        apercu(rig, "repos")
        apercu(rig, "course", "Run-loop", 6)
    print("HEROS_CHIBI_OK", round(tete_os(rig, "Head").z, 3), round(tete_os(rig, "Hips").z, 3))
