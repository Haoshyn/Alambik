shader_type canvas_item;
render_mode unshaded;

uniform float temps_animation = 0.0;
varying vec4 teinte;

void vertex() {
	teinte = COLOR;
}

void fragment() {
	vec4 origine = texture(TEXTURE, UV);
	float chute = 1.0 - smoothstep(0.47, 0.49, UV.y);
	float courant = temps_animation * 2.4;
	vec2 decalage = vec2(sin(UV.y * 290.0 - courant + UV.x * 26.0) * 0.0012,
		sin(UV.y * 390.0 - courant) * 0.0008);
	vec4 eau = texture(TEXTURE, UV + decalage * origine.a * (1.0 - chute));
	// Deux defilements fondus font descendre la peinture sans retour visible.
	float cycle = fract(temps_animation * 0.26);
	vec4 premier = texture(TEXTURE, UV - vec2(0.0, cycle * 0.024));
	vec4 second = texture(TEXTURE, UV - vec2(0.0, fract(cycle + 0.5) * 0.024));
	vec3 ecoulement = mix(second.rgb, premier.rgb, 1.0 - abs(cycle * 2.0 - 1.0));
	float interieur = smoothstep(0.45, 0.85, min(premier.a, second.a));
	eau.rgb = mix(eau.rgb, ecoulement, chute * interieur * 0.85);
	float reflet = pow(0.5 + 0.5 * sin(UV.y * 480.0 - courant * 2.0 + sin(UV.x * 38.0)), 10.0);
	eau.rgb += vec3(0.03, 0.04, 0.045) * reflet * (1.0 - chute);
	eau.a = origine.a;
	COLOR = eau * teinte;
}
