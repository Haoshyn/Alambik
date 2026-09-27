"""Deux esquisses originales editables, sans samples ni melodies externes.

Python 3 + numpy + ffmpeg. --piste aventure / atelier / toutes.
Les originaux du proprietaire ne sont jamais ouverts par ce generateur.
"""
from pathlib import Path
import argparse
import os
import shutil
import subprocess
import tempfile
import wave

import numpy as np


TAUX = 44100
DESTINATION = Path(__file__).resolve().parents[2] / "assets/audio"

# Chaque accord porte sa basse et son voicing ; chaque phrase tient une mesure.
# Evenements melodiques : (position en temps, duree en temps, note MIDI).
PISTES = {
    "aventure": {
        "fichier": "aventure_esquisse", "titre": "Aventure - Esquisse 1",
        "tempo": 120, "temps": 4, "mesures": 32, "graine": 270926,
        "lufs": -17.0,
        "accords": [
            (38, [62, 65, 69, 76]), (43, [62, 67, 71, 76]),
            (41, [60, 65, 69, 72]), (36, [60, 64, 67, 74]),
            (38, [62, 65, 69, 72]), (43, [59, 62, 67, 69]),
            (45, [60, 64, 69, 71]), (36, [60, 64, 67, 74]),
        ],
        "theme": [
            [(0, .65, 74), (.75, .4, 77), (1.5, .9, 81), (2.75, .8, 79)],
            [(0, 1.35, 78), (1.5, .4, 76), (2, 1.5, 74)],
            [(.5, .4, 72), (1, .65, 77), (1.75, 1.1, 76), (3, .6, 72)],
            [(0, 1.7, 74), (2.5, .4, 72), (3, .7, 69)],
            [(0, .9, 74), (1.25, .4, 77), (2, .4, 81), (2.75, 1.0, 84)],
            [(0, 1.4, 83), (1.75, .4, 81), (2.5, 1.0, 79)],
            [(.25, .6, 81), (1, .6, 76), (2, .7, 74), (3, .65, 72)],
            [(0, 1.5, 76), (2, .6, 72), (3, .85, 69)],
        ],
        "reponse": [
            [(0, 1.4, 77), (2, .6, 76), (3, .8, 74)],
            [(.5, 1.1, 79), (2, 1.4, 78)],
            [(0, .6, 81), (1, 1.4, 79), (3, .75, 77)],
            [(0, 1.7, 76), (2.5, 1.0, 74)],
        ],
    },
    "atelier": {
        "fichier": "atelier_esquisse", "titre": "Atelier - Esquisse 1",
        "tempo": 80, "temps": 3, "mesures": 32, "graine": 270927,
        "lufs": -19.0,
        "accords": [
            (48, [60, 64, 67, 74]), (43, [59, 62, 67, 69]),
            (45, [60, 64, 69, 71]), (41, [60, 65, 69, 76]),
            (48, [60, 64, 67, 71]), (40, [59, 64, 67, 74]),
            (41, [60, 65, 69, 72]), (43, [59, 62, 67, 74]),
        ],
        "theme": [
            [(.5, .65, 76), (1.5, 1.15, 79)],
            [(0, 1.3, 74), (1.75, .8, 71)],
            [(.25, .8, 72), (1.5, .5, 76), (2.25, .6, 71)],
            [(0, 1.9, 69)],
            [(.5, .6, 67), (1.5, .9, 72)],
            [(0, .8, 71), (1.5, 1.0, 76)],
            [(.5, .8, 77), (1.75, .8, 76)],
            [(0, 1.3, 74), (2, .7, 71)],
        ],
        "reponse": [
            [(.5, 1.6, 79)], [(0, .8, 78), (1.5, 1.0, 74)],
            [(.5, .8, 76), (1.75, .8, 72)], [(0, 2.2, 69)],
        ],
    },
}


def trouver_ffmpeg():
    chemin = os.environ.get("FFMPEG") or shutil.which("ffmpeg")
    if chemin:
        return chemin
    try:
        import imageio_ffmpeg
        return imageio_ffmpeg.get_ffmpeg_exe()
    except ImportError as erreur:
        raise RuntimeError("Indiquer FFMPEG ou installer imageio-ffmpeg.") from erreur


