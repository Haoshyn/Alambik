"""Bottines plus courtes et course plus souple pour la copie sculptee."""
import math
import struct
import sys
from pathlib import Path

import bpy
import bmesh

sys.path.insert(0,str(Path(__file__).resolve().parent))
from variantes_mage import lire_glb, ecrire_glb
from animer_mage_v2 import quaternion, rampe as progression


def rampe(a,b,x):
    t=max(0.,min(1.,(x-a)/(b-a)))
    return t*t*(3-2*t)


def reprendre_bottes(objet,rig):
    # Les longs triangles du scan traversaient toute la pliure du genou.
    bm=bmesh.new();bm.from_mesh(objet.data)
    aretes=[e for e in bm.edges if all(.34<v.co.z<.56 for v in e.verts)]
    bmesh.ops.subdivide_edges(bm,edges=aretes,cuts=2,use_grid_fill=True)
    bm.to_mesh(objet.data);bm.free()
    # Le genou du scan etait trop proche du haut de la botte.
    bpy.ops.object.select_all(action='DESELECT');rig.select_set(True)
    bpy.context.view_layer.objects.active=rig;bpy.ops.object.mode_set(mode='EDIT')
    for cote in ('droite','gauche'):
        os=rig.data.edit_bones['tibia_'+cote]
        os.head.z+=.020;os.tail.z+=.020
        # Comme les poignets, les volumes du scan sont en avant du squelette.
        # Centrer la pliure dans le pantalon evite de tirer sa face avant.
        for nom in ('cuisse_','tibia_'):
            articulation=rig.data.edit_bones[nom+cote]
            articulation.head.y-=.06;articulation.tail.y-=.06
    bpy.ops.object.mode_set(mode='OBJECT')
    profils=((0.,0.),(.10,.10),(.16,.15),(.355,.24),(.49,.49))
    for v in objet.data.vertices:
        x,y,z=v.co
        if z>=.66:continue
        if z>=.49:
            poids_jambe=sum(g.weight for g in v.groups
                if objet.vertex_groups[g.group].name.startswith(('tibia_','cuisse_')))
            if poids_jambe<.95:continue
        nouveau_z=z
        for (a,ha),(b,hb) in zip(profils,profils[1:]):
            if a<=z<=b:
                nouveau_z=ha+(hb-ha)*(z-a)/(b-a)
                break
        cote='gauche' if x>0 else 'droite'
        centre_x=rig.data.bones['tibia_'+cote].head_local.x
        tige=rampe(.10,.22,z)
        botte=1-rampe(.345,.42,z)
        largeur=1-botte*(.12+.12*tige)
        profondeur=1-botte*(.10+.12*tige)
        centre_y=-.04*(1-tige)
        v.co=(centre_x+(x-centre_x)*largeur,centre_y+(y-centre_y)*profondeur,nouveau_z)
        # Reprendre aussi le dessus du genou : conserver les anciens poids
        # a cette hauteur ouvrait les coutures du scan pendant la flexion.
        pied=1-rampe(.105,.205,nouveau_z)
        genou=rig.data.bones['tibia_'+cote].head_local.z
        cuisse=rampe(genou-.080,genou+.085,nouveau_z)
        ancien=rampe(.58,.66,z)
        poids={objet.vertex_groups[g.group].name:g.weight*ancien for g in v.groups}
        for nom,w in (('pied_'+cote,pied),('tibia_'+cote,(1-pied)*(1-cuisse)),
                      ('cuisse_'+cote,(1-pied)*cuisse)):
            poids[nom]=poids.get(nom,0.)+w*(1-ancien)
        for groupe in objet.vertex_groups:groupe.remove([v.index])
        for nom,w in poids.items():
            if w>0:objet.vertex_groups[nom].add([v.index],w,'REPLACE')
    objet.data.update()
    rigidifier_chaussures(objet,rig)
    reprendre_plis_pantalon(objet,rig)


