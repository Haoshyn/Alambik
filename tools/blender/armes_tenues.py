"""Armes du catalogue en volume, separees du personnage et centrees sur la prise."""
import math
from pathlib import Path
import bpy
from mathutils import Vector

RACINE=Path(__file__).resolve().parents[2]
PROFILS={
    'standard':('orbe',(.52,.06,.85),(.16,.075,.045)),
    'veloce':('pointe',(.12,.78,.92),(.72,.65,.44)),
    'lourd':('masse',(.42,.05,.68),(.12,.05,.025)),
    'chercheur':('branche',(.08,.85,.64),(.19,.105,.035)),
    'explosif':('soleil',(1.,.40,.025),(.28,.065,.025)),
    'prisme':('double',(.30,.78,.95),(.57,.60,.66)),
    'resonant':('diapason',(.35,.65,.85),(.16,.11,.20)),
    'draconique':('soleil',(1.,.16,.025),(.25,.03,.025)),
    'neant':('branche',(.42,.10,.75),(.075,.045,.12)),
    'royal':('masse',(1.,.66,.08),(.26,.085,.20)),
}


def mat(nom,couleur,metal=0.):
    m=bpy.data.materials.new(nom);m.use_nodes=True
    p=m.node_tree.nodes.get('Principled BSDF')
    p.inputs['Base Color'].default_value=(*couleur,1)
    p.inputs['Metallic'].default_value=metal;p.inputs['Roughness'].default_value=.32 if metal else .55
    return m


def finir(nom,m):
    o=bpy.context.object;o.name=nom;o.data.materials.append(m)
    for p in o.data.polygons:p.use_smooth=True
    return o


def tige(a,b,r,m):
    a=Vector(a);b=Vector(b)
    bpy.ops.mesh.primitive_cylinder_add(vertices=24,radius=r,depth=(b-a).length,location=(a+b)/2)
    o=finir('Manche',m);o.rotation_euler=(b-a).to_track_quat('Z','Y').to_euler()
    return o


def boule(p,r,m):
    bpy.ops.mesh.primitive_uv_sphere_add(segments=24,ring_count=12,radius=r,location=p)
    return finir('Orbe',m)


def courbe(points,r,m):
    c=bpy.data.curves.new('Monture','CURVE');c.dimensions='3D';c.bevel_depth=r;c.bevel_resolution=3
    s=c.splines.new('POLY');s.points.add(len(points)-1)
    for p,v in zip(s.points,points):p.co=(*v,1)
    o=bpy.data.objects.new('Monture',c);bpy.context.collection.objects.link(o);o.data.materials.append(m)
    return o


def cristal(p,rayon,hauteur,m):
    bpy.ops.mesh.primitive_ico_sphere_add(subdivisions=1,radius=1,location=p)
    o=finir('Cristal',m);o.scale=(rayon,rayon,hauteur)
    for f in o.data.polygons:f.use_smooth=False


def construire(identifiant,profil):
    bpy.ops.wm.read_factory_settings(use_empty=True)
    forme,couleur,bois=profil
    manche=mat('Bois',bois);cuivre=mat('Monture_cuivre',(.64,.32,.095),.65)
    gemme=mat('Gemme',couleur,.18);cuir=mat('Prise_cuir',(.10,.045,.025))
    # La baguette standard reprend le manche, l'anneau et l'orbe de son icone.
    if forme=='orbe':
        tige((0,0,-.16),(0,0,.40),.026,manche)
        bpy.ops.mesh.primitive_torus_add(major_radius=.077,minor_radius=.012,location=(0,0,.40))
        finir('Anneau',cuivre);boule((0,0,.475),.084,gemme)
    else:
        tige((0,0,-.19),(0,0,.42),.022 if forme=='pointe' else .027,manche)
        tige((0,0,-.065),(0,0,.065),.029,cuir)
        for z in (-.17,.08,.36,.40):tige((0,0,z-.009),(0,0,z+.009),.033,cuivre)
        boule((0,0,-.19),.035,cuivre)
        if forme in ('pointe','masse','double'):
            if forme=='double':
                for x in (-.043,.043):cristal((x,0,.51),.036,.12,gemme)
            else:cristal((0,0,.51),.045 if forme=='pointe' else .085,.13,gemme)
            for signe in (-1,1):courbe([(signe*.02,0,.36),(signe*.07,0,.43),(signe*.065,0,.55)],.012,cuivre)
        elif forme=='diapason':
            for signe in (-1,1):
                courbe([(0,0,.37),(signe*.065,0,.41),(signe*.065,0,.62)],.019,cuivre)
                cristal((signe*.065,0,.61),.025,.035,gemme)
        elif forme=='branche':
            for signe in (-1,1):
                courbe([(0,0,.30),(signe*.065,0,.40),(signe*.08,0,.52)],.021,manche)
                feuille=boule((signe*.065,0,.30),.04,mat('Feuille',(.16,.36,.035)))
                feuille.scale=(.5,.3,1.5);feuille.rotation_euler.y=signe*.7
            cristal((0,0,.52),.06,.10,gemme)
        else:
            boule((0,0,.51),.078,gemme)
            for signe in (-1,1):
                courbe([(signe*.105*math.sin(a),0,.51-.105*math.cos(a))
                    for a in [i*math.pi/18 for i in range(17)]],.012,cuivre)
        courbe([(.029*math.cos(i*.3),.029*math.sin(i*.3),.09+i*.0045) for i in range(55)],.005,cuivre)
    bpy.ops.object.select_all(action='SELECT');bpy.ops.object.convert(target='MESH');bpy.ops.object.join()
    o=bpy.context.object;o.name='Arme_'+identifiant
    bpy.ops.object.transform_apply(location=True,rotation=True,scale=True)
    dossier=RACINE/'assets/3d/weapons';dossier.mkdir(parents=True,exist_ok=True)
    bpy.ops.export_scene.gltf(filepath=str(dossier/(identifiant+'.glb')),export_format='GLB',use_selection=True,export_animations=False)


if __name__=='__main__':
    for identifiant,profil in PROFILS.items():construire(identifiant,profil)
