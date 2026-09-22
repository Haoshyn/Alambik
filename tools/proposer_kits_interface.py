"""Six explorations de DA, hors du jeu : SVG independants et compositions portrait."""
from pathlib import Path
from html import escape
import base64
import json
import shutil

RACINE = Path(__file__).resolve().parents[1]
SORTIE = RACINE / 'propositions/interface_magique'
SORTIE.mkdir(parents=True, exist_ok=True)
(SORTIE / '.gdignore').write_text('')
COMMUN = SORTIE / 'commun'
COMMUN.mkdir(exist_ok=True)
SOURCE_MAGE = Path('/home/giovanni/.codex/generated_images/01a0c945-4084-7ca0-a43c-36be637bad32/exec-65279612-b575-4cd0-8076-7da289382462.png')
shutil.copy2(SOURCE_MAGE, COMMUN / 'mage.png')
MAGE = 'data:image/png;base64,' + base64.b64encode(SOURCE_MAGE.read_bytes()).decode()

THEMES = [
 dict(id='A',nom='Cartoon arcanique',origine='Piste A · formes rondes et contours francs',forme='rond',fond='#a6a8dc',fond2='#7e83bd',panneau='#46385f',bord='#302540',action='#42d5da',action2='#269ea9',papier='#fff0d2',texte='#fff4dd',encre='#302540',accent='#ffce78',second='#9272cd',icone='#71e0df'),
 dict(id='B',nom='Magie graphique',origine='Piste B · facettes simples et aplats',forme='angle',fond='#647fac',fond2='#415b8c',panneau='#253e6b',bord='#1a2c51',action='#ffce62',action2='#d8993e',papier='#f3eddb',texte='#fff1cf',encre='#243355',accent='#ffce62',second='#547cbd',icone='#78d9f0'),
 dict(id='C',nom='Alchimie pop',origine='Piste C · capsules souples et couleurs chaudes',forme='pop',fond='#b792bd',fond2='#91699f',panneau='#583968',bord='#482b58',action='#ff858a',action2='#d95677',papier='#fff2dc',texte='#fff2dc',encre='#513354',accent='#ffcba0',second='#a968c9',icone='#f9bba4'),
 dict(id='D',nom='Hologramme arcanique',origine='Références · contours lumineux des kits Hologram',forme='holo',fond='#567b99',fond2='#345575',panneau='#203e56',bord='#75ede3',action='#68e8d5',action2='#31acae',papier='#d9f4ed',texte='#e6fff5',encre='#173b4b',accent='#bba6f2',second='#357a8e',icone='#83f5e5'),
 dict(id='E',nom='Laboratoire de potions',origine='Références · silhouettes et couleurs des fioles',forme='fiole',fond='#9796ce',fond2='#6b71ac',panneau='#423c77',bord='#322e60',action='#8ae5e8',action2='#50abbc',papier='#f0edff',texte='#f8f0ff',encre='#3b3668',accent='#ffc37b',second='#aa8fda',icone='#8fe7ed'),
 dict(id='F',nom='Sceaux de combat',origine='Références · sorts cyan et ambre, emblèmes RPG',forme='sceau',fond='#7d8ab9',fond2='#545f96',panneau='#34345c',bord='#242543',action='#f4b36d',action2='#ce824e',papier='#f9ecd9',texte='#fff1db',encre='#323251',accent='#78dbe8',second='#6d68b2',icone='#ffca87'),
]

def svg(w,h,corps):
 return f'<svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" width="{w}" height="{h}" viewBox="0 0 {w} {h}">{corps}</svg>'

def groupe(x,y,corps,echelle=1):
 return f'<g transform="translate({x} {y}) scale({echelle})">{corps}</g>'

def texte(x,y,s,taille=28,couleur='#fff',gras=400,ancre='start'):
 return f'<text x="{x}" y="{y}" font-family="DejaVu Sans,sans-serif" font-size="{taille}" font-weight="{gras}" text-anchor="{ancre}" fill="{couleur}">{escape(s)}</text>'