def reprendre_plis_pantalon(objet,rig):
    # Les pans superposes du scan se croisent au creux du genou. Des anneaux
    # continus donnent au tissu assez de geometrie pour accompagner la pliure.
    bm=bmesh.new();bm.from_mesh(objet.data)
    for z in (.260,.505):
        bmesh.ops.bisect_plane(bm,geom=list(bm.verts)+list(bm.edges)+list(bm.faces),
            dist=.000001,plane_co=(0,0,z),plane_no=(0,0,1))
    retrait=[f for f in bm.faces if .260001<f.calc_center_median().z<.504999]
    bmesh.ops.delete(bm,geom=retrait,context='FACES')
    bm.to_mesh(objet.data);bm.free()
    sommets=[];faces=[];poids=[]
    profils=((.210,.058,.058),(.240,.066,.070),(.270,.080,.086),(.310,.090,.101),
             (.355,.098,.114),(.405,.104,.128),(.460,.106,.135),(.570,.105,.130))
    segments=32;niveaux=29
    for signe,cote in ((-1,'droite'),(1,'gauche')):
        debut=len(sommets)
        for j in range(niveaux):
            z=.210+(.570-.210)*j/(niveaux-1)
            for (a,ra,pa),(b,rb,pb) in zip(profils,profils[1:]):
                if a<=z<=b:
                    t=rampe(a,b,z);rayon=ra+(rb-ra)*t;profondeur=pa+(pb-pa)*t
                    break
            genou=rig.data.bones['tibia_'+cote].head_local.z
            haut=rampe(genou-.080,genou+.085,z)
            pied=1-rampe(.255,.330,z)
            for k in range(segments):
                angle=math.tau*k/segments
                centre_y=-.040-.020*rampe(.24,.34,z)
                sommets.append((signe*.14+rayon*math.cos(angle),centre_y+profondeur*math.sin(angle),z))
                poids.append({'pied_'+cote:pied,'tibia_'+cote:(1-pied)*(1-haut),
                              'cuisse_'+cote:(1-pied)*haut})
                if j:
                    a=debut+(j-1)*segments+k;b=debut+(j-1)*segments+(k+1)%segments
                    faces.append((a,b,b+segments,a+segments))
    mesh=bpy.data.meshes.new('Plis_genoux');mesh.from_pydata(sommets,[],faces);mesh.update()
    tissu=bpy.data.objects.new('Plis_genoux',mesh);bpy.context.collection.objects.link(tissu)
    tissu.data.materials.append(next(m for m in objet.data.materials if m.name.startswith('Tunique_violet_uni')))
    for nom in {n for p in poids for n in p}:tissu.vertex_groups.new(name=nom)
    for i,p in enumerate(poids):
        for nom,w in p.items():
            if w>0:tissu.vertex_groups[nom].add([i],w,'REPLACE')
    for face in mesh.polygons:face.use_smooth=True
    bpy.ops.object.select_all(action='DESELECT');objet.select_set(True);tissu.select_set(True)
    bpy.context.view_layer.objects.active=objet;bpy.ops.object.join()


def rigidifier_chaussures(objet,rig):
    for signe,cote in ((-1,'droite'),(1,'gauche')):
        pivot=rig.data.bones['pied_'+cote].head_local
        semelle=[v.co.copy() for v in objet.data.vertices if signe*v.co.x>0 and .025<v.co.z<.085]
        avant=min(p.y for p in semelle)
        pointe=[p for p in semelle if p.y<avant+.04]
        centre_x=(min(p.x for p in pointe)+max(p.x for p in pointe))*.5
        centre_y=sum(p.y for p in pointe)/len(pointe)
        angle=-math.atan2(centre_x-pivot.x,pivot.y-centre_y)
        angle=max(-.45,min(.45,angle))
        for v in objet.data.vertices:
            x,y,z=v.co
            if signe*x<=0 or z>=.32:continue
            a=angle*(1-rampe(.20,.32,z))
            dx=x-pivot.x;dy=y-pivot.y
            v.co.x=pivot.x+math.cos(a)*dx-math.sin(a)*dy
            v.co.y=pivot.y+math.sin(a)*dx+math.cos(a)*dy
        print('Pointe redressee',cote,round(math.degrees(angle),1),flush=True)
    for v in objet.data.vertices:
        x,y,z=v.co
        if z>=.330:continue
        cote='gauche' if x>0 else 'droite'
        # Toute la chaussure, tige comprise, suit un seul os. Le raccord
        # souple se trouve dans le pantalon, au-dessus du cuir.
        tige=rampe(.255,.330,z)
        for groupe in objet.vertex_groups:groupe.remove([v.index])
        objet.vertex_groups['pied_'+cote].add([v.index],1-tige,'REPLACE')
        objet.vertex_groups['tibia_'+cote].add([v.index],tige,'REPLACE')
    objet.data.update()


def composer_rotations(a,b):
    x,y,z,w=a;X,Y,Z,W=b
    return (w*X+x*W+y*Z-z*Y,w*Y-x*Z+y*W+z*X,
            w*Z+x*Y-y*X+z*W,w*W-x*X-y*Y-z*Z)


