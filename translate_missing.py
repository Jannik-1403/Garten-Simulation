import json

with open("Garten_Simulation/Localizable.xcstrings", "r") as f:
    data = json.load(f)

# The mappings
trans_7 = {
    "body.tracking.target_calc_date": {
        "en": "Calculated Date:", "es": "Fecha calculada:", "fr": "Date calculée :",
        "it": "Data calcolata:", "pl": "Obliczona data:", "pt-BR": "Data calculada:", "tr": "Hesaplanan Tarih:"
    },
    "body.tracking.target_mode_date": {
        "en": "Date", "es": "Fecha", "fr": "Date",
        "it": "Data", "pl": "Data", "pt-BR": "Data", "tr": "Tarih"
    },
    "body.tracking.target_mode_pace": {
        "en": "Pace (Weekly)", "es": "Ritmo (Semanal)", "fr": "Rythme (Semaine)",
        "it": "Ritmo (Settimanale)", "pl": "Tempo (Tydzień)", "pt-BR": "Ritmo (Semanal)", "tr": "Hız (Haftalık)"
    },
    "body.tracking.target_pace": {
        "en": "kg per week:", "es": "kg por semana:", "fr": "kg par semaine :",
        "it": "kg a settimana:", "pl": "kg na tydzień:", "pt-BR": "kg por semana:", "tr": "haftalık kg:"
    },
    "calorie.calc.desc.success.new": {
        "en": "This value is calculated based on your body data and goal.",
        "es": "Este valor se calcula en función de tus datos corporales y tu objetivo.",
        "fr": "Cette valeur est calculée en fonction de vos données corporelles et de votre objectif.",
        "it": "Questo valore è calcolato in base ai tuoi dati corporei e al tuo obiettivo.",
        "pl": "Ta wartość jest obliczana na podstawie danych ciała i celu.",
        "pt-BR": "Este valor é calculado com base nos seus dados corporais e objetivo.",
        "tr": "Bu değer, vücut verilerinize ve hedefinize göre hesaplanır."
    },
    "calorie.calc.goal.edit_btn": {
        "en": "Change Goal", "es": "Cambiar objetivo", "fr": "Changer l'objectif",
        "it": "Cambia obiettivo", "pl": "Zmień cel", "pt-BR": "Mudar objetivo", "tr": "Hedefi Değiştir"
    },
    "calorie.calc.goal.pace": {
        "en": "Pace: ~%@ kg / week", "es": "Ritmo: ~%@ kg / semana", "fr": "Rythme : ~%@ kg / sem.",
        "it": "Ritmo: ~%@ kg / sett.", "pl": "Tempo: ~%@ kg / tydz.", "pt-BR": "Ritmo: ~%@ kg / semana", "tr": "Hız: ~%@ kg / hafta"
    }
}

