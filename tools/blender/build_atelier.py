"""Socle original de l'accueil : blender --background --python tools/blender/build_atelier.py."""
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
import bpy
import build_all as atelier


def socle():
    atelier.cone('Fondation', (0, 0, -.20), 1.65, 1.60, .25, 'pierre', 64)
    atelier.cone('Plateau', (0, 0, -.06), 1.58, 1.58, .07, 'pierre_claire', 64)
    atelier.anneau('Filet_cuivre', (0, 0, -.02), 1.50, .022, 'cuivre')
    atelier.anneau('Cercle_alchimique', (0, 0, -.015), .82, .012, 'cristal')
    for cote in [-1, 1]:
        atelier.cone('Vasque', (cote * 1.1, .65, .12), .28, .34, .25, 'pierre', 16)
        atelier.fiole((cote * 1.25, -.55, 0), .14, 'cristal', 'Fiole_atelier')


bpy.ops.wm.read_factory_settings(use_empty=True)
bpy.context.preferences.filepaths.save_version = 0
bpy.context.preferences.filepaths.file_preview_type = 'NONE'
atelier.materiaux()
atelier.exporter('socle_atelier', 'environment', socle)
print('ATELIER_EXPORT_OK', atelier.RAPPORT)
