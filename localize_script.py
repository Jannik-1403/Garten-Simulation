import re
import json
import os
import sys

# Ensure deep-translator is installed (we saw it is, but just to be safe)
try:
    from deep_translator import GoogleTranslator
except ImportError:
    print("Please install deep-translator")
    sys.exit(1)

swift_file_path = "Garten_Simulation/Models/HabitProgressionStrategy.swift"
xcstrings_path = "Garten_Simulation/Localizable.xcstrings"

with open(swift_file_path, "r", encoding="utf-8") as f:
    lines = f.readlines()

new_lines = []
translations_to_add = {} # dict of key: default_value

current_strategy = ""
current_day = 0
current_todos = []

# mapping for languages (Google Translate codes)
# Xcode codes: ['de', 'en', 'es', 'fr', 'hi', 'it', 'ja', 'ko', 'nl', 'pl', 'pt', 'pt-BR', 'ru', 'tr', 'zh-Hans', 'zh-Hant']
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

in_todo_array = False
todo_idx = 0

for line in lines:
    original_line = line
    
    # Track current strategy
    if "class " in line and "ProgressionStrategy" in line:
        current_strategy = line.split("class ")[1].split("ProgressionStrategy")[0].lower()
    
    # Track current day
    day_match = re.search(r'case (\d+):', line)
    if day_match:
        current_day = int(day_match.group(1))
        
    # Match title
    title_match = re.search(r'title = "(.*?)"', line)
    if title_match:
        val = title_match.group(1)
        val = strip_weekdays(val)
        if val != "":
            key = f"prog_{current_strategy}_d{current_day}_title"
            translations_to_add[key] = val
            line = line.replace(title_match.group(0), f'title = String(localized: "{key}", defaultValue: "{val}")')
            
    # Match desc
    desc_match = re.search(r'desc = "(.*?)"', line)
    if desc_match:
        val = desc_match.group(1)
        if val != "":
            key = f"prog_{current_strategy}_d{current_day}_desc"
            translations_to_add[key] = val
            line = line.replace(desc_match.group(0), f'desc = String(localized: "{key}", defaultValue: "{val}")')

    # Todos: Match single-line array
    todos_match = re.search(r'todos = \[(.*?)\]', line)
    if todos_match and "]" in line:
        todo_content = todos_match.group(1)
        # Find all string literals
        strs = re.findall(r'"(.*?)"', todo_content)
        new_todo_content = todo_content
        for i, s in enumerate(strs):
            key = f"prog_{current_strategy}_d{current_day}_t{i+1}"
            translations_to_add[key] = s
            # carefully replace just this string instance (simplistic replace might fail if duplicates, but should be ok here)
            new_todo_content = new_todo_content.replace(f'"{s}"', f'String(localized: "{key}", defaultValue: "{s}")', 1)
        line = line.replace(todo_content, new_todo_content)

    # Phase info and other simple hardcoded returns
    if "return ProgressionData(" in line:
        pass # we will catch the lines inside
    
    phase_title_match = re.search(r'phaseTitle: "(.*?)"', line)
    if phase_title_match:
        val = phase_title_match.group(1)
        key = f"prog_{current_strategy}_phase_title_{sanitize_key(val)}"
        translations_to_add[key] = val
        line = line.replace(phase_title_match.group(0), f'phaseTitle: String(localized: "{key}", defaultValue: "{val}")')
        
    phase_desc_match = re.search(r'phaseDescription: "(.*?)"', line)
    if phase_desc_match:
        val = phase_desc_match.group(1)
        key = f"prog_{current_strategy}_phase_desc"
        translations_to_add[key] = val
        line = line.replace(phase_desc_match.group(0), f'phaseDescription: String(localized: "{key}", defaultValue: "{val}")')
        
    new_lines.append(line)

with open(swift_file_path, "w", encoding="utf-8") as f:
    f.writelines(new_lines)
print(f"Updated {swift_file_path}")

print(f"Found {len(translations_to_add)} strings to translate.")

# Update Localizable.xcstrings
with open(xcstrings_path, "r", encoding="utf-8") as f:
    xc_data = json.load(f)

if "strings" not in xc_data:
    xc_data["strings"] = {}

total_translations = 0
for key, de_text in translations_to_add.items():
    if key not in xc_data["strings"]:
        xc_data["strings"][key] = {
            "extractionState": "manual",
            "localizations": {}
        }
    
    locs = xc_data["strings"][key]["localizations"]
    
    # Add German
    if "de" not in locs:
        locs["de"] = {
            "stringUnit": {
                "state": "translated",
                "value": de_text
            }
        }
    
    for xc_lang, google_lang in lang_mapping.items():
        if xc_lang not in locs:
            try:
                # Some strings have interpolation like \(phaseNumber) or \(targetCount)
                # Let's clean them before translation and restore them, or let Google try (risky)
                # Google translate usually leaves \(something) alone, but to be safe:
                safe_text = re.sub(r'\\\((.*?)\)', r'[\1]', de_text)
                
                translated = GoogleTranslator(source='de', target=google_lang).translate(safe_text)
                
                # Restore
                translated = re.sub(r'\[(.*?)\]', r'\\(\1)', translated)
                
                locs[xc_lang] = {
                    "stringUnit": {
                        "state": "translated",
                        "value": translated
                    }
                }
                total_translations += 1
            except Exception as e:
                print(f"Failed to translate '{de_text}' to {xc_lang}: {e}")

with open(xcstrings_path, "w", encoding="utf-8") as f:
    json.dump(xc_data, f, indent=2, ensure_ascii=False)

print(f"Added {total_translations} translations to {xcstrings_path}")
