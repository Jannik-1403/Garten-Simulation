import re
import json

updates = {
    "assessment.habits.build.title": "Habits to Build",
    "assessment.habits.break.title": "Habits to Break",
    "assessment.health.profile.ignorant.build": "Start moving daily and track your food. Action: Drink 2L water.",
    "assessment.health.profile.ignorant.break": "Stop ignoring body signals. Quit late-night junk food.",
    "stats.score.focus.period_format": "Focus in %@",
    "routine.timer": "Timer"
}

ko_updates = {
    "assessment.habits.build.title": "습관 형성",
    "assessment.habits.break.title": "습관 끊기",
    "assessment.health.profile.ignorant.build": "신체의 신호에 귀를 기울이고 건강한 식단과 운동을 시작하세요.",
    "assessment.health.profile.ignorant.break": "나쁜 식습관과 수면 부족 등 몸을 해치는 행동을 멈추세요.",
    "stats.score.focus.period_format": "%@의 포커스",
    "routine.timer": "타이머"
}

required_langs = ["de", "en", "es", "fr", "it", "pt", "ja", "ko", "pl", "nl", "tr"]

with open("Localization/AppStrings.swift", "r") as f:
    content = f.read()

# Append missing keys at the very end of the static let all dictionary
new_entries = []

# But first check if they exist
for key, eng_text in updates.items():
    if f'"{key}":' not in content:
        # Create full dictionary
        dict_str = f'"en": "{eng_text}"'
        for lang in required_langs:
            if lang == "en": continue
            if lang == "ko" and key in ko_updates:
                val = ko_updates[key]
            else:
                val = eng_text # fallback
            dict_str += f', "{lang}": "{val}"'
        new_entries.append(f'        "{key}": [{dict_str}]')
    else:
        # If it exists, let's just update the Korean part if needed
        if key in ko_updates:
            pattern = r'("' + key + r'":\s*\[.*?"ko":\s*")([^"]+)(")'
            content = re.sub(pattern, r'\g<1>' + ko_updates[key] + r'\g<3>', content)

if new_entries:
    # insert before the last closing bracket of the dictionary
    # The dictionary ends with `    ]`
    # Let's find `    ]` at the end of the file
    content = re.sub(r'(\n    \]\n)', r',\n' + ',\n'.join(new_entries) + r'\1', content)

with open("Localization/AppStrings.swift", "w") as f:
    f.write(content)

print("Updates completed successfully.")