def trajectoire_foulee(u):
    # Appui, poussee, talon ramene derriere, passage sous le bassin, puis
    # extension devant : le retour ne suit plus le meme chemin que l'appui.
    cles=((0.,.130,0.,0.),(.22,-.080,0.,0.),(.36,-.150,0.,.28),
          (.49,-.155,.060,.48),(.66,-.015,.085,.18),
          (.83,.110,.060,-.12),(1.,.130,0.,0.))
    for a,b in zip(cles,cles[1:]):
        if a[0]<=u<=b[0]:
            p=progression(a[0],b[0],u)
            avance,levee,pointe=(a[i]+p*(b[i]-a[i]) for i in (1,2,3))
            # Soulever la chaussure rigide autour de la pointe ou du talon,
            # au lieu d'enfoncer la semelle lorsque la cheville s'incline.
            bord=.24 if pointe>=0. else .10
            levee+=max(0.,bord*abs(math.sin(pointe))+.14*(math.cos(pointe)-1))
            return avance,levee,pointe


def pose_course(t,noeuds):
    demi_pas=t%.5
    # L'appui dure moins d'un demi-cycle : les deux pieds quittent le sol
    # entre les appuis. Le bassin monte alors sans replier davantage le genou.
    if demi_pas<.36:
        rebond=-.010-.003*math.sin(math.pi*demi_pas/.36)**2
    else:
        rebond=-.010+.032*math.sin(math.pi*(demi_pas-.36)/.14)**2
    rotations={};balancements={}
    for signe,cote in ((1,'gauche'),(-1,'droite')):
        u=(t+(.5 if signe>0 else 0.))%1.
        if u<.36:
            p=progression(0.,.36,u)
            avance=.095*(1-2*p);levee=0.
        else:
            p=progression(.36,1.,u)
            avance=-.095+.190*p
            levee=.020*math.sin(math.pi*(u-.36)/.64)**2
        balancements[cote]=avance/.095
        avance,levee,pointe=trajectoire_foulee(u)
        cuisse=-noeuds['tibia_'+cote]['translation'][1]
        bas=noeuds['pied_'+cote]['translation']
        tibia=math.hypot(bas[1],bas[2])
        hauteur=cuisse-bas[1]+rebond-levee-.006
        profondeur=bas[2]+avance
        distance=min(cuisse+tibia-.0001,math.hypot(hauteur,profondeur))
        hanche=math.atan2(-profondeur,hauteur)-math.acos(max(-1.,min(1.,
            (cuisse*cuisse+distance*distance-tibia*tibia)/(2*cuisse*distance))))
        genou=math.acos(max(-1.,min(1.,
            (distance*distance-cuisse*cuisse-tibia*tibia)/(2*cuisse*tibia))))
        genou+=math.atan2(bas[2],-bas[1])
        cheville=pointe-hanche-genou
        for nom,angle in (('cuisse_',hanche),('tibia_',genou),('pied_',cheville)):
            rotations[nom+cote]=quaternion(angle,0.,0.)
        # Tourner le bras APRES l'avoir abaisse place le balancement dans
        # le plan de course. Le bras recule quand la jambe du meme cote avance.
        balancement=.60*balancements[cote]-.10
        rotations['bras_'+cote]=composer_rotations(
            quaternion(balancement,0.,0.),quaternion(0.,0.,-signe*1.19))
        rotations['avant_bras_'+cote]=quaternion(0.,-signe*(1.05+.12*balancements[cote]),0.)
        rotations['main_'+cote]=quaternion(-.85 if cote=='droite' else 0.,signe*.06,0.)
    torsion=.19*(balancements['gauche']-balancements['droite'])*.5
    phase=math.tau*t
    rotations['torse']=quaternion(.25+.025*math.cos(2*phase),torsion,.035*math.sin(phase))
    # La tete accompagne la course tout en gardant le regard vers l'avant.
    rotations['tete']=quaternion(-.16,-torsion*.65,-.020*math.sin(phase))
    rotations['chapeau']=quaternion(.018*math.sin(2*phase-.5),0.,.018*math.sin(phase-.3))
    return rotations,rebond


