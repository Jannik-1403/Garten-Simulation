import re

updates = {
    "shop.seeds.name": "마법의 씨앗",
    "shop.seeds.desc": "나만의 독특한 식물을 만들 수 있는 10개의 마법 씨앗 패킷입니다!"
}

with open("Localization/AppStrings.swift", "r") as f:
    content = f.read()

for key, val in updates.items():
    pattern = r'("' + key + r'":\s*\[.*?"ko":\s*")([^"]+)(")'
    content = re.sub(pattern, r'\g<1>' + val + r'\g<3>', content)

with open("Localization/AppStrings.swift", "w") as f:
    f.write(content)

print("Seed updates done.")
