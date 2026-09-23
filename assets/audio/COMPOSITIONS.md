# Compositions originales

## Collection de vingt choix

Le catalogue `data/musiques.gd` propose **10 musiques en jeu et 10 pour le menu**.
Les identifiants et les choix sauvegardés sont conservés. Les deux premières
pistes de run et `Accueil.ogg` gardent leur composition originale ; leurs sources
intactes se trouvent dans `tools/audio/sources/`. Les 17 autres pistes sont
synthétisées sans samples externes.

| Nouvelle piste | Usage | BPM | Timbre principal |
|---|---|---|---|
| Étincelles | Run | 146 | Célesta |
| Ronde des automates | Run | 118 | Cordes pincées |
| Course en canopée | Run | 132 | Flûte |
| Fournaise de cuivre | Run | 104 | Cordes pincées |
| Marées arcanes | Run | 126 | Clochettes |
| Matin à l’atelier | Menu | 88 | Cordes pincées |
| Jardin de verre | Menu | 76 | Célesta |
| Bibliothèque secrète | Menu | 72 | Clochettes |
| Le thé de l’alchimiste | Menu | 94 | Cordes pincées |
| Serre à l’aube | Menu | 80 | Flûte |
| Poussière d’étoiles | Menu | 68 | Célesta |
| Comptoir de cuivre | Menu | 102 | Cordes pincées |
| Carnet de voyage | Menu | 86 | Flûte |

Chaque piste possède son motif, sa progression et sa tonalité ; gammes majeure,
mineure et dorienne. Les pistes de run ont des pulsations propres, une respiration
centrale et une reprise plus dense. Les pistes de menu sont plus aériennes, avec
quelques percussions légères. Export Ogg stéréo 44,1 kHz, 32 mesures, queues
repliées pour la boucle. La transition de boucle et le rendu sur téléphone restent
à apprécier à l'écoute.

Génération sur demande : `python3 tools/audio/collection.py` avec numpy et ffmpeg
(variable `FFMPEG` facultative). Les anciens rapports de mesure, APK et outils
de diagnostic sont archivés dans `../OldAlambik/2026-09-20/organisation/`
(chemin depuis la racine du projet).

## Première collection

Quatre compositions instrumentales originales, synthétisées sans samples ni mélodies externes. Les fichiers existants `firstarcade.ogg`, `dynamic_arcade.ogg` et `Accueil.ogg` restent disponibles ; `firstarcade.ogg` et `Accueil.ogg` sont les choix par défaut. Leur version jouée est égalisée et alignée en niveau sur les nouveaux morceaux ; `tools/audio/masteriser_originaux.py` repart toujours des fichiers sources intacts.

| Piste | Usage | Tempo | Durée | Couleur |
|---|---|---|---|---|
| Cuivre vif | Run | 124 BPM | 61,94 s | Basse pulsée, clochettes et rythme régulier |
| Vortex d’azur | Run | 138 BPM | 55,65 s | Arpèges rapides et mélodie aérienne |
| Braise volatile | Run | 112 BPM | 68,57 s | Grave plus profond et percussion syncopée |
| Atelier lunaire | Menu | 82 BPM | 93,66 s | Nappes et mélodie cristalline sans batterie |

Chaque morceau comporte 32 mesures, des variations mélodiques et une respiration avant la reprise. Les queues de notes et les échos sont repliés sur le début pour boucler sans silence ajouté. Export Ogg Vorbis stéréo 44,1 kHz, qualité 5.

Reproduction : installer `numpy` pour Python 3 et `ffmpeg`, puis lancer `python3 tools/audio/composer.py`, `python3 tools/audio/collection.py` et `python3 tools/audio/masteriser_originaux.py` depuis la racine. Les générateurs conservent une graine fixe. Le catalogue `data/musiques.gd` alimente les deux sélecteurs des paramètres et valide les choix sauvegardés. Un changement remplace immédiatement la piste de son contexte ; une piste de run choisie depuis le menu s'entend au démarrage de la run.
