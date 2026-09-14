shader_type canvas_item;
render_mode unshaded;

uniform vec4 region = vec4(0.0, 0.0, 1.0, 1.0);

void fragment() {
	vec2 local = (UV - region.xy) / region.zw;
	float rayon = length((local - vec2(0.5)) * 2.0);
	COLOR.a *= 1.0 - smoothstep(0.78, 1.0, rayon);
}
