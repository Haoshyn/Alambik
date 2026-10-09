extends Control

# HUD de combat dessine : cartouche de salle avec badge de niveau, jauges
# bombees, pastilles de ressources et barre de boss avec trace des degats.
# Tout est trace ici pour rester leger sur telephone.

signal pause_demandee

const HAUTEUR_LIGNE := 112.0
const LARGEUR_RESSOURCES := 196.0

var _secousse := 0.0
var _flash_degats := 0.0
var _bouton_pause: Button
var _icone_gouttes: TextureRect
var _icone_augments: TextureRect
var _icone_boss: TextureRect
var _decalage_secousse := Vector2.ZERO
var _temps := 0.0
var _niveau_affiche := -1
var _pulsation_niveau := 0.0
var _xp_affichee := 0.0
var _boss_retard := 1.0
var _boss_ratio_precedent := 1.0
var _boss_attente := 0.0
var _boss_suivi: Node
var _annonces: Array[Dictionary] = []
var _bandeau: _Bandeau
var _annonce: Dictionary = {}
const ANNONCE_DUREE := 1.7


func _ready() -> void:
	HabillagePeint.appliquer(self)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_preset(Control.PRESET_FULL_RECT)
	Jeu.inventaire_change.connect(rafraichir)
	Jeu.experience_run_change.connect(rafraichir)
	ReglagesJoueur.maitrise_changee.connect(rafraichir)
	_bouton_pause = StyleInterface.zone_tactile(func() -> void: pause_demandee.emit())
	add_child(_bouton_pause)
	_bouton_pause.tooltip_text = "Pause"
	_bouton_pause.button_down.connect(func() -> void: Sons.jouer("clic", -14.0))
	_icone_gouttes = _creer_illustration("fiole")
	_icone_augments = _creer_illustration("grimoire")
	_icone_boss = _creer_illustration("couronne")
	_niveau_affiche = Jeu.niveau_run
	_bandeau = _Bandeau.new()
	_bandeau.hud = self
	_bandeau.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_bandeau)
	_bandeau.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_replacer_boutons()
	get_viewport().size_changed.connect(_replacer_boutons)


func _creer_illustration(nom: String) -> TextureRect:
	var illustration := StyleAzur.illustration(nom, 0)
	illustration.visible = false
	add_child(illustration)
	return illustration


func _haut() -> float:
	return Ecran.marge_haute() + 14.0


func _rect_pause() -> Rect2:
	return Rect2(Vector2(Ecran.marge_gauche() + 16.0, _haut()), Vector2(HAUTEUR_LIGNE, HAUTEUR_LIGNE))


func _rect_ressources() -> Rect2:
	var taille := get_viewport_rect().size
	return Rect2(Vector2(taille.x - Ecran.marge_droite() - 16.0 - LARGEUR_RESSOURCES, _haut()),
		Vector2(LARGEUR_RESSOURCES, HAUTEUR_LIGNE))


func _rect_progression() -> Rect2:
	var pause := _rect_pause()
	var ressources := _rect_ressources()
	return Rect2(Vector2(pause.end.x + 14.0, _haut()), Vector2(ressources.position.x - pause.end.x - 28.0, HAUTEUR_LIGNE))


func _replacer_boutons() -> void:
	var rect := _rect_pause()
	_bouton_pause.position = rect.position - Vector2(8, 8)
	_bouton_pause.size = rect.size + Vector2(16, 16)
	_replacer_illustrations()


func _replacer_illustrations() -> void:
	var ressources := _rect_ressources()
	_placer_illustration(_icone_gouttes, Rect2(ressources.position + Vector2(-4, 0) + _decalage_secousse, Vector2(56, 56)))
	_placer_illustration(_icone_augments, Rect2(ressources.position + Vector2(-4, 58) + _decalage_secousse, Vector2(56, 56)))
	var boss := _boss()
	_icone_boss.visible = boss != null
	if _icone_boss.visible:
		var barre := _rect_boss()
		_placer_illustration(_icone_boss, Rect2(barre.position + Vector2(10, 12) + _decalage_secousse, Vector2(60, 60)))


func _placer_illustration(illustration: TextureRect, rectangle: Rect2) -> void:
	illustration.position = rectangle.position
	illustration.size = rectangle.size
	illustration.visible = true


func _boss() -> Node:
	var boss := get_tree().get_first_node_in_group("boss")
	if boss != null and is_instance_valid(boss) and float(boss.pv_max) > 0.0:
		return boss
	return null


