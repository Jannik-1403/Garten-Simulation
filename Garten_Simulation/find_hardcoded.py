import os
import re

def main():
    root_dir = '/Users/jannikschill/Documents/Garten-Simulation/Garten_Simulation'
    
    # Common UI elements that take a StringProtocol as first argument
    patterns = [
        re.compile(r'Text\(\s*"([^"]+)"\s*\)'),
        re.compile(r'Label\(\s*"([^"]+)"\s*,'),
        re.compile(r'Button\(\s*"([^"]+)"\s*,'),
        re.compile(r'Button\(\s*(?:action:\s*\{[^}]*\}\s*,\s*)?label:\s*\{\s*Text\(\s*"([^"]+)"\s*\)'),
        re.compile(r'\.navigationTitle\(\s*"([^"]+)"\s*\)'),
        re.compile(r'Picker\(\s*"([^"]+)"\s*,')
    ]
    
    ignore_files = ['Localizable.xcstrings', 'find_hardcoded.py', 'analyze_strings.py']
    
    for dirpath, dirnames, filenames in os.walk(root_dir):
        for filename in filenames:
            if not filename.endswith('.swift'):
                continue
            if filename in ignore_files:
                continue
                
            filepath = os.path.join(dirpath, filename)
            with open(filepath, 'r', encoding='utf-8') as f:
                content = f.read()
                
            for i, pattern in enumerate(patterns):
                matches = pattern.finditer(content)
                for match in matches:
                    matched_str = match.group(1)
                    # Ignore empty, single symbols, purely numeric strings or SF symbols
                    if not matched_str or len(matched_str.strip()) < 2:
                        continue
                    if re.match(r'^[\W\d_]+$', matched_str):
                        continue
                    if 'sf-symbol' in matched_str.lower() or matched_str.isascii() and not any(c.islower() for c in matched_str): # basic heuristic
                         # let's be careful and print all matches to see
                        print(f"{os.path.relpath(filepath, root_dir)}: {matched_str}")

if __name__ == '__main__':
    main()
