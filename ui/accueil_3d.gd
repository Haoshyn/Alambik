extends Control
signal campagne
signal mine
signal epreuve
signal reglages
signal jouer
signal page_demandee(index: int)

var _surface: Control
var _vue: SubViewport
var _heros: Node3D
var _gouttes: Label
var _pierres: Label
var _chapitre: Label
var _haut: Control
var _bas: Control
var _illustration: SubViewportContainer
var _temps := 0.0

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_surface = Control.new()
	_surface.size = Vector2(1024,1536)
	add_child(_surface)
	_illustration = SubViewportContainer.new()
	_illustration.stretch = true
	_illustration.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_surface.add_child(_illustration)
	_creer_scene()
	_haut = Control.new()
	_surface.add_child(_haut)
	var entete := Panel.new()
	entete.position = Vector2(20,0)
	entete.size = Vector2(984,112)
	entete.mouse_filter = Control.MOUSE_FILTER_IGNORE
	entete.add_theme_stylebox_override("panel",StyleAzur.cadre(Color("082d40e8")))
	_haut.add_child(entete)
	var titre := StyleAzur.texte("ALAMBIC",48)
	titre.position = Vector2(42,23)
	titre.size = Vector2(390,66)
	_haut.add_child(titre)
	_gouttes = _valeur(Rect2(536,30,160,52),30,_haut)
	_pierres = _valeur(Rect2(728,30,138,52),30,_haut)
	var parametres := StyleAzur.bouton("⚙",func(): reglages.emit())
	parametres.position = Vector2(888,0)
	parametres.size = Vector2(112,112)
	parametres.tooltip_text = "Paramètres"
	_haut.add_child(parametres)
	_bas = Control.new()
	_surface.add_child(_bas)
	var modes_bouton := StyleAzur.bouton("Campagne & modes", func(): campagne.emit())
	modes_bouton.position = Vector2(100, 150)
	modes_bouton.size = Vector2(824, 120)
	_bas.add_child(modes_bouton)
	var jouer_bouton := StyleAzur.bouton("JOUER", func(): jouer.emit(), true)
	jouer_bouton.position = Vector2(100, 290)
	jouer_bouton.size = Vector2(824, 150)
	_bas.add_child(jouer_bouton)
	var masque := ColorRect.new()
	masque.position = Vector2(100,14)
	masque.size = Vector2(824,119)
	masque.color = Color("082d40")
	masque.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_bas.add_child(masque)
	_chapitre = _valeur(Rect2(100,22,824,46),29,_bas)
	_chapitre.add_theme_color_override("font_color",StyleAzur.CUIVRE)
	var modes := _valeur(Rect2(100,72,824,54),28,_bas)
	modes.text = "Un nouveau voyage vous attend"
	resized.connect(_cadrer)
	_cadrer()
	rafraichir()

func _valeur(rect: Rect2, taille: int, parent: Control) -> Label:
	var fond := ColorRect.new()
	fond.color = Color("082d40")
	fond.position = rect.position
	fond.size = rect.size
	fond.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(fond)
	var texte := StyleAzur.texte("",taille)
	texte.position = rect.position
	texte.size = rect.size
	texte.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	texte.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	parent.add_child(texte)
	return texte

func _zone(rect: Rect2, action: Callable, titre: String) -> void:
	var bouton := StyleInterface.zone_tactile()
	bouton.position = rect.position
	bouton.size = rect.size
	bouton.tooltip_text = titre
	bouton.pressed.connect(action)
	_bas.add_child(bouton)

func _cadrer() -> void:
	var facteur := size.x/1024.0
	var hauteur := (size.y-Ecran.marge_basse()-StyleAzur.HAUTEUR_NAVIGATION)/facteur
	_surface.scale = Vector2.ONE*facteur
	_surface.size = Vector2(1024,hauteur)
	_surface.position = Vector2.ZERO
	_illustration.size = _surface.size
	_haut.position.y = Ecran.marge_haute()/facteur
	_bas.position.y = hauteur-490

func rafraichir() -> void:
	if _gouttes == null: return
	_gouttes.text = "● %s" % ReglagesJoueur.gouttes_affichees()
	_gouttes.add_theme_color_override("font_color",Color("f7cc79"))
	_pierres.text = "◆ %s" % ReglagesJoueur.pierres_forge
	_pierres.add_theme_color_override("font_color",StyleAzur.MAGIE)
	var mode := ReglagesJoueur.mode_run_choisi
	_chapitre.text = "CHAPITRE %d" % (ReglagesJoueur.chapitre_choisi+1) if mode == "grimoire" else ("LA MINE" if mode == "mine" else "ÉPREUVES")

func _process(delta: float) -> void:
	_vue.render_target_update_mode = SubViewport.UPDATE_ALWAYS if is_visible_in_tree() else SubViewport.UPDATE_DISABLED
	if not is_visible_in_tree(): return
	_temps += delta
	_heros.rotation.y = 0.25 + sin(_temps * 0.35) * 0.12

func _creer_scene() -> void:
	_vue = SubViewport.new()
	_vue.size = Vector2i(768, 1024)
	_vue.own_world_3d = true
	_vue.msaa_3d = Viewport.MSAA_2X
	_illustration.add_child(_vue)
	var monde := Node3D.new()
	_vue.add_child(monde)
	var ambiance := WorldEnvironment.new()
	ambiance.environment = Environment.new()
	ambiance.environment.background_mode = Environment.BG_COLOR
	ambiance.environment.background_color = Color("082d40")
	ambiance.environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	ambiance.environment.ambient_light_color = Color("b9dfe9")
	ambiance.environment.ambient_light_energy = 0.5
	monde.add_child(ambiance)
	var lumiere := DirectionalLight3D.new()
	lumiere.rotation_degrees = Vector3(-45, -35, 0)
	lumiere.light_color = Color("ffe6cf")
	lumiere.light_energy = 0.65
	monde.add_child(lumiere)
	_heros = load(Visuels3D.HEROS_MODELE).instantiate()
	monde.add_child(_heros)
	preload("res://scripts/presentation/materiaux_apprenti.gd").appliquer(_heros)
	var lecteur := _heros.find_child("AnimationPlayer", true, false) as AnimationPlayer
	if lecteur != null:
		lecteur.get_animation("repos").loop_mode = Animation.LOOP_LINEAR
		lecteur.play("repos")
	var socle := MeshInstance3D.new()
	var cylindre := CylinderMesh.new()
	cylindre.top_radius = 0.85
	cylindre.bottom_radius = 0.95
	cylindre.height = 0.12
	socle.mesh = cylindre
	socle.position.y = -0.07
	var matiere := StandardMaterial3D.new()
	matiere.albedo_color = Color("527a86")
	matiere.metallic = 0.25
	socle.material_override = matiere
	monde.add_child(socle)
	var camera := Camera3D.new()
	monde.add_child(camera)
	camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	camera.size = 3.0
	camera.position = Vector3(0, 2.1, 4.0)
	camera.look_at(Vector3(0, 0.7, 0))
