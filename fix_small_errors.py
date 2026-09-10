import json

file_path = "Garten_Simulation/Localizable.xcstrings"
with open(file_path, "r", encoding="utf-8") as f:
    data = json.load(f)

fixes = {
    "time.minutes": {"pt-BR": "Minutos", "nl": "Minuten"},
    "trash.couch_abo.obj_name": {"it": "Casetta per ricci", "ru": "Домик для ежей"},
    "trash.doener_dauerkarte.obj_name": {"it": "Vialetto di ghiaia", "ru": "Гравийная дорожка"},
    "transaction.sale_format": {"it": "Vendita: %@"},
    "streak.days": {"it": "%d Giorni"}
}

for key, locs in fixes.items():
    if key in data["strings"]:
        for lang, val in locs.items():
            if lang in data["strings"][key]["localizations"]:
                data["strings"][key]["localizations"][lang]["stringUnit"]["value"] = val

with open(file_path, "w", encoding="utf-8") as f:
    json.dump(data, f, indent=2, ensure_ascii=False)
    f.write("\n")
