"""Anneau de passage en azur et cuivre, geometrie continue."""
import math, sys, json, bpy
from pathlib import Path
sys.path.insert(0,str(Path(__file__).resolve().parent))
import build_all as b

def anneau(nom, rx, rz, tube, profondeur, mat):
    sommets=[]; faces=[]
    for i in range(64):
        a=math.tau*i/64
        for j in range(10):
            c=math.tau*j/10
            sommets.append(((rx+tube*math.cos(c))*math.cos(a), profondeur+tube*math.sin(c), .99+(rz+tube*math.cos(c))*math.sin(a)))
    for i in range(64):
        for j in range(10):
            faces.append((i*10+j,((i+1)%64)*10+j,((i+1)%64)*10+(j+1)%10,i*10+(j+1)%10))
    mesh=bpy.data.meshes.new(nom); mesh.from_pydata(sommets,[],faces);mesh.update()
    obj=bpy.data.objects.new(nom,mesh);bpy.context.collection.objects.link(obj)
    for p in mesh.polygons:p.use_smooth=True
    b.finir(obj,nom,mat)

def construire(base=None):
    global b
    if base is not None:b=base
    mat=b.MAT['turquoise']; couleur=(.025,.16,.18,1)
    mat.diffuse_color=couleur
    mat.node_tree.nodes.get('Principled BSDF').inputs['Base Color'].default_value=couleur
    b.cone('Socle',(0,0,.055),.85,.79,.11,'turquoise',48)
    b.anneau('Seuil_cuivre',(0,0,.115),.72,.023,'cuivre')
    anneau('Cadre_azur',.65,.86,.105,0,'turquoise')
    anneau('Levre_cuivre',.65,.86,.036,-.093,'cuivre')
    anneau('Liseron_lumineux',.555,.765,.019,-.055,'cristal')
    for cote in [-1,1]:
        b.boite('Ancrage',(cote*.52,0,.18),(.25,.32,.25),'turquoise',.055)
        b.boule('Sceau_lateral',(cote*.65,-.105,.99),(.09,.04,.135),'cuivre',16)
        b.boule('Cristal_lateral',(cote*.65,-.14,.99),(.045,.02,.075),'cristal',12)
    b.boule('Clef',(0,-.06,1.91),(.13,.095,.16),'cuivre',12)
    b.boule('Cristal_clef',(0,-.145,1.93),(.065,.03,.09),'cristal',12)

if __name__=='__main__':
    bpy.ops.wm.read_factory_settings(use_empty=True)
    bpy.context.preferences.filepaths.save_version=0
    bpy.context.preferences.filepaths.file_preview_type='NONE'
    b.materiaux();b.exporter('portail','environment',construire)
    (b.SORTIE/'portail_azur_rapport.json').write_text(json.dumps(b.RAPPORT,indent=2),encoding='utf-8')
