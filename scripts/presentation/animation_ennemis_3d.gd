extends Node3D

const Rendu = preload("res://data/animations_combat.gd")

var _profil: Dictionary
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

func preparer(donnees: Dictionary) -> void:
	_profil = Rendu.profil(donnees)
	_boss = str(donnees["cerveau"]) == "boss"
	# Des respirations decalees evitent une horde qui bouge a l'unisson.
	_temps = float(get_instance_id() % 97) * 0.17

func projeter() -> void:
	# Une salve emet plusieurs signaux ; elle conserve une seule percussion.
	if _attaque <= Rendu.ATTAQUE_DUREE - Rendu.ATTAQUE_REARMEMENT:
		_attaque = Rendu.ATTAQUE_DUREE

func toucher() -> void:
	if _impact <= 0.0:
		_impact = Rendu.IMPACT_DUREE

func mettre_a_jour(ennemi: Node2D, delta: float, orientation: float, vitesse: float) -> void:
	if float(ennemi.get("_gel")) > 0.0:
		return
	_temps += delta
	_attaque = maxf(0.0, _attaque - delta)
	_impact = maxf(0.0, _impact - delta)
	var donnees: Dictionary = ennemi.get("donnees")
	var etat := str(ennemi.get("_motif" if _boss else "_etat"))
	var charge := etat == "charger" or (_boss and etat == "charge" and not ennemi._annonce_charge())
	if charge and not _charge_precedente: projeter()
	_charge_precedente = charge
	var armer := _progression_preparation(ennemi, donnees, etat)
	var lissage := 1.0 - exp(-Rendu.LISSAGE_POSE * delta)
	_preparation = lerpf(_preparation, armer, lissage)
	var mouvement := clampf(vitesse / maxf(float(donnees["vitesse"]) * Reglages.ENNEMI_VITESSE_MULT, 1.0), 0.0, 1.0)
	var pas := _temps * float(_profil["cadence"])
	var souffle := sin(_temps * 2.6) * float(_profil["souffle"])
	var rebond := absf(sin(pas)) * float(_profil["pas"]) * mouvement
	var t := 1.0 - _attaque / Rendu.ATTAQUE_DUREE
	var frappe := sin(minf(t / 0.28, 1.0) * PI) if _attaque > 0.0 else 0.0
	var retour := sin(clampf((t - 0.28) / 0.72, 0.0, 1.0) * PI) if _attaque > 0.0 else 0.0
	var heurt := sin((1.0 - _impact / Rendu.IMPACT_DUREE) * TAU) * _impact / Rendu.IMPACT_DUREE
	var compression := _preparation * Rendu.PREPARATION_COMPRESSION
	var etirement := frappe * 0.10 - retour * 0.035
	_forme = Vector3(1.0 + compression * 0.5 - etirement * 0.4,
		1.0 - compression + etirement + souffle, 1.0 + compression * 0.5 - etirement * 0.4)
	_inclinaison = lerpf(_inclinaison, -_preparation * Rendu.PREPARATION_INCLINAISON
		+ frappe * 0.16 + (Rendu.CHARGE_INCLINAISON if charge else 0.0), lissage)
	_roulis = sin(pas) * float(_profil["roulis"]) * mouvement + heurt * (0.015 if _boss else 0.05)
	var phase := float(ennemi.get("_eclat_phase")) if _boss else 0.0
	_hauteur = rebond * (1.0 - _preparation) + sin(clampf(phase, 0.0, 1.0) * PI) * Rendu.PHASE_HAUTEUR
	var apparition := smoothstep(0.0, 1.0, float(ennemi.get("_apparition")))
	var entree := lerpf(0.72, 1.0, apparition)
	# Ce pivot enveloppe le GLB : les proportions du monde et ses pistes restent intactes.
	var axe := Basis(Vector3.UP, orientation)
	basis = axe * Basis.from_euler(Vector3(_inclinaison, 0, _roulis)) * axe.inverse()
	scale = _forme * entree
	position = axe * Vector3(0, _hauteur, -frappe * Rendu.RECUL)

func _progression_preparation(ennemi: Node2D, donnees: Dictionary, etat: String) -> float:
	if _boss:
		if ennemi._annonce_charge():
			return clampf((float(ennemi._duree_du_motif("charge")) - float(ennemi._minuterie)) / BestiaireMondes.BOSS_CHARGE_ANNONCE, 0.0, 1.0)
		var annonce := float(ennemi._motifs_mondes.annonce)
		if annonce > 0.0: return 1.0 - annonce / BestiaireMondes.BOSS_ANNONCE_TIR
		var signature := float(ennemi._telegraphe_signature)
		return 1.0 - signature / Reglages.BOSS_TELEGRAPHE_SIGNATURE if signature > 0.0 else 0.0
	if etat not in ["preparer", "vise", "vise_orbite", "tisser", "crache", "pulse", "invoque", "phase", "bombarde"]:
		return 0.0
	var duree := float(donnees.get("preparation" if etat == "preparer" else "telegraphe", 1.0))
	return clampf(1.0 - float(ennemi.get("_minuterie")) / maxf(duree, 0.01), 0.0, 1.0)
