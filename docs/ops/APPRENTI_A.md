# Apprenti A — essai 3D du 12 septembre 2026

Le proprietaire a retenu la proposition A de la planche chibi. Le nouveau modele
est construit dans Blender par `tools/blender/apprenti_a.py`, sans Meshy ni nouvelle
generation d'image. C'est une premiere interpretation 3D de la reference, a valider
visuellement en mouvement. Les decors et monstres ne font pas partie de cet essai.

## Sources et integration

- Source editable : `assets/3d/sources/characters/apprenti_a.blend`.
- Export selectionne dans `data/visuels_3d.gd` : `assets/3d/characters/apprenti_a.glb`.
- Version avec prise corrigee : 18 os, 14 surfaces, 72 656 triangles avant LOD Godot,
  GLB de 2,57 Mo.
- Six animations : repos, sprint (clip `course`, 24 images a 60 Hz), attaque,
  touche, mort, victoire. Import Godot des animations a 60 Hz.
- Noms d'os compatibles avec le filtrage du haut du corps et le controleur existant.
- Ancien modele B conserve pour comparaison et retour eventuel.

Reconstruction :

```powershell
& 'C:/Program Files/Blender Foundation/Blender 5.2/blender.exe' --background --python tools/blender/apprenti_a.py
```

Atelier interactif avec boutons de poses et vues :

```powershell
./tools/atelier_apprenti.ps1
```

Ajouter `-EnJeu` pour ouvrir une vraie run jouable avec le profil d'essai isole.

Le rendu Blender, les trois vues Godot et les images de course sont dans
`tmp/apprenti-a/`. La sonde `sondes/atelier_apprenti.gd -- --capturer` regenere
les vues et 48 images de course. Le profil d'essai est isole de la sauvegarde.

## Reprise apres rejet de la premiere animation

La premiere interpretation a ete rejetee : corps trop humain et course donnant
l'impression d'un plot qui remue les pieds. La version compacte raccourcit le
buste d'environ 40 % et les jambes d'environ 47 % par rapport au premier export,
elargit les volumes et arrondit la tunique. Fioles et mains gardent leur rondeur.

La seconde demarche a egalement ete rejetee : marche rebondissante, impression
de bubblegum. Le sprint actuel remplace cette animation, sans changer la geometrie.
Il est compose de poses de contact, passage, poussee, talon ramene et genou lance.
Le cycle dure 0,4 seconde. Le buste penche d'environ 23 degres vers l'avant, sans
compression ni etirement, et varie peu en hauteur. Les bras balancent largement,
les genoux se replient franchement, l'echarpe reste tiree vers l'arriere. Les
controles verifient aussi l'absence de deformation elastique et l'amplitude des
membres ; ils ne remplacent pas la validation artistique du proprietaire.

L'atelier utilise maintenant le controleur de combat pour les transitions et les
tirs. Le bouton Parcours ajoute de vrais deplacements et virages. L'option
`--capturer --parcours` produit aussi 150 images de demarrage, course, tir et arret.
Les nouveaux apercus sont `tmp/apprenti-a/sprint-v3.gif` et
`tmp/apprenti-a/parcours-sprint-v3.gif`. Les GIF v1 et v2 restent disponibles pour
comparaison. Le bouton Profil montre la projection de la foulee.

`scripts/presentation/materiaux_apprenti.gd` partage entre atelier et combat un
eclairage diffus enveloppant, sans reception d'ombres sur le personnage. Il
continue a projeter son ombre au sol. Ce choix privilegie la lisibilite toon.

## Validation et limites

### Prise et coups de baguette (v4, historique)

Le proprietaire conserve provisoirement le sprint v3. Ses poses n'ont pas change.
La main droite a maintenant une paume, des doigts replies et un pouce referme.
Le manche traverse la prise et pointe vers l'avant/bas au repos. Toute l'assemblee
est construite dans un repere commun, puis liee au seul os `main_droite` : aucune
orientation independante de la baguette. La transformation compacte preserve la
position relative des doigts et du manche.

Le coup combine preparation courte, projection du bras, mouvement du coude,
rotation et inclinaison du buste, compensation de la tete et bras libre en contrepoids.
Le fondu d'entree du tir passe a 45 ms. Les jambes du sprint restent hors du filtre.
Les impacts recus engagent aussi tete, buste et bras. La cadence de tir logique
et les degats ne changent pas.

