"""Iris graphiques cuits sur les yeux existants du mage sculpte."""


def styliser(noeuds, liens, uv, couleur, largeur, hauteur):
    axes=noeuds.new('ShaderNodeSeparateXYZ')
    liens.new(uv,axes.inputs[0])

    def calcul(operation,a,b):
        noeud=noeuds.new('ShaderNodeMath');noeud.operation=operation
        for entree,valeur in zip(noeud.inputs,(a,b)):
            if isinstance(valeur,(int,float)):
                entree.default_value=valeur
            else:
                liens.new(valeur,entree)
        return noeud.outputs[0]

    x=calcul('MULTIPLY',axes.outputs['X'],largeur)
    y=calcul('SUBTRACT',hauteur,calcul('MULTIPLY',axes.outputs['Y'],hauteur))

    def ellipse(cx,cy,rx,ry,douceur=.94):
        dx=calcul('DIVIDE',calcul('SUBTRACT',x,cx),rx)
        dy=calcul('DIVIDE',calcul('SUBTRACT',y,cy),ry)
        distance=calcul('ADD',calcul('MULTIPLY',dx,dx),calcul('MULTIPLY',dy,dy))
        bord=noeuds.new('ShaderNodeMapRange');bord.clamp=True
        liens.new(distance,bord.inputs['Value'])
        bord.inputs['From Min'].default_value=douceur
        bord.inputs['From Max'].default_value=1.
        bord.inputs['To Min'].default_value=1.
        bord.inputs['To Max'].default_value=0.
        return bord.outputs[0]

    def melanger(facteur,fond,teinte):
        mix=noeuds.new('ShaderNodeMixRGB')
        liens.new(facteur,mix.inputs[0])
        if isinstance(fond,tuple):mix.inputs[1].default_value=fond
        else:liens.new(fond,mix.inputs[1])
        if isinstance(teinte,tuple):mix.inputs[2].default_value=teinte
        else:liens.new(teinte,mix.inputs[2])
        return mix.outputs[0]

    for cx,cy in ((396,695),(583,695)):
        # Des transitions larges donnent du volume sans retablir les fibres realistes.
        iris=melanger(ellipse(cx,cy+9,27,38,.12),(.022,.010,.007,1),(.24,.085,.032,1))
        iris=melanger(ellipse(cx,cy-3,15,23,.70),iris,(.012,.006,.004,1))
        # Laisser lire l'iris autour de la pupille et ouvrir le reflet rend le regard vif.
        iris=melanger(ellipse(cx-8,cy+19,5,6,.10),iris,(.26,.16,.10,1))
        iris=melanger(ellipse(cx+9,cy-22,8,9,.65),iris,(.95,.95,.92,1))
        couleur=melanger(ellipse(cx,cy,28,42),couleur,iris)
    return couleur
