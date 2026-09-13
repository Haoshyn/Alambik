extends SceneTree

class Cible:
	extends CharacterBody2D
	func recevoir_degats(_montant: float, _effets: Array = []) -> void: pass

var controles := 0
var echecs := 0

func _initialize() -> void:
	call_deferred("verifier")

func exiger(condition: bool, message: String) -> void:
	controles += 1
	if not condition:
		echecs += 1
		push_error(message)

func verifier() -> void:
	root.get_node("ReglagesJoueur").sauvegarde_active = false
	var evolution: Script = load("res://data/evolution_ennemis.gd")
	var catalogue: Script = load("res://data/catalogue_ennemis.gd")
	var boss_script: Script = load("res://scripts/boss.gd")
	var cible := Cible.new()
	root.add_child(cible)
	cible.add_to_group("cibles_ennemis")
	cible.global_position = Vector2(540,1100)
	for chapitre in [0,12,27]:
		var total := 0
		for id: String in catalogue.TOUS:
			var d: Dictionary = evolution.appliquer(catalogue.par_id(id),chapitre)
			var majeur := str(d["cerveau"]) == "boss"
			var acteur: Node2D = load("res://scenes/boss.tscn" if majeur else "res://scenes/ennemi.tscn").instantiate()
			acteur.configurer(d)
			root.add_child(acteur)
			acteur.set_physics_process(false)
			acteur.set("_cible",cible)
			var tirs := [0]
			acteur.tir_demande.connect(func(tir,origine,direction):
				tirs[0] += tir.nb_projectiles
				exiger(origine.is_finite() and direction.is_finite(),"trajectoire valide : "+id))
			if majeur:
				for phase in [1,2]:
					acteur.set("_phase",phase)
					for motif in boss_script.motifs_pour(id,phase):
						acteur.set("_cadence_motif",0.0)
						acteur.set("_minuterie",acteur.call("_duree_du_motif",motif))
						acteur.call("_commencer_motif",motif)
						for frame in 40:
							acteur.set("_minuterie",float(acteur.get("_minuterie"))-.1)
							acteur.set("_anim",float(acteur.get("_anim"))+.1)
							acteur.call("_executer_motif",motif,.1)
			else:
				var cerveau := str(d["cerveau"])
				if cerveau == "veloce":
					acteur.global_position = cible.global_position-Vector2(0,400)
					acteur.call("_agir_veloce",0.0)
					exiger(acteur.get("_etat")=="preparer","premiere charge annoncee")
					acteur.set("_minuterie",0.0)
					acteur.call("_agir_veloce",0.0)
					acteur.set("_minuterie",0.0)
					acteur.call("_agir_veloce",0.0)
					exiger(acteur.get("_etat")==("preparer" if chapitre >= 12 else "repos"),"relance annoncee au bon palier")
				elif cerveau == "rampant":
					acteur.global_position = cible.global_position-Vector2(0,200)
					acteur.set("_recharge",0.0)
					acteur.call("_agir_rampant",0.0)
					exiger((acteur.get("_etat")=="preparer")== (chapitre >= 12),"elan appris en milieu de campagne")
				else:
					if cerveau in ["miroir","essaimeur","volatile"]: acteur.call("_tirer_cercle",int(d["projectiles_cercle"]))
					else: acteur.call("_tirer_vers",cible.global_position)
					var premier: int = tirs[0]
					for salve in 3: acteur.call("_relancer_salves",evolution.INTERVALLE_SALVES)
					exiger(tirs[0]==premier*int(d.get("salves",1)),"rafale finie et exacte : "+id)
					exiger(acteur.get("_salves").is_empty(),"aucune salve residuelle : "+id)
			total += int(tirs[0])
			acteur.free()
		print("PATTERNS chapitre=%d bestiaire=%d tirs=%d" % [chapitre+1,catalogue.TOUS.size(),total])
	cible.free()
	print("EVOLUTION_PATTERNS : %d controles, %d echecs" % [controles,echecs])
	quit(1 if echecs else 0)
