shader_type spatial;
render_mode unshaded, cull_back;

uniform vec4 teinte : source_color = vec4(.77,.63,1.,1.);
varying vec3 normale_locale;

void vertex() {
	normale_locale = NORMAL;
}

void fragment() {
	vec3 normale = normalize(normale_locale);
	float lumiere = dot(normale, normalize(vec3(-.4,.8,.5)));
	float reflet = smoothstep(.80,.93,lumiere);
	vec3 ombre = teinte.rgb * vec3(.52,.44,.72);
	vec3 corps = mix(ombre,teinte.rgb,smoothstep(-.25,.2,lumiere));
	ALBEDO = mix(corps,vec3(1.,.96,.83),reflet);
}
