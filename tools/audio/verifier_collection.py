"""Decode les nouveaux Ogg sans lecture sonore et prepare une page d'ecoute."""
import json
import os
import re
import subprocess
from pathlib import Path
from html import escape
import numpy as np
from collection import PISTES

racine = Path(__file__).resolve().parents[2]
sortie = racine / 'tmp/musiques-20'
sortie.mkdir(parents=True, exist_ok=True)
rapports = []
for identifiant, nom, menu, tempo, *_ in PISTES:
    fichier = racine / 'assets/audio' / (identifiant+'.ogg')
    brut = subprocess.run([os.environ['FFMPEG'],'-v','error','-i',str(fichier),
        '-f','f32le','-ac','2','-ar','44100','pipe:1'],capture_output=True,check=True,
        creationflags=subprocess.CREATE_NO_WINDOW if os.name == 'nt' else 0).stdout
    son = np.frombuffer(brut,dtype='<f4').reshape(-1,2)
    pic = float(np.max(np.abs(son)))
    assert np.isfinite(son).all() and pic < .98 and len(son) > 44100*45
    rapport = dict(id=identifiant,duree=round(len(son)/44100,2),pic=round(pic,4),
        rms_db=round(float(20*np.log10(np.sqrt(np.mean(son**2)))),2),
        raccord=round(float(np.max(np.abs(son[0]-son[-1]))),5))
    rapports.append(rapport)
    print(json.dumps(rapport),flush=True)
(sortie/'mesures.json').write_text(json.dumps(rapports,indent=2),encoding='utf-8')
catalogue = (racine/'data/musiques.gd').read_text(encoding='utf-8')
cartes=[]
for section, titre in [('RUNS','En jeu'),('MENU','Au menu')]:
    bloc=catalogue.split('const '+section+':')[1].split('= [',1)[1].split(']')[0]
    lignes=re.findall(r'"nom"\s*:\s*"([^"]+)".*?"fichier"\s*:\s*"res://([^"]+)"',bloc)
    assert len(lignes)==10
    cartes.append('<h2>'+titre+'</h2><div class="grille">')
    for nom,fichier in lignes:
        cartes.append('<article><h3>'+escape(nom)+'</h3><audio controls preload="none" src="../../'+escape(fichier)+'"></audio></article>')
    cartes.append('</div>')
page='''<!doctype html><html lang="fr"><meta charset="utf-8"><meta name="viewport" content="width=device-width"><title>Alambic — 20 musiques</title><style>body{background:#31213f;color:#faeed8;font:18px system-ui;max-width:1050px;margin:40px auto;padding:20px}h1,h2{font-family:Georgia}h2{color:#61dbce;margin-top:48px}.grille{display:grid;grid-template-columns:repeat(auto-fit,minmax(280px,1fr));gap:16px}article{border:1px solid #b88751;border-radius:18px;padding:20px;background:#493253}h3{margin:0 0 18px;font-size:18px}audio{width:100%}</style><h1>Les musiques d’Alambic</h1><p>Dix ambiances en jeu et dix pour le menu. Lancez les morceaux pour les comparer ; aucune lecture automatique.</p>'''+''.join(cartes)
page+='''<script>document.querySelectorAll('audio').forEach(a=>a.addEventListener('play',()=>document.querySelectorAll('audio').forEach(b=>{if(a!==b)b.pause()})))</script></html>'''
(sortie/'ecouter.html').write_text(page,encoding='utf-8')
