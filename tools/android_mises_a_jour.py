#!/usr/bin/env python3
"""Exports Android versionnes : jamais de desinstallation ni de signature implicite."""
from __future__ import annotations

import argparse
import base64
import configparser
from contextlib import contextmanager
from datetime import datetime
import hashlib
import json
import os
from pathlib import Path
import re
import shutil
import subprocess
import sys
import tempfile

RACINE = Path(__file__).resolve().parents[1]
PAQUET = "com.giovanni.alambic"  # Identite historique : ne pas renommer avec le jeu.
CERTIFICAT_TEST = "6f752d155e248e349d71b92a52fbaee5b9368c60cda6d860ac1a6794b946ba1c"
PRESET_PLAY = "Android Google Play"
LIMITE_CODE = 2_100_000_000


def analyser(texte: str) -> configparser.ConfigParser:
    cfg = configparser.ConfigParser(interpolation=None)
    cfg.optionxform = str
    cfg.read_string(texte)
    return cfg


def valeur(cfg: configparser.ConfigParser, section: str, cle: str) -> str:
    brut = cfg.get(section, cle).strip()
    return json.loads(brut) if brut.startswith('"') else brut


def presets_android(cfg: configparser.ConfigParser) -> list[str]:
    return [s for s in cfg.sections() if re.fullmatch(r"preset\.\d+", s)
            and valeur(cfg, s, "platform") == "Android"]


def verifier_configuration(texte: str) -> int:
    cfg = analyser(texte)
    sections = presets_android(cfg)
    if not sections or sum(valeur(cfg, s, "name") == "Android" for s in sections) != 1:
        raise ValueError("Le preset Android historique doit exister exactement une fois.")
    codes, noms = set(), set()
    for section in sections:
        options = section + ".options"
        if valeur(cfg, section, "name") == "Android" and valeur(cfg, section, "export_path") != "Alambic.apk":
            raise ValueError("Le preset Android doit exporter Alambic.apk a la racine.")
        if valeur(cfg, options, "package/unique_name") != PAQUET:
            raise ValueError("Identifiant Android modifie : mise a jour incompatible.")
        if valeur(cfg, options, "package/signed") != "true":
            raise ValueError("La signature Android doit rester active.")
        code = int(valeur(cfg, options, "version/code"))
        if not 1 <= code <= LIMITE_CODE:
            raise ValueError("version/code hors limites Google Play.")
        codes.add(code)
        noms.add(valeur(cfg, options, "version/name"))
        if valeur(cfg, section, "name") == PRESET_PLAY:
            if (valeur(cfg, options, "gradle_build/use_gradle_build") != "true"
                    or valeur(cfg, options, "gradle_build/export_format") != "1"):
                raise ValueError("Le preset Google Play doit produire un AAB via Gradle.")
    if len(codes) != 1 or len(noms) != 1:
        raise ValueError("Les versions des presets Android doivent rester synchronisees.")
    return next(iter(codes))


def remplacer(texte: str, section: str, cle: str, contenu: str) -> str:
    motif = re.compile(r"(?ms)(^\[" + re.escape(section) + r"\][^\S\n]*\n)(.*?)(?=^\[|\Z)")
    trouve = motif.search(texte)
    if trouve is None:
        raise ValueError(f"Section absente : {section}")
    corps, nombre = re.subn(r"(?m)^" + re.escape(cle) + r"=[^\r\n]*",
                           lambda _: cle + "=" + contenu, trouve[2])
    if nombre != 1:
        raise ValueError(f"Cle absente ou ambigue : {section}/{cle}")
    return texte[:trouve.start(2)] + corps + texte[trouve.end(2):]


