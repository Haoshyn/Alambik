# Musiques additionnelles

Quatre compositions instrumentales originales, synthétisées sans samples ni mélodies externes. Les fichiers existants `firstarcade.ogg`, `dynamic_arcade.ogg` et `Accueil.ogg` sont conservés et restent les choix par défaut.

| Piste | Usage | Tempo | Durée | Couleur |
|---|---|---|---|---|
| Cuivre vif | Run | 124 BPM | 61,94 s | Basse pulsée, clochettes et rythme régulier |
| Vortex d’azur | Run | 138 BPM | 55,65 s | Arpèges rapides et mélodie aérienne |
| Braise volatile | Run | 112 BPM | 68,57 s | Grave plus profond et percussion syncopée |
| Atelier lunaire | Menu | 82 BPM | 93,66 s | Nappes et mélodie cristalline sans batterie |

Chaque morceau comporte 32 mesures, des variations mélodiques et une respiration avant la reprise. Les queues de notes et les échos sont repliés sur le début pour boucler sans silence ajouté. Export Ogg Vorbis stéréo 44,1 kHz, qualité 5.

Reproduction : installer `numpy` pour Python 3 et `ffmpeg`, puis lancer `python3 tools/audio/composer.py` depuis la racine. Le générateur conserve une graine fixe. Le catalogue `data/musiques.gd` alimente les deux sélecteurs des paramètres et valide les choix sauvegardés. Un changement remplace immédiatement la piste de son contexte ; une piste de run choisie depuis le menu s'entend au démarrage de la run.

## Vérification de l’intégration

- `./verifier.sh` : 31 suites, 12 881 assertions, aucune assertion en échec ; sonde de cohérence réussie. La sonde de cohérence émet encore des avertissements de ressources à la fermeture.
- Contrôles en exécution : remplacement sur le même lecteur, maintien du volume du contexte, boucle active, sauvegarde puis rechargement des deux choix ; sélecteurs UI à cinq pistes de run et deux pistes de menu, signaux de sélection vérifiés.
- Décodage des quatre Ogg vérifié : pics inférieurs à 0,88, sans écrêtage ; niveau RMS entre −15 et −14 dBFS. L’écoute subjective et le rendu sur téléphone restent à apprécier.
- Vingt graines de campagne vérifiées (1–20, lot initial interrompu après 8 puis reprise en deux lots) : 20 fins de run, aucune erreur de script. Un blocage du bot à la graine 4, salle 4, est reproduit à l’identique avec les trois fichiers audio/UI remis à leur état Git antérieur dans une copie temporaire ; ce blocage préexiste à la modification musicale.
