import re
import json
import os
import sys
import time

try:
    from deep_translator import GoogleTranslator
except ImportError:
    print("Please install deep-translator")
    sys.exit(1)

swift_file_path = "Garten_Simulation/Models/HabitProgressionStrategy.swift"
xcstrings_path = "Garten_Simulation/Localizable.xcstrings"

# Revert swift file to extract strings properly if it was partially modified
import subprocess
subprocess.run(["git", "checkout", swift_file_path])

with open(swift_file_path, "r", encoding="utf-8") as f:
    lines = f.readlines()

new_lines = []
translations_to_add = {}

current_strategy = ""
current_day = 0

lang_mapping = {
    'en': 'en', 'es': 'es', 'fr': 'fr', 'hi': 'hi', 'it': 'it',
    'ja': 'ja', 'ko': 'ko', 'nl': 'nl', 'pl': 'pl', 'pt': 'pt',
    'pt-BR': 'pt', 'ru': 'ru', 'tr': 'tr', 'zh-Hans': 'zh-CN', 'zh-Hant': 'zh-TW'
}

weekday_prefixes = ["Montag: ", "Dienstag: ", "Mittwoch: ", "Donnerstag: ", "Freitag: ", "Samstag: ", "Sonntag: ", "Montag ", "Dienstag ", "Mittwoch ", "Donnerstag ", "Freitag ", "Samstag ", "Sonntag "]

def strip_weekdays(text):
    for prefix in weekday_prefixes:
        if text.startswith(prefix):
            return text[len(prefix):]
    return text

def sanitize_key(text):
    return "".join([c if c.isalnum() else "_" for c in text.lower()])[:20]

for line in lines:
    if "class " in line and "ProgressionStrategy" in line:
        current_strategy = line.split("class ")[1].split("ProgressionStrategy")[0].lower()
    
    day_match = re.search(r'case (\d+):', line)
    if day_match:
        current_day = int(day_match.group(1))
        
    title_match = re.search(r'title = "(.*?)"', line)
    if title_match:
        val = title_match.group(1)
        val = strip_weekdays(val)
        if val != "":
            key = f"prog_{current_strategy}_d{current_day}_title"
            translations_to_add[key] = val
            line = line.replace(title_match.group(0), f'title = String(localized: "{key}", defaultValue: "{val}")')
            
    desc_match = re.search(r'desc = "(.*?)"', line)
    if desc_match:
        val = desc_match.group(1)
        if val != "":
            key = f"prog_{current_strategy}_d{current_day}_desc"
            translations_to_add[key] = val
            line = line.replace(desc_match.group(0), f'desc = String(localized: "{key}", defaultValue: "{val}")')

    todos_match = re.search(r'todos = \[(.*?)\]', line)
    if todos_match and "]" in line:
        todo_content = todos_match.group(1)
        strs = re.findall(r'"(.*?)"', todo_content)
        new_todo_content = todo_content
        for i, s in enumerate(strs):
            key = f"prog_{current_strategy}_d{current_day}_t{i+1}"
            translations_to_add[key] = s
            new_todo_content = new_todo_content.replace(f'"{s}"', f'String(localized: "{key}", defaultValue: "{s}")', 1)
        line = line.replace(todo_content, new_todo_content)

    phase_title_match = re.search(r'phaseTitle: "(.*?)"', line)
    if phase_title_match:
        val = phase_title_match.group(1)
        key = f"prog_{current_strategy}_phase_title_{sanitize_key(val)}"
        translations_to_add[key] = val
        line = line.replace(phase_title_match.group(0), f'phaseTitle: String(localized: "{key}", defaultValue: "{val}")')
        
    phase_desc_match = re.search(r'phaseDescription: "(.*?)"', line)
    if phase_desc_match:
        val = phase_desc_match.group(1)
        key = f"prog_{current_strategy}_phase_desc_{sanitize_key(val)}"
        translations_to_add[key] = val
        line = line.replace(phase_desc_match.group(0), f'phaseDescription: String(localized: "{key}", defaultValue: "{val}")')
        
    new_lines.append(line)

with open(swift_file_path, "w", encoding="utf-8") as f:
    f.writelines(new_lines)
print(f"Updated {swift_file_path}")

print(f"Found {len(translations_to_add)} strings to translate.")

with open(xcstrings_path, "r", encoding="utf-8") as f:
    xc_data = json.load(f)

if "strings" not in xc_data:
    xc_data["strings"] = {}

# Ensure German (de) exists and default strings are in xc_data
for key, de_text in translations_to_add.items():
    if key not in xc_data["strings"]:
        xc_data["strings"][key] = {
            "extractionState": "manual",
            "localizations": {}
        }
    locs = xc_data["strings"][key]["localizations"]
    if "de" not in locs:
        locs["de"] = {
            "stringUnit": {
                "state": "translated",
                "value": de_text
            }
        }

total_translations = 0

# Prepare arrays for batch translation per language
for xc_lang, google_lang in lang_mapping.items():
    keys_to_translate = []
    texts_to_translate = []
    
    for key, de_text in translations_to_add.items():
        locs = xc_data["strings"][key]["localizations"]
        if xc_lang not in locs or locs[xc_lang]["stringUnit"]["state"] != "translated":
            keys_to_translate.append(key)
            safe_text = re.sub(r'\\\((.*?)\)', r'[\1]', de_text)
            texts_to_translate.append(safe_text)
            
    if not keys_to_translate:
        continue
        
    print(f"Translating {len(keys_to_translate)} strings for {xc_lang}...")
    
    # Batch limit for deep-translator (usually 50 items or 5000 chars)
    batch_size = 50
    for i in range(0, len(texts_to_translate), batch_size):
        batch_keys = keys_to_translate[i:i+batch_size]
        batch_texts = texts_to_translate[i:i+batch_size]
        
        try:
            translated_batch = GoogleTranslator(source='de', target=google_lang).translate_batch(batch_texts)
            
            for k, key in enumerate(batch_keys):
                translated = translated_batch[k]
                translated = re.sub(r'\[(.*?)\]', r'\\(\1)', translated)
                xc_data["strings"][key]["localizations"][xc_lang] = {
                    "stringUnit": {
                        "state": "translated",
                        "value": translated
                    }
                }
                total_translations += 1
                
        except Exception as e:
            print(f"Failed to translate batch to {xc_lang}: {e}")
            
    # Save after each language
    with open(xcstrings_path, "w", encoding="utf-8") as f:
        json.dump(xc_data, f, indent=2, ensure_ascii=False)
        
    time.sleep(1) # Small delay to respect rate limit

print(f"Done! Added {total_translations} translations to {xcstrings_path}")
