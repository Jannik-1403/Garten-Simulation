import json

FILE_PATH = "/Users/jannikschill/Documents/Garten-Simulation/Garten_Simulation/Localizable.xcstrings"

translations = {
    # Todos 
    "plant.detail.todo.add": {
        "en": "Add To-Do", "de": "To-Do hinzufügen", "it": "Aggiungi To-Do", "es": "Añadir Tarea", "fr": "Ajouter une Tâche"
    },
    "todos.tab.select_plant_optional": {
        "en": "For which habit? (Optional)", "de": "Für welche Gewohnheit? (Optional)", "it": "Per quale abitudine? (Opzionale)", "es": "¿Para qué hábito? (Opcional)", "fr": "Pour quelle habitude? (Optionnel)"
    },
    "plant.detail.todo.placeholder": {
        "en": "Enter To-Do...", "de": "To-Do eingeben...", "it": "Inserisci To-Do...", "es": "Introducir Tarea...", "fr": "Entrer la Tâche..."
    },
    "common.save": {
        "en": "SAVE", "de": "SPEICHERN", "it": "SALVA", "es": "GUARDAR", "fr": "ENREGISTRER"
    },
    
    # Custom To-Do
    "routine.todo.title": {
        "en": "Custom To-Do", "de": "Eigenes To-Do", "it": "To-Do Personalizzato", "es": "Tarea Personalizada", "fr": "Tâche Personnalisée"
    },
    "routine.todo.add": {
        "en": "Custom To-Do", "de": "Eigenes To-Do", "it": "To-Do Personalizzato", "es": "Tarea Personalizada", "fr": "Tâche Personnalisée"
    },
    "routine.todo.name.placeholder": {
        "en": "e.g. Take out the trash", "de": "z.B. Müll rausbringen", "it": "es. Buttare la spazzatura", "es": "ej. Sacar la basura", "fr": "ex. Sortir les poubelles"
    },
    "routine.todo.description.placeholder": {
        "en": "e.g. Only the residual waste", "de": "z.B. Nur den Restmüll", "it": "es. Solo i rifiuti residui", "es": "ej. Solo la basura residual", "fr": "ex. Uniquement les déchets résiduels"
    },
    "routine.todo.icon": {
        "en": "Plant Icon", "de": "Pflanzen-Icon", "it": "Icona della pianta", "es": "Icono de planta", "fr": "Icône de plante", "nl": "Plant Icoon"
    },
    "routine.todo.name": {
        "en": "To-Do Name", "de": "To-Do Name", "it": "Nome To-Do", "es": "Nombre de Tarea", "fr": "Nom de la Tâche"
    },
    "routine.todo.description": {
        "en": "Description (Optional)", "de": "Beschreibung (Optional)", "it": "Descrizione (Opzionale)", "es": "Descripción (Opcional)", "fr": "Description (Optionnel)"
    },
    
    # Vitamine
    "nutrient.vitamin_b1": { "en": "Thiamin", "de": "Thiamin", "it": "Tiamina", "es": "Tiamina", "fr": "Thiamine" },
    "nutrient.vitamin_b2": { "en": "Riboflavin", "de": "Riboflavin", "it": "Riboflavina", "es": "Riboflavina", "fr": "Riboflavine" },
    "nutrient.vitamin_b3": { "en": "Niacin", "de": "Niacin", "it": "Niacina", "es": "Niacina", "fr": "Niacine" },
    "nutrient.vitamin_b5": { "en": "Vitamin B5 (Pantothenic Acid)", "de": "Vitamin B5 (Pantothensäure)", "it": "Vitamina B5 (Acido pantotenico)", "es": "Vitamina B5", "fr": "Vitamine B5" },
    "nutrient.vitamin_b6": { "en": "Vitamin B6", "de": "Vitamin B6", "it": "Vitamina B6", "es": "Vitamina B6", "fr": "Vitamine B6" },
    "nutrient.vitamin_b7": { "en": "Biotin", "de": "Biotin", "it": "Biotina", "es": "Biotina", "fr": "Biotine" },
    "nutrient.vitamin_b12": { "en": "Vitamin B12", "de": "Vitamin B12", "it": "Vitamina B12", "es": "Vitamina B12", "fr": "Vitamine B12" },
    "nutrient.vitamin_c": { "en": "Vitamin C", "de": "Vitamin C", "it": "Vitamina C", "es": "Vitamina C", "fr": "Vitamine C" },
    "nutrient.vitamin_a": { "en": "Vitamin A", "de": "Vitamin A", "it": "Vitamina A", "es": "Vitamina A", "fr": "Vitamine A" },
    "nutrient.vitamin_d": { "en": "Vitamin D", "de": "Vitamin D", "it": "Vitamina D", "es": "Vitamina D", "fr": "Vitamine D" },
    "nutrient.vitamin_e": { "en": "Vitamin E", "de": "Vitamin E", "it": "Vitamina E", "es": "Vitamina E", "fr": "Vitamine E" },
    "nutrient.vitamin_k": { "en": "Vitamin K", "de": "Vitamin K", "it": "Vitamina K", "es": "Vitamina K", "fr": "Vitamine K" },
    "nutrient.folate": { "en": "Folate", "de": "Folsäure", "it": "Folato", "es": "Folato", "fr": "Folate" },
    
    # Mineralstoffe
    "nutrient.calcium": { "en": "Calcium", "de": "Kalzium", "it": "Calcio", "es": "Calcio", "fr": "Calcium" },
    "nutrient.chloride": { "en": "Chloride", "de": "Chlorid", "it": "Cloruro", "es": "Cloruro", "fr": "Chlorure" },
    "nutrient.chromium": { "en": "Chromium", "de": "Chrom", "it": "Cromo", "es": "Cromo", "fr": "Chrome" },
    "nutrient.copper": { "en": "Copper", "de": "Kupfer", "it": "Rame", "es": "Cobre", "fr": "Cuivre" },
    "nutrient.iodine": { "en": "Iodine", "de": "Jod", "it": "Iodio", "es": "Yodo", "fr": "Iode" },
    "nutrient.iron": { "en": "Iron", "de": "Eisen", "it": "Ferro", "es": "Hierro", "fr": "Fer" },
    "nutrient.magnesium": { "en": "Magnesium", "de": "Magnesium", "it": "Magnesio", "es": "Magnesio", "fr": "Magnésium" },
    "nutrient.manganese": { "en": "Manganese", "de": "Mangan", "it": "Manganese", "es": "Manganeso", "fr": "Manganèse" },
    "nutrient.molybdenum": { "en": "Molybdenum", "de": "Molybdän", "it": "Molibdeno", "es": "Molibdeno", "fr": "Molybdène" },
    "nutrient.phosphorus": { "en": "Phosphorus", "de": "Phosphor", "it": "Fosforo", "es": "Fósforo", "fr": "Phosphore" },
    "nutrient.potassium": { "en": "Potassium", "de": "Kalium", "it": "Potassio", "es": "Potasio", "fr": "Potassium" },
    "nutrient.selenium": { "en": "Selenium", "de": "Selen", "it": "Selenio", "es": "Selenio", "fr": "Sélénium" },
    "nutrient.sodium": { "en": "Sodium", "de": "Natrium", "it": "Sodio", "es": "Sodio", "fr": "Sodium" },
    "nutrient.zinc": { "en": "Zinc", "de": "Zink", "it": "Zinco", "es": "Zinc", "fr": "Zinc" },
    
    # Kategorien & Sonstiges
    "nutrient.category.minerals": { "en": "Minerals", "de": "Mineralstoffe", "it": "Minerali", "es": "Minerales", "fr": "Minéraux" },
    "nutrient.category.vitamins": { "en": "Vitamins", "de": "Vitamine", "it": "Vitamine", "es": "Vitaminas", "fr": "Vitamines" },
    "health.chart.title.minerals.plain": { "en": "Minerals", "de": "Mineralstoffe", "it": "Minerali", "es": "Minerales", "fr": "Minéraux" },
    "nutrient.target": { "en": "Target:", "de": "Tagesziel:", "it": "Obiettivo:", "es": "Objetivo:", "fr": "Objectif:" },
    "nutrient.settings": { "en": "Settings", "de": "Einstellungen", "it": "Impostazioni", "es": "Ajustes", "fr": "Paramètres" },
    "nutrient.settings.dge_info": {
        "en": "The targets are based on the recommendations of the DGE.",
        "de": "Die Ziele basieren auf den Empfehlungen der DGE (Deutsche Gesellschaft für Ernährung).",
        "it": "Gli obiettivi si basano sulle raccomandazioni della DGE.",
        "es": "Los objetivos se basan en las recomendaciones de la DGE.",
        "fr": "Les objectifs sont basés sur les recommandations de la DGE."
    },
    "nutrient.fiber": { "en": "Dietary Fiber", "de": "Ballaststoffe", "it": "Fibre alimentari", "es": "Fibra dietética", "fr": "Fibres alimentaires" },
    "health.chart.title.fiber.plain": { "en": "Dietary Fiber", "de": "Ballaststoffe", "it": "Fibre alimentari", "es": "Fibra dietética", "fr": "Fibres alimentaires" },
    "nutrient.category.fiber": { "en": "Dietary Fiber", "de": "Ballaststoffe", "it": "Fibre alimentari", "es": "Fibra dietética", "fr": "Fibres alimentaires" },
    
    # Kalorien
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

    data["strings"] = strings

    with open(FILE_PATH, 'w', encoding='utf-8') as f:
        json.dump(data, f, indent=2, ensure_ascii=False)
        f.write("\n")
    print("Successfully patched localizations.")

if __name__ == '__main__':
    main()
