"""Kit A : SVG natifs avec volumes simples, sans vectorisation matricielle."""
from pathlib import Path
import re
import ast
import xml.etree.ElementTree as ET
from generer_icones import MOTIFS, AJOUTS
from habillage_svg_source import generer

RACINE = Path(__file__).resolve().parents[1]
INTERFACE = RACINE/'assets/visual/interface'
DEFS = '''<defs>
<linearGradient id="bronze" x1="0" y1="0" x2=".25" y2="1"><stop stop-color="#fff0c7"/><stop offset=".3" stop-color="#d8b37c"/><stop offset=".65" stop-color="#9b7449"/><stop offset="1" stop-color="#e1c396"/></linearGradient>
<linearGradient id="email" x1=".2" y1="0" x2=".75" y2="1"><stop stop-color="#73c9c8"/><stop offset=".36" stop-color="#328b98"/><stop offset="1" stop-color="#184a60"/></linearGradient>
<linearGradient id="profond" x2=".4" y2="1"><stop stop-color="#32667b"/><stop offset="1" stop-color="#19394f"/></linearGradient>
<linearGradient id="ivoire" x2=".4" y2="1"><stop stop-color="#fff9e9"/><stop offset="1" stop-color="#ded4bd"/></linearGradient>
<linearGradient id="violet" x2=".5" y2="1"><stop stop-color="#e4d5ff"/><stop offset=".4" stop-color="#ad8cdd"/><stop offset="1" stop-color="#65549b"/></linearGradient>
<linearGradient id="argent" x2=".5" y2="1"><stop stop-color="#f3f3ec"/><stop offset=".4" stop-color="#b5c3ce"/><stop offset="1" stop-color="#667991"/></linearGradient>
<radialGradient id="ambre" cx=".3" cy=".2" r=".9"><stop stop-color="#fff3ad"/><stop offset=".35" stop-color="#efbc54"/><stop offset=".7" stop-color="#b77728"/><stop offset="1" stop-color="#795021"/></radialGradient>
<radialGradient id="verre" cx=".3" cy=".25" r=".85"><stop stop-color="#b9f6ef"/><stop offset=".4" stop-color="#5bd5d9"/><stop offset="1" stop-color="#226e8b"/></radialGradient>
</defs>'''

def ecrire(destination, corps, vue='0 0 120 120', taille=(384,384)):
 destination.parent.mkdir(parents=True,exist_ok=True)
 destination.write_text(f'<svg xmlns="http://www.w3.org/2000/svg" width="{taille[0]}" height="{taille[1]}" viewBox="{vue}">{DEFS}{corps}</svg>\n')

def chemin(d,remplissage='email',trait='#234758',largeur=1.5):
 return f'<path d="{d}" fill="url(#{remplissage})" stroke="{trait}" stroke-width="{largeur}" stroke-linejoin="round"/>'

# Les sources de la proposition sont des chemins originaux, sans image incorporee.
correspondances={'forge':'equipement','portail':'aventure','grimoire':'sorts','heros':'heros','parametres':'parametres','gouttes':'gouttes','pierres':'pierres','mine':'mine','epreuves':'epreuves','fiole':'potion','fleche_gauche':'retour','fleche_droite':'suivant','cadenas':'cadenas','pause':'pause','validation':'validation'}
ET.register_namespace('','http://www.w3.org/2000/svg')
for cible,source in correspondances.items():
 racine=ET.parse(RACINE/f'tools/sources_email/{source}.svg').getroot()
 groupe=racine[0]
 for noeud in groupe.iter():
  if 'stroke-width' in noeud.attrib:noeud.set('stroke-width',str(min(float(noeud.get('stroke-width')),5)))
  for cle in ['fill','stroke']:
   couleur=noeud.get(cle)
   conversions={'#71e0df':'url(#email)','#ffce78':'url(#bronze)','#fff0d2':'url(#ivoire)','#9272cd':'url(#violet)','#302540':'#284955'}
   if couleur in conversions:noeud.set(cle,conversions[couleur])
 groupe.set('stroke-width','1.5')
 contenu=ET.tostring(groupe,encoding='unicode').replace('ns0:','').replace(':ns0','')
 if cible=='forge':contenu=contenu.replace('url(#email)','url(#argent)')
 if cible=='gouttes':contenu=contenu.replace('url(#email)','url(#verre)')
 if cible=='pierres':contenu=contenu.replace('url(#email)','url(#violet)')
 ecrire(INTERFACE/(cible+'.svg'),contenu)

