"""Glyphes originaux Cuivre & Azur, reproductibles sans dependance graphique."""
from pathlib import Path

RACINE = Path(__file__).resolve().parents[1]

def cercle(x, y, r):
    return f'<circle cx="{x}" cy="{y}" r="{r}"/>'

def chemin(d):
    return f'<path d="{d}"/>'

MOTIFS = {
    'tir_multiple': 'M42 99V32m-12 14 12-18 12 18M86 99V32m-12 14 12-18 12 18',
    'salve': 'M28 96 55 69m-6 23 20-20M54 67 81 40m-6 23 20-20M79 42 99 22',
    'ricochet': 'M26 97 65 59 30 31h70m-16-13 16 13-16 13',
    'perforation': 'M24 96 99 23m-22 3 22-3-3 22M29 52l47 47M44 37l47 47',
    'fragmentation': 'M54 57 69 51 78 64 63 78ZM42 49 25 30m3 15-3-15 15 3M83 44l17-16M87 81l18 16M43 87l-17 17',
    'homing': 'M28 101V70Q28 35 70 35h27m-15-13 15 13-15 13M70 80h32M86 64v32',
    'frappe_lourde': 'M37 27 91 45 78 77 24 59ZM58 72 43 106M29 97l-9 7M85 87l10 9',
    'cadence_febrile': 'M31 91 62 60 43 60 82 24 71 51h28L62 99l8-25M23 54h16M19 70h12',
    'spirale': 'M62 65c-14-16 14-29 24-12 18 31-30 53-51 28-33-41 24-82 62-47M98 23l-1 12-14-2',
    'trait_transpercant': 'M21 98 99 22m-26 4 26-4-4 26M22 71l7 7m18 18 8 8M48 28l8 8m18 18 10 10',
    'egide': 'M64 24 98 39v26Q98 91 64 107 30 91 30 65V39ZM64 37v52M47 59h34',
    'regeneration': 'M39 38Q73 15 96 49m-1-18 1 18-18-2M91 90Q56 114 31 80m0 17V79l18 3M64 48v31M49 64h30',
    'avidite': 'M35 35 49 47h30l14-12-18-7-11 14-11-14ZM49 48Q21 70 33 93q30 24 62 0 12-23-16-45M61 61v27m12-27H56v13h16v14H54',
    'courageux': 'M64 104Q24 88 34 57q8-18 10-26 4 26 17 29-2-22 16-39-1 26 14 37 21 28-27 46ZM58 86l13-18 4 19',
    'mannequin': 'M51 22h26v24H51ZM34 52h60M64 48v46M42 107l22-15 22 15M34 53l-9 26M94 53l9 26',
    'peau_de_pierre': 'M40 27 85 24 105 62 84 102 41 104 23 64ZM40 27l16 32-15 45M85 24 73 62l11 40M23 64l33-5 17 3 32 0',
    'elan_vital': 'M20 86h27l22-23 20 1M42 102l22-23 18 25M43 65l13-22 25 10 21-14M53 36l17-13 11 10-17 13ZM17 65h18M15 101h17',
    'soif_de_sang': 'M65 24Q39 56 36 70q-8 33 29 35 39-3 28-35ZM48 77q2 12 13 13M20 35l9 14M96 27l-6 16',
    'familier_tireur': 'M30 76 23 43 50 54 64 33 78 54 105 43 98 76 64 101ZM43 68h7m28 0h7M56 82l8 7 8-7M61 19h6',
    'meteores': 'M31 74Q20 103 50 105 78 105 80 77L102 23 74 43 81 20 52 54 54 30ZM40 81l17-8 10 17-17 8Z',
    'zone_heros': 'M26 78q38-26 76 0-38 41-76 0ZM40 99q24 12 48 0M64 30v35M51 43l13-16 13 16',
    'familier_gardien': 'M41 26 64 38 87 26l10 35-11 32-22 13-22-13-11-32ZM45 56l9 5m20 0 9-5M51 79l13 10 13-10',
    'orbes_chargees': 'M32 42Q64 16 96 42M32 88q32 26 64 0M64 50l-8 14h16l-8 14',
    'chaine_alchimique': 'M36 37 60 58 46 68 88 92M90 31 78 51l-18 7M24 29l12-6 10 14-12 9ZM79 23l15-6 12 16-16 9ZM80 88l16-6 10 17-15 9Z',
    'onde_de_choc': 'M50 55q14-17 28 0M35 43q29-30 58 0M20 30q44-43 88 0M50 78q14 17 28 0M35 90q29 30 58 0M64 55l8 10-8 10-8-10Z',
    'sceau_furie': 'M30 36 64 18 98 36v57l-34 17-34-17ZM44 86 75 43 70 66h16L57 95l6-26H44Z',
    'sceau_celerite': 'M64 18 105 44v44l-41 23-41-23V44ZM37 63h29L54 49m12 14L53 77M70 49l15 14-15 14',
    'sceau_garde': 'M28 39 64 18 100 39v50l-36 22-36-22ZM45 45h38v24L64 92 45 69Z',
    'sceau_portee': 'M27 41 64 19 101 41v46l-37 23-37-23ZM40 84 87 40m-18 1 18-1-1 18M40 60v24h24',
    'sceau_ruine': 'M28 40 64 18 100 40v49l-36 22-36-22ZM55 33l13 22-13 16 18 22M34 64h18m24 0h18',
    'force': 'M36 91 84 31 99 30 99 46 48 102ZM65 71l-13-10M27 85l28 22',
    'cadence': 'M30 42h67L81 29M97 42 81 55M30 67h53L69 54M83 67 69 80M30 93h37L54 80M67 93 54 106',
    'precision': 'M64 21v24m0 38v24M21 64h24m38 0h24',
    'puissance': 'M27 91 88 25l14 10-61 66M29 28l64 71 10-11-65-71M18 80l30 27M80 103l27-26',
    'rythme': 'M24 70h17l10-35 15 62 14-43 8 16h16',
    'catalyse': 'M49 25h30M54 27v27L31 88q-3 16 15 16h37q18 0 14-16L74 54V27M43 78h42M53 65l12 13 10-12',
    'trajectoire': 'M22 98 103 26l-27 2m27-2-6 26M29 78 78 32M49 102 99 56',
    'tempete': 'M29 30q60-15 70 7-1 22-64 16-24-3-14 13 17 18 71 7 17-6 5 8L61 108l8-26',
    'domination': 'M27 40 45 60 64 25 83 60 101 40 91 91H37ZM40 104h48',
    'grand_oeuvre': 'M64 20 76 49 107 52 83 72 90 104 64 87 38 104 45 72 21 52 52 49ZM64 45 79 65 64 82 49 65Z',
    'constitution': 'M64 47Q38 20 27 50 19 75 64 103q45-28 37-53-11-30-37-3Z',
    'armure': 'M37 27 52 21q12 22 24 0l15 6 12 28-17 8v39H42V63l-17-8ZM49 70h30M49 85h30',
    'vitalite': 'M64 104Q23 76 27 52 30 25 49 37l15 13 15-13q19-12 22 15 4 24-37 52ZM64 58v30M49 73h30',
    'rempart': 'M24 101V40h15v14h15V29h20v25h15V40h15v61ZM54 100V80q10-15 20 0v20',
    'robustesse': 'M36 100 42 48 64 25 88 48 93 100ZM42 48l22 14 24-14M64 62v38M24 104h81',
    'carapace': 'M24 68Q24 24 64 23q40 1 40 45L84 97H44ZM64 43 83 56 77 78H51L45 56ZM64 23v20M24 68l25-2m30 0h25M44 97l9-19m22 0 9 19',
    'endurance': 'M35 43v48q29 22 58 0V43M48 26h32v20H48ZM46 68h14l8-14 9 29 8-15',
    'bastion': 'M22 103V30h23v17h38V30h23v73ZM22 64h23m38 0h23M51 103V77q13-16 26 0v26M24 22h19m42 0h19',
    'colosse': 'M42 29 64 20 86 29v21L74 64H54L42 50ZM50 65 30 74 23 105h82l-7-31-20-9M49 83v22m30-22v22',
    'immortel': 'M23 70Q27 34 50 53l28 27q23 21 27-14-4-34-27-14L50 79Q27 98 23 70ZM50 26l14 14 14-14M64 23v17',
    'celerite': 'M48 27h24v46l24 13q10 7 2 16H29V88l19-24ZM27 41h11M19 57h18M16 73h16',
    'collecte': 'M28 86 52 97h30l24-28q-9-11-19 5L72 85M28 65h23l19 13H48M22 63v37M59 29Q44 52 64 54q20-2 5-25Z',
    'distillation': 'M24 83 39 52V28h20v24l15 31q8 20-25 20T24 83ZM63 35h26v32l14 14v21H81V81l8-14M29 80h40',
    'fortune': 'M28 48h72v54H28ZM35 48V33h58v15M24 68h80M57 63h14v18H57ZM51 30l13-12 13 12',
    'sagesse': 'M25 33q21-9 39 4 18-13 39-4v63q-22-9-39 4-17-13-39-4ZM64 38v62M35 49l17 3M35 65l17 3M76 52l16-3M76 68l16-3',
    'abondance': 'M25 87q35-1 65-39L76 25q-3 51-51 62ZM25 87q-3 13 14 16 46 1 57-44M42 40l9-16 9 16ZM69 91l15-11',
    'savoir': 'M23 39q16-5 29 4v51q-14-6-29-1ZM105 39q-16-5-29 4v51q14-6 29-1ZM59 54h10M59 69h10M59 84h10M59 28h10',
    'elan': 'M22 90 48 88 65 62 87 58l18-24M39 105l27-21 22 19M38 65l18-25 19 6M55 27l17-9 9 14-17 8ZM18 43h22M16 75h15',
    'prescience': 'M20 62Q64 15 108 62 64 109 20 62ZM43 102l7-11m28 0 7 11M43 23l7 11m28 0 7-11',
    'philosophe': 'M42 30h44l21 33-43 44-43-44ZM42 30l22 77 22-77M21 63h86M42 30l22 33 22-33',
    'onde_alchimique': 'M64 22v16m0 52v16M22 64h16m52 0h16M34 34l11 11m38 38 11 11M34 94l11-11m38-38 11-11',
    'nova_de_givre': 'M64 20v88M26 42l76 44M26 86l76-44M49 27l15 13 15-13M49 101l15-13 15 13M26 60l21-6-3-20M84 94l-3-20 21-6M26 68l21 6-3 20M84 34l-3 20 21 6',
    'barrage_de_braise': 'M25 81 38 44 45 62q22 30-5 35-20 0-15-16ZM66 67 84 21 89 49q30 37-4 45-25-1-19-27M18 109h92',
    'impulsion_foudroyante': 'M73 19 31 71h29l-6 38 43-56H70ZM21 29l11 12M96 89l11 12M93 20l-3 12',
    'explosion_corrosive': 'M50 22h28M55 23v30L29 88l10 17h49l12-17-27-35V23M43 76h43M48 85l8 11 9-11 8 11 9-11M19 46l7 13M106 47l-7 13',
    'temps_suspendu': 'M40 24h48M40 104h48M46 25q0 28 18 39-18 11-18 39M82 25q0 28-18 39 18 11 18 39M54 37h20L64 50ZM54 93l10-15 10 15ZM25 53v24M103 53v24',
    'transmutation_totale': 'M27 36 48 24 69 36v24L48 72 27 60ZM65 85l19-20 21 20-21 22ZM72 26q31 0 31 25m-10-8 10 8 6-11M53 103q-28 0-29-25m-6 10 6-10 11 8',
    'rempart_initial': 'M29 44 64 24 99 44v25l-35 35-35-35ZM45 62h38M64 44v39M23 103h22M83 103h22',
    'heritage_reactif': 'M24 43h80v57H24ZM24 61h80M53 45v55m21-55v55M64 42Q31 35 39 23q17-6 25 19 8-25 25-19 8 12-25 19Z',
    'moisson_vitale': 'M36 26q60-8 65 30L69 46 35 105M35 105 21 94M52 83q11-15 20 0 9-15 20 0 6 13-20 26-25-13-20-26',
    'riposte_alchimique': 'M23 40h43q37 0 37 32 0 30-37 30H44m15-14-15 14 15 9M32 57 61 69 43 83l-8-15-12 0Z',
    'seconde_chance': 'M30 53Q43 19 80 29l19 20M98 29l1 20-21-1M98 77q-13 33-50 22L29 79M30 99l-1-20 21 1M52 58q12-14 24 0 14 15-12 30-26-15-12-30Z',
    'reserve_ultime': 'M44 27h40v13h13v62H31V40h13ZM51 56h26M51 73h26M51 90h26M55 19h18',
    'sang_froid': 'M33 36h51l17 24v41H27V60ZM42 24v12m33-12v12M64 48v42M44 59l40 20M44 79l40-20',
    'dernier_rempart': 'M29 29h70v37Q93 95 64 109 35 95 29 66ZM64 30l-9 23 17 12-11 16M40 93h48',
    'audace': 'M33 104 91 23l11 10-61 79M22 81l31 21M30 41l8-18 14 14-5 23ZM74 84l16-14 17 21-23 12Z',
    'echo_alchimique': 'M27 72q25-30 50 0M27 89q25 30 50 0M51 36q25-30 50 0M51 53q25 30 50 0M52 60v15M78 43v15',
    'feu': 'M64 105Q22 86 35 54l12-24 15 29 18-39q-1 30 14 46 15 28-30 39Z',
    'eau': 'M64 23Q25 64 31 84q8 28 33 23 25 5 33-23 6-20-33-61ZM30 82q17-15 34 0t34 0',
    'air': 'M23 46h56q23-1 17-16-7-14-19-1M23 66h68q22 0 14 16-7 11-17 0M23 85h32q18 0 12 16-5 10-15 0',
    'terre': 'M21 100 46 38 61 65 78 26 107 100ZM38 59l13 13 10-7M65 56l13 11 10-13',
    'lumiere': 'M64 17v20m0 54v20M17 64h20m54 0h20M30 30l14 14m40 40 14 14M30 98l14-14m40-40 14-14',
    'tenebres': 'M83 22Q31 23 26 65q5 47 56 42-29-17-28-42 0-26 29-43ZM85 49l5 12 13 3-13 4-5 12-4-12-13-4 13-3Z',
}

