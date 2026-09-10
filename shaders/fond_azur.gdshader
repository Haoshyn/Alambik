shader_type canvas_item;
void fragment(){
 vec2 p=UV;
 float lumiere=exp(-length((p-vec2(.5,.05))*vec2(1.,.7))*2.8);
 vec3 couleur=mix(vec3(.021,.071,.097),vec3(.068,.20,.25),lumiere*.65);
 float grain=fract(sin(dot(FRAGCOORD.xy,vec2(12.9898,78.233)))*43758.5453);
 couleur+=(grain-.5)*.006;
 COLOR=vec4(couleur,1.);
}
