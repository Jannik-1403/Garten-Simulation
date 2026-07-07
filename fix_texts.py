import os
import re

directory = 'Garten_Simulation'

# Regex to find Text("...")
# We must be careful about nested parens, but swift string interpolation is usually simple.
pattern = re.compile(r'Text\(\s*"([^"]*\\\([^"]*)"\s*\)')

def should_be_verbatim(string_content):
    # Remove all string interpolations \(...) from the string content
    # to see what is left outside.
    # Note: this simple regex assumes no nested parens inside the interpolation.
    outside_text = re.sub(r'\\\([^\)]+\)', '', string_content)
    # Check if there are any letters left
    if re.search(r'[a-zA-Z]', outside_text):
        return False
    return True

count = 0
for root, _, files in os.walk(directory):
    for file in files:
        if file.endswith('.swift'):
            filepath = os.path.join(root, file)
            with open(filepath, 'r', encoding='utf-8') as f:
                content = f.read()
            
            def replacer(match):
                inner_string = match.group(1)
                if should_be_verbatim(inner_string):
                    return f'Text(verbatim: "{inner_string}")'
                return match.group(0)
            
            new_content = pattern.sub(replacer, content)
            
            if new_content != content:
                with open(filepath, 'w', encoding='utf-8') as f:
                    f.write(new_content)
                count += 1
                print(f"Updated {filepath}")

print(f"Total files updated: {count}")
