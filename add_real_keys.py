import re
import time
from deep_translator import GoogleTranslator

app_strings_path = "/Users/jannikschill/Documents/Garten-Simulation/Garten_Simulation/Localization/AppStrings.swift"
languages = ["de", "en", "es", "fr", "pt", "it", "ja", "ko", "pl", "nl", "tr"]

new_keys = {
    "10 Min Dehnen": "10 Min Stretching",
    "Workout aufwärmen": "Warm up workout",
    "Ausrüstung richten": "Prepare equipment",
    "Wasser trinken": "Drink water",
    "Gesundes Rezept planen": "Plan healthy recipe",
    "Ernährungstagebuch": "Food diary",
    "Tiefes Atmen": "Deep breathing",
    "Journaling": "Journaling",
    "Meditation starten": "Start meditation",
    "1 Kapitel lesen": "Read 1 chapter",
    "Vokabeln wiederholen": "Review vocabulary",
    "Zusammenfassung schreiben": "Write summary",
    "Zimmer aufräumen": "Tidy room",
    "Pflanzen gießen": "Water plants",
    "Wochenplan erstellen": "Create weekly plan",
    "Ausgaben tracken": "Track expenses",
    "Budget überprüfen": "Check budget",
    "Rechnungen bezahlen": "Pay bills",
    "Fokus setzen": "Set focus",
    "Handy weglegen": "Put phone away",
    "Ablenkungen blockieren": "Block distractions",
    "Niedrig": "Low",
    "Mittel": "Medium",
    "Hoch": "High",
    "Ablenkungen weg": "Remove Distractions",
    "Schalte dein Handy jetzt auf 'Nicht stören' und lege es nach dieser Einrichtung außer Sichtweite.": "Put your phone on 'Do Not Disturb' and place it out of sight after this setup.",
    "Erledigt": "Done",
    "Klares Ziel": "Clear Goal",
    "Was genau möchtest du in deiner Fokus-Zeit schaffen? Nimm dir einen Moment, um dich zu fokussieren.": "What exactly do you want to achieve in your focus time? Take a moment to focus.",
    "Timer starten": "Start Timer",
    "Fokus-Session": "Focus Session",
    "Dauer: %lld Minuten": "Duration: %lld Minutes",
    "Vorbereitung starten": "Start Preparation",
    "Neues Hauptziel...": "New Main Goal...",
    "Aufgabe hinzufügen...": "Add Task...",
    "Deine Ziele": "Your Goals"
}

with open(app_strings_path, "r", encoding="utf-8") as f:
    content = f.read()

lines_to_add = []
for key, en_text in new_keys.items():
    if f'"{key}"' in content:
        continue
    translations = {"de": key, "en": en_text}
    print(f"Translating {key}...")
    for lang in languages:
        if lang in ["de", "en"]: continue
        try:
            res = GoogleTranslator(source='en', target=lang).translate(en_text)
            translations[lang] = res.replace('"', '\\"') if res else en_text
        except Exception as e:
            print(f"Failed {lang}: {e}")
            translations[lang] = en_text
        time.sleep(0.05)
    dict_str = ", ".join([f'"{l}": "{t}"' for l, t in translations.items()])
    lines_to_add.append(f'        "{key}": [{dict_str}],\n')

if lines_to_add:
    pattern = r'\n\s*\]\n\}\n?$'
    match = re.search(pattern, content)
    if match:
        insert_pos = match.start()
        new_content = content[:insert_pos] + ",\n" + "".join(lines_to_add).rstrip(',\n') + content[insert_pos:]
        with open(app_strings_path, "w", encoding="utf-8") as f:
            f.write(new_content)
        print("Keys added successfully.")
    else:
        parts = content.rsplit(']', 1)
        new_content = parts[0].rstrip() + ",\n" + "".join(lines_to_add).rstrip(',\n') + "\n    ]" + parts[1]
        with open(app_strings_path, "w", encoding="utf-8") as f:
            f.write(new_content)
else:
    print("No new keys to add.")

