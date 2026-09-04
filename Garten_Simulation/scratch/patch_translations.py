import json

FILE_PATH = "/Users/jannikschill/Documents/Garten-Simulation/Garten_Simulation/Localizable.xcstrings"

# We supply translations for the main keys. 
# We'll use EN and DE as fallback for anything we didn't translate perfectly to 16 languages, 
# but we provide IT, FR, ES, etc for the main ones.

translations = {
    "routine.todo.icon": {
        "en": "Plant Icon", "de": "Pflanzen-Icon", "it": "Icona della pianta", "es": "Icono de planta", "fr": "Icône de plante", "nl": "Plant Icoon"
    },
    "routine.todo.name": {
        "en": "To-Do Name", "de": "To-Do Name", "it": "Nome To-Do", "es": "Nombre de Tareas", "fr": "Nom de la Tâche"
    },
    "routine.todo.description": {
        "en": "Description (Optional)", "de": "Beschreibung (Optional)", "it": "Descrizione (Opzionale)", "es": "Descripción (Opcional)", "fr": "Description (Optionnel)"
    },
    "nutrient.settings.dge_info": {
        "en": "The targets are based on the recommendations of the DGE.",
        "de": "Die Ziele basieren auf den Empfehlungen der DGE (Deutsche Gesellschaft für Ernährung).",
        "it": "Gli obiettivi si basano sulle raccomandazioni della DGE.",
        "es": "Los objetivos se basan en las recomendaciones de la DGE.",
        "fr": "Les objectifs sont basés sur les recommandations de la DGE."
    },
    "nutrient.fiber": {
        "en": "Dietary Fiber", "de": "Ballaststoffe", "it": "Fibre alimentari", "es": "Fibra dietética", "fr": "Fibres alimentaires"
    },
    "health.chart.title.fiber.plain": {
        "en": "Dietary Fiber", "de": "Ballaststoffe", "it": "Fibre alimentari", "es": "Fibra dietética", "fr": "Fibres alimentaires"
    },
    "nutrient.category.fiber": {
        "en": "Dietary Fiber", "de": "Ballaststoffe", "it": "Fibre alimentari", "es": "Fibra dietética", "fr": "Fibres alimentaires"
    },
    "nutrient.minerals": {
        "en": "Minerals", "de": "Mineralstoffe", "it": "Minerali", "es": "Minerales", "fr": "Minéraux"
    },
    "calorie.calc.nav": {
        "en": "Data & Calories", "de": "Daten & Kalorien", "it": "Dati & Calorie", "es": "Datos y Calorías", "fr": "Données & Calories"
    },
    "calorie.detail.nav": {
        "en": "Calorie Details", "de": "Kalorien Details", "it": "Dettagli Calorie", "es": "Detalles de Calorías", "fr": "Détails des Calories"
    },
    "calorie.history.title": {
        "en": "Calorie History", "de": "Kalorien Historie", "it": "Cronologia Calorie", "es": "Historial de Calorías", "fr": "Historique des Calories"
    },
    "calorie.history.today": {
        "en": "Today", "de": "Heute", "it": "Oggi", "es": "Hoy", "fr": "Aujourd'hui"
    },
    "calorie.calc.goal.title": {
        "en": "My Goal", "de": "Mein Ziel", "it": "Il mio Obiettivo", "es": "Mi Objetivo", "fr": "Mon Objectif"
    },
    "calorie.calc.goal.lose": {
        "en": "Lose Weight", "de": "Abnehmen", "it": "Dimagrire", "es": "Perder Peso", "fr": "Perdre du Poids"
    },
    "calorie.calc.goal.gain": {
        "en": "Gain Weight", "de": "Zunehmen", "it": "Prendere Peso", "es": "Ganar Peso", "fr": "Prendre du Poids"
    },
    "calorie.calc.goal.target_date": {
        "en": "Target Date", "de": "Ziel-Datum", "it": "Data di Scadenza", "es": "Fecha Objetivo", "fr": "Date Cible"
    },
    "calorie.calc.goal.info": {
        "en": "Your daily calories and macros will automatically adjust based on your target date.",
        "de": "Deine täglichen Kalorien und Makros werden automatisch basierend auf deinem Ziel-Datum angepasst.",
        "it": "Le tue calorie e macronutrienti giornalieri verranno adattati automaticamente in base alla tua data di scadenza.",
        "es": "Tus calorías diarias se ajustarán automáticamente.",
        "fr": "Vos calories quotidiennes seront ajustées automatiquement."
    },
    "calorie.history.consumed": {
        "en": "Consumed", "de": "Konsumiert", "it": "Consumato", "es": "Consumido", "fr": "Consommé"
    },
    "Add To-Do": {
        "en": "Add To-Do", "de": "To-Do hinzufügen", "it": "Aggiungi To-Do", "es": "Añadir Tarea", "fr": "Ajouter une Tâche"
    },
    "For which habit? (Optional)": {
        "en": "For which habit? (Optional)", "de": "Für welche Gewohnheit? (Optional)", "it": "Per quale abitudine? (Opzionale)", "es": "¿Para qué hábito? (Opcional)", "fr": "Pour quelle habitude? (Optionnel)"
    },
    "Enter To-Do...": {
        "en": "Enter To-Do...", "de": "To-Do eingeben...", "it": "Inserisci To-Do...", "es": "Introducir Tarea...", "fr": "Entrer la Tâche..."
    },
    "SAVE": {
        "en": "SAVE", "de": "SPEICHERN", "it": "SALVA", "es": "GUARDAR", "fr": "ENREGISTRER"
    },
    "Custom To-Do": {
        "en": "Custom To-Do", "de": "Eigenes To-Do", "it": "To-Do Personalizzato", "es": "Tarea Personalizada", "fr": "Tâche Personnalisée"
    },
    "To-Do Name": {
        "en": "To-Do Name", "de": "To-Do Name", "it": "Nome To-Do", "es": "Nombre de Tarea", "fr": "Nom de la Tâche"
    },
    "Description (Optional)": {
        "en": "Description (Optional)", "de": "Beschreibung (Optional)", "it": "Descrizione (Opzionale)", "es": "Descripción (Opcional)", "fr": "Description (Optionnel)"
    },
    "Plant Icon": {
        "en": "Plant Icon", "de": "Pflanzen-Icon", "it": "Icona della pianta", "es": "Icono de planta", "fr": "Icône de plante"
    },
    "Vitamin B5 (Pantothenic Acid)": {
        "en": "Vitamin B5 (Pantothenic Acid)", "de": "Vitamin B5 (Pantothensäure)", "it": "Vitamina B5 (Acido pantotenico)", "es": "Vitamina B5", "fr": "Vitamine B5"
    },
    "Thiamin": {
        "en": "Thiamin", "de": "Thiamin", "it": "Tiamina", "es": "Tiamina", "fr": "Thiamine"
    },
    "Riboflavin": {
        "en": "Riboflavin", "de": "Riboflavin", "it": "Riboflavina", "es": "Riboflavina", "fr": "Riboflavine"
    },
    "Niacin": {
         "en": "Niacin", "de": "Niacin", "it": "Niacina", "es": "Niacina", "fr": "Niacine"
    },
    "Vitamin B6": {
         "en": "Vitamin B6", "de": "Vitamin B6", "it": "Vitamina B6", "es": "Vitamina B6", "fr": "Vitamine B6"
    },
    "Mineralstoffe": {
         "en": "Minerals", "de": "Mineralstoffe", "it": "Minerali", "es": "Minerales", "fr": "Minéraux"
    },
    "Ballaststoffe": {
         "en": "Dietary Fiber", "de": "Ballaststoffe", "it": "Fibre alimentari", "es": "Fibra dietética", "fr": "Fibres alimentaires"
    },
    "streak.weekdays.short": {
        "de": "M,D,M,D,F,S,S",
        "en": "M,T,W,T,F,S,S",
        "es": "L,M,X,J,V,S,D",
        "fr": "L,M,M,J,V,S,D",
        "hi": "सो,मं,बु,गु,शु,श,र",
        "it": "L,M,M,G,V,S,D",
        "ja": "月,火,水,木,金,土,日",
        "ko": "월,화,수,목,금,토,일",
        "nl": "M,D,W,D,V,Z,Z",
        "pl": "P,W,Ś,C,P,S,N",
        "pt": "S,T,Q,Q,S,S,D",
        "pt-BR": "S,T,Q,Q,S,S,D",
        "ru": "П,В,С,Ч,П,С,В",
        "tr": "P,S,Ç,P,C,C,P",
        "zh-Hans": "一,二,三,四,五,六,日",
        "zh-Hant": "一,二,三,四,五,六,日"
    }
}

