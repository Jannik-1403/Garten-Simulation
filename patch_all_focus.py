import json

file_path = 'Garten_Simulation/Localizable.xcstrings'
with open(file_path, 'r', encoding='utf-8') as f:
    data = json.load(f)

translations = {
    "focus.generic.title": {
        "en": "Start Focus", "fr": "Démarrer la concentration", "es": "Iniciar enfoque",
        "it": "Inizia concentrazione", "pt": "Iniciar foco", "nl": "Focus starten",
        "pl": "Rozpocznij skupienie", "tr": "Odaklanmayı başlat", "ja": "集中を開始",
        "ko": "집중 시작", "zh-Hant": "開始專注"
    },
    "focus.generic.subtitle": {
        "en": "What do you want to achieve in this session?", "fr": "Que souhaitez-vous accomplir lors de cette session ?",
        "es": "¿Qué quieres lograr en esta sesión?", "it": "Cosa vuoi ottenere in questa sessione?",
        "pt": "O que você quer alcançar nesta sessão?", "nl": "Wat wil je bereiken in deze sessie?",
        "pl": "Co chcesz osiągnąć podczas tej sesji?", "tr": "Bu oturumda ne başarmak istiyorsunuz?",
        "ja": "このセッションで何を達成したいですか？", "ko": "이번 세션에서 무엇을 달성하고 싶나요?",
        "zh-Hant": "你想在這次會議中實現什麼？"
    },
    "focus.generic.placeholder": {
        "en": "e.g. Homework, Reading, ...", "fr": "ex. Devoirs, Lecture, ...",
        "es": "ej. Tareas, Leer, ...", "it": "es. Compiti, Lettura, ...",
        "pt": "ex. Lição de casa, Leitura, ...", "nl": "bijv. Huiswerk, Lezen, ...",
        "pl": "np. Zadania domowe, Czytanie, ...", "tr": "ör. Ödev, Okuma, ...",
        "ja": "例：宿題、読書など...", "ko": "예: 숙제, 독서...",
        "zh-Hant": "例如：作業、閱讀..."
    },
    "profile.focus.title": {
        "en": "Focus", "fr": "Concentration", "es": "Enfoque", "it": "Concentrazione",
        "pt": "Foco", "nl": "Focus", "pl": "Skupienie", "tr": "Odak", "ja": "集中",
        "ko": "집중", "zh-Hant": "專注"
    },
    "profile.focus.start": {
        "en": "Start", "fr": "Démarrer", "es": "Iniciar", "it": "Inizia",
        "pt": "Iniciar", "nl": "Starten", "pl": "Rozpocznij", "tr": "Başlat",
        "ja": "開始", "ko": "시작", "zh-Hant": "開始"
    },
    "focus.phone_prompt.title": {
        "en": "Will you put the phone away?", "fr": "Allez-vous ranger votre téléphone ?",
        "es": "¿Dejarás el teléfono a un lado?", "it": "Metterai via il telefono?",
        "pt": "Vai guardar o telemóvel?", "nl": "Leg je de telefoon weg?",
        "pl": "Odłożysz telefon?", "tr": "Telefonu bir kenara koyacak mısın?",
        "ja": "スマホを置きますか？", "ko": "휴대폰을 치우시겠습니까?",
        "zh-Hant": "你會把手機放下嗎？"
    },
    "focus.phone_prompt.yes": {
        "en": "Yes, put away", "fr": "Oui, le ranger", "es": "Sí, guardarlo",
        "it": "Sì, mettilo via", "pt": "Sim, guardar", "nl": "Ja, wegleggen",
        "pl": "Tak, odłożę", "tr": "Evet, uzağa koy", "ja": "はい、置きます",
        "ko": "네, 치워둡니다", "zh-Hant": "是的，放下"
    },
    "focus.phone_prompt.no": {
        "en": "No, I need it", "fr": "Non, j'en ai besoin", "es": "No, lo necesito",
        "it": "No, mi serve", "pt": "Não, eu preciso", "nl": "Nee, ik heb het nodig",
        "pl": "Nie, potrzebuję go", "tr": "Hayır, ihtiyacım var", "ja": "いいえ、必要です",
        "ko": "아니요, 필요합니다", "zh-Hant": "不，我需要它"
    },
    "focus.phone_prompt.message": {
        "en": "Afterwards, select the apps that should be blocked for this focus.",
        "fr": "Ensuite, sélectionnez les applications qui doivent être bloquées pour cette session de concentration.",
        "es": "Después, selecciona las aplicaciones que deben bloquearse para este enfoque.",
        "it": "Successivamente, seleziona le app che dovrebbero essere bloccate per questa concentrazione.",
        "pt": "Em seguida, selecione os aplicativos que devem ser bloqueados para este foco.",
        "nl": "Selecteer daarna de apps die voor deze focus geblokkeerd moeten worden.",
        "pl": "Następnie wybierz aplikacje, które powinny zostać zablokowane na czas tego skupienia.",
        "tr": "Ardından, bu odak için engellenmesi gereken uygulamaları seçin.",
        "ja": "その後、この集中のためにブロックするアプリを選択してください。",
        "ko": "그런 다음 이 집중에 대해 차단해야 하는 앱을 선택하세요.",
        "zh-Hant": "然後選擇要為此焦點阻止的應用程式。"
    }
}

for key, lang_dict in translations.items():
    if key in data['strings']:
        for lang, text in lang_dict.items():
            if 'localizations' not in data['strings'][key]:
                data['strings'][key]['localizations'] = {}
            data['strings'][key]['localizations'][lang] = {
                "stringUnit": {
                    "state": "translated",
                    "value": text
                }
            }

with open(file_path, 'w', encoding='utf-8') as f:
    json.dump(data, f, ensure_ascii=False, indent=2)

print("All missing translations injected successfully.")
