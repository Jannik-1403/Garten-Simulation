import json

path = "Garten_Simulation/Localizable.xcstrings"
with open(path, "r", encoding="utf-8") as f:
    data = json.load(f)

categories = {
    "category.fitness": {
        "de": "Fitness", "en": "Fitness", "nl": "Fitness", "fr": "Condition physique", "it": "Fitness", "ja": "フィットネス", "ko": "피트니스", "pl": "Fitness", "pt": "Aptidão", "es": "Aptitud física", "tr": "Fitness"
    },
    "category.health": {
        "de": "Gesundheit", "en": "Health", "nl": "Gezondheid", "fr": "Santé", "it": "Salute", "ja": "健康", "ko": "건강", "pl": "Zdrowie", "pt": "Saúde", "es": "Salud", "tr": "Sağlık"
    },
    "category.mental": {
        "de": "Mental", "en": "Mental", "nl": "Mentaal", "fr": "Mental", "it": "Mentale", "ja": "メンタル", "ko": "정신", "pl": "Mentalny", "pt": "Mental", "es": "Mental", "tr": "Zihinsel"
    },
    "category.growth": {
        "de": "Wachstum", "en": "Growth", "nl": "Groei", "fr": "Croissance", "it": "Crescita", "ja": "成長", "ko": "성장", "pl": "Wzrost", "pt": "Crescimento", "es": "Crecimiento", "tr": "Büyüme"
    },
    "category.lifestyle": {
        "de": "Lifestyle", "en": "Lifestyle", "nl": "Levensstijl", "fr": "Mode de vie", "it": "Stile di vita", "ja": "ライフスタイル", "ko": "라이프스타일", "pl": "Styl życia", "pt": "Estilo de vida", "es": "Estilo de vida", "tr": "Yaşam tarzı"
    },
    "category.finance": {
        "de": "Finanzen", "en": "Finance", "nl": "Financiën", "fr": "Finances", "it": "Finanza", "ja": "ファイナンス", "ko": "재정", "pl": "Finanse", "pt": "Finanças", "es": "Finanzas", "tr": "Finans"
    },
    "category.seeds": {
        "de": "Samen", "en": "Seeds", "nl": "Zaden", "fr": "Graines", "it": "Semi", "ja": "種", "ko": "씨앗", "pl": "Nasiona", "pt": "Sementes", "es": "Semillas", "tr": "Tohumlar"
    }
}

for key, translations in categories.items():
    if key not in data["strings"]:
        data["strings"][key] = {"extractionState": "manual", "localizations": {}}
    for lang, text in translations.items():
        data["strings"][key]["localizations"][lang] = {
            "stringUnit": {
                "state": "translated",
                "value": text
            }
        }

with open(path, "w", encoding="utf-8") as f:
    json.dump(data, f, indent=2, ensure_ascii=False)