func _heros() -> Node:
	return get_tree().get_first_node_in_group("heros")


func rafraichir() -> void:
	if Jeu.niveau_run != _niveau_affiche:
		if Jeu.niveau_run > _niveau_affiche and _niveau_affiche >= 0:
			_pulsation_niveau = 1.0
		_niveau_affiche = Jeu.niveau_run
	queue_redraw()


# Bandeau central : salle nettoyee, arrivee d'un boss. Les annonces se suivent.
func annoncer(titre: String, sous_titre := "", teinte := "ambre") -> void:
	_annonces.append({"titre": titre, "sous_titre": sous_titre, "teinte": teinte, "age": 0.0})

func secouer() -> void:
	if ReglagesJoueur.secousses_ecran:
		_secousse = 1.0


func impact_degats() -> void:
	_flash_degats = 1.0
	secouer()


func _process(delta: float) -> void:
	_temps += delta
	_secousse = maxf(0.0, _secousse - delta * 3.0)
	_flash_degats = maxf(0.0, _flash_degats - delta * 3.2)
	_pulsation_niveau = maxf(0.0, _pulsation_niveau - delta * 1.6)
	_decalage_secousse = Vector2(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0)) * _secousse * 5.0
	var xp := Jeu.experience_vers_prochain_niveau()
	var cible_xp := clampf(float(xp["actuelle"]) / maxf(1.0, float(xp["requise"])), 0.0, 1.0)
	_xp_affichee = cible_xp if cible_xp < _xp_affichee else move_toward(_xp_affichee, cible_xp, delta * 1.8)
	var boss := _boss()
	if boss != _boss_suivi:
		_boss_suivi = boss
		_boss_retard = 1.0
		_boss_ratio_precedent = 1.0
		if boss != null:
			annoncer(str(boss.donnees.get("nom", "Boss")).to_upper(), "BOSS", "rubis")
	if _annonce.is_empty() and not _annonces.is_empty():
		_annonce = _annonces.pop_front()
	if not _annonce.is_empty():
		_annonce["age"] = float(_annonce["age"]) + delta
		if float(_annonce["age"]) >= ANNONCE_DUREE:
			_annonce = {}
	_bandeau.visible = not _annonce.is_empty()
	if _bandeau.visible:
		_bandeau.modulate.a = _opacite_annonce()
		_bandeau.queue_redraw()
	if boss != null:
		var ratio := clampf(float(boss.pv) / maxf(1.0, float(boss.pv_max)), 0.0, 1.0)
		# La trace claire attend un instant avant de rejoindre la vie restante.
		if ratio < _boss_ratio_precedent - 0.0001:
			_boss_ratio_precedent = ratio
			_boss_attente = 0.45
		_boss_attente = maxf(0.0, _boss_attente - delta)
		if _boss_attente <= 0.0:
			_boss_retard = move_toward(_boss_retard, ratio, delta * 0.6)
		_boss_retard = maxf(_boss_retard, ratio)
	_replacer_illustrations()
	queue_redraw()


func _draw() -> void:
	var taille := get_viewport_rect().size
	_dessiner_vignette(taille)
	var tremble := _decalage_secousse
	_dessiner_pause(Rect2(_rect_pause().position + tremble, _rect_pause().size))
	_dessiner_progression(Rect2(_rect_progression().position + tremble, _rect_progression().size))
	_dessiner_ressources(Rect2(_rect_ressources().position + tremble, _rect_ressources().size))
	var boss := _boss()
	if boss != null:
		var rect := _rect_boss()
		_dessiner_barre_boss(boss, Rect2(rect.position + tremble, rect.size))



func _rect_boss() -> Rect2:
	var taille := get_viewport_rect().size
	var gauche := Ecran.marge_gauche() + 16.0
	return Rect2(Vector2(gauche, _haut() + HAUTEUR_LIGNE + 18.0),
		Vector2(taille.x - gauche - Ecran.marge_droite() - 16.0, 84.0))


