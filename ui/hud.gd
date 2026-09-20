extends Control

signal pause_demandee
signal sort_actif_demande
signal ultime_demande

var _secousse := 0.0
var _flash_degats := 0.0
var _bouton_pause: Button
var _bouton_actif: Button
var _bouton_ultime: Button
var _recharge_active := 0.0
var _charge_ultime := 0.0
var _ultimes_utilises := 0
var _fond_jauge: StyleBoxTexture
var _plein_jauge: StyleBoxTexture
var _panneau_hud: StyleBoxFlat
var _panneau_presse: StyleBoxFlat
var _panneau_indisponible: StyleBoxFlat
var _icone_gouttes: TextureRect
var _icone_augments: TextureRect
var _icone_boss: TextureRect
var _icone_active: TextureRect
var _icone_ultime: TextureRect
var _decalage_secousse := Vector2.ZERO

func _ready() -> void:
	HabillagePeint.appliquer(self)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_preset(Control.PRESET_FULL_RECT)
	Jeu.inventaire_change.connect(rafraichir)
	Jeu.experience_run_change.connect(rafraichir)
	ReglagesJoueur.maitrise_changee.connect(rafraichir)
	_bouton_pause = _creer_zone(func() -> void: pause_demandee.emit())
	_bouton_actif = _creer_zone(func() -> void: sort_actif_demande.emit())
	_bouton_ultime = _creer_zone(func() -> void: ultime_demande.emit())
	# Les images ont leur detourage propre sans toucher au rendu natif des lettres du HUD.
	_icone_gouttes = _creer_illustration("fiole")
	_icone_augments = _creer_illustration("grimoire")
	_icone_boss = _creer_illustration("couronne")
	_icone_active = _creer_illustration("grimoire")
	_icone_ultime = _creer_illustration("astrolabe")
	_bouton_pause.tooltip_text = "Pause"
	_fond_jauge = _style_jauge("jauge_fond")
	_plein_jauge = _style_jauge("jauge_plein")
	_panneau_hud = _style_compact(Color("111a32"), Color("9c8857"))
	_panneau_presse = _style_compact(Color("223453"), Color("f0d7a2"))
	_panneau_indisponible = _style_compact(Color("111a32"), Color("636b80"))
	_replacer_boutons()
	get_viewport().size_changed.connect(_replacer_boutons)

func _creer_zone(action: Callable) -> Button:
	var bouton := StyleInterface.zone_tactile(action)
	add_child(bouton)
	return bouton

func _creer_illustration(nom: String) -> TextureRect:
	var illustration := StyleAzur.illustration(nom, 0)
	illustration.visible = false
	add_child(illustration)
	return illustration

func _replacer_boutons() -> void:
	var taille := get_viewport_rect().size
	var haut := Ecran.marge_haute() + 12.0
	_bouton_pause.position = Vector2(18, haut)
	_bouton_pause.size = Vector2(124, 124)
	_bouton_actif.position = Vector2(taille.x - 164, taille.y - Ecran.marge_basse() - 365)
	_bouton_actif.size = Vector2(146, 146)
	_bouton_ultime.position = Vector2(taille.x - 164, taille.y - Ecran.marge_basse() - 577)
	_bouton_ultime.size = Vector2(146, 146)
	_replacer_illustrations()

func _replacer_illustrations() -> void:
	var taille := get_viewport_rect().size
	var haut := Ecran.marge_haute() + 12.0
	var points := Vector2(taille.x - 192, haut) + _decalage_secousse
	_placer_illustration(_icone_gouttes, Rect2(points + Vector2(12, 10), Vector2(48, 48)))
	_placer_illustration(_icone_augments, Rect2(points + Vector2(12, 66), Vector2(48, 48)))
	var boss := get_tree().get_first_node_in_group("boss")
	_icone_boss.visible = boss != null and is_instance_valid(boss) and float(boss.pv_max) > 0.0
	if _icone_boss.visible:
		_placer_illustration(_icone_boss, Rect2(Vector2(144, haut + 174) + _decalage_secousse, Vector2(52, 52)))
	_replacer_icone_sort(_icone_active, _bouton_actif, ReglagesJoueur.sort_actif_effectif())
	_replacer_icone_sort(_icone_ultime, _bouton_ultime, ReglagesJoueur.ultime_effectif())

func _placer_illustration(illustration: TextureRect, rectangle: Rect2) -> void:
	illustration.position = rectangle.position
	illustration.size = rectangle.size
	illustration.visible = true

func _replacer_icone_sort(illustration: TextureRect, bouton: Button, id: String) -> void:
	illustration.visible = bouton.visible and not id.is_empty()
	if not illustration.visible:
		return
	illustration.texture = StyleAzur.glyphe(id)
	_placer_illustration(illustration, Rect2(bouton.position + Vector2((bouton.size.x - 70.0) * 0.5, 31), Vector2(70, 70)))
	illustration.modulate = Color("afb8cd") if bouton.disabled else Color.WHITE

