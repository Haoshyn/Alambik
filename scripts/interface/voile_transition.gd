extends Control

const CHARGEMENT_AVENTURE := preload("res://ui/composants/chargement_aventure.gd")

var _chargement_entree: Control

func presenter_etage(livre: Dictionary, etage: int, total_etages: int, mode: String) -> void:
	var configuration := livre.duplicate()
	configuration["etage"] = etage
	configuration["total_etages"] = total_etages
	configuration["mode"] = mode
	if not is_instance_valid(_chargement_entree):
		_chargement_entree = CHARGEMENT_AVENTURE.new()
		_chargement_entree.name = "ChargementEtage"
		_chargement_entree.configurer(configuration)
		add_child(_chargement_entree)
	else:
		_chargement_entree.configurer(configuration)
	_chargement_entree.show()

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	process_mode = Node.PROCESS_MODE_ALWAYS
