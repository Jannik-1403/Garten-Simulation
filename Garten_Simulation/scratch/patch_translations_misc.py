import json

with open("Localizable.xcstrings", "r") as f:
    data = json.load(f)

# Define the keys and their translations
# We want to translate:
# 1. calorie.calc.desc.success.new (Dieser Wert wird basierend auf deinen Körperdaten und deinem Ziel berechnet.)
# 2. body.tracking.target_mode_date (Datum)
# 3. body.tracking.target_mode_pace (Tempo (Woche))

translations = {
    "calorie.calc.desc.success.new": {
        "de": "Dieser Wert wird basierend auf deinen Körperdaten und deinem Ziel berechnet.",
        "en": "This value is calculated based on your body data and goal.",
        "es": "Este valor se calcula en base a tus datos corporales y objetivo.",
        "fr": "Cette valeur est calculée en fonction de vos données corporelles et de votre objectif.",
        "it": "Questo valore è calcolato in base ai tuoi dati corporei e al tuo obiettivo.",
        "pt-BR": "Esse valor é calculado com base em seus dados corporais e sua meta.",
        "zh-Hans": "该值是根据您的身体数据和目标计算得出的。"
    },
    "body.tracking.target_mode_date": {
        "de": "Datum",
        "en": "Date",
        "es": "Fecha",
        "fr": "Date",
        "it": "Data",
        "pt-BR": "Data",
        "zh-Hans": "日期"
    },
    "body.tracking.target_mode_pace": {
        "de": "Tempo (Woche)",
        "en": "Pace (Weekly)",
        "es": "Ritmo (Semanal)",
        "fr": "Rythme (Hebdo)",
        "it": "Ritmo (Settimanale)",
        "pt-BR": "Ritmo (Semanal)",
        "zh-Hans": "进度 (每周)"
    }
}

for key, trans_dict in translations.items():
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
print("Translations patched.")
