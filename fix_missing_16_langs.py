import json

path = "/Users/jannikschill/Documents/Garten-Simulation/Garten_Simulation/Localizable.xcstrings"
with open(path, "r", encoding="utf-8") as f:
    data = json.load(f)

# The keys we need to fully translate:
translations = {
    "fitness.score.detail.title": {
        "en": "Daily Analysis", "fr": "Analyse Quotidienne", "es": "Análisis Diario", "it": "Analisi Quotidiana",
        "pt": "Análise Diária", "pt-BR": "Análise Diária", "nl": "Dagelijkse Analyse", "pl": "Codzienna Analiza",
        "ru": "Ежедневный Анализ", "tr": "Günlük Analiz", "ja": "毎日の分析", "ko": "일일 분석",
        "zh-Hans": "每日分析", "zh-Hant": "每日分析", "hi": "दैनिक विश्लेषण"
    },
    "fitness.water.detail.progress": {
        "en": "Drank %lld of %lld ml.", "fr": "Tu as bu %lld sur %lld ml.", "es": "Bebiste %lld de %lld ml.",
        "it": "Hai bevuto %lld di %lld ml.", "pt": "Bebeste %lld de %lld ml.", "pt-BR": "Bebeu %lld de %lld ml.",
        "nl": "%lld van %lld ml gedronken.", "pl": "Wypito %lld z %lld ml.", "ru": "Выпито %lld из %lld мл.",
        "tr": "%lld / %lld ml içildi.", "ja": "%lld / %lld ml 飲みました。", "ko": "%lld / %lld ml 마셨습니다.",
        "zh-Hans": "已喝 %lld / %lld 毫升。", "zh-Hant": "已喝 %lld / %lld 毫升。", "hi": "%lld में से %lld मिली पिया।"
    },
    "fitness.sleep.detail.timehint": {
        "en": "Tomorrow you should go to bed around %@ and wake up around %@.",
        "fr": "Demain, tu devrais te coucher vers %@ et te réveiller vers %@.",
        "es": "Mañana deberías acostarte a las %@ y despertarte a las %@.",
        "it": "Domani dovresti andare a letto verso le %@ e svegliarti verso le %@.",
        "pt": "Amanhã deves ir para a cama por volta das %@ e acordar às %@.",
        "pt-BR": "Amanhã você deve ir para a cama por volta das %@ e acordar às %@.",
        "nl": "Morgen zou je rond %@ naar bed moeten gaan en rond %@ wakker moeten worden.",
        "pl": "Jutro powinieneś położyć się około %@ i obudzić się około %@.",
        "ru": "Завтра вам следует лечь спать около %@ и проснуться около %@.",
        "tr": "Yarın %@ civarında yatmalı ve %@ civarında uyanmalısın.",
        "ja": "明日は%@頃に就寝し、%@頃に起床してください。",
        "ko": "내일은 %@경에 잠자리에 들고 %@경에 일어나야 합니다.",
        "zh-Hans": "明天你应该在%@左右睡觉，在%@左右起床。",
        "zh-Hant": "明天你應該在%@左右睡覺，在%@左右起床。",
        "hi": "कल आपको लगभग %@ बजे सोना चाहिए और %@ बजे उठना चाहिए।"
    },
    "fitness.strength.summary.daysago": {
        "en": "(%lld days ago)", "fr": "(Il y a %lld jours)", "es": "(Hace %lld días)", "it": "(%lld giorni fa)",
        "pt": "(Há %lld dias)", "pt-BR": "(Há %lld dias)", "nl": "(%lld dagen geleden)", "pl": "(%lld dni temu)",
        "ru": "(%lld дней назад)", "tr": "(%lld gün önce)", "ja": "(%lld日前)", "ko": "(%lld일 전)",
        "zh-Hans": "(%lld天前)", "zh-Hant": "(%lld天前)", "hi": "(%lld दिन पहले)"
    },
    "fitness.running.detail.good": {
        "en": "Step goal reached ✓ Well done!", "fr": "Objectif de pas atteint ✓ Bien joué !",
        "es": "Meta de pasos alcanzada ✓ ¡Bien hecho!", "it": "Obiettivo passi raggiunto ✓ Ben fatto!",
        "pt": "Objetivo de passos atingido ✓ Muito bem!", "pt-BR": "Meta de passos alcançada ✓ Muito bem!",
        "nl": "Stappendoel bereikt ✓ Goed gedaan!", "pl": "Cel kroków osiągnięty ✓ Dobra robota!",
        "ru": "Цель по шагам достигнута ✓ Отлично!", "tr": "Adım hedefine ulaşıldı ✓ Tebrikler!",
        "ja": "歩数目標達成 ✓ よくできました！", "ko": "걸음 수 목표 달성 ✓ 잘하셨습니다!",
        "zh-Hans": "步数目标达成 ✓ 干得好！", "zh-Hant": "步數目標達成 ✓ 幹得好！", "hi": "कदम लक्ष्य पूरा हुआ ✓ बहुत बढ़िया!"
    },
    "fitness.running.detail.missing.large": {
        "en": "You're missing %lld steps. You need to be much more active, plan a longer walk.",
        "fr": "Il te manque %lld pas. Tu dois être beaucoup plus actif, prévois une plus longue marche.",
        "es": "Te faltan %lld pasos. Debes estar mucho más activo, planea una caminata larga.",
        "it": "Ti mancano %lld passi. Devi essere molto più attivo, pianifica una passeggiata più lunga.",
        "pt": "Faltam %lld passos. Tens de ser muito mais ativo, planeia uma caminhada mais longa.",
        "pt-BR": "Faltam %lld passos. Você precisa ser muito mais ativo, planeje uma caminhada longa.",
        "nl": "Je mist nog %lld stappen. Je moet veel actiever zijn, plan een langere wandeling.",
        "pl": "Brakuje Ci %lld kroków. Musisz być bardziej aktywny, zaplanuj dłuższy spacer.",
        "ru": "Вам не хватает %lld шагов. Нужно быть активнее, запланируйте долгую прогулку.",
        "tr": "%lld adım eksik. Daha aktif olmalısın, daha uzun bir yürüyüş planla.",
        "ja": "あと%lld歩足りません。もっと活動的になり、長い散歩を計画しましょう。",
        "ko": "%lld걸음이 부족합니다. 더 활동적으로 움직이고 긴 산책을 계획하세요.",
        "zh-Hans": "还差%lld步。你需要更加活跃，计划一次更长的散步。",
        "zh-Hant": "還差%lld步。你需要更加活躍，計劃一次更長的散步。",
        "hi": "आपको %lld कदम और चलने हैं। आपको अधिक सक्रिय होना चाहिए, लंबी सैर की योजना बनाएं।"
    },
    "fitness.running.detail.missing.medium": {
        "en": "You're missing %lld steps. Take a short walk.",
        "fr": "Il te manque %lld pas. Fais une courte promenade.",
        "es": "Te faltan %lld pasos. Da un breve paseo.",
        "it": "Ti mancano %lld passi. Fai una breve passeggiata.",
        "pt": "Faltam %lld passos. Dá um curto passeio.",
        "pt-BR": "Faltam %lld passos. Dê uma curta caminhada.",
        "nl": "Je mist %lld stappen. Maak een korte wandeling.",
        "pl": "Brakuje Ci %lld kroków. Wybierz się na krótki spacer.",
        "ru": "Не хватает %lld шагов. Совершите короткую прогулку.",
        "tr": "%lld adım eksik. Kısa bir yürüyüşe çık.",
        "ja": "あと%lld歩です。少し散歩しましょう。",
        "ko": "%lld걸음이 부족합니다. 짧은 산책을 하세요.",
        "zh-Hans": "还差%lld步。去散个步吧。",
        "zh-Hant": "還差%lld步。去散個步吧。",
        "hi": "आपको %lld कदम और चलने हैं। थोड़ी सैर करें।"
    },
    "fitness.running.detail.missing.small": {
        "en": "Only %lld steps left. Just move a little bit more!",
        "fr": "Plus que %lld pas. Bouge juste un peu plus !",
        "es": "Solo faltan %lld pasos. ¡Muévete un poco más!",
        "it": "Solo %lld passi rimasti. Muoviti un po' di più!",
        "pt": "Faltam apenas %lld passos. Move-te só um pouco mais!",
        "pt-BR": "Faltam apenas %lld passos. Mova-se só um pouquinho mais!",
        "nl": "Nog maar %lld stappen. Beweeg nog een klein beetje!",
        "pl": "Zostało tylko %lld kroków. Ruszaj się jeszcze trochę!",
        "ru": "Осталось всего %lld шагов. Подвигайтесь еще немного!",
        "tr": "Sadece %lld adım kaldı. Biraz daha hareket et!",
        "ja": "残り%lld歩です。もう少し動きましょう！",
        "ko": "단 %lld걸음 남았습니다. 조금만 더 움직이세요!",
        "zh-Hans": "仅剩%lld步。再稍微活动一下！",
        "zh-Hant": "僅剩%lld步。再稍微活動一下！",
        "hi": "केवल %lld कदम बचे हैं। बस थोड़ा और चलें!"
    },
    "fitness.running.steps.short": {
        "en": "Steps", "fr": "Pas", "es": "Pasos", "it": "Passi", "pt": "Passos", "pt-BR": "Passos",
        "nl": "Stappen", "pl": "Kroki", "ru": "Шаги", "tr": "Adımlar", "ja": "歩数", "ko": "걸음",
        "zh-Hans": "步", "zh-Hant": "步", "hi": "कदम"
    },
    "fitness.sleep.detail.fallback": {
        "en": "Try to go to bed earlier today.",
        "fr": "Essaie de te coucher plus tôt aujourd'hui.",
        "es": "Intenta acostarte más temprano hoy.",
        "it": "Cerca di andare a letto prima oggi.",
        "pt": "Tenta deitar-te mais cedo hoje.",
        "pt-BR": "Tente dormir mais cedo hoje.",
        "nl": "Probeer vandaag eerder naar bed te gaan.",
        "pl": "Spróbuj dzisiaj pójść wcześniej spać.",
        "ru": "Постарайтесь лечь спать пораньше сегодня.",
        "tr": "Bugün daha erken yatmaya çalış.",
        "ja": "今日は早めに寝るようにしてください。",
        "ko": "오늘은 일찍 잠자리에 들도록 하세요.",
        "zh-Hans": "今天试着早点睡觉。",
        "zh-Hant": "今天試著早點睡覺。",
        "hi": "आज जल्दी सोने की कोशिश करें।"
    },
    "fitness.water.summary.good": {
        "en": "%lld / %lld ml ✓", "fr": "%lld / %lld ml ✓", "es": "%lld / %lld ml ✓", "it": "%lld / %lld ml ✓",
        "pt": "%lld / %lld ml ✓", "pt-BR": "%lld / %lld ml ✓", "nl": "%lld / %lld ml ✓", "pl": "%lld / %lld ml ✓",
        "ru": "%lld / %lld мл ✓", "tr": "%lld / %lld ml ✓", "ja": "%lld / %lld ml ✓", "ko": "%lld / %lld ml ✓",
        "zh-Hans": "%lld / %lld 毫升 ✓", "zh-Hant": "%lld / %lld 毫升 ✓", "hi": "%lld / %lld मिली ✓"
    },
    "fitness.water.summary": {
        "en": "%lld / %lld ml", "fr": "%lld / %lld ml", "es": "%lld / %lld ml", "it": "%lld / %lld ml",
        "pt": "%lld / %lld ml", "pt-BR": "%lld / %lld ml", "nl": "%lld / %lld ml", "pl": "%lld / %lld ml",
        "ru": "%lld / %lld мл", "tr": "%lld / %lld ml", "ja": "%lld / %lld ml", "ko": "%lld / %lld ml",
        "zh-Hans": "%lld / %lld 毫升", "zh-Hant": "%lld / %lld 毫升", "hi": "%lld / %lld मिली"
    },
    "fitness.sleep.summary": {
        "en": "%@ / %@ h", "fr": "%@ / %@ h", "es": "%@ / %@ h", "it": "%@ / %@ h",
        "pt": "%@ / %@ h", "pt-BR": "%@ / %@ h", "nl": "%@ / %@ h", "pl": "%@ / %@ h",
        "ru": "%@ / %@ ч", "tr": "%@ / %@ s", "ja": "%@ / %@ 時間", "ko": "%@ / %@ 시간",
        "zh-Hans": "%@ / %@ 小时", "zh-Hant": "%@ / %@ 小時", "hi": "%@ / %@ घंटे"
    },
    "fitness.strength.summary.min": {
        "en": "%lld / %lld min", "fr": "%lld / %lld min", "es": "%lld / %lld min", "it": "%lld / %lld min",
        "pt": "%lld / %lld min", "pt-BR": "%lld / %lld min", "nl": "%lld / %lld min", "pl": "%lld / %lld min",
        "ru": "%lld / %lld мин", "tr": "%lld / %lld dk", "ja": "%lld / %lld 分", "ko": "%lld / %lld 분",
        "zh-Hans": "%lld / %lld 分钟", "zh-Hant": "%lld / %lld 分鐘", "hi": "%lld / %lld मिनट"
    },
    "fitness.running.summary": {
        "en": "%lld / %lld steps", "fr": "%lld / %lld pas", "es": "%lld / %lld pasos", "it": "%lld / %lld passi",
        "pt": "%lld / %lld passos", "pt-BR": "%lld / %lld passos", "nl": "%lld / %lld stappen", "pl": "%lld / %lld kroków",
        "ru": "%lld / %lld шагов", "tr": "%lld / %lld adım", "ja": "%lld / %lld 歩", "ko": "%lld / %lld 걸음",
        "zh-Hans": "%lld / %lld 步", "zh-Hant": "%lld / %lld 步", "hi": "%lld / %lld कदम"
    },
    "fitness.nutrition.summary.good": {
        "en": "%lld / %lld kcal ✓", "fr": "%lld / %lld kcal ✓", "es": "%lld / %lld kcal ✓", "it": "%lld / %lld kcal ✓",
        "pt": "%lld / %lld kcal ✓", "pt-BR": "%lld / %lld kcal ✓", "nl": "%lld / %lld kcal ✓", "pl": "%lld / %lld kcal ✓",
        "ru": "%lld / %lld ккал ✓", "tr": "%lld / %lld kcal ✓", "ja": "%lld / %lld kcal ✓", "ko": "%lld / %lld kcal ✓",
        "zh-Hans": "%lld / %lld 千卡 ✓", "zh-Hant": "%lld / %lld 千卡 ✓", "hi": "%lld / %lld कैलोरी ✓"
    },
    "fitness.nutrition.summary": {
        "en": "%lld / %lld kcal", "fr": "%lld / %lld kcal", "es": "%lld / %lld kcal", "it": "%lld / %lld kcal",
        "pt": "%lld / %lld kcal", "pt-BR": "%lld / %lld kcal", "nl": "%lld / %lld kcal", "pl": "%lld / %lld kcal",
        "ru": "%lld / %lld ккал", "tr": "%lld / %lld kcal", "ja": "%lld / %lld kcal", "ko": "%lld / %lld kcal",
        "zh-Hans": "%lld / %lld 千卡", "zh-Hant": "%lld / %lld 千卡", "hi": "%lld / %lld कैलोरी"
    }
}

for key, trans in translations.items():
    if key not in data["strings"]:
        data["strings"][key] = {"extractionState": "manual", "localizations": {}}
    
    data["strings"][key]["extractionState"] = "manual"
    
    for lang, text in trans.items():
        if "localizations" not in data["strings"][key]:
            data["strings"][key]["localizations"] = {}
        
        data["strings"][key]["localizations"][lang] = {
            "stringUnit": {
                "state": "translated",
                "value": text
            }
        }

with open(path, "w", encoding="utf-8") as f:
    json.dump(data, f, indent=2, ensure_ascii=False)

print("Updated 16 languages for 17 keys.")
