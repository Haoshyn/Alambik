shader_type spatial;
render_mode unshaded;

uniform vec4 teinte : source_color = vec4(1.0);
uniform float metal = 0.0;
uniform float rugosite = 0.7;
uniform bool peau = false;
uniform bool oeil = false;
uniform bool tissu = false;
uniform bool cheveux = false;
varying vec3 position_matiere;

void vertex() {
	position_matiere = VERTEX;
}

void fragment() {
	vec3 n = normalize((INV_VIEW_MATRIX * vec4(NORMAL,0.0)).xyz);
	vec3 vue = normalize((INV_VIEW_MATRIX * vec4(VIEW,0.0)).xyz);
	vec3 cle = normalize(vec3(-0.5,0.8,0.65));
	float diffus = smoothstep(-0.5,.9,dot(n,cle));
	// La peau garde une ombre peche ; l'occlusion du chapeau ne la grise plus.
	vec3 ombre = peau ? vec3(.85,.68,.61) : vec3(.67,.66,.80);
	vec3 lumiere = peau ? vec3(1.,.98,.95) : vec3(1.,.97,.94);
	vec3 occlusion = mix(vec3(1.),COLOR.rgb,peau ? .30 : .85);
	vec3 couleur = teinte.rgb * occlusion * mix(ombre,lumiere,diffus);
	if (tissu) {
		// Une trame mate tres legere disparait a distance pour garder la silhouette nette.
		vec2 trame = vec2(position_matiere.x, position_matiere.y + position_matiere.z) * 190.;
		float finesse = 1. - smoothstep(.6, 2., max(fwidth(trame.x), fwidth(trame.y)));
		couleur *= 1. + .018 * sin(trame.x) * sin(trame.y) * finesse;
	}
	if (oeil) {
		// Les reflets sont dessines dans l'iris, independants de l'angle de vue.
		couleur = teinte.rgb * mix(vec3(.91),vec3(1.),diffus);
	} else {
		vec3 reflet = normalize(cle+vue);
		float brillance = pow(max(dot(n,reflet),0.),mix(64.,18.,rugosite));
		float intensite = peau ? .006 : mix(.08,.012,rugosite)+metal*.14;
		if (tissu || cheveux) intensite *= .25;
		couleur += brillance*intensite*mix(vec3(1.),teinte.rgb,metal);
	}
	ALBEDO = couleur;
}
