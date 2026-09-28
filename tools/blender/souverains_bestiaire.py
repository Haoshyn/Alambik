"""Silhouettes des dix gardiens et dix souverains alchimiques."""
import math
import build_all as b
import creatures_bestiaire as c
from sculpture_bestiaire import articulation, courbe, regard, gemme, plume, pattes


def couronne(z, mat='cuivre', nombre=5, rayon=.18):
    b.anneau('Diademe',(0,0,z),rayon,.028,mat)
    for i in range(nombre):
        a = math.tau*i/nombre
        x,y = math.cos(a)*rayon, math.sin(a)*rayon
        courbe('Fleuron',[(x,y,z),(x*1.13,y*1.13,z+.14),(x*.9,y*.9,z+.25)], [.046,.029,.002],mat,6)


def aureole(z=1.02, mat='cuivre'):
    with articulation('roue_1',(0,.14,z)):
        b.anneau('Nimbe',(0,.14,z),.32,.024,mat,(math.pi/2,0,0))
        for i in range(7):
            a = math.tau*i/7
            x,h = math.sin(a)*.34, math.cos(a)*.34
            gemme((x,.125,z+h),.031)


def bras_lourds(mat='metal', rune='feu', arme=False):
    for cote in (-1,1):
        with articulation('bras_%s_0' % ('g' if cote < 0 else 'd'),(cote*.24,0,.78)):
            b.boule('Epaulette',(cote*.30,0,.76),(.20,.22,.16),mat)
            b.anneau('Bord_epaule',(cote*.30,0,.75),.165,.027,'cuivre')
            b.boite('Avant_bras',(cote*.39,-.02,.49),(.23,.24,.26),mat,.05)
            b.boule('Poing',(cote*.40,-.08,.31),(.14,.15,.12),'encre')
            gemme((cote*.4,-.149,.52),.074,rune)
            if arme and cote == 1:
                b.tige('Manche',(cote*.44,-.14,.20),(cote*.44,-.14,.95),.032,'cuivre')
                b.boite('Marteau',(cote*.44,-.14,1.02),(.32,.24,.23),mat,.044)
                gemme((cote*.44,-.272,1.02),.073,rune)


def gardien(mat='metal', rune='feu', arme=True):
    b.surface('Plastron',[(0,0,.29,.17,.16),(0,0,.49,.29,.22),(0,0,.73,.26,.21),
                         (0,0,.84,.21,.16)],mat,12)
    b.boule('Foyer',(0,-.21,.58),(.17,.072,.20),rune,16)
    for x in (-.095,0,.095):
        b.tige('Barreau',(x,-.26,.43),(x,-.275,.73),.017,'cuivre')
    b.anneau('Ceinture',(0,0,.36),.21,.032,'cuivre')
    for cote in (-1,1):
        with articulation('patte_%s_0' % ('g' if cote < 0 else 'd'),(cote*.15,0,.31)):
            b.boite('Cuisse',(cote*.15,0,.26),(.17,.20,.15),mat,.04)
            with articulation('tibia_%s_0' % ('g' if cote < 0 else 'd'),(cote*.15,-.025,.19)):
                b.boite('Tibia',(cote*.15,-.015,.16),(.16,.18,.15),mat,.035)
                b.boite('Soleret',(cote*.16,-.07,.075),(.23,.34,.13),'encre',.04)
                with articulation('appui_%s_0' % ('g' if cote < 0 else 'd'),(cote*.16,-.07,.075)) as appui:
                    appui.name = 'Appui_%s_0' % ('g' if cote < 0 else 'd')
    with articulation('tete_0',(0,0,.84)):
        b.boule('Casque',(0,0,.985),(.18,.17,.19),mat)
        regard(-.16,1.0,.068,.046,rune)
        couronne(1.12, 'cuivre' if arme else 'pierre_claire')
    bras_lourds(mat,rune,arme)


def ailes(mat='papier', ombre=False):
    for cote in (-1,1):
        with articulation('aile_%s_0' % ('g' if cote < 0 else 'd'),(cote*.20,.10,.72)):
            for i in range(4):
                plume('Penne',(cote*.20,.12,.70-i*.05),
                      (cote*(.43+i*.09),.16,1.1-i*.17),.072,mat)
            if ombre:
                courbe('Armature_aile',[(cote*.2,.1,.7),(cote*.52,.13,1.11),(cote*.64,.16,.62)], [.024,.031,.006],'cuivre')