Apercus : `attaque-v4.gif`, `attaque-dessus-v4.gif`, `prise-030.png`, `combat-v4.gif`
dans `tmp/apprenti-a/`. `sondes/apercu_apprenti_en_jeu.gd` capture une vraie salle :
deplacements, arrets et tirs automatiques, avec une cible immobilisee et rendue
resistante uniquement pour la capture. La camera, les projectiles et le controleur
sont ceux du jeu.
Pour enregistrer cette sonde, passer `--fixed-fps 30` a Godot : le temps simule
reste constant meme si l'ecriture des PNG ralentit le rendu.

- Verification generale : 31 suites, 12 882 assertions, aucun echec ; selftest valide.
- Fluidite : 619 assertions, aucun echec ; sprint conserve, baguette liee a la main,
  coude, buste et bras libre engages pendant le coup.
- Integration graphique : aucun echec ; modele reel en salle, animations,
  projection, nettoyage et profil reduit controles.
- Vingt runs v4 : **1 echec / 20**. Graine 3, salle 2, blocage du bot apres 120 s :
  heros (705,875), ennemi (325,732) a 1 PV. Reproduit par une relance isolee de la
  graine 3 (`tmp/apprenti-a-graine3-v4.log`). Pas d'erreur de script ; la cause
  de navigation reste a diagnostiquer. Ne pas presenter cette serie comme validee.
- Certains processus Godot signalent des ressources encore allouees a l'arret.
  Cela ne constitue pas une validation de leur nettoyage complet.
- Le rendu temps reel garde des ombres plus dures que le studio Blender.
- La densite du modele et les performances sur telephone restent a mesurer et
  optimiser apres validation artistique. Aucune nouvelle APK dans cet essai.

Journaux courants : `tmp/apprenti-a-verification-v4.log`, `tmp/apprenti-a-fluidite-v4.log`,
`tmp/apprenti-a-integration-v4.log`, `tmp/apprenti-a-vingt-runs-v4.log`.

### Corps rond et lancer du bras (v5, historique)

La demande suivante remplace le buste tres engage de v4 : largeur et profondeur
egales pour la tunique, sans augmenter la hauteur ; geste ample du bras et du
poignet, buste presque fixe. Les rayons des anneaux compensent la mise a l'echelle
finale pour obtenir des sections circulaires. Ceinture, boucle, fiole et plastron
suivent ce nouveau volume. Le baton pointe horizontalement au repos, toujours
solidaire de la main fermee. L'epaule ouvre le bras, le coude arme puis se deplie,
le poignet accompagne la projection. Le buste reste sous 0,06 radian pendant le
lancer. Les poses du sprint v3 sont conservees.

Apercus actuels : `attaque-v5.gif`, `attaque-dessus-v5.gif`, `sprint-v5.gif`,
`combat-v5.gif` et `godot-profil.png` dans `tmp/apprenti-a/`.
Le controle d'integration mesure l'excursion de la main pendant le geste plutot
que sa seule position a une image donnee. La validation artistique et la mesure
des performances Android restent a faire.

Controles v5 : verification generale (31 suites, 12 882 assertions) et selftest
valides ; fluidite (643 assertions) et integration graphique sans echec. Excursion
de la main mesuree a 0,087 unite dans le squelette pendant le lancer. La serie des
vingt runs compte deux blocages : graine 3 salle 2 et graine 5 salle 11. Ces echecs
du bot restent a diagnostiquer ; la serie n'est pas validee. Journaux dans
`tmp/apprenti-a-*-v5.log`. Les avertissements de ressources a l'arret persistent.

### Silhouette verticale et bras continus (v6)

La v5 ne corrigeait que la tunique : la tete et le bord du chapeau restaient
elliptiques. La v6 donne aussi de la profondeur au visage et a ses accessoires,
et rend le bord du chapeau circulaire et plat. La vue orthographique « Dessus »
de l'atelier pointe exactement a 90 degres. L'export controle la largeur et la
profondeur apres transformation : visage 0,88312 / 0,88312 ; tunique
0,63218 / 0,63218 ; bord du chapeau 1,32410 / 1,32410 unite.

