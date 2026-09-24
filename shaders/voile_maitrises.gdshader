shader_type canvas_item;

void fragment() {
	vec2 centre = UV - vec2(0.5, 0.48);
	float bords = smoothstep(0.16, 0.68, length(centre));
	float haut = 1.0 - smoothstep(0.08, 0.54, UV.y);
	float bas = smoothstep(0.50, 1.0, UV.y);
	float opacite = 0.26 + 0.20 * bords + 0.12 * haut + 0.10 * bas;
	COLOR = vec4(mix(vec3(0.055, 0.084, 0.18), vec3(0.035, 0.058, 0.13), bords), opacite);
}