def preparer_play(texte: str) -> str:
    verifier_configuration(texte)
    cfg = analyser(texte)
    if any(valeur(cfg, s, "name") == PRESET_PLAY for s in presets_android(cfg)):
        return texte
    source = next(s for s in presets_android(cfg) if valeur(cfg, s, "name") == "Android")
    numero = max(int(s.split(".")[1]) for s in cfg.sections()
                 if re.fullmatch(r"preset\.\d+", s)) + 1
    cible = f"preset.{numero}"
    blocs = []
    for section in (source, source + ".options"):
        bloc = re.search(r"(?ms)^\[" + re.escape(section) + r"\][^\S\n]*\n.*?(?=^\[|\Z)", texte)
        if bloc is None:
            raise ValueError("Preset source incomplet.")
        blocs.append(bloc[0].replace("[" + section + "]", "[" + section.replace(source, cible) + "]", 1).rstrip())
    ajout = "\n\n".join(blocs) + "\n"
    for section, cle, contenu in [
        (cible, "name", json.dumps(PRESET_PLAY)), (cible, "runnable", "false"),
        (cible, "export_path", '"build/android/alambik-play.aab"'),
        (cible + ".options", "gradle_build/use_gradle_build", "true"),
        (cible + ".options", "gradle_build/export_format", "1"),
    ]:
        ajout = remplacer(ajout, section, cle, contenu)
    resultat = texte.rstrip() + "\n\n" + ajout
    verifier_configuration(resultat)
    return resultat


def prochaine_version(texte: str, nom: str | None = None) -> tuple[str, int, str]:
    code = verifier_configuration(texte) + 1
    if code > LIMITE_CODE:
        raise ValueError("Limite version/code atteinte.")
    cfg = analyser(texte)
    sections = presets_android(cfg)
    if nom is None:
        ancien = valeur(cfg, sections[0] + ".options", "version/name").split("+", 1)[0]
        nom = ancien + "+" + str(code)
    if not nom.strip() or any(ord(c) < 32 for c in nom) or len(nom) > 100:
        raise ValueError("Nom de version vide, trop long ou contenant des caracteres de controle.")
    for section in sections:
        texte = remplacer(texte, section + ".options", "version/code", str(code))
        texte = remplacer(texte, section + ".options", "version/name", json.dumps(nom, ensure_ascii=False))
    verifier_configuration(texte)
    return texte, code, nom


def ecrire_compare(fichier: Path, original: bytes, texte: str) -> None:
    # Ne jamais restaurer une ancienne copie complete : une autre IA peut travailler.
    nouveau = texte.replace("\r\n", "\n")
    if b"\r\n" in original:
        nouveau = nouveau.replace("\n", "\r\n")
    temporaire = None
    try:
        with tempfile.NamedTemporaryFile(dir=fichier.parent, delete=False) as flux:
            temporaire = Path(flux.name)
            flux.write(nouveau.encode("utf-8"))
            flux.flush()
            os.fsync(flux.fileno())
        if fichier.read_bytes() != original:
            raise RuntimeError("Configuration modifiee entre-temps : aucune ecriture effectuee.")
        os.replace(temporaire, fichier)
    finally:
        if temporaire and temporaire.exists():
            temporaire.unlink()


@contextmanager
def verrou(dossier: Path):
    dossier.mkdir(parents=True, exist_ok=True)
    fichier = dossier / ".publication.lock"
    try:
        fd = os.open(fichier, os.O_CREAT | os.O_EXCL | os.O_WRONLY, 0o600)
    except FileExistsError as exc:
        raise RuntimeError("Un export Android est deja verrouille ; ne pas lancer deux publications.") from exc
    try:
        with os.fdopen(fd, "w") as flux:
            flux.write(str(os.getpid()))
        yield
    finally:
        fichier.unlink(missing_ok=True)


def executer(commande: list[str], *, env: dict[str, str] | None = None,
             delai: int = 60, journal: Path | None = None) -> str:
    options = {"creationflags": subprocess.CREATE_NO_WINDOW} if os.name == "nt" else {}
    resultat = subprocess.run(commande, cwd=RACINE, env=env, capture_output=True,
                              encoding="utf-8", errors="replace", timeout=delai, **options)
    sortie = resultat.stdout + resultat.stderr
    for cle, secret in (env or {}).items():
        if secret and ("PASSWORD" in cle or cle == "ALAMBIK_MOT_DE_PASSE"):
            sortie = sortie.replace(secret, "[MASQUE]")
    if journal:
        journal.write_text(sortie, encoding="utf-8")
    if resultat.returncode:
        raise RuntimeError(f"Echec de {Path(commande[0]).name} ({resultat.returncode}) :\n{sortie[-2500:]}")
    if "SCRIPT ERROR" in sortie:
        raise RuntimeError("Erreur de script Godot pendant l'export ; voir le journal.")
    return sortie


