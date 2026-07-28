import re
import os

files = [
    'GartenWidget/GroovyNewWidgetViews.swift',
    'GartenWidget/GartenWidget.swift'
]

locale_var = """
private var widgetLocale: Locale {
    Locale(identifier: SharedUserDefaults.suite.string(forKey: "appLanguage") ?? "de")
}
"""

def patch_file(filepath):
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()
        
    # Check if widgetLocale is already there
    if 'var widgetLocale: Locale' not in content:
        # insert it after imports
        imports_end = content.rfind('import ')
        next_newline = content.find('\n', imports_end)
        content = content[:next_newline+1] + "\n" + locale_var + "\n" + content[next_newline+1:]
        
    # Replace String(localized: "...", defaultValue: "...") 
    # taking care not to replace if locale is already there
    # Regex handles optional newlines/spaces
    pattern = r'String\s*\(\s*localized\s*:\s*("[^"]+")\s*,\s*defaultValue\s*:\s*("[^"]+")\s*\)'
    replacement = r'String(localized: \1, defaultValue: \2, locale: widgetLocale)'
    
    content = re.sub(pattern, replacement, content)
    
    with open(filepath, 'w', encoding='utf-8') as f:
        f.write(content)

for filepath in files:
    if os.path.exists(filepath):
        patch_file(filepath)
        print(f"Patched {filepath}")

