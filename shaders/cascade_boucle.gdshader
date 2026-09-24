shader_type canvas_item;
render_mode unshaded;

uniform float temps_animation = 0.0;
varying vec4 teinte;

void vertex() {
	teinte = COLOR;
}

void fragment() {
	float phase = mod(temps_animation * 0.8, 4.0);
	float actuel = floor(phase);
	float suivant = mod(actuel + 1.0, 4.0);
	float fondu = smoothstep(0.0, 1.0, fract(phase));
	vec2 uv_actuel = vec2((actuel * 68.0 + 2.0 + UV.x * 64.0) / 272.0, UV.y);
	vec2 uv_suivant = vec2((suivant * 68.0 + 2.0 + UV.x * 64.0) / 272.0, UV.y);
	COLOR = mix(texture(TEXTURE, uv_actuel), texture(TEXTURE, uv_suivant), fondu) * teinte;
}
