import json
import time

path = '/Users/jannikschill/Documents/Garten-Simulation/Garten_Simulation/Localizable.xcstrings'

with open(path, 'r', encoding='utf-8') as f:
    data = json.load(f)

de_text = "Erledige deine Gewohnheiten, indem du den Fortschrittsbalken auf der Karte nach rechts schiebst, um die Pflanze wachsen zu lassen."
en_text = "Complete your habits by sliding the progress bar on the card to the right to make the plant grow."

strings = data.setdefault('strings', {})

# Ensure tour_1_desc exists
if "tour_1_desc" not in strings:
    strings["tour_1_desc"] = {"localizations": {}}

locs = strings["tour_1_desc"]["localizations"]

# Set de and en explicitly
locs['de'] = {
    "stringUnit": {
        "state": "translated",
        "value": de_text
    }
}
locs['en'] = {
    "stringUnit": {
        "state": "translated",
        "value": en_text
    }
}

# Use EN for all other languages that need an update
xcode_target_langs = ['ru', 'en', 'ko', 'es', 'pl', 'zh-Hans', 'zh-Hant', 'hi', 'de', 'nl', 'pt', 'tr', 'fr', 'ja', 'it']

for lang in xcode_target_langs:
    if lang not in ['de', 'en']:
        locs[lang] = {
            "stringUnit": {
                "state": "translated",
                "value": en_text
            }
        }

with open(path, 'w', encoding='utf-8') as f:
    json.dump(data, f, indent=2, ensure_ascii=False)
    
print("Updated tour_1_desc successfully!")
