# Augmentations et endurance — 12 septembre 2026

Demande : enlever les PV chiffrés et la rangée d'augmentations du HUD, corriger le déplacement conservé après un choix, revoir les trente augmentations et viser des boss de 30–45 secondes en début de campagne.

## Règles de cumul

Les bonus positifs restent additifs. Les pénalités deviennent multiplicatives, séparément : `base × (1 + somme des bonus) × produit des coûts`. Ainsi, une amélioration de dégâts ne rembourse plus artificiellement le coût des projectiles supplémentaires, et trois pénalités ne ramènent plus la puissance au plancher. L'ordre d'acquisition ne change rien. Les descriptions chiffrées des copies suivent la même règle.

Toutes les paires du catalogue et les 180 fusions élémentaires sont couvertes par les tests de composition. Ces tests vérifient la cohérence des statistiques, pas la qualité artistique ni toutes les situations tactiques possibles.

## Audit des trente choix

Les gains de DPS ci-dessous supposent que les projectiles touchent. Un éventail sur une petite cible éloignée ne réalise pas son budget complet. Les phénomènes utilisent les dégâts de base du héros et leur propre cadence : ils continuent pendant les déplacements, sans hériter des pénalités des tirs multiples.

| Augmentation | Décision et raison |
|---|---|
| Tir multiple | Coût par trait −32 → −22 %. Deux traits : +56 % de dégâts totaux ; ajouté à Spirale, ne diminue plus les dégâts totaux de l'éventail. |
| Salve | Coût −32 → −28 %. Deux tirs : +44 % ; coût composé avec Tir multiple. |
| Ricochet | Conservé : +5 % sur la première cible, un rebond avec 22 % de perte. Utile contre les groupes. |
| Perforation | Conservée : +8 %, deux cibles supplémentaires avec 20 % de perte successive. |
| Fragmentation | Conservée : trois éclats à 28 %, portée 260 ; budget secondaire maximal +84 %, conditionné par leurs trajectoires. |
| Homing | Conservé : +8 %, guidage à 8 rad/s ; utilité dans les tirs effectivement touchés. |
| Frappe lourde | Dégâts ×1,62 → ×1,70 ; cadence ×0,68 → ×0,72. Gain soutenu +10 → +22,4 %, tout en gardant les gros impacts. |
| Cadence fébrile | Cadence +30 → +38 %, portée −18 % conservée. Son coût la distinguait trop peu du Sceau de célérité gratuit. |
| Spirale | Conservée : trois traits à 58 %, arc de 0,55 rad ; +74 % seulement si tous touchent. Le nouveau cumul corrige ses interactions. |
| Trait transperçant | Conservé : traversées illimitées, dégâts et vitesse −5 %, perte progressive à chaque cible. |
| Égide | Conservée : une attaque annulée par salle. |
| Régénération | Conservée : 6 % des PV max entre les salles, soin garanti indépendant du nombre d'ennemis. |
| Avidité | Conservée : XP et Gouttes +20 % ; investissement plutôt que puissance immédiate. |
| Courageux | Conservé : bonus linéaire jusqu'à +70 % à presque zéro PV ; +35 % à mi-vie. |
| Mannequin | Après 1,2 s immobile : dégâts +25 % et cadence +15 %, contre +35/+25 auparavant. Gain soutenu +43,75 %, contre +68,75 %. |
| Peau de pierre | Réduction des dégâts 24 → 30 %, cadence −8 % conservée. Protection distincte du Sceau de garde sans coût. |
| Élan vital | Dégâts +45 → +35 % pendant 1,1 s après déplacement. Exige désormais un déplacement dans la salle ; ne s'active plus gratuitement à l'apparition. |
| Soif de sang | Soin par élimination 1,2 → 0,6 % des PV max. Dix éliminations égalent une Régénération ; moins de soin excessif dans les vagues denses. |
| Familier tireur | Conservé : 42 % des dégâts de base toutes les 0,85 s, soit environ 20,6 % du DPS de base, même en mouvement. |
| Météores | Conservés : 260 % toutes les 4 s, rayon 150 ; environ +27 % sur une cible, avec utilité de zone. |
| Zone alchimique | Conservée : 32 % toutes les 0,45 s, rayon 145 ; environ +30 % par cible, avec risque de proximité. |
| Familier gardien | Conservé : 55 % toutes les 0,75 s, 55 PV, retour après 6 s. Environ +31 % si toujours au contact, plus interception. |
| Orbes chargées | Conservées : une charge par 2 s de mouvement, trois au maximum, chacune à 55 %. Réserve de dégâts, pas un bonus permanent de cadence. |
| Chaîne alchimique | Conservée : 52 % toutes les 1,6 s, jusqu'à quatre cibles distinctes, sauts de 340. Ne rebondit pas plusieurs fois sur le même boss. |
| Onde de choc | Conservée : 115 % toutes les 3,2 s, rayon 300 et poussée 300 ; dégâts modestes compensés par le dégagement. |
| Sceau de furie | Conservé : dégâts +28 % sans condition. |
| Sceau de célérité | Conservé : cadence +26 % sans condition. |
| Sceau de garde | Conservé : dégâts reçus −22 %, sans perte offensive. |
| Sceau d'envergure | Conservé : portée +45 %, vitesse des tirs +20 % ; confort de ciblage, sans dégâts gratuits. |
| Sceau de ruine | Conservé : dégâts +50 %, dégâts reçus +30 % ; risque maintenu, coûts des tirs non effacés par son bonus. |

