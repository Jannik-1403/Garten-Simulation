import json
import re

with open('TranslatedAssessment.json', 'r', encoding='utf-8') as f:
    translated_data = json.load(f)

with open('Localization/AppStrings.swift', 'r', encoding='utf-8') as f:
    content = f.read()

# 1. Remove all existing lines containing "assessment."
lines = content.split('\n')
filtered_lines = []
for line in lines:
    if '"assessment.' in line:
        continue
    if '// MARK: - Lifestyle Assessment Strings' in line:
        continue
    filtered_lines.append(line)

content = '\n'.join(filtered_lines)

# 2. Format the new assessment strings
new_entries = []
new_entries.append("        // MARK: - Assessment Strings")
for key, langs in translated_data.items():
    # Make sure we escape quotes properly in the translations
    def escape(s):
        if not isinstance(s, str): return ""
        return s.replace('\\', '\\\\').replace('"', '\\"').replace('\n', ' ')
    
    dict_str = ", ".join([f'"{lang}": "{escape(text)}"' for lang, text in langs.items() if text])
    new_entries.append(f'        "{key}": [{dict_str}],')

# 3. Find the end of the `all` dictionary
# The dictionary is inside `static let all: [String: [String: String]] = [`
# The end of the dictionary is marked by `    ]` followed by `}`.
# Since we removed the assessment strings, we should just find the last `    ]` that closes the dictionary.

match = re.search(r'(\s+)\]\n\}', content)
if match:
    indent = match.group(1)
    
    # We need to remove the trailing comma from the last entry if we're adding to it,
    # or just add our entries with a comma to the previous ones.
    # Actually, let's just insert our new entries right before `    ]\n}`.
    # Since our last entry has a comma, we should ideally remove the comma from the very last entry
    # but Swift allows trailing commas in dictionaries! Oh wait, does it? NO, Swift does NOT allow trailing commas in dictionaries? 
    # Wait, Swift DOES allow trailing commas in arrays and dictionaries. Let's be safe and remove the last comma of our generated list.

    new_entries[-1] = new_entries[-1].rstrip(',')
    
    insert_str = '\n'.join(new_entries) + '\n' + indent + ']\n}'
    content = content.replace(indent + ']\n}', insert_str)
else:
    print("Could not find the end of the dictionary.")
    exit(1)

with open('Localization/AppStrings.swift', 'w', encoding='utf-8') as f:
    f.write(content)

print("Updated AppStrings.swift successfully!")
