import json
import re

file_path = "Garten_Simulation/Localizable.xcstrings"

with open(file_path, "r") as f:
    data = json.load(f)

def fix_string(key, text):
    if not text or "\\(" not in text:
        return text
    
    # Exception for Screen Time Ignore button that might have been mistranslated to \(15...
    if "prog_screentime_d1_desc" in key:
        text = re.sub(r'\\\((15[^)]*)\)', r'(\1)', text)
        if "\\(" not in text:
             return text

    # Handle String(format:) -> %@
    text = re.sub(r'\\\(String\(format:[^)]+\)\)', '%@', text)
    
    # Determine what to replace \(...) with based on the key
    if "_phase_title" in key:
        text = re.sub(r'\\\([^)]+\)', '%lld', text)
    elif "prog_running_d2_t2" in key:
        # Expected two vars: \(intervals)x \(sprintTime)
        # Find all occurrences of \(...)
        matches = re.findall(r'\\\([^)]+\)', text)
        if len(matches) == 2:
            text = text.replace(matches[0], '%lld', 1)
            text = text.replace(matches[1], '%@', 1)
        else:
            text = re.sub(r'\\\([^)]+\)', '%lld', text) # Fallback
    elif "prog_running_" in key and ("d1_t1" in key or "d4_t1" in key or "d6_t1" in key):
        text = re.sub(r'\\\([^)]+\)', '%@', text)
    elif "prog_water_" in key:
        text = re.sub(r'\\\([^)]+\)', '%@', text)
    elif "prog_saving_" in key:
        text = re.sub(r'\\\([^)]+\)', '%@', text)
    else:
        # Default to %lld for currentMin, currentSec, targetCount, rounds etc.
        text = re.sub(r'\\\([^)]+\)', '%lld', text)
        
    return text

if "strings" in data:
    for key, val in data["strings"].items():
        if "localizations" in val:
            for lang, lang_val in val["localizations"].items():
                if "stringUnit" in lang_val and "value" in lang_val["stringUnit"]:
                    original = lang_val["stringUnit"]["value"]
                    fixed = fix_string(key, original)
                    if fixed != original:
                        data["strings"][key]["localizations"][lang]["stringUnit"]["value"] = fixed

with open(file_path, "w") as f:
    json.dump(data, f, indent=2, ensure_ascii=False)

print("Interpolation strings fixed successfully.")
