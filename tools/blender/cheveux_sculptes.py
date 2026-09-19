"""Meches du dessus et de la nuque ; conserver la frange sculptee d'origine."""
import math
import bpy
import bmesh
from pathlib import Path
from chapeau_sculpte import matiere, altitude


def remplacer(objet):
    maillage=bmesh.new();maillage.from_mesh(objet.data)
    marque=maillage.faces.layers.int.get('fermeture_crane')
    zone=maillage.faces.layers.int.new('reprise_cheveux')
    retirer=[]
    for face in maillage.faces:
        x,y,z=face.calc_center_median()
        raccord=marque is not None and face[marque]!=0
        if raccord or (z>1.025 and y>-.025) or (z>1.22 and abs(x)>.29 and y>-.30):
            face[zone]=1
            retirer.append(face)
    # Garder un fond ferme sous les meches, en retrait et sans deplacer la frange.
    region=set(retirer)
    for sommet in maillage.verts:
        if sommet.link_faces and all(face in region for face in sommet.link_faces):
            sommet.co.x*=.86
            sommet.co.y=-.035+(sommet.co.y+.035)*.86
    maillage.to_mesh(objet.data);maillage.free();objet.data.update()
    mat=matiere('Tete_meches_chataignes',(.16,.057,.027),.63)
    mat.node_tree.nodes['Principled BSDF'].inputs['Specular IOR Level'].default_value=.22
    reference=Path(__file__).resolve().parents[2]/'assets/3d/sources/characters/mage_v2/reference.png'
    image=bpy.data.images.load(str(reference),check_existing=True)
    texture=mat.node_tree.nodes.new('ShaderNodeTexImage');texture.image=image
    coord=mat.node_tree.nodes.new('ShaderNodeUVMap');coord.uv_map='Meches'
    mat.node_tree.links.new(coord.outputs['UV'],texture.inputs['Vector'])
    mat.node_tree.links.new(texture.outputs['Color'],mat.node_tree.nodes['Principled BSDF'].inputs['Base Color'])
    def uv_frange(u,t):
        # Suivre la courbe des fibres sur toute la longueur de la meche de reference.
        # Un petit rectangle etire ecrasait le grain et coupait les reflets aux pointes.
        sections=((527,368,480),(548,378,509),(575,403,528),
                  (600,441,532),(625,477,526),(648,507,516))
        ligne=527+121*t
        for haut,bas in zip(sections,sections[1:]):
            if ligne<=bas[0]:
                poids=(ligne-haut[0])/(bas[0]-haut[0])
                gauche=haut[1]*(1-poids)+bas[1]*poids
                droite=haut[2]*(1-poids)+bas[2]*poids
                return (gauche+(droite-gauche)*u)/image.size[0],1-ligne/image.size[1]
        return (507+9*u)/image.size[0],1-648/image.size[1]

    uv_fond=objet.data.uv_layers.get('Meches') or objet.data.uv_layers.new(name='Meches')
    indice=len(objet.data.materials);objet.data.materials.append(mat)
    zone=objet.data.attributes['reprise_cheveux']
    for face in objet.data.polygons:
        if zone.data[face.index].value==0:
            continue
        face.material_index=indice
        for numero in face.loop_indices:
            p=objet.data.vertices[objet.data.loops[numero].vertex_index].co
            # Une coordonnee continue evite les stries radiales aux raccords de la joue.
            angle=math.atan2(p.y+.035,p.x)
            if angle<-1.:angle+=math.tau
            u=max(0.,min(1.,(angle+1.)/(math.pi+2.)))
            t=max(0.,min(1.,(1.34-p.z)/.29))
            uv_fond.data[numero].uv=uv_frange(u,t)
    points=[];faces=[];coordonnees=[]

    def grille(lignes,colonnes,fonction):
        debut=len(points)
        for j in range(lignes):
            for i in range(colonnes):
                u=i/(colonnes-1);t=j/(lignes-1)
                points.append(fonction(u,t));coordonnees.append(uv_frange(u,t))
        for j in range(lignes-1):
            for i in range(colonnes-1):
                a=debut+j*colonnes+i
                faces.append((a,a+colonnes,a+1+colonnes,a+1))

    # Le fond reste en retrait : seuls les reliefs et les pointes dessinent la coiffure.
    def fond(u,t):
        a=-.95+(math.pi+1.90)*u
        x=.286*math.cos(a);y=-.035+.285*math.sin(a)
        bas=1.07+.04*abs(math.cos(a))
        # Fermer les tempes sous le bord sans recouvrir la frange qui descend devant.
        bas=max(bas,1.265) if math.sin(a)<-.25 else bas
        return x,y,(altitude(x,y)-.008)*(1-t)+bas*t
    grille(14,65,fond)

    def meche(angle,largeur,bas,couche):
        def point(u,t):
            courbe=angle+.30*math.cos(angle)*t+.045*math.sin(t*math.pi)
            largeur_t=largeur*(1-.995*t**1.65)
            a=courbe+(u-.5)*2*largeur_t
            ventre=math.sin(math.pi*u)**.8
            relief=.021*ventre-.001*(math.sin(u*math.pi*3)**2)*ventre
            # Une courbe bombee et une pointe fine detachent la meche du crane.
            rayon=.298+.046*math.sin(math.pi*t)-.009*t*t+couche+relief
            x=rayon*math.cos(a);y=-.035+rayon*math.sin(a)
            haut=altitude(.30*math.cos(angle),-.035+.30*math.sin(angle))-.008
            z=haut*(1-t)+bas*t+.011*math.sin(math.pi*u)*math.sin(math.pi*t)
            return x,y,z
        grille(25,19,point)

    for i in range(12):
        angle=-.43+(math.pi+.86)*i/11
        # Couvrir aussi les cotes jusqu'a la nuque : le fond ne doit pas former une plaque.
        bas=1.055+.04*abs(math.cos(angle))+.008*math.sin(i*2.3)
        meche(angle,.27,bas,0.)
    # Une rangee courte oblique rompt l'effet de casque et rejoint les meches frontales.
    for i in range(10):
        angle=-.46+(math.pi+.92)*i/9
        bas=1.17+.075*abs(math.cos(angle))+.012*math.sin(i*1.7)
        meche(angle,.29,bas,.018)
    mesh=bpy.data.meshes.new('Cheveux_meches');mesh.from_pydata(points,[],faces);mesh.materials.append(mat)
    uv=mesh.uv_layers.new(name='Meches')
    for boucle in mesh.loops:uv.data[boucle.index].uv=coordonnees[boucle.vertex_index]
    bm=bmesh.new();bm.from_mesh(mesh)
    bmesh.ops.recalc_face_normals(bm,faces=list(bm.faces));bm.to_mesh(mesh);bm.free()
    for face in mesh.polygons:face.use_smooth=True
    cheveux=bpy.data.objects.new('Cheveux_meches',mesh);bpy.context.collection.objects.link(cheveux)
    bpy.ops.object.select_all(action='DESELECT');objet.select_set(True);cheveux.select_set(True)
    bpy.context.view_layer.objects.active=objet;bpy.ops.object.join()
