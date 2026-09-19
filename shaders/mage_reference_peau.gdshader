shader_type spatial;
render_mode specular_schlick_ggx;

uniform vec4 teinte : source_color = vec4(.95, .65, .47, 1.);

void fragment() {
	// La peau conserve ses joues peintes sans durcir l'occlusion des volumes voisins.
	ALBEDO = teinte.rgb * mix(vec3(1.), COLOR.rgb, .3);
	ROUGHNESS = .68;
	SPECULAR = .16;
}

void light() {
	// Diffusion enveloppante pour un visage doux, meme sous le grand chapeau.
	float diffus = smoothstep(-.65, 1., dot(NORMAL, LIGHT));
	DIFFUSE_LIGHT += ALBEDO * LIGHT_COLOR * ATTENUATION * diffus / 3.14159265;
}