def hydre():
    b.boule('Cuve',(0,.08,.34),(.34,.27,.27),'violet',20)
    b.anneau('Ceinture',(0,.08,.28),.30,.041,'cuivre')
    pattes(4,.30,.20)
    for i in (-1,0,1):
        z = .96 if i == 0 else .77
        x = i*.28
        with articulation('tete_%d' % (i+1),(i*.14,.04,.46)):
            courbe('Cou',[(i*.12,.02,.44),(x,.04,.61),(x,-.04,z)], [.088,.072,.09],'violet',12)
            b.boule('Gueule',(x,-.09,z),(.145,.185,.11),'encre')
            b.boule('Venin',(x,-.075,z+.06),(.14,.14,.085),'venin')
            for cote in (-1,1):
                b.boule('Oeil',(x+cote*.074,-.224,z+.054),(.04,.025,.035),'papier',10)
                courbe('Croc',[(x+cote*.064,-.24,z-.02),(x+cote*.060,-.25,z-.085)], [.021,.001],'papier',6)
                courbe('Corne',[(x+cote*.1,.015,z+.06),(x+cote*.145,.075,z+.23)], [.042,.001],'cuivre',6)


def devoreur():
    with articulation('tete_0',(0,0,.57)):
        b.boule('Gorge',(0,0,.62),(.32,.21,.36),'encre',20)
        b.anneau('Machoire',(0,-.12,.62),.29,.078,'violet',(math.pi/2,0,0))
        for i in range(12):
            a = math.tau*i/12
            x,z = math.cos(a),math.sin(a)
            courbe('Croc',[(x*.265,-.20,.62+z*.265),(x*.18,-.24,.62+z*.18)], [.039,.001],'papier',6)
        gemme((0,-.22,.94),.065)
    for cote in (-1,1):
        with articulation('bras_%s_0' % ('g' if cote < 0 else 'd'),(cote*.22,0,.59)):
            courbe('Pince',[(cote*.20,0,.59),(cote*.44,-.02,.39),(cote*.47,-.14,.19),
                           (cote*.33,-.23,.28)], [.08,.075,.046,.002],'violet',10)
    with articulation('queue_0',(0,.12,.51)):
        courbe('Queue',[(0,.1,.55),(0,.26,.28),(.16,.30,.13),(.30,.25,.22)], [.20,.14,.07,.002],'encre',12)
    aureole(.70)


def alambic():
    b.surface('Chaudron',[(0,0,.12,.21,.20),(0,0,.31,.35,.31),(0,0,.60,.31,.28),
                         (0,0,.73,.22,.21)],'violet',20)
    for z,r in ((.22,.31),(.58,.32),(.71,.23)):
        b.anneau('Cerclage',(0,0,z),r,.036,'cuivre')
    regard(-.294,.50,.12,.069,'feu')
    pattes(4,.32,.23,'cuivre')
    with articulation('bouchon_0',(0,0,.72)):
        b.cone('Couvercle',(0,0,.82),.24,.105,.18,'cuivre',16)
        b.boule('Reserve',(0,0,.98),(.12,.12,.15),'feu')
        b.anneau('Col',(0,0,1.08),.09,.02,'cuivre')
    for cote in (-1,1):
        with articulation('bras_%s_0' % ('g' if cote < 0 else 'd'),(cote*.21,.06,.57)):
            courbe('Serpentin',[(cote*.23,.04,.55),(cote*.44,.04,.69),(cote*.43,.04,.97),
                               (cote*.30,.04,1.12)], [.041,.038,.034,.029],'cuivre',10)
            b.boule('Ampoule',(cote*.43,.04,.94),(.115,.105,.18),'feu')
            b.anneau('Collier_ampoule',(cote*.43,.04,.90),.115,.021,'cuivre')


