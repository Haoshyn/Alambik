# Archive de l'état avant ménage — 18 septembre 2026

Ce document conserve l'ancien journal de travail. Ses variantes, commandes, chiffres
de tests et APK sont historiques ; ils ne décrivent ni l'état actif ni des
obligations de vérification. Voir `docs/CURRENT.md` et `AGENTS.md` pour le présent.

---

# État courant — résumé de travail

Ce fichier sert à s'orienter, pas à remplacer les données du jeu. Pour une valeur exacte, lire le catalogue ou `data/reglages.gd` concerné.

## Héros — retour à l'accueil v2, 18 septembre

Le propriétaire rejette l'essai Feutre & cuir. `apprenti_accueil_v2.glb`
est de nouveau actif, avec le modèle et les matières d'avant, inchangés.

## Garantie de drop et calcul économique — 16 septembre

Objet 1/3, garanti à la troisième victoire éligible du chapitre ; sort 1/5,
garanti à la cinquième de son Épreuve. Compteurs persistants, réinitialisés au
drop et inactifs sur défaite ou pool complète ; premier bijou toujours offert.
Aperçus synchronisés avec la vraie probabilité et le compteur restant.
Deux/trois victoires sur chacun des six premiers chapitres : environ 1 638/2 456
gouttes, 664/832 PV et 956/1 240 dégâts bruts encaissables pour un achat équilibré.
Aucune forge inventée sans Mine. Courbe monde 3 recalée à 120 dégâts de référence
et ×3 PV ennemis, en conservant les extrémités de campagne.
Détails, hypothèses et reproduction : `docs/ops/ECONOMIE_MONDE3_ET_GARANTIES.md`.
37 502 assertions et 17 contrôles dédiés réussis ; vingt runs sans blocage.
Les six sondes économiques monde 3 perdent salles 5–6 : confort humain à apprécier.

## Progression, bijoux et prise en main — 16 septembre

Premier chapitre adouci et premier bijou garanti à la victoire. Courbe fixe
exponentielle : 120 dégâts de référence à l’entrée du monde 3, sans
ajustement selon le build réel. Cadence de base réduite de 20 %.
Un pouvoir par bijou au niveau 10 ; forge statistique au-delà, coût exponentiel,
plafond 100. Objets de même budget entre mondes. Dix baguettes, une par monde ;
aiguille moins dominante et cuivre perforant sans perte.
Maîtrises majeures à rang unique aux positions 3/6/9, autres nœuds à dix rangs ;
utilitaire orienté ressources. Anciens achats de maîtrises remboursés une fois.
Sorts +3 % par rang, Réserve d’ultime −45 % de recharge au rang 1.
Conseil initial non bloquant, lancement direct du chapitre touché, fiches de
butin illustrées et cliquables. Détails et limites :
`docs/ops/PROGRESSION_STATISTIQUES.md`, `docs/ops/EFFETS_BIJOUX.md`.

Validation : 31 252 assertions et 47 contrôles d’intégration réussis. Chapitre 1 :
17 victoires sur vingt runs, aucun blocage. Le profil de fin sous-investi en défense
reste insuffisant (mort salle 1 du chapitre 30) ; rythme humain à apprécier en jeu.
Diagnostics de ressources à la fermeture headless persistants.

## Variété des salles — 15 septembre

Six profils de campagne : alcôves, rotonde, galerie allongée, cour large,
ovale et cour décalée. Dimensions partagées par les acteurs et la caméra ;
contour commun au sol 3D et aux collisions. Huit compositions d'obstacles et
quatre arrangements de piliers/jardins. Apparitions vérifiées dans le contour.
18 485 assertions réussies ; vingt runs sans blocage, morts entre les salles
3 et 10. Diagnostics de ressources à la fermeture du selftest inchangés.
Rendu sur téléphone à apprécier. Voir `docs/ops/FORMES_SALLES.md`.

## Coffres, sorts et épreuves — 14 septembre

Invocations de boss : 2 par salve, 18 s minimum, plafond 3, 28 % des PV normaux.
Sorts et ultimes à récupération temporelle ; dégâts et passifs tempérés. Aiguille
vive et Élan avaient des bonus de récupération, retirés lors de la passe du 16 septembre.
Onze niveaux d’épreuve avec loots locaux, zéro augment initial et quatre choix
entre les cinq boss. Coffre interactif à toute fin de run, abandon compris,
vide sans salle terminée ; objets et sorts aléatoires seulement à la victoire.
Aperçu « ! » dans la sélection. Gros scaling offensif multiplicatif, courbe fixe
de PV par chapitre. Zone alchimique et familier désormais visibles en 3D ; icône
de la baguette de base rendue depuis le modèle porté. Validation : 17 700 assertions,
41 d’intégration dédiée et vingt runs sans blocage. Voir
`docs/ops/COFFRES_EPREUVES_RECHARGES.md`. APK : `build/alambic-coffres-epreuves.apk`.