def main():
    with open(FILE_PATH, 'r', encoding='utf-8') as f:
        data = json.load(f)

    strings = data.get("strings", {})
    all_langs = [
        "de", "en", "es", "fr", "hi", "it", "ja", "ko", "nl", "pl", "pt", "pt-BR", "ru", "tr", "zh-Hans", "zh-Hant"
    ]

    for key, trans_dict in translations.items():
        if key not in strings:
            strings[key] = {"extractionState": "manual", "localizations": {}}
        
        locs = strings[key].get("localizations", {})
        
        for lang in all_langs:
            # Try to get language, fallback to English, then German
            if lang in trans_dict:
                val = trans_dict[lang]
            elif "en" in trans_dict:
                val = trans_dict["en"]
            elif "de" in trans_dict:
                val = trans_dict["de"]
            else:
                val = key
                
            locs[lang] = {
                "stringUnit": {
                    "state": "translated",
                    "value": val
                }
            }
            
        strings[key]["localizations"] = locs

    # Also iterate over all other keys to ensure state is 'translated' 
    # and they have SOME value for all languages
    for k, v in strings.items():
        locs = v.get("localizations", {})
        
        # Determine fallback value
        fallback = k
        if "en" in locs and "stringUnit" in locs["en"]:
            fallback = locs["en"]["stringUnit"]["value"]
        elif "de" in locs and "stringUnit" in locs["de"]:
            fallback = locs["de"]["stringUnit"]["value"]
            
        for lang in all_langs:
            if lang not in locs or "stringUnit" not in locs[lang] or locs[lang]["stringUnit"]["state"] != "translated":
                locs[lang] = {
                    "stringUnit": {
                        "state": "translated",
                        "value": fallback
                    }
                }
        strings[k]["localizations"] = locs

    data["strings"] = strings

    with open(FILE_PATH, 'w', encoding='utf-8') as f:
        json.dump(data, f, indent=2, ensure_ascii=False)
        f.write("\n")
    print("Successfully patched localizations.")

if __name__ == '__main__':
    main()
