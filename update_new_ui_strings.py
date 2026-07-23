import json

file_path = "Garten_Simulation/Localizable.xcstrings"

with open(file_path, "r", encoding="utf-8") as f:
    data = json.load(f)

translations = {
    "screenTime.blockedApps": {
        "en": "Blocked Apps (%@)",
        "de": "Geblockte Apps (%@)",
        "es": "Aplicaciones bloqueadas (%@)",
        "fr": "Applications bloquées (%@)",
        "it": "App bloccate (%@)",
        "pt": "Apps Bloqueados (%@)",
        "pt-BR": "Apps Bloqueados (%@)",
        "nl": "Geblokkeerde apps (%@)",
        "pl": "Zablokowane aplikacje (%@)",
        "ru": "Заблокированные приложения (%@)",
        "tr": "Engellenen Uygulamalar (%@)",
        "hi": "अवरुद्ध ऐप्स (%@)",
        "ja": "ブロックされたアプリ (%@)",
        "ko": "차단된 앱 (%@)",
        "zh-Hans": "已拦截应用 (%@)",
        "zh-Hant": "已攔截應用 (%@)"
    },
    "screenTime.schedule.desc": {
        "en": "Force focus at specific times.",
        "de": "Erzwinge Fokus zu bestimmten Zeiten.",
        "es": "Fuerza el enfoque en horarios específicos.",
        "fr": "Forcez la concentration à des heures précises.",
        "it": "Forza la concentrazione in orari specifici.",
        "pt": "Forçar foco em horários específicos.",
        "pt-BR": "Forçar foco em horários específicos.",
        "nl": "Forceer focus op specifieke tijden.",
        "pl": "Wymuszaj skupienie w określonych godzinach.",
        "ru": "Принудительная фокусировка в определенное время.",
        "tr": "Belirli zamanlarda odaklanmaya zorla.",
        "hi": "विशिष्ट समय पर फोकस को बाध्य करें।",
        "ja": "特定の時間帯に集中を強制します。",
        "ko": "특정 시간에 집중을 강제합니다.",
        "zh-Hans": "在特定时间强制保持专注。",
        "zh-Hant": "在特定時間強制保持專注。"
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
