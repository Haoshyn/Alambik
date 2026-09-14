shader_type spatial;
render_mode unshaded, cull_disabled, blend_mix, depth_draw_never, shadows_disabled;
uniform vec4 teinte : source_color = vec4(0.65, 0.42, 1.0, 1.0);
void fragment() {
	float rayon = length(UV - vec2(0.5)) * 2.0;
	float bord = smoothstep(0.90, 0.94, rayon) * (1.0 - smoothstep(0.97, 1.0, rayon));
	float interieur = (1.0 - smoothstep(0.93, 1.0, rayon)) * 0.10;
	ALBEDO = teinte.rgb;
	ALPHA = max(bord * 0.85, interieur);
}
