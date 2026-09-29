shader_type spatial;
render_mode unshaded, cull_front;
uniform float epaisseur = 0.00075;
uniform vec4 encre : source_color = vec4(0.095,0.13,0.22,1.0);
void vertex() { VERTEX += NORMAL * epaisseur; }
void fragment() { ALBEDO = encre.rgb; }
