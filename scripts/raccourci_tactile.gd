class_name RaccourciTactile
extends RefCounted

# Reconnait une tape rapide sur l'ecran, pour lancer le Sort actif sans viser
# son icone.
#
# Un pouce qui pilote le heros reste pose et parcourt de la distance ; une tape
# volontaire est breve et quasi immobile. Sans ces deux bornes, chaque
# micro-correction de trajectoire declencherait le Sort au milieu d'un combat.
# Le temps est fourni par l'appelant : la detection reste ainsi verifiable en
# headless, sans horloge ni arbre de scene.

const MODES := ["visee", "automatique", "tape"]
const MODE_DEFAUT := "visee"
const DUREE_MAX := 0.22       # secondes entre l'appui et le relachement
const DISTANCE_MAX := 34.0    # pixels parcourus pendant la tape

var _pose := false
var _debut := 0.0
var _precedente := Vector2.ZERO
var _distance := 0.0

static func mode_valide(mode: String) -> String:
	# Migration des choix presents dans les sauvegardes precedentes.
	match mode:
		"icone": return "visee"
		"double_tape": return "tape"
	return mode if mode in MODES else MODE_DEFAUT

static func nom_mode(mode: String) -> String:
	match mode_valide(mode):
		"automatique": return "ICÔNE · CIBLE PROCHE"
		"tape": return "TAPE COURTE · CIBLE PROCHE"
	return "ICÔNE · VISÉE MANUELLE"

# Nombre de tapes qu'un mode demande avant de lancer le Sort. Zero signifie que
# seule l'icone du HUD declenche.
static func tapes_requises(mode: String) -> int:
	return 1 if mode_valide(mode) == "tape" else 0

static func visee_manuelle(mode: String) -> bool:
	return mode_valide(mode) == "visee"

func appuyer(position: Vector2, temps: float) -> void:
	_pose = true
	_debut = temps
	_precedente = position
	_distance = 0.0

func deplacer(position: Vector2) -> void:
	if not _pose:
		return
	_distance += _precedente.distance_to(position)
	_precedente = position

# Renvoie un pour une tape courte, ou zero si le geste relache n'en est pas une.
func relacher(temps: float) -> int:
	if not _pose:
		return 0
	_pose = false
	if temps - _debut > DUREE_MAX or _distance > DISTANCE_MAX:
		return 0
	return 1

func annuler() -> void:
	_pose = false

# Les autres doigts deja poses ne doivent pas relancer le meme Sort en se
# relevant apres la tape qui vient d'etre consommee.
func consommer() -> void:
	_pose = false
