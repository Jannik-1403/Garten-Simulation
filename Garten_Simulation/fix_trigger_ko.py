import re

updates = {
    "trigger.save_button": "재발 저장",
    "trigger.own_trigger_desc": "이 재발의 사용자 지정 이유를 입력하세요.",
    "trigger.trigger_name": "트리거 이름"
}

with open("Localization/AppStrings.swift", "r") as f:
    content = f.read()

for key, val in updates.items():
    pattern = r'("' + key + r'":\s*\[.*?"ko":\s*")([^"]+)(")'
    content = re.sub(pattern, r'\g<1>' + val + r'\g<3>', content)

with open("Localization/AppStrings.swift", "w") as f:
    f.write(content)

print("Trigger updates done.")
