# Mettre Alambik à jour sur Android

## Sur le PC fixe : le chemin simple

Double-cliquer sur `Mettre_a_jour_Android.cmd`, à la racine du projet.
Le fichier à envoyer au téléphone est **`build/android/alambik-test.apk`**.
Ouvrir ce nouvel APK sur le téléphone et accepter la mise à jour, sans désinstaller l'ancien jeu.
Cela fonctionne si le jeu installé utilise bien le même identifiant et le même certificat que l'APK de référence du PC ; ce n'est pas encore une vérification du téléphone lui-même.

Chaque export réserve automatiquement un `version/code` supérieur, garde la signature de test historique et vérifie le paquet, le numéro et le certificat de l'APK produit.
Une copie numérotée, son empreinte SHA-256 et un journal restent dans `build/android/`.
L'ancien `alambik.apk` à la racine n'est pas écrasé : un autre agent peut encore l'utiliser pour les graphismes.

Avec un téléphone déjà autorisé pour le débogage USB, depuis le dossier du projet :

```powershell
python tools/android_mises_a_jour.py exporter --cible test --installer
```

Pour installer l'APK déjà généré sans le reconstruire :

```powershell
python tools/android_mises_a_jour.py installer build/android/alambik-test.apk
```

Plusieurs téléphones : ajouter `--serie IDENTIFIANT_ADB` pour en choisir un explicitement.
Sans téléphone connecté, l'export reste utilisable par transfert manuel.
Le script n'effectue ni `adb uninstall`, ni `pm clear`, ni rétrogradation forcée.
Une signature incompatible arrête l'installation au lieu d'effacer le jeu.

## Ce que fait réellement la mise à jour

Android remplace le programme installé en conservant son espace de données ; la sauvegarde actuelle reste `user://alambic.cfg`.
Ce n'est pas une désinstallation suivie d'une nouvelle installation.
Cela ne garantit pas qu'une future modification incompatible du format des sauvegardes sera migrée : ces changements devront conserver des migrations testées.

Un **APK envoyé à la main se télécharge en entier**, même s'il met à jour l'application en place.
Sur **Google Play**, le magasin gère les téléchargements optimisés et, lorsque possible, les correctifs différentiels ; le volume exact n'est pas garanti.
Aucun téléchargement de code ni système de correctifs maison n'a été ajouté au jeu.
Un avertissement « une mise à jour est disponible » à l'intérieur du jeu n'est pas inclus ; Play In-App Updates est une intégration supplémentaire, distincte des mises à jour normales du magasin.

## Identité et signature à conserver

- Identifiant installé : `com.giovanni.alambic` (orthographe historique volontaire).
- Certificat de test de l'APK de référence `alambik.apk` :
  `6f752d155e248e349d71b92a52fbaee5b9368c60cda6d860ac1a6794b946ba1c` (SHA-256 public, pas une clé privée).
- Aucun nom de projet, fichier de sauvegarde, graphisme ou comportement de jeu n'est modifié par l'outil.

Ne pas créer une nouvelle clé de test sur une autre machine : réutiliser de manière privée la clé existante ; ne jamais la mettre dans Git.
Le script relit les chemins Android/Java et la clé de debug dans les réglages Godot 4.7 de l'utilisateur, avec surcharge possible par les variables d'environnement officielles Godot.
La version de Godot attendue par le projet est 4.7.1.

## Préparation Google Play

Le preset **Android Google Play** est distinct du preset de test **Android** : AAB, Gradle, même identifiant et numéros de version synchronisés.
Il ne suffit pas, à lui seul, à publier le jeu.
Avant le premier export de production, il faut installer le modèle de compilation Android depuis Godot, disposer du SDK requis par ce modèle, configurer une vraie clé de publication et préparer l'application dans Play Console.
Vérifier les exigences Play en vigueur au moment de l'envoi (API cible, déclaration des données, tests et fiche du magasin).

La clé et les mots de passe ne sont pas écrits dans `export_presets.cfg` ni dans ce guide.
Définir de manière privée ces trois variables dans l'environnement du processus :

