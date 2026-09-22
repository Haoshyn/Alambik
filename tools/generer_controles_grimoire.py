"""Petits controles SVG du kit bois, cuivre et seve ; aucune image incorporee."""
from pathlib import Path

DOSSIER = Path(__file__).resolve().parents[1] / 'assets/visual/interface'
DEFS = '''<defs>
<linearGradient id="bois" x2="0" y2="1"><stop stop-color="#cf9965"/><stop offset=".22" stop-color="#94623d"/><stop offset=".6" stop-color="#533621"/><stop offset="1" stop-color="#ad764b"/></linearGradient>
<linearGradient id="cuivre" x2=".3" y2="1"><stop stop-color="#ffe4aa"/><stop offset=".3" stop-color="#d9a86d"/><stop offset=".6" stop-color="#8b532f"/><stop offset="1" stop-color="#e4b377"/></linearGradient>
<radialGradient id="seve" cx=".35" cy=".25" r=".8"><stop stop-color="#c4f3ca"/><stop offset=".3" stop-color="#67c9a8"/><stop offset=".7" stop-color="#2e8b7a"/><stop offset="1" stop-color="#184e48"/></radialGradient>
<linearGradient id="feuille" x2="1" y2="1"><stop stop-color="#c1cd79"/><stop offset=".45" stop-color="#728c43"/><stop offset="1" stop-color="#354b29"/></linearGradient>
</defs>'''

def ecrire(nom, largeur, hauteur, dessin):
    (DOSSIER / (nom+'.svg')).write_text(f'<svg xmlns="http://www.w3.org/2000/svg" width="{largeur}" height="{hauteur}" viewBox="0 0 {largeur} {hauteur}">{DEFS}{dessin}</svg>\n')

FEUILLE = '<path d="M0 0Q-20-28-43-20Q-36 5 0 0Z" fill="url(#feuille)" stroke="#404c2c" stroke-width="1.2"/><path d="M-36-17Q-20-6 0 0" fill="none" stroke="#d4d89a" stroke-width="1"/>'

ecrire('jauge_fond',256,32,'<rect x="2" y="2" width="252" height="28" rx="13" fill="url(#bois)" stroke="#412e22" stroke-width="2"/><rect x="7" y="7" width="242" height="18" rx="8" fill="#263d32" stroke="#d1a36a" stroke-width="1"/><path d="M17 5H239" stroke="#f3d099" stroke-opacity=".6"/>')
# Le remplissage neutre accepte les teintes fonctionnelles (vie, experience, recharge).
ecrire('jauge_plein',256,32,'<defs><linearGradient id="plein" x2="0" y2="1"><stop stop-color="#f5ffdf"/><stop offset=".4" stop-color="#d5ecdb"/><stop offset="1" stop-color="#6b9c88"/></linearGradient></defs><rect x="3" y="5" width="250" height="22" rx="9" fill="url(#plein)"/><path d="M15 9H241" stroke="#fffde4" stroke-width="2" stroke-opacity=".8"/>')
ecrire('separateur',512,40,'<path d="M8 22Q106 12 245 21M267 21Q405 12 504 22" fill="none" stroke="#765235" stroke-width="4"/><path d="M16 20Q110 11 243 19M269 19Q406 11 496 20" fill="none" stroke="#d4b47d" stroke-width="1.4"/><g transform="translate(225 20) scale(.6)">'+FEUILLE+'</g><g transform="translate(287 20) scale(-.6 .6)">'+FEUILLE+'</g><path d="M256 4Q274 20 256 36Q238 20 256 4" fill="url(#seve)" stroke="url(#cuivre)" stroke-width="2"/><path d="M252 12Q247 19 252 24" fill="none" stroke="#dcf1c9" stroke-width="2"/>')
for nom,actif in [('oui',True),('non',False)]:
    x=70 if actif else 26
    ecrire(nom,96,52,f'<rect x="3" y="7" width="90" height="38" rx="19" fill="url(#bois)" stroke="#4e3626" stroke-width="2"/><rect x="8" y="12" width="80" height="28" rx="14" fill="{ "#286752" if actif else "#453c30"}"/><circle cx="{x}" cy="26" r="21" fill="url(#cuivre)" stroke="#583d27" stroke-width="2"/><circle cx="{x}" cy="26" r="16" fill="url(#{"seve" if actif else "bois"})"/><path d="M{x-8} 26l5 6 11-13" fill="none" stroke="#f7efcf" stroke-width="3" stroke-linecap="round" stroke-linejoin="round" opacity="{1 if actif else .35}"/>')
ecrire('curseur',48,48,'<circle cx="24" cy="25" r="21" fill="url(#bois)" stroke="#523620" stroke-width="2"/><circle cx="24" cy="23" r="17" fill="url(#seve)" stroke="url(#cuivre)" stroke-width="3"/><path d="M16 13Q10 19 14 24" fill="none" stroke="#eaf9d4" stroke-width="2" stroke-linecap="round"/>')
ecrire('joystick_base',256,256,'<circle cx="128" cy="128" r="112" fill="#29473b" fill-opacity=".3" stroke="url(#bois)" stroke-width="9"/><circle cx="128" cy="128" r="105" fill="none" stroke="#d2ad73" stroke-width="1.5" stroke-opacity=".7"/><circle cx="128" cy="128" r="78" fill="none" stroke="#a6ccb1" stroke-width="1.5" stroke-dasharray="2 16" stroke-opacity=".5"/>'+''.join(f'<g transform="translate(128 128) rotate({a}) translate(0 -106) scale(.5)">{FEUILLE}</g>' for a in [0,90,180,270]))
ecrire('joystick_curseur',128,128,'<circle cx="64" cy="67" r="51" fill="#243a30" fill-opacity=".3"/><circle cx="64" cy="64" r="49" fill="url(#bois)" stroke="#4e3424" stroke-width="2"/><circle cx="64" cy="64" r="42" fill="url(#seve)" stroke="url(#cuivre)" stroke-width="3"/><path d="M64 87V45M64 68Q40 67 39 47Q61 46 64 68M64 58Q84 57 88 37Q66 35 64 58" fill="url(#feuille)" stroke="#d5dca0" stroke-width="1.5"/><path d="M34 43Q39 31 50 29" fill="none" stroke="#dcf4d9" stroke-opacity=".8" stroke-width="3" stroke-linecap="round"/>')
ecrire('validation',40,40,'<circle cx="20" cy="20" r="17" fill="url(#seve)" stroke="url(#cuivre)" stroke-width="2"/><path d="M10 20l7 7 14-16" fill="none" stroke="#fff4ce" stroke-width="3.5" stroke-linecap="round" stroke-linejoin="round"/>')
ecrire('selection',40,40,'<path d="M20 3Q25 15 37 20Q25 25 20 37Q15 25 3 20Q15 15 20 3Z" fill="url(#seve)" stroke="url(#cuivre)" stroke-width="2"/><path d="M20 11v18m-9-9h18" stroke="#e8f1c2" stroke-width="1.5"/>')
ecrire('fleche_bas',40,32,'<path d="M5 6L20 24L35 6L28 5L20 14L12 5Z" fill="url(#cuivre)" stroke="#5a3d28" stroke-width="1.5"/><path d="M8 7L20 21L32 7" fill="none" stroke="#f2d69e" stroke-width="1"/>')
