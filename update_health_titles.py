import json

path = "Garten_Simulation/Localizable.xcstrings"
with open(path, "r", encoding="utf-8") as f:
    data = json.load(f)

# Update settings.health.title
if "settings.health.title" in data["strings"]:
    data["strings"]["settings.health.title"]["localizations"]["ko"] = {"stringUnit": {"state": "translated", "value": "Apple Health (건강)"}}
    data["strings"]["settings.health.title"]["localizations"]["ja"] = {"stringUnit": {"state": "translated", "value": "Apple Health (ヘルスケア)"}}

# Update paywall.feature.health.title
if "paywall.feature.health.title" in data["strings"]:
    data["strings"]["paywall.feature.health.title"]["localizations"]["ko"] = {"stringUnit": {"state": "translated", "value": "Apple Health (건강 동기화)"}}
    data["strings"]["paywall.feature.health.title"]["localizations"]["ja"] = {"stringUnit": {"state": "translated", "value": "Apple Health (ヘルスケア同期)"}}

with open(path, "w", encoding="utf-8") as f:
    json.dump(data, f, indent=2, ensure_ascii=False)
