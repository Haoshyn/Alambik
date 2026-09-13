"""Treize nouvelles compositions originales ; conserve les fichiers precedents."""
from composer import composer

MAJEUR = [0,2,4,5,7,9,11]
DORIEN = [0,2,3,5,7,9,10]
MINEUR = [0,2,3,5,7,8,10]
PISTES = [
    ('etincelles', 'Étincelles', False, 146, 55, [0,3,4,0], 1, MAJEUR, [7,9,11,14,11,9,8,7], 'celesta'),
    ('ronde_automates', 'Ronde des automates', False, 118, 48, [0,2,5,4], 0, DORIEN, [7,4,7,8,11,9,6,4], 'corde'),
    ('course_canopee', 'Course en canopée', False, 132, 60, [0,5,3,4], 1, MAJEUR, [9,11,12,11,9,7,8,6], 'flute'),
    ('fournaise', 'Fournaise de cuivre', False, 104, 45, [0,4,5,3], 2, MINEUR, [4,7,6,4,3,4,7,6], 'corde'),
    ('marees_arcanes', 'Marées arcanes', False, 126, 53, [0,6,3,5], 0, DORIEN, [11,9,7,9,6,4,6,7], 'cloche'),
    ('matin_atelier', 'Matin à l’atelier', True, 88, 60, [0,3,4,0], 3, MAJEUR, [7,9,8,7,4,6,7,4], 'corde'),
    ('jardin_verre', 'Jardin de verre', True, 76, 65, [0,5,3,4], 3, MAJEUR, [11,9,7,6,7,8,9,7], 'celesta'),
    ('bibliotheque', 'Bibliothèque secrète', True, 72, 50, [0,3,5,4], 3, MINEUR, [7,6,4,3,4,6,7,9], 'cloche'),
    ('the_alchimiste', 'Le thé de l’alchimiste', True, 94, 57, [0,2,5,4], 3, MAJEUR, [4,7,9,8,7,6,4,2], 'corde'),
    ('serre_aube', 'Serre à l’aube', True, 80, 62, [0,3,0,5], 3, DORIEN, [7,8,11,9,8,7,6,7], 'flute'),
    ('poussiere_etoiles', 'Poussière d’étoiles', True, 68, 67, [0,5,2,3], 3, MAJEUR, [14,11,9,7,9,11,12,9], 'celesta'),
    ('comptoir_cuivre', 'Comptoir de cuivre', True, 102, 53, [0,4,3,5], 3, DORIEN, [7,4,6,9,7,8,6,4], 'corde'),
    ('carnet_voyage', 'Carnet de voyage', True, 86, 59, [0,5,3,0], 3, MAJEUR, [7,11,9,8,9,7,6,7], 'flute'),
]

if __name__ == '__main__':
    for identifiant, nom, menu, tempo, tonique, accords, style, gamme, motif, timbre in PISTES:
        composer(identifiant,tempo,tonique,accords,style,gamme,motif,timbre,
                 [0,2,4,7,6,4,2,4] if timbre == 'flute' else [0,4,7,2,4,6,2,7])
