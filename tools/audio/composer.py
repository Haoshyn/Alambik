"""Compositions originales Alambik. Python 3 + numpy, ffmpeg dans PATH.
Reproduction : python3 tools/audio/composer.py. Aucun sample externe.
"""
from pathlib import Path
import subprocess
import tempfile
import wave
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


def note(degre, tonique):
    return tonique + GAMME[degre % 7] + 12 * (degre // 7)


def composer(nom, tempo, tonique, accords, style):
    hasard = np.random.default_rng(310 + style)
    temps = 60 / tempo
    longueur = round(32 * 4 * temps * TAUX)
    mixage = np.zeros((longueur, 2), dtype=np.float64)

    def deposer(son, debut, volume, panoramique=0.0, echo=False):
        indices = (round(debut * temps * TAUX) + np.arange(len(son))) % longueur
        stereo = son[:, None] * volume * np.array([
            np.sqrt((1 - panoramique) / 2), np.sqrt((1 + panoramique) / 2)])
        np.add.at(mixage, indices, stereo)
        if echo:
            for retard, gain in [(0.75, .23), (1.5, .12), (2.25, .06)]:
                np.add.at(mixage, (indices + round(retard * temps * TAUX)) % longueur,
                          stereo[:, ::-1] * gain)

    def jouer(midi, debut, duree, volume, timbre, pan=0):
        t = np.arange(round(duree * temps * TAUX)) / TAUX
        f = 440 * 2 ** ((midi - 69) / 12)
        phase = 2 * np.pi * f * t
        relache = np.minimum(1, (t[-1] - t) / .05)
        if timbre == 'nappe':
            son = (np.sin(phase) + .28 * np.sin(phase * 1.002) + .18 * np.sin(phase * 2)) / 1.46
            enveloppe = np.minimum(t / .25, 1) * np.minimum((t[-1] - t) / .35, 1)
        elif timbre == 'basse':
            son = np.sin(phase) + .25 * np.sin(phase * 2) + .12 * np.sin(phase * 3)
            enveloppe = np.minimum(t / .008, 1) * np.exp(-t * 2) * relache
        else:
            son = np.sin(phase + 1.5 * np.sin(phase * 2) * np.exp(-t * 9))
            son += .22 * np.sin(phase * 3) * np.exp(-t * 7)
            enveloppe = np.minimum(t / .006, 1) * np.exp(-t * (3 if timbre == 'cloche' else 7)) * relache
        deposer(son * enveloppe, debut, volume, pan, timbre == 'cloche')

    def percussion(debut, genre, volume):
        duree = .32 if genre == 'pied' else .18
        t = np.arange(round(duree * TAUX)) / TAUX
        bruit = hasard.uniform(-1, 1, len(t))
        if genre == 'pied':
            son = np.sin(2 * np.pi * (48 * t + 5 * (1 - np.exp(-t * 35)))) * np.exp(-t * 16)
        elif genre == 'caisse':
            son = (.7 * bruit + .3 * np.sin(2 * np.pi * 180 * t)) * np.exp(-t * 28)
        else:
            son = np.concatenate(([0], np.diff(bruit))) * np.exp(-t * 65) * .4
        son *= np.minimum(t / .002, 1) * np.minimum((t[-1] - t) / .01, 1)
        deposer(son, debut, volume, .25 if genre == 'charley' else 0)

    for mesure in range(32):
        debut = mesure * 4
        degre = accords[(mesure // 2) % 4]
        # Une respiration centrale puis une reprise evite une boucle uniforme.
        respiration = 16 <= mesure < 20
        for i, intervalle in enumerate([0, 2, 4, 6]):
            jouer(note(degre + intervalle, tonique), debut, 4.15, .085 if style != 3 else .12,
                  'nappe', (i - 1.5) * .36)
        for pas in range(8 if style != 3 else 4):
            position = pas * (.5 if style != 3 else 1)
            jouer(note(degre, tonique - 12), debut + position, .42 if style != 3 else .95,
                  .24 if style != 3 else .16, 'basse')
        if not respiration or style == 3:
            for pas in range(8):
                intervalle = [0, 4, 2, 6, 4, 2, 7, 4][(pas + style) % 8]
                jouer(note(degre + intervalle, tonique + 12), debut + pas * .5, .4,
                      .055 if style != 1 else .085, 'pince', (-1 if pas % 2 else 1) * .45)
        if mesure % 4 != 3 or mesure >= 24:
            for pas in range(4):
                motif = MOTIFS[style][(mesure % 2) * 4 + pas]
                jouer(note(motif + (degre if mesure % 4 >= 2 else 0), tonique),
                      debut + pas + (0.25 if style == 2 and pas % 2 else 0),
                      1.6 if style == 3 else .85, .15 if style != 3 else .17, 'cloche', -.12)
        if style != 3 and not respiration:
            for position in ([0, 1, 2, 3] if style != 2 else [0, 1.5, 2.75]):
                percussion(debut + position, 'pied', .42)
            for position in [1, 3]:
                percussion(debut + position, 'caisse', .15)
            for pas in range(8):
                percussion(debut + pas * .5, 'charley', .075 if pas % 2 else .04)
            if mesure % 8 == 7:
                for position in [3.25, 3.5, 3.75]:
                    percussion(debut + position, 'caisse', .07)
    # Les queues et echos sont replies au debut pour une jonction sans silence.
    mixage -= mixage.mean(axis=0)
    mixage = np.tanh(mixage * 1.3)
    mixage *= .84 / np.max(np.abs(mixage))
    with tempfile.TemporaryDirectory() as dossier:
        wav = Path(dossier) / 'composition.wav'
        with wave.open(str(wav), 'wb') as flux:
            flux.setnchannels(2)
            flux.setsampwidth(2)
            flux.setframerate(TAUX)
            flux.writeframes((mixage * 32767).astype('<i2').tobytes())
        subprocess.run(['ffmpeg', '-v', 'error', '-y', '-i', str(wav), '-c:a', 'libvorbis',
                        '-q:a', '5', '-metadata', f'title={nom}', '-metadata',
                        'artist=Alambik - composition originale', str(DESTINATION / f'{nom}.ogg')], check=True)
    print(f'{nom}: {longueur / TAUX:.2f} s, {tempo} BPM', flush=True)


if __name__ == '__main__':
    for parametres in PISTES:
        composer(*parametres)