# Vignette rouge : coup recu et vie basse. Elle reste douce en effets reduits.
func _dessiner_vignette(taille: Vector2) -> void:
	var heros := _heros()
	var danger := 0.0
	if heros != null and heros.get("stats") != null:
		var part := float(heros.stats.pv) / maxf(1.0, float(heros.stats.pv_max))
		if part < 0.35 and part > 0.0:
			var battement := 0.5 + 0.5 * sin(_temps * (7.0 if part < 0.18 else 4.5))
			danger = (1.0 - part / 0.35) * (0.35 + 0.35 * battement)
	var intensite := maxf(_flash_degats, danger)
	if intensite <= 0.01:
		return
	var alpha := intensite * (0.32 if ReglagesJoueur.effets_reduits else 0.55)
	var epaisseur := minf(taille.x, taille.y) * (0.16 + 0.08 * _flash_degats)
	var rouge := Color(Palette.DANGER.darkened(0.15), alpha)
	var vide := Color(Palette.DANGER, 0.0)
	var e := Vector2(epaisseur, epaisseur)
	var coins := [Vector2.ZERO, Vector2(taille.x, 0), taille, Vector2(0, taille.y)]
	var interieurs := [e, Vector2(taille.x - e.x, e.y), taille - e, Vector2(e.x, taille.y - e.y)]
	for i in 4:
		var j := (i + 1) % 4
		draw_polygon(PackedVector2Array([coins[i], coins[j], interieurs[j], interieurs[i]]),
			PackedColorArray([rouge, rouge, vide, vide]))


func _opacite_annonce() -> float:
	var age := float(_annonce.get("age", 0.0))
	return minf(1.0, age / 0.12) * (1.0 - smoothstep(ANNONCE_DUREE - 0.35, ANNONCE_DUREE, age))

func dessiner_annonce(surface: Control) -> void:
	if _annonce.is_empty():
		return
	var taille := surface.size
	var age := float(_annonce["age"])
	var reduit := ReglagesJoueur.effets_reduits
	var entree := clampf(age / 0.28, 0.0, 1.0)
	# Retombee elastique : le bandeau claque puis se pose.
	var echelle := 1.0 if reduit else lerpf(1.6, 1.0, 1.0 - pow(1.0 - entree, 3.0)) + 0.06 * sin(entree * PI)
	var teinte := str(_annonce["teinte"])
	var couleurs := StyleJeu.teinte(teinte)
	var centre := Vector2(taille.x * 0.5, taille.y * 0.32)
	var largeur := minf(taille.x - 70.0, 860.0)
	var sous_titre := str(_annonce["sous_titre"])
	var hauteur := 150.0 if not sous_titre.is_empty() else 120.0
	if not reduit:
		DessinJeu.rayons(surface, centre, largeur * 0.62, Color(couleurs["haut"], 0.32), age * 0.9, 16)
	surface.draw_set_transform(centre, 0.0, Vector2.ONE * echelle)
	surface.draw_style_box(StyleJeu.boite(teinte, 44.0), Rect2(-largeur * 0.5, -hauteur * 0.5, largeur, hauteur))
	var contour: Color = couleurs["contour_texte"]
	DessinJeu.texte_centre(surface, Polices.JEU_FORT, Vector2(0, -14.0 if not sous_titre.is_empty() else 4.0),
		str(_annonce["titre"]), 62, StyleJeu.TEXTE, contour, largeur - 60.0)
	if not sous_titre.is_empty():
		DessinJeu.texte_centre(surface, Polices.JEU, Vector2(0, 46), sous_titre, 28, StyleJeu.TEXTE, contour, largeur - 60.0)
	surface.draw_set_transform(Vector2.ZERO)

func _dessiner_pause(rect: Rect2) -> void:
	var appuye := _bouton_pause.button_pressed
	var boite := StyleJeu.boite("violet", rect.size.x * 0.5, "pressed" if appuye else "normal")
	draw_style_box(boite, rect)
	var centre := rect.get_center() + Vector2(0, 2 if appuye else -3)
	var barre := Vector2(13, 40)
	for cote in [-1.0, 1.0]:
		var r := Rect2(centre + Vector2(cote * 12.0 - barre.x * 0.5, -barre.y * 0.5), barre)
		draw_rect(r.grow(3.0), StyleJeu.teinte("violet")["contour_texte"])
		draw_rect(r, StyleJeu.TEXTE)


