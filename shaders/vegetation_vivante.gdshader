shader_type canvas_item;
render_mode unshaded;

uniform float temps_animation = 0.0;
varying vec4 teinte;

void vertex() {
	teinte = COLOR;
}

void fragment() {
	vec4 origine = texture(TEXTURE, UV);
	float feuilles = smoothstep(-0.02, 0.09, origine.b - origine.r);
	float cime = 1.0 - smoothstep(0.23, 0.38, UV.y);
	float sol = smoothstep(0.70, 0.84, UV.y);
	float attache = sin(clamp(UV.x, 0.0, 1.0) * 3.14159);
	float vent = sin(temps_animation * 0.85 + UV.y * 11.0) + 0.38 * sin(temps_animation * 1.47 + UV.x * 17.0);
	vec2 decalage = vec2(vent * 0.007, sin(temps_animation * 0.72 + UV.x * 14.0) * 0.0018);
	// Les troncs, les rochers et les attaches aux bords portent le feuillage.
	decalage *= (cime * attache + sol * 0.55) * feuilles;
	COLOR = texture(TEXTURE, clamp(UV + decalage, vec2(0.001), vec2(0.999))) * teinte;
}
