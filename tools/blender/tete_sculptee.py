"""Fermeture du crane et oreilles en volume sur la copie de travail."""
import math
import bpy
import bmesh
from pathlib import Path
from chapeau_sculpte import matiere
from texturer_mage_reference import rampe


def preparer_oreilles(objet):
    # Rentrer les anciennes languettes dans la tete, sans ouvrir le maillage du visage.
    for v in objet.data.vertices:
        x,y,z=v.co
        poids=rampe(.31,.34,abs(x))*rampe(1.025,1.055,z)*(1-rampe(1.205,1.235,z))
        poids*=rampe(-.27,-.21,y)*(1-rampe(.07,.13,y))
        v.co.x=x*(1-poids)+math.copysign(.27,x)*poids
    objet.data.update()


def ajouter(objet):
    cheveux=matiere('Tete_cheveux_reference',(.16,.057,.027),.63)
    reference=Path(__file__).resolve().parents[2]/'assets/3d/sources/characters/mage_reference/direction.png'
    image=bpy.data.images.load(str(reference),check_existing=True)
    nodes=cheveux.node_tree.nodes;liens=cheveux.node_tree.links
    texture=nodes.new('ShaderNodeTexImage');texture.image=image;texture.extension='EXTEND'
    coord=nodes.new('ShaderNodeUVMap');coord.uv_map='Cheveux_reference'
    liens.new(coord.outputs['UV'],texture.inputs['Vector'])
    liens.new(texture.outputs['Color'],nodes.get('Principled BSDF').inputs['Base Color'])
    uv=objet.data.uv_layers.new(name='Cheveux_reference')
    indice=len(objet.data.materials);objet.data.materials.append(cheveux)
    marque=objet.data.attributes.get('fermeture_crane')
    for face in objet.data.polygons:
        x,y,z=face.center
        raccord=marque is not None and marque.data[face.index].value!=0
        arriere=z>1.025 and y>-.025
        tempe=z>1.22 and abs(x)>.29 and y>-.16
        if not (raccord or arriere or tempe):continue
        face.material_index=indice
        for numero in face.loop_indices:
            x,y,z=objet.data.vertices[objet.data.loops[numero].vertex_index].co
            # Reprendre les fibres et les nuances des meches de devant, pas celles du cuir.
            angle=(math.atan2(y,x)+math.pi/2)%math.tau
            hauteur=max(0.,min(1.,(z-1.025)/.42))
            colonne=455+40*hauteur
            ligne=606-54*angle/math.tau
            uv.data[numero].uv=(colonne/image.size[0],1-ligne/image.size[1])
    peau=matiere('Oreille_peau',(.82,.43,.23),.72)
    interieur=matiere('Oreille_interieur',(.66,.29,.16),.8)
    morceaux=[]
    for signe in [-1,1]:
        # Un lobe arrondi conserve une vraie profondeur meme vu de profil.
        points=[];faces=[];n=48;m=24
        for j in range(m+1):
            p=math.pi*j/m
            for i in range(n):
                a=math.tau*i/n
                x=signe*(.335+.050*math.sin(p)*math.cos(a))
                y=-.04+.045*math.sin(p)*math.sin(a)
                z=1.168+.052*math.cos(p)
                points.append((x,y,z))
        for j in range(m):
            for i in range(n):
                f=(j*n+i,j*n+(i+1)%n,(j+1)*n+(i+1)%n,(j+1)*n+i)
                faces.append(f if signe>0 else tuple(reversed(f)))
        mesh=bpy.data.meshes.new('Oreille_arrondie');mesh.from_pydata(points,[],faces)
        mesh.materials.append(peau);mesh.materials.append(interieur)
        bm=bmesh.new();bm.from_mesh(mesh)
        bmesh.ops.remove_doubles(bm,verts=list(bm.verts),dist=.000001)
        bmesh.ops.recalc_face_normals(bm,faces=list(bm.faces))
        bm.to_mesh(mesh);bm.free();mesh.update()
        o=bpy.data.objects.new('Oreille_arrondie',mesh);bpy.context.collection.objects.link(o)
        for f in mesh.polygons:
            f.use_smooth=True
        morceaux.append(o)
    bpy.ops.object.select_all(action='DESELECT');objet.select_set(True)
    for morceau in morceaux:morceau.select_set(True)
    bpy.context.view_layer.objects.active=objet;bpy.ops.object.join()
