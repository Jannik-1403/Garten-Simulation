import json
import time
from deep_translator import GoogleTranslator
import concurrent.futures
import threading

with open("/Users/jannikschill/Documents/Garten-Simulation/Garten_Simulation/Localizable.xcstrings", "r") as f:
    data = json.load(f)

languages = set()
for key, value in data["strings"].items():
    if "localizations" in value:
        for lang in value["localizations"].keys():
            languages.add(lang)
languages = sorted(list(languages))

tasks = []
for key, value in data["strings"].items():
    default_text = ""
    # find german or english text
    if "localizations" in value and "de" in value["localizations"] and value["localizations"]["de"].get("stringUnit", {}).get("state") == "translated":
        default_text = value["localizations"]["de"]["stringUnit"]["value"]
    elif "localizations" in value and "en" in value["localizations"] and value["localizations"]["en"].get("stringUnit", {}).get("state") == "translated":
        default_text = value["localizations"]["en"]["stringUnit"]["value"]
    else:
        # Check extractionState
        if value.get("extractionState") == "manual" and not (" " in key or key.istitle()):
            continue
        if "." not in key and "_" not in key:
            default_text = key
        else:
            continue

    if not default_text: continue

    if "localizations" not in value:
        value["localizations"] = {}

    for lang in languages:
        if lang not in value["localizations"] or value["localizations"][lang].get("stringUnit", {}).get("state") != "translated":
            # skip if the translation is already there
            if "stringUnit" in value["localizations"].get(lang, {}) and value["localizations"][lang]["stringUnit"].get("state") == "translated":
                continue
            
            tasks.append((key, lang, default_text))

print(f"Total translation tasks: {len(tasks)}")

lock = threading.Lock()
completed = 0
failed = 0

# Limit unique requests by caching identical source strings per language
cache = {}

def translate_task(task):
    global completed, failed
    key, lang, text = task
    target_lang = lang
    if lang == "zh-Hans": target_lang = "zh-CN"
    elif lang == "zh-Hant": target_lang = "zh-TW"
    elif lang == "pt-BR": target_lang = "pt"
    
    cache_key = f"{text}_{target_lang}"
    
    try:
        with lock:
            is_cached = cache_key in cache
            if is_cached:
                translated = cache[cache_key]
        
        if not is_cached:
            translator = GoogleTranslator(source='auto', target=target_lang)
            translated = translator.translate(text)
            with lock:
                cache[cache_key] = translated
        
        with lock:
            if lang not in data["strings"][key]["localizations"]:
                data["strings"][key]["localizations"][lang] = {}
            data["strings"][key]["localizations"][lang]["stringUnit"] = {
                "state": "translated",
                "value": translated
            }
            completed += 1
            if completed % 100 == 0:
                print(f"Progress: {completed}/{len(tasks)}")
    except Exception as e:
        with lock:
            failed += 1
            print(f"Failed {key} to {lang}: {e}")

with concurrent.futures.ThreadPoolExecutor(max_workers=30) as executor:
    executor.map(translate_task, tasks)

print(f"Done! Completed: {completed}, Failed: {failed}")

with open("/Users/jannikschill/Documents/Garten-Simulation/Garten_Simulation/Localizable.xcstrings", "w") as f:
    json.dump(data, f, indent=2, ensure_ascii=False)