def environnement() -> tuple[dict[str, str], dict[str, str]]:
    base = (Path(os.environ.get("APPDATA", str(Path.home()))) / "Godot" if os.name == "nt"
            else Path(os.environ.get("XDG_CONFIG_HOME", str(Path.home() / ".config"))) / "godot")
    reglages: dict[str, str] = {}
    for fichier in sorted(base.glob("editor_settings-4.7*.tres")):
        texte = fichier.read_text(encoding="utf-8")
        for cle, brut in re.findall(r'(?m)^export/android/(\w+)\s*=\s*("[^\n]*")\s*$', texte):
            reglages[cle] = json.loads(brut)
    env = os.environ.copy()
    sdk = env.get("ANDROID_HOME") or env.get("ANDROID_SDK_ROOT") or reglages.get("android_sdk_path", "")
    java = env.get("JAVA_HOME") or reglages.get("java_sdk_path", "")
    if not sdk or not java or not Path(sdk).is_dir() or not Path(java).is_dir():
        raise RuntimeError("Configurer Android SDK et Java SDK dans Godot, ou ANDROID_HOME/JAVA_HOME.")
    env.update(ANDROID_HOME=sdk, ANDROID_SDK_ROOT=sdk, JAVA_HOME=java)
    return env, reglages


def outil(env: dict[str, str], nom: str) -> str:
    suffixe = ".exe" if os.name == "nt" else ""
    if nom in ("java", "keytool"):
        chemin = Path(env["JAVA_HOME"]) / "bin" / (nom + suffixe)
    elif nom == "adb":
        chemin = Path(env["ANDROID_HOME"]) / "platform-tools" / (nom + suffixe)
    else:
        repertoires = [p for p in (Path(env["ANDROID_HOME"]) / "build-tools").iterdir()
                      if p.is_dir() and re.fullmatch(r"\d+(\.\d+)*", p.name)]
        if not repertoires:
            raise RuntimeError("Android Build Tools absents.")
        base = max(repertoires, key=lambda p: tuple(map(int, p.name.split("."))))
        chemin = base / ("lib/apksigner.jar" if nom == "apksigner" else nom + suffixe)
    if not chemin.is_file():
        raise RuntimeError(f"Outil Android absent : {chemin}")
    return str(chemin)


def certificat_cle(env: dict[str, str], chemin: str, alias: str, mot_de_passe: str) -> str:
    env_cle = dict(env, ALAMBIK_MOT_DE_PASSE=mot_de_passe)
    pem = executer([outil(env, "keytool"), "-exportcert", "-rfc", "-keystore", chemin,
                   "-alias", alias, "-storepass:env", "ALAMBIK_MOT_DE_PASSE"], env=env_cle)
    bloc = re.search(r"-----BEGIN CERTIFICATE-----(.*?)-----END CERTIFICATE-----", pem, re.S)
    if bloc is None:
        raise RuntimeError("Certificat de signature illisible.")
    return hashlib.sha256(base64.b64decode(bloc[1])).hexdigest()


def preparer_signature(cible: str, env: dict[str, str], reglages: dict[str, str]) -> str:
    mode = "DEBUG" if cible == "test" else "RELEASE"
    prefixe = "GODOT_ANDROID_KEYSTORE_" + mode + "_"
    valeurs = {cle: env.get(prefixe + cle, "") for cle in ("PATH", "USER", "PASSWORD")}
    if cible == "test":
        valeurs["PATH"] = valeurs["PATH"] or reglages.get("debug_keystore", "")
        valeurs["USER"] = valeurs["USER"] or reglages.get("debug_keystore_user", "androiddebugkey")
        valeurs["PASSWORD"] = valeurs["PASSWORD"] or reglages.get("debug_keystore_pass", "android")
    if not all(valeurs.values()) or not Path(valeurs["PATH"]).is_file():
        raise RuntimeError(f"Signature {mode} absente : definir {prefixe}PATH, USER et PASSWORD ; aucune cle ne sera creee ni remplacee.")
    empreinte = certificat_cle(env, valeurs["PATH"], valeurs["USER"], valeurs["PASSWORD"])
    if cible == "test" and empreinte != CERTIFICAT_TEST:
        raise RuntimeError("Cle de test differente de l'APK historique : export bloque pour proteger les mises a jour.")
    if cible != "test" and (empreinte == CERTIFICAT_TEST or valeurs["USER"].lower() == "androiddebugkey"):
        raise RuntimeError("Une cle de debug ne peut pas servir a la publication Google Play.")
    env.update({prefixe + cle: contenu for cle, contenu in valeurs.items()})
    return empreinte


