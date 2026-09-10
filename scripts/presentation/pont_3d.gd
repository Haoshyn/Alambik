class_name Pont3D
extends RefCounted

const ECHELLE := 0.01
const INCLINAISON := 48.0

# L'anamorphose du plan annule le raccourcissement orthographique : un cercle
# de collision reste un cercle a l'ecran et le joystick conserve ses directions.
static func vers_monde(point: Vector2, hauteur := 0.0, inclinaison := INCLINAISON) -> Vector3:
	return Vector3(point.x * ECHELLE, hauteur, point.y * ECHELLE / sin(deg_to_rad(inclinaison)))

static func vers_logique(point: Vector3, inclinaison := INCLINAISON) -> Vector2:
	return Vector2(point.x, point.z * sin(deg_to_rad(inclinaison))) / ECHELLE

static func cadrer(camera: Camera3D, taille: Vector2, canevas := Transform2D.IDENTITY) -> void:
	var inverse := canevas.affine_inverse()
	var centre := vers_monde(inverse * (taille * 0.5))
	camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	camera.keep_aspect = Camera3D.KEEP_WIDTH
	camera.size = taille.x * ECHELLE / canevas.x.length()
	camera.position = centre + Vector3(0.0, sin(deg_to_rad(INCLINAISON)), cos(deg_to_rad(INCLINAISON))) * 40.0
	camera.look_at(centre, Vector3.UP)
