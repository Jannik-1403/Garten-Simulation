import re
import os

filepath = 'GartenWidget/GroovyWidgetIntent.swift'

locale_var = """
private var widgetLocale: Locale {
    Locale(identifier: SharedUserDefaults.suite.string(forKey: "appLanguage") ?? "de")
}
"""

with open(filepath, 'r', encoding='utf-8') as f:
    content = f.read()

if 'var widgetLocale: Locale' not in content:
    imports_end = content.rfind('import ')
    next_newline = content.find('\n', imports_end)
    content = content[:next_newline+1] + "\n" + locale_var + "\n" + content[next_newline+1:]

content = content.replace(
    'String(localized: String.LocalizationValue(titleKey))', 
    'String(localized: String.LocalizationValue(titleKey), locale: widgetLocale)'
)

with open(filepath, 'w', encoding='utf-8') as f:
    f.write(content)

print(f"Patched {filepath}")
