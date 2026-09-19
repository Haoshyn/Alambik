shader_type spatial;
render_mode specular_schlick_ggx;

uniform sampler2D couleur : source_color, filter_linear_mipmap_anisotropic;
uniform sampler2D normales : hint_normal, filter_linear_mipmap_anisotropic;
uniform sampler2D rugosite : filter_linear_mipmap_anisotropic;

void fragment() {
	vec3 base = texture(couleur, UV).rgb;
	float luminance = dot(base, vec3(.2126, .7152, .0722));
	ALBEDO = mix(vec3(luminance), base, .94);
	ROUGHNESS = clamp(texture(rugosite, UV).g, .46, .92);
	METALLIC = 0.;
	SPECULAR = .20;
	NORMAL_MAP = texture(normales, UV).rgb;
	NORMAL_MAP_DEPTH = .30;
}

void light() {
	// La texture contient une lumiere peinte : une diffusion douce evite un second cerne sombre.
	float diffus = smoothstep(-.45, 1., dot(NORMAL, LIGHT));
	DIFFUSE_LIGHT += ALBEDO * LIGHT_COLOR * ATTENUATION * diffus / 3.14159265;
	vec3 demi_angle = normalize(LIGHT + VIEW);
	float reflet = pow(max(dot(NORMAL, demi_angle), 0.), mix(48., 12., ROUGHNESS));
	SPECULAR_LIGHT += LIGHT_COLOR * ATTENUATION * reflet * .035 * (1. - ROUGHNESS);
}