def examiner_apk(fichier: Path, env: dict[str, str]) -> tuple[str, int, str]:
    infos = executer([outil(env, "aapt"), "dump", "badging", str(fichier)], env=env)
    paquet = re.search(r"package: name='([^']+)' versionCode='(\d+)'", infos)
    signature = executer([outil(env, "java"), "-jar", outil(env, "apksigner"),
                          "verify", "--print-certs", str(fichier)], env=env)
    certificats = re.findall(r"Signer #\d+ certificate SHA-256 digest: ([0-9a-fA-F]+)", signature)
    if paquet is None or len(certificats) != 1:
        raise RuntimeError("APK illisible ou signature multiple non prise en charge.")
    return paquet[1], int(paquet[2]), certificats[0].lower()


def installer(fichier: Path, env: dict[str, str], serie: str | None = None) -> None:
    paquet, code, _ = examiner_apk(fichier, env)
    if paquet != PAQUET:
        raise RuntimeError("Cet APK n'est pas Alambik.")
    adb = [outil(env, "adb")]
    appareils = re.findall(r"(?m)^(\S+)\s+device\s*$", executer(adb + ["devices"], env=env, delai=20))
    if serie is None and len(appareils) == 1:
        serie = appareils[0]
    if serie not in appareils:
        raise RuntimeError("Brancher et autoriser un telephone USB ; avec plusieurs appareils, ajouter --serie IDENTIFIANT. L'APK reste disponible.")
    adb += ["-s", serie]
    present = executer(adb + ["shell", "dumpsys", "package", PAQUET], env=env)
    precedent = re.search(r"versionCode=(\d+)", present)
    if precedent and int(precedent[1]) >= code:
        raise RuntimeError("Version installee egale ou plus recente : aucune modification du telephone.")
    # Android controle lui-meme la signature ; ne jamais contourner un refus par uninstall/-d/pm clear.
    resultat = executer(adb + ["install", "-r", str(fichier)], env=env, delai=180)
    if not re.search(r"(?m)^Success\s*$", resultat):
        raise RuntimeError("Installation non confirmee : " + resultat[-1000:])
    print("Mise a jour installee sans desinstallation ; les donnees de l'application sont conservees.")


def trouver_godot(argument: str | None) -> str:
    candidats = [argument, os.environ.get("GODOT"),
                 str(RACINE / "tmp/outils/godot-4.7.1/Godot_v4.7.1-stable_win64_console.exe"),
                 shutil.which("godot")]
    for candidat in candidats:
        if candidat and (Path(candidat).is_file() or shutil.which(candidat)):
            return str(Path(candidat).resolve()) if Path(candidat).is_file() else str(shutil.which(candidat))
    raise RuntimeError("Godot introuvable : utiliser --godot CHEMIN ou la variable GODOT.")


