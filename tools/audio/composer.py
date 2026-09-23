"""Compositions originales Alambik. Python 3 + numpy, ffmpeg dans PATH.
Reproduction : python3 tools/audio/composer.py. Aucun sample externe.
"""
from pathlib import Path
import subprocess
import tempfile
import wave
import os
import time
import numpy as np

TAUX = 44100
DESTINATION = Path(__file__).resolve().parents[2] / 'assets/audio'
PISTES = [
    ('cuivre_vif', 124, 50, [0, 5, 3, 7], 0),
    ('vortex_azur', 138, 57, [0, 3, 5, 4], 1),
    ('braise_volatile', 112, 43, [0, 0, 5, 4], 2),
    ('atelier_lunaire', 82, 62, [0, 5, 2, 3], 3),
]
GAMME = [0, 2, 3, 5, 7, 8, 10]
MOTIFS = [
    [7, 9, 11, 9, 7, 4, 6, 4],
    [7, 11, 9, 14, 13, 11, 9, 6],
    [7, 7, 4, 6, 7, 9, 6, 4],
    [11, 9, 7, 6, 4, 6, 7, 9],
]
PROFILS = {
    'cuivre_vif': 'rebond', 'vortex_azur': 'course',
    'braise_volatile': 'lourd', 'etincelles': 'rebond',
    'ronde_automates': 'mecanique', 'course_canopee': 'course',
    'fournaise': 'lourd', 'marees_arcanes': 'flottant',
    'atelier_lunaire': 'nuit', 'matin_atelier': 'atelier',
    'jardin_verre': 'verre', 'bibliotheque': 'secret',
    'the_alchimiste': 'atelier', 'serre_aube': 'jardin',
    'poussiere_etoiles': 'verre', 'comptoir_cuivre': 'atelier',
    'carnet_voyage': 'jardin',
}


