class_name Musiques
extends RefCounted

# Un catalogue commun evite de desynchroniser sauvegarde, selecteurs et lecteur.
const RUNS: Array[Dictionary] = [
	{"id": "first_arcade", "nom": "FIRST ARCADE", "fichier": "res://assets/audio/firstarcade.ogg"},
	{"id": "dynamic_arcade", "nom": "DYNAMIC ARCADE", "fichier": "res://assets/audio/dynamic_arcade.ogg"},
	{"id": "cuivre_vif", "nom": "Cuivre vif", "fichier": "res://assets/audio/cuivre_vif.ogg"},
	{"id": "vortex_azur", "nom": "Vortex d’azur", "fichier": "res://assets/audio/vortex_azur.ogg"},
	{"id": "braise_volatile", "nom": "Braise volatile", "fichier": "res://assets/audio/braise_volatile.ogg"},
	{"id":"etincelles", "nom":"Étincelles", "fichier":"res://assets/audio/etincelles.ogg"},
	{"id":"ronde_automates", "nom":"Ronde des automates", "fichier":"res://assets/audio/ronde_automates.ogg"},
	{"id":"course_canopee", "nom":"Course en canopée", "fichier":"res://assets/audio/course_canopee.ogg"},
	{"id":"fournaise", "nom":"Fournaise de cuivre", "fichier":"res://assets/audio/fournaise.ogg"},
	{"id":"marees_arcanes", "nom":"Marées arcanes", "fichier":"res://assets/audio/marees_arcanes.ogg"},
]
const MENU: Array[Dictionary] = [
	{"id": "accueil", "nom": "Accueil — originale", "fichier": "res://Accueil.ogg"},
	{"id": "atelier_lunaire", "nom": "Atelier lunaire", "fichier": "res://assets/audio/atelier_lunaire.ogg"},
	{"id":"matin_atelier", "nom":"Matin à l’atelier", "fichier":"res://assets/audio/matin_atelier.ogg"},
	{"id":"jardin_verre", "nom":"Jardin de verre", "fichier":"res://assets/audio/jardin_verre.ogg"},
	{"id":"bibliotheque", "nom":"Bibliothèque secrète", "fichier":"res://assets/audio/bibliotheque.ogg"},
	{"id":"the_alchimiste", "nom":"Le thé de l’alchimiste", "fichier":"res://assets/audio/the_alchimiste.ogg"},
	{"id":"serre_aube", "nom":"Serre à l’aube", "fichier":"res://assets/audio/serre_aube.ogg"},
	{"id":"poussiere_etoiles", "nom":"Poussière d’étoiles", "fichier":"res://assets/audio/poussiere_etoiles.ogg"},
	{"id":"comptoir_cuivre", "nom":"Comptoir de cuivre", "fichier":"res://assets/audio/comptoir_cuivre.ogg"},
	{"id":"carnet_voyage", "nom":"Carnet de voyage", "fichier":"res://assets/audio/carnet_voyage.ogg"},
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