func _dessiner_progression(rect: Rect2) -> void:
	draw_style_box(StyleJeu.panneau(Color(), 30.0, 0.94), rect)
	var badge := Rect2(rect.position + Vector2(10, 8), Vector2(rect.size.y - 16.0, rect.size.y - 16.0))
	var pulsation := sin(_pulsation_niveau * PI) * 0.18
	var centre_badge := badge.get_center()
	if _pulsation_niveau > 0.0 and not ReglagesJoueur.effets_reduits:
		DessinJeu.rayons(self, centre_badge, badge.size.x * (0.9 + _pulsation_niveau),
			Color(StyleJeu.OR, 0.55 * _pulsation_niveau), _temps * 1.5, 10)
	var badge_anime := Rect2(centre_badge - badge.size * (0.5 + pulsation), badge.size * (1.0 + pulsation * 2.0))
	draw_style_box(StyleJeu.boite("azur", badge_anime.size.x * 0.5), badge_anime)
	DessinJeu.texte_centre(self, Polices.JEU, centre_badge + Vector2(0, -22), "NIV", 20, StyleJeu.TEXTE, StyleJeu.teinte("azur")["contour_texte"])
	DessinJeu.texte_centre(self, Polices.JEU_FORT, centre_badge + Vector2(0, 10), str(Jeu.niveau_run), 42 + roundi(pulsation * 40.0), StyleJeu.TEXTE, StyleJeu.teinte("azur")["contour_texte"], badge.size.x - 8.0)
	var zone := Rect2(Vector2(badge.end.x + 12.0, rect.position.y), Vector2(rect.end.x - badge.end.x - 30.0, rect.size.y))
	var titre := "MINE %d:%02d" % [ceili(Jeu.temps_mine_restant) / 60, ceili(Jeu.temps_mine_restant) % 60] if Jeu.mode_run == "mine" \
		else "SALLE %d/%d" % [Jeu.salle_courante, Jeu.salles_du_chapitre()]
	DessinJeu.texte_centre(self, Polices.JEU_FORT, Vector2(zone.get_center().x, zone.position.y + 36.0), titre, 34, StyleJeu.TEXTE, StyleJeu.CONTOUR_TEXTE, zone.size.x)
	var barre := Rect2(Vector2(zone.position.x, zone.position.y + 62.0), Vector2(zone.size.x, 30.0))
	DessinJeu.jauge(self, barre, _xp_affichee, Color("8ff3ff"), Color("2b8be6"))


func _dessiner_ressources(rect: Rect2) -> void:
	var hauteur := (rect.size.y - 8.0) * 0.5
	var lignes := [[ReglagesJoueur.gouttes_affichees(), "azur"], [str(Jeu.inventaire.size()), "violet"]]
	for i in 2:
		var pilule := Rect2(rect.position + Vector2(20, float(i) * (hauteur + 8.0)), Vector2(rect.size.x - 20.0, hauteur))
		draw_style_box(StyleJeu.panneau(StyleJeu.teinte(str(lignes[i][1]))["bas"], hauteur * 0.5, 0.94), pilule)
		DessinJeu.texte_centre(self, Polices.JEU_FORT, pilule.get_center() + Vector2(18, 0), str(lignes[i][0]), 30,
			StyleJeu.TEXTE, StyleJeu.CONTOUR_TEXTE, pilule.size.x - 50.0)


func _dessiner_barre_boss(boss: Node, rect: Rect2) -> void:
	var ratio := clampf(float(boss.pv) / maxf(1.0, float(boss.pv_max)), 0.0, 1.0)
	var nom := str(boss.donnees.get("nom", "BOSS")).to_upper()
	draw_style_box(StyleJeu.panneau(Palette.DANGER, 30.0, 0.95), rect)
	var badge := Rect2(rect.position + Vector2(4, 4), Vector2(rect.size.y - 8.0, rect.size.y - 8.0))
	draw_style_box(StyleJeu.boite("rubis", badge.size.x * 0.5), badge)
	var zone := Rect2(Vector2(badge.end.x + 12.0, rect.position.y), Vector2(rect.end.x - badge.end.x - 30.0, rect.size.y))
	DessinJeu.texte(self, Polices.JEU_FORT, Vector2(zone.position.x + 4.0, zone.position.y + 33.0), nom, 26,
		Color("ffe1d6"), Color("4a0d18"))
	var barre := Rect2(Vector2(zone.position.x, zone.position.y + 44.0), Vector2(zone.size.x, 28.0))
	var chaud := Color("ff6b5e").lerp(Color("ffd36b"), ratio)
	DessinJeu.jauge(self, barre, ratio, chaud.lightened(0.25), chaud.darkened(0.35), _boss_retard, 4)


# Couche propre aux annonces : son opacite fond le bandeau entier.
class _Bandeau:
	extends Control
	var hud: Control

	func _draw() -> void:
		if is_instance_valid(hud):
			hud.dessiner_annonce(self)