AJOUTS = {
    'precision': cercle(64,64,29)+cercle(64,64,9),
    'prescience': cercle(64,62,18)+cercle(64,62,5),
    'orbes_chargees': cercle(32,64,13)+cercle(96,64,13)+cercle(64,29,9)+cercle(64,99,9),
    'onde_alchimique': cercle(64,64,20)+cercle(64,64,34),
    'lumiere': cercle(64,64,21),
}

def generer():
    dossier = RACINE/'assets/visual/azur/glyphes'
    dossier.mkdir(parents=True, exist_ok=True)
    for nom, dessin in MOTIFS.items():
        couleur = '#7ae0ed'
        if nom in ['courageux','audace','frappe_lourde','meteores','barrage_de_braise','feu','sceau_furie']: couleur='#ffad72'
        elif nom in ['regeneration','vitalite','moisson_vitale','explosion_corrosive','elan_vital']: couleur='#92e5b2'
        elif nom in ['grand_oeuvre','tenebres','sceau_ruine','orbes_chargees','transmutation_totale']: couleur='#d1a0ff'
        motif = chemin(dessin)+AJOUTS.get(nom,'')
        svg = f'''<svg xmlns="http://www.w3.org/2000/svg" width="128" height="128" viewBox="0 0 128 128">
<defs><linearGradient id="fond" x2="0.8" y2="1"><stop stop-color="#245063"/><stop offset="1" stop-color="#071e30"/></linearGradient><linearGradient id="metal" x2="0.5" y2="1"><stop stop-color="#fff0bf"/><stop offset="0.5" stop-color="{couleur}"/><stop offset="1" stop-color="#5b9daf"/></linearGradient></defs>
<rect x="3" y="3" width="122" height="122" rx="24" fill="url(#fond)" stroke="#ad8954" stroke-width="2"/>
<path d="M23 9H98M9 26V95" fill="none" stroke="#e5c388" stroke-opacity=".25" stroke-width="2"/>
<g fill="none" stroke="#010f20" stroke-width="8" stroke-linecap="round" stroke-linejoin="round" transform="translate(0 3)">{motif}</g>
<g fill="none" stroke="url(#metal)" stroke-width="4.5" stroke-linecap="round" stroke-linejoin="round">{motif}</g></svg>'''
        (dossier/(nom+'.svg')).write_text(svg,encoding='utf-8')
    print(f'{len(MOTIFS)} glyphes generes')

if __name__ == '__main__':
    generer()
