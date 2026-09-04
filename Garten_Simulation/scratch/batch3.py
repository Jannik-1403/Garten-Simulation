import json
import re

with open('/Users/jannikschill/.gemini/antigravity-ide/brain/f71db36e-4d7b-4637-b8c0-e74b49ed9b3f/needs_translation.json', encoding='utf-8') as f:
    batch = [item for item in json.load(f) if item['language'] in ['fr', 'nl', 'pt', 'pt-BR']]

IMPACT_TMPL = {
'fr': "Cette habitude ({x}) te coûte de l'énergie, du temps et de l'argent à long terme. Elle t'empêche d'exploiter pleinement ton potentiel.",
'nl': "Deze gewoonte ({x}) kost je op lange termijn energie, tijd en geld. Het weerhoudt je ervan je volledige potentieel te benutten.",
'pt': "Este hábito ({x}) custa-te energia, tempo e dinheiro a longo prazo. Impede-te de aproveitar todo o teu potencial.",
'pt-BR': "Esse hábito ({x}) custa energia, tempo e dinheiro a longo prazo. Ele te impede de aproveitar todo o seu potencial.",
}

TIPS_TMPL = {
'fr': ("**Se débarrasser de la mauvaise habitude ({x})**\n"
       "1. La rendre invisible : Retire les déclencheurs de ton champ de vision.\n"
       "2. La rendre peu attirante : Prends conscience des conséquences négatives.\n"
       "3. La rendre difficile : Ajoute des obstacles (par ex. supprime des applis, débranche la prise).\n"
       "4. La rendre insatisfaisante : Associe l'action à une sanction.\n\n"
       "**Mettre en place la bonne habitude ({y})**\n"
       "1. La rendre évidente : Place le déclencheur bien en vue.\n"
       "2. La rendre attirante : Associe-la à quelque chose que tu aimes.\n"
       "3. La rendre facile : Réduis les obstacles au minimum (par ex. seulement 2 minutes).\n"
       "4. La rendre satisfaisante : Récompense-toi juste après."),
'nl': ("**Slechte gewoonte afleren ({x})**\n"
       "1. Onzichtbaar maken: Verwijder de triggers uit je blikveld.\n"
       "2. Onaantrekkelijk maken: Word je bewust van de negatieve gevolgen.\n"
       "3. Moeilijk maken: Bouw obstakels in (bijv. apps verwijderen, stekker eruit trekken).\n"
       "4. Onbevredigend maken: Koppel de handeling aan een straf.\n\n"
       "**Goede gewoonte opbouwen ({y})**\n"
       "1. Duidelijk maken: Plaats de trigger goed zichtbaar.\n"
       "2. Aantrekkelijk maken: Koppel het aan iets wat je leuk vindt.\n"
       "3. Makkelijk maken: Beperk de obstakels tot een minimum (bijv. slechts 2 minuten).\n"
       "4. Bevredigend maken: Beloon jezelf direct daarna."),
'pt': ("**Livra-te do mau hábito ({x})**\n"
       "1. Torná-lo invisível: Remove os gatilhos do teu campo de visão.\n"
       "2. Torná-lo pouco atrativo: Consciencializa-te das consequências negativas.\n"
       "3. Torná-lo difícil: Cria obstáculos (por ex. elimina apps, desliga a ficha).\n"
       "4. Torná-lo insatisfatório: Associa a ação a uma penalização.\n\n"
       "**Estabelece o bom hábito ({y})**\n"
       "1. Torná-lo evidente: Coloca o gatilho bem visível.\n"
       "2. Torná-lo atrativo: Associa-o a algo de que gostas.\n"
       "3. Torná-lo fácil: Reduz os obstáculos ao mínimo (por ex. apenas 2 minutos).\n"
       "4. Torná-lo satisfatório: Recompensa-te logo a seguir."),
'pt-BR': ("**Elimine o mau hábito ({x})**\n"
       "1. Torne-o invisível: Remova os gatilhos do seu campo de visão.\n"
       "2. Torne-o pouco atraente: Conscientize-se das consequências negativas.\n"
       "3. Torne-o difícil: Crie obstáculos (ex.: exclua apps, desligue a tomada).\n"
       "4. Torne-o insatisfatório: Associe a ação a uma punição.\n\n"
       "**Estabeleça o bom hábito ({y})**\n"
       "1. Torne-o evidente: Coloque o gatilho bem visível.\n"
       "2. Torne-o atraente: Associe-o a algo que você gosta.\n"
       "3. Torne-o fácil: Reduza os obstáculos ao mínimo (ex.: apenas 2 minutos).\n"
       "4. Torne-o satisfatório: Recompense-se logo em seguida."),
}

