"""Controle des deformations finales, y compris entre les cles exportees."""
import bpy
import json
from pathlib import Path
from mathutils.bvhtree import BVHTree

RACINE = Path(__file__).resolve().parents[2]
SOURCE = RACINE / 'assets/3d/sources/characters/heros_b'


def controler_superpositions(rig, peau, baton, chapeau):
    haut = ['torse','tete','chapeau','bras_droite','avant_bras_droite','main_droite',
            'bras_gauche','avant_bras_gauche','main_gauche']
    def pose(nom,part):
        action = bpy.data.actions[nom]
        rig.animation_data.action = action
        f = 1+(action.frame_range.y-1)*part
        bpy.context.scene.frame_set(int(f),subframe=f%1)
        bpy.context.view_layer.update()
        return {p.name:(p.location.copy(),p.rotation_euler.to_quaternion(),p.scale.copy()) for p in rig.pose.bones}
    controles = 0
    for nom in ['attaque','touche']:
        for a in range(8):
            course = pose('course',a/8)
            for b in range(8):
                geste = pose(nom,b/8)
                rig.animation_data.action = None
                for poids in [.5,1.0]:
                    for p in rig.pose.bones:
                        loc,rot,taille = course[p.name]
                        if p.name in haut:
                            l,r,s = geste[p.name]
                            loc=loc.lerp(l,poids);rot=rot.slerp(r,poids);taille=taille.lerp(s,poids)
                        p.location=loc;p.rotation_euler=rot.to_euler();p.scale=taille
                    bpy.context.view_layer.update()
                    graphe=bpy.context.evaluated_depsgraph_get()
                    corps=peau.evaluated_get(graphe).data
                    accessoire=baton.evaluated_get(graphe).data
                    aabb_chapeau=BVHTree.FromPolygons([v.co for v in corps.vertices],chapeau)
                    aabb_baton=BVHTree.FromPolygons([v.co for v in accessoire.vertices],[tuple(p.vertices) for p in accessoire.polygons])
                    assert not aabb_chapeau.overlap(aabb_baton), ('superposition',nom,a,b,poids,'baton dans le chapeau')
                    controles += 1
    return controles


def main():
    bpy.ops.wm.open_mainfile(filepath=str(SOURCE/'heros_b_anime.blend'))
    rig = bpy.data.objects['Heros_B']
    peau = bpy.data.objects['Heros_B_peau']
    baton = bpy.data.objects['Baton_heros_B']
    chapeau = [tuple(p.vertices) for p in peau.data.polygons if all(peau.data.vertices[i].co.z > 1.42 for i in p.vertices)]
    rapport = {}
    for nom in ['repos', 'course', 'attaque', 'touche', 'mort', 'victoire']:
        action = bpy.data.actions[nom]
        rig.animation_data.action = action
        duree = int(action.frame_range.y)
        sol_peau, sol_baton, hauteurs_racine = [], [], []
        premier = None
        ecart_main = 0.0
        for demi_image in range((duree-1)*2+1):
            bpy.context.scene.frame_set(1+demi_image//2, subframe=(demi_image%2)*.5)
            bpy.context.view_layer.update()
            graphe = bpy.context.evaluated_depsgraph_get()
            corps = peau.evaluated_get(graphe).data
            accessoire = baton.evaluated_get(graphe).data
            sol_peau.append(min(v.co.z for v in corps.vertices))
            sol_baton.append(min(v.co.z for v in accessoire.vertices))
            chapeau_evalue = BVHTree.FromPolygons([v.co for v in corps.vertices],chapeau)
            baton_evalue = BVHTree.FromPolygons([v.co for v in accessoire.vertices],[tuple(p.vertices) for p in accessoire.polygons])
            assert not chapeau_evalue.overlap(baton_evalue), (nom,'baton dans le chapeau',demi_image)
            hauteurs_racine.append(rig.pose.bones['racine'].location.y)
            main = rig.pose.bones['main_droite'].matrix @ rig.data.bones['main_droite'].matrix_local.inverted()
            for i in range(0,len(accessoire.vertices),31):
                ecart_main = max(ecart_main,(accessoire.vertices[i].co-main @ baton.data.vertices[i].co).length)
            if premier is None:
                premier = [v.co.copy() for v in corps.vertices]
            if nom == 'course':
                for cote in ['gauche','droite']:
                    h = rig.pose.bones['cuisse_'+cote].head
                    g = rig.pose.bones['tibia_'+cote].head
                    a = rig.pose.bones['pied_'+cote].head
                    assert (g.y-h.y)*(a.z-g.z)-(g.z-h.z)*(a.y-g.y) > .01, ('genou inverse',demi_image,cote)
        raccord = max((a-v.co).length for a,v in zip(premier,corps.vertices))
        assert min(sol_peau) > -.001, (nom,'corps sous le sol',min(sol_peau))
        assert min(sol_baton) > -.001, (nom,'baton sous le sol',min(sol_baton))
        assert ecart_main < .00001, (nom,'baton detache',ecart_main)
        if nom in ['repos','course']:
            assert raccord < .00001, (nom,'raccord de boucle',raccord)
        if nom == 'course':
            assert max(hauteurs_racine)-min(hauteurs_racine) < .00001, 'Correction verticale discontinue'
            assert .005 < max(sol_peau) < .12, ('suspension de course',max(sol_peau))
        rapport[nom] = {'echantillons':len(sol_peau), 'sol_corps':[min(sol_peau),max(sol_peau)],
                        'sol_baton_min':min(sol_baton), 'erreur_liaison_main':ecart_main,
                        'raccord_boucle':raccord if nom in ['repos','course'] else None}
    rapport['superpositions_sans_contact_chapeau'] = controler_superpositions(rig,peau,baton,chapeau)
    sortie = RACINE/'tmp/heros-polissage/controle-geometrie.json'
    sortie.parent.mkdir(parents=True,exist_ok=True)
    sortie.write_text(json.dumps(rapport,indent=2)+'\n')
    print('GEOMETRIE_HEROS',json.dumps(rapport))


if __name__ == '__main__':
    main()
