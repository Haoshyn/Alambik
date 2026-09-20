# Connecter et observer Alambik sur téléphone

Pour les exports, versions, clés et installations, suivre [MISES_A_JOUR_ANDROID.md](MISES_A_JOUR_ANDROID.md). Ce guide couvre la connexion ADB et les observations sur appareil ; aucun lancement sur téléphone n'est automatique.

## Connexion

Activer les options développeur du téléphone (sept appuis sur *Numéro de build*), puis le **Débogage USB**. Brancher un câble de données et accepter l'autorisation sur le téléphone.

Commandes Linux ci-dessous : adapter le chemin au SDK Android configuré sur la machine. L'état attendu est `device`.

```sh
~/Android/Sdk/platform-tools/adb devices
```

Si le téléphone propose le débogage sans fil :

```sh
~/Android/Sdk/platform-tools/adb pair IP:PORT_ASSOCIATION
~/Android/Sdk/platform-tools/adb connect IP:PORT_CONNEXION
```

Les ports d'association et de connexion sont distincts et peuvent changer. Avec plusieurs appareils, ajouter `-s IDENTIFIANT_ADB` aux commandes ADB qui ciblent le téléphone.

## Lancement et diagnostic demandés

Après installation par l'outil de mise à jour :

```sh
~/Android/Sdk/platform-tools/adb shell monkey -p com.giovanni.alambic -c android.intent.category.LAUNCHER 1
~/Android/Sdk/platform-tools/adb logcat godot:V GodotEngine:V "*:S"
```

`./deploy.sh` est un raccourci de développement : export debug direct dans `build/alambic.apk`, installation, lancement et logs (`--sans-logs` pour arrêter après lancement). Il ne réserve pas de nouveau numéro et ne contrôle pas le certificat historique ; utiliser l'outil de mise à jour pour les APK à distribuer.

| Symptôme | Action |
|---|---|
| Aucun appareil dans `adb devices` | Vérifier câble de données, connexion et débogage USB. |
| `unauthorized` | Accepter l'autorisation sur le téléphone. |
| `INSTALL_FAILED_UPDATE_INCOMPATIBLE` | Réexporter avec la clé correspondant à l'application installée ; ne pas désinstaller ni effacer les données. |
| Version installée égale ou plus récente | Exporter une nouvelle version avec l'outil ; ne pas forcer une rétrogradation. |
| Fermeture au lancement | Lire les erreurs de `adb logcat`. |
| Export impossible | Lire le journal dans `build/android/` et vérifier SDK, Java, Godot 4.7.1 et signature. |

## Observations sur appareil

- Confort du pouce : `scripts/joystick_logique.gd`.
- Lisibilité des silhouettes et télégraphes en mouvement.
- Marges pour les encoches : `autoload/ecran.gd`.
- Performances mesurées sur le téléphone concerné.

Garder seulement les constats encore utiles dans `docs/CURRENT.md` ; réserver les mesures détaillées à une demande explicite.
