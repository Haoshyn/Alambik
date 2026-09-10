shader_type canvas_item;
uniform float temps;
uniform float amplitude;
float ellipse(vec2 p,vec2 centre,vec2 rayon) {
	return 1.-smoothstep(.4,1.,length((p-centre)/rayon));
}
void fragment() {
	vec2 p = UV;
	float souffle = sin(temps*1.3)*amplitude;
	float tissu = ellipse(UV,vec2(.37,.42),vec2(.20,.11));
	p.x += tissu*souffle*.0009;
	float ciel = ellipse(UV,vec2(.50,.15),vec2(.20,.10));
	p.x += ciel*sin(temps*.17)*.004*amplitude;
	vec3 couleur = texture(TEXTURE,p).rgb;
	float sceptre = ellipse(UV,vec2(.14,.324),vec2(.04,.035));
	float fiole = ellipse(UV,vec2(.43,.49),vec2(.047,.03));
	couleur += amplitude*(.5+.5*sin(temps*2.))*
		(vec3(.15,.03,.21)*sceptre+vec3(.015,.11,.13)*fiole);
	COLOR = vec4(couleur,1.);
}
