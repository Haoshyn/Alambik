shader_type canvas_item;


uniform float temps;
uniform float amplitude;

float ellipse(vec2 p,vec2 c,vec2 r){float d=length((p-c)/r);return 1.-smoothstep(.50,1.,d);}
float disque(vec2 p,vec2 c,float r){return 1.-smoothstep(r*.4,r,distance(p*vec2(1.,1.5),c*vec2(1.,1.5)));}
void fragment(){
 vec2 uv=UV;
 vec2 p=uv;
 float souffle=sin(temps*2.*PI/4.8);
 float lent=sin(temps*2.*PI/14.4);
 float torse=ellipse(p,vec2(.375,.337),vec2(.195,.145));
 float tete=ellipse(p,vec2(.376,.198),vec2(.148,.076));
 float livre=ellipse(p,vec2(.595,.326),vec2(.133,.099));
 float echarpe=ellipse(p,vec2(.372,.269),vec2(.12,.046));
 float pan=ellipse(p,vec2(.456,.638),vec2(.087,.12));
 float cape=ellipse(p,vec2(.20,.594),vec2(.105,.129));
 float interfaceDroite=step(.49,p.x)*smoothstep(.535,.547,p.y);
 float interfaceBasse=smoothstep(.864,.876,p.y);
 float libre=(1.-interfaceDroite)*(1.-interfaceBasse);
 // La poitrine se souleve ; le visage et la main accompagnent la pose en bloc.
 p.y+=amplitude*libre*souffle*(torse*.00125+tete*.00095+livre*.00085);
 p.x-=amplitude*libre*torse*(p.x-.35)*souffle*.004;
 p.x+=amplitude*libre*(echarpe*.0008*sin(temps*2.*PI/7.2)+pan*.00165*lent+cape*.0014*sin(temps*2.*PI/9.6));
 float ciel=ellipse(uv,vec2(.51,.113),vec2(.16,.047));
 p.x+=ciel*.007*sin(temps*2.*PI/28.8)*amplitude;
 float liquide=ellipse(uv,vec2(.871,.444),vec2(.044,.012));
 p.y+=liquide*.0009*sin(temps*2.*PI/3.6+uv.x*90.)*amplitude;
 vec3 couleur=texture(TEXTURE,clamp(p,vec2(.001),vec2(.999))).rgb;
 float coeur=ellipse(uv,vec2(.148,.250),vec2(.038,.027));
 couleur+=vec3(.10,.025,.18)*coeur*(.45+.45*sin(temps*2.*PI/4.8))*amplitude;
 float fiole=ellipse(uv,vec2(.444,.456),vec2(.036,.019));
 couleur+=vec3(.015,.10,.11)*fiole*(.5+.5*sin(temps*2.*PI/7.2))*amplitude;
 // Les bulles restent dans la chambre de verre et disparaissent avant son col.
 for(int i=0;i<4;i++){
  float k=float(i);float phase=fract(temps/3.6+k*.25);
  vec2 c=vec2(.854+k*.012+sin(temps*1.1+k)*.0018,.443-phase*.022);
  float a=sin(phase*PI)*.32*amplitude;
  float d=distance(uv*vec2(1.,1.5),c*vec2(1.,1.5));
  float anneau=(1.-smoothstep(.0004,.0012,abs(d-(.0013+k*.00025))));
  couleur=mix(couleur,vec3(.63,.99,1.),anneau*a);
 }
 // Vapeur fine au-dessus du col, sans brouillard devant les commandes.
 for(int i=0;i<3;i++){
  float k=float(i);float phase=fract(temps/4.8+k/3.);
  vec2 c=vec2(.874+sin(phase*5.+k)*.007,.359-phase*.040);
  float vapeur=ellipse(uv,c,vec2(.003+phase*.006,.008+phase*.010));
  couleur=mix(couleur,vec3(.83,.95,.96),vapeur*sin(phase*PI)*.10*amplitude);
 }
 COLOR=vec4(couleur,1.);
}