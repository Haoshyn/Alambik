shader_type canvas_item;
render_mode unshaded;

uniform float temps_animation = 0.0;
uniform float vitesse_boucle = 1.6;
uniform float ecoulement_px = 4.5;
uniform float vitesse_ecoulement = 7.2;
varying vec4 teinte;

void vertex() {
	teinte = COLOR;
}

void fragment() {
	float phase = mod(temps_animation * vitesse_boucle, 4.0);
	float actuel = floor(phase);
	float suivant = mod(actuel + 1.0, 4.0);
	float fondu = smoothstep(0.0, 1.0, fract(phase));
	vec2 uv_actuel = vec2((actuel * 68.0 + 2.0 + UV.x * 64.0) / 272.0, UV.y);
	vec2 uv_suivant = vec2((suivant * 68.0 + 2.0 + UV.x * 64.0) / 272.0, UV.y);
	vec4 fixe = mix(texture(TEXTURE, uv_actuel), texture(TEXTURE, uv_suivant), fondu);
	// Seul le detail interieur descend, l'alpha peint conserve les rives de la chute.
	float interieur = smoothstep(0.05, 0.3, UV.y) * (1.0 - smoothstep(0.72, 0.98, UV.y));
	float phase_chute = UV.y * 40.0 + UV.x * 8.0;
	float courant = (sin(phase_chute - temps_animation * vitesse_ecoulement) - sin(phase_chute))
		* ecoulement_px * TEXTURE_PIXEL_SIZE.y * interieur;
	uv_actuel.y = clamp(uv_actuel.y + courant, 0.0, 1.0);
	uv_suivant.y = clamp(uv_suivant.y + courant, 0.0, 1.0);
	vec3 eau = mix(texture(TEXTURE, uv_actuel).rgb, texture(TEXTURE, uv_suivant).rgb, fondu);
	COLOR = vec4(eau, fixe.a) * teinte;
}
