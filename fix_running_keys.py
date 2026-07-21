import json

file_path = "Garten_Simulation/Localizable.xcstrings"
with open(file_path, "r") as f:
    data = json.load(f)

fixes = {
    "prog_running_d1_t1": {
        "de": "%@ km locker laufen",
        "en": "%@ km easy run"
    },
    "prog_running_d4_t1": {
        "de": "%@ km im zügigen Tempo",
        "en": "%@ km at a brisk pace"
    },
    "prog_running_d6_t1": {
        "de": "%@ km absolviert",
        "en": "%@ km completed"
    }
}

languages = ['de', 'en', 'es', 'fr', 'hi', 'it', 'ja', 'ko', 'nl', 'pl', 'pt', 'pt-BR', 'ru', 'tr', 'zh-Hans', 'zh-Hant']

if "strings" in data:
    for key, trans in fixes.items():
        if key in data["strings"]:
            for lang in languages:
                if lang not in data["strings"][key].get("localizations", {}):
                    if "localizations" not in data["strings"][key]:
                        data["strings"][key]["localizations"] = {}
                    data["strings"][key]["localizations"][lang] = {"stringUnit": {"state": "translated", "value": ""}}
                
                # set the fixed string
                if lang == "de":
                    data["strings"][key]["localizations"][lang]["stringUnit"]["value"] = trans["de"]
                else:
                    data["strings"][key]["localizations"][lang]["stringUnit"]["value"] = trans["en"]
                    
with open(file_path, "w") as f:
    json.dump(data, f, indent=2, ensure_ascii=False)

print("Running keys fixed.")
