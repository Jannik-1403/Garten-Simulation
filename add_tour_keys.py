import re
import time
from deep_translator import GoogleTranslator

app_strings_path = "/Users/jannikschill/Documents/Garten-Simulation/Garten_Simulation/Localization/AppStrings.swift"

languages = ["de", "en", "es", "fr", "pt", "it", "ja", "ko", "pl", "nl", "tr"]

new_keys = {
    "tour_prompt_title": ("Einführung", "App Tour"),
    "tour_prompt_desc": ("Möchtest du eine kurze Einführung in die wichtigsten Funktionen von Grovy erhalten?", "Would you like a quick tour of the main features of Grovy?"),
    "tour_prompt_yes": ("Ja, gerne!", "Yes, please!"),
    "tour_prompt_no": ("Nein, danke", "No, thanks"),
    "tour_1_title": ("Gießen & XP sammeln", "Watering & XP"),
    "tour_1_desc": ("Erledige deine Gewohnheiten und ziehe den Wassertropfen auf deine Pflanze, um sie wachsen zu lassen.", "Complete your habits and drag the water drop onto your plant to make it grow."),
    "tour_2_title": ("Schlechte Gewohnheiten", "Bad Habits"),
    "tour_2_desc": ("Achte auf Unkraut! Es wächst, wenn du schlechte Gewohnheiten hast und blockiert deinen Fortschritt.", "Watch out for weeds! They grow when you have bad habits and block your progress."),
    "tour_3_title": ("Shop & Power-Ups", "Shop & Power-Ups"),
    "tour_3_desc": ("Nutze deine Coins im Shop, um hilfreiche Power-Ups und süße Dekorationen zu kaufen.", "Use your coins in the shop to buy helpful power-ups and cute decorations."),
    "tour_4_title": ("Spiel Titel", "Game Titles"),
    "tour_4_desc": ("Spiele regelmäßig, um neue Titel zu verdienen und im Rang aufzusteigen.", "Play regularly to earn new titles and rank up."),
    "tour_5_title": ("Fokus Timer", "Focus Timer"),
    "tour_5_desc": ("Stelle Timer ein, um konzentriert an deinen Zielen zu arbeiten und mehr XP zu erhalten.", "Set timers to work focused on your goals and earn more XP."),
    "tour_6_title": ("Erfolge", "Achievements"),
    "tour_6_desc": ("Schalte verschiedene Erfolge frei, während du deine Gewohnheiten meisterst.", "Unlock various achievements as you master your habits."),
    "tour_7_title": ("Streak Statistik", "Streak Statistics"),
    "tour_7_desc": ("Behalte deine Fortschritte im Auge und versuche, deine Streak nicht abreißen zu lassen!", "Keep an eye on your progress and try not to break your streak!"),
    "tour_btn_next": ("Weiter", "Next"),
    "tour_btn_done": ("Los geht's!", "Let's go!")
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
        parts = content.rsplit(']', 1)
        new_content = parts[0].rstrip() + ",\n" + "".join(lines_to_add).rstrip(',\n') + "\n    ]" + parts[1]
        with open(app_strings_path, "w", encoding="utf-8") as f:
            f.write(new_content)
else:
    print("No new keys to add.")
