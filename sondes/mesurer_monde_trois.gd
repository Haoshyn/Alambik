extends SceneTree

func _initialize() -> void:
	var lignes: Array[String] = []
	for chapitres in [6,9]:
		for repetitions in [2,3]:
			for poids in [0.5,1.0,2.0]:
				var mesures: Array[Dictionary] = []
				for graine in range(1,101):
					mesures.append(preload("res://sondes/economie_monde_trois.gd").simuler(repetitions,graine,poids,chapitres))
				var resume := {"chapitres":chapitres,"repetitions":repetitions,"poids_defense":poids}
				for champ in ["revenus","pv","resistance","dps","degats"]:
					var valeurs: Array[float] = []
					for mesure in mesures: valeurs.append(float(mesure[champ]))
					valeurs.sort()
					resume[champ] = {"p10":valeurs[9],"mediane":valeurs[49],"p90":valeurs[89]}
				resume["exemple"] = mesures[0]
				lignes.append(JSON.stringify(resume))
	DirAccess.make_dir_recursive_absolute("res://tmp/progression")
	var fichier := FileAccess.open("res://tmp/progression/economie_monde3.jsonl",FileAccess.WRITE)
	fichier.store_string("\n".join(lignes)+"\n")
	for ligne in lignes: print(ligne)
	quit()
