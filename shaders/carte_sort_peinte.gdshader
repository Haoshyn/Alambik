shader_type canvas_item;
render_mode unshaded;

uniform vec4 region = vec4(0.0, 0.0, 0.5, 0.333333);
uniform vec2 dimensions = vec2(500.0, 340.0);
uniform float eclat : hint_range(0.0, 1.0) = 0.0;

void fragment() {
	vec2 point = UV * dimensions;
	vec2 distance_bord = abs(point - dimensions * 0.5) - dimensions * 0.5 + vec2(35.0);
	float distance_arrondi = length(max(distance_bord, vec2(0.0))) + min(max(distance_bord.x, distance_bord.y), 0.0) - 29.0;
	float masque = 1.0 - smoothstep(-1.0, 1.0, distance_arrondi);
	// La lecture prend un voile local ; les effets peints restent vifs au bord du glyphe.
	vec2 uv_peinture = region.xy + (UV * 0.98 + 0.01) * region.zw;
	vec3 peinture = texture(TEXTURE, uv_peinture).rgb;
	float lecture = smoothstep(0.22, 0.62, UV.x) * 0.34 + smoothstep(0.36, 0.65, UV.y) * 0.48;
	peinture = mix(peinture, vec3(0.065, 0.055, 0.13), min(lecture, 0.74));
	peinture *= 1.06 + 0.18 * eclat;
	COLOR = vec4(peinture, masque);
}
