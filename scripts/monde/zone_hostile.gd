extends Node2D

var profil: Dictionary
var origine := Vector2.ZERO
var degats := 0.0
var _age := 0.0
var _prochain_impact := 0.0
var _declenchee := false

func _ready() -> void:
	add_to_group("zones_hostiles")
	z_index = 1
	_prochain_impact = float(profil["delai"])

func _physics_process(delta: float) -> void:
	_age += delta
	var delai := float(profil["delai"])
	var duree := float(profil["duree"])
	if _age >= _prochain_impact and (not _declenchee or _age <= delai + duree):
		_declenchee = true
		_prochain_impact = _age + BestiaireMondes.ZONE_INTERVALLE
		for cible in get_tree().get_nodes_in_group("cibles_ennemis"):
			if is_instance_valid(cible) and cible.global_position.distance_to(global_position) <= float(profil["rayon"]) + Reglages.HEROS_RAYON:
				cible.recevoir_degats(degats * float(profil["part_degats"]))
	if _declenchee and _age >= delai + maxf(duree, BestiaireMondes.ZONE_ECLAT_DUREE):
		queue_free()
	queue_redraw()

func _draw() -> void:
	preload("res://scripts/presentation/dessin_zone_hostile.gd").dessiner(self, profil, origine - global_position, _age)
