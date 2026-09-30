extends Control

const ACCENTS := {
	"Offensif": Color("f5b8a0"), "Défensif": Color("a5e7e0"),
	"Utilitaire": Color("d6c4fa"), "Tous": Color("dbc4a0"),
}

var identifiant := "vigueur"
var equipe := false
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
	var accent := accent_pour(identifiant)
	var debut := Vector2(12, size.y - 2)
	var fin := Vector2(maxf(12, size.x - 12), size.y - 2)
	# Un filet marque l'interaction sans teinter le decor ou encadrer les textes.
	draw_line(debut, fin, Color(accent, 0.28 + 0.35 * _eclat), 1.5 + _eclat, true)
	draw_line(debut, debut + Vector2(48, 0), Color(accent, 0.65), 2.0, true)
	if equipe:
		draw_line(Vector2(2, 32), Vector2(2, size.y - 32), Color(StyleAzur.VERT_VIF, 0.8), 2.0, true)

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