Fusion Lumière des sceaux : soin plafonné à trois cibles par pulsation, soit 1,2 % des PV max toutes les 0,55 s au mieux. Les autres effets élémentaires gardent leurs plafonds et règles existants (Feu à quatre couches, effets identiques non dupliqués). Aucun nouvel effet ou système de rareté ajouté.

## Boss

PV de campagne : miniboss ×1,25 → ×6,5 ; signatures ×3 → ×5. Les dégâts, vitesses, télégraphes et modes annexes restent sur leurs réglages propres. Les PV sont fixes pour un boss et un palier, sans adaptation cachée au build du joueur.

Sonde `sondes/choix_et_endurance.gd`, Godot 4.7.1, `--fixed-fps 60 --vierge --mode=grimoire --graine=1` : vraie cadence du héros, préparation, projectiles et collisions. Cibles fixes sans attaques, alternance de 3 s d'arrêt et 0,6 s de déplacement. Ni sorts ni progression permanente. Ce banc mesure l'endurance, pas une partie réelle avec esquives et invocations.

| Rencontre | Build du banc | PV | Durée mesurée |
|---|---|---:|---:|
| La Rature, chapitre 1 salle 5 | Furie | 829,3 | 33,28 s |
| Copiste aveugle, chapitre 1 salle 5 | Furie | 1 013,5 | 40,92 s |
| Archiscribe, chapitre 3 salle 20 | Tir multiple, Furie, Célérité | 1 852,1 | 37,12 s |

Les dix miniboss sont également vérifiés à 30–45 s de tir de base théorique continu au premier palier. Un build offensif plus fort peut les tuer plus vite ; un joueur qui esquive longtemps peut dépasser la cible. Les chapitres avancés restent à valider avec leurs équipements réels.

## Interface et commandes

Les barres de vie restent visibles, leurs chiffres sont retirés. La rangée d'augmentations sous l'XP est retirée ; le détail reste dans la pause. Chaque panneau de choix, infusion ou pause annule doigt, direction et inertie avant de suspendre le jeu. Les intentions sont ignorées pendant le panneau. Le joystick annule aussi son état à la perte de focus.

La sonde reproduit glissement → choix → relâchement pendant la pause → validation → attente sans entrée → nouvel appui. Elle vérifie aussi Élan vital et le plafond de soin de l'aura.

## Vérification finale

- `tools/verifier_windows.ps1` : 32 suites, 15 418 assertions, zéro échec ; selftest cohérent. Avertissements de ressources/RID au nettoyage du moteur headless, déjà présents avant cette passe.
- `sondes/choix_et_endurance.gd` : 15 assertions, zéro échec.
- `tools/verifier_windows.ps1 -VingtRuns` : vingt fins de run, zéro blocage et zéro erreur de script. Une victoire (graine 15), dix morts en salle 5 ; les autres atteignent les salles 6 à 13. La campagne reste terminable par le bot mais le premier boss représente désormais un obstacle important. Ce résultat ne prouve pas que la difficulté ressentie par un débutant est idéale ; elle demande un essai humain.
- Logs : `tmp/augmentations-verification.log`, `tmp/choix-endurance.log`, `tmp/augmentations-vingt-runs.log`. Aucun export APK effectué.
