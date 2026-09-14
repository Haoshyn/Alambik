extends Node3D

var heros: Node2D
var zone: MeshInstance3D
var familier: Sprite3D
var _temps := 0.0

func _ready() -> void:
	zone = MeshInstance3D.new()
	zone.name = "ZoneAlchimique"
	var disque := PlaneMesh.new()
	var diametre := Reglages.ZONE_HEROS_RAYON * 2.0 * Pont3D.ECHELLE
	disque.size = Vector2(diametre, diametre / sin(deg_to_rad(Pont3D.INCLINAISON)))
	zone.mesh = disque
	var matiere := ShaderMaterial.new()
	matiere.shader = preload("res://shaders/zone_alchimique.gdshader")
	zone.material_override = matiere
	zone.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(zone)
	familier = Sprite3D.new()
	familier.name = "FamilierTireur"
	familier.texture = IconesArcane.texture("familier_tireur")
	familier.pixel_size = 0.0045
	familier.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	familier.shaded = false
	familier.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR
	familier.alpha_cut = SpriteBase3D.ALPHA_CUT_DISCARD
	add_child(familier)
	mettre_a_jour(0.0)

func mettre_a_jour(delta: float) -> void:
	if not is_instance_valid(heros) or heros.tir_courant == null:
		hide()
		return
	visible = heros.visible
	_temps += delta
	var drapeaux: Array[String] = heros.tir_courant.drapeaux
	zone.visible = "zone_heros" in drapeaux
	familier.visible = "familier_tireur" in drapeaux
	var suivi := heros.get_node_or_null("SuiviVisuel3D")
	var position_heros: Vector2 = suivi.position_affichee() if suivi != null else heros.global_position
	zone.position = Pont3D.vers_monde(position_heros, 0.055)
	# Le point d'emission logique reste le meme que celui du compagnon visible.
	familier.position = Pont3D.vers_monde(position_heros + Reglages.FAMILIER_DECALAGE, 0.45)
	if not ReglagesJoueur.effets_reduits: familier.position.y += sin(_temps * 3.5) * 0.045
