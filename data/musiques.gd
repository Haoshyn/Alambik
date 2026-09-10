class_name Musiques
extends RefCounted

# Un catalogue commun evite de desynchroniser sauvegarde, selecteurs et lecteur.
const RUNS: Array[Dictionary] = [
	{"id": "first_arcade", "nom": "FIRST ARCADE", "fichier": "res://assets/audio/firstarcade.ogg"},
	{"id": "dynamic_arcade", "nom": "DYNAMIC ARCADE", "fichier": "res://assets/audio/dynamic_arcade.ogg"},
	{"id": "cuivre_vif", "nom": "Cuivre vif", "fichier": "res://assets/audio/cuivre_vif.ogg"},
	{"id": "vortex_azur", "nom": "Vortex d’azur", "fichier": "res://assets/audio/vortex_azur.ogg"},
	{"id": "braise_volatile", "nom": "Braise volatile", "fichier": "res://assets/audio/braise_volatile.ogg"},
]
const MENU: Array[Dictionary] = [
	{"id": "accueil", "nom": "Accueil — originale", "fichier": "res://Accueil.ogg"},
	{"id": "atelier_lunaire", "nom": "Atelier lunaire", "fichier": "res://assets/audio/atelier_lunaire.ogg"},
]

static func contient(id: String, menu := false) -> bool:
	for piste in MENU if menu else RUNS:
		if str(piste["id"]) == id:
			return true
	return false

static func valider(id: String, menu := false) -> String:
	return id if contient(id, menu) else ("accueil" if menu else "first_arcade")

static func creer_flux(id: String, menu := false) -> AudioStreamOggVorbis:
	var choix := valider(id, menu)
	for piste in MENU if menu else RUNS:
		if str(piste["id"]) == choix:
			var source: AudioStreamOggVorbis = load(str(piste["fichier"]))
			var flux: AudioStreamOggVorbis = source.duplicate()
			flux.loop = true
			return flux
	return null
