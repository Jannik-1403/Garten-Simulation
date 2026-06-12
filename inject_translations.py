import re

app_strings_path = "/Users/jannikschill/Documents/Garten-Simulation/Garten_Simulation/Localization/AppStrings.swift"

translations_dict = {
    "10 Min Dehnen": {"de": "10 Min Dehnen", "en": "10 Min Stretching", "es": "10 min de estiramiento", "fr": "10 min d'étirement", "it": "10 min di stretching", "pt": "10 min de alongamento", "ja": "10分間のストレッチ", "ko": "10분 스트레칭", "pl": "10 min rozciągania", "nl": "10 min stretchen", "tr": "10 dk esneme"},
    "Workout aufwärmen": {"de": "Workout aufwärmen", "en": "Warm up", "es": "Calentamiento", "fr": "Échauffement", "it": "Riscaldamento", "pt": "Aquecimento", "ja": "ウォームアップ", "ko": "워밍업", "pl": "Rozgrzewka", "nl": "Opwarming", "tr": "Isınma"},
    "Ausrüstung richten": {"de": "Ausrüstung richten", "en": "Prepare equipment", "es": "Preparar equipo", "fr": "Préparer l'équipement", "it": "Preparare l'attrezzatura", "pt": "Preparar equipamento", "ja": "機材の準備", "ko": "장비 준비", "pl": "Przygotuj sprzęt", "nl": "Apparatuur voorbereiden", "tr": "Ekipmanı hazırla"},
    "Wasser trinken": {"de": "Wasser trinken", "en": "Drink water", "es": "Beber agua", "fr": "Boire de l'eau", "it": "Bere acqua", "pt": "Beber água", "ja": "水を飲む", "ko": "물 마시기", "pl": "Pij wodę", "nl": "Water drinken", "tr": "Su iç"},
    "Gesundes Rezept planen": {"de": "Gesundes Rezept planen", "en": "Plan healthy recipe", "es": "Planear receta sana", "fr": "Recette saine", "it": "Ricetta sana", "pt": "Receita saudável", "ja": "健康的なレシピ", "ko": "건강한 레시피", "pl": "Zdrowy przepis", "nl": "Gezond recept", "tr": "Sağlıklı tarif"},
    "Ernährungstagebuch": {"de": "Ernährungstagebuch", "en": "Food diary", "es": "Diario de comida", "fr": "Journal alimentaire", "it": "Diario alimentare", "pt": "Diário alimentar", "ja": "食事日記", "ko": "식단 일기", "pl": "Dziennik jedzenia", "nl": "Voedingsdagboek", "tr": "Yemek günlüğü"},
    "Tiefes Atmen": {"de": "Tiefes Atmen", "en": "Deep breathing", "es": "Respiración profunda", "fr": "Respiration profonde", "it": "Respirazione profonda", "pt": "Respiração profunda", "ja": "深呼吸", "ko": "심호흡", "pl": "Głębokie oddychanie", "nl": "Diep ademhalen", "tr": "Derin nefes"},
    "Journaling": {"de": "Journaling", "en": "Journaling", "es": "Diario", "fr": "Journal intime", "it": "Diario", "pt": "Diário", "ja": "日記", "ko": "일기", "pl": "Dziennik", "nl": "Dagboek", "tr": "Günlük"},
    "Meditation starten": {"de": "Meditation starten", "en": "Start meditation", "es": "Iniciar meditación", "fr": "Commencer la méditation", "it": "Inizia meditazione", "pt": "Iniciar meditação", "ja": "瞑想を開始", "ko": "명상 시작", "pl": "Rozpocznij medytację", "nl": "Begin met meditatie", "tr": "Meditasyona başla"},
    "1 Kapitel lesen": {"de": "1 Kapitel lesen", "en": "Read 1 chapter", "es": "Leer 1 capítulo", "fr": "Lire 1 chapitre", "it": "Leggi 1 capitolo", "pt": "Ler 1 capítulo", "ja": "1章を読む", "ko": "1장 읽기", "pl": "Przeczytaj 1 rozdział", "nl": "Lees 1 hoofdstuk", "tr": "1 bölüm oku"},
    "Vokabeln wiederholen": {"de": "Vokabeln wiederholen", "en": "Review vocabulary", "es": "Repasar vocabulario", "fr": "Réviser le vocabulaire", "it": "Ripassa i vocaboli", "pt": "Rever vocabulário", "ja": "単語の復習", "ko": "단어 복습", "pl": "Powtórz słówka", "nl": "Woordenschat herhalen", "tr": "Kelime tekrarı"},
    "Zusammenfassung schreiben": {"de": "Zusammenfassung schreiben", "en": "Write summary", "es": "Escribir resumen", "fr": "Écrire un résumé", "it": "Scrivi riassunto", "pt": "Escrever resumo", "ja": "要約を書く", "ko": "요약 쓰기", "pl": "Napisz podsumowanie", "nl": "Samenvatting schrijven", "tr": "Özet yaz"},
    "Zimmer aufräumen": {"de": "Zimmer aufräumen", "en": "Tidy room", "es": "Ordenar habitación", "fr": "Ranger la chambre", "it": "Riordinare la stanza", "pt": "Arrumar quarto", "ja": "部屋を片付ける", "ko": "방 정리", "pl": "Posprzątaj pokój", "nl": "Kamer opruimen", "tr": "Odayı topla"},
    "Pflanzen gießen": {"de": "Pflanzen gießen", "en": "Water plants", "es": "Regar plantas", "fr": "Arroser les plantes", "it": "Innaffia le piante", "pt": "Regar plantas", "ja": "植物に水をやる", "ko": "식물 물주기", "pl": "Podlej rośliny", "nl": "Planten water geven", "tr": "Bitkileri sula"},
    "Wochenplan erstellen": {"de": "Wochenplan erstellen", "en": "Create weekly plan", "es": "Plan semanal", "fr": "Plan hebdomadaire", "it": "Piano settimanale", "pt": "Plano semanal", "ja": "週間計画", "ko": "주간 계획", "pl": "Plan tygodniowy", "nl": "Weekplan", "tr": "Haftalık plan"},
    "Ausgaben tracken": {"de": "Ausgaben tracken", "en": "Track expenses", "es": "Registrar gastos", "fr": "Suivre les dépenses", "it": "Traccia le spese", "pt": "Registar despesas", "ja": "支出を記録", "ko": "지출 기록", "pl": "Śledź wydatki", "nl": "Uitgaven bijhouden", "tr": "Harcamaları takip et"},
    "Budget überprüfen": {"de": "Budget überprüfen", "en": "Check budget", "es": "Revisar presupuesto", "fr": "Vérifier le budget", "it": "Controlla il budget", "pt": "Verificar orçamento", "ja": "予算を確認", "ko": "예산 확인", "pl": "Sprawdź budżet", "nl": "Budget controleren", "tr": "Bütçeyi kontrol et"},
    "Rechnungen bezahlen": {"de": "Rechnungen bezahlen", "en": "Pay bills", "es": "Pagar facturas", "fr": "Payer les factures", "it": "Paga le bollette", "pt": "Pagar contas", "ja": "請求書を支払う", "ko": "청구서 지불", "pl": "Zapłać rachunki", "nl": "Rekeningen betalen", "tr": "Faturaları öde"},
    "Fokus setzen": {"de": "Fokus setzen", "en": "Set focus", "es": "Fijar foco", "fr": "Fixer un objectif", "it": "Imposta il focus", "pt": "Definir foco", "ja": "フォーカスを設定", "ko": "집중 목표 설정", "pl": "Ustaw cel", "nl": "Doel bepalen", "tr": "Hedef belirle"},
    "Handy weglegen": {"de": "Handy weglegen", "en": "Put phone away", "es": "Guardar el móvil", "fr": "Ranger le téléphone", "it": "Metti via il telefono", "pt": "Guardar o telemóvel", "ja": "スマホを置く", "ko": "휴대폰 치우기", "pl": "Odłóż telefon", "nl": "Telefoon wegleggen", "tr": "Telefonu bırak"},
    "Ablenkungen blockieren": {"de": "Ablenkungen blockieren", "en": "Block distractions", "es": "Bloquear distracciones", "fr": "Bloquer les distractions", "it": "Blocca le distrazioni", "pt": "Bloquear distrações", "ja": "気を散らすものをブロック", "ko": "방해요소 차단", "pl": "Zablokuj rozpraszacze", "nl": "Afleidingen blokkeren", "tr": "Dikkat dağıtıcıları engelle"},
    "Niedrig": {"de": "Niedrig", "en": "Low", "es": "Baja", "fr": "Basse", "it": "Bassa", "pt": "Baixa", "ja": "低", "ko": "낮음", "pl": "Niski", "nl": "Laag", "tr": "Düşük"},
    "Mittel": {"de": "Mittel", "en": "Medium", "es": "Media", "fr": "Moyenne", "it": "Media", "pt": "Média", "ja": "中", "ko": "중간", "pl": "Średni", "nl": "Midden", "tr": "Orta"},
    "Hoch": {"de": "Hoch", "en": "High", "es": "Alta", "fr": "Haute", "it": "Alta", "pt": "Alta", "ja": "高", "ko": "높음", "pl": "Wysoki", "nl": "Hoog", "tr": "Yüksek"},
    "Ablenkungen weg": {"de": "Ablenkungen weg", "en": "Remove Distractions", "es": "Sin distracciones", "fr": "Pas de distractions", "it": "Nessuna distrazione", "pt": "Sem distrações", "ja": "気を散らさない", "ko": "방해요소 제거", "pl": "Bez rozpraszaczy", "nl": "Geen afleidingen", "tr": "Dikkat dağıtıcı yok"},
    "Schalte dein Handy jetzt auf 'Nicht stören' und lege es nach dieser Einrichtung außer Sichtweite.": {"de": "Schalte dein Handy jetzt auf 'Nicht stören' und lege es nach dieser Einrichtung außer Sichtweite.", "en": "Put your phone on 'Do Not Disturb' and place it out of sight after this setup.", "es": "Pon tu teléfono en 'No molestar' y guárdalo.", "fr": "Mets ton téléphone en 'Ne pas déranger' et range-le.", "it": "Metti il telefono su 'Non disturbare' e mettilo via.", "pt": "Põe o telemóvel no modo 'Não incomodar' e guarda-o.", "ja": "スマホを「おやすみモード」にして、見えない場所に置いてください。", "ko": "휴대폰을 '방해 금지' 모드로 설정하고 보이지 않는 곳에 두세요.", "pl": "Włącz tryb „Nie przeszkadzać” i odłóż telefon.", "nl": "Zet je telefoon op 'Niet storen' en leg hem weg.", "tr": "Telefonu 'Rahatsız Etmeyin' moduna alın ve uzağa koyun."},
    "Erledigt": {"de": "Erledigt", "en": "Done", "es": "Hecho", "fr": "Terminé", "it": "Fatto", "pt": "Feito", "ja": "完了", "ko": "완료", "pl": "Gotowe", "nl": "Klaar", "tr": "Tamam"},
    "Klares Ziel": {"de": "Klares Ziel", "en": "Clear Goal", "es": "Objetivo claro", "fr": "Objectif clair", "it": "Obiettivo chiaro", "pt": "Objetivo claro", "ja": "明確な目標", "ko": "명확한 목표", "pl": "Jasny cel", "nl": "Helder doel", "tr": "Net hedef"},
    "Was genau möchtest du in deiner Fokus-Zeit schaffen? Nimm dir einen Moment, um dich zu fokussieren.": {"de": "Was genau möchtest du in deiner Fokus-Zeit schaffen? Nimm dir einen Moment, um dich zu fokussieren.", "en": "What exactly do you want to achieve? Take a moment to focus.", "es": "¿Qué quieres lograr? Tómate un momento.", "fr": "Que veux-tu accomplir ? Prends un moment.", "it": "Cosa vuoi ottenere? Prenditi un momento.", "pt": "O que queres alcançar? Tira um momento.", "ja": "何を達成したいですか？少し考えてみましょう。", "ko": "무엇을 이루고 싶나요? 잠시 집중해 보세요.", "pl": "Co chcesz osiągnąć? Poświęć chwilę.", "nl": "Wat wil je bereiken? Neem een moment.", "tr": "Ne başarmak istersin? Bir an düşün."},
    "Timer starten": {"de": "Timer starten", "en": "Start Timer", "es": "Iniciar temporizador", "fr": "Démarrer le minuteur", "it": "Avvia il timer", "pt": "Iniciar temporizador", "ja": "タイマーを開始", "ko": "타이머 시작", "pl": "Uruchom minutnik", "nl": "Timer starten", "tr": "Sayacı başlat"},
    "Fokus-Session": {"de": "Fokus-Session", "en": "Focus Session", "es": "Sesión de enfoque", "fr": "Session de concentration", "it": "Sessione di focus", "pt": "Sessão de foco", "ja": "集中セッション", "ko": "집중 세션", "pl": "Sesja skupienia", "nl": "Focussessie", "tr": "Odaklanma oturumu"},
    "Dauer: %lld Minuten": {"de": "Dauer: %lld Minuten", "en": "Duration: %lld Minutes", "es": "Duración: %lld Minutos", "fr": "Durée: %lld Minutes", "it": "Durata: %lld Minuti", "pt": "Duração: %lld Minutos", "ja": "期間: %lld 分", "ko": "소요 시간: %lld 분", "pl": "Czas trwania: %lld Minut", "nl": "Duur: %lld Minuten", "tr": "Süre: %lld Dakika"},
    "Vorbereitung starten": {"de": "Vorbereitung starten", "en": "Start Preparation", "es": "Iniciar preparación", "fr": "Commencer la préparation", "it": "Inizia la preparazione", "pt": "Iniciar preparação", "ja": "準備を開始", "ko": "준비 시작", "pl": "Zacznij przygotowania", "nl": "Voorbereiding starten", "tr": "Hazırlığa başla"},
    "Neues Hauptziel...": {"de": "Neues Hauptziel...", "en": "New Main Goal...", "es": "Nuevo objetivo principal...", "fr": "Nouvel objectif principal...", "it": "Nuovo obiettivo principale...", "pt": "Novo objetivo principal...", "ja": "新しい主要目標...", "ko": "새로운 주요 목표...", "pl": "Nowy główny cel...", "nl": "Nieuw hoofddoel...", "tr": "Yeni ana hedef..."},
    "Aufgabe hinzufügen...": {"de": "Aufgabe hinzufügen...", "en": "Add Task...", "es": "Añadir tarea...", "fr": "Ajouter une tâche...", "it": "Aggiungi compito...", "pt": "Adicionar tarefa...", "ja": "タスクを追加...", "ko": "작업 추가...", "pl": "Dodaj zadanie...", "nl": "Taak toevoegen...", "tr": "Görev ekle..."},
    "Deine Ziele": {"de": "Deine Ziele", "en": "Your Goals", "es": "Tus objetivos", "fr": "Tes objectifs", "it": "I tuoi obiettivi", "pt": "Os teus objetivos", "ja": "あなたの目標", "ko": "당신의 목표", "pl": "Twoje cele", "nl": "Jouw doelen", "tr": "Hedeflerin"}
}

with open(app_strings_path, "r", encoding="utf-8") as f:
    content = f.read()

lines_to_add = []
for key, lang_dict in translations_dict.items():
    if f'"{key}"' in content:
        continue
    # Escape quotes
    escaped_dict = {k: v.replace('"', '\\"') for k, v in lang_dict.items()}
    dict_str = ", ".join([f'"{k}": "{v}"' for k, v in escaped_dict.items()])
    lines_to_add.append(f'        "{key}": [{dict_str}],\n')

if lines_to_add:
    pattern = r'\n\s*\]\n\}\n?$'
    match = re.search(pattern, content)
    if match:
        insert_pos = match.start()
        new_content = content[:insert_pos] + ",\n" + "".join(lines_to_add).rstrip(',\n') + content[insert_pos:]
        with open(app_strings_path, "w", encoding="utf-8") as f:
            f.write(new_content)
        print("Keys added successfully.")
    else:
        parts = content.rsplit(']', 1)
        new_content = parts[0].rstrip() + ",\n" + "".join(lines_to_add).rstrip(',\n') + "\n    ]" + parts[1]
        with open(app_strings_path, "w", encoding="utf-8") as f:
            f.write(new_content)
else:
    print("No new keys to add.")

