extends Node

# Les effets sont synthetises ; les compositions sont lues en boucle depuis Ogg.

const EFFETS := preload("res://data/effets_sonores.gd")
const SYNTHESE := preload("res://scripts/audio/synthese_effets.gd")
const DUREE_FONDU := 2.2
const DUREE_BLANC_COMBAT := 0.14
const BUS_MUSIQUE := "Musique"
const BUS_EFFETS := "Effets"

var _banque: Dictionary = {}
var _voix: Array[AudioStreamPlayer] = []
var _noms_voix: Array[String] = []
var _priorites_voix := PackedInt32Array()
var _debuts_voix := PackedInt64Array()
var _derniers_sons: Dictionary = {}
var _dernieres_variantes: Dictionary = {}
var _alea := RandomNumberGenerator.new()
var _retrait_restant := 0.0
var _retrait_mixage := 0.0
var _index_bus_combat := -1
var _application_active := true
var _vibrations_autorisees := false
var _derniere_vibration := -10000
var _dernieres_vibrations: Dictionary = {}
var actif := true
var _musiques: Array[AudioStreamPlayer] = []
var _volumes_vises := PackedFloat32Array([-80.0, -80.0])
var _piste_chargee := ""
var _piste_menu_chargee := "accueil"

func pistes_disponibles() -> Array[Dictionary]:
	return Musiques.RUNS

func pistes_menu_disponibles() -> Array[Dictionary]:
	return Musiques.MENU

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_preparer_bus(BUS_MUSIQUE)
	_preparer_bus(BUS_EFFETS)
	_preparer_bus(EFFETS.BUS_COMBAT)
	_index_bus_combat = AudioServer.get_bus_index(EFFETS.BUS_COMBAT)
	AudioServer.set_bus_send(_index_bus_combat, BUS_EFFETS)
	if OS.has_feature("headless") or DisplayServer.get_name() == "headless":
		actif = false
	var arguments := OS.get_cmdline_args() + OS.get_cmdline_user_args()
	_vibrations_autorisees = actif and OS.has_feature("android") and not arguments.has("--auto")
	_alea.randomize()
	if actif:
		_banque = SYNTHESE.creer_banque()
	for i in EFFETS.VOIX:
		var lecteur := AudioStreamPlayer.new()
		lecteur.bus = BUS_EFFETS
		add_child(lecteur)
		_voix.append(lecteur)
		_noms_voix.append("")
		_priorites_voix.append(0)
		_debuts_voix.append(0)
	if actif:
		# Une copie locale active la boucle sans modifier la ressource importee.
		for ambiance in 2:
			var musique := AudioStreamPlayer.new()
			musique.bus = BUS_MUSIQUE
			if ambiance == 1:
				musique.stream = _creer_flux_combat("first_arcade")
				_piste_chargee = "first_arcade"
			else:
				musique.stream = _creer_flux_accueil()
			musique.volume_db = -80.0
			add_child(musique)
			_musiques.append(musique)
		# Tout demarrer une fois permet ensuite des fondus sans latence de lecture.
		for musique in _musiques:
			musique.play()
		musique_menu()

func _process(delta: float) -> void:
	_retrait_restant = maxf(0.0, _retrait_restant - delta)
	var duree := EFFETS.ATTAQUE_RETRAIT if _retrait_restant > 0.0 else EFFETS.SORTIE_RETRAIT
	_retrait_mixage = move_toward(_retrait_mixage, 1.0 if _retrait_restant > 0.0 else 0.0, delta / duree)
	if _index_bus_combat >= 0:
		AudioServer.set_bus_volume_db(_index_bus_combat, _retrait_mixage * EFFETS.RETRAIT_COMBAT_DB)
	for i in _musiques.size():
		var volume := _volumes_vises[i] + _retrait_mixage * EFFETS.RETRAIT_MUSIQUE_DB
		_musiques[i].volume_db = move_toward(_musiques[i].volume_db, volume,
			80.0 * delta / DUREE_FONDU)

func _notification(quoi: int) -> void:
	if quoi in [NOTIFICATION_APPLICATION_FOCUS_OUT, NOTIFICATION_APPLICATION_PAUSED]:
		_application_active = false
	elif quoi in [NOTIFICATION_APPLICATION_FOCUS_IN, NOTIFICATION_APPLICATION_RESUMED]:
		_application_active = true

func musique_menu() -> void:
	_regler_musique(-8.0, -80.0)

func musique_calme() -> void:
	# Une pause ne baisse ni ne rembobine la piste : elle suspend seulement le jeu.
	var volume_combat := _volumes_vises[1] if _volumes_vises.size() > 1 else -13.0
	_regler_musique(-80.0, volume_combat)

func musique_combat(intensite := 0.5) -> void:
	var niveau := clampf(intensite, 0.0, 1.0)
	_regler_musique(-80.0, lerpf(-13.0, -8.0, niveau))

func musique_boss() -> void:
	_regler_musique(-80.0, -8.0)

func demarrer_musique_combat() -> void:
	if not actif or _musiques.size() < 2:
		return
	# Couper avant de rembobiner rend l'attaque composee dans LMMS intacte.
	_regler_musique(-80.0, -80.0)
	for musique in _musiques:
		musique.volume_db = -80.0
	_musiques[1].stop()
	await get_tree().create_timer(DUREE_BLANC_COMBAT).timeout
	if _musiques.size() < 2:
		return
	_musiques[1].play(0.0)
	_musiques[1].volume_db = -12.0
	_regler_musique(-80.0, -12.0)

func _regler_musique(ambiante: float, combat: float) -> void:
	_volumes_vises = PackedFloat32Array([ambiante, combat])

