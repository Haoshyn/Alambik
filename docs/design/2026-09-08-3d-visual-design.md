# Alambik — migration 3D visuelle avec gameplay 2D

Date : 2026-09-08
Statut : conception validée en conversation, à relire avant implémentation

## 1. Objectif

Transformer Alambik en un jeu visuellement 3D, stylisé et premium, tout en conservant la logique de gameplay 2D existante autant que possible.

Le joueur doit percevoir :
- des personnages réellement modélisés en 3D ;
- des ennemis, boss, projectiles et obstacles en 3D ;
- des arènes 3D avec profondeur, éclairage, matériaux et ombres ;
- une caméra top-down / trois-quarts adaptée au format portrait mobile ;
- une direction artistique plus sobre que la version actuelle : moins d'ornements, moins de saturation globale, moins de halos permanents, davantage d'espace visuel calme.

Le système de jeu conserve sa logique 2D : déplacements, ciblage, collisions, IA, géométrie des salles, tests et équilibrage restent basés sur Vector2 / CharacterBody2D / Rect2 tant qu'une migration n'est pas nécessaire.

## 2. Principe d'architecture

### 2.1 Couche logique

Les entités de gameplay restent des Node2D / CharacterBody2D :
- héros ;
- ennemis ;
- boss ;
- projectiles ;
- obstacles ;
- salle et limites de déplacement.

Cette couche continue de produire les positions, états et signaux utilisés par le jeu.

### 2.2 Couche visuelle 3D

Une scène 3D parallèle représente le même espace de combat.

Conversion de coordonnées de base :
- gameplay 2D `(x, y)` ;
- rendu 3D `(x * 0.01, 0, y * 0.01)`.

L'échelle initiale est donc fixée à **0,01 unité 3D par unité 2D**. Cette valeur vit dans un pont unique et peut être ajustée ultérieurement sans modifier les scripts de gameplay. Aucune conversion dispersée n'est autorisée.

Chaque entité logique importante possède un proxy visuel 3D. Le proxy :
- suit la position 2D ;
- suit l'orientation utile ;
- lit les états de mouvement / attaque / dégâts / mort ;
- déclenche les animations et VFX correspondants ;
- ne prend aucune décision de gameplay.

Les collisions et la logique de visée ne dépendent pas des meshes 3D.

## 3. Direction artistique 3D

### 3.1 Identité générale

Fantasy alchimique colorée mais maîtrisée.

Le rendu ne cherche ni le photoréalisme ni le low-poly brut. Il vise une 3D stylisée propre, avec :
- silhouettes simples et fortes ;
- volumes lisibles sur petit écran ;
- textures peintes / stylisées ;
- matériaux mats majoritaires ;
- surfaces brillantes limitées au verre, métal, liquides et cristaux ;
- palette globale légèrement désaturée par rapport aux assets actuels ;
- accents saturés réservés aux attaques, dangers, récompenses et magie active.

### 3.2 Sobriété visuelle

Le rendu doit corriger l'excès d'ornementation actuel.

Règles :
- un matériau ou une couleur dominante par grande surface ;
- détails concentrés sur les bords et points d'intérêt ;
- zones de combat centrales simples et calmes ;
- pas de glow permanent sur tous les objets ;
- pas de particules décoratives continues en grand nombre ;
- pas de contours noirs épais généralisés ;
- pas de saturation maximale sur le décor ;
- pas d'amas de fioles, cristaux, plantes et ornements simultanément ;
- les éléments interactifs doivent être plus contrastés que l'environnement ;
- le danger doit toujours dominer visuellement le décor.

### 3.3 Palette cible

Base environnementale :
- pierre claire légèrement froide ;
- verts mousse / sauge ;
- bleu-gris / saphir atténué ;
- bois ou cuir brun doux ;
- cuivre vieilli et or chaud en accent.

Magie :
- violet / lavande pour l'identité du héros ;
- turquoise / cyan pour l'alchimie et certains portails ;
- couleurs élémentaires plus saturées uniquement pendant l'action.

Ombres : bleu-violet sombre plutôt que noir pur.

## 4. Héros 3D

Identité conservée :
- jeune alchimiste-mage androgyne ;
- grand chapeau violet asymétrique ;
- liserés cuivre-or ;
- écharpe turquoise ;
- sacoche de fioles ;
- baguette en forme de cornue ;
- yeux ambre ;
- magie violette de base.

Simplifications pour la lisibilité mobile :
- peu de petits accessoires ;
- fioles regroupées plutôt que nombreuses ;
- silhouette du chapeau et de l'écharpe fortement identifiable ;
- détails de visage simples ;
- matières propres, non réalistes.

