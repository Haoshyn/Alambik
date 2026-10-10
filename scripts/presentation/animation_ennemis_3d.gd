extends Node3D

const Rendu = preload("res://data/presentation/animations_combat.gd")

var _boss := false
var _temps := 0.0
var _attaque := 0.0
var _impact := 0.0
var _preparation := 0.0
var _charge_precedente := false
var _forme := Vector3.ONE
var _inclinaison := 0.0
var _roulis := 0.0
var _hauteur := 0.0
var _membres := preload("res://scripts/presentation/animation_membres_ennemis.gd").new()
var _appuis := preload("res://scripts/presentation/appuis_bestiaire_3d.gd").new()
var _elan := Vector2.ZERO

func preparer(donnees: Dictionary, modele: Node3D) -> void:
	_boss = str(donnees["cerveau"]) == "boss"
	_membres.preparer(modele, donnees)
	_appuis.preparer(modele)
	# Des respirations decalees evitent une horde qui bouge a l'unisson.
	_temps = float(get_instance_id() % 97) * 0.17

func projeter() -> void:
	# Une salve emet plusieurs signaux ; elle conserve une seule percussion.
	if _attaque <= Rendu.ATTAQUE_DUREE - Rendu.ATTAQUE_REARMEMENT:
		_attaque = Rendu.ATTAQUE_DUREE

func toucher() -> void:
	if _impact <= 0.0:
		_impact = Rendu.IMPACT_DUREE

func mettre_a_jour(ennemi: Node2D, delta: float, orientation: float, _vitesse: float) -> void:
	if float(ennemi.get("_gel")) > 0.0:
		return
	_temps += delta
	_attaque = maxf(0.0, _attaque - delta)
	_impact = maxf(0.0, _impact - delta)
	var donnees: Dictionary = ennemi.get("donnees")
	var etat := str(ennemi.get("_motif" if _boss else "_etat"))
	var charge: bool = etat == "charger" or (_boss and etat == "charge" and ennemi._charge_debutee and not ennemi._charge_terminee)
	if _boss and etat == "assaut_contact": charge = str(ennemi._contact.etat) == "frappe"
	if charge and not _charge_precedente: projeter()
	_charge_precedente = charge
	var armer := _progression_preparation(ennemi, donnees, etat)
	var lissage := 1.0 - exp(-Rendu.LISSAGE_POSE * delta)
	_preparation = lerpf(_preparation, armer, lissage)
	var trajet := _appuis.mesurer(delta)
	var mouvement := clampf(_appuis.vitesse / 1.8, 0.0, 1.0)
	var axe := Basis(Vector3.UP, orientation)
	var local := axe.inverse() * trajet.normalized() * mouvement
	_elan = _elan.lerp(Vector2(local.x, local.z), 1.0 - exp(-6.0 * delta))
	var flottant := _appuis.pattes.is_empty()
	var souffle := sin(_temps * 1.65) * (0.0 if ReglagesJoueur.effets_reduits else 1.0)
	var t := 1.0 - _attaque / Rendu.ATTAQUE_DUREE
	# Le geste atteint sa cible vite puis absorbe le recul plus lentement.
	var frappe := (smoothstep(0.0, .16, t) if t < .16 else 1.0 - smoothstep(.16, 1.0, t)) if _attaque > 0.0 else 0.0
	var heurt := sin((1.0 - _impact / Rendu.IMPACT_DUREE) * TAU) * _impact / Rendu.IMPACT_DUREE
	_membres.mettre_a_jour(delta, mouvement, _preparation, frappe, heurt, _elan, 0.0 if flottant else _appuis.phase)
	_forme = Vector3.ONE
	_inclinaison = lerpf(_inclinaison, -_preparation * Rendu.PREPARATION_INCLINAISON
		+ frappe * .09 + _elan.y * (.065 if flottant else .025)
		+ (Rendu.CHARGE_INCLINAISON * .5 if charge else 0.0), lissage)
	_roulis = -_elan.x * (.075 if flottant else .025) + heurt * (.015 if _boss else .035)
	var phase := float(ennemi.get("_eclat_phase")) if _boss else 0.0
	_hauteur = .025 + souffle * .010 if flottant else -.018 - _preparation * .018
	if not flottant and not ReglagesJoueur.effets_reduits:
		_hauteur -= (1.0 - cos(_appuis.phase * TAU * 2.0)) * .014 * mouvement
	_hauteur += sin(clampf(phase, 0.0, 1.0) * PI) * Rendu.PHASE_HAUTEUR
	var apparition := smoothstep(0.0, 1.0, float(ennemi.get("_apparition")))
	var entree := lerpf(0.72, 1.0, apparition)
	if not _boss and etat == "phase":
		var progression := clampf(1.0 - float(ennemi._minuterie) / Reglages.PHASE_ANNONCE, 0.0, 1.0)
		entree *= lerpf(1.0, Rendu.PHASE_ECHELLE_MIN, smoothstep(0.0, 1.0, progression))
	elif not _boss and etat == "vise_phase":
		var progression := clampf((1.0 - float(ennemi._minuterie) / Reglages.PHASE_PREPARATION_TIR) / Rendu.PHASE_RETOUR_PART, 0.0, 1.0)
		entree *= lerpf(Rendu.PHASE_ECHELLE_MIN, 1.0, smoothstep(0.0, 1.0, progression))
	# Ce pivot enveloppe le GLB : les proportions du monde et ses pistes restent intactes.
	basis = axe * Basis.from_euler(Vector3(_inclinaison, 0, _roulis)) * axe.inverse()
	scale = _forme * entree
	position = axe * Vector3(0, _hauteur, -frappe * Rendu.RECUL * .45)
	_appuis.poser(delta, trajet)

func _progression_preparation(ennemi: Node2D, donnees: Dictionary, etat: String) -> float:
	if _boss:
		if etat == "assaut_contact" and str(ennemi._contact.etat) == "annonce":
			return 1.0 - float(ennemi._contact.reste) / float(ennemi._contact.profil["annonce"])
		if ennemi._annonce_charge():
			return clampf((float(ennemi._duree_du_motif("charge")) - float(ennemi._minuterie)) / BestiaireMondes.BOSS_CHARGE_ANNONCE, 0.0, 1.0)
		var annonce := float(ennemi._motifs_mondes.annonce)
		if annonce > 0.0: return 1.0 - annonce / BestiaireMondes.BOSS_ANNONCE_TIR
		var signature := float(ennemi._telegraphe_signature)
		return 1.0 - signature / Reglages.BOSS_TELEGRAPHE_SIGNATURE if signature > 0.0 else 0.0
	var salves: Array = ennemi._salves
	if not salves.is_empty():
		var prochaine: Dictionary = salves[0]
		return clampf(1.0 - float(prochaine["delai"]) / EvolutionEnnemis.INTERVALLE_SALVES, 0.0, 1.0)
	if etat not in ["preparer", "vise", "vise_orbite", "tisser", "crache", "pulse", "invoque", "phase", "vise_phase", "bombarde", "frappe", "gonfler"]:
		return 0.0
	var duree := float(donnees.get("preparation" if etat in ["preparer", "gonfler"] else "telegraphe", 1.0))
	if etat == "phase": duree = Reglages.PHASE_ANNONCE
	elif etat == "vise_phase": duree = Reglages.PHASE_PREPARATION_TIR
	elif etat == "frappe": duree = Reglages.ENNEMI_CONTACT_ANNONCE
	return clampf(1.0 - float(ennemi.get("_minuterie")) / maxf(duree, 0.01), 0.0, 1.0)
