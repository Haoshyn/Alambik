shader_type canvas_item;

void fragment() {
    vec4 portrait = texture(TEXTURE, UV) * COLOR;
    float luminance = dot(portrait.rgb, vec3(0.2126, 0.7152, 0.0722));
    portrait.rgb = mix(vec3(luminance), portrait.rgb, 0.66);
    COLOR = portrait;
}
