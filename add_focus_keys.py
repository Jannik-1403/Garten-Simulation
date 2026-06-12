import re
import time
from deep_translator import GoogleTranslator

app_strings_path = "/Users/jannikschill/Documents/Garten-Simulation/Garten_Simulation/Localization/AppStrings.swift"

languages = ["de", "en", "es", "fr", "pt", "it", "ja", "ko", "pl", "nl", "tr"]

# mapping key to (de, en) tuple
new_keys = {
    "focus.priority.low": ("Niedrig", "Low"),
    "focus.priority.medium": ("Mittel", "Medium"),
    "focus.priority.high": ("Hoch", "High"),
    "focus.prep.step1.title": ("Ablenkungen weg", "Remove Distractions"),
    "focus.prep.step1.desc": ("Schalte dein Handy jetzt auf 'Nicht stören' und lege es nach dieser Einrichtung außer Sichtweite.", "Put your phone on 'Do Not Disturb' and place it out of sight after this setup."),
    "focus.prep.btn.done": ("Erledigt", "Done"),
    "focus.prep.step2.title": ("Klares Ziel", "Clear Goal"),
    "focus.prep.step2.desc": ("Was genau möchtest du in deiner Fokus-Zeit schaffen? Nimm dir einen Moment, um dich zu fokussieren.", "What exactly do you want to achieve in your focus time? Take a moment to focus."),
    "focus.prep.btn.start": ("Timer starten", "Start Timer"),
    "focus.timer.title": ("Fokus-Session", "Focus Session"),
    "focus.timer.duration": ("Dauer: %d Minuten", "Duration: %d Minutes"),
    "focus.timer.btn.prep": ("Vorbereitung starten", "Start Preparation"),
    "focus.timer.goals": ("Deine Ziele", "Your Goals"),
    "focus.input.main": ("Neues Hauptziel...", "New Main Goal..."),
    "focus.input.sub": ("Aufgabe hinzufügen...", "Add Task..."),
    "focus.sugg.fitness1": ("10 Min Dehnen", "10 Min Stretching"),
    "focus.sugg.fitness2": ("Wasser trinken", "Drink Water"),
    "focus.sugg.fitness3": ("Kurzer Spaziergang", "Short Walk"),
    "focus.sugg.fitness4": ("Gesunder Snack", "Healthy Snack"),
    "focus.sugg.growth1": ("Kapitel lesen", "Read a Chapter"),
    "focus.sugg.growth2": ("Podcast hören", "Listen to a Podcast"),
    "focus.sugg.growth3": ("Journaling", "Journaling"),
    "focus.sugg.mental1": ("Meditation", "Meditation"),
    "focus.sugg.mental2": ("Atemübung", "Breathing Exercise"),
    "focus.sugg.mental3": ("Bildschirm-Pause", "Screen Break"),
    "focus.sugg.prod1": ("Schreibtisch aufräumen", "Clean Desk"),
    "focus.sugg.prod2": ("To-Do Liste machen", "Make To-Do List"),
    "focus.sugg.prod3": ("E-Mails sortieren", "Sort Emails"),
    "focus.sugg.social1": ("Freund anrufen", "Call a Friend"),
    "focus.sugg.social2": ("Familienzeit", "Family Time"),
    "focus.sugg.social3": ("Kompliment machen", "Give a Compliment"),
    "focus.sugg.def1": ("Gießen", "Watering"),
    "focus.sugg.def2": ("Düngen", "Fertilize"),
    "focus.sugg.def3": ("Umtopfen", "Repotting")
}

with open(app_strings_path, "r", encoding="utf-8") as f:
    content = f.read()

lines_to_add = []
for key, (de_text, en_text) in new_keys.items():
    if f'"{key}"' in content:
        continue # Already exists
    translations = {}
    translations["de"] = de_text
    translations["en"] = en_text
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
    # Find the end of the `all` dictionary
    pattern = r'\n\s*\]\n\}\n?$'
    match = re.search(pattern, content)
    if match:
        insert_pos = match.start()
        new_content = content[:insert_pos] + ",\n" + "".join(lines_to_add).rstrip(',\n') + content[insert_pos:]
        with open(app_strings_path, "w", encoding="utf-8") as f:
            f.write(new_content)
        print("Keys added successfully.")
    else:
        print("Could not find insertion point. Appending manually...")
        # fallback
        parts = content.rsplit(']', 1)
        new_content = parts[0].rstrip() + ",\n" + "".join(lines_to_add).rstrip(',\n') + "\n    ]" + parts[1]
        with open(app_strings_path, "w", encoding="utf-8") as f:
            f.write(new_content)
else:
    print("No new keys to add.")

