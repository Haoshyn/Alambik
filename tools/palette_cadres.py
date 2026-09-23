"""Palette des surfaces SVG de l'interface."""
from pathlib import Path
import xml.etree.ElementTree as ET


DEGRADES = {
    "bronze": ["#f2eee9", "#c8c5d2", "#8e93af", "#a6abc3"],
    "email": ["#716ba1", "#5c568a", "#423e70"],
    "profond": ["#3b4b72", "#2c3c63", "#1c2b4e"],
    "ivoire": ["#fffdf6", "#e3e6f1", "#b9c6d8"],
    "violet": ["#f2e9fa", "#c2afdf", "#887bb4"],
    "argent": ["#f0f6fa", "#b8cce1", "#7995b5"],
    "ambre": ["#f7eddb", "#d8c29c", "#9b816a"],
    "verre": ["#d9f7f2", "#8acfd5", "#4d91ac"],
}

SELECTIONS = {"case_selection", "carte_selection", "rond_selection", "saisie_focus"}
ACTIONS = {"action", "action_pressee"}
BARRES = {"navigation", "bandeau", "compteur"}


def appliquer(dossier: Path) -> None:
    ET.register_namespace("", "http://www.w3.org/2000/svg")
    for fichier in sorted(dossier.glob("*.svg")):
        degrades = {nom: couleurs[:] for nom, couleurs in DEGRADES.items()}
        if fichier.stem in SELECTIONS:
            degrades["email"] = ["#8e83b8", "#7165a0", "#504678"]
        elif fichier.stem in ACTIONS:
            degrades["email"] = ["#786ea7", "#5d548e", "#423d72"]
        elif fichier.stem in BARRES:
            degrades["profond"] = ["#38496e", "#2c3b5f", "#1e2c4f"]
        arbre = ET.parse(fichier)
        for noeud in arbre.iter():
            couleurs = degrades.get(noeud.get("id"))
            if couleurs is not None:
                for palier, couleur in zip(noeud, couleurs):
                    palier.set("stop-color", couleur)
        arbre.write(fichier, encoding="unicode")


if __name__ == "__main__":
    appliquer(Path(__file__).resolve().parents[1] / "assets/visual/interface/cadres")
