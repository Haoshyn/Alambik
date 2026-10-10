extends Control

const ACCENTS := {
	"Offensif": Color("ff9f7a"), "Défensif": Color("6fe8c6"),
	"Utilitaire": Color("c6a6ff"), "Tous": Color("ffd88a"),
}
const CADENAS := preload("res://assets/visual/interface/cadenas.svg")

var identifiant := "vigueur"
var equipe := false
var verrouille := false
# Centre du medaillon de l'icone, en proportion de la carte.
var centre_embleme := Vector2(0.5, 0.0)
var rayon_embleme := 66.0
var _animation: Tween
var _eclat := 0.0

static func accent_pour(id: String) -> Color:
	return accent_categorie(str(Passifs.donnees(id).get("categorie", "Tous")))

static func accent_categorie(categorie: String) -> Color:
	var accent: Color = ACCENTS.get(categorie, ACCENTS["Tous"])
	return accent

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	resized.connect(queue_redraw)

func _draw() -> void:
	var accent := Color("8f93ad") if verrouille else accent_pour(identifiant)
	var centre := Vector2(size.x * centre_embleme.x, centre_embleme.y)
	# Medaillon creuse : la couleur de categorie se lit avant le texte.
	draw_circle(centre + Vector2(0, 5), rayon_embleme + 6.0, Color(0.03, 0.02, 0.1, 0.5))
	draw_circle(centre, rayon_embleme + 6.0, StyleJeu.CONTOUR)
	draw_circle(centre, rayon_embleme + 3.0, accent.darkened(0.15))
	draw_circle(centre, rayon_embleme, accent.darkened(0.72))
	draw_circle(centre, rayon_embleme * 0.82, Color(accent.darkened(0.45), 0.55 + 0.3 * _eclat))
	draw_arc(centre, rayon_embleme - 3.0, PI * 1.08, PI * 1.72, 24, Color(1, 1, 1, 0.22 + 0.2 * _eclat), 3.0, true)
	if equipe:
		draw_arc(centre, rayon_embleme + 11.0, 0.0, TAU, 64, Color(StyleAzur.VERT_VIF, 0.9), 4.0, true)
	if verrouille:
		var cote := 46.0
		var coin := centre + Vector2(rayon_embleme * 0.62, rayon_embleme * 0.5)
		draw_texture_rect(CADENAS, Rect2(coin - Vector2.ONE * cote * 0.5, Vector2.ONE * cote), false)

func illuminer(actif: bool) -> void:
	if not is_inside_tree(): return
	if is_instance_valid(_animation): _animation.kill()
	var cible := 1.0 if actif else 0.0
	if ReglagesJoueur.effets_reduits:
		_definir_eclat(cible)
		return
	_animation = create_tween()
	_animation.tween_method(_definir_eclat, _eclat, cible, 0.15)

func _definir_eclat(valeur: float) -> void:
	_eclat = valeur
	queue_redraw()
