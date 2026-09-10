# -*- coding: utf-8 -*-
import json
import csv

path = "/Users/jannikschill/Documents/Garten-Simulation/Garten_Simulation/Localizable.xcstrings"
with open(path, "r", encoding="utf-8") as f:
    data = json.load(f)

with open("translations.csv", "r", encoding="utf-8") as f:
    reader = csv.DictReader(f)
    for row in reader:
        key = row["key"]
        if key not in data["strings"]:
            data["strings"][key] = {"extractionState": "manual", "localizations": {}}
        
        data["strings"][key]["extractionState"] = "manual"
        
        for lang, text in row.items():
            if lang == "key" or lang == "de": 
                continue
            
            if "localizations" not in data["strings"][key]:
                data["strings"][key]["localizations"] = {}
            
            data["strings"][key]["localizations"][lang] = {
                "stringUnit": {
                    "state": "translated",
                    "value": text
                }
            }

with open(path, "w", encoding="utf-8") as f:
    json.dump(data, f, indent=2, ensure_ascii=False)

print("Updated 10 new keys.")
