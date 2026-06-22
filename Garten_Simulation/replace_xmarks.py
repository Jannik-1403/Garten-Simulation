import os
import re

directory = "/Users/jannikschill/Documents/Garten-Simulation/Garten_Simulation"

# Regex to match Button { dismiss() } label: { Image(...) ... }
pattern = re.compile(r'Button\s*\{\s*dismiss\(\)\s*\}\s*label:\s*\{\s*Image\(systemName:\s*"xmark"\)[^}]*\}', re.DOTALL)
pattern_2 = re.compile(r'Button\(action:\s*\{\s*dismiss\(\)\s*\}\)\s*\{\s*Image\(systemName:\s*"xmark"\)[^}]*\}', re.DOTALL)

for root, _, files in os.walk(directory):
    for file in files:
        if file.endswith(".swift"):
            path = os.path.join(root, file)
            with open(path, "r") as f:
                content = f.read()
            
            new_content = pattern.sub('LiquidGlassDismissButton { dismiss() }', content)
            new_content = pattern_2.sub('LiquidGlassDismissButton { dismiss() }', new_content)
            
            # Additional common pattern:
            # Button {
            #     dismiss()
            # } label: {
            #     Image(systemName: "xmark") ...
            # }
            pattern_3 = re.compile(r'Button\s*\{\s*dismiss\(\)\s*\}\s*label:\s*\{\s*Image\(systemName:\s*"xmark"\)[^}]*\}', re.DOTALL)
            
            if new_content != content:
                with open(path, "w") as f:
                    f.write(new_content)
                print(f"Updated {file}")
