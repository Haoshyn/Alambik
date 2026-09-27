extends SceneTree

const Listes = preload("res://tools/statistiques/listes.gd")
const Mathematiques = preload("res://tools/statistiques/mathematiques.gd")

func _init() -> void:
	call_deferred("_exporter")

func _exporter() -> void:
	var verifier := "--verifier" in OS.get_cmdline_user_args()
	var contenus := {
		"liste_augments.md": Listes.augments(),
		"liste_items.md": Listes.items(),
		"liste_maitrises.md": Listes.maitrises(),
		"liste_passifs.md": Listes.passifs(),
		"liste_monstres.md": Listes.monstres(),
		"liste_mathematique.md": Mathematiques.generer(),
	}
	var erreurs := 0
	for nom: String in contenus:
		var chemin := "res://statistiques_jeu/" + nom
		var attendu: String = contenus[nom]
		if verifier:
			if not FileAccess.file_exists(chemin) or FileAccess.get_file_as_string(chemin) != attendu:
				push_error("Liste absente ou périmée : " + nom)
				erreurs += 1
		else:
			var fichier := FileAccess.open(chemin, FileAccess.WRITE)
			if fichier == null:
				push_error("Impossible d’écrire : " + chemin)
				erreurs += 1
				continue
			fichier.store_string(attendu)
	if erreurs == 0:
		print("Listes %s : %d catégories." % ["vérifiées" if verifier else "actualisées", contenus.size()])
	quit(1 if erreurs > 0 else 0)
