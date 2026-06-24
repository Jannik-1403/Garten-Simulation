import os

keys_de = {
    "Fokus-Score": "Fokus-Score",
    "stats.score.focus.period_format": "Fokus in %@"
}

keys_en = {
    "Fokus-Score": "Focus Score",
    "stats.score.focus.period_format": "Focus in %@"
}

for root, dirs, files in os.walk('.'):
    for file in files:
        if file == 'Localizable.strings':
            filepath = os.path.join(root, file)
            print(f"Updating {filepath}")
            
            with open(filepath, 'r', encoding='utf-8') as f:
                content = f.read()
            
            keys = keys_en if '/en.lproj/' in filepath else keys_de
            
            append_str = ""
            for k, v in keys.items():
                if f'"{k}"' not in content:
                    append_str += f'\n"{k}" = "{v}";\n'
                    
            if append_str:
                with open(filepath, 'a', encoding='utf-8') as f:
                    f.write(append_str)

print("Done")
