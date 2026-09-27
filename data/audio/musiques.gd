class_name Musiques
extends RefCounted

# Un catalogue commun evite de desynchroniser sauvegarde, selecteurs et lecteur.
const RUNS: Array[Dictionary] = [
	{"id": "first_arcade", "nom": "FIRST ARCADE", "fichier": "res://assets/audio/firstarcade.ogg"},
	{"id": "dynamic_arcade", "nom": "DYNAMIC ARCADE", "fichier": "res://assets/audio/dynamic_arcade.ogg"},
	{"id": "aventure_esquisse", "nom": "Aventure · Esquisse 1", "fichier": "res://assets/audio/aventure_esquisse.ogg"},
]
const MENU: Array[Dictionary] = [
	{"id": "accueil", "nom": "Accueil — originale", "fichier": "res://assets/audio/Accueil.ogg"},
	{"id": "atelier_esquisse", "nom": "Atelier · Esquisse 1", "fichier": "res://assets/audio/atelier_esquisse.ogg"},
]

# Les choix retires reviennent aux originaux sans perdre les autres reglages.
const PISTES_RETIREES := {
	"cuivre_vif": "first_arcade", "vortex_azur": "first_arcade",
	"braise_volatile": "first_arcade", "etincelles": "first_arcade",
	"ronde_automates": "first_arcade", "course_canopee": "first_arcade",
	"fournaise": "first_arcade", "marees_arcanes": "first_arcade",
	"atelier_lunaire": "accueil", "matin_atelier": "accueil",
	"jardin_verre": "accueil", "bibliotheque": "accueil",
	"the_alchimiste": "accueil", "serre_aube": "accueil",
	"poussiere_etoiles": "accueil", "comptoir_cuivre": "accueil",
	"carnet_voyage": "accueil",
}

static func contient(id: String, menu := false) -> bool:
	for piste in MENU if menu else RUNS:
		if str(piste["id"]) == id:
			return true
	return false

static func valider(id: String, menu := false) -> String:
	var remplacee := str(PISTES_RETIREES.get(id, id))
	return remplacee if contient(remplacee, menu) else ("accueil" if menu else "first_arcade")

static func creer_flux(id: String, menu := false) -> AudioStreamOggVorbis:
	var choix := valider(id, menu)
	for piste in MENU if menu else RUNS:
		if str(piste["id"]) == choix:
			var source: AudioStreamOggVorbis = load(str(piste["fichier"]))
			var flux: AudioStreamOggVorbis = source.duplicate()
			flux.loop = true
			return flux
	return null
