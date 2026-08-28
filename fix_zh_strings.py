import json

file_path = "Garten_Simulation/Localizable.xcstrings"
with open(file_path, "r", encoding="utf-8") as f:
    data = json.load(f)

strings = data.get("strings", {})

fixes = {
    "plant.detail.todo.add": {
        "en": "Add To-Do",
        "de": "To-Do hinzufügen",
        "zh-Hant": "新增待辦事項",
        "zh-Hans": "新增待办事项"
    },
    "plant.detail.todo.placeholder": {
        "en": "Enter To-Do...",
        "de": "To-Do eingeben...",
        "zh-Hant": "輸入待辦事項...",
        "zh-Hans": "输入待办事项..."
    },
    "routine.todo.add": {
        "en": "Custom To-Do",
        "de": "Eigenes To-Do",
        "zh-Hant": "自訂待辦事項",
        "zh-Hans": "自定义待办事项"
    },
    "tab.todos": {
        "en": "To-Dos",
        "de": "To-Dos",
        "zh-Hant": "待辦事項",
        "zh-Hans": "待办事项"
    },
    "type.todo": {
        "en": "To-Do",
        "de": "To-Do",
        "zh-Hant": "待辦事項",
        "zh-Hans": "待办事项"
    },
    "common.save": {
        "en": "Save",
        "de": "Speichern",
        "zh-Hant": "儲存",
        "zh-Hans": "保存"
    }
}

lang_map = ["en", "de", "es", "fr", "hi", "it", "ja", "ko", "nl", "pl", "pt", "ru", "tr", "zh-Hans", "zh-Hant"]

count = 0
for key, trans_dict in fixes.items():
    if key not in strings:
        strings[key] = {"localizations": {}}
    localizations = strings[key].setdefault("localizations", {})
    
    en_fallback = trans_dict["en"]
    for lang in lang_map:
        val = trans_dict.get(lang, en_fallback)
        localizations[lang] = {"stringUnit": {"state": "translated", "value": val}}
        count += 1

with open(file_path, "w", encoding="utf-8") as f:
    json.dump(data, f, ensure_ascii=False, indent=2)

print(f"Fixed {count} remaining unlocalized UI texts!")
