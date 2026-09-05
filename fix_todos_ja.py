import json

file_path = 'Garten_Simulation/Localizable.xcstrings'
with open(file_path, 'r', encoding='utf-8') as f:
    data = json.load(f)

if "tab.todos" in data["strings"]:
    if "ja" in data["strings"]["tab.todos"].get("localizations", {}):
        data["strings"]["tab.todos"]["localizations"]["ja"]["stringUnit"]["value"] = "タスク"

# Check if there are other keys like ToDos
for k, v in data["strings"].items():
    if "todo" in k.lower() or "todo" in v.get("localizations", {}).get("en", {}).get("stringUnit", {}).get("value", "").lower():
        if "ja" in v.get("localizations", {}):
            val = v["localizations"]["ja"]["stringUnit"]["value"]
            if "ToDo" in val or "To-Do" in val:
                new_val = val.replace("ToDo", "タスク").replace("To-Do", "タスク")
                data["strings"][k]["localizations"]["ja"]["stringUnit"]["value"] = new_val

with open(file_path, 'w', encoding='utf-8') as f:
    json.dump(data, f, indent=2, ensure_ascii=False)
