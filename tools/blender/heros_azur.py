"""Point d'entree reproductible du mage manga approuve."""
import bpy, json, sys
from pathlib import Path
sys.path.insert(0,str(Path(__file__).resolve().parent))
import build_all as b
from mage_manga import construire, creer_squelette, animer

if __name__=='__main__':
    bpy.ops.wm.read_factory_settings(use_empty=True)
    bpy.context.preferences.filepaths.save_version=0
    bpy.context.preferences.filepaths.file_preview_type='NONE'
    b.materiaux()
    b.exporter('heros','characters',construire,True)
    (b.SORTIE/'heros_azur_rapport.json').write_text(json.dumps(b.RAPPORT,indent=2),encoding='utf-8')
