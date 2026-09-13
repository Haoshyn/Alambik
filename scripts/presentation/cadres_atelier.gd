class_name CadresAtelier
extends RefCounted

# Neuf tranches : les gravures gardent leur taille sur les ecrans etires.
static func creer(fond: Color, bord: Color, rond := false) -> StyleBoxTexture:
	var haut := fond.lightened(0.14).to_html(false)
	var bas := fond.darkened(0.13).to_html(false)
	var cuivre := bord.to_html(false)
	var rayon := 108 if rond else 22
	var svg := '''<svg xmlns="http://www.w3.org/2000/svg" width="256" height="256" viewBox="0 0 256 256">
<defs><linearGradient id="papier" x2="0" y2="1"><stop stop-color="#%s"/><stop offset=".48" stop-color="#%s"/><stop offset="1" stop-color="#%s"/></linearGradient>
<linearGradient id="metal" x2=".3" y2="1"><stop stop-color="#fff1cc"/><stop offset=".36" stop-color="#%s"/><stop offset=".66" stop-color="#f7d5a0"/><stop offset="1" stop-color="#805337"/></linearGradient></defs>
<rect x="7" y="11" width="242" height="240" rx="%d" fill="#281632" opacity=".22"/>
<rect x="6" y="5" width="244" height="244" rx="%d" fill="url(#metal)"/>
<rect x="11" y="10" width="234" height="234" rx="%d" fill="url(#papier)" stroke="#fff2ce" stroke-width="2"/>
<rect x="17" y="16" width="222" height="222" rx="%d" fill="none" stroke="#%s" stroke-opacity=".5"/>
<path d="M30 20 H220" fill="none" stroke="#fff9e5" stroke-width="2" opacity=".6"/>
%s</svg>''' % [haut,fond.to_html(false),bas,cuivre,rayon,rayon,rayon-4,rayon-8,cuivre,
		'' if rond else '<g fill="none" stroke="#'+cuivre+'" stroke-width="1.5" opacity=".7"><path d="M19 42 V29 Q29 29 29 19 H42 M214 19 H227 Q227 29 237 29 V42 M19 214 V227 Q29 227 29 237 H42 M214 237 H227 Q227 227 237 227 V214"/></g><g fill="#'+cuivre+'"><path d="M29 31 l4 5 -4 5 -4 -5z M227 31 l4 5 -4 5 -4 -5z M29 215 l4 5 -4 5 -4 -5z M227 215 l4 5 -4 5 -4 -5z"/></g>']
	var image := Image.new()
	image.load_svg_from_string(svg)
	var style := StyleBoxTexture.new()
	style.texture = ImageTexture.create_from_image(image)
	for cote in [SIDE_LEFT,SIDE_TOP,SIDE_RIGHT,SIDE_BOTTOM]:
		style.set_texture_margin(cote,110 if rond else 44)
		style.set_content_margin(cote,20 if rond else 28)
	style.modulate_color.a = fond.a
	return style
