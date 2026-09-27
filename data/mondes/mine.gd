class_name Mine
extends RefCounted

# Chaque niveau reprend un palier deja acquis en campagne.
static func nombre() -> int:
	return Chapitres.nombre() - Reglages.MINE_NIVEAU_DEBLOCAGE + 1

static func campagne_requise(niveau: int) -> int:
	return Reglages.MINE_NIVEAU_DEBLOCAGE + clampi(niveau, 1, nombre()) - 1

static func palier(niveau: int) -> int:
	return campagne_requise(niveau) - 1
