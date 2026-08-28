import json

file_path = "Garten_Simulation/Localizable.xcstrings"
with open(file_path, "r", encoding="utf-8") as f:
    data = json.load(f)

translations = {
    "routine.todo.title": {"en": "Custom To-Do", "zh-Hans": "自定义待办事项", "zh-Hant": "自定義待辦事項"},
    "routine.todo.name": {"en": "To-Do Name", "zh-Hans": "待办事项名称", "zh-Hant": "待辦事項名稱"},
    "routine.todo.name.placeholder": {"en": "e.g. Take out the trash", "zh-Hans": "例如：倒垃圾", "zh-Hant": "例如：倒垃圾"},
    "routine.todo.icon": {"en": "Plant Icon", "zh-Hans": "植物图标", "zh-Hant": "植物圖標"},
    "routine.todo.description": {"en": "Description (Optional)", "zh-Hans": "描述 (可选)", "zh-Hant": "描述 (可選)"},
    "routine.todo.description.placeholder": {"en": "e.g. only residual waste", "zh-Hans": "例如：仅限不可回收垃圾", "zh-Hant": "例如：僅限不可回收垃圾"},
    "shop.tab.items.short": {"en": "Bad Habits", "zh-Hans": "坏习惯", "zh-Hant": "壞習慣"},
    "shop.tab.plants.short": {"en": "Good Habits", "zh-Hans": "好习惯", "zh-Hant": "好習慣"},
    "shop.seeds.desc": {"en": "Create your own habits. For 10 seeds you can create your own custom habits.", "zh-Hans": "创建你自己的习惯。只需10颗种子，你就可以创建自己的专属习惯。", "zh-Hant": "創建你自己的習慣。只需10顆種子，你就可以創建自己的專屬習慣。"},
    "Erstelle dir eigene Gewohnheiten. Für 10 Samen kannst du dir eigene Gewohnheiten erstellen.": {"en": "Create your own habits. For 10 seeds you can create your own custom habits.", "zh-Hans": "创建你自己的习惯。只需10颗种子，你就可以创建自己的专属习惯。", "zh-Hant": "創建你自己的習慣。只需10顆種子，你就可以創建自己的專屬習慣。"},
    "badhabit.category.sucht": {"en": "Addiction & Vices", "zh-Hans": "成瘾与恶习", "zh-Hant": "成癮與惡習"},
    "badhabit.category.ernaehrung": {"en": "Diet", "zh-Hans": "饮食", "zh-Hant": "飲食"},
    "badhabit.category.digital": {"en": "Digital", "zh-Hans": "数字", "zh-Hant": "數位"},
    "badhabit.category.finanzen": {"en": "Consumption", "zh-Hans": "消费", "zh-Hant": "消費"},
    "badhabit.category.freizeit": {"en": "Leisure", "zh-Hans": "休闲", "zh-Hant": "休閒"},
    "badhabit.category.faulheit": {"en": "Laziness", "zh-Hans": "懒惰", "zh-Hant": "懶惰"},
    "badhabit.category.sonstiges": {"en": "Other", "zh-Hans": "其他", "zh-Hant": "其他"},
    "shop.tab.header": {"en": "Habits", "zh-Hans": "习惯", "zh-Hant": "習慣"}
}

strings = data.setdefault("strings", {})

count = 0
for key, trans_dict in translations.items():
    if key not in strings:
        strings[key] = {"localizations": {}}
    localizations = strings[key].setdefault("localizations", {})
    
    for lang, val in trans_dict.items():
        if lang not in localizations:
            localizations[lang] = {"stringUnit": {"state": "translated", "value": val}}
            count += 1
        else:
            localizations[lang]["stringUnit"]["value"] = val
            localizations[lang]["stringUnit"]["state"] = "translated"
            count += 1

with open(file_path, "w", encoding="utf-8") as f:
    json.dump(data, f, ensure_ascii=False, indent=2)

print(f"Injected {count} translations successfully.")
