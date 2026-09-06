import json

with open("Localizable.xcstrings", "r") as f:
    data = json.load(f)

key = "calorie.calc.goal.edit_btn"

translations = {
    "de": "Ziel ändern",
    "en": "Change Goal",
    "es": "Cambiar objetivo",
    "fr": "Modifier l'objectif",
    "it": "Modifica obiettivo",
    "pt-BR": "Mudar meta",
    "zh-Hans": "修改目标"
}

if key in data["strings"]:
    for lang, val in translations.items():
        if lang not in data["strings"][key]["localizations"]:
            data["strings"][key]["localizations"][lang] = {"stringUnit": {"state": "translated", "value": val}}
        else:
            data["strings"][key]["localizations"][lang]["stringUnit"]["value"] = val
            data["strings"][key]["localizations"][lang]["stringUnit"]["state"] = "translated"

with open("Localizable.xcstrings", "w") as f:
    json.dump(data, f, indent=2, ensure_ascii=False)
print("Translations patched.")