Animations minimales :
- idle ;
- marche/course ;
- attaque/tir ;
- touché ;
- mort ;
- victoire ou courte pose de fin si nécessaire.

Animations secondaires :
- écharpe ;
- bord du chapeau ;
- sacoche / fiole principale ;
- léger squash/stretch lors d'une attaque ou d'un impact.

## 5. Ennemis et boss

Chaque famille garde une silhouette différente et un langage visuel lié à sa fonction.

Les modèles 3D doivent être plus simples que leurs planches actuelles, pas plus chargés.

Principes :
- 1 silhouette forte ;
- 1 détail de lecture principal ;
- 1 accent magique maximum en état neutre ;
- intensification visuelle uniquement lors des attaques ou états spéciaux.

Les boss peuvent avoir davantage de détail, mais leurs zones vulnérables, télégraphes et attaques doivent rester plus lisibles que leur décoration.

## 6. Arène 3D — Atelier verdoyant

La première arène sert de vertical slice et de référence pour le pipeline.

Ambiance : jardin d'alchimiste en ruine au-dessus d'une eau turquoise, lumière douce de matin ou fin de matinée.

Composition :
- centre de combat très dégagé ;
- sol en pierre claire / dalle légèrement moussue ;
- bordures avec végétation modérée ;
- quelques éléments cuivre / verre ;
- eau visible hors zone de combat ;
- architecture et cascades en arrière-plan ;
- portail de sortie cyan-violet ;
- pas de surcharge de fioles, lanternes, cristaux et plantes simultanément.

Kit modulaire recommandé :
- dalle sol ;
- bord droit ;
- coin ;
- muret ;
- rochers ;
- jardinière / bosquet ;
- colonne ou ruine ;
- tuyau / cuivre discret ;
- cristal occasionnel ;
- portail ;
- eau ;
- éléments de fond hors gameplay.

Le centre jouable doit pouvoir être compris sans texture complexe au sol.

## 7. Caméra et rendu

La cible initiale est une **Camera3D orthographique inclinée**. C'est le choix par défaut de la migration afin de préserver la lecture tactique et la correspondance avec les distances du gameplay 2D.

Cible initiale :
- vue trois-quarts top-down ;
- caméra inclinée d'environ 55° vers le sol ;
- aucune rotation libre par le joueur ;
- cadrage portrait 9:16 ;
- taille orthographique réglée pour couvrir toute la largeur jouable et la hauteur utile de la salle ;
- personnage lisible même sur écran mobile ;
- pas de perspective susceptible de fausser la lecture des distances ou des hitboxes.

Une variante perspective ne sera envisagée qu'après la vertical slice, si elle apporte un gain visuel évident sans dégrader la lisibilité.

Le pont 2D→3D doit assurer que les éléments visuels restent alignés sur les positions de collision.

## 8. Éclairage

Éclairage sobre et lisible :
- une lumière principale douce ;
- une lumière d'ambiance / environnement ;
- quelques lumières locales seulement sur des éléments importants ;
- ombres douces ;
- rim light léger pour le héros et certains ennemis si nécessaire.

Les effets emissifs ne doivent pas éclairer toute la scène en permanence.

## 9. Matériaux

Bibliothèque commune :
- pierre claire ;
- pierre moussue ;
- cuivre vieilli ;
- or chaud ;
- bois ;
- tissu violet ;
- tissu turquoise ;
- cuir ;
- verre ;
- liquide alchimique ;
- cristal ;
- encre ;
- magie emissive contrôlée.

Les matériaux doivent partager une logique cohérente de roughness, couleur et émission.

## 10. VFX

Les VFX doivent être plus intenses que le décor mais plus courts que dans un rendu « flashy » permanent.

Utiliser :
- impacts courts ;
- trails fins ;
- particules peu nombreuses ;
- flash d'attaque ;
- télégraphes propres ;
- anneaux ou glyphes ponctuels ;
- légère distorsion ou émission uniquement si compatible mobile.

Éviter :
- brouillard de particules permanent ;
- bloom excessif ;
- halos de grande taille sur chaque acteur ;
- effets masquant les projectiles ennemis.

## 11. Interface

L'UI reste en 2D Control / CanvasLayer.

Elle ne doit pas être convertie en mesh 3D.

La DA UI peut être simplifiée plus tard pour correspondre au rendu plus sobre :
- panneaux saphir moins décorés ;
- bordures plus fines ;
- moins d'ornements dorés ;
- hiérarchie typographique plus nette.

La migration 3D ne doit pas obliger à refaire immédiatement toute l'interface.

## 12. Pipeline Blender → Godot