```text
GODOT_ANDROID_KEYSTORE_RELEASE_PATH
GODOT_ANDROID_KEYSTORE_RELEASE_USER
GODOT_ANDROID_KEYSTORE_RELEASE_PASSWORD
```

Puis exécuter :

```powershell
python tools/android_mises_a_jour.py exporter --cible play --nom 0.4.0
```

Le résultat attendu est `build/android/alambik-play.aab`, à déposer dans une piste de test interne Google Play avant la production.
Sans signature de production configurée, l'outil s'arrête : **aucun basculement silencieux en signature de debug**.
Une clé d'envoi AAB et la clé qui signe les APK distribués par Play peuvent être différentes avec Play App Signing.
**L'APK de test actuel ne devient donc pas automatiquement compatible avec la première version Play** : si les certificats diffèrent, prévoir la migration/export des sauvegardes avant la transition, et ne pas supprimer la version de test pour contourner une erreur.
Après installation depuis la piste Play, les versions suivantes distribuées par cette même application bénéficient du mécanisme normal de mise à jour du magasin.

## Vérifications et concurrence

```powershell
python -m unittest discover -s tools -p test_android_mises_a_jour.py -v
python tools/android_mises_a_jour.py verifier
powershell -NoProfile -ExecutionPolicy Bypass -File tools/verifier_windows.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File tools/verifier_windows.ps1 -VingtRuns
```

L'outil vérifie les changements concurrents avant d'écrire la configuration et sérialise ses exports avec `build/android/.publication.lock`.
Ne pas exporter simultanément depuis l'éditeur ou un autre agent : le verrou protège les appels de cet outil, pas les programmes externes.
Après un arrêt brutal seulement, vérifier qu'aucun export ne tourne avant de retirer ce verrou résiduel.
Un code réservé par un export échoué n'est pas réutilisé automatiquement ; les trous dans les numéros sont normaux.
Les fichiers du chantier graphique restent hors du périmètre des modifications.

## Validation realisee le 13 septembre 2026

- APK reel genere et controle : version 0.3.20260913, code 20260815, 140,9 Mo, certificat identique au fichier de reference.
- Outil Android : 24 tests passes ; lanceur Windows et syntaxe publier.sh verifies.
- Jeu : 35 suites, 15 120 assertions, aucun echec ; selftest compile et donnees coherentes.
- Simulations : 20 runs termines sans blocage ni erreur de script ; ces runs ne sont pas des victoires, le bot meurt entre les salles 3 et 7.
- Des messages de ressources non liberees apparaissent a la fermeture du selftest ; ils restent visibles dans build/android/verification-jeu.log et ne sont pas corriges par ce chantier.
- Aucun telephone connecte : mise a jour et conservation effective de la progression non testees sur appareil.
- Cle de production et modele Gradle non configures : preset Play prepare, aucun AAB de production genere ni publication effectuee.

Le script historique publier.sh utilise maintenant le meme outil, en release par defaut sans repli debug ; ALAMBIK_CIBLE=test rend le mode test explicite et ALAMBIK_CIBLE=play demande un AAB.
Les sorties sont desormais dans build/android/, pas dist/.
Pour beneficier du versionnement automatique, utiliser ce script ou Mettre_a_jour_Android.cmd plutot qu un export direct depuis l editeur.

## Sources officielles consultées le 13 septembre 2026

- Versions Android : https://developer.android.com/studio/publish/versioning
- Signatures et Play App Signing : https://developer.android.com/studio/publish/app-signing
- APK/AAB et variables de signature Godot : https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_android.html
- Android App Bundles : https://developer.android.com/guide/app-bundle
- Correctifs différentiels Google Play : https://android-developers.googleblog.com/2016/12/saving-data-reducing-the-size-of-app-updates-by-65-percent.html
- Installation ADB : https://developer.android.com/tools/adb
- Proposition de mise à jour dans le jeu (non intégrée) : https://developer.android.com/guide/playcore/in-app-updates
