shader_type canvas_item;
render_mode unshaded;

uniform float temps_animation = 0.0;
varying vec4 teinte;

void vertex() {
	teinte = COLOR;
}

void fragment() {
	vec4 origine = texture(TEXTURE, UV);
	float prairie = smoothstep(0.53, 0.59, UV.y) * (1.0 - smoothstep(0.90, 1.0, UV.y));
	prairie *= smoothstep(0.01, 0.09, origine.g - origine.b);
	vec2 vent = vec2(sin(UV.y * 75.0 + UV.x * 11.0 - temps_animation * 1.4) * 0.0019, 0.0);
	vec4 paysage = texture(TEXTURE, UV + vent * prairie);
	float rune = smoothstep(0.15, 0.40, min(origine.g, origine.b) - origine.r);
	float respiration = 0.5 + 0.5 * sin(temps_animation * 1.05 + UV.y * 12.0);
	paysage.rgb += vec3(0.015, 0.065, 0.075) * rune * respiration;
	COLOR = paysage * teinte;
}