func _preparer_bus(nom: String) -> void:
	if AudioServer.get_bus_index(nom) >= 0:
		return
	AudioServer.add_bus()
	AudioServer.set_bus_name(AudioServer.bus_count - 1, nom)

func appliquer_reglages() -> void:
	_appliquer_volume_bus(BUS_MUSIQUE, ReglagesJoueur.volume_musique)
	_appliquer_volume_bus(BUS_EFFETS, ReglagesJoueur.volume_effets)
	_appliquer_piste_selectionnee()

func _appliquer_piste_selectionnee() -> void:
	if not actif or _musiques.size() < 2:
		return
	_remplacer_piste(0, ReglagesJoueur.piste_menu)
	_remplacer_piste(1, ReglagesJoueur.piste_musique)

func _remplacer_piste(index: int, id: String) -> void:
	var ancienne := _piste_menu_chargee if index == 0 else _piste_chargee
	if id == ancienne:
		return
	_musiques[index].stop()
	_musiques[index].stream = Musiques.creer_flux(id, index == 0)
	if index == 0:
		_piste_menu_chargee = id
	else:
		_piste_chargee = id
	_musiques[index].play(0.0)
	# Le changement s'entend dans le contexte courant, meme pendant une pause.
	_musiques[index].volume_db = _volumes_vises[index]

func _creer_flux_accueil() -> AudioStreamOggVorbis:
	return Musiques.creer_flux("accueil", true)

func _creer_flux_combat(id: String) -> AudioStreamOggVorbis:
	return Musiques.creer_flux(id)

func _appliquer_volume_bus(nom: String, volume: float) -> void:
	var index := AudioServer.get_bus_index(nom)
	if index < 0:
		return
	AudioServer.set_bus_mute(index, volume <= 0.001)
	AudioServer.set_bus_volume_db(index, linear_to_db(maxf(volume, 0.001)))

func jouer(nom: String, volume_db := -12.0, hauteur := 1.0) -> void:
	# Le tactile reste utilisable lorsque le joueur coupe les effets sonores.
	vibrer(nom)
	if not actif or not _banque.has(nom):
		return
	if ReglagesJoueur.volume_effets <= 0.001:
		return
	var profil: Dictionary = EFFETS.PROFILS[nom]
	var maintenant := Time.get_ticks_msec()
	if maintenant - int(_derniers_sons.get(nom, -10000)) < int(profil["intervalle_ms"]):
		return
	var index := _choisir_voix(nom, int(profil["priorite"]), int(profil["simultanes"]))
	if index < 0:
		return
	var variantes: Array[AudioStreamWAV] = _banque[nom]
	var variante := _choisir_variante(nom, variantes.size())
	var variation := float(profil["variation_hauteur"])
	var vitesse := clampf(hauteur * _alea.randf_range(1.0 - variation, 1.0 + variation), 0.35, 2.5)
	var lecteur := _voix[index]
	lecteur.stop()
	lecteur.bus = EFFETS.BUS_COMBAT if bool(profil.get("combat", false)) else BUS_EFFETS
	lecteur.stream = variantes[variante]
	lecteur.volume_db = volume_db
	lecteur.pitch_scale = vitesse
	_noms_voix[index] = nom
	_priorites_voix[index] = int(profil["priorite"])
	_debuts_voix[index] = maintenant
	_derniers_sons[nom] = maintenant
	_retrait_restant = maxf(_retrait_restant, float(profil.get("retrait", 0.0)) / vitesse)
	lecteur.play()

func _choisir_voix(nom: String, priorite: int, simultanes: int) -> int:
	var libre := -1
	var remplacable := -1
	var ancienne_identique := -1
	var nombre_identiques := 0
	for i in _voix.size():
		if not _voix[i].playing:
			if libre < 0:
				libre = i
			continue
		if _noms_voix[i] == nom:
			nombre_identiques += 1
			if ancienne_identique < 0 or _debuts_voix[i] < _debuts_voix[ancienne_identique]:
				ancienne_identique = i
		# Une rafale peut remplacer un autre tir, jamais une blessure ni un coffre.
		if _priorites_voix[i] > priorite:
			continue
		if remplacable < 0 or _priorites_voix[i] < _priorites_voix[remplacable] \
				or (_priorites_voix[i] == _priorites_voix[remplacable] and _debuts_voix[i] < _debuts_voix[remplacable]):
			remplacable = i
	if nombre_identiques >= simultanes:
		return ancienne_identique
	return libre if libre >= 0 else remplacable

func _choisir_variante(nom: String, nombre: int) -> int:
	var precedente := int(_dernieres_variantes.get(nom, -1))
	var variante := 0
	if precedente < 0:
		variante = _alea.randi_range(0, nombre - 1)
	elif nombre > 1:
		variante = _alea.randi_range(0, nombre - 2)
		if variante >= precedente:
			variante += 1
	_dernieres_variantes[nom] = variante
	return variante

func vibrer(nom: String) -> void:
	if not _vibrations_autorisees or not ReglagesJoueur.vibrations or Jeu.mode_auto:
		return
	if not _application_active or not get_window().has_focus() or not EFFETS.VIBRATIONS.has(nom):
		return
	var maintenant := Time.get_ticks_msec()
	var profil: Dictionary = EFFETS.VIBRATIONS[nom]
	if maintenant - _derniere_vibration < EFFETS.VIBRATION_INTERVALLE_MS:
		return
	if maintenant - int(_dernieres_vibrations.get(nom, -10000)) < int(profil["intervalle_ms"]):
		return
	_derniere_vibration = maintenant
	_dernieres_vibrations[nom] = maintenant
	Input.vibrate_handheld(int(profil["duree_ms"]), float(profil["amplitude"]))
