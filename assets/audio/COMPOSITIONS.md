# Compositions originales

Le catalogue `data/audio/musiques.gd` propose cinq morceaux : les trois
originaux conservés et deux esquisses à retravailler avec le propriétaire.

| Morceau | Contexte | Source |
|---|---|---|
| First Arcade | Aventure | Composition fournie par le propriétaire |
| Dynamic Arcade | Aventure | Composition fournie par le propriétaire |
| Accueil — originale | Atelier / menu | Composition fournie par le propriétaire |
| Aventure · Esquisse 1 | Aventure | Synthèse originale, `tools/audio/composer.py` |
| Atelier · Esquisse 1 | Atelier / menu | Synthèse originale, `tools/audio/composer.py` |

Les trois fichiers joués du propriétaire ne sont pas modifiés. Leurs sources
intactes restent dans `tools/audio/sources/`. First Arcade et Accueil restent
les choix par défaut. Les deux nouvelles pistes se choisissent dans
**Paramètres → Ambiance sonore**, sous **Pendant l’aventure** et **Dans l’atelier**.

## Deux bases modifiables

- **Aventure** : 120 BPM, 4/4, 64 secondes. Cordes pincées, mélodie de flûte,
  basse et tambour synthétiques ; introduction, thème, réponse, respiration
  et reprise.
- **Atelier** : 80 BPM, 3/4, 72 secondes. Piano doux et notes de verre
  synthétiques, avec une basse discrète et des souffles tenus, sans batterie.

Ces deux compositions n'utilisent aucun sample, enregistrement ou mélodie
externe. Le dictionnaire `PISTES` du générateur contient séparément tempo,
accords et notes ; les timbres et niveaux sont également éditables.
Les graines fixes rendent la synthèse reproductible.

Reproduction avec Python, NumPy et FFmpeg (variable `FFMPEG`, exécutable du
PATH ou paquet `imageio-ffmpeg`) :

```text
python tools/audio/composer.py --piste aventure
python tools/audio/composer.py --piste atelier
```

Omettre `--piste` génère les deux esquisses. Le générateur n'ouvre jamais les
trois originaux. Export Ogg Vorbis stéréo, 44,1 kHz, qualité 6 ; les queues
de notes et de réverbération traversent la jonction de boucle.
Le rendu musical et le confort sur téléphone restent à apprécier à l'écoute.

## Anciens morceaux retirés

Les dix-sept anciennes compositions synthétisées, leurs fichiers d'import
et l'ancien `collection.py` ont été retirés du dépôt à la demande du
propriétaire. Copie de récupération hors dépôt, depuis la racine du projet :

`../Alambik_sauvegardes/menu_audio_2026-09-27_122711/retires/`

L'inventaire `inventaire_retires.json` voisin donne les chemins et empreintes.
L'ancien générateur est conservé dans `avant/tools/audio/composer.py`.
Les identifiants retirés sont explicitement redirigés vers First Arcade
ou Accueil dans `Musiques.PISTES_RETIREES` lors de la lecture de la sauvegarde.
