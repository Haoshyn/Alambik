shader_type canvas_item;
render_mode unshaded;

uniform sampler2D masque_eau : filter_linear_mipmap, repeat_disable;
uniform float temps_animation = 0.0;
uniform vec2 amplitude_px = vec2(6.5, 2.6);
uniform float vitesse_eau = 2.4;
uniform float force_reflets = 0.10;
varying vec4 teinte;

void vertex() {
	teinte = COLOR;
}

void fragment() {
	vec4 fixe = texture(TEXTURE, UV);
	float masque = texture(masque_eau, UV).r;
	float interieur = smoothstep(0.18, 0.82, masque);
	float temps = temps_animation * vitesse_eau;
	// Des ondes larges restent lisibles dans la petite surface du lac sur mobile.
	float phase_x = UV.y * 42.0 + UV.x * 12.0;
	float phase_y = UV.x * 30.0 + UV.y * 18.0;
	vec2 decalage = vec2(
		(sin(phase_x + temps * 0.95) - sin(phase_x)),
		(sin(phase_y - temps * 0.73) - sin(phase_y))
	) * amplitude_px * TEXTURE_PIXEL_SIZE * interieur;
	vec3 reflet = texture(TEXTURE, clamp(UV + decalage, vec2(0.0), vec2(1.0))).rgb;
	float phase_large = UV.y * 64.0 + sin(UV.x * 18.0) * 0.65;
	float phase_fine = UV.y * 114.0 - UV.x * 7.0;
	float crete = smoothstep(0.35, 1.0, sin(phase_large - temps * 1.4));
	float crete_repos = smoothstep(0.35, 1.0, sin(phase_large));
	float ridules = ((crete - crete_repos) * 0.7
		+ (sin(phase_fine - temps * 0.95) - sin(phase_fine)) * 0.3) * force_reflets;
	reflet += vec3(0.8, 0.91, 1.0) * ridules * interieur;
	COLOR = vec4(reflet, fixe.a * masque) * teinte;
}
