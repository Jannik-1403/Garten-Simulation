import json
import os

filepath = '/Users/jannikschill/Documents/Garten-Simulation/Garten_Simulation/Localizable.xcstrings'

with open(filepath, 'r', encoding='utf-8') as f:
    data = json.load(f)

translations = {
    "habit.gratitude.mood.title": {
        "de": "Wie hast du dich heute gefühlt?",
        "en": "How did you feel today?",
        "fr": "Comment vous êtes-vous senti aujourd'hui ?",
        "es": "¿Cómo te sentiste hoy?",
        "it": "Come ti sei sentito oggi?",
        "pt": "Como você se sentiu hoje?",
        "nl": "Hoe voelde je je vandaag?",
        "tr": "Bugün nasıl hissettin?",
        "pl": "Jak się dzisiaj czułeś?",
        "ru": "Как вы себя чувствовали сегодня?",
        "ja": "今日はどんな気分でしたか？",
        "ko": "오늘 기분이 어땠나요?",
        "zh": "你今天感觉如何？",
        "ar": "كيف شعرت اليوم؟",
        "hi": "आज आपने कैसा महसूस किया?",
        "sv": "Hur mådde du idag?",
        "da": "Hvordan havde du det i dag?"
    },
    "habit.gratitude.thankful.title": {
        "de": "Wofür warst du heute dankbar?",
        "en": "What were you grateful for today?",
        "fr": "De quoi étiez-vous reconnaissant aujourd'hui ?",
        "es": "¿De qué estuviste agradecido hoy?",
        "it": "Per cosa sei stato grato oggi?",
        "pt": "Pelo que você foi grato hoje?",
        "nl": "Waar was je vandaag dankbaar voor?",
        "tr": "Bugün neye şükrettin?",
        "pl": "Za co byłeś dzisiaj wdzięczny?",
        "ru": "За что вы были благодарны сегодня?",
        "ja": "今日感謝したことは何ですか？",
        "ko": "오늘 무엇에 감사했나요?",
        "zh": "你今天对什么感到感恩？",
        "ar": "على ماذا كنت ممتناً اليوم؟",
        "hi": "आज आप किस बात के लिए आभारी थे?",
        "sv": "Vad var du tacksam för idag?",
        "da": "Hvad var du taknemmelig for i dag?"
    },
    "habit.gratitude.well_done.title": {
        "de": "Was hast du heute gut gemacht?",
        "en": "What did you do well today?",
        "fr": "Qu'avez-vous bien fait aujourd'hui ?",
        "es": "¿Qué hiciste bien hoy?",
        "it": "Cosa hai fatto bene oggi?",
        "pt": "O que você fez bem hoje?",
        "nl": "Wat heb je vandaag goed gedaan?",
        "tr": "Bugün neyi iyi yaptın?",
        "pl": "Co dzisiaj zrobiłeś dobrze?",
        "ru": "Что вы сделали хорошо сегодня?",
        "ja": "今日うまくできたことは何ですか？",
        "ko": "오늘 무엇을 잘 했나요?",
        "zh": "你今天做得好的是什么？",
        "ar": "ما الذي فعلته جيداً اليوم؟",
        "hi": "आज आपने क्या अच्छा किया?",
        "sv": "Vad gjorde du bra idag?",
        "da": "Hvad gjorde du godt i dag?"
    },
    "habit.gratitude.differently.title": {
        "de": "Was würdest du rückblickend anders machen?",
        "en": "What would you do differently in retrospect?",
        "fr": "Que feriez-vous différemment avec le recul ?",
        "es": "¿Qué harías diferente en retrospectiva?",
        "it": "Cosa faresti diversamente col senno di poi?",
        "pt": "O que você faria diferente em retrospecto?",
        "nl": "Wat zou je achteraf gezien anders doen?",
        "tr": "Geriye dönüp baktığında neyi farklı yapardın?",
        "pl": "Co byś zrobił inaczej z perspektywy czasu?",
        "ru": "Что бы вы сделали по-другому, оглядываясь назад?",
        "ja": "振り返ってみて、何を違うようにしますか？",
        "ko": "돌이켜보면 무엇을 다르게 하시겠습니까?",
        "zh": "回想起来你会有什么不同的做法？",
        "ar": "ما الذي كنت ستفعله بشكل مختلف بالنظر إلى الماضي؟",
        "hi": "पीछे मुड़कर देखें तो आप क्या अलग करते?",
        "sv": "Vad skulle du göra annorlunda i efterhand?",
        "da": "Hvad ville du gøre anderledes i bakspejlet?"
    },
    "habit.gratitude.tomorrow.title": {
        "de": "Was möchtest du morgen besser machen?",
        "en": "What do you want to do better tomorrow?",
        "fr": "Que voulez-vous faire de mieux demain ?",
        "es": "¿Qué quieres hacer mejor mañana?",
        "it": "Cosa vuoi fare meglio domani?",
        "pt": "O que você quer fazer melhor amanhã?",
        "nl": "Wat wil je morgen beter doen?",
        "tr": "Yarın neyi daha iyi yapmak istersin?",
        "pl": "Co chcesz jutro zrobić lepiej?",
        "ru": "Что вы хотите сделать лучше завтра?",
        "ja": "明日は何を改善したいですか？",
        "ko": "내일은 무엇을 더 잘하고 싶나요?",
        "zh": "明天你想在哪些方面做得更好？",
        "ar": "ما الذي تريد أن تفعله بشكل أفضل غداً؟",
        "hi": "कल आप क्या बेहतर करना चाहते हैं?",
        "sv": "Vad vill du göra bättre imorgon?",
        "da": "Hvad vil du gøre bedre i morgen?"
    },
    "habit.gratitude.save_button": {
        "de": "Eintrag speichern",
        "en": "Save entry",
        "fr": "Enregistrer l'entrée",
        "es": "Guardar entrada",
        "it": "Salva voce",
        "pt": "Salvar entrada",
        "nl": "Invoer opslaan",
        "tr": "Girdiyi kaydet",
        "pl": "Zapisz wpis",
        "ru": "Сохранить запись",
        "ja": "エントリーを保存",
        "ko": "항목 저장",
        "zh": "保存记录",
        "ar": "حفظ الإدخال",
        "hi": "प्रविष्टि सहेजें",
        "sv": "Spara inlägg",
        "da": "Gem indtastning"
    },
    "habit.gratitude.fast_mode.title": {
        "de": "Schnell-Tagesreview",
        "en": "Quick Daily Review",
        "fr": "Bilan Quotidien Rapide",
        "es": "Revisión Diaria Rápida",
        "it": "Revisione Quotidiana Rapida",
        "pt": "Revisão Diária Rápida",
        "nl": "Snelle Dagelijkse Evaluatie",
        "tr": "Hızlı Günlük İnceleme",
        "pl": "Szybki Przegląd Dnia",
        "ru": "Быстрый Обзор Дня",
        "ja": "クイックデイリーレビュー",
        "ko": "빠른 일일 리뷰",
        "zh": "快速每日回顾",
        "ar": "المراجعة اليومية السريعة",
        "hi": "त्वरित दैनिक समीक्षा",
        "sv": "Snabb Daglig Genomgång",
        "da": "Hurtig Daglig Gennemgang"
    },
    "habit.gratitude.expand.title": {
        "de": "Volle Reflexion",
        "en": "Full Reflection",
        "fr": "Réflexion Complète",
        "es": "Reflexión Completa",
        "it": "Riflessione Completa",
        "pt": "Reflexão Completa",
        "nl": "Volledige Reflectie",
        "tr": "Tam Yansıma",
        "pl": "Pełna Refleksja",
        "ru": "Полное Размышление",
        "ja": "フルリフレクション",
        "ko": "전체 리플렉션",
        "zh": "完整反思",
        "ar": "انعكاس كامل",
        "hi": "पूर्ण प्रतिबिंब",
        "sv": "Fullständig Reflektion",
        "da": "Fuld Refleksion"
    },
    "habit.gratitude.collapse.title": {
        "de": "Weniger anzeigen",
        "en": "Show less",
        "fr": "Afficher moins",
        "es": "Mostrar menos",
        "it": "Mostra meno",
        "pt": "Mostrar menos",
        "nl": "Minder weergeven",
        "tr": "Daha az göster",
        "pl": "Pokaż mniej",
        "ru": "Показать меньше",
        "ja": "表示を減らす",
        "ko": "간략히 보기",
        "zh": "显示更少",
        "ar": "إظهار أقل",
        "hi": "कम दिखाएं",
        "sv": "Visa mindre",
        "da": "Vis mindre"
    },
    "habit.gratitude.thankful.placeholder": {
        "de": "Z.B. für einen Spaziergang in der Sonne...",
        "en": "E.g., for a walk in the sun...",
        "fr": "Par ex. pour une promenade au soleil...",
        "es": "Ej., por un paseo bajo el sol...",
        "it": "Es. per una passeggiata al sole...",
        "pt": "Ex., por um passeio ao sol...",
        "nl": "Bijv. voor een wandeling in de zon...",
        "tr": "Örn., güneşte bir yürüyüş için...",
        "pl": "Np. za spacer w słońcu...",
        "ru": "Напр., за прогулку на солнце...",
        "ja": "例：太陽の下での散歩...",
        "ko": "예: 햇살 아래 산책하기...",
        "zh": "例如，在阳光下散步...",
        "ar": "على سبيل المثال، للمشي في الشمس...",
        "hi": "उदा., धूप में सैर के लिए...",
        "sv": "T.ex., för en promenad i solen...",
        "da": "F.eks., for en gåtur i solen..."
    },
    "habit.gratitude.well_done.placeholder": {
        "de": "Z.B. an meiner Aufgabe drangeblieben...",
        "en": "E.g., stayed focused on my task...",
        "fr": "Par ex. je suis resté concentré sur ma tâche...",
        "es": "Ej., me mantuve enfocado en mi tarea...",
        "it": "Es. sono rimasto concentrato sul mio compito...",
        "pt": "Ex., me mantive focado na minha tarefa...",
        "nl": "Bijv. gefocust gebleven op mijn taak...",
        "tr": "Örn., görevime odaklandım...",
        "pl": "Np. skupiłem się na zadaniu...",
        "ru": "Напр., оставался сосредоточенным на задаче...",
        "ja": "例：タスクに集中した...",
        "ko": "예: 내 일에 집중했다...",
        "zh": "例如，专注于我的任务...",
        "ar": "على سبيل المثال، بقيت مركزاً على مهمتي...",
        "hi": "उदा., अपने काम पर ध्यान केंद्रित रखा...",
        "sv": "T.ex., förblev fokuserad på min uppgift...",
        "da": "F.eks., forblev fokuseret på min opgave..."
    },
    "habit.gratitude.differently.placeholder": {
        "de": "Z.B. mich nicht über Kleinigkeiten ärgern...",
        "en": "E.g., not getting annoyed over little things...",
        "fr": "Par ex. ne pas m'énerver pour des petits riens...",
        "es": "Ej., no enojarme por cosas pequeñas...",
        "it": "Es. non arrabbiarmi per le piccole cose...",
        "pt": "Ex., não me irritar com pequenas coisas...",
        "nl": "Bijv. me niet ergeren aan kleine dingen...",
        "tr": "Örn., küçük şeylere sinirlenmemek...",
        "pl": "Np. nie denerwować się drobnostkami...",
        "ru": "Напр., не злиться по пустякам...",
        "ja": "例：些細なことでイライラしない...",
        "ko": "예: 사소한 일에 짜증내지 않기...",
        "zh": "例如，不为小事烦恼...",
        "ar": "على سبيل المثال، عدم الانزعاج من الأشياء الصغيرة...",
        "hi": "उदा., छोटी-छोटी बातों पर गुस्सा न करना...",
        "sv": "T.ex., att inte störa mig på småsaker...",
        "da": "F.eks., ikke blive irriteret over små ting..."
    },
    "habit.gratitude.tomorrow.placeholder": {
        "de": "Z.B. 10 Minuten früher schlafen gehen...",
        "en": "E.g., go to sleep 10 minutes earlier...",
        "fr": "Par ex. me coucher 10 minutes plus tôt...",
        "es": "Ej., dormir 10 minutos antes...",
        "it": "Es. andare a dormire 10 minuti prima...",
        "pt": "Ex., dormir 10 minutos mais cedo...",
        "nl": "Bijv. 10 minuten eerder gaan slapen...",
        "tr": "Örn., 10 dakika daha erken uyumak...",
        "pl": "Np. pójść spać 10 minut wcześniej...",
        "ru": "Напр., лечь спать на 10 минут раньше...",
        "ja": "例：10分早く寝る...",
        "ko": "예: 10분 일찍 자기...",
        "zh": "例如，提早10分钟睡觉...",
        "ar": "على سبيل المثال، النوم أبكر بـ 10 دقائق...",
        "hi": "उदा., 10 मिनट पहले सो जाना...",
        "sv": "T.ex., gå och lägga sig 10 minuter tidigare...",
        "da": "F.eks., gå i seng 10 minutter tidligere..."
    },
    "habit.gratitude.chip.family": {
        "de": "Familie", "en": "Family", "fr": "Famille", "es": "Familia", "it": "Famiglia", "pt": "Família", "nl": "Familie", "tr": "Aile", "pl": "Rodzina", "ru": "Семья", "ja": "家族", "ko": "가족", "zh": "家庭", "ar": "العائلة", "hi": "परिवार", "sv": "Familj", "da": "Familie"
    },
    "habit.gratitude.chip.health": {
        "de": "Gesundheit", "en": "Health", "fr": "Santé", "es": "Salud", "it": "Salute", "pt": "Saúde", "nl": "Gezondheid", "tr": "Sağlık", "pl": "Zdrowie", "ru": "Здоровье", "ja": "健康", "ko": "건강", "zh": "健康", "ar": "الصحة", "hi": "स्वास्थ्य", "sv": "Hälsa", "da": "Sundhed"
    },
    "habit.gratitude.chip.work": {
        "de": "Arbeit", "en": "Work", "fr": "Travail", "es": "Trabajo", "it": "Lavoro", "pt": "Trabalho", "nl": "Werk", "tr": "İş", "pl": "Praca", "ru": "Работа", "ja": "仕事", "ko": "직장", "zh": "工作", "ar": "العمل", "hi": "काम", "sv": "Arbete", "da": "Arbejde"
    },
    "habit.gratitude.chip.friends": {
        "de": "Freunde", "en": "Friends", "fr": "Amis", "es": "Amigos", "it": "Amici", "pt": "Amigos", "nl": "Vrienden", "tr": "Arkadaşlar", "pl": "Przyjaciele", "ru": "Друзья", "ja": "友達", "ko": "친구", "zh": "朋友", "ar": "الأصدقاء", "hi": "दोस्त", "sv": "Vänner", "da": "Venner"
    },
    "habit.gratitude.chip.small_things": {
        "de": "Kleinigkeit", "en": "Small Thing", "fr": "Petite Chose", "es": "Pequeña Cosa", "it": "Piccola Cosa", "pt": "Pequena Coisa", "nl": "Klein Ding", "tr": "Küçük Şey", "pl": "Drobnostka", "ru": "Мелочь", "ja": "些細なこと", "ko": "사소한 것", "zh": "小事", "ar": "شيء صغير", "hi": "छोटी बात", "sv": "Liten Sak", "da": "Lille Ting"
    },
    "habit.gratitude.chip.sport": {
        "de": "Sport", "en": "Sports", "fr": "Sport", "es": "Deportes", "it": "Sport", "pt": "Esportes", "nl": "Sport", "tr": "Spor", "pl": "Sport", "ru": "Спорт", "ja": "スポーツ", "ko": "스포츠", "zh": "运动", "ar": "الرياضة", "hi": "खेल", "sv": "Sport", "da": "Sport"
    },
    "habit.gratitude.chip.nature": {
        "de": "Natur", "en": "Nature", "fr": "Nature", "es": "Naturaleza", "it": "Natura", "pt": "Natureza", "nl": "Natuur", "tr": "Doğa", "pl": "Natura", "ru": "Природа", "ja": "自然", "ko": "자연", "zh": "自然", "ar": "الطبيعة", "hi": "प्रकृति", "sv": "Natur", "da": "Natur"
    }
}

for key, langs in translations.items():
    if key not in data["strings"]:
        data["strings"][key] = {"extractionState": "manual", "localizations": {}}
    for lang_code, translated_text in langs.items():
        data["strings"][key]["localizations"][lang_code] = {
            "stringUnit": {
                "state": "translated",
                "value": translated_text
            }
        }

with open(filepath, 'w', encoding='utf-8') as f:
    json.dump(data, f, indent=2, ensure_ascii=False)