def forme(t,w,h,couleur,bord=None,ep=5,m=5):
 bord=bord or t['bord'];k=t['forme'];r=min(30,h*.22)
 attr=f'fill="{couleur}" stroke="{bord}" stroke-width="{ep}" stroke-linejoin="round"'
 if k in ['angle','sceau']:
  c=min(26,h*.24)
  d=f'M{m+c} {m}H{w-m-c}L{w-m} {m+c}V{h-m-c}L{w-m-c} {h-m}H{m+c}L{m} {h-m-c}V{m+c}Z'
 elif k=='pop':
  d=f'M{r+6} {m+3}Q{w*.5} {-1} {w-r} {m}Q{w-m} {m} {w-m} {r}V{h-r}Q{w-m} {h-m} {w-r} {h-m}Q{w*.5} {h-1} {r} {h-m-2}Q{m} {h-m} {m} {h-r}V{r}Q{m} {m+3} {r+6} {m+3}Z'
 else:
  return f'<rect x="{m}" y="{m}" width="{w-2*m}" height="{h-2*m}" rx="{r if k!= "fiole" else min(h*.38,48)}" {attr}/>'
 return f'<path d="{d}" {attr}/>'

def etoile(x,y,r,c):
 return f'<path d="M{x} {y-r}Q{x+r*.22} {y-r*.2} {x+r} {y}Q{x+r*.22} {y+r*.2} {x} {y+r}Q{x-r*.22} {y+r*.2} {x-r} {y}Q{x-r*.22} {y-r*.2} {x} {y-r}Z" fill="{c}"/>'

def surface(t,role,w,h,etat='normal'):
 fill=t['papier'] if role=='lecture' else t['action'] if role=='principal' else t['panneau'] if role in ['navigation','compteur'] else t['second']
 if etat=='desactive': fill='#9695ab'
 if etat=='presse': fill=t['action2'] if role=='principal' else t['fond2']
 s=forme(t,w,h,t['bord'])
 s+=groupe(0,-5 if etat!='presse' else 0,forme(t,w,h-6,fill))
 if role=='principal':
  s+=f'<path d="M38 22H{w-38}" stroke="{t["papier"]}" stroke-width="5" stroke-opacity=".55" stroke-linecap="round"/>'
 if t['forme']=='holo':
  s+=f'<path d="M18 35V18H48M{w-48} {h-23}H{w-18}V{h-40}" fill="none" stroke="{t["bord"]}" stroke-width="3"/>'
 if t['forme']=='sceau' and role not in ['compteur','navigation']:
  s+=etoile(22,h/2-3,8,t['accent'])+etoile(w-22,h/2-3,8,t['accent'])
 if t['forme']=='fiole' and role=='principal':
  s+=f'<circle cx="{w-33}" cy="{h-31}" r="7" fill="{t["papier"]}" opacity=".65"/>'
 return s

NOMS = ['equipement','aventure','maitrises','sorts','heros','parametres','gouttes','pierres','mine','epreuves','potion','retour','suivant','cadenas','pause','validation']
LIBELLES = ['Équipement','Aventure','Maîtrises','Sorts','Héros','Paramètres','Gouttes','Pierres','La Mine','Épreuves','Potion','Retour','Suivant','Verrou','Pause','Acquis']

