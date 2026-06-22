import glob
import re
import os

# 1. Clean Localizable.strings
for path in glob.glob('*.lproj/Localizable.strings'):
    with open(path, 'r', encoding='utf-8') as f:
        lines = f.readlines()
    
    new_lines = [line for line in lines if not line.strip().startswith('"assessment.')]
    
    with open(path, 'w', encoding='utf-8') as f:
        f.writelines(new_lines)
    print(f"Cleaned {path}")

# 2. Update assessment.category.sub in AppStrings.swift
from deep_translator import GoogleTranslator
langs = ["en", "es", "fr", "it", "pt", "ja", "ko", "pl", "nl", "tr"]

# We start with the German text
de_text = "5 Fragen. 2 Minuten. Keine Selbsttäuschung."
new_translations = {"de": de_text}

for lang in langs:
    print(f"Translating to {lang}...")
    # Force the English text to be exactly what the user wants
    if lang == "en":
        new_translations[lang] = "5 questions. 2 minutes. No self-deception."
    else:
        # Translate from English for better accuracy with this specific idiom
        new_translations[lang] = GoogleTranslator(source='en', target=lang).translate("5 questions. 2 minutes. No self-deception.")

# Now replace it in AppStrings.swift
with open('Localization/AppStrings.swift', 'r', encoding='utf-8') as f:
    content = f.read()

# We need to find the line starting with:        "assessment.category.sub": [
def escape(s):
    return s.replace('\\', '\\\\').replace('"', '\\"').replace('\n', ' ')

dict_str = ", ".join([f'"{lang}": "{escape(text)}"' for lang, text in new_translations.items()])
new_line = f'        "assessment.category.sub": [{dict_str}],'

content = re.sub(r'^\s*"assessment\.category\.sub": \[.*?\],', new_line, content, flags=re.MULTILINE)

with open('Localization/AppStrings.swift', 'w', encoding='utf-8') as f:
    f.write(content)

print("AppStrings.swift updated!")
