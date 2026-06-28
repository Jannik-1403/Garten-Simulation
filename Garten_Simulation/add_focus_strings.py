import re
from deep_translator import GoogleTranslator

with open("Localization/AppStrings.swift", "r") as f:
    content = f.read()

more_de = "Du hast heute %@ Minuten mehr fokussiert als gestern. Weiter so!"
less_de = "Du hast heute %@ Minuten früher Schluss gemacht als gestern. Bleib dran!"

langs = ["en", "es", "fr", "it", "pt", "ja", "ko", "pl", "nl", "tr"]

more_dict = {'de': more_de, 'en': "You focused %@ minutes more today than yesterday. Keep it up!"}
less_dict = {'de': less_de, 'en': "You stopped %@ minutes earlier today than yesterday. Hang in there!"}

print("Translating...")
for lang in langs:
    if lang != 'en':
        more_dict[lang] = GoogleTranslator(source='en', target=lang).translate(more_dict['en'])
        less_dict[lang] = GoogleTranslator(source='en', target=lang).translate(less_dict['en'])

def escape(s):
    return s.replace('"', '\\"')

def make_str(d):
    parts = []
    for k, v in d.items():
        parts.append('"' + k + '": "' + escape(v) + '"')
    return ", ".join(parts)

more_line = '        "stats.focus.more": [' + make_str(more_dict) + '],'
less_line = '        "stats.focus.less": [' + make_str(less_dict) + '],'

match = re.search(r'("stats\.score\.msg\.low": \[.*?\],)', content)
if match:
    new_content = content[:match.end()] + "\n" + more_line + "\n" + less_line + content[match.end():]
    with open("Localization/AppStrings.swift", "w") as f:
        f.write(new_content)
    print("Added focus strings successfully!")
else:
    print("Could not find insertion point!")