func rafraichir_sorts(recharge_active: float, charge_ultime: float, utilisations := 0) -> void:
	_ultimes_utilises = utilisations
	_recharge_active = maxf(0.0, recharge_active)
	_charge_ultime = maxf(0.0, charge_ultime)
	var actif := ReglagesJoueur.sort_actif_effectif()
	var ultime := ReglagesJoueur.ultime_effectif()
	var donnees_actif: Dictionary = Sorts.ACTIFS.get(actif, {})
	var donnees_ultime: Dictionary = Sorts.ULTIMES.get(ultime, {})
	_bouton_actif.visible = Sorts.ACTIFS.has(actif)
	_bouton_ultime.visible = Sorts.ULTIMES.has(ultime)
	_bouton_actif.disabled = _recharge_active > 0.0
	_bouton_actif.tooltip_text = "Sort actif · %s" % str(donnees_actif.get("nom", ""))
	if _bouton_ultime.visible:
		_bouton_ultime.disabled = _charge_ultime > 0.0
		_bouton_ultime.tooltip_text = "Sort ultime · %s" % str(donnees_ultime.get("nom", ""))
	_replacer_illustrations()
	queue_redraw()

func rafraichir() -> void:
	queue_redraw()

func secouer() -> void:
	if ReglagesJoueur.secousses_ecran:
		_secousse = 1.0

func impact_degats() -> void:
	_flash_degats = 1.0
	secouer()

func _process(delta: float) -> void:
	_secousse = maxf(0.0, _secousse - delta * 3.0)
	_flash_degats = maxf(0.0, _flash_degats - delta * 7.5)
	_decalage_secousse = Vector2(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0)) * _secousse * 4.0
	_replacer_illustrations()
	queue_redraw()

func _draw() -> void:
	var police := Polices.CORPS
	var taille := get_viewport_rect().size
	var haut := Ecran.marge_haute() + 12.0
	var tremble := _decalage_secousse
	_dessiner_flash(taille)
	_dessiner_pause(police, Rect2(_bouton_pause.position + tremble, _bouton_pause.size))
	_dessiner_progression(police, Rect2(Vector2(150, haut) + tremble, Vector2(taille.x - 354, 126)))
	_dessiner_points(police, Rect2(Vector2(taille.x - 192, haut) + tremble, Vector2(176, 126)))
	var boss := get_tree().get_first_node_in_group("boss")
	var boss_visible := boss != null and is_instance_valid(boss) and float(boss.pv_max) > 0.0
	if boss_visible:
		_dessiner_barre_boss(boss, Polices.TITRE, Rect2(Vector2(130, haut + 154) + tremble, Vector2(taille.x - 260, 92)))
	_dessiner_bouton_sort(police, _bouton_actif, false)
	_dessiner_bouton_sort(police, _bouton_ultime, true)

func _dessiner_flash(taille: Vector2) -> void:
	if _flash_degats <= 0.0:
		return
	var alpha := _flash_degats * (0.10 if ReglagesJoueur.effets_reduits else 0.17)
	var e := 34.0 + _flash_degats * 22.0
	draw_rect(Rect2(0, 0, taille.x, e), Color(Palette.DANGER, alpha))
	draw_rect(Rect2(0, taille.y - e, taille.x, e), Color(Palette.DANGER, alpha))
	draw_rect(Rect2(0, 0, e, taille.y), Color(Palette.DANGER, alpha))
	draw_rect(Rect2(taille.x - e, 0, e, taille.y), Color(Palette.DANGER, alpha))

func _dessiner_pause(police: Font, rect: Rect2) -> void:
	draw_style_box(_panneau_presse if _bouton_pause.button_pressed else _panneau_hud, rect)
	for x in [45.0, 69.0]:
		draw_rect(Rect2(rect.position + Vector2(x, 28), Vector2(10, 35)), StyleAzur.TEXTE)
	_draw_centre(police, Vector2(rect.position.x, rect.end.y - 26), rect.size.x, "PAUSE", 18, StyleAzur.TEXTE)

func _dessiner_progression(police: Font, rect: Rect2) -> void:
	draw_style_box(_panneau_hud, rect)
	var salle := "MINE %02d:%02d" % [ceili(Jeu.temps_mine_restant) / 60, ceili(Jeu.temps_mine_restant) % 60] if Jeu.mode_run == "mine" else "SALLE %02d / %02d" % [Jeu.salle_courante, Jeu.salles_du_chapitre()]
	_draw_centre(Polices.TITRE, rect.position + Vector2(20, 39), rect.size.x - 40, salle, 30, StyleAzur.TEXTE)
	_draw_centre(police, rect.position + Vector2(20, 69), rect.size.x - 40, "NIVEAU %d" % Jeu.niveau_run, 20, StyleAzur.ATTENUE)
	var xp := Jeu.experience_vers_prochain_niveau()
	var barre := Rect2(rect.position + Vector2(20, 87), Vector2(rect.size.x - 40, 18))
	_barre_premium(barre, clampf(float(xp["actuelle"]) / maxf(1.0, float(xp["requise"])), 0.0, 1.0), StyleAzur.MAGIE)

