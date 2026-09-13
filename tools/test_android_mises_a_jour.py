"""Tests sans Godot, telephone, reseau ni acces au profil du joueur."""
import argparse
import configparser
from pathlib import Path
import tempfile
import unittest
from unittest.mock import patch

import android_mises_a_jour as android

EXEMPLE = '''[preset.0]
name="Android"
platform="Android"
runnable=true
export_path="build/alambic.apk"
exclude_filter="tests/*, tools/*"

[preset.0.options]
gradle_build/use_gradle_build=false
gradle_build/export_format=0
version/code=20260814
version/name="0.3.20260814"
package/unique_name="com.giovanni.alambic"
package/signed=true
launcher_icons/main_192x192="res://icone.png"
'''


class Configuration(unittest.TestCase):
    def test_configuration_historique(self):
        self.assertEqual(android.verifier_configuration(EXEMPLE), 20260814)

    def test_identite_changee_refusee(self):
        with self.assertRaises(ValueError):
            android.verifier_configuration(EXEMPLE.replace('com.giovanni.alambic', 'com.giovanni.alambik'))

    def test_export_non_signe_refuse(self):
        with self.assertRaises(ValueError):
            android.verifier_configuration(EXEMPLE.replace('package/signed=true', 'package/signed=false'))

    def test_code_limite(self):
        with self.assertRaises(ValueError):
            android.prochaine_version(EXEMPLE.replace('20260814', str(android.LIMITE_CODE)))

    def test_code_zero_refuse(self):
        with self.assertRaises(ValueError):
            android.verifier_configuration(EXEMPLE.replace('version/code=20260814', 'version/code=0'))

    def test_versions_synchronisees(self):
        texte, code, nom = android.prochaine_version(android.preparer_play(EXEMPLE), '0.4.0')
        self.assertEqual(code, 20260815)
        self.assertEqual(nom, '0.4.0')
        self.assertEqual(texte.count('version/code=20260815'), 2)
        self.assertEqual(texte.count('version/name="0.4.0"'), 2)
        self.assertEqual(android.verifier_configuration(texte), code)

    def test_code_toujours_croissant(self):
        texte, code, _ = android.prochaine_version(EXEMPLE)
        texte, suivant, nom = android.prochaine_version(texte)
        self.assertEqual(suivant, code + 1)
        self.assertEqual(nom.count('+'), 1)

    def test_nom_invalide_refuse(self):
        for nom in ('', '  ', 'test\nversion/code=1', 'x' * 101):
            with self.subTest(nom=nom), self.assertRaises(ValueError):
                android.prochaine_version(EXEMPLE, nom)

    def test_play_idempotent(self):
        texte = android.preparer_play(EXEMPLE)
        self.assertEqual(android.preparer_play(texte), texte)
        cfg = android.analyser(texte)
        self.assertEqual(android.valeur(cfg, 'preset.1.options', 'gradle_build/export_format'), '1')
        self.assertEqual(android.valeur(cfg, 'preset.1', 'runnable'), 'false')
        self.assertEqual(android.valeur(cfg, 'preset.0.options', 'gradle_build/export_format'), '0')

    def test_graphismes_preserves(self):
        texte, _, _ = android.prochaine_version(EXEMPLE)
        self.assertIn('launcher_icons/main_192x192="res://icone.png"', texte)
        self.assertIn('exclude_filter="tests/*, tools/*"', texte)

    def test_autre_plateforme_preservee(self):
        autre = '\n[preset.4]\nname="Windows"\nplatform="Windows Desktop"\n\n[preset.4.options]\nversion/code=10\n'
        texte = android.preparer_play(EXEMPLE + autre)
        self.assertIn('[preset.5]', texte)
        self.assertIn(autre.rstrip(), texte)

    def test_versions_divergentes_refusees(self):
        texte = android.preparer_play(EXEMPLE).replace('version/code=20260814', 'version/code=20260815', 1)
        with self.assertRaises(ValueError):
            android.verifier_configuration(texte)

    def test_faux_aab_refuse(self):
        texte = android.preparer_play(EXEMPLE)
        texte = android.remplacer(texte, 'preset.1.options', 'gradle_build/export_format', '0')
        with self.assertRaises(ValueError):
            android.verifier_configuration(texte)

    def test_cle_dupliquee_refusee(self):
        with self.assertRaises(configparser.Error):
            android.verifier_configuration(EXEMPLE + 'version/code=1\n')

    def test_ecriture_concurrente_preservee(self):
        with tempfile.TemporaryDirectory() as dossier:
            fichier = Path(dossier) / 'export.cfg'
            fichier.write_bytes(b'autre IA')
            with self.assertRaises(RuntimeError):
                android.ecrire_compare(fichier, b'ancien', 'nouveau')
            self.assertEqual(fichier.read_bytes(), b'autre IA')
            self.assertEqual(list(Path(dossier).iterdir()), [fichier])

    def test_retours_windows_preserves(self):
        with tempfile.TemporaryDirectory() as dossier:
            fichier = Path(dossier) / 'export.cfg'
            fichier.write_bytes(b'a\r\nb\r\n')
            android.ecrire_compare(fichier, fichier.read_bytes(), 'c\nd\n')
            self.assertEqual(fichier.read_bytes(), b'c\r\nd\r\n')

    def test_verrou_concurrent(self):
        with tempfile.TemporaryDirectory() as dossier:
            with android.verrou(Path(dossier)):
                with self.assertRaises(RuntimeError):
                    with android.verrou(Path(dossier)):
                        pass
            self.assertFalse((Path(dossier) / '.publication.lock').exists())

    def test_release_sans_secret_refuse(self):
        with self.assertRaises(RuntimeError):
            android.preparer_signature('play', {}, {})

    def test_mauvaise_cle_test_refusee(self):
        with tempfile.NamedTemporaryFile() as cle:
            with patch.object(android, 'certificat_cle', return_value='0' * 64):
                with self.assertRaises(RuntimeError):
                    android.preparer_signature('test', {}, {'debug_keystore': cle.name})

    def test_cle_debug_interdite_en_release(self):
        with tempfile.NamedTemporaryFile() as cle:
            env = {'GODOT_ANDROID_KEYSTORE_RELEASE_PATH': cle.name,
                   'GODOT_ANDROID_KEYSTORE_RELEASE_USER': 'publication',
                   'GODOT_ANDROID_KEYSTORE_RELEASE_PASSWORD': 'secret'}
            with patch.object(android, 'certificat_cle', return_value=android.CERTIFICAT_TEST):
                with self.assertRaises(RuntimeError):
                    android.preparer_signature('play', env, {})

    def test_installation_conserve_donnees(self):
        commandes = []
        def executer(commande, **_):
            commandes.append(commande)
            if 'devices' in commande:
                return 'List of devices attached\ntelephone\tdevice\n'
            if 'dumpsys' in commande:
                return 'versionCode=10 minSdk=24'
            return 'Success\n'
        with patch.object(android, 'examiner_apk', return_value=(android.PAQUET, 11, 'cert')), \
             patch.object(android, 'outil', return_value='adb'), \
             patch.object(android, 'executer', side_effect=executer):
            android.installer(Path('jeu.apk'), {})
        self.assertEqual(commandes[-1], ['adb', '-s', 'telephone', 'install', '-r', 'jeu.apk'])
        self.assertFalse(any(arg in ('uninstall', 'clear', '-d') for cmd in commandes for arg in cmd))

    def test_downgrade_refuse(self):
        with patch.object(android, 'examiner_apk', return_value=(android.PAQUET, 10, 'cert')), \
             patch.object(android, 'outil', return_value='adb'), \
             patch.object(android, 'executer', side_effect=['telephone\tdevice\n', 'versionCode=11']) as run:
            with self.assertRaises(RuntimeError):
                android.installer(Path('jeu.apk'), {})
            self.assertEqual(run.call_count, 2)

    def test_pas_de_telephone_pas_dinstallation(self):
        with patch.object(android, 'examiner_apk', return_value=(android.PAQUET, 10, 'cert')), \
             patch.object(android, 'outil', return_value='adb'), \
             patch.object(android, 'executer', return_value='List of devices attached\n') as run:
            with self.assertRaises(RuntimeError):
                android.installer(Path('jeu.apk'), {})
            self.assertEqual(run.call_count, 1)

    def test_installation_aab_refusee_avant_export(self):
        with self.assertRaises(ValueError):
            android.exporter(argparse.Namespace(cible='play', installer=True))


if __name__ == '__main__':
    unittest.main()
