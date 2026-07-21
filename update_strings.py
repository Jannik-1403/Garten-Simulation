import json
import re

file_path = "Garten_Simulation/Localizable.xcstrings"

with open(file_path, "r") as f:
    data = json.load(f)

languages = ['de', 'en', 'es', 'fr', 'hi', 'it', 'ja', 'ko', 'nl', 'pl', 'pt', 'pt-BR', 'ru', 'tr', 'zh-Hans', 'zh-Hant']

# Map of key -> Default German Value
new_strings = {
    "prog_strength_phase1_desc": "Fundament & Basisaufbau",
    "prog_strength_phase2_desc": "Intensivierung & Hypertrophie",
    "prog_strength_phase3_desc": "Crucible & Maximale Kraft",
    "prog_strength_d1_title": "Push-Fokus",
    "prog_strength_d1_desc": "Absolviere ein EMOM (Every Minute on the Minute) - %lld Minuten.\nMinute 1: Übung 1\nMinute 2: Übung 2\nMinute 3: Übung 3\nMinute 4: Pause",
    "prog_strength_rounds": "%lld Runden absolviert",
    "prog_strength_d1_t1": "Minute 1: %lld %@",
    "prog_strength_d1_t2": "Minute 2: %@",
    "prog_strength_d1_t3": "Minute 3: 30s Pike Hold / Handstand",
    "prog_strength_d2_title": "Pull & Core",
    "prog_strength_d2_desc": "Absolviere ein EMOM - %lld Minuten.\nZiele auf saubere Wiederholungen ohne Schwung.",
    "prog_strength_d2_t1": "Minute 1: %@",
    "prog_strength_d2_t2": "Minute 2: %lld Bodyweight Rows",
    "prog_strength_d2_t3": "Minute 3: 15-20 Leg Raises",
    "prog_strength_d3_title": "Explosive Kraft",
    "prog_strength_d3_desc": "Fokus auf 100% Effort pro Sprint. Langsame Erholung beim Zurückgehen.",
    "prog_strength_d3_t1": "10 Min dynamisches Dehnen",
    "prog_strength_d3_t2": "%lld x %@ Sprints (Maximale Intensität)",
    "prog_strength_d3_t3": "3x 15 Jump Squats Finisher",
    "prog_strength_d4_title": "Kapazität (AMRAP)",
    "prog_strength_d4_desc": "Stelle einen Timer auf %lld Minuten. Absolviere so viele saubere Runden wie möglich. Bei unsauberer Technik abbrechen!",
    "prog_strength_d4_t1": "%lld Minuten Timer absolviert",
    "prog_strength_d4_t2": "Runde: %lld Pull-ups",
    "prog_strength_d4_t3": "Runde: %lld Push-ups",
    "prog_strength_d5_title": "Beine & Core",
    "prog_strength_d5_desc": "Absolviere ein EMOM - %lld Minuten. Squats müssen tief sein (Hüfte unter Kniehöhe).",
    "prog_strength_d5_t1": "Minute 1: %lld %@",
    "prog_strength_d5_t2": "Minute 2: %lld Squats",
    "prog_strength_d5_t3": "Minute 3: 40s Plank / L-Sit",
    "prog_strength_d6_title": "MetCon",
    "prog_strength_d6_desc": "Auf Zeit! Absolviere %lld Runden so schnell wie möglich mit sauberer Form. Ziel: Bei hohem Puls Technik beibehalten.",
    "prog_strength_d6_t1": "Übung: %lld Burpees",
    "prog_strength_d6_t2": "Übung: %@ Lauf",
    "prog_strength_d6_t3": "Übung: %@",
    "prog_strength_d7_title": "Aktive Erholung",
    "prog_strength_d7_desc": "KEIN Sofa-Tag. Aktive Regeneration für Muskeln und Nervensystem.",
    "prog_strength_d7_t1": "30 Min Mobilitätsarbeit / Dehnen",
    "prog_strength_d7_t2": "Leichter Spaziergang (30+ Min)",
    "prog_strength_d7_t3": "Mentale Vorbereitung auf nächste Woche"
}

