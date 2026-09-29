"""Onze creatures originales : silhouette, visage et membres independants."""
import math
import build_all as b
from sculpture_bestiaire import articulation, courbe, regard, gemme, plume, pattes, pan_tissu

NOMS = ['encrier_rampant', 'plume_sentinelle', 'tache_veloce', 'scribe_essaimeur',
        'folio_orbiteur', 'sceau_belier', 'marge_harceleuse', 'miroir_encre',
        'cachet_phaseur', 'fuseau_tisseur', 'fiole_volatile']


def encrier():
    b.surface('Ventre', [(0,0,.12,.17,.17),(0,0,.22,.28,.25),(0,0,.42,.27,.24),
                        (0,0,.53,.20,.18)], 'violet', 20)
    b.anneau('Pied_du_pot', (0,0,.19), .22, .035, 'cuivre')
    b.anneau('Levre', (0,0,.52), .20, .039, 'cuivre')
    b.boule('Encre', (0,0,.49), (.185,.17,.038), 'encre')
    for c in (-1,1):
        courbe('Coulure', [(c*.19,-.10,.51),(c*.22,-.17,.41),(c*.18,-.22,.28)], [.034,.036,.016], 'encre')
    b.tige('Charniere', (-.095,.20,.54), (.095,.20,.54), .024, 'cuivre')
    with articulation('tete_0', (0,.20,.54)) as couvercle:
        b.cone('Couvercle', (0,0,.56), .205, .19, .038, 'cuivre')
        b.anneau('Bord_du_couvercle', (0,0,.555), .19, .013, 'cuivre')
        pierre = b.cone('Pierre_du_couvercle', (0,-.015,.598), .061, .028, .035, 'magie', 4)
        pierre.rotation_euler.z = math.pi/4
    couvercle.rotation_euler.x = -.62
    regard(-.24,.365,.107,.060)
    pattes()


def sentinelle():
    b.boule('Masque', (0,0,.32), (.20,.13,.20), 'encre')
    b.anneau('Collerette', (0,0,.23), .17, .035, 'cuivre')
    regard(-.13,.36,.076,.05)
    with articulation('tete_0', (0,0,.38)):
        courbe('Rachis', [(0,0,.22),(.015,.025,.56),(.13,.04,.94),(.18,.035,1.07)], [.030,.028,.018,.002], 'cuivre')
        for i in range(6):
            z = .42+i*.082
            x = .015+i*.022
            for c in (-1,1):
                plume('Barbe', (x,0,z), (x+c*(.19-i*.019),.01,z+.17), .044, 'papier' if i%2 == 0 else 'violet')
    for c in (-1,1):
        with articulation('aile_%s_0' % ('g' if c < 0 else 'd'), (c*.12,0,.29)):
            plume('Empennage', (c*.11,0,.30), (c*.31,.03,.15), .068, 'violet')
    with articulation('arme_0', (0,-.02,.30)):
        courbe('Bec_de_plume', [(0,-.08,.30),(0,-.27,.25),(0,-.44,.18)], [.06,.048,.002], 'cuivre', 6)
        b.tige('Fente', (0,-.22,.272),(0,-.4,.20), .009, 'encre')


def veloce():
    b.boule('Corps', (0,.015,.25), (.25,.30,.21), 'encre', 20)
    for i in range(3):
        ecaille = b.boule('Carapace', (0,.09+i*.09,.35-i*.025), (.215-i*.03,.16,.105), 'violet')
        ecaille.rotation_euler.x = -.3
    regard(-.255,.30,.106,.058)
    for c in (-1,1):
        courbe('Corne', [(c*.16,-.09,.39),(c*.25,-.02,.51),(c*.25,.09,.55)], [.044,.027,.002], 'papier')
    with articulation('queue_0', (0,.25,.24)):
        courbe('Queue', [(0,.22,.23),(0,.41,.19),(.10,.54,.25),(.14,.66,.34)], [.15,.10,.055,.002], 'violet', 12)
    pattes(4,.31,.22)


