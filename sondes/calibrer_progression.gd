extends SceneTree

# Profil indicatif : ne modifie pas le jeu et ne compense pas automatiquement ses stats.
func _initialize() -> void:
	var lignes := ["chapitre;degats;cadence;pv;resistance;ennemi_pv_mult;coup_reference;impacts_avant_mort"]
	for palier in 30:
		var actuel := preload("res://sondes/profil_progression.gd").au_palier(palier)
		var coup := Reglages.DEGATS_COUP_REFERENCE*Chapitres.facteur_degats(palier,1)
		lignes.append("%d;%.2f;%.2f;%.2f;%.2f;%.2f;%.2f;%.2f" % [palier+1,
			actuel["degats"],actuel["cadence"],actuel["pv"],actuel["resistance"],
			Chapitres.facteur_pv(palier,1),coup,float(actuel["resistance"])/coup])
	DirAccess.make_dir_recursive_absolute("res://tmp/progression")
	var fichier := FileAccess.open("res://tmp/progression/courbe.csv", FileAccess.WRITE)
	fichier.store_string("\n".join(lignes)+"\n")
	print("\n".join(lignes))
	quit()