def icone(t,nom):
 c=t['icone'];a=t['accent'];p=t['papier'];n=t['bord'];ombre=t['second']
 # Les chemins sont originaux et communs aux variantes, les traitements restent editables.
 dessins={
 'equipement':f'<path d="M18 30H80V44H103L89 58H75V69L86 84H37L48 69V58H37L18 45Z" fill="{c}"/><path d="M28 34H74M47 78H75" fill="none" stroke="{p}" stroke-width="5"/>',
 'aventure':f'<path d="M27 98V53C27 10 93 10 93 53V98Z" fill="{ombre}"/><path d="M40 94V54C40 28 80 28 80 54V94" fill="{c}"/><path d="M61 45C43 45 43 75 62 75C79 75 75 53 61 58C53 61 59 70 65 66" fill="none" stroke="{p}" stroke-width="7"/><path d="M23 99H97" stroke="{a}" stroke-width="7"/>',
 'maitrises':f'<path d="M60 27L27 89H94Z" fill="none" stroke="{c}" stroke-width="8"/><circle cx="60" cy="27" r="13" fill="{a}"/><circle cx="27" cy="89" r="13" fill="{c}"/><circle cx="94" cy="89" r="13" fill="{c}"/>',
 'sorts':f'<path d="M23 24Q43 16 60 29Q77 16 98 24V93Q76 86 60 99Q42 86 23 93Z" fill="{ombre}"/><path d="M30 32Q44 26 55 34V84Q42 78 30 82ZM66 34Q81 26 91 32V82Q80 78 66 84Z" fill="{p}"/><path d="M60 30V99" stroke="{a}" stroke-width="6"/>'+etoile(80,54,12,c),
 'heros':f'<path d="M40 62H83L77 92Q60 108 43 92Z" fill="{p}"/><path d="M38 68L52 17L85 70Z" fill="{ombre}"/><path d="M17 74Q58 52 103 74Q62 91 17 74Z" fill="{c}"/><path d="M53 94Q61 102 69 94" fill="none" stroke="{n}" stroke-width="4"/>'+etoile(60,47,9,a),
 'parametres':f'<path d="M50 14H70L75 29L89 25L103 40L96 54L108 63L102 81L86 81L82 97L62 103L52 89L36 94L23 79L29 65L16 55L23 36L40 36Z" fill="{c}"/><circle cx="62" cy="59" r="20" fill="{ombre}"/><circle cx="62" cy="59" r="10" fill="{p}"/>',
 'gouttes':f'<path d="M60 13C51 38 26 56 26 76C26 113 94 113 94 76C94 56 70 38 60 13Z" fill="{c}"/><path d="M46 61Q32 78 44 88" fill="none" stroke="{p}" stroke-width="8"/>',
 'pierres':f'<path d="M59 12L84 42L80 88L60 108L36 88L34 42Z" fill="{ombre}"/><path d="M59 12L61 63L34 42ZM61 63L60 108L80 88L84 42Z" fill="{c}"/><path d="M61 25V52" stroke="{p}" stroke-width="5"/>',
 'mine':f'<path d="M35 100L26 91L74 29L84 37Z" fill="{a}"/><path d="M21 37Q57 0 102 49L81 40Q65 25 46 31L25 47Z" fill="{c}"/>',
 'epreuves':f'<path d="M71 11C81 38 43 42 54 61C63 64 67 51 74 47C104 81 83 106 59 107C28 106 19 78 36 55C36 77 47 69 42 50C37 33 61 31 71 11Z" fill="{c}"/><path d="M64 64C69 80 52 82 58 97C42 96 45 79 64 64Z" fill="{p}"/>',
 'potion':f'<path d="M43 24H77V43C77 51 99 58 99 79C99 119 21 119 21 79C21 58 43 51 43 43Z" fill="{p}"/><path d="M31 73Q46 61 63 72Q78 82 89 73V83C87 109 32 109 31 83Z" fill="{c}"/><rect x="40" y="16" width="40" height="16" rx="4" fill="{a}"/><path d="M36 61L42 55" stroke="{p}" stroke-width="7"/><circle cx="49" cy="85" r="5" fill="{p}"/><circle cx="73" cy="91" r="3" fill="{p}"/>',
 'suivant':f'<path d="M42 23L81 60L42 98L30 85L57 60L30 36Z" fill="{c}"/>',
 'retour':f'<path d="M78 23L39 60L78 98L90 85L63 60L90 36Z" fill="{c}"/>',
 'cadenas':f'<path d="M36 56V38C36 7 84 7 84 38V56" fill="none" stroke="{a}" stroke-width="12"/><rect x="24" y="51" width="72" height="54" rx="12" fill="{c}"/><circle cx="60" cy="72" r="8" fill="{n}"/><path d="M60 74V87" stroke="{n}" stroke-width="7"/>',
 'pause':f'<rect x="28" y="24" width="23" height="74" rx="5" fill="{c}"/><rect x="70" y="24" width="23" height="74" rx="5" fill="{c}"/>',
 'validation':f'<path d="M20 58L48 86L102 29L88 16L48 61L34 45Z" fill="{c}"/>',
 }
 ep=3 if t['forme'] in ['holo','sceau'] else 5
 corps=f'<g stroke="{n}" stroke-width="{ep}" stroke-linejoin="round" stroke-linecap="round">{dessins[nom]}</g>'
 if t['forme']=='holo':
  corps=f'<g stroke="{c}" stroke-width="3" stroke-linejoin="round" stroke-linecap="round">{dessins[nom]}</g>'
 return corps

