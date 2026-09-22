shader_type canvas_item;
render_mode unshaded;

uniform float intensite : hint_range(0.0, 1.0) = 1.0;

void fragment() {
	vec4 couleur = texture(TEXTURE, UV);
	float clarte = dot(couleur.rgb, vec3(0.2126, 0.7152, 0.0722));
	float couronnes = max(
		(1.0 - smoothstep(0.22, 0.38, UV.x)) * (1.0 - smoothstep(0.13, 0.28, UV.y)),
		smoothstep(0.64, 0.78, UV.x) * (1.0 - smoothstep(0.14, 0.31, UV.y))
	);
	float feuilles = couronnes
		* (1.0 - smoothstep(0.13, 0.31, couleur.b - couleur.g))
		* (1.0 - smoothstep(0.61, 0.78, clarte));
	float sol = smoothstep(0.52, 0.60, UV.y) * (1.0 - smoothstep(0.94, 1.0, UV.y));
	float herbe = sol
		* smoothstep(0.01, 0.10, couleur.g - couleur.b)
		* smoothstep(0.30, 0.45, clarte)
		* (1.0 - smoothstep(0.81, 0.90, clarte));

	float rafale = pow(max(sin(TIME * 0.42 - UV.x * 2.5), 0.0), 14.0);
	float souffle = 0.24 + 0.12 * sin(TIME * 0.67 + UV.x * 13.0)
		+ 0.09 * sin(TIME * 1.13 + UV.y * 19.0) + rafale * 0.55;
	vec2 decale = vec2(
		sin(TIME * 0.9 + UV.y * 17.0 + UV.x * 8.0) * 0.0030 * souffle,
		cos(TIME * 0.72 + UV.x * 21.0) * 0.0008 * souffle
	);
	float vegetation = clamp(feuilles + herbe, 0.0, 1.0) * intensite;
	couleur = mix(couleur, texture(TEXTURE, UV + decale), vegetation);

	float eau = smoothstep(0.445, 0.462, UV.y) * (1.0 - smoothstep(0.510, 0.530, UV.y));
	eau *= smoothstep(0.27, 0.35, UV.x) * (1.0 - smoothstep(0.67, 0.76, UV.x));
	float reflet = pow(0.5 + 0.5 * sin(UV.y * 165.0 + TIME * 1.1 + UV.x * 17.0), 10.0);
	couleur.rgb += vec3(0.012, 0.018, 0.025) * reflet * eau * intensite;
	COLOR = couleur;
}
