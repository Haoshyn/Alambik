extends RefCounted

var etat := "repos"
var reste := 0.0
var direction := Vector2.DOWN
var profil: Dictionary = {}

func commencer(boss: CharacterBody2D) -> void:
	profil = AttaquesContactBoss.PROFILS[str(boss.donnees["contact_boss"])]
	etat = "approche"
	reste = float(profil["approche"])

func avancer(boss: CharacterBody2D, delta: float) -> void:
	reste = maxf(0.0, reste - delta)
	boss.velocity = Vector2.ZERO
	match etat:
		"approche":
			var ecart: Vector2 = boss._cible.global_position - boss.global_position
			if reste <= 0.0 or ecart.length() <= float(profil["portee"]) * AttaquesContactBoss.DISTANCE_ARRET:
				etat = "annonce"
				reste = float(profil["annonce"])
				direction = ecart.normalized() if not ecart.is_zero_approx() else Vector2.DOWN
				boss._direction_charge = direction
			else:
				boss.velocity = ecart.normalized() * float(boss.donnees["vitesse"]) * float(profil["vitesse"]) * Reglages.ENNEMI_VITESSE_MULT * float(boss._facteur_ralentissement())
				boss.move_and_slide()
		"annonce":
			if reste <= 0.0:
				etat = "frappe"
				reste = AttaquesContactBoss.FRAPPE_DUREE
				if AttaquesContactBoss.contient_cible(boss.global_position, direction, boss._cible.global_position, profil, Reglages.HEROS_RAYON):
					boss._cible.recevoir_degats(float(boss.donnees["degats"]))
		"frappe":
			if reste <= 0.0:
				etat = "recuperation"
				reste = float(profil["repos"])
		"recuperation":
			if reste <= 0.0:
				etat = "repos"
				boss._minuterie = 0.0
	# Le cycle local protege la recuperation meme si l'approche finit plus tot.
	if etat != "repos": boss._minuterie = maxf(float(boss._minuterie), delta * 2.0)
