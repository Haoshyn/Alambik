class_name DonneesTutoriel
extends RefCounted

const MODE := "tutoriel"
const ARME := "standard"
const MAITRISE := "force"
const ETAGE_AUGMENT := 2
const PV_MULT := 0.70
const DEGATS_MULT := 0.40
const BOSS_PV_MULT := 0.65
const RENCONTRES := [
	[["encrier_rampant"]],
	[["plume_sentinelle"]],
	[["encrier_rampant", "plume_sentinelle"]],
	[["tache_veloce", "encrier_rampant"]],
	[["la_rature"]],
]
const LECONS := {
	1: ["Votre première arme", "Vous êtes alchimiste de niveau 1. La Baguette d’acier est équipée : elle vise et tire quand vous vous arrêtez.\n\nGlissez le pouce dans la moitié basse pour bouger, puis relâchez pour tirer. Sur PC, faites le même geste avec la souris.\n\nCe parcours de cinq étages est séparé de la campagne."],
	2: ["Esquiver, puis riposter", "Déplacez-vous pour éviter les projectiles ; arrêtez-vous entre les attaques pour riposter.\n\nAprès cet étage, choisissez une augmentation : elle renforce cette tentative et disparaît à sa fin. Les maîtrises, elles, restent acquises."],
	3: ["La campagne fait grandir votre compte", "Les salles de campagne rapportent des gouttes pour les maîtrises, de l’XP de compte et des pierres de forge. Les coffres de victoire peuvent donner des bijoux.\n\nAvancer débloque aussi de nouvelles armes, des familiers et certains sorts. Les augmentations choisies pendant une aventure ne sont pas de l’équipement permanent."],
	4: ["Votre atelier et vos paramètres", "La Mine fournit surtout des pierres pour forger armes, bijoux et familiers. Les Épreuves permettent d’obtenir et d’améliorer des capacités, ainsi que des Cœurs de mana.\n\nDepuis Pause → Paramètres, vous pouvez choisir vous-même la musique de combat et celle de l’atelier, régler le volume et réduire les effets visuels. Nous regarderons les commandes des sorts après votre premier sort actif d’épreuve."],
	5: ["Votre premier mini-boss", "Observez ses attaques annoncées, esquivez, puis profitez des ouvertures pour tirer.\n\nLa victoire offre une seule fois juste assez de gouttes pour acheter un premier rang de maîtrise. Vous resterez au niveau de compte 1 et le premier chapitre de campagne restera à découvrir.\n\nLa première Épreuve et la Mine seront accessibles dès votre retour à l’accueil."],
}

static func nombre_salles() -> int:
	return RENCONTRES.size()

static func recompense_gouttes() -> int:
	return ArbreCompetences.cout(MAITRISE, 0)
