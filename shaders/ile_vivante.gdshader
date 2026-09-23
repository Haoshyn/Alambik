shader_type canvas_item;
render_mode unshaded;

uniform float temps_animation = 0.0;
uniform int monde = 0;
uniform vec4 chutes[6];
uniform vec4 bassins[3];
uniform vec4 feuillages[4];
uniform vec4 tissus[2];
uniform vec4 portail;
uniform vec4 accent : source_color = vec4(0.5, 0.9, 1.0, 1.0);
varying vec4 teinte;

void vertex() {
	teinte = COLOR;
}

float zone(vec2 point, vec4 limites) {
	if (limites.z <= limites.x || limites.w <= limites.y) { return 0.0; }
	vec2 marge = min(vec2(0.012), (limites.zw - limites.xy) * 0.25);
	vec2 masque = smoothstep(limites.xy, limites.xy + marge, point)
		* (1.0 - smoothstep(limites.zw - marge, limites.zw, point));
	return masque.x * masque.y;
}

float matiere_fluide(vec3 couleur) {
	if (monde == 1) { return smoothstep(0.07, 0.22, couleur.r - couleur.b) * smoothstep(0.55, 0.78, couleur.r); }
	if (monde == 3) { return smoothstep(0.025, 0.12, couleur.b - couleur.r) * smoothstep(0.5, 0.72, couleur.g); }
	if (monde == 4) { return smoothstep(0.20, 0.48, couleur.r - couleur.b) * smoothstep(0.50, 0.85, couleur.r); }
	return smoothstep(0.035, 0.16, min(couleur.g, couleur.b) - couleur.r);
}

void fragment() {
	vec4 origine = texture(TEXTURE, UV);
	float chute = 0.0;
	float bassin = 0.0;
	float feuille = 0.0;
	vec2 decalage = vec2(0.0);
	for (int i = 0; i < 6; i++) { chute = max(chute, zone(UV, chutes[i])); }
	for (int i = 0; i < 3; i++) { bassin = max(bassin, zone(UV, bassins[i])); }
	for (int i = 0; i < 4; i++) { feuille = max(feuille, zone(UV, feuillages[i])); }
	float fluide = matiere_fluide(origine.rgb);
	chute *= fluide;
	bassin *= fluide;
	float vitesse = monde == 1 || monde == 4 ? 1.6 : 3.4;
	float courant = UV.y * 160.0 - temps_animation * vitesse;
	decalage += vec2(sin(UV.y * 330.0 - temps_animation * 2.0) * 0.0015, sin(UV.x * 100.0 + temps_animation) * 0.0007) * bassin;
	float couleur_feuille = monde == 1 ? smoothstep(0.025, 0.10, origine.g - origine.b) : smoothstep(0.03, 0.14, origine.b - origine.g);
	decalage.x += sin(temps_animation * 1.3 + UV.y * 24.0) * 0.0035 * feuille * couleur_feuille;
	for (int i = 0; i < 2; i++) {
		float masque = zone(UV, tissus[i]);
		float attache = clamp((UV.y - tissus[i].y) / max(0.001, tissus[i].w - tissus[i].y), 0.0, 1.0);
		decalage.x += sin(temps_animation * 2.1 + UV.y * 38.0) * 0.0045 * masque * attache;
	}
	float porte = zone(UV, portail);
	decalage.x += sin(UV.y * 100.0 - temps_animation * 1.8) * 0.002 * porte * fluide;
	vec4 couleur = texture(TEXTURE, clamp(UV + decalage * origine.a, vec2(0.001), vec2(0.999)));
	if (chute > 0.01) {
		float cycle = fract(temps_animation * vitesse * 0.07);
		vec4 premier = texture(TEXTURE, UV - vec2(0.0, cycle * 0.028));
		vec4 second = texture(TEXTURE, UV - vec2(0.0, fract(cycle + 0.5) * 0.028));
		float interieur = min(matiere_fluide(premier.rgb) * premier.a, matiere_fluide(second.rgb) * second.a);
		vec3 ecoulement = mix(second.rgb, premier.rgb, 1.0 - abs(cycle * 2.0 - 1.0));
		couleur.rgb = mix(couleur.rgb, ecoulement, chute * interieur * 0.78);
	}
	float eclat = pow(0.5 + 0.5 * sin(courant * 2.4 + UV.x * 63.0), 6.0);
	couleur.rgb += accent.rgb * eclat * (chute * 0.025 + bassin * 0.035);
	couleur.rgb += accent.rgb * porte * fluide * (0.06 + 0.05 * sin(temps_animation * 1.7));
	if (monde == 4) {
		float chaleur = 0.035 * (sin(temps_animation * 3.7 + UV.y * 22.0) + sin(temps_animation * 6.1)) * fluide;
		couleur.rgb += accent.rgb * chaleur;
	}
	// L'alpha peint conserve les silhouettes des rochers et les trous des arches.
	couleur.a = origine.a;
	COLOR = couleur * teinte;
}