trans_24 = {
    "%lld kcal": {
        "hi": "%lld kcal", "ja": "%lld kcal", "ko": "%lld kcal", "nl": "%lld kcal", "ru": "%lld kcal", "zh-Hans": "%lld kcal", "zh-Hant": "%lld kcal", "pt": "%lld kcal"
    },
    "calorie.calc.goal.gain": {
        "hi": "वजन बढ़ाएं", "ja": "増量", "ko": "체중 증량", "nl": "Aankomen", "ru": "Набор веса", "zh-Hans": "增重", "zh-Hant": "增重", "pt": "Ganhar Peso"
    },
    "calorie.calc.goal.info": {
        "hi": "आपके दैनिक कैलोरी और मैक्रोज़ आपके लक्ष्य की तारीख के आधार पर स्वचालित रूप से समायोजित किए जाते हैं।", "ja": "目標日に基づいて、毎日のカロリーとマクロが自動的に調整されます。", "ko": "목표 날짜에 따라 일일 칼로리와 매크로가 자동으로 조정됩니다.", "nl": "Je dagelijkse calorieën en macro's worden automatisch aangepast op basis van je streefdatum.", "ru": "Ваши ежедневные калории и макросы автоматически корректируются на основе вашей целевой даты.", "zh-Hans": "您的每日卡路里和常量营养素将根据您的目标日期自动调整。", "zh-Hant": "您的每日卡路里和常量營養素將根據您的目標日期自動調整。", "pt": "Suas calorias diárias e macros são ajustadas automaticamente com base na data do seu objetivo."
    },
    "calorie.calc.goal.linked": {
        "hi": "आपका लक्ष्य स्वचालित रूप से आपके शक्ति प्रशिक्षण से ले लिया गया है।", "ja": "目標は筋力トレーニングから自動的にインポートされました。", "ko": "목표가 근력 운동에서 자동으로 가져와졌습니다.", "nl": "Je doel is automatisch overgenomen van je krachttraining.", "ru": "Ваша цель была автоматически перенесена из ваших силовых тренировок.", "zh-Hans": "您的目标已自动从您的力量训练中导入。", "zh-Hant": "您的目標已自動從您的力量訓練中導入。", "pt": "Seu objetivo foi importado automaticamente do seu treino de força."
    },
    "calorie.calc.goal.lose": {
        "hi": "वजन घटाएं", "ja": "減量", "ko": "체중 감량", "nl": "Afvallen", "ru": "Похудение", "zh-Hans": "减重", "zh-Hant": "減重", "pt": "Perder Peso"
    },
    "calorie.calc.goal.maintain": {
        "hi": "वजन बनाए रखें", "ja": "維持", "ko": "체중 유지", "nl": "Gewicht behouden", "ru": "Поддержание", "zh-Hans": "保持体重", "zh-Hant": "保持體重", "pt": "Manter Peso"
    },
    "calorie.calc.goal.target_date": {
        "hi": "लक्ष्य की तारीख", "ja": "目標日", "ko": "목표 날짜", "nl": "Streefdatum", "ru": "Целевая дата", "zh-Hans": "目标日期", "zh-Hant": "目標日期", "pt": "Data do Objetivo"
    },
    "calorie.calc.goal.target_weight": {
        "hi": "लक्ष्य का वजन", "ja": "目標体重", "ko": "목표 체중", "nl": "Streefgewicht", "ru": "Целевой вес", "zh-Hans": "目标体重", "zh-Hant": "目標體重", "pt": "Peso Alvo"
    },
    "calorie.calc.goal.title": {
        "hi": "मेरा लक्ष्य", "ja": "私の目標", "ko": "내 목표", "nl": "Mijn doel", "ru": "Моя цель", "zh-Hans": "我的目标", "zh-Hant": "我的目標", "pt": "Meu Objetivo"
    },
    "calorie.detail.nav": {
        "hi": "कैलोरी विवरण", "ja": "カロリー詳細", "ko": "칼로리 세부정보", "nl": "Calorie details", "ru": "Детали калорий", "zh-Hans": "卡路里详情", "zh-Hant": "卡路里詳情", "pt": "Detalhes das Calorias"
    },
    "calorie.history.consumed": {
        "hi": "खपत", "ja": "摂取済み", "ko": "소비됨", "nl": "Geconsumeerd", "ru": "Потреблено", "zh-Hans": "已消耗", "zh-Hant": "已消耗", "pt": "Consumido"
    },
    "calorie.history.target": {
        "hi": "लक्ष्य", "ja": "目標", "ko": "목표", "nl": "Doel", "ru": "Цель", "zh-Hans": "目标", "zh-Hant": "目標", "pt": "Objetivo"
    },
    "calorie.history.title": {
        "hi": "कैलोरी इतिहास", "ja": "カロリー履歴", "ko": "칼로리 기록", "nl": "Caloriehistorie", "ru": "История калорий", "zh-Hans": "卡路里历史", "zh-Hant": "卡路里歷史", "pt": "Histórico de Calorias"
    },
    "calorie.history.today": {
        "hi": "आज", "ja": "今日", "ko": "오늘", "nl": "Vandaag", "ru": "Сегодня", "zh-Hans": "今天", "zh-Hant": "今天", "pt": "Hoje"
    },
    "Datum": {
        "hi": "तारीख", "ja": "日付", "ko": "날짜", "nl": "Datum", "ru": "Дата", "zh-Hans": "日期", "zh-Hant": "日期", "pt": "Data"
    },
    "Kalorien": {
        "hi": "कैलोरी", "ja": "カロリー", "ko": "칼로리", "nl": "Calorieën", "ru": "Калории", "zh-Hans": "卡路里", "zh-Hant": "卡路里", "pt": "Calorias"
    },
    "kg": {
        "hi": "kg", "ja": "kg", "ko": "kg", "nl": "kg", "ru": "kg", "zh-Hans": "kg", "zh-Hant": "kg", "pt": "kg"
    }
}

# The remaining keys for pt (Portugiesisch)
trans_pt = {
    "body.tracking.status.bulking.deficit.desc": "Você queima mais do que come. Aumente as calorias em 300 kcal agora.",
    "body.tracking.status.bulking.stagnation.desc": "Pouco combustível. Aumente 200 kcal nas calorias diárias a partir de amanhã.",
    "body.tracking.status.bulking.fat.desc": "Ganho de peso muito rápido. Reduza 200 kcal para evitar acúmulo de gordura.",
    "body.tracking.status.cutting.gain.desc": "Você está ganhando peso em vez de perder. Reduza 300 kcal por dia.",
    "body.tracking.status.cutting.stagnation.desc": "Perda de peso estagnada. Reduza 200 kcal ou aumente o cardio.",
    "body.tracking.status.cutting.muscleloss.desc": "Perda de peso muito agressiva. Você está perdendo músculos. Aumente as calorias em 200 kcal.",
    "calorie.calc.age": "Idade",
    "calorie.calc.desc.success": "Este valor (TDEE) é calculado com base na fórmula de Mifflin-St. Jeor e seus dados corporais.",
    "calorie.calc.height": "Altura",
    "calorie.calc.nav": "Dados e Calorias",
    "calorie.calc.sex": "Gênero",
    "calorie.calc.tap_for_details": "Ver Cálculo",
    "calorie.calc.title": "Sua Necessidade Calórica",
    "calorie.calc.weight": "Peso",
    "calorie.calc.years": "Anos",
    "health.metric.calories": "Calorias",
    "macro.fat.details": "Detalhes de Gordura",
    "macro.fat.mono": "Gorduras Monoinsaturadas",
    "macro.fat.poly": "Gorduras Poli-insaturadas",
    "macro.fat.sat": "Gorduras Saturadas",
    "macro.goal.set": "Ajustar Meta Diária",
    "macro.recommendation.apply": "Aplicar",
    "macro.recommendation.auth": "Compartilhar Dados",
    "macro.recommendation.desc": "Com base nos seus dados corporais (altura, peso, idade), recomendamos esta meta diária.",
    "macro.recommendation.missing": "Precisamos da sua altura, idade e peso no Apple Health para te dar uma recomendação.",
    "macro.recommendation.missing.new": "Faltam alguns dados corporais para uma recomendação precisa. Por favor, adicione-os na visão geral.",
    "macro.recommendation.title": "Recomendação do App",
    "sex.female": "Feminino",
    "sex.male": "Masculino",
    "sex.none": "Selecionar"
}

