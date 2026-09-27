extends RefCounted

var attentes: Array[Dictionary] = []

func programmer(tir: Tir, origine: Vector2, direction: Vector2) -> void:
	attentes.append({"tir": tir, "origine": origine, "direction": direction,
		"reste": BestiaireMondes.BOSS_ANNONCE_TIR})

func avancer(delta: float) -> Array[Dictionary]:
	var prets: Array[Dictionary] = []
	var restantes: Array[Dictionary] = []
	for attente: Dictionary in attentes:
		attente["reste"] = maxf(0.0, float(attente["reste"]) - delta)
		if float(attente["reste"]) <= 0.0: prets.append(attente)
		else: restantes.append(attente)
	attentes = restantes
	return prets

func annuler() -> void:
	attentes.clear()
