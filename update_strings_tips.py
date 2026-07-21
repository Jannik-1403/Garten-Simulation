import json

with open('Garten_Simulation/Localizable.xcstrings', 'r') as f:
    data = json.load(f)

new_keys = {
    "smart.weekly.title.tip": "Tipp",
    "smart.weekly.tip.no_focus": "Du hast diese Woche keine Fokus-Sessions genutzt. Baue feste Fokus-Zeiten in deinen Alltag ein. Reserviere dir jeden Tag zur selben Uhrzeit (z.B. direkt nach dem Frühstück) 25 Minuten, um eine Routine zu entwickeln.",
    "smart.weekly.tip.weekend_drop": "Am Wochenende bricht deine Fokuszeit komplett ein. Versuche, auch an diesen Tagen zumindest eine kleine 15-Minuten-Session einzulegen, um den Rhythmus nicht zu verlieren.",
    "smart.weekly.tip.gaps": "Du hast am %@ pausiert, bist aber sonst konstant. Um solche Aussetzer zu vermeiden, koppele deine Gewohnheiten an feste Anker in deinem Alltag (z.B. immer direkt nach dem Zähneputzen).",
    "smart.weekly.tip.early_bird": "Du hakst '%@' oft erst spät ab (gegen %d Uhr). Wenn du wirklich früh aufstehen willst, lege dein Handy abends in einen anderen Raum und stelle den Wecker 30 Minuten früher.",
    "smart.weekly.tip.late_habits": "Du erledigst viele Gewohnheiten erst spät am Abend. Versuche, deine wichtigste Gewohnheit direkt morgens als Erstes abzuhaken (Eat the Frog) – dann hast du den Rest des Tages den Kopf frei.",
    "smart.weekly.tip.fallback_low": "Sammle nächste Woche mehr Fokus-Sessions und hake Gewohnheiten ab, um präzise Tipps zu deinem Rhythmus zu erhalten.",
    "smart.weekly.tip.fallback_good": "Deine Routine ist sehr stabil! Halte diese Konsistenz aufrecht, indem du deine Gewohnheiten weiterhin an feste Zeiten koppelst."
}

translations = {
    "en": {
        "smart.weekly.title.tip": "Tip",
        "smart.weekly.tip.no_focus": "You didn't use any focus sessions this week. Build fixed focus times into your everyday life. Reserve 25 minutes every day at the same time (e.g., right after breakfast) to develop a routine.",
        "smart.weekly.tip.weekend_drop": "Your focus time completely collapses on the weekend. Try to fit in at least a small 15-minute session on these days so you don't lose your rhythm.",
        "smart.weekly.tip.gaps": "You paused on %@, but are otherwise consistent. To avoid such dropouts, link your habits to fixed anchors in your everyday life (e.g., always right after brushing your teeth).",
        "smart.weekly.tip.early_bird": "You often complete '%@' late (around %d o'clock). If you really want to wake up early, put your phone in another room in the evening and set the alarm 30 minutes earlier.",
        "smart.weekly.tip.late_habits": "You complete many habits late in the evening. Try checking off your most important habit first thing in the morning (Eat the Frog) - then your mind is clear for the rest of the day.",
        "smart.weekly.tip.fallback_low": "Collect more focus sessions and check off habits next week to get precise tips on your rhythm.",
        "smart.weekly.tip.fallback_good": "Your routine is very stable! Maintain this consistency by continuing to tie your habits to fixed times."
    }
}

langs = ["de", "en", "es", "fr", "hi", "it", "ja", "ko", "nl", "pl", "pt", "pt-BR", "ru", "tr", "zh-Hans", "zh-Hant"]

for key, de_text in new_keys.items():
    if key not in data['strings']:
        data['strings'][key] = {
            "extractionState": "manual",
            "localizations": {}
        }
    
    for lang in langs:
        val = translations.get(lang, {}).get(key, de_text)
        data['strings'][key]['localizations'][lang] = {
            "stringUnit": {
                "state": "translated",
                "value": val
            }
        }

with open('Garten_Simulation/Localizable.xcstrings', 'w') as f:
    json.dump(data, f, indent=2, ensure_ascii=False)
