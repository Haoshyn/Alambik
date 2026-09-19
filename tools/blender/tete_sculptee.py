"""Preparation de la tete sans oreilles ajoutees sur la copie de travail."""
import bmesh
import cheveux_sculptes


def preparer_oreilles(objet):
    maillage=bmesh.new();maillage.from_mesh(objet.data)
    sommets=[]
    for sommet in maillage.verts:
        x,y,z=sommet.co
        if abs(x)>.12 and -.12<y<.27 and 1.015<z<1.245:
            sommets.append(sommet)
    # Lisser toute l'ancienne oreille dans la surface continue evite les replis
    # d'une projection sur un plan et les raccords d'une piece rapportee.
    for _ in range(600):
        bmesh.ops.smooth_vert(maillage,verts=sommets,factor=.5,use_axis_x=True,use_axis_y=True,use_axis_z=True)
    bmesh.ops.recalc_face_normals(maillage,faces=list(maillage.faces))
    maillage.to_mesh(objet.data);maillage.free();objet.data.update()


def ajouter(objet):
    cheveux_sculptes.remplacer(objet)