# Expand trans_7 to the 24 languages where they were also missing!
# The 7 keys are also missing in hi, ja, ko, nl, ru, zh-Hans, zh-Hant, pt.
trans_7_extensions = {
    "body.tracking.target_calc_date": {
        "hi": "गणना की गई तारीख:", "ja": "計算された日付:", "ko": "계산된 날짜:", "nl": "Berekende datum:", "ru": "Расчетная дата:", "zh-Hans": "计算日期：", "zh-Hant": "計算日期：", "pt": "Data calculada:"
    },
    "body.tracking.target_mode_date": {
        "hi": "तारीख", "ja": "日付", "ko": "날짜", "nl": "Datum", "ru": "Дата", "zh-Hans": "日期", "zh-Hant": "日期", "pt": "Data"
    },
    "body.tracking.target_mode_pace": {
        "hi": "गति (साप्ताहिक)", "ja": "ペース (毎週)", "ko": "속도 (매주)", "nl": "Tempo (Wekelijks)", "ru": "Темп (Еженедельно)", "zh-Hans": "节奏 (每周)", "zh-Hant": "節奏 (每週)", "pt": "Ritmo (Semanal)"
    },
    "body.tracking.target_pace": {
        "hi": "किलोग्राम प्रति सप्ताह:", "ja": "週あたりのkg:", "ko": "주당 kg:", "nl": "kg per week:", "ru": "кг в неделю:", "zh-Hans": "每周公斤：", "zh-Hant": "每週公斤：", "pt": "kg por semana:"
    },
    "calorie.calc.desc.success.new": {
        "hi": "यह मान आपके शरीर के डेटा और लक्ष्य के आधार पर गणना किया जाता है।",
        "ja": "この値は、身体データと目標に基づいて計算されます。",
        "ko": "이 값은 신체 데이터 및 목표를 기반으로 계산됩니다.",
        "nl": "Deze waarde wordt berekend op basis van uw lichaamsgegevens en doel.",
        "ru": "Это значение рассчитывается на основе данных вашего тела и цели.",
        "zh-Hans": "该值根据您的身体数据和目标进行计算。",
        "zh-Hant": "該值根據您的身體數據和目標進行計算。",
        "pt": "Este valor é calculado com base nos seus dados corporais e objetivo."
    },
    "calorie.calc.goal.edit_btn": {
        "hi": "लक्ष्य बदलें", "ja": "目標を変更", "ko": "목표 변경", "nl": "Doel wijzigen", "ru": "Изменить цель", "zh-Hans": "更改目标", "zh-Hant": "更改目標", "pt": "Mudar objetivo"
    },
    "calorie.calc.goal.pace": {
        "hi": "गति: ~%@ किलोग्राम/सप्ताह", "ja": "ペース: 約%@ kg/週", "ko": "속도: ~%@ kg/주", "nl": "Tempo: ~%@ kg/week", "ru": "Темп: ~%@ кг/нед.", "zh-Hans": "节奏：~%@公斤/周", "zh-Hant": "節奏：~%@公斤/週", "pt": "Ritmo: ~%@ kg/semana"
    }
}

for k, d in trans_7_extensions.items():
    trans_7[k].update(d)

strings = data.get("strings", {})

def update_lang(key, lang, translated_text):
    if key not in strings:
        strings[key] = {"localizations": {}}
    if "localizations" not in strings[key]:
        strings[key]["localizations"] = {}
    
    strings[key]["localizations"][lang] = {
        "stringUnit": {
            "state": "translated",
            "value": translated_text
        }
    }

for key, langs in trans_7.items():
    for lang, text in langs.items():
        update_lang(key, lang, text)

for key, langs in trans_24.items():
    for lang, text in langs.items():
        update_lang(key, lang, text)

for key, text in trans_pt.items():
    update_lang(key, "pt", text)

with open("Garten_Simulation/Localizable.xcstrings", "w") as f:
    json.dump(data, f, indent=2, ensure_ascii=False)

print("Translation update complete.")
