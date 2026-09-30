shader_type canvas_item;
render_mode unshaded;

uniform sampler2D masque_vent : filter_linear, repeat_disable;
uniform float temps_animation = 0.0;
uniform vec2 origine_peinture = vec2(0.0);
uniform float amplitude_px = 0.0;
uniform float vitesse_vent = 1.0;
varying vec4 teinte;

void vertex() {
	teinte = COLOR;
}

void fragment() {
	float souplesse = texture(masque_vent, UV).r;
	vec4 peinture = texture(TEXTURE, UV);
	if (souplesse > 0.002) {
		vec2 point = origine_peinture + UV / TEXTURE_PIXEL_SIZE;
		float temps = temps_animation * vitesse_vent;
		// Le meme souffle traverse les calques ; les petits details restent desynchronises.
		float phase = point.x * 0.012 + point.y * 0.006;
		float rafale = 0.72 * (sin(temps + phase) - sin(phase))
			+ 0.28 * (sin(temps * 0.47 + phase * 1.7) - sin(phase * 1.7));
		float phase_feuille = point.x * 0.055 + point.y * 0.04;
		float fremissement = sin(temps * 2.3 + phase_feuille) - sin(phase_feuille);
		float amplitude = souplesse * amplitude_px;
		vec2 deplacement = vec2(rafale + fremissement * 0.07, rafale * 0.22) * amplitude;
		vec2 uv_mobile = clamp(UV + deplacement * TEXTURE_PIXEL_SIZE,
			TEXTURE_PIXEL_SIZE * 0.5, vec2(1.0) - TEXTURE_PIXEL_SIZE * 0.5);
		// Une feuille voisine ne doit jamais entrainer un pixel de pierre ou de bois.
		float zone_source = texture(masque_vent, uv_mobile).r;
		float protection = smoothstep(0.0, 0.12, min(souplesse, zone_source));
		peinture = mix(peinture, texture(TEXTURE, uv_mobile), protection);
	}
	COLOR = peinture * teinte;
}