### 12.1 Organisation cible

`tools/blender/`
- scripts de génération / préparation ;
- création des matériaux ;
- rig ;
- export ;
- validation.

`assets/3d/`
- characters/ ;
- enemies/ ;
- bosses/ ;
- environment/ ;
- props/ ;
- projectiles/ ;
- materials/.

`scenes/3d/`
- monde_3d.tscn ;
- heros_visuel_3d.tscn ;
- proxies d'ennemis ;
- arène ;
- VFX.

### 12.2 Export

Format principal : glTF / GLB.

Conventions :
- unités cohérentes ;
- transforms appliquées ;
- origine au pied pour les personnages ;
- axes compatibles Godot ;
- meshes nommés proprement ;
- armature unique par personnage ;
- animations nommées de manière stable ;
- pas de dépendances externes non nécessaires.

### 12.3 Automatisation

Les scripts Blender doivent pouvoir être appelés en headless lorsque Blender est installé.

Objectif de commande :
`blender --background --python tools/blender/build_all.py`

Le pipeline doit pouvoir :
1. créer ou charger les scènes de production ;
2. appliquer les matériaux communs ;
3. générer certains props simples procéduralement ;
4. vérifier échelle, origine et naming ;
5. exporter les `.glb` ;
6. produire un rapport de validation.

Le pipeline ne doit pas prétendre générer automatiquement un héros haut de gamme uniquement à partir de primitives. Les scripts automatisent la préparation, la cohérence, les matériaux, l'export et les éléments procéduraux ; les meshes complexes peuvent nécessiter une source 3D générée ou sculptée.

## 13. Vertical slice obligatoire

Avant conversion massive, valider :
- héros 3D ;
- Encrier rampant ;
- projectile principal ;
- obstacle ;
- arène Atelier verdoyant ;
- caméra ;
- éclairage ;
- ombres ;
- VFX d'impact ;
- synchronisation 2D→3D ;
- performance mobile de base.

Une fois cette tranche validée, le même système est étendu au reste du bestiaire.

## 14. Performance mobile

Le jeu cible Android portrait.

Principes :
- géométrie raisonnable ;
- textures atlasées lorsque pertinent ;
- matériaux partagés ;
- nombre de lumières dynamiques limité ;
- particules plafonnées ;
- ombres désactivables ou réglables ;
- LOD uniquement si réellement utile ;
- éviter les shaders complexes et dépendances coûteuses ;
- profil de qualité mobile centralisé.

Le rendu doit rester élégant à qualité réduite.

## 15. Compatibilité avec le gameplay existant

La migration doit préserver :
- mouvement ;
- ciblage ;
- auto-tir ;
- collisions ;
- IA ;
- logique de salle ;
- progression ;
- tests headless autant que possible.

Les scripts de gameplay ne doivent pas dépendre de Blender, des meshes ou du rendu 3D pour fonctionner.

Le rendu 3D doit pouvoir être désactivé ou remplacé par un fallback minimal lors des tests headless.

## 16. Plan d'implémentation conceptuel

Ordre :
1. créer le pont monde 2D / monde 3D ;
2. créer la caméra et l'environnement 3D ;
3. créer le proxy héros ;
4. créer le proxy ennemi ;
5. créer le proxy projectile ;
6. mettre en place les matériaux communs ;
7. créer le pipeline Blender ;
8. produire la vertical slice ;
9. vérifier gameplay et tests ;
10. étendre aux autres ennemis et boss ;
11. remplacer progressivement les anciens dessins 2D ;
12. faire un pass de sobriété et performance mobile.

## 17. Critères de réussite

La migration est considérée réussie lorsque :
- la boucle de jeu reste fonctionnelle ;
- les collisions et le ciblage restent cohérents ;
- héros, ennemi, projectile et arène sont réellement rendus en 3D ;
- le rendu est plus sobre que les assets actuels ;
- les éléments importants sont immédiatement lisibles sur téléphone ;
- les VFX ne masquent pas les télégraphes ;
- le pipeline Blender peut exporter de manière reproductible les assets vers Godot ;
- les tests headless peuvent toujours fonctionner sans dépendre d'un rendu graphique complet ;
- le projet dispose d'une structure permettant de convertir progressivement tout le contenu restant.

## 18. Hors périmètre immédiat

Ne pas inclure dans cette migration initiale :
- réécriture complète du gameplay en CharacterBody3D ;
- caméra libre ;
- navigation 3D complète ;
- physique verticale ;
- photoréalisme ;
- refonte complète de toute l'UI ;
- ajout de contenu gameplay sans rapport avec la migration visuelle.