def note(degre, tonique):
    return tonique + GAMME[degre % 7] + 12 * (degre // 7)


def composer(nom, tempo, tonique, accords, style, gamme=None, motif=None, instrument='cloche', arpege=None):
    gamme = gamme or GAMME
    motif = motif or MOTIFS[style]
    arpege = arpege or [0, 4, 2, 6, 4, 2, 7, 4]
    def note(degre, tonique):
        return tonique + gamme[degre % 7] + 12 * (degre // 7)
    profil = PROFILS[nom]
    menu = style == 3
    hasard = np.random.default_rng(310 + sum(map(ord, nom)))
    temps = 60 / tempo
    longueur = round(32 * 4 * temps * TAUX)
    mixage = np.zeros((longueur, 2), dtype=np.float32)

    def deposer(son, debut, volume, panoramique=0.0, echo=False):
        stereo = (son[:, None] * volume * np.array([
            np.sqrt((1 - panoramique) / 2), np.sqrt((1 + panoramique) / 2)],
            dtype=np.float32)).astype(np.float32)

        def ajouter(position, extrait):
            position %= longueur
            fin = min(len(extrait), longueur - position)
            mixage[position:position + fin] += extrait[:fin]
            if fin < len(extrait):
                mixage[:len(extrait) - fin] += extrait[fin:]

        ajouter(round(debut * temps * TAUX), stereo)
        if echo:
            for retard, gain in [(0.75, .19), (1.5, .075)]:
                ajouter(round((debut + retard) * temps * TAUX), stereo[:, ::-1] * gain)

    def jouer(midi, debut, duree, volume, timbre, pan=0):
        t = np.arange(round(duree * temps * TAUX)) / TAUX
        f = 440 * 2 ** ((midi - 69) / 12)
        phase = 2 * np.pi * f * t
        relache = np.minimum(1, (t[-1] - t) / .05)
        if timbre == 'nappe':
            son = (np.sin(phase) + .28 * np.sin(phase * 1.002) + .18 * np.sin(phase * 2)) / 1.46
            enveloppe = np.minimum(t / .25, 1) * np.minimum((t[-1] - t) / .35, 1)
        elif timbre == 'basse':
            son = np.sin(phase) + .34 * np.sin(phase * 2) + .11 * np.sin(phase * 3)
            enveloppe = np.minimum(t / .008, 1) * np.exp(-t * 3) * relache
        elif timbre == 'flute':
            son = np.sin(phase + .012*np.sin(2*np.pi*5*t)) + .15*np.sin(phase*2)
            enveloppe = np.minimum(t/.07,1)*np.exp(-t*.8)*relache
        elif timbre == 'corde':
            son = sum(np.sin(phase*k)*np.exp(-t*k*1.8)/k for k in range(1,7))
            enveloppe = np.minimum(t/.012,1)*relache
        elif timbre == 'celesta':
            son = np.sin(phase)*np.exp(-t*1.7)+.28*np.sin(phase*2.01)*np.exp(-t*4)
            enveloppe = np.minimum(t/.005,1)*relache
        elif timbre == 'onde':
            son = np.sin(phase + .55 * np.sin(phase * 2)) + .14 * np.sin(phase * 3)
            enveloppe = np.minimum(t / .012, 1) * np.exp(-t * 1.4) * relache
        else:
            son = np.sin(phase + 1.1 * np.sin(phase * 2) * np.exp(-t * 7))
            son += .14 * np.sin(phase * 3) * np.exp(-t * 6)
            enveloppe = np.minimum(t / .006, 1) * np.exp(-t * (2.7 if timbre == 'cloche' else 4.5)) * relache
        deposer((son * enveloppe).astype(np.float32), debut, volume, pan, timbre == 'cloche')

    def percussion(debut, genre, volume):
        duree = .32 if genre == 'pied' else .18
        t = np.arange(round(duree * TAUX)) / TAUX
        bruit = hasard.uniform(-1, 1, len(t))
        if genre == 'pied':
            son = np.sin(2 * np.pi * (48 * t + 5 * (1 - np.exp(-t * 35)))) * np.exp(-t * 16)
        elif genre == 'caisse':
            son = (.7 * bruit + .3 * np.sin(2 * np.pi * 180 * t)) * np.exp(-t * 28)
        elif genre == 'tom':
            son = np.sin(2 * np.pi * (100 * t + 1.8 * (1 - np.exp(-t * 30)))) * np.exp(-t * 19)
        else:
            son = np.concatenate(([0], np.diff(bruit))) * np.exp(-t * 55) * .4
        son *= np.minimum(t / .002, 1) * np.minimum((t[-1] - t) / .01, 1)
        deposer(son, debut, volume, .25 if genre == 'charley' else 0)

    for mesure in range(32):
        debut = mesure * 4
        degre = accords[(mesure // 2) % 4]
        respiration = 16 <= mesure < 20
        reprise = mesure >= 24
        ouverture = mesure < 4
        intensite = .62 if respiration else (1.13 if reprise else (.76 if ouverture else 1.0))

        # Les couches se retirent puis reviennent pour laisser respirer la boucle.
        for i, intervalle in enumerate([0, 2, 4]):
            jouer(note(degre + intervalle, tonique - 12), debut, 4.2,
                  (.07 if menu else .05) * intensite, 'nappe', (i - 1) * .34)
        if mesure % 4 == 2 and not respiration:
            jouer(note(degre + 7, tonique - 12), debut, 3.6,
                  .025 if menu else .032, 'nappe', .25)

        if menu:
            basses = [0, 2] if profil in ('nuit', 'secret', 'verre') else [0, 1.5, 3]
        elif profil == 'lourd':
            basses = [0, 1.5, 2.75]
        elif profil == 'flottant':
            basses = [0, 1, 2.5, 3.5]
        elif profil == 'mecanique':
            basses = [0, .75, 1.5, 2, 2.75, 3.5]
        else:
            basses = [0, .75, 1.5, 2.5, 3.25]
        for pas, position in enumerate(basses):
            hauteur = degre + (4 if pas == len(basses) - 1 and mesure % 2 else 0)
            jouer(note(hauteur, tonique - 24), debut + position,
                  .9 if menu else .62, (.16 if menu else .23) * intensite, 'basse')

        if not respiration or menu:
            pas_arpege = 4 if menu and profil in ('nuit', 'secret') else 8
            for pas in range(pas_arpege):
                intervalle = arpege[(pas + (mesure // 4) * 2 + style) % 8]
                position = pas * 4 / pas_arpege + (.125 * (pas % 2) if profil == 'flottant' else 0)
                jouer(note(degre + intervalle, tonique), debut + position,
                      .5 if not menu else .76,
                      (.047 if menu else .066) * intensite * (1.16 if pas % 2 == 0 else .8),
                      'onde' if profil in ('flottant', 'nuit') else 'pince',
                      .42 if pas % 2 else -.42)

        if not respiration and (not ouverture or mesure % 2 == 0):
            for pas in range(4):
                hauteur = motif[(mesure % 2) * 4 + pas]
                variation = degre if mesure % 4 >= 2 else 0
                if reprise and mesure % 4 >= 2:
                    variation += 2
                if menu and pas == 1 and mesure % 2:
                    continue
                position = ([0, 1, 2.15, 3] if menu else [0, .75, 1.75, 2.75])[pas]
                jouer(note(hauteur + variation, tonique), debut + position,
                      1.15 if menu else (.82 if pas < 3 else 1.1),
                      (.14 if menu else .18) * intensite, instrument,
                      -.18 if pas % 2 else .12)
        if reprise and mesure % 2 == 1:
            jouer(note(degre + motif[(mesure + 3) % 8] - 7, tonique + 12),
                  debut + 2.5, .7, .045 if menu else .065,
                  'flute' if instrument != 'flute' else 'celesta', .38)

        if menu:
            if profil in ('atelier', 'jardin') and not respiration:
                for position in [0, 2]:
                    percussion(debut + position, 'tom', .028 * intensite)
            if profil in ('verre', 'jardin') and mesure % 2 == 0:
                jouer(note(degre + 11, tonique + 12), debut + 3.5, .48,
                      .04 * intensite, 'celesta', .52)
            continue

        if respiration:
            if mesure == 19:
                for position in [2.5, 3, 3.5, 3.75]:
                    percussion(debut + position, 'tom', .09 + .06 * (position - 2.5))
            continue
        if profil == 'lourd':
            pieds = [0, 1.5, 2.75]
        elif profil == 'flottant':
            pieds = [0, 1.5, 2.5, 3.5]
        elif profil == 'mecanique':
            pieds = [0, 1, 2, 2.75, 3.5]
        elif profil == 'course':
            pieds = [0, .75, 2, 2.75, 3.5]
        else:
            pieds = [0, 1, 2, 3.25]
        for position in pieds:
            percussion(debut + position, 'pied', .3 * intensite)
        for position in [1, 3]:
            percussion(debut + position, 'caisse', .14 * intensite)
        subdivision = 16 if profil in ('course', 'rebond') and (reprise or mesure % 4 >= 2) else 8
        for pas in range(subdivision):
            if ouverture and pas % 2:
                continue
            percussion(debut + pas * 4 / subdivision, 'charley',
                       (.055 if pas % 2 else .075) * intensite)
        if mesure % 8 == 7:
            for position in [3.25, 3.5, 3.75]:
                percussion(debut + position, 'caisse', .075 * intensite)
    # Les queues et echos sont replies au debut pour une jonction sans silence.
    mixage -= mixage.mean(axis=0)
    rms = float(np.sqrt(np.mean(mixage * mixage)))
    crete = float(np.max(np.abs(mixage)))
    mixage *= min((.073 if menu else .105) / rms, .89 / crete)
    with tempfile.TemporaryDirectory() as dossier:
        wav = Path(dossier) / 'composition.wav'
        with wave.open(str(wav), 'wb') as flux:
            flux.setnchannels(2)
            flux.setsampwidth(2)
            flux.setframerate(TAUX)
            flux.writeframes((mixage * 32767).astype('<i2').tobytes())
        cible_lufs = '-18.5' if menu else '-16.5'
        commande = [os.environ.get('FFMPEG', 'ffmpeg'), '-v', 'error', '-y',
                    '-filter_threads', '1', '-i', str(wav),
                    '-af', f'loudnorm=I={cible_lufs}:TP=-1.5:LRA=8', '-ar', str(TAUX),
                    '-c:a', 'libvorbis', '-q:a', '5', '-metadata', f'title={nom}',
                    '-metadata', 'artist=Alambik - composition originale',
                    str(DESTINATION / f'{nom}.ogg')]
        for tentative in range(3):
            rendu = subprocess.run(commande, capture_output=True, text=True,
                                   creationflags=subprocess.CREATE_NO_WINDOW if os.name == 'nt' else 0)
            if rendu.returncode == 0:
                break
            if tentative == 2:
                raise RuntimeError(f'Export de {nom} impossible : {rendu.stderr}')
            time.sleep(.3)
    print(f'{nom}: {longueur / TAUX:.2f} s, {tempo} BPM', flush=True)


if __name__ == '__main__':
    for parametres in PISTES:
        composer(*parametres)