func _dessiner_points(police: Font, rect: Rect2) -> void:
	draw_style_box(_panneau_hud, rect)
	_draw_centre(police, rect.position + Vector2(60, 45), rect.size.x - 74, ReglagesJoueur.gouttes_affichees(), 22, StyleAzur.TEXTE)
	_draw_centre(police, rect.position + Vector2(60, 99), rect.size.x - 74, str(Jeu.inventaire.size()), 22, StyleAzur.TEXTE)

func _dessiner_barre_boss(boss: Node, police: Font, rect: Rect2) -> void:
	var ratio := clampf(float(boss.pv) / maxf(1.0, float(boss.pv_max)), 0.0, 1.0)
	var nom := str(boss.donnees.get("nom", "BOSS")).to_upper()
	draw_style_box(_panneau_hud, rect)
	_draw_centre(police, rect.position + Vector2(82, 34), rect.size.x - 102, nom, 26, StyleAzur.TEXTE)
	var barre := Rect2(rect.position + Vector2(82, 53), Vector2(rect.size.x - 102, 18))
	_barre_premium(barre, ratio, Palette.DANGER.lerp(StyleAzur.CUIVRE, ratio))

func _dessiner_bouton_sort(police: Font, bouton: Button, ultime: bool) -> void:
	if bouton == null or not bouton.visible:
		return
	var rect := Rect2(bouton.position, bouton.size)
	var accent := StyleAzur.MAGIE if ultime else StyleAzur.CUIVRE
	var panneau := _panneau_indisponible if bouton.disabled else _panneau_hud
	draw_style_box(_panneau_presse if bouton.button_pressed else panneau, rect)
	var id := ReglagesJoueur.ultime_effectif() if ultime else ReglagesJoueur.sort_actif_effectif()
	var ratio := 0.0
	var texte := "PRÊT"
	var restant := _charge_ultime if ultime else _recharge_active
	var recharge_max := ReglagesJoueur.recharge_sort(id, Jeu.mods())
	ratio = 1.0 - clampf(restant / maxf(0.01, recharge_max), 0.0, 1.0)
	texte = "%d s" % ceili(restant) if restant > 0.0 else "PRÊT"

	var jauge := Rect2(rect.position + Vector2(18, 108), Vector2(rect.size.x - 36, 10))
	_barre_premium(jauge, ratio, accent)
	_draw_centre(police, rect.position + Vector2(10, 23), rect.size.x - 20, "ULTIME" if ultime else "SORT", 17, StyleAzur.TEXTE)
	_draw_centre(police, Vector2(rect.position.x + 10, rect.end.y - 9), rect.size.x - 20, texte, 18, StyleAzur.TEXTE)
	# Un raccourci invisible n'est jamais utilise : l'icone rappelle le geste
	# choisi dans les reglages tant qu'il en existe un.
	if not ultime and RaccourciTactile.tapes_requises(ReglagesJoueur.raccourci_sort) > 0:
		_draw_centre(police, Vector2(rect.position.x - 20, rect.end.y + 26), rect.size.x + 40,
			"TAPE ×%d" % RaccourciTactile.tapes_requises(ReglagesJoueur.raccourci_sort),
			14, StyleAzur.ATTENUE)

func _barre_premium(rect: Rect2, ratio: float, couleur: Color) -> void:
	draw_style_box(_fond_jauge, rect)
	var pleine := rect.grow(-2.0)
	pleine.size.x *= clampf(ratio, 0.0, 1.0)
	if pleine.size.x > 1.0:
		_plein_jauge.modulate_color = couleur
		draw_style_box(_plein_jauge, pleine)

func _style_jauge(nom: String) -> StyleBoxTexture:
	var style := StyleBoxTexture.new()
	style.texture = StyleAzur.texture_interface(nom)
	for cote in [SIDE_LEFT, SIDE_RIGHT, SIDE_TOP, SIDE_BOTTOM]:
		style.set_texture_margin(cote, 6.0 if cote in [SIDE_LEFT, SIDE_RIGHT] else 2.0)
	return style

func _style_compact(fond: Color, bord: Color) -> StyleBoxFlat:
	# Les panneaux de combat gardent l'espace disponible pour les valeurs et les jauges.
	var style := StyleBoxFlat.new()
	style.bg_color = fond
	style.border_color = bord
	style.set_border_width_all(2)
	style.set_corner_radius_all(12)
	return style

func _draw_centre(police: Font, position: Vector2, largeur: float, texte: String,
		taille_police: int, couleur: Color) -> void:
	var largeur_texte := police.get_string_size(texte, HORIZONTAL_ALIGNMENT_LEFT, -1, taille_police).x
	var taille_adaptee := mini(taille_police, maxi(12, floori(taille_police * largeur / maxf(1.0, largeur_texte))))
	draw_string_outline(police, position, texte, HORIZONTAL_ALIGNMENT_CENTER, largeur, taille_adaptee, 2, Color(StyleAzur.FOND, 0.95))
	draw_string(police, position, texte, HORIZONTAL_ALIGNMENT_CENTER, largeur, taille_adaptee, couleur)
