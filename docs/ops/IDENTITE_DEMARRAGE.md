# Icone et demarrage — 12 septembre 2026

L'icone represente l'Apprenti A : visage rond, chapeau violet, echarpe turquoise
et fiole lumineuse. Illustration generee a partir du personnage du jeu.
La source est conservee dans `docs/art/identite/icone_source.png`, hors export.

`tools/preparer_identite.gd` produit les PNG de distribution avec Godot :
512 px pour le projet, 192 px pour le lanceur Android, 432 px pour la couche
adaptative et son fond. Les chemins sont definis dans `project.godot` et
`export_presets.cfg`. Le masque final de l'icone est choisi par le lanceur Android.

L'ancienne introduction du menu masquait les pages et la navigation pendant
1,55 seconde alors que leur construction etait deja terminee. Elle est supprimee,
ainsi que la fiole procedurale et le message « Le grimoire vivant s'eveille… ».
La transition d'entree habituelle du menu est conservee. Aucun nouveau temps
d'attente n'est impose. Le logo moteur est masque et son fond bleu nuit correspond
au fond du menu. Le temps reel d'initialisation des ressources reste necessaire.

Verification visuelle : `sondes/demarrage_menu.gd`, profil de sauvegarde isole.
Quatre controles valident la disponibilite immediate des pages, de la navigation
et la configuration du splash. Captures : `tmp/demarrage-premiere-image.png`
et `tmp/demarrage-menu.png`.

Verification generale : 32 suites, 13 425 assertions, aucun echec ; selftest valide.
Serie de vingt runs : un blocage du bot, graine 13 salle 4, dernier ennemi a
11 PV apres 120 s. Pas d'erreur de script ; cette serie n'est pas validee.
Journal : `tmp/identite-vingt-runs.log`. Les controles du demarrage passent.
Aucune nouvelle APK exportee ou installee pour cette retouche. L'icone du lanceur
Android sera prise en compte a la prochaine mise a jour de l'application.
