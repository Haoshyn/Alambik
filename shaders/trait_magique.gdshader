shader_type spatial;
render_mode unshaded, blend_mix, cull_disabled, depth_draw_never;
uniform vec4 teinte : source_color = vec4(.67,.36,1.,1.);
uniform bool hostile = false;
uniform bool reduit = false;
void fragment() {
	vec2 p = UV * 2. - 1.;
	float d = hostile ? length(p) : length(p * vec2(1.15,.9));
	float coque = 1. - smoothstep(.68,.76,d);
	float corps = 1. - smoothstep(.49,.56,d);
	float coeur = 1. - smoothstep(.19,.29,length(p-vec2(-.07,-.08)));
	float halo = (1.-smoothstep(.65,1.,d)) * (reduit ? .0 : .20);
	// Un contour opaque conserve le danger sur les sols clairs.
	vec3 contour = hostile ? vec3(.19,.012,.065) : vec3(.10,.035,.25);
	ALBEDO = mix(mix(contour,teinte.rgb,corps),vec3(1.,.94,.72),coeur);
	ALPHA = max(coque,halo);
}
