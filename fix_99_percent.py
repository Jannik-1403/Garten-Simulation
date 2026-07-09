import json

unused_keys = [
    "%lldh %lldm",
    "bad_habit.screen_time.name",
    "habit.screen_time.name",
    "screentime.preprompt.button",
    "screentime.preprompt.desc",
    "screenTime.target.label"
]

translations_zh = {
    "bad_habit.screen_time.desc": ("复发", "復發"),
    "common.hours": ("小时", "小時"),
    "common.hours.short": ("小时", "小時"),
    "common.minutes": ("分钟", "分鐘"),
    "common.minutes.short": ("分钟", "分鐘"),
    "habit.screen_time.desc": ("数字排毒", "數字排毒"),
    "note.auto.screentime_success": ("屏幕时间限制得到遵守", "螢幕時間限制得到遵守"),
    "screentime.preprompt.subtitle": ("允许访问屏幕使用时间，以便 Grovy 可以阻止分心的应用程序。", "允許訪問螢幕使用時間，以便 Grovy 可以阻止分心的應用程式。"),
    "screentime.preprompt.title": ("保护你的专注力", "保護你的專注力"),
    "screenTime.reason.exceeded": ("超出每日限制", "超出每日限制"),
    "settings.screenTime.instruction": ("管理拦截时间和限制。", "管理攔截時間和限制。")
}

with open("Garten_Simulation/Localizable.xcstrings", "r", encoding="utf-8") as f:
    data = json.load(f)

for k in unused_keys:
    if k in data["strings"]:
        del data["strings"][k]
        print(f"Deleted unused key {k}")

for key, (zh_hans, zh_hant) in translations_zh.items():
    if key in data["strings"]:
        locs = data["strings"][key].setdefault("localizations", {})
        
        locs["zh-Hans"] = {
            "stringUnit": {
                "state": "translated",
                "value": zh_hans
            }
        }
        locs["zh-Hant"] = {
            "stringUnit": {
                "state": "translated",
                "value": zh_hant
            }
        }
        print(f"Translated {key} to zh-Hans and zh-Hant")

with open("Garten_Simulation/Localizable.xcstrings", "w", encoding="utf-8") as f:
    json.dump(data, f, ensure_ascii=False, indent=2)

print("Done.")
