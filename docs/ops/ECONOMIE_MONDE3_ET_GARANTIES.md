# Monde 3 : économie accessible et garanties de butin

Décision du 16 septembre 2026 : les « 60–70 dégâts » étaient un exemple,
la courbe doit suivre ce qu’on peut réellement acheter après deux à trois
passages par chapitre. Les coffres suivent une chance de 1/X, garantie au Xe
coffre éligible si aucun drop n’a eu lieu auparavant.

## Hypothèses de calcul

Entrée du monde 3 = six chapitres terminés, douze ou dix-huit victoires.
Cent graines par scénario, trois préférences d’achat : offensive, équilibrée,
défensive. Les achats sont effectués après chaque coffre au prix réel, avec
leurs prérequis et plafonds. Trois rangs de Récolte au début (+12 % gouttes),
puis achats selon le gain relatif de dégâts/résistance par goutte, en incluant
les prérequis dans le coût. C’est un modèle de décisions, pas une stratégie
imposée ni une prédiction de tous les joueurs.

Aucune Mine, aucune Épreuve ajoutée ; aucun augment de run dans les stats de
départ. **Forge zéro** : la campagne seule ne donne pas de pierres. Deux sorts
cadeaux au rang 1, Onde alchimique et Grand Œuvre ; aucun passif supposé.
Le sceptre de cuivre devient disponible à l’entrée du monde 3. Les trois slots
utilisent les bijoux effectivement obtenus, sans dupliquer un anneau.

## Résultats à l’entrée du monde 3

Médianes du scénario équilibré :

| Par chapitre | Gouttes cumulées | PV | Résistance en dégâts bruts | Dégâts par tir de cuivre | DPS de tir |
|---|---:|---:|---:|---:|---:|
| 2 victoires | 1 638 | 664 | 956 | 120 | 139 |
| 3 victoires | 2 456 | 832 | 1 240 | 150 | 180 |

Les médianes de chaque colonne ne décrivent pas nécessairement la même graine.
L’armure explique la différence entre PV et dégâts bruts encaissables.

Exemple payé, deux passages, graine 1 : 1 632 gouttes gagnées, 1 629 dépensées,
3 restantes. Force 8, Cadence 4, Frappe souveraine 1, Puissance 5 ; Constitution 8,
Armure 6, Vitalité souveraine 1, Rempart 4, Robustesse 2 ; Récolte 3.
Trois passages : 2 447 gagnées, 2 402 dépensées, 45 restantes. Force 9,
Cadence 6, Frappe souveraine 1, Puissance 6 ; Constitution 9, Armure 7,
Vitalité souveraine 1, Rempart 6, Robustesse 2 ; Récolte 3.

Deux passages donnent en moyenne **3,78 bijoux sur six** : premier garanti,
chacun des cinq autres obtenu avec probabilité `1 − (2/3)² = 5/9`.
Trois passages garantissent les six bijoux, dont trois équipés simultanément.
Aucun pouvoir de bijou sans forge 10. Les choix orientés attaque ou défense
élargissent la fourchette : résistance médiane de 742 à 1 162 après deux passages,
de 1 045 à 1 558 après trois. Le rapport JSON contient aussi les percentiles.

En terminant également les trois chapitres du monde 3, le scénario équilibré
atteint environ 3 438 / 5 165 gouttes cumulées après deux / trois passages.
Les paliers majeurs expliquent les sauts de puissance, pas un bonus gratuit.

## Calibration retenue

Le coup de référence à l’entrée du monde 3 vaut **120 dégâts**, soit environ
8 / 10 coups bruts encaissables pour ces deux profils équilibrés, avant soins,
boucliers et améliorations de run. Les attaques de boss ont leurs propres ratios.
Les PV ennemis sont multipliés par 3 : un Sceau-bélier a 174 PV en première salle,
soit deux tirs de cuivre avec les profils équilibrés. Les ennemis légers restent
rapides à éliminer. Une première passe à 150 dégâts et ×6 PV était trop sévère
dans les essais de combat ; le boss impose aussi du déplacement et des esquives.

Les coefficients sont **fixes**, interpolés exponentiellement entre chapitre 1,
entrée du monde 3 et chapitre 30. Départ conservé (×0,14 PV, ×0,15 dégâts),
fin conservée (×4 475,83 PV, ×1 259,36 dégâts). Aucun ajustement sur le compte réel.
Les mondes 1–2 montent plus vite qu’avant ; le raccord ultérieur reste continu.

## Garantie exacte, persistante et locale

- Campagne : **1/3** par victoire éligible ; après deux coffres sans objet,
  la troisième victoire donne l’objet. Compteur distinct par chapitre.
- Épreuve : **1/5** ; après quatre coffres sans sort, la cinquième victoire
  donne un sort de la pool locale. Compteur distinct par niveau d’Épreuve.
- Le premier bijou reste garanti dès la première victoire du premier chapitre.
- Tout drop aléatoire réussi remet son compteur à zéro, doublon de sort compris.
- Défaite, abandon, pool complète et réouverture du même bilan ne font pas
  progresser le compteur. Les cadeaux de campagne ne modifient pas celui des Épreuves.
- Sauvegarde des sorts : `epreuves/pities`, absente = compteurs zéro. Les anciens
  compteurs d’objets sont conservés ; un ancien compteur déjà élevé garantit le prochain drop.
- La garantie concerne **un sort**, pas chaque sort individuel : une pool de deux
  sorts encore disponibles affiche 50 % chacun lors du coffre garanti.
- L’aperçu montre les chances du prochain coffre et le nombre maximal de victoires
  restantes. Le taux moyen avec garantie est supérieur à la chance de base.

## Reproduction

`sondes/mesurer_monde_trois.gd` produit `tmp/progression/economie_monde3.jsonl`.
`sondes/run_parcours_economique.gd -- --auto --chapitre=7 --repetitions=2 --graine=1`
charge ce profil dans le combat sans écrire de sauvegarde.
`sondes/garanties_butin.gd` vérifie les coffres réels, l’idempotence, la sauvegarde,
les pools complètes et l’aperçu. Elle exige un profil local `tmp/profil/`.
Les tests de garanties couvrent 6 000 tirages, en plus des frontières exactes.

Deux ou trois **tentatives perdues** ne donnent pas le même budget que deux ou trois
victoires : leurs coffres partiels paient moins et ne comptent pas dans la garantie.
Le modèle ne simule ni la durée humaine de farm ni les choix d’augmentations.

## Vérifications

41 suites, 37 502 assertions et 17 contrôles d’intégration réussis. Vingt runs du
chapitre 1 : 16 victoires, 4 défaites, zéro blocage/erreur de script.
Six runs du chapitre 7, profils économiques à deux/trois passages, graines 1–3 :
défaites aux salles 5–6. Les boss restent exigeants pour le bot ; ces essais ne
prouvent pas le confort de progression humain. Les dégâts affichés dans le tableau
sont ceux des statistiques de départ, sans les augmentations gagnées dans la run.
Les diagnostics de ressources à la fermeture du selftest headless subsistent.

Logs : `tmp/verification-pity-final.log`, `tmp/sonde-pity.log`,
`tmp/vingt-pity.log`, `tmp/run-monde3-ajuste-2-1.log` à `tmp/run-monde3-ajuste-3-3.log`.
