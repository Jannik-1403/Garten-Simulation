import json

with open("Localizable.xcstrings", "r") as f:
    data = json.load(f)

missing_translations = {
    "calorie.calc.desc.success.new": {
        "hi": "यह मान आपके शरीर के डेटा और लक्ष्य के आधार पर गणना की जाती है।",
        "ja": "この値は、あなたの身体データと目標に基づいて計算されます。",
        "ko": "이 값은 귀하의 신체 데이터 및 목표를 기반으로 계산됩니다.",
        "nl": "Deze waarde wordt berekend op basis van je lichaamsgegevens en doel.",
        "pl": "Ta wartość jest obliczana na podstawie danych Twojego ciała i celu.",
        "pt": "Este valor é calculado com base nos dados do seu corpo e objetivo.",
        "ru": "Это значение рассчитывается на основе ваших телесных данных и цели.",
        "tr": "Bu değer, vücut verilerinize ve hedefinize göre hesaplanır.",
        "zh-Hant": "該值是根據您的身體數據和目標計算得出的。"
    },
    "body.tracking.target_mode_date": {
        "hi": "तारीख",
        "ja": "日付",
        "ko": "날짜",
        "nl": "Datum",
        "pl": "Data",
        "pt": "Data",
        "ru": "Дата",
        "tr": "Tarih",
        "zh-Hant": "日期"
    },
    "body.tracking.target_mode_pace": {
        "hi": "गति (साप्ताहिक)",
        "ja": "ペース (週間)",
        "ko": "속도 (매주)",
        "nl": "Tempo (wekelijks)",
        "pl": "Tempo (tygodniowe)",
        "pt": "Ritmo (Semanal)",
        "ru": "Темп (Еженедельно)",
        "tr": "Hız (Haftalık)",
        "zh-Hant": "進度 (每週)"
    },
    "developer.cheats.title": {
        "hi": "चीट्स",
        "ja": "チート",
        "ko": "치트",
        "nl": "Cheats",
        "pl": "Kody",
        "pt": "Cheats",
        "ru": "Читы",
        "tr": "Hileler",
        "zh-Hant": "作弊"
    },
    "developer.cheats.addCoins": {
        "hi": "+ 100,000 सिक्के",
        "ja": "+ 100,000 コイン",
        "ko": "+ 100,000 코인",
        "nl": "+ 100.000 Munten",
        "pl": "+ 100 000 Monet",
        "pt": "+ 100.000 Moedas",
        "ru": "+ 100 000 Монет",
        "tr": "+ 100.000 Jeton",
        "zh-Hant": "+ 100,000 金幣"
    },
    "calorie.calc.goal.edit_btn": {
        "hi": "लक्ष्य बदलें",
        "ja": "目標を変更",
        "ko": "목표 변경",
        "nl": "Doel wijzigen",
        "pl": "Zmień cel",
        "pt": "Mudar objetivo",
        "ru": "Изменить цель",
        "tr": "Hedefi değiştir",
        "zh-Hant": "更改目標"
    }
}

for key, trans_dict in missing_translations.items():
    if key not in data["strings"]:
        data["strings"][key] = {"extractionState": "manual", "localizations": {}}
    
    for lang, val in trans_dict.items():
        if lang not in data["strings"][key]["localizations"]:
            data["strings"][key]["localizations"][lang] = {"stringUnit": {"state": "translated", "value": val}}
        else:
            data["strings"][key]["localizations"][lang]["stringUnit"]["value"] = val
            data["strings"][key]["localizations"][lang]["stringUnit"]["state"] = "translated"

with open("Localizable.xcstrings", "w") as f:
    json.dump(data, f, indent=2, ensure_ascii=False)
print("Translations for all remaining languages patched.")
