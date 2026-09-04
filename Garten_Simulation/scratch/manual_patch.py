import json

file_path = "/Users/jannikschill/Documents/Garten-Simulation/Garten_Simulation/Localizable.xcstrings"
with open(file_path, "r") as f:
    d = json.load(f)

# The keys we want to instantly fix
patches = {
    "leben.titel": {
        "it": "Le tue vite",
        "es": "Tus vidas"
    },
    "leben.verbleibend": {
        "it": "vite rimanenti",
        "es": "vidas restantes"
    },
    "leben.regel1": {
        "it": "Innaffia le piante ogni giorno per mantenere le vite",
        "es": "Riega tus plantas cada día para mantener tus vidas"
    },
    "leben.regel2": {
        "it": "Se una pianta muore, perdi una vita",
        "es": "Si una planta muere, pierdes una vida"
    },
    "leben.regel3": {
        "it": "A 0 vite, tutte le piante vengono eliminate",
        "es": "Con 0 vidas, se eliminan todas las plantas"
    },
    "streak.label": {
        "it": "Serie",
        "es": "Racha"
    },
    "streak.mode.week": {
        "it": "Settimana",
        "es": "Semana"
    },
    "streak.mode.month": {
        "it": "Mese",
        "es": "Mes"
    },
    "streak.mode.year": {
        "it": "Anno",
        "es": "Año"
    },
    "streak.view.weekly_overview": {
        "it": "Panoramica settimanale",
        "es": "Resumen semanal"
    },
    "streak.freeze.title": {
        "it": "Serie congelata",
        "es": "Racha congelada"
    },
    "streak.freeze.unit": {
        "it": "unità",
        "es": "unidades"
    },
    "profile.streak": {
        "it": "Serie",
        "es": "Racha"
    },
    "stats.streak": {
        "it": "Serie",
        "es": "Racha"
    },
    "category.streak": {
        "it": "Serie",
        "es": "Racha"
    }
}

for key, langs in patches.items():
    if key not in d["strings"]:
        d["strings"][key] = {"extractionState": "manual", "localizations": {}}
    if "localizations" not in d["strings"][key]:
        d["strings"][key]["localizations"] = {}
        
    for lang, value in langs.items():
        d["strings"][key]["localizations"][lang] = {
            "stringUnit": {
                "state": "translated",
                "value": value
            }
        }

with open(file_path, "w") as f:
    json.dump(d, f, indent=2, ensure_ascii=False)
print("Manual patch applied successfully.")
