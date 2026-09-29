shader_type canvas_item;
render_mode unshaded;

uniform vec4 cadre = vec4(0.0, 0.0, 1.0, 1.0);
uniform vec4 fond : source_color = vec4(0.12549, 0.145098, 0.454902, 1.0);

void fragment() {
	vec2 uv_image = (UV - cadre.xy) / cadre.zw;
	vec2 bord = clamp(uv_image, vec2(0.0), vec2(1.0));
	float distance_bord = length(uv_image - bord);
	vec4 peinture = texture(TEXTURE, bord);
	// Les bords se prolongent doucement sans etirer le logo ni la fiole.
	float flou = min(distance_bord * 0.75, 0.16);
	vec2 depassement = abs(uv_image - bord);
	vec2 axe = depassement.y >= depassement.x ? vec2(1.0, 0.0) : vec2(0.0, 1.0);
	vec4 prolongement = peinture * 0.28;
	prolongement += texture(TEXTURE, clamp(bord + axe * flou, vec2(0.0), vec2(1.0))) * 0.18;
	prolongement += texture(TEXTURE, clamp(bord - axe * flou, vec2(0.0), vec2(1.0))) * 0.18;
	prolongement += texture(TEXTURE, clamp(bord + axe * flou * 0.5, vec2(0.0), vec2(1.0))) * 0.18;
	prolongement += texture(TEXTURE, clamp(bord - axe * flou * 0.5, vec2(0.0), vec2(1.0))) * 0.18;
	COLOR = mix(prolongement, fond, smoothstep(0.0, 0.14, distance_bord));
}
