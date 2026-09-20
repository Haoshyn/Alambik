shader_type canvas_item;
render_mode unshaded;

varying vec4 teinte;

void vertex() {
	teinte = COLOR;
}

void fragment() {
	vec4 peinture = texture(TEXTURE, UV);
	// Les franges colorees du detourage disparaissent avant les fades du controle.
	// Reserve aux images et panneaux, jamais aux controles qui dessinent du texte.
	float chroma = max(peinture.r, max(peinture.g, peinture.b)) - min(peinture.r, min(peinture.g, peinture.b));
	float couverture = smoothstep(0.14, 0.9, peinture.a);
	peinture.a = mix(peinture.a, couverture, smoothstep(0.02, 0.08, chroma));
	COLOR = peinture * teinte;
}
