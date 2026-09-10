"""Mage humain : silhouette simple et visage abrite par le grand chapeau."""
import math
import bpy


def construire(m):
    def matiere(nom,hexadecimal):
        rgb=[int(hexadecimal[i:i+2],16)/255 for i in (0,2,4)]
        couleur=tuple(c/12.92 if c<=.04045 else ((c+.055)/1.055)**2.4 for c in rgb)+(1,)
        mat=bpy.data.materials.new(nom);mat.use_nodes=True;mat.diffuse_color=couleur
        mat['alambik_matiere']=nom
        bsdf=mat.node_tree.nodes.get('Principled BSDF')
        bsdf.inputs['Base Color'].default_value=couleur
        bsdf.inputs['Roughness'].default_value=.88
        bsdf.inputs['Specular IOR Level'].default_value=.15
        m.b.MAT[nom]=mat
    for nom,couleur in [('robe','6844AC'),('ombre_robe','493479'),('ruban','329F9D'),
                         ('or_mat','DCB76A'),('peau_mate','B98362'),('cheveux_mats','503627'),
                         ('regard','342B38'),
                         ('bottes','343047'),('bois_mat','73503E'),('cristal_mat','A47EE9')]:
        matiere(nom,couleur)
    m.ZONE='corps'
    # Le bas evase forme une seule robe, plutot qu'un assemblage d'accessoires.
    m.tissu('Robe',[(0,0,.53,.26,.185),(0,0,.57,.27,.195),(0,0,.82,.224,.168),
        (0,0,1.08,.196,.15),(0,0,1.23,.22,.152),(0,0,1.29,.128,.11)],'robe')
    m.tissu('Ourlet_robe',[(0,0,.532,.263,.188),(0,0,.56,.274,.199),(0,0,.585,.269,.195)],'or_mat')
    for cote,nom in [(-1,'gauche'),(1,'droite')]:
        jambe='jambe_'+nom;tibia='tibia_'+nom;pied='pied_'+nom
        m.tissu('Jambe',[(cote*.119,0,.18,.068,.073),(cote*.119,0,.46,.072,.074),(cote*.119,0,.83,.074,.076)],'ombre_robe',jambe,(tibia,.46,.08))
        m.volume('Bottine',(cote*.119,-.035,.115),(.088,.137,.106),'bottes',pied)
        m.tissu('Haut_bottine',[(cote*.119,0,.12,.077,.08),(cote*.119,0,.33,.078,.077)],'bottes',tibia,(pied,.17,.03))
        bras='bras_'+('droit' if cote>0 else nom);avant='avant_'+bras
        m.tissu('Manche',[(cote*.37,-.035,.87,.095,.092),(cote*.37,-.028,.92,.103,.10),
            (cote*.325,0,1.065,.084,.081),(cote*.265,0,1.23,.087,.086),(cote*.224,0,1.27,.066,.071)],'robe',bras,(avant,1.035,.08))
        m.tissu('Poignet_dore',[(cote*.37,-.035,.866,.098,.095),(cote*.37,-.03,.915,.106,.103)],'or_mat',avant)
        m.volume('Main',(cote*.382,-.046,.829),(.050,.047,.064),'peau_mate','main_'+nom)
        m.volume('Pouce',(cote*.342,-.067,.83),(.022,.025,.038),'peau_mate','main_'+nom)
    # Col et echarpe courts, sans bijoux ni reliefs repetes.
    m.tissu('Col',[(0,0,1.24,.16,.125),(0,0,1.29,.163,.13),(0,0,1.36,.12,.105)],'ruban')
    m.courbe('Pli_echarpe',[(-.14,-.075,1.31),(-.08,-.142,1.265),(.045,-.144,1.26),(.145,-.07,1.32)],.023,'ruban')
    m.lame('Pan_echarpe',[(.11,.07,1.30),(.22,.15,1.24),(.26,.25,1.16),(.29,.30,1.13)],.071,'ruban','echarpe',epaisseur=.014,normale=(0,0,1))
    m.ZONE='tete'
    # Le menton et les tempes suffisent a identifier un humain sous le chapeau.
    m.volume('Cou',(0,.018,1.37),(.073,.067,.08),'peau_mate')
    m.tissu('Tete',[(0,0,1.405,.067,.077),(0,0,1.43,.105,.105),
        (0,0,1.49,.15,.134),(0,0,1.59,.174,.144),(0,0,1.70,.17,.14),
        (0,0,1.79,.12,.105),(0,0,1.82,.035,.035)],'peau_mate')
    for cote in [-1,1]:
        m.volume('Oreille',(cote*.164,.015,1.585),(.018,.024,.035),'peau_mate')
        m.volume('Regard',(cote*.058,-.135,1.624),(.020,.006,.009),'regard')
        m.lame('Tempe',[(cote*.12,.03,1.79),(cote*.175,.03,1.74),
            (cote*.179,.02,1.66),(cote*.161,.012,1.59)],.040,'cheveux_mats',epaisseur=.012,normale=(cote,0,0))
    m.volume('Nuque',(0,.075,1.715),(.161,.11,.115),'cheveux_mats')
    m.ZONE='chapeau'
    points=[];uv=[];faces=[];n=64
    for j,r in enumerate([.205,.24,.36,.445,.46]):
        for i in range(n+1):
            a=math.tau*i/n
            avant=max(0,math.cos(a))
            z=1.80-.035*avant+.018*math.sin(a)*(r/.46)
            points.append((r*math.sin(a),-.81*r*math.cos(a)*(1-.12*avant**2),z));uv.append((i/n,j/4))
    for j in range(4):
        for i in range(n):
            q=j*(n+1)+i;faces.append((q,q+1,q+n+2,q+n+1))
    o=m.maillage('Bord_chapeau',points,faces,'robe',uv)
    bpy.ops.object.select_all(action='DESELECT');o.select_set(True);bpy.context.view_layer.objects.active=o
    mod=o.modifiers.new('Epaisseur','SOLIDIFY');mod.thickness=.018;bpy.ops.object.modifier_apply(modifier=mod.name)
    m.lier(o,subdivisions=1)
    m.tissu('Chapeau',[(0,0,1.79,.225,.182),(0,0,1.90,.221,.18),(-.015,.015,2.02,.18,.147),
        (-.04,.018,2.16,.125,.107),(-.012,.012,2.28,.073,.063),(.08,.0,2.33,.047,.04),
        (.18,-.02,2.30,.028,.025),(.215,-.028,2.25,.002,.002)],'robe')
    m.tissu('Ruban_chapeau',[(0,0,1.85,.229,.186),(0,0,1.895,.226,.184),(0,0,1.934,.213,.174)],'or_mat')
    m.ZONE='corps'
    main='main_droite';x=.422;y=-.085
    m.courbe('Baguette',[(x,y,.64),(x,y,1.20)],.023,'bois_mat',main)
    m.volume('Sertissage',(x,y,1.22),(.052,.049,.039),'or_mat',main)
    o=m.lier(m.b.boule('Gemme',(x,y,1.315),(.052,.052,.093),'cristal_mat',12),main)
    for f in o.data.polygons:f.use_smooth=False