TERMS = {
'fr': {
 'Alkohol trinken': "Boire de l'alcool", 'Tee trinken': 'Boire du thé',
 'Binge Streaming': 'Regarder des séries en boucle', 'Hobby nachgehen': 'Pratiquer un loisir',
 'Auf der Couch liegen': 'Rester avachi sur le canapé', 'Stretching': 'Étirements',
 'Zu viel Fast Food': 'Trop de fast-food', 'Gesunder Snack': 'Snack sain',
 'Doomscrolling': 'Doomscrolling', 'Meditieren': 'Méditer',
 'Zuviel Fernsehen': 'Trop de télévision', 'Ein Buch lesen': 'Lire un livre',
 'Energy Drinks': 'Boissons énergisantes', 'Wasser trinken': "Boire de l'eau",
 'Fast Food': 'Fast-food', 'Gesund kochen': 'Cuisiner sainement',
 'Lieferdienst bestellen': 'Commander à emporter', 'Meal Prep': 'Meal prep (préparation des repas)',
 'Spam & Ablenkung': 'Spam et distractions', 'Digital Detox': 'Digital detox',
 'Glücksspiel/Lootboxen': "Jeux d'argent/Loot boxes", 'Sparen': 'Épargner',
 'Sinnlose Autofahrten': 'Trajets en voiture inutiles', 'Spazieren gehen': 'Se promener',
 'Statussymbole kaufen': 'Acheter des symboles de statut', 'Dankbarkeit üben': 'Pratiquer la gratitude',
 'Nächtliches Snacken': 'Grignoter la nuit', 'Intervallfasten': 'Jeûne intermittent',
 'Negativer News Feed': "Fil d'actualités négatif", 'Positives Journaling': 'Journal positif',
 'Online Shopping': 'Achats en ligne', 'Geld sparen': "Économiser de l'argent",
 'Zu viel Party': 'Trop de fêtes', 'Me-Time & Selfcare': 'Temps pour soi et bien-être',
 'Zu viel Koffein': 'Trop de caféine', 'Schlafroutine': 'Routine de sommeil',
 'Rauchen': 'Fumer', 'Atemübungen': 'Exercices de respiration',
},
'nl': {
 'Alkohol trinken': 'Alcohol drinken', 'Tee trinken': 'Thee drinken',
 'Binge Streaming': 'Bingewatchen', 'Hobby nachgehen': 'Een hobby beoefenen',
 'Auf der Couch liegen': 'Op de bank hangen', 'Stretching': 'Stretchen',
 'Zu viel Fast Food': 'Te veel fastfood', 'Gesunder Snack': 'Gezonde snack',
 'Doomscrolling': 'Doomscrollen', 'Meditieren': 'Mediteren',
 'Zuviel Fernsehen': 'Te veel tv kijken', 'Ein Buch lesen': 'Een boek lezen',
 'Energy Drinks': 'Energiedrankjes', 'Wasser trinken': 'Water drinken',
 'Fast Food': 'Fastfood', 'Gesund kochen': 'Gezond koken',
 'Lieferdienst bestellen': 'Eten laten bezorgen', 'Meal Prep': 'Meal prep (maaltijden voorbereiden)',
 'Spam & Ablenkung': 'Spam en afleiding', 'Digital Detox': 'Digitale detox',
 'Glücksspiel/Lootboxen': 'Gokken/Loot boxes', 'Sparen': 'Sparen',
 'Sinnlose Autofahrten': 'Zinloze autoritjes', 'Spazieren gehen': 'Wandelen',
 'Statussymbole kaufen': 'Statussymbolen kopen', 'Dankbarkeit üben': 'Dankbaarheid oefenen',
 'Nächtliches Snacken': "'s Nachts snacken", 'Intervallfasten': 'Intermitterend vasten',
 'Negativer News Feed': 'Negatieve nieuwsfeed', 'Positives Journaling': 'Positief journaling',
 'Online Shopping': 'Online shoppen', 'Geld sparen': 'Geld sparen',
 'Zu viel Party': 'Te veel feesten', 'Me-Time & Selfcare': 'Me-time & zelfzorg',
 'Zu viel Koffein': 'Te veel cafeïne', 'Schlafroutine': 'Slaaproutine',
 'Rauchen': 'Roken', 'Atemübungen': 'Ademhalingsoefeningen',
},
'pt': {
 'Alkohol trinken': 'Beber álcool', 'Tee trinken': 'Beber chá',
 'Binge Streaming': 'Maratonas de séries', 'Hobby nachgehen': 'Dedicar-se a um hobby',
 'Auf der Couch liegen': 'Ficar deitado no sofá', 'Stretching': 'Alongamentos',
 'Zu viel Fast Food': 'Demasiada fast food', 'Gesunder Snack': 'Snack saudável',
 'Doomscrolling': 'Doomscrolling', 'Meditieren': 'Meditar',
 'Zuviel Fernsehen': 'Demasiada televisão', 'Ein Buch lesen': 'Ler um livro',
 'Energy Drinks': 'Bebidas energéticas', 'Wasser trinken': 'Beber água',
 'Fast Food': 'Fast food', 'Gesund kochen': 'Cozinhar de forma saudável',
 'Lieferdienst bestellen': 'Pedir comida ao domicílio', 'Meal Prep': 'Meal prep (preparação de refeições)',
 'Spam & Ablenkung': 'Spam e distrações', 'Digital Detox': 'Digital detox',
 'Glücksspiel/Lootboxen': 'Jogos de azar/Loot boxes', 'Sparen': 'Poupar',
 'Sinnlose Autofahrten': 'Viagens de carro sem sentido', 'Spazieren gehen': 'Dar um passeio',
 'Statussymbole kaufen': 'Comprar símbolos de estatuto', 'Dankbarkeit üben': 'Praticar gratidão',
 'Nächtliches Snacken': 'Petiscar à noite', 'Intervallfasten': 'Jejum intermitente',
 'Negativer News Feed': 'Feed de notícias negativo', 'Positives Journaling': 'Diário positivo',
 'Online Shopping': 'Compras online', 'Geld sparen': 'Poupar dinheiro',
 'Zu viel Party': 'Demasiadas festas', 'Me-Time & Selfcare': 'Tempo para ti e autocuidado',
 'Zu viel Koffein': 'Demasiada cafeína', 'Schlafroutine': 'Rotina de sono',
 'Rauchen': 'Fumar', 'Atemübungen': 'Exercícios de respiração',
},
'pt-BR': {
 'Alkohol trinken': 'Beber álcool', 'Tee trinken': 'Beber chá',
 'Binge Streaming': 'Maratonar séries', 'Hobby nachgehen': 'Praticar um hobby',
 'Auf der Couch liegen': 'Ficar deitado no sofá', 'Stretching': 'Alongamento',
 'Zu viel Fast Food': 'Fast food em excesso', 'Gesunder Snack': 'Lanche saudável',
 'Doomscrolling': 'Doomscrolling', 'Meditieren': 'Meditar',
 'Zuviel Fernsehen': 'Televisão em excesso', 'Ein Buch lesen': 'Ler um livro',
 'Energy Drinks': 'Energéticos', 'Wasser trinken': 'Beber água',
 'Fast Food': 'Fast food', 'Gesund kochen': 'Cozinhar de forma saudável',
 'Lieferdienst bestellen': 'Pedir delivery', 'Meal Prep': 'Meal prep (preparo de refeições)',
 'Spam & Ablenkung': 'Spam e distrações', 'Digital Detox': 'Detox digital',
 'Glücksspiel/Lootboxen': 'Apostas/Loot boxes', 'Sparen': 'Economizar',
 'Sinnlose Autofahrten': 'Passeios de carro sem sentido', 'Spazieren gehen': 'Caminhar',
 'Statussymbole kaufen': 'Comprar símbolos de status', 'Dankbarkeit üben': 'Praticar gratidão',
 'Nächtliches Snacken': 'Beliscar à noite', 'Intervallfasten': 'Jejum intermitente',
 'Negativer News Feed': 'Feed de notícias negativo', 'Positives Journaling': 'Diário positivo',
 'Online Shopping': 'Compras online', 'Geld sparen': 'Economizar dinheiro',
 'Zu viel Party': 'Festas em excesso', 'Me-Time & Selfcare': 'Tempo para si e autocuidado',
 'Zu viel Koffein': 'Cafeína em excesso', 'Schlafroutine': 'Rotina de sono',
 'Rauchen': 'Fumar', 'Atemübungen': 'Exercícios de respiração',
},
}

