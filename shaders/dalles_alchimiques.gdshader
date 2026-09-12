shader_type spatial;
render_mode diffuse_burley;

uniform vec4 pierre : source_color = vec4(0.66, 0.71, 0.63, 1.0);
uniform vec4 joint : source_color = vec4(0.26, 0.36, 0.32, 1.0);
varying vec3 position_monde;

float hasard(vec2 p) { return fract(sin(dot(p, vec2(127.1,311.7))) * 43758.5453); }
float hauteur(vec2 p) {
    vec2 cellule = p / 1.65;
    cellule.x += mod(floor(cellule.y), 2.0) * 0.5;
    vec2 q = abs(fract(cellule) - 0.5) - vec2(0.44);
    float bord = length(max(q, vec2(0.0))) + min(max(q.x,q.y),0.0) - 0.052;
    return 1.0 - smoothstep(-0.018, 0.006, bord);
}
void vertex() { position_monde = (MODEL_MATRIX * vec4(VERTEX,1.0)).xyz; }
void fragment() {
    vec2 p = position_monde.xz;
    vec2 cellule = p / 1.65;
    cellule.x += mod(floor(cellule.y), 2.0) * 0.5;
    float h = hauteur(p);
    float nuance = hasard(floor(cellule));
    vec3 dalle = pierre.rgb * (0.96 + nuance * 0.07);
    ALBEDO = mix(joint.rgb, dalle, h);
    float dx = (hauteur(p+vec2(0.012,0.0))-hauteur(p-vec2(0.012,0.0))) * 0.7;
    float dz = (hauteur(p+vec2(0.0,0.012))-hauteur(p-vec2(0.0,0.012))) * 0.7;
    NORMAL = normalize((VIEW_MATRIX * vec4(-dx,1.0,-dz,0.0)).xyz);
    ROUGHNESS = 0.88;
}