def scribe(harceleur=False):
    b.surface('Manteau', [(0,.04,.11,.24,.20),(0,.025,.31,.235,.17),
                         (0,0,.56,.14,.12),(0,0,.75,.22,.16)], 'violet', 18)
    for c in (-1,1):
        with articulation('pan_%s_0' % ('g' if c < 0 else 'd'), (c*.13,.02,.46)):
            pan_tissu('Pan_de_parchemin', [(c*.12,-.16,.58),(c*.15,-.205,.43),
                      (c*.22,-.22,.27),(c*.27,-.18,.11),(c*.29,-.13,.085)], [.058,.07,.083,.068,.055])
    b.anneau('Ceinture', (0,0,.46), .17, .027, 'cuivre').scale.y = .8
    gemme((0,-.155,.49),.073)
    with articulation('tete_0', (0,0,.73)):
        b.surface('Capuche', [(0,0,.72,.22,.17),(0,.025,.92,.22,.17),
                             (0,.10,1.07,.13,.115),(.04,.14,1.13,.01,.01)], 'violet', 18)
        b.boule('Visage', (0,-.147,.86), (.15,.075,.16), 'encre')
        regard(-.216,.90,.07,.044)
        for c in (-1,1):
            courbe('Revers', [(c*.13,-.14,.72),(c*.18,-.16,.84),(c*.13,-.14,1.0)], [.024,.029,.015], 'papier')
    for c in (-1,1):
        with articulation('bras_%s_0' % ('g' if c < 0 else 'd'), (c*.17,0,.71)):
            courbe('Manche', [(c*.18,0,.72),(c*.29,-.02,.61),(c*.33,-.12,.55)], [.10,.094,.07], 'violet', 10)
            b.boule('Main', (c*.34,-.14,.52), (.069,.06,.067), 'encre', 12)
            if harceleur:
                for i in range(3):
                    courbe('Griffe', [(c*(.3+i*.032),-.15,.50),(c*(.31+i*.043),-.24,.42),
                                     (c*(.30+i*.045),-.32,.46)], [.023,.019,.002], 'papier', 6)
            else:
                b.cone('Rouleau', (c*.36,-.15,.59), .065,.065,.41, 'papier',12)
                for z in (.41,.76):
                    b.anneau('Embout', (c*.36,-.15,z), .064,.018,'cuivre')


def folio():
    b.boite('Dos', (0,.015,.52), (.075,.22,.65), 'cuir', .028)
    for c in (-1,1):
        with articulation('livre_%s_0' % ('g' if c < 0 else 'd'), (0,0,.51)):
            b.boite('Couverture', (c*.18,.06,.52), (.36,.085,.62), 'cuir', .035)
            b.boite('Tranche', (c*.185,-.001,.52), (.30,.055,.53), 'papier', .018)
            for ligne, z in enumerate((.32,.385,.45,.58,.645,.71)):
                b.boite('Ligne_encree', (c*(.17+.013*(ligne%2)),-.034,z), (.12+.04*(ligne%3),.005,.007), 'bois', .002)
            for z in (.245,.795):
                b.boite('Coin', (c*.29,.005,z), (.125,.085,.037), 'cuivre', .01)
            gemme((c*.18,-.052,.52), .055)
    b.boule('Visage', (0,-.15,.46), (.125,.09,.17),'encre')
    regard(-.224,.51,.054,.039)
    with articulation('queue_0', (0,.02,.27)):
        courbe('Signet', [(0,0,.3),(0,-.035,.16),(.065,-.055,.10),(.1,-.015,.15)], [.043,.043,.035,.008], 'sang',6)


def belier():
    b.boule('Corps', (0,.05,.32), (.285,.33,.235), 'violet', 20)
    for z,y,r in ((.44,.16,.24),(.50,.03,.24),(.49,-.1,.23)):
        plaque = b.boule('Plaque', (0,y,z), (r,.13,.09), 'papier')
        plaque.rotation_euler.x = -.2
    pattes(4,.29,.23)
    with articulation('tete_0', (0,-.18,.38)):
        b.boule('Masque', (0,-.225,.35), (.225,.18,.18),'encre')
        cachet = b.cone('Bouclier_de_cire',(0,-.378,.30),.175,.16,.07,'sang',16)
        cachet.rotation_euler.x = math.pi/2
        b.anneau('Bord_du_cachet',(0,-.412,.3),.14,.024,'cuivre',(math.pi/2,0,0))
        b.boite('Glyphe', (0,-.437,.30),(.08,.019,.13),'papier',.008)
        regard(-.363,.44,.11,.043)
        for c in (-1,1):
            courbe('Corne', [(c*.16,-.14,.48),(c*.31,-.11,.58),(c*.37,-.24,.56),
                            (c*.33,-.34,.47),(c*.26,-.33,.46)], [.073,.068,.051,.033,.002], 'cuivre',10)