def instrument(note, duree, timbre, hasard):
    t = np.arange(max(2, round(duree * TAUX)), dtype=np.float64) / TAUX
    frequence = 440 * 2 ** ((note - 69) / 12)
    phase = 2 * np.pi * frequence * t
    relache = np.minimum(1, (t[-1] - t) / .08)
    if timbre == "cordes":
        son = sum(np.sin(phase * k + .018 * np.sin(2 * np.pi * 4.2 * t))
                  * np.exp(-t * k * 2.5) / k ** 1.45 for k in range(1, 7))
        enveloppe = np.minimum(t / .007, 1) * relache
    elif timbre == "flute":
        vibrato = .023 * np.sin(2 * np.pi * 4.7 * t) * np.minimum(t / .25, 1)
        son = (np.sin(phase + vibrato) + .13 * np.sin(2 * phase + vibrato)
               + .045 * np.sin(3 * phase))
        enveloppe = np.minimum(t / .065, 1) * relache * (.85 + .15 * np.exp(-t * 2))
    elif timbre == "verre":
        son = (np.sin(phase) * np.exp(-t * 2.1)
               + .23 * np.sin(phase * 2.002) * np.exp(-t * 4)
               + .06 * np.sin(phase * 3.98) * np.exp(-t * 7))
        enveloppe = np.minimum(t / .005, 1) * relache
    elif timbre == "piano":
        son = sum(np.sin(phase * k * (1 + .00009 * k * k))
                  * np.exp(-t * (.9 + k * .6)) / k ** 1.8 for k in range(1, 7))
        enveloppe = np.minimum(t / .006, 1) * relache
    elif timbre == "basse":
        son = np.sin(phase) + .24 * np.sin(2 * phase) + .08 * np.sin(3 * phase)
        enveloppe = np.minimum(t / .014, 1) * np.exp(-t * 1.8) * relache
    elif timbre == "souffle":
        son = (np.sin(phase) + .3 * np.sin(phase * 1.0015)
               + .15 * np.sin(phase * 2)) / 1.45
        enveloppe = np.minimum(t / .4, 1) * np.minimum((t[-1] - t) / .45, 1)
    elif timbre == "tambour":
        son = (np.sin(2 * np.pi * (62 * t + 3 * (1 - np.exp(-t * 24))))
               + .06 * hasard.uniform(-1, 1, len(t)) * np.exp(-t * 60))
        enveloppe = np.minimum(t / .002, 1) * np.exp(-t * 15) * relache
    else:
        bruit = hasard.uniform(-1, 1, len(t))
        son = bruit - np.roll(bruit, 1)
        enveloppe = np.minimum(t / .006, 1) * np.exp(-t * 38) * relache
    return (son * enveloppe).astype(np.float32)


