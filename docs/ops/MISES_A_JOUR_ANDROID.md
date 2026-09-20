# Mettre Alambik à jour sur Android

Outil de référence : `tools/android_mises_a_jour.py`. Exports uniquement sur demande, avec Godot 4.7.1 en mode headless. Configurer le SDK Android et Java dans les réglages Godot ou via `ANDROID_HOME` et `JAVA_HOME` ; indiquer Godot via `GODOT` ou `exporter --godot CHEMIN`.

## Exporter et installer

Depuis la racine du projet (`python3` sous Linux, `python` sous Windows) :

```sh
python3 tools/android_mises_a_jour.py verifier
python3 tools/android_mises_a_jour.py exporter --cible test
python3 tools/android_mises_a_jour.py exporter --cible test --installer
python3 tools/android_mises_a_jour.py installer build/android/alambik-test.apk
```

Choisir une seule commande d'export : `--installer` ajoute l'installation sur un téléphone autorisé. La commande `installer` utilise l'APK existant sans nouvel export. Avec plusieurs appareils, ajouter `--serie IDENTIFIANT_ADB`. Connexion et diagnostic : [MOBILE.md](MOBILE.md).

Sous Windows, `Mettre_a_jour_Android.cmd` produit également `build/android/alambik-test.apk`. Pour un transfert manuel, envoyer cet APK au téléphone et accepter sa mise à jour. Les fichiers numérotés, journaux et empreintes SHA-256 restent dans `build/android/`.

Chaque export réserve un `version/code` supérieur et synchronise les presets Android. L'outil contrôle le paquet, la version et le certificat des APK produits. L'installation utilise `adb install -r`, refuse une version égale ou antérieure et laisse Android refuser toute signature incompatible. Ne jamais contourner un refus par une désinstallation, `pm clear` ou une rétrogradation forcée : la progression est dans `user://alambic.cfg`.

## Identité et signature

- Identifiant historique à conserver : `com.giovanni.alambic`.
- Certificat de test historique, SHA-256 public : `6f752d155e248e349d71b92a52fbaee5b9368c60cda6d860ac1a6794b946ba1c`.
- Réutiliser la clé de test existante sur les autres machines. L'outil refuse une autre clé et ne crée aucune clé de remplacement.

La clé de test vient des réglages Godot, avec surcharge par `GODOT_ANDROID_KEYSTORE_DEBUG_PATH`, `GODOT_ANDROID_KEYSTORE_DEBUG_USER` et `GODOT_ANDROID_KEYSTORE_DEBUG_PASSWORD`. Garder les clés privées et mots de passe hors de Git et de `export_presets.cfg`.

## Distribution et Google Play

Les cibles `release` et `play` exigent une clé de publication distincte de la clé de test. Définir ces variables dans un environnement privé :

```text
GODOT_ANDROID_KEYSTORE_RELEASE_PATH
GODOT_ANDROID_KEYSTORE_RELEASE_USER
GODOT_ANDROID_KEYSTORE_RELEASE_PASSWORD
```

```sh
python3 tools/android_mises_a_jour.py exporter --cible release --nom 0.4.0
python3 tools/android_mises_a_jour.py exporter --cible play --nom 0.4.0
```

Sorties : `build/android/alambik-release.apk` et `build/android/alambik-play.aab`. La cible Play utilise le preset **Android Google Play** et nécessite le modèle de compilation Android dans `android/build/`, son SDK requis et l'application préparée dans Play Console. Vérifier les exigences du magasin au moment de publier. Un AAB ne s'installe pas directement avec `--installer` ; le distribuer d'abord via une piste de test Play.

L'outil refuse une publication sans clé de production et ne bascule jamais sur la clé de test. Avec Play App Signing, la clé d'envoi peut différer du certificat distribué : ne pas supposer qu'une version Play remplacera l'APK de test. Si les certificats diffèrent, préparer la migration des sauvegardes avant la transition.

`./publier.sh 0.4.0` appelle le même outil en cible `release`. `ALAMBIK_CIBLE=test` ou `ALAMBIK_CIBLE=play` change la cible ; le script lit éventuellement `~/.config/alambic/release.env`, hors du dépôt.

## Versions et concurrence

Le verrou `build/android/.publication.lock` sérialise les exports de cet outil ; il ne protège pas contre un export parallèle depuis l'éditeur. L'outil refuse aussi d'écraser une configuration modifiée entre sa lecture et son écriture. Après un arrêt brutal, retirer un verrou résiduel seulement après avoir vérifié qu'aucun export ne tourne.

Un code réservé par un export échoué reste consommé. Utiliser l'outil ou ses lanceurs pour les versions à distribuer ; un export direct depuis l'éditeur ne bénéficie pas de ces garanties. Les mises à jour doivent conserver la compatibilité des sauvegardes ou prévoir leurs migrations.
