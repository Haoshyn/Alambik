#!/bin/sh
# Publication signee et versionnee ; aucun repli implicite sur une cle de test.
# ./publier.sh 0.4.0
# ALAMBIK_CIBLE=play ./publier.sh 0.4.0    AAB pour Google Play
# ALAMBIK_CIBLE=test ./publier.sh         APK de test explicite
# APK : Alambic.apk ; AAB et journaux : build/android/ ; guide : docs/ops/MISES_A_JOUR_ANDROID.md
set -eu
cd "$(dirname "$0")" || exit 1
export GODOT="${GODOT:-$HOME/Téléchargements/Godot_v4.7.1-stable_linux.x86_64}"
PYTHON="${PYTHON:-python3}"
SECRETS="$HOME/.config/alambic/release.env"
if [ -f "$SECRETS" ]; then
    set -a
    . "$SECRETS"
    set +a
fi
CIBLE="${ALAMBIK_CIBLE:-release}"
case "$CIBLE" in
    test|release|play) ;;
    *) echo "ALAMBIK_CIBLE doit valoir test, release ou play." >&2; exit 1 ;;
esac
if [ "$CIBLE" != test ]; then
    : "${GODOT_ANDROID_KEYSTORE_RELEASE_PATH:?Cle de publication absente ; aucun repli debug.}"
    : "${GODOT_ANDROID_KEYSTORE_RELEASE_USER:?Alias de publication absent.}"
    : "${GODOT_ANDROID_KEYSTORE_RELEASE_PASSWORD:?Mot de passe de publication absent.}"
fi
if [ -n "${1:-}" ]; then
    set -- --nom "$1"
else
    set --
fi
exec "$PYTHON" tools/android_mises_a_jour.py exporter --cible "$CIBLE" "$@"
