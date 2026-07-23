import json

file_path = "Garten_Simulation/Localizable.xcstrings"

with open(file_path, "r", encoding="utf-8") as f:
    data = json.load(f)

translations = {
    "screenTime.blockedApps": {
        "en": "Blocked Apps",
        "de": "Geblockte Apps",
        "es": "Aplicaciones bloqueadas",
        "fr": "Applications bloquées",
        "it": "App bloccate",
        "pt": "Apps Bloqueados",
        "pt-BR": "Apps Bloqueados",
        "nl": "Geblokkeerde apps",
        "pl": "Zablokowane aplikacje",
        "ru": "Заблокированные приложения",
        "tr": "Engellenen Uygulamalar",
        "hi": "अवरुद्ध ऐप्स",
        "ja": "ブロックされたアプリ",
        "ko": "차단된 앱",
        "zh-Hans": "已拦截应用",
        "zh-Hant": "已攔截應用"
    }
}

for key, trans in translations.items():
    if key not in data["strings"]:
        data["strings"][key] = {"extractionState": "manual", "localizations": {}}
    for lang, text in trans.items():
        data["strings"][key]["localizations"][lang] = {
            "stringUnit": {
                "state": "translated",
                "value": text
            }
        }

with open(file_path, "w", encoding="utf-8") as f:
    json.dump(data, f, indent=2, ensure_ascii=False)

print("Strings added to xcstrings.")
