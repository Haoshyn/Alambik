shader_type spatial;
render_mode diffuse_burley, specular_schlick_ggx;

uniform sampler2D couleur : source_color, filter_linear_mipmap_anisotropic, repeat_enable;
uniform sampler2D normales : hint_normal, filter_linear_mipmap_anisotropic, repeat_enable;

void fragment() {
	vec3 teinte = texture(couleur, UV).rgb;
	// Les broderies dorees captent la lumiere ; le tissu conserve un reflet doux.
	float cuivre = smoothstep(1.25, 1.8, teinte.g / max(teinte.b, 0.015));
	cuivre *= smoothstep(0.24, 0.48, teinte.r) * smoothstep(1.05, 1.4, teinte.r / max(teinte.g, 0.015));
	float tissu = smoothstep(1.0, 1.35, teinte.b / max(teinte.r, 0.015));
	ALBEDO = teinte;
	METALLIC = cuivre * 0.48;
	ROUGHNESS = mix(0.78, 0.36, cuivre);
	SPECULAR = 0.32;
	NORMAL_MAP = texture(normales, UV).rgb;
	NORMAL_MAP_DEPTH = 0.32;
	RIM = tissu * 0.22;
	RIM_TINT = 0.65;
}
