import json

file_path = '/Users/jannikschill/Documents/Garten-Simulation/Garten_Simulation/Localizable.xcstrings'

with open(file_path, 'r', encoding='utf-8') as f:
    data = json.load(f)

new_keys = {
    "fitness.gratitude.summary.good": {
        "de": "Journal ✓", "en": "Journal ✓", "es": "Diario ✓", "fr": "Journal ✓", "it": "Diario ✓",
        "pt": "Diário ✓", "nl": "Dagboek ✓", "ru": "Журнал ✓", "zh": "日记 ✓", "ja": "日記 ✓"
    },
    "fitness.gratitude.summary.missing": {
        "de": "Journal fehlt", "en": "Journal missing", "es": "Falta el diario", "fr": "Journal manquant", "it": "Diario mancante",
        "pt": "Diário em falta", "nl": "Dagboek ontbreekt", "ru": "Журнал отсутствует", "zh": "缺少日记", "ja": "日記がありません"
    },
    "fitness.gratitude.detail.good": {
        "de": "Klasse, du hast dir heute schon Zeit für dein Journal genommen!", 
        "en": "Great, you have already taken time for your journal today!",
        "es": "¡Genial, ya te has tomado tiempo para tu diario hoy!",
        "fr": "Super, tu as déjà pris du temps pour ton journal aujourd'hui !",
        "it": "Fantastico, hai già dedicato del tempo al tuo diario oggi!"
    },
    "fitness.gratitude.detail.yesterday.improve": {
        "de": "Heute wolltest du laut gestern das hier besser machen: %@",
        "en": "Yesterday you said you wanted to do this better today: %@",
        "es": "Ayer dijiste que querías hacer esto mejor hoy: %@",
        "fr": "Hier, tu as dit que tu voulais mieux faire cela aujourd'hui : %@",
        "it": "Ieri hai detto che volevi fare meglio questo oggi: %@"
    },
    "fitness.gratitude.detail.yesterday.low": {
        "de": "Gestern hast du dich nicht so gut gefühlt. Probier heute dich besser zu fühlen oder gestalte deinen Tag so, dass du dich besser fühlst.",
        "en": "Yesterday you didn't feel so good. Try to feel better today or shape your day so you feel better.",
        "es": "Ayer no te sentiste muy bien. Intenta sentirte mejor hoy o diseña tu día para sentirte mejor.",
        "fr": "Hier, tu ne te sentais pas très bien. Essaie de te sentir mieux aujourd'hui ou organise ta journée pour te sentir mieux.",
        "it": "Ieri non ti sei sentito molto bene. Prova a sentirti meglio oggi o organizza la tua giornata per sentirti meglio."
    },
    "fitness.gratitude.detail.yesterday.high": {
        "de": "Gestern hast du dich exzellent gefühlt, mach heute weiter so!",
        "en": "Yesterday you felt excellent, keep it up today!",
        "es": "Ayer te sentiste excelente, ¡sigue así hoy!",
        "fr": "Hier tu te sentais très bien, continue comme ça aujourd'hui !",
        "it": "Ieri ti sei sentito eccellente, continua così oggi!"
    },
    "fitness.gratitude.detail.yesterday.medium": {
        "de": "Nutze dein Journal, um deinen Tag zu reflektieren.",
        "en": "Use your journal to reflect on your day.",
        "es": "Usa tu diario para reflexionar sobre tu día.",
        "fr": "Utilise ton journal pour réfléchir à ta journée.",
        "it": "Usa il tuo diario per riflettere sulla tua giornata."
    },
    "fitness.gratitude.detail.not_done": {
        "de": "Du hast heute noch kein Journal geschrieben. Halte kurz inne und reflektiere deinen Tag.",
        "en": "You haven't written a journal today. Pause for a moment and reflect on your day.",
        "es": "Aún no has escrito un diario hoy. Haz una pausa y reflexiona sobre tu día.",
        "fr": "Tu n'as pas encore écrit dans ton journal aujourd'hui. Fais une pause et réfléchis à ta journée.",
        "it": "Non hai ancora scritto un diario oggi. Fai una pausa e rifletti sulla tua giornata."
    },
    "fitness.category.gratitude": {
        "de": "Dankbarkeits-Check", "en": "Gratitude Check", "es": "Control de gratitud", "fr": "Bilan de gratitude", "it": "Controllo gratitudine",
        "pt": "Check de Gratidão", "nl": "Dankbaarheidscheck", "ru": "Проверка благодарности", "zh": "感恩检查", "ja": "感謝チェック"
    },
    "tagesanalyseHeaderDankbarkeit": {
        "de": "Dankbarkeits-Check", "en": "Gratitude Check", "es": "Control de gratitud", "fr": "Bilan de gratitude", "it": "Controllo gratitudine",
        "pt": "Check de Gratidão", "nl": "Dankbaarheidscheck", "ru": "Проверка благодарности", "zh": "感恩检查", "ja": "感謝チェック"
    }
}

languages_in_file = set()
for string_data in data.get("strings", {}).values():
    if "localizations" in string_data:
        languages_in_file.update(string_data["localizations"].keys())

for key, translations in new_keys.items():
    if key not in data["strings"]:
        data["strings"][key] = {
            "extractionState": "manual",
            "localizations": {}
        }
    
    for lang in languages_in_file:
        trans_text = translations.get(lang, translations.get("en", translations.get("de")))
        data["strings"][key]["localizations"][lang] = {
            "stringUnit": {
                "state": "translated",
                "value": trans_text
            }
        }

with open(file_path, 'w', encoding='utf-8') as f:
    json.dump(data, f, indent=2, ensure_ascii=False)

print(f"Added {len(new_keys)} strings across {len(languages_in_file)} languages.")
