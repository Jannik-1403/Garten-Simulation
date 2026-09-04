import json

fixes = {
    "nutrient.calcium": {"nl": "Calcium", "pl": "Wapń"},
    "nutrient.category.fiber": {"pl": "Błonnik"},
    "nutrient.category.minerals": {"pl": "Minerały"},
    "nutrient.fiber": {"pl": "Błonnik"},
    "nutrient.vitamin_b1": {"zh-Hant": "維生素B1 (硫胺素)"},
    "nutrient.vitamin_b7": {"tr": "B7 Vitamini (Biyotin)"},
    "nutrient.vitamin_b12": {"nl": "Vitamine B12", "pl": "Witamina B12", "pt": "Vitamina B12", "tr": "B12 Vitamini", "zh-Hant": "維生素B12"},
    "nutrient.vitamin_c": {"pt": "Vitamina C", "tr": "C Vitamini", "zh-Hant": "維生素C"},
    "nutrient.vitamin_d": {"nl": "Vitamine D", "pl": "Witamina D", "pt": "Vitamina D", "tr": "D Vitamini", "zh-Hant": "維生素D"},
    "nutrient.vitamin_e": {"nl": "Vitamine E", "pl": "Witamina E", "tr": "E Vitamini", "zh-Hant": "維生素E"},
    "nutrient.vitamin_k": {"nl": "Vitamine K", "pl": "Witamina K", "pt": "Vitamina K"},
    "prog_nutrition_d4_t2": {"ja": "1食分は%@生で食べられます", "ru": "Одна порция съедается на %@ в сыром виде"},
    "prog_water_d2_desc": {"ja": "午後2時までに必要な水分の少なくとも%@を摂取するようにしてください。これにより、夕方の飲酒や夜間のトイレに行くことがなくなります。"},
    "prog_water_d2_t1": {"ja": "午後2時までに%@飲酒", "tr": "Saat 14:00'ten önce %@ içildi"},
    "pfad.ice.desc": {
        "ru": "Лед для серии защищает вашу серию. Вы не потеряете ее, если пропустите день полива.\n\nВы получаете 1 новый лед за каждую завершенную неделю (7-дневное кольцо). Одновременно может быть активно не более 3 льдов.",
        "zh-Hans": "连击冰可以保护您的连击。如果您某天没有浇水，您不会失去连击。\n\n每完成一周（7天连击圈），您将获得1个新冰。最多可以同时激活3个冰。"
    },
    "pfad.ice.title": {"hi": "स्ट्रीक आइस", "ru": "Лед для серии", "zh-Hans": "连击冰"},
    "settings.manage_subscription": {"nl": "Abonnement beheren", "ru": "Управление подпиской"},
    "widget_intent_history_title": {"ru": "Настроить виджет истории"},
    "widget_intent_routine_desc": {"ru": "Выберите рутину и фон."},
    "widget_intent_routine_title": {"ru": "Настроить виджет рутины"},
    "widget_intent_streak_title": {"ru": "Настроить виджет серии"},
    "widget_intent_water_desc": {"ru": "Выберите фон."},
    "widget_intent_water_title": {"ru": "Настроить виджет воды"},
    "widget_period_alltime": {"ru": "За все время"},
    "widget_period_month": {"ru": "Этот месяц"},
    "widget_period_today": {"ru": "Сегодня"},
    "widget_period_type": {"ru": "Период"},
    "widget_period_week": {"ru": "Эта неделя"},
    "widget_routine_type": {"ru": "Рутина"},
    "widget_style_dark": {"ru": "Темный (черный)"},
    "widget_style_light": {"ru": "Светлый (белый)"},
    "widget_style_type": {"ru": "Стиль фона"},
    "focus.generic.title": {"ru": "Начать фокус"}
}

with open("Garten_Simulation/Localizable.xcstrings", "r") as f:
    data = json.load(f)
    
strings = data.get("strings", {})

count = 0
for key, lang_dict in fixes.items():
    if key in strings:
        for lang, val in lang_dict.items():
            if "localizations" not in strings[key]:
                strings[key]["localizations"] = {}
            if lang not in strings[key]["localizations"]:
                strings[key]["localizations"][lang] = {"stringUnit": {}}
            strings[key]["localizations"][lang]["stringUnit"]["state"] = "translated"
            strings[key]["localizations"][lang]["stringUnit"]["value"] = val
            count += 1

with open("Garten_Simulation/Localizable.xcstrings", "w") as f:
    json.dump(data, f, indent=2, ensure_ascii=False)

print(f"Fixed {count} broken translations!")
