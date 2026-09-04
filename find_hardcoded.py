import os
import re

def is_catalog_key_or_ignore(text):
    if not text:
        return True
    
    # Ignore very short strings
    if len(text.strip()) <= 1:
        return True
        
    # Ignore strings that look like SF symbols or IDs (no spaces, contains dots or dashes, lowercase)
    if " " not in text:
        # e.g. "assessment.entry.title", "star.fill", "btn_save"
        if "." in text or "_" in text or "-" in text:
            return True
        # purely camelCase (starts with lowercase, no spaces)
        if text[0].islower() and text.isalpha():
            return True
            
    # SF symbol check just in case
    if " " not in text and "." in text and text.islower():
        return True
        
    # Ignore format specifiers if they are the only thing
    if re.match(r'^%[0-9]*\.?[0-9]*[a-zA-Z]$', text):
        return True

    return False

def suggest_key(text):
    # Convert "Du hast \(count) Tage" to "du.hast.tage" or similar
    clean = re.sub(r'\\\(.*?\)', '', text)
    clean = re.sub(r'[^a-zA-Z0-9\s]', '', clean)
    words = clean.lower().split()
    if not words:
        return "new.key"
    return ".".join(words[:4])

def search_files(directory):
    patterns = [
        r'Text\(\s*"([^"]+)"\s*\)',
        r'Button\(\s*(?:role:\s*[^,]+,\s*)?(?:action:\s*\{[^}]*\}\s*,\s*label:\s*\{\s*)?"([^"]+)"',
        r'Label\(\s*"([^"]+)"',
        r'\.navigationTitle\(\s*"([^"]+)"\s*\)',
        r'\.alert\(\s*"([^"]+)"',
        r'\.confirmationDialog\(\s*"([^"]+)"',
        r'TextField\(\s*"([^"]+)"',
        r'SecureField\(\s*"([^"]+)"',
        r'Picker\(\s*"([^"]+)"',
        r'Toggle\(\s*"([^"]+)"',
        r'\.tabItem\s*\{\s*Text\(\s*"([^"]+)"\s*\)\s*\}',
    ]
    
    compiled_patterns = [re.compile(p) for p in patterns]
    
    results = []
    
    for root, dirs, files in os.walk(directory):
        # Ignore build directories and derived data
        dirs[:] = [d for d in dirs if d not in ('.git', 'DerivedDataTest', 'DerivedDataTest2', 'build', 'venv', 'test_clone')]
        for file in files:
            if not file.endswith('.swift'):
                continue
            
            filepath = os.path.join(root, file)
            with open(filepath, 'r', encoding='utf-8') as f:
                try:
                    lines = f.readlines()
                except UnicodeDecodeError:
                    continue
                
                for line_idx, line in enumerate(lines):
                    # ignore commented lines
                    if line.strip().startswith('//'):
                        continue
                        
                    for pattern in compiled_patterns:
                        for match in pattern.finditer(line):
                            text = match.group(1)
                            # check if it's not a localized usage like String(localized: "...")
                            # (The regexes above don't match String(localized:) because they look for Text("...") directly)
                            
                            if not is_catalog_key_or_ignore(text):
                                rel_path = os.path.relpath(filepath, directory)
                                results.append({
                                    'file': rel_path,
                                    'line': line_idx + 1,
                                    'code': line.strip(),
                                    'text': text,
                                    'key': suggest_key(text)
                                })
    return results

def main():
    import sys
    directory = '.'
    if len(sys.argv) > 1:
        directory = sys.argv[1]
        
    results = search_files(directory)
    
    # Sort by file
    results.sort(key=lambda x: (x['file'], x['line']))
    
    if not results:
        print("Keine hardcodierten Texte gefunden!")
        return

    print("| Datei | Zeile | Gefundener Code | Vorschlag für Catalog-Key |")
    print("|---|---|---|---|")
    
    summary = {}
    
    for r in results:
        code_preview = r['code']
        if len(code_preview) > 80:
            code_preview = code_preview[:77] + "..."
        # Escape pipes for markdown
        code_preview = code_preview.replace('|', '\\|')
        
        print(f"| {r['file']} | {r['line']} | `{code_preview}` | `{r['key']}` |")
        
        summary[r['file']] = summary.get(r['file'], 0) + 1
        
    print("\n## Zusammenfassung")
    for f, count in sorted(summary.items(), key=lambda x: x[1], reverse=True):
        print(f"- {f}: {count} Funde")
        
if __name__ == '__main__':
    main()