## Direction visuelle intégrée

Apprenti accueil v2, essai après rejet du rendu précédent : buste et jambes
moins tassés, manches volumétriques avec poignets, mains remodelées dont une
main libre entrouverte, tunique reprise et iris bruns. Shader spécifique à
cette variante : ombres de peau chaudes, occlusion atténuée, reflets des yeux
dessinés. Icône Aventure remplacée par des épées croisées. Autres menus et
icônes conservés. Les modèles v9 et accueil v1 restent intacts.
Validation artistique en jeu encore nécessaire ; détails et mesures dans
`docs/ops/APPRENTI_ACCUEIL_V2.md`.
15 120 assertions générales, 22 de matériaux, 643 de fluidité, 30 de
synchronisation, 194 contrôles d'interface et 1 781 de formats réussis.
Vingt runs sans blocage ; APK : `build/alambic-apprenti-accueil-v2.apk`.

Essai Apprenti de l'accueil : le propriétaire conserve les icônes manga.
Bouton Jouer rouge remplacé par une commande violette plus compacte. Projectiles
alliés en perles 3D opaques, avec deux petites perles de traîne ; tirs ennemis
conservés. Variante `apprenti_accueil.glb` active, avec yeux bruns, sourire,
frange remodelée, chapeau incliné et écharpe latérale. Ancien modèle v9 et
ses sources conservés à l'identique ; sélection réversible dans `Visuels3D`.
Rendus Blender dans `tmp/apprenti-accueil/`, ressemblance à apprécier par le
propriétaire. 15 120 assertions générales, 643 de fluidité, 30 de synchronisation,
55 de projectiles, 194 contrôles d'interface et 1 781 de formats réussis.
Vingt runs sans blocage ; APK signée : `build/alambic-apprenti-accueil.apk`.
Détails : `docs/ops/APPRENTI_ACCUEIL.md`.

Essai manga demandé le 14 septembre : accueil et personnage illustrés conservés,
Jouer en sceau corail, modes en ruban prune, navigation espacée avec accents
ambre/corail/menthe/lilas. Maîtrises, sorts et augmentations utilisent 90 icônes
chibi détourées ; cadres métalliques remplacés par des aplats et contours nets,
titres DM Sans. Rouage explicite et livre commun aux deux transitions.
15 120 assertions, 194 contrôles d'interface, 928 de disposition et 1 781 de
formats réussis ; vingt runs sans blocage. Rendu final sur téléphone à apprécier.
Détails : `docs/ops/ESSAI_MANGA.md`.

Menus Éclats d'arcane : fonds bleu/prune, cadres de verre illustrés, titres
Cinzel, 90 icônes, médaillons de maîtrise et cartes d'augmentation teintées.
Accueil avec illustration originale proche de l'Apprenti A ; modèle 3D retiré
de cet écran à la demande du propriétaire. Combat et bestiaire conservés.
15 120 assertions, 194 contrôles d'interface, 924 de disposition et 1 774 de
formats réussis ; vingt runs terminées sans blocage. APK signée :
`build/alambic-eclats-arcane.apk`. Rendu sur téléphone à apprécier ; aucune
fenêtre de jeu ouverte. Détails : `docs/ops/ECLATS_ARCANE.md`.

Confort combat : Tir multiple + Spirale conserve deux tirs droits et deux
latéraux ; huit compositions d'obstacles de tailles et nombres variés. Soin
garanti de 30 % à l'entrée des boss 5/10/15/20, une fois par rencontre ; les
alambics gardent leur choix mais ne donnent plus le soin automatique de 50 %.
Sort ciblé lancé au premier appui sur la zone, monde ralenti à 10 %, vitesse
restaurée à l'annulation, la pause, la mort et la sortie. Une arme initiale ;
aiguille à longue portée (0,70 dégâts × 1,40 cadence), sceptre perforant
(1,20 × 0,70, trois cibles), projectiles aux silhouettes distinctes.
Menus lavande/prune, cadres de maîtrise carrés, textes DM Sans en MSDF,
filtrage linéaire, boutons principaux nets, slogan retiré. HUD adaptatif et
compteurs sans libellés ; PV du héros plus contrastés. Option secousses retirée.
Contrôles : 15 120 assertions, 37 de combat ciblé, 834 de disposition, 38
d'interface, 1 774 de formats. Vingt runs sans blocage ; le bot meurt encore
souvent au premier boss, ce qui ne mesure pas le ressenti humain. Avertissements
de ressources du moteur headless à la fermeture du selftest inchangés.
APK exporté et signature vérifiée : `build/alambic-confort-combat.apk`. Rendu et toucher à valider sur
Pixel ; aucun test avec fenêtre visible.