def adoucir_course(chemin):
    doc,brut=lire_glb(chemin);binaire=bytearray(brut)
    noeuds={n['name']:n for n in doc['nodes'] if 'name' in n}
    animation=next(a for a in doc['animations'] if a['name']=='course')

    def adresse(indice):
        acc=doc['accessors'][indice];vue=doc['bufferViews'][acc['bufferView']]
        return acc,vue,vue.get('byteOffset',0)+acc.get('byteOffset',0)

    for canal in animation['channels']:
        cible=canal['target'];nom=doc['nodes'][cible['node']].get('name','')
        rotation=cible['path']=='rotation' and (nom.startswith(
            ('cuisse_','tibia_','pied_','bras_','avant_bras_','main_')) or nom in ('torse','tete','chapeau'))
        bassin=nom=='bassin' and cible['path']=='translation'
        if not rotation and not bassin:continue
        echantillons=animation['samplers'][canal['sampler']]
        acc,vue,debut=adresse(echantillons['input'])
        pas=vue.get('byteStride',4)
        instants=[struct.unpack_from('<f',binaire,debut+i*pas)[0] for i in range(acc['count'])]
        duree=instants[-1]-instants[0]
        sortie,vue,debut=adresse(echantillons['output'])
        largeur=4 if rotation else 3;pas=vue.get('byteStride',largeur*4)
        valeurs=[]
        for i,instant in enumerate(instants):
            t=(instant-instants[0])/duree
            poses,rebond=pose_course(0. if i==len(instants)-1 else t,noeuds)
            if rotation:valeur=poses[nom]
            else:
                valeur=list(noeuds['bassin']['translation']);valeur[1]+=rebond
            struct.pack_into('<'+'f'*largeur,binaire,debut+i*pas,*valeur)
            valeurs.append(valeur)
        if 'min' in sortie:sortie['min']=[min(v[i] for v in valeurs) for i in range(largeur)]
        if 'max' in sortie:sortie['max']=[max(v[i] for v in valeurs) for i in range(largeur)]
    # Des accesseurs propres au clip evitent de retimer les autres gestes.
    horaires={}
    for echantillons in animation['samplers']:
        indice=echantillons['input']
        if indice not in horaires:
            acc,vue,debut=adresse(indice);pas=vue.get('byteStride',4)
            instants=[struct.unpack_from('<f',binaire,debut+i*pas)[0] for i in range(acc['count'])]
            duree=instants[-1]-instants[0]
            instants=[.54*(v-instants[0])/duree for v in instants]
            while len(binaire)%4:binaire.append(0)
            offset=len(binaire)
            binaire.extend(struct.pack('<'+'f'*len(instants),*instants))
            doc['bufferViews'].append({'buffer':0,'byteOffset':offset,'byteLength':4*len(instants)})
            horaires[indice]=len(doc['accessors'])
            doc['accessors'].append({'bufferView':len(doc['bufferViews'])-1,'componentType':5126,
                'count':len(instants),'type':'SCALAR','min':[0.],'max':[.54]})
        echantillons['input']=horaires[indice]
    doc['buffers'][0]['byteLength']=len(binaire)
    doc.setdefault('extras',{})['bottes_sculptees_revision']=8
    # Conserver le marqueur de la passe precedente apres le reexport Blender.
    doc['extras']['vetement_sculpte_revision']=2
    ecrire_glb(chemin,doc,binaire)


def finaliser(chemin):
    doc,_=lire_glb(chemin)
    if doc.get('extras',{}).get('bottes_sculptees_revision')==8:return
    if doc.get('extras',{}).get('bottes_sculptees_revision') in (4,5,6,7):
        adoucir_course(chemin)
        return
    if doc.get('extras',{}).get('bottes_sculptees_revision'):
        raise ValueError('Repartir du GLB avant la premiere retouche des bottes.')
    bpy.ops.wm.read_factory_settings(use_empty=True)
    bpy.ops.import_scene.gltf(filepath=str(chemin))
    objet=bpy.data.objects['Mage_sculpte']
    rig=next(o for o in bpy.context.scene.objects if o.type=='ARMATURE')
    reprendre_bottes(objet,rig)
    bpy.ops.object.select_all(action='DESELECT');objet.select_set(True);rig.select_set(True)
    bpy.context.view_layer.objects.active=rig
    bpy.ops.export_scene.gltf(filepath=str(chemin),export_format='GLB',use_selection=True,
        export_animations=True,export_animation_mode='NLA_TRACKS',export_force_sampling=True,export_skins=True)
    adoucir_course(chemin)


if __name__=='__main__':
    finaliser(Path(sys.argv[sys.argv.index('--')+1]).resolve())
