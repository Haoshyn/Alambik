"""Prise droite et avance de la main armee dans la direction du lancer."""
import math
import struct
import sys
from pathlib import Path

sys.path.insert(0,str(Path(__file__).resolve().parent))
from variantes_mage import lire_glb,ecrire_glb
from animer_mage_v2 import quaternion,rampe
from mathutils import Quaternion,Vector
from bottes_sculptees import pose_course,composer_rotations


def qmath(q):
    return Quaternion((q[3],q[0],q[1],q[2]))


def prise_droite(bras,coude,direction):
    chaine=bras @ coude
    naturelle=chaine @ qmath(quaternion(-.60,-.06,0.))
    correction=(naturelle @ Vector((0,0,1))).rotation_difference(direction)
    return chaine.inverted() @ correction @ naturelle


def finaliser(chemin):
    doc,brut=lire_glb(chemin)
    if doc.get('extras',{}).get('gestes_baguette_revision')==5:return
    binaire=bytearray(brut)
    noeuds={n['name']:n for n in doc['nodes'] if 'name' in n}
    for animation in doc['animations']:
        nom=animation['name']
        if nom not in ('course','attaque'):continue
        for canal in animation['channels']:
            os=doc['nodes'][canal['target']['node']].get('name','')
            if canal['target']['path']!='rotation':continue
            if os!='main_droite' and not (nom=='attaque' and os in ('bras_droite','avant_bras_droite')):continue
            sampler=animation['samplers'][canal['sampler']]
            acc=doc['accessors'][sampler['input']];vue=doc['bufferViews'][acc['bufferView']]
            debut=vue.get('byteOffset',0)+acc.get('byteOffset',0);pas=vue.get('byteStride',4)
            instants=[struct.unpack_from('<f',binaire,debut+i*pas)[0] for i in range(acc['count'])]
            if nom in ('course','attaque'):
                # Le poignet etait constant : son export ne contenait que
                # deux cles. Recreer les temps permet de porter le geste bref.
                premier,dernier=instants[0],instants[-1]
                nombre=math.ceil((dernier-premier)*120)+1
                instants=[premier+(dernier-premier)*i/(nombre-1) for i in range(nombre)]
                while len(binaire)%4:binaire.append(0)
                offset=len(binaire);binaire.extend(struct.pack('<'+'f'*nombre,*instants))
                doc['bufferViews'].append({'buffer':0,'byteOffset':offset,'byteLength':nombre*4})
                sampler['input']=len(doc['accessors'])
                doc['accessors'].append({'bufferView':len(doc['bufferViews'])-1,
                    'componentType':5126,'type':'SCALAR','count':nombre,'min':[premier],'max':[dernier]})
            valeurs=[]
            for instant in instants:
                if nom=='course':
                    t=(instant-instants[0])/(instants[-1]-instants[0])
                    poses,_=pose_course(t,noeuds)
                    bras=qmath(poses['bras_droite']);coude=qmath(poses['avant_bras_droite'])
                    # Une prise droite accompagne le bras sans repartir sur
                    # les cotes. La pointe reste legerement devant la main.
                    q=prise_droite(bras,coude,Vector((0,.84,.54)).normalized())
                    valeur=(q.x,q.y,q.z,q.w)
                else:
                    t=instant-instants[0]
                    geste=rampe(.025,.05,t)*(1-rampe(.10,.4,t))
                    bras=qmath(composer_rotations(quaternion(-.20-.65*geste,0.,0.),quaternion(0.,0.,1.19)))
                    coude=qmath(quaternion(0.,.80-.55*geste,0.))
                    if os=='bras_droite':
                        valeur=(bras.x,bras.y,bras.z,bras.w)
                    elif os=='avant_bras_droite':
                        valeur=(coude.x,coude.y,coude.z,coude.w)
                    else:
                        # La paume pivote avec la prise : deplacer seulement
                        # l'accessoire le ferait glisser hors des doigts.
                        poids=rampe(0.,.05,t)*(1-rampe(.20,.4,t))
                        direction=Vector((0.,.84*(1-poids)+.12*poids,.54*(1-poids)+.993*poids)).normalized()
                        q=prise_droite(bras,coude,direction)
                        valeur=(q.x,q.y,q.z,q.w)
                valeurs.extend(valeur)
            while len(binaire)%4:binaire.append(0)
            offset=len(binaire);binaire.extend(struct.pack('<'+'f'*len(valeurs),*valeurs))
            doc['bufferViews'].append({'buffer':0,'byteOffset':offset,'byteLength':len(valeurs)*4})
            sampler['output']=len(doc['accessors'])
            doc['accessors'].append({'bufferView':len(doc['bufferViews'])-1,
                'componentType':5126,'type':'VEC4','count':len(instants)})
    doc['buffers'][0]['byteLength']=len(binaire)
    doc.setdefault('extras',{})['gestes_baguette_revision']=5
    ecrire_glb(chemin,doc,binaire)