SIMPLE = {
('screenTime.limit.confirm.title','fr'): "Es-tu sûr(e) ?",
('screenTime.schedule.locked.title','fr'): "Programme en cours",
('screenTime.strictMode.active','fr'): "Activer le mode protection",
('screenTime.strictMode.title','fr'): "Mode protection",
('sex.none','fr'): "Sélectionner",
('shop.badge.popular','fr'): "Populaire",
('shop.category.powerups','fr'): "POWER-UPS",
('shop.seeds.desc','fr'): "Crée tes propres habitudes. Pour 10 graines, tu peux créer tes propres habitudes.",
('shop.tab.header','fr'): "Habitudes",
('shop.tab.items.short','fr'): "Mauvaises",
('shop.tab.plants.short','fr'): "Bonnes",
('spin_button_later','fr'): "Plus tard",
('statistik_periode_woche','fr'): "Semaine",
('stats.consistency.perfect','fr'): "Parfait !",
('streak.mode.week','fr'): "Semaine",
('support.reason.question','fr'): "Question",
('time.month','fr'): "Mois",
('time.week','fr'): "Semaine",
('time.year','fr'): "Année",
('timer.mode.standard','fr'): "Standard",
('titel.bambusorchidee','fr'): "Double Diva",
('titel.edelweiss','fr'): "Soldat d'Élite de l'Edelweiss",
('todos.tab.general','fr'): "Tâches générales",
('tour_1_desc','fr'): "Accomplis tes habitudes en faisant glisser la barre de progression de la carte vers la droite pour faire grandir la plante.",
('trigger.fatigue','fr'): "Fatigue",
('trigger.selection_title','fr'): "Déclencheurs",
('wasser.leer.body','fr'): "Arrose tes plantes pour voir les statistiques.",
('wasser.leer.titel','fr'): "Pas encore d'eau",
('widget_interactive_routine_title','fr'): "Routine (Pro)",
('widget_water_alltime','fr'): "TOTAL",
('Wiederherstellung erfolgreich','fr'): "Restauration réussie",

('screenTime.limit.confirm.title','nl'): "Weet je het zeker?",
('screenTime.strictMode.title','nl'): "Beschermingsmodus",
('shop.tab.items.short','nl'): "Slechte",
('spin_button_later','nl'): "Later",
('statistik_periode_woche','nl'): "Week",
('stats.consistency.perfect','nl'): "Perfect!",
('streak.mode.week','nl'): "Week",
('time.week','nl'): "Week",
('titel.edelweiss','nl'): "Edelweiss-Elitesoldaat",
('todos.tab.general','nl'): "Algemene taken",
('tour_1_desc','nl'): "Voltooi je gewoontes door de voortgangsbalk op de kaart naar rechts te schuiven om de plant te laten groeien.",
('trigger.selection_title','nl'): "Triggers",
('wasser.leer.body','nl'): "Geef je planten water om statistieken te zien.",
('widget_water_alltime','nl'): "TOTAAL",

('screenTime.schedule.locked.title','pt'): "Horário em curso",
('screenTime.strictMode.active','pt'): "Ativar modo de proteção",
('screenTime.strictMode.title','pt'): "Modo de proteção",
('shop.badge.popular','pt'): "Popular",
('shop.category.powerups','pt'): "POWER-UPS",
('shop.tab.header','pt'): "Hábitos",
('support.reason.question','pt'): "Pergunta",
('titel.edelweiss','pt'): "Soldado de Elite do Edelvéiss",
('tour_1_desc','pt'): "Completa os teus hábitos deslizando a barra de progresso no cartão para a direita, para fazer a planta crescer.",
('Wiederherstellung erfolgreich','pt'): "Restauro concluído com sucesso",

('screenTime.schedule.locked.title','pt-BR'): "Programação em andamento",
('screenTime.strictMode.active','pt-BR'): "Ativar modo de proteção",
('shop.badge.popular','pt-BR'): "Popular",
('shop.category.powerups','pt-BR'): "POWER-UPS",
('shop.tab.items.short','pt-BR'): "Ruins",
('time.month','pt-BR'): "Mês",
('time.week','pt-BR'): "Semana",
('time.year','pt-BR'): "Ano",
('todos.tab.general','pt-BR'): "Tarefas gerais",
('tour_1_desc','pt-BR'): "Complete seus hábitos deslizando a barra de progresso no cartão para a direita, para fazer a planta crescer.",
('wasser.leer.titel','pt-BR'): "Ainda sem água",
('widget_water_alltime','pt-BR'): "TOTAL",
('Wiederherstellung erfolgreich','pt-BR'): "Restauração concluída com sucesso",

('shop.seeds.desc', 'pt-BR'): "Crie seus próprios hábitos. Por 10 sementes, você pode criar seus próprios hábitos.",
('wasser.leer.body', 'pt-BR'): "Regue suas plantas para ver as estatísticas.",
('wasser.leer.titel', 'pt'): "Nenhuma água até agora",
('widget_water_alltime', 'pt'): "TOTAL",
('Wiederherstellung erfolgreich', 'nl'): "Herstel succesvol"
}

