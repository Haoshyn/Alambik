"""Mage alchimiste : feutre souple, manteau taille et outils de voyage."""
import math
import bpy
from mathutils import Vector


def construire(m):
    def matiere(nom,hexadecimal):
        rgb=[int(hexadecimal[i:i+2],16)/255 for i in (0,2,4)]
        couleur=tuple(c/12.92 if c<=.04045 else ((c+.055)/1.055)**2.4 for c in rgb)+(1,)
        mat=bpy.data.materials.new(nom);mat.use_nodes=True;mat.diffuse_color=couleur
        mat['alambik_matiere']=nom
        bsdf=mat.node_tree.nodes.get('Principled BSDF')
        bsdf.inputs['Base Color'].default_value=couleur
        bsdf.inputs['Roughness'].default_value=.88
        bsdf.inputs['Specular IOR Level'].default_value=.25
        if nom=='or_mat':
            bsdf.inputs['Metallic'].default_value=.65
            bsdf.inputs['Roughness'].default_value=.32
        elif nom=='cristal_mat':
            bsdf.inputs['Roughness'].default_value=.22
            bsdf.inputs['Emission Color'].default_value=couleur
            bsdf.inputs['Emission Strength'].default_value=.22
        elif nom in ('robe','ombre_robe','ruban'):
            bsdf.inputs['Sheen Weight'].default_value=.22
        m.b.MAT[nom]=mat
    for nom,couleur in [('robe','65449D'),('ombre_robe','342747'),('ruban','32B7B0'),
                         ('or_mat','DDB778'),('peau_mate','B98362'),('cheveux_mats','503627'),
                         ('regard','342B38'),
                         ('bottes','343047'),('bois_mat','73503E'),('cristal_mat','A47EE9')]:
        matiere(nom,couleur)
    # Les volumes secondaires restent peu subdivises pour le rendu mobile.
    def volume(nom,pos,taille,mat,os='racine'):
        return m.lier(m.b.boule(nom,pos,taille,mat,16),os)
    m.ZONE='corps'
    # Le bas evase forme une seule robe, plutot qu'un assemblage d'accessoires.
    m.tissu('Robe',[(0,0,.53,.26,.185),(0,0,.57,.27,.195),(0,0,.82,.224,.168),
        (0,0,1.08,.196,.15),(0,0,1.23,.22,.152),(0,0,1.29,.128,.11)],'ombre_robe')
    m.tissu('Ourlet_robe',[(0,0,.532,.263,.188),(0,0,.56,.274,.199),(0,0,.585,.269,.195)],'or_mat')
    for cote,nom in [(-1,'gauche'),(1,'droite')]:
        jambe='jambe_'+nom;tibia='tibia_'+nom;pied='pied_'+nom
        m.tissu('Jambe',[(cote*.119,0,.18,.068,.073),(cote*.119,0,.46,.072,.074),(cote*.119,0,.83,.074,.076)],'ombre_robe',jambe,(tibia,.46,.08))
        volume('Bottine',(cote*.119,-.035,.115),(.088,.137,.106),'bottes',pied)
        m.tissu('Haut_bottine',[(cote*.119,0,.12,.077,.08),(cote*.119,0,.33,.078,.077)],'bottes',tibia,(pied,.17,.03))
        bras='bras_'+('droit' if cote>0 else nom);avant='avant_'+bras
        m.tissu('Manche',[(cote*.37,-.035,.87,.095,.092),(cote*.37,-.028,.92,.103,.10),
            (cote*.325,0,1.065,.084,.081),(cote*.265,0,1.23,.087,.086),(cote*.224,0,1.27,.066,.071)],'robe',bras,(avant,1.035,.08))
        m.tissu('Poignet_dore',[(cote*.37,-.035,.866,.098,.095),(cote*.37,-.03,.915,.106,.103)],'or_mat',avant)
        volume('Main',(cote*.382,-.046,.829),(.050,.047,.064),'peau_mate','main_'+nom)
        volume('Pouce',(cote*.342,-.067,.83),(.022,.025,.038),'peau_mate','main_'+nom)
    # Les pans ouverts dessinent une taille et degagent la marche de face.
    for cote in [-1,1]:
        points=[];faces=[]
        for j,(z,rx,ry) in enumerate([(1.25,.224,.135),(1.12,.205,.148),(.94,.215,.18),(.75,.26,.203),(.54,.31,.225)]):
            for i in range(13):
                a=.22+i/12*2.75
                ondulation=1+.028*math.sin(a*5+j*.7)
                points.append((cote*rx*math.sin(a)*ondulation,-ry*math.cos(a),z+.04*math.sin(a) if j==4 else z))
        for j in range(4):
            for i in range(12):
                q=j*13+i;face=(q,q+1,q+14,q+13)
                faces.append(tuple(reversed(face)) if cote==1 else face)
        o=m.maillage('Pan_manteau',points,faces,'robe')
        m.lier(o,subdivisions=1)
        m.courbe('Bord_manteau',[(cote*.047,-.158,1.10),(cote*.047,-.175,.95),(cote*.061,-.206,.72),(cote*.074,-.221,.55)],.009,'or_mat')
        m.courbe('Couture_manteau',[(cote*.19,-.088,1.13),(cote*.201,-.09,.91),(cote*.266,-.115,.59)],.004,'ombre_robe')
    m.tissu('Ceinture',[(0,0,.96,.221,.187),(0,0,1.015,.217,.182)],'bois_mat')
    m.courbe('Boucle_ceinture',[(-.027,-.188,.968),(-.029,-.191,1.01),(.031,-.191,1.01),(.03,-.188,.968),(-.027,-.188,.968)],.009,'or_mat')
    # La pelerine relie visuellement les epaules au col.
    m.tissu('Pelerine',[(0,.023,1.12,.29,.18),(0,.02,1.15,.299,.185),(0,.015,1.25,.257,.157),(0,.012,1.335,.105,.085)],'ombre_robe')
    m.courbe('Galon_pelerine',[(-.286,-.028,1.14),(-.20,-.137,1.145),(0,-.167,1.14),(.20,-.137,1.145),(.286,-.028,1.14)],.009,'or_mat')
    m.tissu('Col',[(0,0,1.24,.16,.125),(0,0,1.29,.163,.13),(0,0,1.36,.12,.105)],'ruban')
    m.courbe('Pli_echarpe',[(-.14,-.075,1.31),(-.08,-.142,1.265),(.045,-.144,1.26),(.145,-.07,1.32)],.023,'ruban')
    m.lame('Pan_echarpe',[(.11,.07,1.30),(.22,.15,1.24),(.26,.25,1.16),(.29,.30,1.13)],.071,'ruban','echarpe',epaisseur=.014,normale=(0,0,1))
    volume('Noeud_echarpe',(-.105,-.132,1.30),(.072,.038,.047),'ruban')
    m.lame('Echarpe_retour',[(.11,.085,1.3),(.12,.21,1.23),(.03,.33,1.08),(-.07,.34,1.10)],.065,'ruban','echarpe',epaisseur=.012,normale=(0,0,1))
    volume('Broche',(.073,-.139,1.275),(.032,.014,.038),'or_mat')
    volume('Coeur_broche',(.073,-.151,1.278),(.016,.008,.021),'cristal_mat')
    # Sacoche et fioles restent contre le corps, hors du geste de la baguette.
    volume('Sacoche',(-.255,.06,.875),(.103,.068,.125),'bois_mat')
    volume('Rabat_sacoche',(-.257,-.007,.924),(.105,.026,.062),'bottes')
    volume('Fermoir_sacoche',(-.258,-.032,.902),(.019,.01,.021),'or_mat')
    m.courbe('Sangle_sacoche',[(-.24,.025,1.02),(-.29,-.008,.977),(-.28,-.025,.91)],.012,'bois_mat')
    for x,z in [(-.145,.90),(-.06,.87)]:
        volume('Potion',(x,-.207,z),(.029,.026,.044),'ruban')
        m.tissu('Col_fiole',[(x,-.207,z+.025,.016,.016),(x,-.207,z+.060,.016,.016)],'or_mat',n=12)
        volume('Bouchon',(x,-.207,z+.065),(.02,.019,.012),'bois_mat')
    m.ZONE='tete'
    # Le menton et les tempes suffisent a identifier un humain sous le chapeau.
    volume('Cou',(0,.018,1.37),(.073,.067,.08),'peau_mate')
    m.tissu('Tete',[(0,0,1.405,.067,.077),(0,0,1.43,.105,.105),
        (0,0,1.49,.15,.134),(0,0,1.59,.174,.144),(0,0,1.70,.17,.14),
        (0,0,1.76,.12,.105),(0,0,1.78,.035,.035)],'peau_mate')
    volume('Nez',(0,-.137,1.56),(.025,.024,.032),'peau_mate')
    for cote in [-1,1]:
        volume('Oreille',(cote*.164,.015,1.585),(.018,.024,.035),'peau_mate')
        volume('Regard',(cote*.058,-.135,1.624),(.020,.006,.009),'regard')
        m.lame('Tempe',[(cote*.12,.03,1.79),(cote*.175,.03,1.74),
            (cote*.179,.02,1.66),(cote*.161,.012,1.59)],.040,'cheveux_mats',epaisseur=.012,normale=(cote,0,0))
    volume('Nuque',(0,.075,1.69),(.158,.10,.095),'cheveux_mats')
    m.ZONE='chapeau'
    points=[];uv=[];faces=[];n=64
    for j,r in enumerate([.205,.24,.36,.445,.46]):
        for i in range(n+1):
            a=math.tau*i/n
            avant=max(0,math.cos(a))
            z=1.80-.045*avant+(r/.46)**2*(.038*math.sin(2*a+.5)+.028*math.sin(a))
            points.append((r*math.sin(a)*(1+.045*math.sin(a)),-.81*r*math.cos(a)*(1-.12*avant**2),z));uv.append((i/n,j/4))
    for j in range(4):
        for i in range(n):
            q=j*(n+1)+i;faces.append((q,q+1,q+n+2,q+n+1))
    o=m.maillage('Bord_chapeau',points,faces,'robe',uv)
    bpy.ops.object.select_all(action='DESELECT');o.select_set(True);bpy.context.view_layer.objects.active=o
    mod=o.modifiers.new('Epaisseur','SOLIDIFY');mod.thickness=.018;bpy.ops.object.modifier_apply(modifier=mod.name)
    m.lier(o,subdivisions=1)
    bord=[]
    for i in range(33):
        a=math.tau*i/32;avant=max(0,math.cos(a));r=.46
        bord.append((r*math.sin(a)*(1+.045*math.sin(a)),-.81*r*math.cos(a)*(1-.12*avant**2),1.80-.045*avant+.038*math.sin(2*a+.5)+.028*math.sin(a)))
    m.courbe('Lisere_chapeau',bord,.009,'or_mat')
    # Les sections suivent la courbure pour ne pas pincer la pointe rabattue.
    sections=[(0,0,1.71,.225,.182),(0,0,1.76,.225,.182),(0,0,1.90,.221,.18),
        (-.015,.015,2.02,.18,.147),(-.065,.025,2.16,.132,.108),
        (-.035,.012,2.29,.086,.071),(.065,-.008,2.37,.058,.048),
        (.185,-.035,2.34,.039,.032),(.26,-.05,2.26,.02,.016),(.27,-.05,2.22,.001,.001)]
    points=[];faces=[];n=32
    for j,section in enumerate(sections):
        centre=Vector(section[:3])
        tangente=Vector(sections[min(j+1,len(sections)-1)][:3])-Vector(sections[max(0,j-1)][:3])
        tangente.normalize()
        axe=Vector((tangente.z,0,-tangente.x)).normalized()
        profondeur=tangente.cross(axe).normalized()
        for i in range(n):
            a=math.tau*i/n
            points.append(centre+axe*math.cos(a)*section[3]+profondeur*math.sin(a)*section[4])
    for j in range(len(sections)-1):
        for i in range(n):
            faces.append((j*n+i,j*n+(i+1)%n,(j+1)*n+(i+1)%n,(j+1)*n+i))
    faces.extend([tuple(reversed(range(n))),tuple(range((len(sections)-1)*n,len(sections)*n))])
    m.lier(m.maillage('Chapeau',points,faces,'robe'),subdivisions=1)
    m.tissu('Ruban_chapeau',[(0,0,1.85,.229,.186),(0,0,1.895,.226,.184),(0,0,1.934,.213,.174)],'bois_mat')
    volume('Insigne_chapeau',(-.075,-.177,1.90),(.042,.014,.050),'or_mat')
    volume('Pierre_chapeau',(-.075,-.19,1.90),(.024,.008,.030),'ruban')
    m.ZONE='corps'
    main='main_droite';x=.422;y=-.085
    m.courbe('Baguette',[(x,y,.64),(x,y,1.20)],.023,'bois_mat',main)
    volume('Sertissage',(x,y,1.22),(.052,.049,.039),'or_mat',main)
    o=m.lier(m.b.boule('Gemme',(x,y,1.315),(.052,.052,.093),'cristal_mat',12),main)
    for f in o.data.polygons:f.use_smooth=False

    # La tete de cornue donne a l'arme une silhouette propre a l'alchimiste.
    m.courbe('Cornue',[(x-.042,y,1.22),(x-.087,y,1.30),(x-.069,y,1.41),(x+.009,y,1.45),(x+.091,y,1.38),(x+.09,y,1.33)],.014,'or_mat',main)
    m.courbe('Bec_cornue',[(x+.09,y,1.33),(x+.118,y,1.35),(x+.133,y,1.39)],.011,'or_mat',main)
    for z in [.72,.77,.82]:
        m.tissu('Prise_baguette',[(x,y,z,.027,.027),(x,y,z+.023,.027,.027)],'bottes',main,n=12)
