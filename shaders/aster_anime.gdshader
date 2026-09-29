shader_type spatial;
render_mode unshaded, cull_disabled;
uniform sampler2D texture_base : source_color, filter_linear_mipmap;
uniform bool utiliser_texture = false;
uniform bool couleur_sommets = false;
uniform vec4 couleur_base : source_color = vec4(1.0);
uniform vec3 direction_lumiere = vec3(-0.4,0.7,0.75);
uniform vec3 couleur_ombre = vec3(0.55,0.63,0.79);
uniform float visage = 0.0;
uniform float metal = 0.0;
uniform float emission = 0.0;
uniform vec3 couleur_emission : source_color = vec3(0.0);
varying vec3 normale_monde;
varying vec3 position_monde;
void vertex() {
 normale_monde = MODEL_NORMAL_MATRIX * NORMAL;
 position_monde = (MODEL_MATRIX * vec4(VERTEX,1.0)).xyz;
}
void fragment() {
 vec3 couleur=couleur_base.rgb;
 if(utiliser_texture)couleur*=texture(texture_base,UV).rgb;
 if(couleur_sommets)couleur*=COLOR.rgb;
 vec3 normale=normalize(normale_monde);
 float ndl=dot(normale,normalize(direction_lumiere));
 float bande=smoothstep(-0.06,0.10,ndl);
 vec3 eclairage=mix(couleur_ombre,vec3(1.0),bande);
 eclairage=mix(eclairage,vec3(1.0),visage);
 vec3 v=normalize(CAMERA_POSITION_WORLD-position_monde);
 float bord=pow(1.0-max(dot(normale,v),0.0),4.0)*max(normale.x*.5+.5,0.0);
 float reflet=pow(max(dot(normale,normalize(v+normalize(direction_lumiere))),0.0),36.0);
 ALBEDO=couleur*eclairage+vec3(.20,.28,.36)*bord*.16;
 ALBEDO+=vec3(.85,.72,.48)*reflet*metal*.60;
 EMISSION=couleur_emission*emission*.2;
}
