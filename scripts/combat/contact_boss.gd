extends RefCounted

var etat := "repos"
var reste := 0.0
var direction := Vector2.DOWN
var profil: Dictionary = {}

func peut_commencer(boss: CharacterBody2D) -> bool:
	var attaque: Dictionary = AttaquesContactBoss.PROFILS[str(boss.donnees["contact_boss"])]
	var approche := float(boss.donnees["vitesse"]) * float(attaque["vitesse"]) \
		* Reglages.ENNEMI_VITESSE_MULT * float(boss._facteur_ralentissement()) * float(attaque["approche"])
	return boss.global_position.distance_to(boss._cible.global_position) <= float(attaque["portee"]) * AttaquesContactBoss.DISTANCE_ARRET + approche \
		and Geometrie.ligne_libre(boss.global_position, boss._cible.global_position, boss.get_parent().obstacles(),
			float(boss.donnees["rayon"]) * Reglages.BOSS_HITBOX_MULT)

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
			if ecart.length() <= float(profil["portee"]) * AttaquesContactBoss.DISTANCE_ARRET \
					and Geometrie.ligne_libre(boss.global_position, boss._cible.global_position, boss.get_parent().obstacles()):
				etat = "annonce"
				reste = float(profil["annonce"])
				direction = ecart.normalized() if not ecart.is_zero_approx() else Vector2.DOWN
				boss._direction_charge = direction
			elif reste <= 0.0:
				# Une approche ratee rend la main au choix de motif, sans cast dans le vide.
				etat = "repos"
				boss._minuterie = 0.0
			else:
				boss._deplacement.avancer(boss, float(profil["portee"]) * AttaquesContactBoss.DISTANCE_ARRET, float(profil["vitesse"]))
		"annonce":
			if reste <= 0.0:
				etat = "frappe"
				reste = AttaquesContactBoss.FRAPPE_DUREE
				if AttaquesContactBoss.contient_cible(boss.global_position, direction, boss._cible.global_position, profil, Reglages.HEROS_RAYON) \
						and Geometrie.ligne_libre(boss.global_position, boss._cible.global_position, boss.get_parent().obstacles()):
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