astrolabe='''<g fill="none" stroke="url(#bronze)" stroke-width="6"><ellipse cx="60" cy="52" rx="43" ry="30"/><ellipse cx="60" cy="52" rx="18" ry="42" transform="rotate(26 60 52)"/><path d="M18 62L101 37M60 86V105M41 109H79"/></g><circle cx="60" cy="52" r="8" fill="url(#verre)"/><path d="M28 36Q51 19 76 29" fill="none" stroke="#fff1c8" stroke-width="2"/>'''
ecrire(INTERFACE/'astrolabe.svg',astrolabe)
ecrire(INTERFACE/'couronne.svg',chemin('M20 39L40 55L60 22L80 55L101 39L91 94H29Z','bronze')+chemin('M33 82H87V96H33Z','bronze')+chemin('M60 45L70 61L60 75L50 61Z','email'))
ecrire(INTERFACE/'selection.svg',chemin('M60 15L76 44L104 60L76 76L60 106L44 76L16 60L44 44Z','bronze')+chemin('M60 35L75 60L60 86L45 60Z','email'))
ecrire(INTERFACE/'fleche_bas.svg',chemin('M23 38L60 76L97 38L86 27L60 53L34 27Z','bronze'),taille=(48,48))

# Une surface 128 px fixe les coins ; les marges d'etirement excluent les biseaux.
def cadre(remplissage):
 return '<rect x="3" y="5" width="122" height="121" rx="19" fill="#183746" fill-opacity=".45"/>'+chemin('M20 2H108L126 20V107L108 125H20L2 107V20Z','bronze','#705b43',1)+chemin('M22 7H106L120 22V104L106 119H22L8 104V22Z',remplissage,'#f0dcba',1)+f'<path d="M24 12H104M13 25V100" fill="none" stroke="#fff7dc" stroke-opacity=".27" stroke-width="2"/>'
for nom,matiere in [('panneau','ivoire'),('action','email'),('secondaire','profond'),('navigation','profond')]:
 ecrire(INTERFACE/'cadres'/(nom+'.svg'),cadre(matiere),'0 0 128 128',(128,128))
for nom,matiere in [('panneau','profond'),('cadre','profond'),('bouton_principal','email'),('bouton_secondaire','profond'),('bandeau','profond'),('carte_augment','profond')]:
 ecrire(INTERFACE/(nom+'.svg'),cadre(matiere),'0 0 128 128',(128,128))
ecrire(INTERFACE/'medaillon.svg','<circle cx="60" cy="61" r="54" fill="url(#bronze)"/><circle cx="60" cy="60" r="48" fill="url(#profond)" stroke="#f4dfb3" stroke-width="1.5"/>')

# Les bijoux et baguettes conservent chacun une silhouette et une gemme distinctes.
for i,p in enumerate(sorted((INTERFACE/'equipement').glob('*.svg'))):
 gemme='violet' if 'amethyste' in p.stem or 'lune' in p.stem else 'bronze' if 'ambre' in p.stem or 'soleil' in p.stem else 'verre'
 if p.stem.startswith('anneau'):
  corps='<ellipse cx="60" cy="73" rx="31" ry="32" fill="none" stroke="#715635" stroke-width="13"/><ellipse cx="60" cy="70" rx="31" ry="32" fill="none" stroke="url(#bronze)" stroke-width="10"/>'
 else:
  corps='<path d="M25 15Q60 100 95 15" fill="none" stroke="url(#bronze)" stroke-width="5"/>'
 corps+=chemin('M60 22L82 43L60 69L38 43Z','bronze')+chemin('M60 29L74 43L60 60L46 43Z',gemme)+f'<path d="M60 30L60 58L47 43Z" fill="#fff" opacity=".24"/>'
 ecrire(p,corps)
for i,nom in enumerate(['standard','veloce','lourd','chercheur','explosif']):
 corps=chemin('M22 103L13 94L73 30L83 40Z','bronze')
 sommets=['M78 12L101 29L82 50L62 31Z','M87 8L105 39L81 50L69 27Z','M63 12H107V49H63Z','M86 7L108 30L85 54L60 31Z','M87 6L95 24L115 30L97 40L87 59L78 40L59 30L77 23Z']
 corps+=chemin(sommets[i],'verre' if i<2 else 'violet')+'<path d="M31 80L42 90M42 69L53 79" stroke="#f1d6a8" stroke-width="4"/>'
 ecrire(INTERFACE/'armes'/(nom+'.svg'),corps)

texte=(RACINE/'scripts/presentation/icones_arcane.gd').read_text()
identifiants=ast.literal_eval(re.search(r'const IDENTIFIANTS := (\[.*?\])',texte,re.S).group(1))
for nom in identifiants:
 if nom.startswith('navigation_') or nom in ['parametres','gouttes','pierres']:continue
 motif=MOTIFS.get(nom)
 if motif is None:raise ValueError('Motif manquant : '+nom)
 couleur='verre'
 if nom in ['feu','meteores','barrage_de_braise','audace','frappe_lourde','courageux','sceau_furie']:couleur='bronze'
 elif nom in ['tenebres','grand_oeuvre','transmutation_totale','sceau_ruine','orbes_chargees']:couleur='violet'
 trace=f'<path d="{motif}"/>'+AJOUTS.get(nom,'')
 corps='<circle cx="64" cy="65" r="58" fill="url(#bronze)"/><circle cx="64" cy="63" r="52" fill="url(#profond)" stroke="#f3ddb7" stroke-width="1"/>'
 corps+=f'<g fill="none" stroke="#102e40" stroke-width="10" stroke-linecap="round" stroke-linejoin="round" transform="translate(0 2)">{trace}</g><g fill="none" stroke="url(#{couleur})" stroke-width="7" stroke-linecap="round" stroke-linejoin="round">{trace}</g>'
 ecrire(RACINE/'assets/visual/azur/glyphes'/(nom+'.svg'),corps,'0 0 128 128')