Les deux grosses coques de manches sont retirees. Une manche continue aux poids
progressifs relie l'epaule au poignet et se plie au coude. Les mains comportent
une paume arrondie, trois doigts replies autour de l'axe du manche et un pouce,
fusionnes en une surface continue. Main et baguette partagent toujours le meme
os. Le sprint v3 et le lancer v5 restent identiques.

Modele : 84 357 triangles avant LOD, 14 surfaces, 18 os, GLB de 2,90 Mo. La
validation de maillage est executee apres fusion des surfaces dans Blender.
Apercus : `godot-dessus.png`, `prise-v6.png`, `attaque-v6.gif`,
`attaque-dessus-v6.gif` et `combat-v6.gif` dans `tmp/apprenti-a/`.

Controles v6 : 31 suites / 12 882 assertions et selftest valides ; fluidite
643 assertions et integration graphique sans echec. La serie des vingt runs
compte un blocage, graine 3 salle 2 (dernier ennemi a 1 PV), encore a diagnostiquer.
Les dix-neuf autres runs se terminent sans blocage ni erreur de script ; une
defaite du bot est un resultat de jeu, pas un echec du harnais. Journaux
`tmp/apprenti-a-*-v6.log`. Des ressources restent signalees a l'arret de Godot.

### Finition, synchronisation et premier decor (v7)

Le proprietaire accepte la silhouette v6. Les spheres passent a 32 segments et
20 anneaux ; les normales lisses sont reappliquees apres fusion des maillages.
Les proportions et le sprint sont conserves. Le modele compte 95 269 triangles
avant LOD et 14 surfaces ; le GLB fait 3,27 Mo. L'optimisation Android reste ouverte.

Le lancer dure 0,20 s au lieu de 0,40 s. La projection correspond a 0,05 s,
apres une preparation courte. Le heros emet `attaque_preparee`, puis le vrai
`tir_demande` apres `Reglages.TIR_PREPARATION`. Le son et le compteur des tirs
suivent l'emission reelle. Chaque balle de rafale est preparee separement. Les
intervalles de cadence restent ceux du catalogue ; la premiere emission gagne
50 ms d'anticipation. Un geste engage peut se terminer en mouvement ; la mort
et l'entree dans une nouvelle salle annulent les projectiles en attente.

Le controleur 3D recale la pose sur la projection au signal du projectile et la
preserve pour la premiere image affichee. Il avance les jambes normalement.
Le retour du bras a un fondu de 45 ms. La sonde `synchronisation_tir.gd` couvre
30, 60 et 120 Hz, les rafales et l'annulation a la mort.

Premier decor de cour alchimique : shader de grandes dalles aux joints discrets,
legeres variations de pierre et biseaux eclaires ; bordures chanfreinees ;
obstacles construits aux dimensions de leurs rectangles physiques, coiffes de
pierre claire, de sceaux cuivre/turquoise et de mousse. Le contour de salle,
les collisions et les monstres restent ceux du jeu. Les palettes de mondes
teintent encore le sol ; ce passage ne constitue pas une refonte complete des
dix environnements ni du portail. La direction du decor reste a valider.

Sources : `shaders/dalles_alchimiques.gdshader`,
`scripts/presentation/decor_alchimique.gd` et `arene_3d.gd`.
La geometrie des pierres est testee : normales vers l'exterieur et emprise
exacte malgre les chanfreins. Captures reproductibles avec
`sondes/apercu_apprenti_en_jeu.gd -- --graine=1`, et `--detail` pour le gros plan.

Apercus en temps reel : `tmp/apprenti-a/cour-alchimique-v7.webm` et
`tmp/apprenti-a/lancer-synchronise-v7.webm` (30 images/s, six secondes chacun),
avec `cour-alchimique-v7.png` pour l'image fixe.
Controles : 32 suites / 13 425 assertions sans echec et selftest valide ;
643 assertions de fluidite et 30 de synchronisation sans echec ; integration
graphique sans echec. Les avertissements de ressources a l'arret persistent.
La serie finale des vingt runs se termine avec **0 echec / 20** (journal
`tmp/apprenti-a-vingt-runs-v7-final.log`). Les defaites restent des resultats
normaux du bot ; aucun blocage ni erreur de script dans cette serie.
