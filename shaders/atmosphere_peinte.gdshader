shader_type canvas_item;
render_mode unshaded;

uniform vec2 case_atlas = vec2(0.0);
uniform float temps_animation = 0.0;
varying vec4 teinte;

void vertex() {
	teinte = COLOR;
}

void fragment() {
	vec2 point = UV;
	point.x += sin(UV.y * 10.0 + temps_animation * 0.34) * 0.008 * sin(UV.x * 3.14159);
	vec4 nuage = texture(TEXTURE, clamp((point + case_atlas) * 0.5, case_atlas * 0.5 + 0.001, (case_atlas + 1.0) * 0.5 - 0.001));
	// Les marges evitent que les sprites voisins de l'atlas apparaissent.
	vec2 bord = smoothstep(vec2(0.0), vec2(0.10), UV) * (1.0 - smoothstep(vec2(0.90), vec2(1.0), UV));
	nuage.a *= bord.x * bord.y;
	COLOR = nuage * teinte;
}
