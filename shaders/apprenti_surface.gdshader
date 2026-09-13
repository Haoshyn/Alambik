shader_type spatial;
render_mode unshaded;

uniform vec4 teinte : source_color = vec4(1.0);
uniform float metal = 0.0;
uniform float rugosite = 0.7;

// Un eclairage de figurine continu garde le galbe sur le profil mobile.
// Les creux sont fournis par l'occlusion de sommets du modele, pas un contour noir.
void fragment() {
    vec3 n = normalize((INV_VIEW_MATRIX * vec4(NORMAL,0.0)).xyz);
    vec3 vue = normalize((INV_VIEW_MATRIX * vec4(VIEW,0.0)).xyz);
    vec3 cle = normalize(vec3(-0.5,0.8,0.65));
    float diffus = smoothstep(-0.65,1.0,dot(n,cle));
    vec3 ambiance = mix(vec3(0.69,0.70,0.82),vec3(1.0,0.97,0.91),diffus);
    vec3 couleur = teinte.rgb * COLOR.rgb * ambiance;
    vec3 reflet = normalize(cle+vue);
    float brillance = pow(max(dot(n,reflet),0.0),mix(70.0,12.0,rugosite));
    float intensite = mix(0.14,0.025,rugosite)+metal*0.18;
    couleur += brillance*intensite*mix(vec3(1.0),teinte.rgb,metal);
    float bord = pow(1.0-max(dot(n,vue),0.0),3.0)*max(n.y,0.0);
    ALBEDO = couleur+bord*0.035;
}
