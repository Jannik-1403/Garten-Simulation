import re

updates = {
    "trigger.loneliness": "외로움",
    "trigger.boredom": "지루함",
    "trigger.reward": "보상으로",
    "trigger.title": "가장 흔한 트리거",
    "trigger.selection_title": "트리거",
    "trigger.own_trigger": "맞춤형 트리거",
    "routine.pending": "대기 중",
    "routine.start": "시작",
    "trigger.stress": "스트레스",
    "trigger.sadness": "슬픔",
    "trigger.social_pressure": "사회적 압력",
    "trigger.fatigue": "피로",
    "trigger.cancel": "취소",
    "trigger.add": "추가"
}

with open("Localization/AppStrings.swift", "r") as f:
    content = f.read()

for k, v in updates.items():
    # replace "ko": "fallback" with "ko": "v"
    # we need to find the array for k
    pattern = r'("' + k + r'":\s*\[.*?"ko":\s*")([^"]+)(")'
    content = re.sub(pattern, r'\g<1>' + v + r'\g<3>', content)

with open("Localization/AppStrings.swift", "w") as f:
    f.write(content)
print("Updated Korean strings.")
