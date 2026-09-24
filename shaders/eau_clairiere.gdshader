shader_type canvas_item;
render_mode unshaded;

uniform sampler2D masque_eau : filter_linear_mipmap, repeat_disable;
uniform float temps_animation = 0.0;
varying vec4 teinte;

void vertex() {
	teinte = COLOR;
}

void fragment() {
	vec4 fixe = texture(TEXTURE, UV);
	float masque = texture(masque_eau, UV).r;
	float interieur = smoothstep(0.18, 0.82, masque);
	float phase_x = UV.y * 112.0 + UV.x * 17.0;
	float phase_y = UV.x * 48.0 + UV.y * 71.0;
	vec2 decalage = vec2(
		(sin(phase_x + temps_animation * 0.95) - sin(phase_x)) * 0.0025,
		(sin(phase_y + temps_animation * 0.73) - sin(phase_y)) * 0.0065
	) * interieur;
	vec3 reflet = texture(TEXTURE, clamp(UV + decalage, vec2(0.0), vec2(1.0))).rgb;
	float phase_large = UV.y * 135.0 + UV.x * 11.0;
	float phase_fine = UV.y * 260.0 - UV.x * 9.0;
	float ridules = (sin(phase_large + temps_animation * 1.25) - sin(phase_large)) * 0.025
		+ (sin(phase_fine - temps_animation * 0.86) - sin(phase_fine)) * 0.015;
	reflet += vec3(0.8, 0.91, 1.0) * ridules * interieur;
	COLOR = vec4(reflet, fixe.a * masque) * teinte;
}
