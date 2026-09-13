"""Ombres de contact douces dans les couleurs de sommets, sans texture lourde."""
import math
import bpy
from mathutils import Vector
from mathutils.bvhtree import BVHTree


def appliquer(compacter):
    objets=[o for o in bpy.context.scene.objects if o.type=='MESH']
    points=[];faces=[]
    for o in objets:
        debut=len(points)
        points.extend(v.co.copy() for v in o.data.vertices)
        faces.extend(tuple(debut+i for i in p.vertices) for p in o.data.polygons)
    arbre=BVHTree.FromPolygons(points,faces)
    directions=[]
    for i in range(12):
        z=math.sqrt((i+.5)/12)
        r=math.sqrt(1-z*z);a=i*2.399963
        directions.append(Vector((r*math.cos(a),r*math.sin(a),z)))
    joues=[compacter((s*.292,-.30,1.535)) for s in [-1,1]]
    for o in objets:
        attribut=o.data.color_attributes.new(name='Occlusion_douce',type='FLOAT_COLOR',domain='POINT')
        for v in o.data.vertices:
            normale=v.normal.normalized()
            tangente=normale.cross(Vector((0,0,1)))
            if tangente.length<.01:tangente=normale.cross(Vector((0,1,0)))
            tangente.normalize();bitangente=normale.cross(tangente)
            masque=0.0
            for d in directions:
                rayon=tangente*d.x+bitangente*d.y+normale*d.z
                position,_,_,distance=arbre.ray_cast(v.co+normale*.002,rayon,.16)
                if position is not None:masque+=1.0-distance/.16
            valeur=1.0-.42*masque/12
            couleur=Vector((valeur,valeur,valeur))
            # Le rose est dans la peau ; aucun disque ne flotte devant la joue.
            if o.name=='Visage' and normale.y<-.25:
                poids=max(math.exp(-((v.co.x-c.x)/.067)**2-((v.co.z-c.z)/.035)**2) for c in joues)*.48
                couleur.y*=1-poids*.44;couleur.z*=1-poids*.35
            attribut.data[v.index].color=(*couleur,1)
        o.data.color_attributes.active_color=attribut
    print('OCCLUSION_APPRENTI',len(points),'sommets, 12 rayons par sommet')
