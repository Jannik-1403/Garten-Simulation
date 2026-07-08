import json

path = "Garten_Simulation/Localizable.xcstrings"
with open(path, "r", encoding="utf-8") as f:
    data = json.load(f)

translations = {
    "widget_streak_days": {
        "de": "TAGE", "en": "DAYS", "nl": "DAGEN", "fr": "JOURS", "it": "GIORNI",
        "ja": "日", "ko": "일", "pl": "DNI", "pt": "DIAS", "es": "DÍAS", "tr": "GÜN"
    },
    "widget_verlauf_week_title": {
        "de": "WOCHENVERLAUF", "en": "WEEKLY HISTORY", "nl": "WEEKVERLOOP", "fr": "HISTORIQUE HEBDO", "it": "STORIA SETTIMANALE",
        "ja": "週間履歴", "ko": "주간 기록", "pl": "HISTORIA TYGODNIOWA", "pt": "HISTÓRICO SEMANAL", "es": "HISTORIAL SEMANAL", "tr": "HAFTALIK GEÇMİŞ"
    },
    "widget_verlauf_month_title": {
        "de": "Monatsverlauf", "en": "Monthly History", "nl": "Maandverloop", "fr": "Historique Mensuel", "it": "Storia Mensile",
        "ja": "月間履歴", "ko": "월간 기록", "pl": "Historia Miesięczna", "pt": "Histórico Mensal", "es": "Historial Mensual", "tr": "Aylık Geçmiş"
    },
    "widget_streak_current": {
        "de": "Aktuell: %d", "en": "Current: %d", "nl": "Huidig: %d", "fr": "Actuel: %d", "it": "Attuale: %d",
        "ja": "現在: %d", "ko": "현재: %d", "pl": "Obecnie: %d", "pt": "Atual: %d", "es": "Actual: %d", "tr": "Mevcut: %d"
    }
}

for key, langs in translations.items():
    if key not in data["strings"]:
        data["strings"][key] = {"extractionState": "manual", "localizations": {}}
    for lang, text in langs.items():
        data["strings"][key]["localizations"][lang] = {
            "stringUnit": {
                "state": "translated",
                "value": text
            }
        }

with open(path, "w", encoding="utf-8") as f:
    json.dump(data, f, indent=2, ensure_ascii=False)
