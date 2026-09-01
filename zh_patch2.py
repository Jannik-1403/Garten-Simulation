import json

patch_data = {
  "T": "天",
  "W": "周",
  "M": "月",
  "6 M.": "6个月",
  "J": "年",
  "body.tracking.weight.unit.kg": "千克 (kg)",
  "body.tracking.weight.unit.lbs": "磅 (lbs)",
  "body.tracking.measurement.unit.cm": "厘米 (cm)",
  "body.tracking.measurement.unit.inch": "英寸 (inch)",
  "common.points.short": "分",
  "body.measure.info.prefix": "使用柔性卷尺，在寒冷状态下测量且不要泵感，并将卷尺始终绝对水平放置。",
  "Selected": "已选",
  "x": "x",
  "y": "y",
  "Ginkgo": "银杏"
}

with open("Garten_Simulation/Localizable.xcstrings", "r") as f:
    data = json.load(f)

count = 0
for key, zh_text in patch_data.items():
    if key in data["strings"]:
        if "localizations" not in data["strings"][key]:
            data["strings"][key]["localizations"] = {}
        data["strings"][key]["localizations"]["zh-Hans"] = {"stringUnit": {"state": "translated", "value": zh_text}}
        data["strings"][key]["localizations"]["zh-Hant"] = {"stringUnit": {"state": "translated", "value": zh_text}}
        count += 1

with open("Garten_Simulation/Localizable.xcstrings", "w") as f:
    json.dump(data, f, ensure_ascii=False, indent=2)

print(f"Patched {count} keys for Chinese part 2.")
