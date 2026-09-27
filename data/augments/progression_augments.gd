class_name ProgressionAugments
extends RefCounted

# Le rattrapage garantit dix niveaux avant le boss, meme avec peu d'XP.
# Chaque niveau accorde un seul choix ; le planning est fixe avant les offres.
const XP_SEUILS := [4, 20, 32, 50, 70, 90, 112, 140, 180, 220]
const SALLES_NIVEAUX := [1, 3, 4, 6, 8, 9, 11, 13, 16, 19]
const NIVEAU_LEGENDAIRE := 5
const NOMBRE_EPIQUES := 3
const CHANCE_LEGENDAIRE_BONUS := 0.10
const NOMBRE_CHOIX := 3
const DERNIER_NIVEAU_AVIDITE := 6

static func niveau_max() -> int:
	return XP_SEUILS.size()

static func plafond_salle(salle: int, total_salles: int) -> int:
	var avancement := float(maxi(0, salle)) / float(maxi(1, total_salles - 1))
	var cible := 0
	for palier: int in SALLES_NIVEAUX:
		if avancement >= float(palier) / float(SALLES_NIVEAUX.back()):
			cible += 1
	return cible

static func tirer_raretes_niveaux(rng: RandomNumberGenerator, autoriser_legendaire_bonus := true) -> Array[String]:
	var disponibles: Array[int] = []
	var raretes: Array[String] = []
	for niveau in range(1, niveau_max() + 1):
		raretes.append(Reactif.LEGENDAIRE if niveau == NIVEAU_LEGENDAIRE else Reactif.RARE)
		if niveau != NIVEAU_LEGENDAIRE:
			disponibles.append(niveau - 1)
	var candidats_bonus := disponibles.duplicate()
	for _choix in NOMBRE_EPIQUES:
		var index := rng.randi_range(0, disponibles.size() - 1)
		raretes[disponibles[index]] = Reactif.EPIQUE
		disponibles.remove_at(index)
	# Un tirage par run garantit exactement la probabilite annoncee et jamais
	# une troisieme legendaire. Le remplacement peut toucher une rare ou une epique.
	if autoriser_legendaire_bonus and rng.randf() < CHANCE_LEGENDAIRE_BONUS:
		var niveau_bonus: int = candidats_bonus[rng.randi_range(0, candidats_bonus.size() - 1)]
		raretes[niveau_bonus] = Reactif.LEGENDAIRE
	return raretes

static func rarete_niveau(niveau: int, raretes: Array[String]) -> String:
	if niveau < 1 or niveau > raretes.size():
		return Reactif.RARE
	return raretes[niveau - 1]

static func relance_autorisee(rarete: String) -> bool:
	return rarete in [Reactif.RARE, Reactif.EPIQUE]