def logo(t):
 s=''
 if t['forme'] in ['rond','pop','fiole']:
  for i,lettre in enumerate('ALAMBIK'):
   x=222+i*106;y=306+abs(i-3)*6
   s+=f'<text x="{x}" y="{y}" text-anchor="middle" font-family="DejaVu Sans" font-size="112" font-weight="900" fill="{t["papier"]}" stroke="{t["bord"]}" stroke-width="10" paint-order="stroke fill" stroke-linejoin="round" transform="rotate({(i-3)*-2} {x} {y})">{lettre}</text>'
 else:
  s+=f'<text x="540" y="315" text-anchor="middle" font-family="DejaVu Sans" font-size="110" font-weight="900" letter-spacing="3" fill="{t["papier"]}" stroke="{t["panneau"]}" stroke-width="10" paint-order="stroke fill" stroke-linejoin="round">ALAMBIK</text>'
 return s+etoile(540,360,16,t['accent'])

def decor(t):
 a=t['fond'];b=t['fond2'];c=t['panneau'];k=t['forme']
 s=f'<rect width="1080" height="1920" fill="{a}"/>'
 if k=='holo':
  s+=f'<path d="M0 0H210L75 1380H0ZM1080 0H870L1005 1380H1080Z" fill="{b}"/>'
  s+=f'<path d="M250 580L540 430L830 580V1140L540 1300L250 1140Z" fill="{b}" stroke="{t["icone"]}" stroke-width="4"/>'
  s+=f'<circle cx="540" cy="820" r="240" fill="none" stroke="{t["icone"]}" stroke-width="5" opacity=".4"/><path d="M540 560L766 970H314Z" fill="none" stroke="{t["accent"]}" stroke-width="8" opacity=".5"/>'
 elif k=='fiole':
  s+=f'<path d="M0 1170Q160 1060 380 1170T1080 1150V1920H0Z" fill="{b}"/>'
  s+=f'<path d="M442 445H638V614C638 680 828 751 828 966C828 1260 252 1260 252 966C252 751 442 680 442 614Z" fill="{t["papier"]}" opacity=".22"/><rect x="424" y="419" width="232" height="62" rx="25" fill="{b}"/>'
  for x,y,r in [(200,610,49),(884,736,61),(206,954,24),(815,470,25)]:
   s+=f'<circle cx="{x}" cy="{y}" r="{r}" fill="{t["papier"]}" opacity=".25"/>'
 elif k=='sceau':
  s+=f'<path d="M0 0H135V1330H0ZM945 0H1080V1330H945Z" fill="{b}"/>'
  s+=f'<circle cx="540" cy="832" r="350" fill="{b}"/><circle cx="540" cy="832" r="300" fill="none" stroke="{t["accent"]}" stroke-width="8" opacity=".6"/><path d="M540 503L824 994H256Z" fill="none" stroke="{t["accent"]}" stroke-width="7" opacity=".55"/>'
  for x,y in [(540,502),(254,988),(826,988)]:s+=etoile(x,y,27,t['action'])
  s+=f'<path d="M0 1340L540 1160L1080 1340V1920H0Z" fill="{b}"/>'
 else:
  s+=f'<path d="M160 1230V568L540 352L920 568V1230H802V628L540 467L278 628V1230Z" fill="{b}"/>'
  s+=f'<path d="M328 1230V690Q540 388 752 690V1230Z" fill="{t["papier"]}" opacity=".24"/>'
  s+=f'<path d="M0 850L120 793V1210H0ZM1080 850L960 793V1210H1080Z" fill="{b}"/>'
  s+=f'<path d="M0 1330L540 1180L1080 1330V1920H0Z" fill="{b}"/>'
  s+=etoile(540,548,47,t['accent'])
 s+=f'<ellipse cx="540" cy="1240" rx="344" ry="76" fill="{c}" opacity=".18"/>'
 return s