def signature(index):
    if index == 1:
        gardien()
    elif index == 4:
        hydre()
    elif index == 7:
        gardien('pierre','cristal',False)
        for cote in (-1,1):
            for i in range(3):
                b.boite('Rune', (cote*.17,-.199,.48+i*.09),(.045,.025,.041),'papier',.008)
    elif index == 8:
        devoreur()
    elif index == 9:
        alambic()
    else:
        c.scribe(index == 6)
        if index == 0:
            aureole()
            for cote in (-1,1):
                with articulation('aile_%s_0' % ('g' if cote < 0 else 'd'),(cote*.2,.13,.68)):
                    for i in range(3):
                        plume('Page_decollee',(cote*.20,.13,.62+i*.06),(cote*(.42+i*.06),.16,.83+i*.12),.075)
            couronne(1.10)
        elif index == 2:
            couronne(1.11,'givre',7,.20)
            ailes('givre')
            for i in range(7):
                a = math.tau*i/7
                b.cone('Cristal',(math.cos(a)*.26,math.sin(a)*.23,.19),.065,0,.30,'givre',5)
        elif index == 3:
            ailes('cuivre')
            aureole(1.04,'cristal')
            gemme((0,-.23,1.01),.071,'cristal')
        elif index == 5:
            for cote in (-1,1):
                with articulation('tete_%d' % (1 if cote < 0 else 2),(cote*.32,.04,.73)):
                    b.boule('Masque_du_choeur',(cote*.33,.035,.96),(.13,.10,.18),'papier')
                    for x in (-.04,.04):
                        b.boule('Regard',(cote*.33+x,-.062,1.0),(.025,.012,.045),'encre',10)
                    b.boule('Chant',(cote*.33,-.071,.90),(.045,.016,.065),'encre',12)
            aureole(1.10)
        elif index == 6:
            ailes('encre',True)
            couronne(1.1,'sang',5,.21)


def miniature(index):
    if index == 1:
        c.encrier()
        with articulation('bouchon_0',(0,.08,.51)):
            b.fiole((0,.08,.51),.13,'feu')
    elif index == 3:
        c.folio()
        for cote in (-1,1):
            for i in range(4):
                x = cote*(.07+i*.073)
                courbe('Dent',[(x,-.10,.72),(x,-.14,.62)],[.027,.001],'papier',6)
                courbe('Dent',[(x,-.10,.30),(x,-.14,.38)],[.027,.001],'papier',6)
    elif index == 5:
        pattes(4,.29,.22)
        b.boite('Armoire',(0,.04,.51),(.49,.32,.68),'violet',.045)
        with articulation('tete_0',(0,0,.44)):
            for z in range(3):
                for cote in (-1,1):
                    b.boite('Tiroir',(cote*.125,-.14,.29+z*.21),(.22,.10,.18),'papier',.022)
                    gemme((cote*.125,-.206,.29+z*.21),.029)
            regard(-.20,.90,.087,.039)
    else:
        c.scribe(index in (0,6,8))
        if index == 0:
            for z in (.33,.51,.68):
                b.anneau('Rature',(0,0,z),.21,.022,'papier').scale.y = .83
        elif index == 2:
            with articulation('arme_0',(-.31,-.11,.58)):
                b.boite('Bouclier',(-.35,-.15,.56),(.25,.075,.43),'cuivre',.04)
                gemme((-.35,-.195,.56),.08)
        elif index == 4:
            with articulation('roue_0',(0,0,1.15)):
                courbe('Virgule',[(.10,0,1.23),(-.05,0,1.30),(-.14,0,1.21),(-.12,0,1.07),(.03,0,1.01)], [.07,.11,.09,.04,.001],'encre',12)
        elif index == 6:
            b.boule('Cri',(0,-.228,.80),(.072,.017,.077),'encre')
            ailes('papier')
        elif index == 7:
            with articulation('arme_0',(.34,-.14,.53)):
                b.tige('Pinceau',(.37,-.15,.20),(.37,-.15,1.12),.027,'cuivre')
                courbe('Brosse',[(.37,-.15,1.1),(.39,-.15,1.24),(.45,-.15,1.32)],[.085,.065,.002],'feu',12)
        elif index == 8:
            with articulation('arme_0',(.34,-.14,.54)):
                b.boite('Garde',(.36,-.17,.58),(.18,.035,.045),'cuivre',.012)
                courbe('Lame',[(.36,-.17,.60),(.36,-.17,.85),(.38,-.17,1.07)],[.042,.039,.001],'papier',6)
            courbe('Signet',[(0,-.17,.76),(0,-.2,.44),(.1,-.15,.13)], [.055,.07,.013],'sang',6)
        elif index == 9:
            with articulation('livre_g_0',(0,-.20,.56)):
                b.boite('Pupitre',(0,-.30,.53),(.45,.25,.06),'cuivre',.025)
                b.boite('Page',(0,-.31,.57),(.39,.21,.015),'papier',.004)
