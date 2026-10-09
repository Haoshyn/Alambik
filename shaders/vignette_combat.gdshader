shader_type canvas_item;

// Assombrit doucement les bords de l'arene pour concentrer le regard sur le
// centre du combat, sans toucher a la lisibilite des tirs.
uniform vec4 teinte : source_color = vec4(0.07, 0.03, 0.16, 1.0);
uniform float force = 0.5;

void fragment() {
	vec2 centre = UV - vec2(0.5);
	centre.x *= 0.82;
	float distance_centre = length(centre) * 1.41421356;
	float voile = smoothstep(0.42, 1.08, distance_centre);
	COLOR = vec4(teinte.rgb, voile * force);
}