def miroir():
    pattes(4,.27,.20)
    with articulation('tete_0', (0,0,.36)):
        b.boule('Fond', (0,.01,.54), (.235,.075,.355), 'violet',20)
        b.boule('Verre_noir', (0,-.056,.54), (.189,.047,.294),'encre',20)
        cadre = b.anneau('Cadre',(0,-.065,.54),.227,.033,'cuivre',(math.pi/2,0,0))
        cadre.scale.y = 1.42
        regard(-.106,.59,.080,.05,'cristal')
        for c in (-1,1):
            courbe('Volute', [(c*.10,0,.84),(c*.21,0,.94),(c*.13,0,1.02),(c*.09,0,.97)], [.028,.026,.022,.004], 'cuivre')
        gemme((0,-.048,.88),.057,'cristal')
        courbe('Reflet_du_verre',[(-.12,-.09,.61),(-.09,-.102,.73),(-.02,-.096,.79)],[.008,.015,.008],'papier',6)


def phaseur():
    b.cone('Semelle', (0,0,.16), .265,.235,.13,'violet',16)
    for z in (.105,.22):
        b.anneau('Bague', (0,0,z), .245,.032,'cuivre')
    b.cone('Cire', (0,0,.092),.238,.238,.032,'sang',16)
    with articulation('tete_0', (0,0,.23)):
        b.surface('Poignee',[(0,0,.22,.12,.12),(0,0,.40,.085,.085),(0,0,.56,.15,.14),
                            (0,0,.73,.15,.14),(0,0,.79,.08,.08)],'violet',16)
        b.anneau('Col', (0,0,.40), .105,.026,'cuivre')
        regard(-.14,.66,.066,.043)
        gemme((0,-.01,.795),.065)
    for c in (-1,1):
        with articulation('aile_%s_0' % ('g' if c < 0 else 'd'),(c*.19,0,.19)):
            plume('Sceau_flottant',(c*.2,.02,.19),(c*.34,.05,.43),.075,'papier')


def tisseur():
    b.boule('Abdomen',(0,.13,.31),(.22,.25,.21),'violet',20)
    b.boule('Tete',(0,-.16,.29),(.16,.155,.13),'encre')
    regard(-.295,.32,.071,.045)
    pattes(6,.40,.28,'cuivre')
    with articulation('roue_0',(0,.10,.36)):
        b.cone('Bobine',(0,.11,.47),.13,.13,.18,'papier',16)
        for z in (.38,.56):
            b.cone('Flasque',(0,.11,z),.18,.18,.029,'cuivre',16)
        for z in (.42,.46,.50):
            b.anneau('Fil',(0,.11,z),.13,.012,'magie')
    for c in (-1,1):
        courbe('Mandibule',[(c*.08,-.23,.23),(c*.12,-.34,.20),(c*.035,-.385,.24)],[.035,.025,.002],'papier')


def volatile():
    b.boule('Cuve',(0,0,.35),(.25,.23,.285),'violet',20)
    b.boule('Reserve_lumineuse',(0,-.095,.32),(.195,.172,.20),'magie',20)
    for z,r in ((.17,.18),(.46,.23)):
        b.anneau('Cerclage',(0,0,z),r,.030,'cuivre')
    for c in (-1,1):
        courbe('Armature',[(c*.13,-.09,.14),(c*.23,-.05,.31),(c*.19,-.05,.49)], [.020,.024,.017],'cuivre')
    regard(-.25,.39,.085,.051)
    with articulation('bouchon_0',(0,0,.55)):
        b.cone('Col',(0,0,.61),.10,.075,.20,'cuivre',12)
        b.cone('Bouchon',(0,0,.745),.095,.11,.10,'violet',12)
        b.anneau('Bord',(0,0,.80),.105,.022,'cuivre')
        gemme((0,-.095,.747),.041)
    for c in (-1,1):
        with articulation('aile_%s_0' % ('g' if c < 0 else 'd'),(c*.16,.05,.45)):
            plume('Ailette',(c*.16,.05,.45),(c*.35,.05,.64),.072,'papier')


def construire(nom):
    fonctions = [encrier,sentinelle,veloce,scribe,folio,belier,lambda:scribe(True),
                 miroir,phaseur,tisseur,volatile]
    fonctions[NOMS.index(nom)]()