def composer(nom, ffmpeg):
    piste = PISTES[nom]
    aventure = nom == "aventure"
    hasard = np.random.default_rng(piste["graine"])
    temps = 60 / piste["tempo"]
    longueur = round(piste["mesures"] * piste["temps"] * temps * TAUX)
    sec = np.zeros((longueur, 2), dtype=np.float32)
    espace = np.zeros_like(sec)

    def deposer(cible, son, position):
        position %= longueur
        fin = min(len(son), longueur - position)
        cible[position:position + fin] += son[:fin]
        if fin < len(son):
            cible[:len(son) - fin] += son[fin:]

    def jouer(note, debut, duree, volume, timbre, pan=0, reverbe=.2):
        son = instrument(note, duree * temps, timbre, hasard)
        balance = np.sqrt(np.array([(1 - pan) / 2, (1 + pan) / 2], dtype=np.float32))
        stereo = son[:, None] * balance * volume * hasard.uniform(.94, 1.04)
        position = round((debut * temps + hasard.uniform(-.006, .006)) * TAUX)
        deposer(sec, stereo, position)
        deposer(espace, stereo * reverbe, position)

    for mesure in range(piste["mesures"]):
        debut = mesure * piste["temps"]
        basse, accord = piste["accords"][mesure % len(piste["accords"])]
        respiration = 16 <= mesure < 20
        ouverture = mesure < 4
        reprise = 20 <= mesure < 28
        intensite = .68 if respiration else .8 if ouverture else 1.0

        for index, note in enumerate(accord[:3]):
            jouer(note - 12, debut, piste["temps"] + .65,
                  .036 * intensite, "souffle", -.36 + .36 * index, .3)
        jouer(basse, debut, 1.75, .19 if aventure else .12, "basse", 0, .07)
        if aventure and not respiration:
            jouer(basse + 7, debut + 2.5, .7, .105, "basse", 0, .07)
        if aventure:
            positions = [0, .5, 1.5, 2, 2.5, 3.5]
            indices = [0, 2, 1, 3, 2, 1]
        else:
            positions = [0, .5, 1, 1.5, 2, 2.5]
            indices = [0, 2, 1, 3, 2, 1]
        for index, position in enumerate(positions):
            if respiration and index % 2:
                continue
            jouer(accord[indices[index]], debut + position, 1.1 if aventure else 1.8,
                  (.095 if aventure else .075) * intensite,
                  "cordes" if aventure else "piano", -.3 if index % 2 else .28, .3)

        if not ouverture and not respiration:
            phrases = piste["reponse"] if 12 <= mesure < 16 or mesure >= 28 else piste["theme"]
            for index, (position, duree, note) in enumerate(phrases[mesure % len(phrases)]):
                jouer(note, debut + position, duree, .145 if aventure else .17,
                      "flute" if aventure else "verre", .08, .32)
                if reprise and index == 0:
                    jouer(note - 12, debut + position, duree * .8, .045,
                          "cordes" if aventure else "flute", -.24, .3)
        elif mesure % 2 == 0:
            jouer(accord[2] + 12, debut + 1, 1.8, .075, "verre", .35, .38)

        if aventure and not respiration:
            for position, volume in [(0, .21), (1.5, .075), (2, .16), (3.5, .08)]:
                jouer(36, debut + position, .6, volume * intensite, "tambour", 0, .1)
            for pas in range(8):
                if ouverture and pas % 2:
                    continue
                jouer(0, debut + pas * .5, .2, .022 if pas % 2 else .033,
                      "grain", .35 if pas % 2 else -.35, .08)
        if reprise and mesure % 4 == 3:
            jouer(accord[1] + 12, debut + piste["temps"] - .5, 1.5,
                  .045, "verre", -.4, .4)

    # Les retours sont circulaires : les queues traversent la jonction de boucle.
    mixage = sec.copy()
    for retard, gain, inverse in [(.073, .34, False), (.113, .25, True),
                                  (.191, .19, False), (.283, .13, True),
                                  (.431, .09, False), (.617, .06, True)]:
        retour = espace[:, ::-1] if inverse else espace
        mixage += np.roll(retour, round(retard * TAUX), axis=0) * gain
    mixage -= mixage.mean(axis=0)
    mixage *= .84 / max(float(np.max(np.abs(mixage))), 1e-8)
    assert np.isfinite(mixage).all(), "Valeur audio invalide"
    DESTINATION.mkdir(parents=True, exist_ok=True)
    with tempfile.TemporaryDirectory() as dossier:
        wav = Path(dossier) / "composition.wav"
        with wave.open(str(wav), "wb") as flux:
            flux.setnchannels(2)
            flux.setsampwidth(2)
            flux.setframerate(TAUX)
            flux.writeframes((mixage * 32767).astype("<i2").tobytes())
        commande = [ffmpeg, "-v", "error", "-y", "-i", str(wav),
                    "-af", f"loudnorm=I={piste['lufs']}:TP=-2:LRA=8", "-ar", str(TAUX),
                    "-c:a", "libvorbis", "-q:a", "6",
                    "-metadata", f"title={piste['titre']}",
                    "-metadata", "artist=Alambik - composition originale synthetisee",
                    "-metadata", f"BPM={piste['tempo']}",
                    str(DESTINATION / (piste["fichier"] + ".ogg"))]
        subprocess.run(commande, check=True,
                       creationflags=subprocess.CREATE_NO_WINDOW if os.name == "nt" else 0)
    print(f"{piste['titre']} : {longueur / TAUX:.2f} s, {piste['tempo']} BPM, "
          f"{piste['temps']}/4, {piste['mesures']} mesures", flush=True)


if __name__ == "__main__":
    arguments = argparse.ArgumentParser(description=__doc__)
    arguments.add_argument("--piste", choices=[*PISTES, "toutes"], default="toutes")
    choix = arguments.parse_args().piste
    ffmpeg = trouver_ffmpeg()
    for nom in PISTES if choix == "toutes" else [choix]:
        composer(nom, ffmpeg)