Paramètres Atelier v3 : listes de musiques et de raccourci harmonisées, hauteur
bornée, curseurs cuivre/turquoise, options multilignes. Parcours réel testé
pendant la pause (38 contrôles), disposition (840), six formats (1 774), tests
généraux et vingt runs réussis. APK : `build/alambic-menus-atelier-v3.apk`.

Menus Atelier vivant v2 : reprise sur la planche du propriétaire, cadres gravés
à neuf tranches, titres Cinzel, cases violettes, armes illustrées, médaillons de
maîtrise et cartes de sorts structurées. Masque rectangulaire de l'accueil
remplacé, compteurs et icône des paramètres corrigés. Contrôles headless :
14 397 assertions, 1 774 contrôles de formats, 19 d'actions et 844 de disposition.
APK : `build/alambic-menus-atelier-v2.apk`. Rendu sur Pixel à valider ; détails
dans `docs/ops/ATELIER_VIVANT.md`. Aucun test avec fenêtre visible.

Atelier vivant intégré : accueil illustré avec héros 3D, menus ivoire/cuivre, navigation originale, dix profils de décors dont Encres en pierre crème et turquoise. Affichage adaptatif sans bandes sur les six formats testés ; 14 397 assertions, 1 775 contrôles de formats et vingt runs terminés. APK : `build/alambic-atelier-vivant.apk`. Validation sur Pixel encore à faire ; détails et diagnostics moteur : `docs/ops/ATELIER_VIVANT.md`.

## Jouable

- Difficulté : miniboss −41,5 % de PV et boss signatures −40 % en campagne ;
  boss des annexes −35 %. Évolution des 31 profils aux mondes 2, 5 et 8 :
  éventails, anneaux décalés, salves successives, charges doubles annoncées et
  variantes des motifs majeurs. Début de campagne conservé. 15 044 assertions
  et 11 957 contrôles des patterns réussis. APK :
  `build/alambic-patterns-evolutifs.apk`. Détails : `docs/ops/PATTERNS_EVOLUTIFS.md`.

- Musiques : dix choix en jeu et dix au menu, dont treize nouvelles compositions
  synthétisées originales (flûte, célesta, cordes pincées, clochettes). Sélection
  dans les paramètres existants ; page d'écoute `tmp/musiques-20/ecouter.html`.
  14 443 assertions et 38 contrôles d'interface réussis, décodage des treize Ogg
  sans écrêtage. APK : `build/alambic-20-musiques.apk`. Détails et reproduction :
  `assets/audio/COMPOSITIONS.md`.

- Apprenti A v9 : finition v8 conservée, buste et jambes moins tassés, bras plus longs avec manches légèrement épaissies, échelle générale augmentée de 2,4 %. GLB et source Blender reconstruits ; 14 397 assertions générales, 643 de fluidité et 30 de synchronisation réussies ; vingt runs sans blocage. APK : `build/alambic-apprenti-v9.apk`. Préférence du propriétaire : aucun test avec fenêtre visible ou prise de focus (voir `AGENTS.md`). Détails : `docs/ops/APPRENTI_A.md`.

- Apprenti A v8 : modèle retravaillé après rejet de la qualité de finition. Pointe et bord du chapeau resculptés, écharpe continue, joues dans la peau, reflets des yeux et rendu doux commun accueil/combat. 74 965 triangles, 12 surfaces, rig et gestes conservés. Vérifications générales, mouvement, synchronisation et vingt runs valides ; approbation artistique encore à faire. APK : `build/alambic-apprenti-v8.apk`. Détails : `docs/ops/APPRENTI_A.md`.

- Reprise arcade du 13 septembre : fusions retirées de la boucle active, haltes à +50 % de PV et choix classique, coups de référence à 15, soins de combat plafonnés, cinq armes de comportement, sorts ciblés en pause et rechargés aux impacts, quatre ultimes maximum. Héros réduit, contact physique corrigé, accueil avec le vrai modèle animé, récompenses précoces et dix rangs de maîtrise. État mesuré et limites : `docs/ops/REWORK_ARCADE.md`.

- HUD et augmentations : PV chiffres et rangee d'inventaire sous l'XP retires ; commandes neutralisees avant les choix/pause pour eviter la course bloquee. Audit des trente augmentations, couts multiplicatifs separes des bonus, reequilibrage offensif/soin/defense. Boss de campagne renforces ; banc controle debutant a 33–41 s, premiere signature a 37 s. Protocole, limites et catalogue complet : `docs/ops/EQUILIBRAGE_AUGMENTATIONS.md`.

