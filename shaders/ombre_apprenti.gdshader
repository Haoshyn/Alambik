shader_type spatial;
render_mode unshaded, depth_draw_never, cull_disabled;
void fragment() {
    float rayon = length((UV-0.5)*2.0);
    ALBEDO = vec3(0.12,0.075,0.12);
    ALPHA = (1.0-smoothstep(0.15,1.0,rayon))*0.20;
}