en_translations = {
    "prog_strength_phase1_desc": "Foundation & Basics",
    "prog_strength_phase2_desc": "Intensification & Hypertrophy",
    "prog_strength_phase3_desc": "Crucible & Maximum Strength",
    "prog_strength_d1_title": "Push Focus",
    "prog_strength_d1_desc": "Complete an EMOM (Every Minute on the Minute) - %lld minutes.\nMinute 1: Exercise 1\nMinute 2: Exercise 2\nMinute 3: Exercise 3\nMinute 4: Rest",
    "prog_strength_rounds": "%lld rounds completed",
    "prog_strength_d1_t1": "Minute 1: %lld %@",
    "prog_strength_d1_t2": "Minute 2: %@",
    "prog_strength_d1_t3": "Minute 3: 30s Pike Hold / Handstand",
    "prog_strength_d2_title": "Pull & Core",
    "prog_strength_d2_desc": "Complete an EMOM - %lld minutes.\nAim for clean reps without swinging.",
    "prog_strength_d2_t1": "Minute 1: %@",
    "prog_strength_d2_t2": "Minute 2: %lld Bodyweight Rows",
    "prog_strength_d2_t3": "Minute 3: 15-20 Leg Raises",
    "prog_strength_d3_title": "Explosive Strength",
    "prog_strength_d3_desc": "Focus on 100% effort per sprint. Slow recovery while walking back.",
    "prog_strength_d3_t1": "10 min dynamic stretching",
    "prog_strength_d3_t2": "%lld x %@ Sprints (Max Intensity)",
    "prog_strength_d3_t3": "3x 15 Jump Squats Finisher",
    "prog_strength_d4_title": "Capacity (AMRAP)",
    "prog_strength_d4_desc": "Set a timer for %lld minutes. Complete as many clean rounds as possible. Stop if form breaks down!",
    "prog_strength_d4_t1": "%lld minute timer completed",
    "prog_strength_d4_t2": "Round: %lld Pull-ups",
    "prog_strength_d4_t3": "Round: %lld Push-ups",
    "prog_strength_d5_title": "Legs & Core",
    "prog_strength_d5_desc": "Complete an EMOM - %lld minutes. Squats must be deep (hips below knees).",
    "prog_strength_d5_t1": "Minute 1: %lld %@",
    "prog_strength_d5_t2": "Minute 2: %lld Squats",
    "prog_strength_d5_t3": "Minute 3: 40s Plank / L-Sit",
    "prog_strength_d6_title": "MetCon",
    "prog_strength_d6_desc": "For time! Complete %lld rounds as fast as possible with clean form. Goal: Maintain technique at high heart rate.",
    "prog_strength_d6_t1": "Exercise: %lld Burpees",
    "prog_strength_d6_t2": "Exercise: %@ Run",
    "prog_strength_d6_t3": "Exercise: %@",
    "prog_strength_d7_title": "Active Recovery",
    "prog_strength_d7_desc": "NO couch day. Active regeneration for muscles and nervous system.",
    "prog_strength_d7_t1": "30 min mobility work / stretching",
    "prog_strength_d7_t2": "Light walk (30+ min)",
    "prog_strength_d7_t3": "Mental preparation for next week"
}

if "strings" not in data:
    data["strings"] = {}

for key, de_val in new_strings.items():
    if key not in data["strings"]:
        data["strings"][key] = {
            "extractionState": "manual",
            "localizations": {}
        }
    
    # German
    data["strings"][key]["localizations"]["de"] = {
        "stringUnit": {
            "state": "translated",
            "value": de_val
        }
    }
    
    # English
    en_val = en_translations.get(key, de_val)
    data["strings"][key]["localizations"]["en"] = {
        "stringUnit": {
            "state": "translated",
            "value": en_val
        }
    }
    
    # Other languages
    for lang in languages:
        if lang not in ["de", "en"]:
            data["strings"][key]["localizations"][lang] = {
                "stringUnit": {
                    "state": "translated",
                    "value": en_val  # Fallback to English for now, keeping it robust
                }
            }
            
with open(file_path, "w") as f:
    json.dump(data, f, indent=2, ensure_ascii=False)

print("Strings injected successfully.")
