shader_type spatial;
render_mode unshaded, blend_mix, cull_disabled, depth_draw_never;
uniform float mouvement = 1.;
void fragment() {
    vec2 p = UV * 2. - 1.;
    float d = length(p);
    float angle = atan(p.y,p.x);
    float t = TIME * mouvement;
    float bord = smoothstep(.72,.91,d);
    float arc = pow(max(0.,sin(angle*2.-t*1.3+d*4.)),10.) * smoothstep(.45,.85,d);
    vec3 fond = mix(vec3(.018,.075,.17),vec3(.04,.42,.52),smoothstep(.1,.85,d));
    ALBEDO = fond + vec3(.18,.52,.50)*bord + vec3(.28,.55,.48)*arc*.45;
    ALPHA = (1.-smoothstep(.94,1.,d))*.96;
}