def exporter(args: argparse.Namespace) -> None:
    if args.cible == "play" and args.installer:
        raise ValueError("Un AAB se transmet a Google Play, pas directement au telephone.")
    env, reglages = environnement()
    certificat = preparer_signature(args.cible, env, reglages)
    godot = trouver_godot(args.godot)
    version = executer([godot, "--headless", "--version"], env=env).strip()
    if not version.startswith("4.7.1."):
        raise RuntimeError("Godot 4.7.1 requis par ce projet.")
    if args.cible == "play" and not (RACINE / "android/build/build.gradle").is_file():
        raise RuntimeError("Installer d'abord le modele Gradle : Godot > Projet > Installer le modele de compilation Android ; voir docs/ops/MISES_A_JOUR_ANDROID.md.")
    dossier = RACINE / "build/android"
    with verrou(dossier):
        fichier = RACINE / "export_presets.cfg"
        original = fichier.read_bytes()
        texte = preparer_play(original.decode("utf-8-sig"))
        texte, code, nom = prochaine_version(texte, args.nom)
        # Le code est reserve avant l'export : un echec ne peut pas reutiliser un numero publie.
        ecrire_compare(fichier, original, texte)
        extension = "aab" if args.cible == "play" else "apk"
        destination = dossier / f"alambik-play-{code}.aab" if args.cible == "play" else RACINE / "Alambic.apk"
        temporaire = dossier / f"alambik-{args.cible}-{code}.part.{extension}"
        journal = dossier / f"export-{args.cible}-{code}.log"
        preset = PRESET_PLAY if args.cible == "play" else "Android"
        mode = "--export-debug" if args.cible == "test" else "--export-release"
        print(f"Export {args.cible} : {nom} (code {code})", flush=True)
        try:
            executer([godot, "--headless", "--path", str(RACINE), mode, preset, str(temporaire)],
                     env=env, delai=600, journal=journal)
            if not temporaire.is_file() or temporaire.stat().st_size == 0:
                raise RuntimeError("Godot n'a pas produit le fichier attendu.")
            if args.cible != "play" and examiner_apk(temporaire, env) != (PAQUET, code, certificat):
                raise RuntimeError("Identite, version ou signature incorrecte ; APK non distribue.")
            if verifier_configuration(fichier.read_text(encoding="utf-8-sig")) != code:
                raise RuntimeError("Version modifiee par un autre export ; resultat non distribue.")
            os.replace(temporaire, destination)
            stable = destination
            if args.cible == "play":
                stable = dossier / "alambik-play.aab"
                copie = stable.with_name(stable.name + ".tmp")
                shutil.copyfile(destination, copie)
                os.replace(copie, stable)
            rapport = {"paquet": PAQUET, "code": code, "nom": nom, "cible": args.cible,
                       "certificat_signature_sha256": certificat,
                       "fichier_sha256": hashlib.sha256(destination.read_bytes()).hexdigest(),
                       "fichier": destination.name, "date": datetime.now().isoformat(timespec="seconds")}
            (dossier / f"export-{args.cible}-{code}.json").write_text(
                json.dumps(rapport, indent=2) + "\n", encoding="utf-8")
            print(f"Pret : {stable}\nJournal : {journal}", flush=True)
            if args.installer:
                installer(stable, env, args.serie)
        finally:
            temporaire.unlink(missing_ok=True)
            Path(str(temporaire) + ".idsig").unlink(missing_ok=True)


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    commandes = parser.add_subparsers(dest="commande", required=True)
    commandes.add_parser("verifier", help="Controle identite et versions, sans modifier le projet")
    commandes.add_parser("preparer", help="Ajoute le preset Google Play sans changer le jeu")
    export = commandes.add_parser("exporter", help="Reserve un nouveau code et produit un APK/AAB signe")
    export.add_argument("--cible", choices=("test", "release", "play"), default="test")
    export.add_argument("--nom", help="Version visible, par exemple 0.4.0")
    export.add_argument("--godot")
    export.add_argument("--installer", action="store_true")
    export.add_argument("--serie")
    installation = commandes.add_parser("installer", help="Installe un APK deja genere, sans effacer les donnees")
    installation.add_argument("apk", type=Path)
    installation.add_argument("--serie")
    args = parser.parse_args()
    try:
        if args.commande == "exporter":
            exporter(args)
        elif args.commande == "installer":
            env, _ = environnement()
            installer(args.apk.resolve(), env, args.serie)
        else:
            fichier = RACINE / "export_presets.cfg"
            original = fichier.read_bytes()
            texte = original.decode("utf-8-sig")
            if args.commande == "preparer":
                with verrou(RACINE / "build/android"):
                    nouveau = preparer_play(texte)
                    if nouveau != texte:
                        ecrire_compare(fichier, original, nouveau)
                    texte = nouveau
            code = verifier_configuration(texte)
            print(f"Configuration valide : {PAQUET}, code {code}, {len(presets_android(analyser(texte)))} preset(s) Android.")
        return 0
    except (OSError, ValueError, RuntimeError, configparser.Error, subprocess.TimeoutExpired) as exc:
        print(f"ERREUR : {exc}\nAucune desinstallation ni suppression de sauvegarde n'a ete demandee.", file=sys.stderr)
        return 1


if __name__ == "__main__":
    raise SystemExit(main())