# Tous les petits controles partagent la meme matiere, y compris en combat.
for nom,actif in [('oui',True),('non',False)]:
 x=72 if actif else 25
 ecrire(INTERFACE/(nom+'.svg'),f'<rect x="2" y="5" width="96" height="42" rx="21" fill="url(#bronze)"/><rect x="7" y="10" width="86" height="32" rx="16" fill="url(#profond)"/><circle cx="{x}" cy="26" r="22" fill="url(#bronze)"/><circle cx="{x}" cy="26" r="17" fill="url(#{"verre" if actif else "argent"})"/>','0 0 100 52',(100,52))
ecrire(INTERFACE/'curseur.svg','<circle cx="24" cy="25" r="22" fill="url(#bronze)"/><circle cx="24" cy="23" r="17" fill="url(#verre)"/>','0 0 48 48',(48,48))
ecrire(INTERFACE/'jauge_fond.svg','<rect x="1" y="2" width="254" height="28" rx="13" fill="url(#bronze)"/><rect x="5" y="6" width="246" height="20" rx="9" fill="url(#profond)"/>','0 0 256 32',(256,32))
ecrire(INTERFACE/'jauge_plein.svg','<rect x="3" y="5" width="250" height="22" rx="9" fill="url(#ivoire)"/><path d="M16 9H240" stroke="#fff" stroke-width="2" opacity=".6"/>','0 0 256 32',(256,32))
ecrire(INTERFACE/'separateur.svg','<path d="M8 16H234M278 16H504" stroke="url(#bronze)" stroke-width="2"/>'+chemin('M256 3L269 16L256 29L243 16Z','email'),'0 0 512 32',(512,32))
ecrire(INTERFACE/'joystick_base.svg','<circle cx="60" cy="60" r="53" fill="url(#profond)" fill-opacity=".18" stroke="url(#bronze)" stroke-opacity=".6" stroke-width="2"/><circle cx="60" cy="60" r="43" fill="none" stroke="#8ce0dd" stroke-opacity=".35" stroke-width="1.5"/>')
ecrire(INTERFACE/'joystick_curseur.svg','<circle cx="60" cy="60" r="48" fill="url(#bronze)"/><circle cx="60" cy="58" r="42" fill="url(#verre)"/>'+chemin('M60 33L73 58L60 83L47 58Z','ivoire'))
for nom,glyphe in [('victoire','M60 22L71 44L98 48L78 66L83 92L60 79L37 92L42 66L22 48L49 44Z'),('defaite','M78 21C28 18 19 90 76 100C36 78 46 39 78 21Z')]:
 ecrire(INTERFACE/(nom+'.svg'),'<circle cx="60" cy="60" r="53" fill="url(#bronze)"/><circle cx="60" cy="60" r="47" fill="url(#profond)"/>'+chemin(glyphe,'ivoire'))

# Les mipmaps filtrent les reductions d'echelle, sans compression destructive.
for dossier in [INTERFACE,RACINE/'assets/visual/azur/glyphes']:
 for p in dossier.rglob('*.svg.import'):
  s=p.read_text().replace('mipmaps/generate=false','mipmaps/generate=true')
  s=re.sub(r'compress/mode=\d+','compress/mode=0',s)
  p.write_text(s)
generer(ecrire)
print('Kit Email arcanique genere : surfaces modulaires et icones du dossier SVG.')
# Les deux pieces du coffre restent animees separement.
ecrire(INTERFACE/'coffre_corps.svg','<path d="M22 28H296V143L282 154H38L22 140Z" fill="url(#profond)" stroke="url(#bronze)" stroke-width="10"/><path d="M48 30V148M270 30V148M27 134H291" fill="none" stroke="url(#bronze)" stroke-width="12"/><rect x="142" y="33" width="38" height="46" rx="8" fill="url(#bronze)"/><circle cx="161" cy="55" r="7" fill="url(#verre)"/>','0 0 320 160',(640,320))
ecrire(INTERFACE/'coffre_couvercle.svg','<path d="M22 132V71Q22 17 77 17H241Q296 17 296 71V132Z" fill="url(#email)" stroke="url(#bronze)" stroke-width="10"/><path d="M48 130V68Q48 28 82 25M270 130V68Q270 28 238 25M24 123H295" fill="none" stroke="url(#bronze)" stroke-width="12"/><path d="M89 32H225" stroke="#b4e4e0" stroke-width="4" stroke-linecap="round"/>','0 0 320 160',(640,320))