- Identite et demarrage : nouvelle icone illustree de l'Apprenti A, variantes Android configurees. Ancienne intro de 1,55 s et message « Le grimoire vivant s'eveille » retires ; menu et navigation disponibles immediatement. Splash moteur masque, fond bleu nuit raccorde au menu. Voir `docs/ops/IDENTITE_DEMARRAGE.md`.

- Apprenti A : silhouette v6 acceptee par le proprietaire. V7 polit les surfaces, raccourcit le lancer a 0,20 s et synchronise le projectile apres 0,05 s de preparation, y compris en rafale. Premier passage sur le decor : dalles claires, bordures chanfreinees, obstacles en pierre avec sceaux cuivre/turquoise et mousse. Essai : `tools/atelier_apprenti.ps1 -EnJeu`. Details et controles dans `docs/ops/APPRENTI_A.md`.

- Apprenti A : geometrie compacte conservee ; la demarche rebondissante v2 a ete rejetee. Sprint v3 compose de poses amples, cycle de 0,4 s, buste penche sans squash, genou lance et talon ramene, bras engages. Atelier avec controleur du jeu, profil et parcours en virages ; matieres toon communes au combat. 615 assertions de mouvement valides ; validation artistique encore a faire. Voir `docs/ops/APPRENTI_A.md`.

- Essai visuel actif : **Apprenti A chibi**, choisi sur la planche du 12 septembre. Nouvelle geometrie Blender originale, sans Meshy, grosse tete, chapeau violet souple, echarpe turquoise, fiole et baguette. 18 os et six animations ; export selectionne en combat. Atelier interactif : `tools/atelier_apprenti.ps1`. Premiere interpretation a valider visuellement ; optimisation mobile encore ouverte. Details : `docs/ops/APPRENTI_A.md`. Le modele B decrit plus bas est conserve mais n'est plus selectionne.

- Campagne structurée en mondes, chapitres et salles, avec miniboss et boss.
- XP de run, augmentations classiques et choix supplémentaires aux haltes ; fusions élémentaires désactivées.
- Équipement, Forge et progression permanente.
- Mine de survie et Épreuves rituelles.
- Sort actif, Passif(s) et Ultime équipables.
- Interface portrait mobile, joystick/tactile, réglages, pause et navigation paginée.
- Combat 3D : modèles GLB existants du héros, gardien, bestiaire, boss, projectiles et décor ; palettes lumineuses des dix mondes.
- Accueil Atelier vivant : fond original d’atelier, Apprenti A 3D animé, éclairage et commandes natives.
- Menus natifs Atelier vivant : équipements Anneau/Collier/Bague, maîtrises, sorts, trois cartes d’amélioration superposées, paramètres, pause, infusion et bilan. Aucun portrait du héros sur ces écrans.
- Salles de campagne aux dimensions variables à partir de 1260 × 1900, six silhouettes et huit compositions d'obstacles. Boss et Épreuves dégagés ; Mine sans retraits sur les bords d'apparition. Caméra de suivi avec vue 3D à 48°.
- 83 glyphes SVG : silhouettes distinctes par amélioration, maîtrise et sort. Bijoux absents dans les emplacements vides. Captures et validation des retouches : `docs/ops/RETOUCHES_GRAPHIQUES.md`.
- Base portrait 1080 × 1920 avec extension adaptative du viewport, sans déformation ni bandes sur les formats testés. Vérifications : `docs/ops/ATELIER_VIVANT.md`.
- Sondes headless et suites de tests maison.

## Architecture de données

Les chiffres et catalogues sont centralisés dans `data/` : réglages généraux, Améliorations, Éléménts, ennemis, objets, chapitres, vagues, récompenses, sorts et Maîtrises. La logique doit consommer ces données au lieu de créer une deuxième source de vérité.

## Points encore ouverts

- Identité environnementale et bestiaire propres à chaque monde.
- Variantes et polissage final des boss.
- Effets finaux de certains équipements et migration d'anciens objets.
- Ajustement fin de l'économie et des paliers des modes annexes.
- Identité finale de certaines transformations élémentaires.
- Contrôle mobile définitif et post-game.
- Découpage progressif des plus gros contrôleurs lorsque leur modification l'exige réellement.

## Vérification

L'état historique détaillé et les anciennes mesures ont été conservés dans `docs/archive/ETAT_2026-08-14.md`. Elles ne doivent pas être considérées comme des mesures actuelles sans relancer les outils.

Pour vérifier l'état présent :

```sh
./verifier.sh
./sondes/vingt_runs.sh
```

