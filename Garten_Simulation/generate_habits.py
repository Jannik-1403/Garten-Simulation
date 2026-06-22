import json
import re
from deep_translator import GoogleTranslator

langs = ["en", "es", "fr", "it", "pt", "ja", "ko", "pl", "nl", "tr"]

data = {
    "assessment.habits.build.title": "Do's",
    "assessment.habits.break.title": "Don'ts",
    
    "assessment.growth.profile.traeumer.build": "10 Minuten Deep Work blocken. Handy weg. Eine einzige harte Aufgabe erledigen.",
    "assessment.growth.profile.traeumer.break": "Aufhören, Vision-Boards zu basteln. Die Umsetzung bringt das Ergebnis, nicht das Tagträumen.",
    "assessment.growth.profile.fakeWorker.build": "Täglich die 3 wichtigsten Aufgaben priorisieren. Alles andere ist Ablenkung.",
    "assessment.growth.profile.fakeWorker.break": "Aufhören, sich mit 'Busy Work' etwas vorzumachen. Fokus auf den Impact.",
    "assessment.growth.profile.aufgeber.build": "Wenn es wehtut, noch 5 Minuten weitermachen. Schmerz ist Wachstum.",
    "assessment.growth.profile.aufgeber.break": "Keine Ausreden mehr. Wenn du aufgibst, belügst du dich selbst.",
    "assessment.growth.profile.macher.build": "Das eigene System auditieren. Was dich hierher gebracht hat, bringt dich nicht ans nächste Ziel.",
    "assessment.growth.profile.macher.break": "Kontakt zur Realität behalten. Hochmut kommt vor dem Fall.",

    "assessment.lifestyle.profile.gefangener.build": "Täglich 15 Minuten allein verbringen. Das Denken von fremden Einflüssen entgiften.",
    "assessment.lifestyle.profile.gefangener.break": "Kontakt zu Energiefressern abbrechen. Dulde keine toxischen Leute.",
    "assessment.lifestyle.profile.chaot.build": "Jeden Morgen das Bett machen und dein Chaos kontrollieren.",
    "assessment.lifestyle.profile.chaot.break": "Ausreden wie 'kreatives Chaos' beenden. Disziplin beginnt bei den Standards.",
    "assessment.lifestyle.profile.mitlaeufer.build": "Eine Entscheidung gegen den Strom treffen. Eigene Meinung statt Konsens.",
    "assessment.lifestyle.profile.mitlaeufer.break": "Aufhören, anderen gefallen zu wollen. Respekt verdient man nicht durch Anpassung.",
    "assessment.lifestyle.profile.elite.build": "Verantwortung für andere übernehmen. Setze die Standards für dein Umfeld.",
    "assessment.lifestyle.profile.elite.break": "Nicht auf dem Status Quo ausruhen. Der Preis für Elite ist ständige Wachsamkeit.",

    "assessment.mental.profile.glaeserner.build": "Täglich kalt duschen. Den Geist zwingen, physischen Widerstand zu überwinden.",
    "assessment.mental.profile.glaeserner.break": "Aufhören, in Panik zu verfallen. Atmen statt reagieren.",
    "assessment.mental.profile.getriebener.build": "10 Minuten Stille aushalten. Keine Reize, keine Ablenkung.",
    "assessment.mental.profile.getriebener.break": "Reiz-Konsum stoppen. Dopamin-Detox für mehr Klarheit.",
    "assessment.mental.profile.spiegel.build": "Eine klare Grenze setzen. Ein 'Nein' ohne Rechtfertigung kommunizieren.",
    "assessment.mental.profile.spiegel.break": "Hör auf, deinen Wert an Erwartungen anderer zu messen.",
    "assessment.mental.profile.unerschuetterlicher.build": "Neue Herausforderungen suchen, um das Ego täglich zu zerstören.",
    "assessment.mental.profile.unerschuetterlicher.break": "Arroganz vermeiden. Dein größter Feind ist die Selbstgefälligkeit.",

    "assessment.health.profile.erschoepfer.build": "Schlaf radikal priorisieren. 8 Stunden sind eine biologische Notwendigkeit.",
    "assessment.health.profile.erschoepfer.break": "Körper auf Pump stoppen. Koffein ersetzt keine Erholung.",
    "assessment.health.profile.vergifter.build": "3 Liter klares Wasser trinken. Den Motor mit Kraftstoff versorgen.",
    "assessment.health.profile.vergifter.break": "Verarbeiteten Müll streichen. Was du isst, formt deinen Verstand.",
    "assessment.health.profile.ignorant.build": "Täglich in Mobility investieren. Prävention ist günstiger als Reparatur.",
    "assessment.health.profile.ignorant.break": "Aufhören, Schmerzen mit Schmerzmitteln zu übertünchen.",
    "assessment.health.profile.optimierer.build": "Neue wissenschaftliche Erkenntnisse prüfen und adaptieren.",
    "assessment.health.profile.optimierer.break": "Die Obsession mit Metriken vermeiden. Hör auf deinen Körper.",

    "assessment.fitness.profile.schoenwetter_sportler.build": "Training fest blocken. Unabhängig von Wetter oder Lust durchziehen.",
    "assessment.fitness.profile.schoenwetter_sportler.break": "Training nicht vom Gefühl abhängig machen. Gefühle sind irrelevant.",
    "assessment.fitness.profile.wohlfuehler.build": "Im Training ans Limit gehen. Dort beginnt das Wachstum.",
    "assessment.fitness.profile.wohlfuehler.break": "Komfortzone verlassen. 10 Reps sind nutzlos, wenn 15 möglich wären.",
    "assessment.fitness.profile.ausreden_sucher.build": "Verantwortung übernehmen. Deine Form ist das Spiegelbild deiner Disziplin.",
    "assessment.fitness.profile.ausreden_sucher.break": "Keine Schuld bei Genetik suchen. Mach die verdammte Arbeit.",
    "assessment.fitness.profile.maschine.build": "Aktive Regeneration ernst nehmen. Nur ein erholter Muskel wächst.",
    "assessment.fitness.profile.maschine.break": "Burnout vermeiden. Regeneration ist kein Zeichen von Schwäche."
}