def libelle_bouton(t,x,y,w,h,titre,role='secondaire',taille=34):
 c=t['encre'] if role in ['principal','lecture'] else t['texte']
 return groupe(x,y,surface(t,role,w,h)+texte(w/2,h/2+taille*.32-5,titre,taille,c,800,'middle'))

def nav(t,w=984,h=180):
 s=surface(t,'navigation',w,h)
 for i,nom in enumerate(NOMS[:5]):
  x=12+i*(w-24)/5;largeur=(w-24)/5
  if i==1:s+=groupe(x+10,12,forme(t,largeur-20,h-29,t['second'],t['accent'],3))
  s+=groupe(x+(largeur-80)/2,25,icone(t,nom),80/120)
  s+=texte(x+largeur/2,139,LIBELLES[i].upper(),19,t['texte'],700,'middle')
  if i==1:s+=f'<rect x="{x+largeur/2-24}" y="151" width="48" height="5" rx="2" fill="{t["accent"]}"/>'
 return s

def menu(t):
 s=decor(t)
 s+=groupe(40,45,surface(t,'compteur',190,140)+texte(95,54,'ALCHIMISTE',16,t['texte'],600,'middle')+texte(95,101,'NIV. 12',34,t['texte'],800,'middle'))
 for x,nom,val in [(256,'gouttes','1 240'),(554,'pierres','86')]:
  s+=groupe(x,63,surface(t,'compteur',270,100)+groupe(14,13,icone(t,nom),.58)+texte(98,61,val,38,t['texte'],700))
 s+=groupe(884,63,surface(t,'secondaire',136,100)+groupe(32,10,icone(t,'parametres'),.62))
 s+=logo(t)
 s+=f'<image x="224" y="430" width="632" height="870" href="{MAGE}"/>'
 for x,nom,titre in [(48,'mine','LA MINE'),(848,'epreuves','ÉPREUVES')]:
  s+=groupe(x,988,surface(t,'secondaire',184,212)+groupe(40,24,icone(t,nom),.87)+texte(92,173,titre,24,t['texte'],800,'middle'))
 s+=groupe(48,1350,surface(t,'lecture',984,152)+groupe(23,22,icone(t,'aventure'),.8)+texte(150,64,'CHAPITRE 1',34,t['encre'],800)+texte(150,110,'Les premières encres',30,t['encre'])+groupe(870,39,icone(t,'suivant'),.57))
 s+=libelle_bouton(t,48,1530,984,178,'JOUER','principal',64)
 s+=groupe(48,1740,nav(t))
 return s

