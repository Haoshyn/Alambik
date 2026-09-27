class_name MigrationPassifs
extends RefCounted

const VERSION := 1
const GOUTTES_PAR_RANG_EXCEDENTAIRE := 20

# Seule la migration connait les capacites retirees : aucun combat ne les consulte.
const CORRESPONDANCES := {
	"onde_alchimique": "carapace", "nova_de_givre": "vitalite",
	"barrage_de_braise": "impact_critique", "impulsion_foudroyante": "oeil_precis",
	"explosion_corrosive": "butin_precieux", "vortex_alchimique": "pas_leger",
	"grand_oeuvre": "vigueur", "temps_suspendu": "recuperation",
	"transmutation_totale": "soins_renforces", "purification_totale": "vitalite",
	"riposte_alchimique": "vigueur", "reserve_ultime": "celerite",
	"heritage_reactif": "savoir_pratique", "echo_alchimique": "projectiles_vifs",
}

static func convertir(rangs: Dictionary, equipes: Array) -> Dictionary:
	var convertis := {}
	var compensation := 0
	for ancien: String in rangs:
		var id := str(CORRESPONDANCES.get(ancien, ancien))
		var nombre := maxi(0, int(rangs[ancien]))
		if not Passifs.contient(id):
			compensation += nombre * GOUTTES_PAR_RANG_EXCEDENTAIRE
			continue
		var precedent := int(convertis.get(id, 0))
		var total := precedent + nombre
		convertis[id] = mini(Passifs.RANG_MAX, total)
		compensation += maxi(0, total - Passifs.RANG_MAX) * GOUTTES_PAR_RANG_EXCEDENTAIRE
	var selection: Array[String] = []
	for ancien in equipes:
		var id := str(CORRESPONDANCES.get(str(ancien), str(ancien)))
		if int(convertis.get(id, 0)) > 0 and id not in selection and selection.size() < Passifs.EMPLACEMENTS:
			selection.append(id)
	return {"rangs": convertis, "equipes": selection, "gouttes": compensation}
