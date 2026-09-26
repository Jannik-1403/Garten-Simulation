import json

file_path = "Garten_Simulation/Localizable.xcstrings"
with open(file_path, "r", encoding="utf-8") as f:
    data = json.load(f)

translations = {
    "habit.cook.setup_title": {
        "en": "Set nutrition goal",
        "es": "Establecer meta de nutrición",
        "fr": "Définir l'objectif nutritionnel",
        "it": "Imposta obiettivo nutrizionale",
        "nl": "Voedingsdoel instellen",
        "pt": "Definir meta de nutrição",
        "pt-BR": "Definir meta de nutrição",
        "ru": "Установить цель по питанию",
        "pl": "Ustal cel żywieniowy",
        "tr": "Beslenme hedefini belirle",
        "ja": "栄養目標を設定する",
        "zh-Hans": "设置营养目标",
        "zh-Hant": "設定營養目標",
        "ko": "영양 목표 설정",
        "hi": "पोषण लक्ष्य निर्धारित करें"
    },
    "habit.cook.setup_desc": {
        "en": "Enter your calorie goal before the statistics are calculated and displayed.",
        "es": "Ingresa tu meta de calorías antes de que se calculen y muestren las estadísticas.",
        "fr": "Entrez votre objectif de calories avant que les statistiques ne soient calculées et affichées.",
        "it": "Inserisci il tuo obiettivo calorico prima che le statistiche vengano calcolate e visualizzate.",
        "nl": "Voer uw caloriedoel in voordat de statistieken worden berekend en weergegeven.",
        "pt": "Insira sua meta de calorias antes que as estatísticas sejam calculadas e exibidas.",
        "pt-BR": "Insira sua meta de calorias antes que as estatísticas sejam calculadas e exibidas.",
        "ru": "Введите вашу цель по калориям перед тем, как статистика будет рассчитана и отображена.",
        "pl": "Wprowadź swój cel kaloryczny, zanim statystyki zostaną obliczone i wyświetlone.",
        "tr": "İstatistikler hesaplanıp görüntülenmeden önce kalori hedefinizi girin.",
        "ja": "統計が計算されて表示される前に、カロリー目標を入力してください。",
        "zh-Hans": "在计算和显示统计数据之前，请输入您的卡路里目标。",
        "zh-Hant": "在計算和顯示統計數據之前，請輸入您的卡路里目標。",
        "ko": "통계가 계산되고 표시되기 전에 칼로리 목표를 입력하세요.",
        "hi": "आँकड़ों की गणना और प्रदर्शित होने से पहले अपना कैलोरी लक्ष्य दर्ज करें।"
    },
    "habit.cook.setup_btn": {
        "en": "Enter goal",
        "es": "Ingresar meta",
        "fr": "Entrer l'objectif",
        "it": "Inserisci obiettivo",
        "nl": "Doel invoeren",
        "pt": "Inserir meta",
        "pt-BR": "Inserir meta",
        "ru": "Ввести цель",
        "pl": "Wprowadź cel",
        "tr": "Hedefi girin",
        "ja": "目標を入力",
        "zh-Hans": "输入目标",
        "zh-Hant": "輸入目標",
        "ko": "목표 입력",
        "hi": "लक्ष्य दर्ज करें"
    },
    "sleep.routine.insight.missing_last_night": {
        "en": "Your long-term average is calculated, but data for last night is still missing.",
        "es": "Tu promedio a largo plazo ha sido calculado, pero aún faltan los datos de anoche.",
        "fr": "Votre moyenne à long terme est calculée, mais les données de la nuit dernière manquent encore.",
        "it": "La tua media a lungo termine è calcolata, ma mancano ancora i dati della scorsa notte.",
        "nl": "Je langetermijngemiddelde is berekend, maar de gegevens van afgelopen nacht ontbreken nog.",
        "pt": "Sua média de longo prazo foi calculada, mas os dados da noite passada ainda estão faltando.",
        "pt-BR": "Sua média de longo prazo foi calculada, mas os dados da noite passada ainda estão faltando.",
        "ru": "Ваше долгосрочное среднее рассчитано, но данные за прошлую ночь еще отсутствуют.",
        "pl": "Twoja średnia długoterminowa jest obliczona, ale brakuje jeszcze danych z zeszłej nocy.",
        "tr": "Uzun vadeli ortalamanız hesaplandı, ancak dün geceye ait veriler hala eksik.",
        "ja": "長期の平均は計算されましたが、昨夜のデータがまだ不足しています。",
        "zh-Hans": "您的长期平均值已计算，但昨晚的数据仍然缺失。",
        "zh-Hant": "您的長期平均值已計算，但昨晚的數據仍然缺失。",
        "ko": "장기 평균이 계산되었지만 어젯밤 데이터가 아직 누락되었습니다.",
        "hi": "आपका दीर्घकालिक औसत गिने जा चुका है, लेकिन पिछली रात का डेटा अभी भी अनुपलब्ध है।"
    },
    "health.unit.minutes": {
        "en": "Minutes",
        "es": "Minutos",
        "fr": "Minutes",
        "it": "Minuti",
        "nl": "Minuten",
        "pt": "Minutos",
        "pt-BR": "Minutos",
        "ru": "Минуты",
        "pl": "Minuty",
        
        "tr": "Dakika",
        "ja": "分",
        "zh-Hans": "分钟",
        "zh-Hant": "分鐘",
        "ko": "분",
        "hi": "मिनट"
    }
}

count = 0
for key, trans in translations.items():
    if key in data["strings"]:
        for lang, text in trans.items():
            if "localizations" not in data["strings"][key]:
                data["strings"][key]["localizations"] = {}
            data["strings"][key]["localizations"][lang] = {
                "stringUnit": {
                    "state": "translated",
                    "value": text
                }
            }
            count += 1
            
with open(file_path, "w", encoding="utf-8") as f:
    json.dump(data, f, indent=2, ensure_ascii=False)

print(f"Updated {count} translations.")