def planche(t):
 s=f'<rect width="1080" height="1920" fill="#f2f0f4"/>'
 s+=texte(48,62,'ALAMBIK / ÉTUDES D’INTERFACE',22,'#6b687e',600)
 s+=texte(48,129,t['id']+' — '+t['nom'],44,t['encre'],800)
 s+=texte(48,175,t['origine'],22,'#6b687e')
 s+=groupe(48,215,menu(t),.40)
 s+=texte(532,252,'COMMANDES',20,'#6b687e',700)
 s+=libelle_bouton(t,532,278,500,124,'JOUER','principal',40)
 s+=libelle_bouton(t,532,426,240,98,'LA MINE',taille=25)
 s+=libelle_bouton(t,792,426,240,98,'ÉPREUVES',taille=25)
 s+=groupe(532,552,surface(t,'lecture',500,148)+texte(28,56,'CHAPITRE 1',27,t['encre'],800)+texte(28,103,'Zone de texte indépendante',21,t['encre']))
 s+=texte(532,754,'ÉTATS DU BOUTON',20,'#6b687e',700)
 for x,etat,txt in [(532,'normal','NORMAL'),(703,'presse','PRESSÉ'),(874,'desactive','INACTIF')]:
  s+=groupe(x,778,surface(t,'principal',158,84,etat)+texte(79,45,txt,17,t['encre'],700,'middle'))
 s+=texte(532,918,'NIVEAU / RESSOURCES',20,'#6b687e',700)
 s+=groupe(532,942,surface(t,'compteur',500,75)+groupe(12,8,icone(t,'gouttes'),.45)+texte(86,46,'1 240',26,t['texte'],700)+groupe(278,8,icone(t,'pierres'),.45)+texte(351,46,'86',26,t['texte'],700))
 s+=texte(48,1058,'ICÔNES VECTORIELLES / 120 × 120',22,'#6b687e',700)
 for i,nom in enumerate(NOMS):
  x=48+(i%8)*126;y=1090+(i//8)*172
  s+=groupe(x,y,icone(t,nom),.85)
  s+=texte(x+51,y+133,LIBELLES[i],14,t['encre'],600,'middle')
 s+=texte(48,1465,'NAVIGATION / CINQ ÉLÉMENTS INDÉPENDANTS',22,'#6b687e',700)
 s+=groupe(48,1495,nav(t))
 s+=texte(48,1732,'PALETTE',20,'#6b687e',700)
 for i,cle in enumerate(['fond','panneau','action','papier','accent','icone']):
  x=48+i*164
  s+=f'<rect x="{x}" y="1755" width="144" height="46" rx="10" fill="{t[cle]}"/>'
  s+=texte(x+72,1827,t[cle].upper(),17,'#6b687e',500,'middle')
 s+=texte(48,1882,'Composition 9:16 · aplats sans grain · textes séparés · SVG éditables',21,'#6b687e')
 return s

for t in THEMES:
 dossier=SORTIE/t['id'];(dossier/'icones').mkdir(parents=True,exist_ok=True);(dossier/'surfaces').mkdir(exist_ok=True)
 for nom in NOMS:(dossier/'icones'/(nom+'.svg')).write_text(svg(120,120,icone(t,nom)))
 composants={}
 for role,w,h in [('principal',984,178),('secondaire',320,124),('lecture',984,152),('navigation',984,180),('compteur',270,100)]:
  etats=['normal','presse','desactive'] if role in ['principal','secondaire'] else ['normal']
  for etat in etats:
   nom=role+'_'+etat
   (dossier/'surfaces'/(nom+'.svg')).write_text(svg(w,h,surface(t,role,w,h,etat)))
   composants[nom]={'taille':[w,h],'marges_neuf_zones':[48,40,48,40],'texte_incorpore':False}
 (dossier/'surfaces/onglet_actif.svg').write_text(svg(176,151,forme(t,176,151,t['second'],t['accent'],3)))
 (dossier/'surfaces/mode.svg').write_text(svg(184,212,surface(t,'secondaire',184,212)))
 (dossier/'decor.svg').write_text(svg(1080,1920,decor(t)))
 (dossier/'composition.svg').write_text(svg(1080,1920,menu(t)))
 (dossier/'planche.svg').write_text(svg(1080,1920,planche(t)))
 (dossier/'theme.json').write_text(json.dumps({'nom':t['nom'],'reference':t['origine'],'palette':t,'viewport':[1080,1920],'composants':composants},ensure_ascii=False,indent=2))
print(SORTIE)
