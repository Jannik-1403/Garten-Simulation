import json
import re

file_path = "Garten_Simulation/Localizable.xcstrings"
with open(file_path, "r", encoding="utf-8") as f:
    data = json.load(f)

# English dictionary (all 38 terms)
dict_en = {
    "Alkohol trinken": "Drinking alcohol", "Tee trinken": "Drinking tea",
    "Binge Streaming": "Binge streaming", "Hobby nachgehen": "Pursuing a hobby",
    "Auf der Couch liegen": "Lying on the couch", "Stretching": "Stretching",
    "Zu viel Fast Food": "Too much fast food", "Gesunder Snack": "Healthy snack",
    "Doomscrolling": "Doomscrolling", "Meditieren": "Meditating",
    "Zuviel Fernsehen": "Too much TV", "Ein Buch lesen": "Reading a book",
    "Energy Drinks": "Energy drinks", "Wasser trinken": "Drinking water",
    "Fast Food": "Fast food", "Gesund kochen": "Healthy cooking",
    "Lieferdienst bestellen": "Ordering takeout", "Meal Prep": "Meal prep",
    "Spam & Ablenkung": "Spam & Distractions", "Digital Detox": "Digital detox",
    "Glücksspiel/Lootboxen": "Gambling/Lootboxes", "Sparen": "Saving",
    "Sinnlose Autofahrten": "Pointless drives", "Spazieren gehen": "Going for a walk",
    "Statussymbole kaufen": "Buying status symbols", "Dankbarkeit üben": "Practicing gratitude",
    "Nächtliches Snacken": "Late-night snacking", "Intervallfasten": "Intermittent fasting",
    "Negativer News Feed": "Negative news feed", "Positives Journaling": "Positive journaling",
    "Online Shopping": "Online shopping", "Geld sparen": "Saving money",
    "Zu viel Party": "Partying too much", "Me-Time & Selfcare": "Me-time & self-care",
    "Zu viel Koffein": "Too much caffeine", "Schlafroutine": "Sleep routine",
    "Rauchen": "Smoking", "Atemübungen": "Breathing exercises"
}

# The others have only a few broken ones. Let's just define a generic dictionary for the missing ones based on what was found.
dict_other = {
    "es": {"Doomscrolling": "Doomscrolling", "Meditieren": "Meditar", "Fast Food": "Comida rápida", "Gesund kochen": "Cocinar sano", "Binge Streaming": "Binge Streaming", "Hobby nachgehen": "Practicar un hobby"},
    "it": {"Doomscrolling": "Doomscrolling", "Meditieren": "Meditare", "Fast Food": "Fast Food", "Gesund kochen": "Cucinare sano"},
    "fr": {"Doomscrolling": "Doomscrolling", "Meditieren": "Méditer", "Fast Food": "Fast-food", "Gesund kochen": "Cuisiner sainement"},
    "tr": {"Doomscrolling": "Doomscrolling", "Meditieren": "Meditasyon yapmak", "Fast Food": "Fast Food", "Gesund kochen": "Sağlıklı yemek yapmak", "Binge Streaming": "Dizi Maratonu"},
    "nl": {"Doomscrolling": "Doomscrollen", "Meditieren": "Mediteren", "Fast Food": "Fastfood", "Gesund kochen": "Gezond koken"},
    "pt": {"Doomscrolling": "Doomscrolling", "Meditieren": "Meditar", "Fast Food": "Fast food", "Gesund kochen": "Cozinhar de forma saudável"},
    "pt-BR": {"Doomscrolling": "Doomscrolling", "Meditieren": "Meditar", "Fast Food": "Fast food", "Gesund kochen": "Cozinhar de forma saudável"},
    "pl": {"Doomscrolling": "Doomscrolling", "Meditieren": "Medytować", "Fast Food": "Fast food", "Gesund kochen": "Gotować zdrowo"},
    "ru": {"Doomscrolling": "Думскроллинг", "Meditieren": "Медитировать", "Fast Food": "Фастфуд", "Gesund kochen": "Готовить полезную еду"},
    "hi": {"Doomscrolling": "डूमस्क्रॉलिंग", "Meditieren": "ध्यान करना", "Fast Food": "फास्ट फूड", "Gesund kochen": "स्वस्थ खाना बनाना"},
    "ko": {"Doomscrolling": "둠스크롤링", "Meditieren": "명상하기", "Fast Food": "패스트푸드", "Gesund kochen": "건강하게 요리하기"},
    "ja": {"Doomscrolling": "ドゥームスクローリング", "Meditieren": "瞑想する", "Fast Food": "ファーストフード", "Gesund kochen": "健康的な料理"},
    "zh-Hans": {"Doomscrolling": "末日刷屏", "Meditieren": "冥想", "Fast Food": "快餐", "Gesund kochen": "健康烹饪"},
    "zh-Hant": {"Doomscrolling": "末日刷屏", "Meditieren": "冥想", "Fast Food": "快餐", "Gesund kochen": "健康烹飪"}
}

habits_de = list(dict_en.keys())

count = 0
for key, value in data["strings"].items():
    if not (key.startswith("trash.") and (key.endswith(".tips") or key.endswith(".impact"))):
        continue
        
    localizations = value.get("localizations", {})
    for lang, loc in localizations.items():
        if lang == "de":
            continue
        
        val = loc.get("stringUnit", {}).get("value", "")
        original_val = val
        
        if lang == "en":
            for h in habits_de:
                val = val.replace(f"({h})", f"({dict_en[h]})")
        else:
            for h in habits_de:
                if f"({h})" in val:
                    replacement = dict_other.get(lang, {}).get(h, h) # fallback to h if not found
                    val = val.replace(f"({h})", f"({replacement})")
        
        if val != original_val:
            data["strings"][key]["localizations"][lang]["stringUnit"]["value"] = val
            count += 1

with open(file_path, "w", encoding="utf-8") as f:
    json.dump(data, f, indent=2, ensure_ascii=False)

print(f"Fixed {count} broken translations!")