impact_re = re.compile(r"^Diese Gewohnheit \((.+?)\) kostet dich langfristig Energie, Zeit und Geld\. Sie hindert dich daran, dein volles Potenzial auszuschöpfen\.$")
tips_re = re.compile(r"loswerden \((.+?)\)\*\*.*?etablieren \((.+?)\)\*\*", re.DOTALL)

with open('Localizable.xcstrings', encoding='utf-8') as f:
    catalog = json.load(f)

count = 0
for entry in batch:
    key, lang, orig = entry['key'], entry['language'], entry['original_text']
    translated = None

    m = impact_re.match(orig)
    if m and lang in IMPACT_TMPL:
        x_de = m.group(1)
        x_t = TERMS[lang].get(x_de, x_de)
        translated = IMPACT_TMPL[lang].format(x=x_t)

    if translated is None:
        m2 = tips_re.search(orig)
        if m2 and lang in TIPS_TMPL:
            x_de, y_de = m2.group(1), m2.group(2)
            x_t = TERMS[lang].get(x_de, x_de)
            y_t = TERMS[lang].get(y_de, y_de)
            translated = TIPS_TMPL[lang].format(x=x_t, y=y_t)

    if translated is None:
        translated = SIMPLE.get((key, lang))

    if translated:
        if key in catalog["strings"]:
            if "localizations" not in catalog["strings"][key]:
                catalog["strings"][key]["localizations"] = {}
            if lang not in catalog["strings"][key]["localizations"]:
                catalog["strings"][key]["localizations"][lang] = {}
            
            catalog["strings"][key]["localizations"][lang]["stringUnit"] = {
                "state": "translated",
                "value": translated
            }
            count += 1
    else:
        # Fallback if something wasn't caught, though we covered the 5 unresolved
        print(f"Warning: could not translate {key} for {lang} (Orig: {orig})")

with open('Localizable.xcstrings', 'w', encoding='utf-8') as f:
    json.dump(catalog, f, ensure_ascii=False, indent=2)

print(f"Successfully applied {count} patches to Localizable.xcstrings.")
