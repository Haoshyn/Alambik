extends RefCounted

const CATALOGUE := preload("res://data/effets_sonores.gd")

static func creer_banque() -> Dictionary:
	var banque: Dictionary = {}
	for nom: String in CATALOGUE.PROFILS:
		var profil: Dictionary = CATALOGUE.PROFILS[nom]
		var variantes: Array[AudioStreamWAV] = []
		for variante in int(profil["variantes"]):
			variantes.append(_creer_flux(nom, profil, variante))
		banque[nom] = variantes
	return banque

static func _creer_flux(nom: String, profil: Dictionary, variante: int) -> AudioStreamWAV:
	var nombre := ceili(float(profil["duree"]) * CATALOGUE.TAUX)
	var signal_sonore := PackedFloat32Array()
	signal_sonore.resize(nombre)
	# Un generateur local ne consomme jamais le hasard utilise par les combats.
	var alea := RandomNumberGenerator.new()
	alea.seed = int(nom.hash()) + variante * 7919
	var hauteur := 1.0 + alea.randf_range(-CATALOGUE.VARIATION_TIMBRE, CATALOGUE.VARIATION_TIMBRE)
	var couches: Array = profil["couches"]
	for couche: Dictionary in couches:
		_ajouter_couche(signal_sonore, couche, hauteur, alea)
	var pic := 0.0
	for valeur in signal_sonore:
		pic = maxf(pic, absf(valeur))
	var gain := CATALOGUE.PIC_MAX / maxf(1.0, pic)
	var donnees := PackedByteArray()
	donnees.resize(nombre * 2)
	for i in nombre:
		donnees.encode_s16(i * 2, int(signal_sonore[i] * gain * 32767.0))
	var flux := AudioStreamWAV.new()
	flux.format = AudioStreamWAV.FORMAT_16_BITS
	flux.mix_rate = CATALOGUE.TAUX
	flux.stereo = false
	flux.data = donnees
	return flux

static func _ajouter_couche(signal_sonore: PackedFloat32Array, couche: Dictionary,
		hauteur: float, alea: RandomNumberGenerator) -> void:
	var debut := roundi(float(couche.get("debut", 0.0)) * CATALOGUE.TAUX)
	var duree: float = couche["duree"]
	var nombre := mini(ceili(duree * CATALOGUE.TAUX), signal_sonore.size() - debut)
	var forme := str(couche["forme"])
	var frequence := float(couche.get("frequence", 0.0)) * hauteur
	var fin := float(couche.get("fin", couche.get("frequence", 0.0))) * hauteur
	var gain: float = couche["gain"]
	var decroissance := float(couche.get("decroissance", 2.0))
	var attaque := float(couche.get("attaque", CATALOGUE.ATTAQUE))
	var filtre := float(couche.get("filtre", 0.3))
	var phase := 0.0
	var bruit_filtre := 0.0
	for i in nombre:
		var secondes := float(i) / CATALOGUE.TAUX
		var t := secondes / duree
		phase += TAU * lerpf(frequence, fin, t) / CATALOGUE.TAUX
		var enveloppe := pow(1.0 - t, decroissance)
		enveloppe *= minf(1.0, secondes / attaque)
		enveloppe *= minf(1.0, (duree - secondes) / CATALOGUE.SORTIE)
		var valeur := 0.0
		match forme:
			"corps":
				valeur = (sin(phase) + 0.16 * sin(phase * 2.0)) / 1.16
			"verre":
				# Des partiels inharmoniques donnent le verre sans note metallique longue.
				valeur = sin(phase) + sin(phase * 2.71) * 0.28 * exp(-secondes * 26.0)
				valeur += sin(phase * 4.13) * 0.12 * exp(-secondes * 45.0)
				valeur /= 1.4
			"grain", "air":
				var bruit := alea.randf_range(-1.0, 1.0)
				bruit_filtre = lerpf(bruit_filtre, bruit, filtre)
				valeur = bruit_filtre * 2.0 if forme == "grain" else (bruit - bruit_filtre) * 0.65
		signal_sonore[debut + i] += valeur * enveloppe * gain
