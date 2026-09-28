shader_type spatial;
render_mode cull_back;

uniform vec4 teinte : source_color = vec4(.3, .65, .7, 1.0);
uniform float temps = 0.0;
varying vec3 position_locale;

void vertex() {
    position_locale = VERTEX;
}

void fragment() {
    // Un courant lent dans les appareils et les canaux hors de l'aire de combat.
    float onde = sin(position_locale.z * 5.0 + position_locale.x * 3.0 - temps * .8);
    float reflet = smoothstep(.80, 1.0, onde) * .10;
    ALBEDO = teinte.rgb + vec3(reflet);
    EMISSION = teinte.rgb * .12;
    ROUGHNESS = .38;
}
