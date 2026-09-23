"""Ajuste le niveau et la couleur des morceaux fournis par le createur.

Les sources dans tools/audio/sources restent intactes pour eviter un reencodage
successif si le traitement est relance.
"""
from pathlib import Path
import os
import subprocess
import tempfile


RACINE = Path(__file__).resolve().parents[2]
SOURCE = Path(__file__).resolve().parent / 'sources'
DESTINATION = RACINE / 'assets/audio'
PISTES = [
    ('firstarcade', DESTINATION / 'firstarcade.ogg', '-15.5',
     'highpass=f=35,equalizer=f=3100:width_type=o:width=1.3:g=-1.2,lowpass=f=15000'),
    ('dynamic_arcade', DESTINATION / 'dynamic_arcade.ogg', '-15.5',
     'highpass=f=35,equalizer=f=120:width_type=o:width=1.2:g=-1,equalizer=f=3600:width_type=o:width=1.3:g=-1.5,lowpass=f=15000'),
    ('Accueil', RACINE / 'Accueil.ogg', '-18.5',
     'highpass=f=35,equalizer=f=3100:width_type=o:width=1.3:g=-1,lowpass=f=15000'),
]


def masteriser(nom, sortie, cible_lufs, filtres):
    entree = SOURCE / f'{nom}.ogg'
    with tempfile.TemporaryDirectory() as dossier:
        provisoire = Path(dossier) / f'{nom}.ogg'
        commande = [
            os.environ.get('FFMPEG', 'ffmpeg'), '-v', 'error', '-y', '-i', str(entree),
            '-af', f'{filtres},loudnorm=I={cible_lufs}:TP=-1.5:LRA=7',
            '-ar', '44100', '-c:a', 'libvorbis', '-q:a', '7',
            '-map_metadata', '0', str(provisoire),
        ]
        subprocess.run(commande, check=True,
                       creationflags=subprocess.CREATE_NO_WINDOW if os.name == 'nt' else 0)
        provisoire.replace(sortie)
    print(f'{nom}: niveau et balance ajustes', flush=True)


if __name__ == '__main__':
    for parametres in PISTES:
        masteriser(*parametres)
