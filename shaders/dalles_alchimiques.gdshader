shader_type spatial;
render_mode diffuse_burley;
uniform vec4 pierre : source_color = vec4(0.91,0.83,0.67,1.0);
uniform vec4 joint : source_color = vec4(0.72,0.67,0.55,1.0);
uniform int motif = 0;
uniform sampler2D calcaire : source_color, filter_linear_mipmap, repeat_enable;
varying vec3 position_monde;
float hasard(vec2 p) { return fract(sin(dot(p,vec2(127.1,311.7)))*43758.5453); }
void vertex() { position_monde = (MODEL_MATRIX * vec4(VERTEX,1.0)).xyz; }
void fragment() {
    vec2 p = position_monde.xz;
    vec2 cellule = p / vec2(1.8,1.6);
    float bord = 0.0;
    if (motif == 1) {
        vec2 e = vec2(1.0,1.73205);
        vec2 a = mod(p,e)-e*.5;
        vec2 b = mod(p-e*.5,e)-e*.5;
        vec2 h = dot(a,a)<dot(b,b) ? a : b;
        bord = .5-max(abs(h.x),dot(abs(h),vec2(.5,.866025)));
        cellule = p-h;
    } else {
        if (motif == 2) cellule = mat2(vec2(.707,-.707),vec2(.707,.707))*cellule;
        if (motif == 3) cellule = vec2(length(p)*.6,atan(p.y,p.x)*3.82);
        if (motif == 4) cellule *= .78;
        if (motif == 0) cellule.x += mod(floor(cellule.y),2.0)*.5;
        vec2 q = min(fract(cellule),1.0-fract(cellule));
        bord = min(q.x,q.y);
    }
    float aa = max(fwidth(bord),.001);
    float dalle = smoothstep(.014-aa,.014+aa,bord);
    float nuance = hasard(floor(cellule));
    vec3 couleur = pierre.rgb*(.97+nuance*.06);
    float grain = dot(texture(calcaire,p*.23).rgb,vec3(.333333));
    couleur *= mix(.92,1.06,grain);
    float biseau = smoothstep(.016,.045,bord);
    couleur *= .94+.06*biseau;
    ALBEDO = mix(joint.rgb,couleur,dalle);
    ROUGHNESS = .9;
}