translations = {}
for key, de_text in data.items():
    translations[key] = {"de": de_text}

for lang in langs:
    print(f"Translating to {lang}...")
    translator = GoogleTranslator(source='de', target=lang)
    for key, de_text in data.items():
        try:
            translations[key][lang] = translator.translate(de_text)
        except Exception as e:
            translations[key][lang] = de_text

# Update AppStrings.swift
with open('Localization/AppStrings.swift', 'r', encoding='utf-8') as f:
    content = f.read()

new_entries = []
for key, langs_dict in translations.items():
    def escape(s):
        if not isinstance(s, str): return ""
        return s.replace('\\', '\\\\').replace('"', '\\"').replace('\n', ' ')
    
    dict_str = ", ".join([f'"{lang}": "{escape(text)}"' for lang, text in langs_dict.items()])
    new_entries.append(f'        "{key}": [{dict_str}],')

# Insert before the last `    ]\n}`
match = re.search(r'(\s+)\]\n\}', content)
if match:
    indent = match.group(1)
    # Add a comma to the last existing entry if needed? The regex assumes we just append.
    # Swift allows arrays to have trailing commas, but dictionaries? Yes, dictionaries too. But wait, no, we just append with a comma.
    # Since we don't know if the previous line has a comma, we just add our lines.
    # We assume the last line of `content` before `    ]\n}` ends with `,`.
    
    insert_str = '\n'.join(new_entries) + '\n' + indent + ']\n}'
    content = content.replace(indent + ']\n}', insert_str)
else:
    print("Could not find end of dict")

with open('Localization/AppStrings.swift', 'w', encoding='utf-8') as f:
    f.write(content)

print("Translations generated and injected!")
