import json

filepath = 'Garten_Simulation/Localizable.xcstrings'

with open(filepath, 'r') as f:
    data = json.load(f)

# Define texts in DE and EN
texts = {
    # Headers
    "assessment.analysis.strength_title": {"de": "Deine größte Stärke", "en": "Your Greatest Strength"},
    "assessment.analysis.weakness_title": {"de": "Die harte Wahrheit", "en": "The Hard Truth"},
    "assessment.analysis.pitfall_title": {"de": "Gefahrenzone: Was du vermeiden musst", "en": "Danger Zone: What to Avoid"},
    "assessment.analysis.benchmark_title": {"de": "Dein Benchmark-Score", "en": "Your Benchmark Score"},
    
    # Benchmarks
    "assessment.benchmark.top10": {"de": "Du gehörst zu den Top 10% in dieser Kategorie. Du bist extrem diszipliniert und hebst dich deutlich vom Durchschnitt ab.", "en": "You are in the top 10%. You are extremely disciplined and stand out from the crowd."},
    "assessment.benchmark.top30": {"de": "Solide Leistung (Top 30%). Du bist überdurchschnittlich, aber es gibt noch klares Potenzial nach oben.", "en": "Solid performance (Top 30%). You are above average, but there is room for improvement."},
    "assessment.benchmark.average": {"de": "Du liegst im Durchschnitt. Das ist nicht schlecht, aber Mittelmaß bringt keine außergewöhnlichen Ergebnisse.", "en": "You are average. Not bad, but average efforts don't yield extraordinary results."},
    "assessment.benchmark.bottom30": {"de": "Alarmbereitschaft. Du liegst unter dem Durchschnitt. Hier musst du dringend ansetzen, um nicht weiter zurückzufallen.", "en": "Red alert. You are below average. You need to take immediate action to avoid falling further behind."},
    "benchmark.bottom": {"de": "Anfänger", "en": "Beginner"},
    "benchmark.top": {"de": "Top 1%", "en": "Top 1%"},
    
    # FINANCE
    "assessment.finance.strength.control": {"de": "Du hast deine Finanzen im Blick. Jeder Euro wird getrackt und du weißt genau, wohin dein Geld fließt.", "en": "You track every cent and know exactly where your money flows."},
    "assessment.finance.strength.budget": {"de": "Klare Entscheidungen. Du gibst dein Geld extrem zielgerichtet aus und vermeidest Spontankäufe.", "en": "Clear decisions. You spend money purposefully and avoid impulse purchases."},
    "assessment.finance.strength.reserves": {"de": "Du baust verlässlich Rücklagen auf und hast einen Notgroschen für unvorhergesehene Krisen.", "en": "You reliably build reserves and have a safety net for crises."},
    "assessment.finance.weakness.control": {"de": "Dir rinnt das Geld durch die Finger. Ohne Tracking hast du keine Ahnung, wofür du wirklich arbeitest.", "en": "Money slips through your fingers. Without tracking, you are working blind."},
    "assessment.finance.weakness.budget": {"de": "Emotionale Käufe sabotieren deinen Fortschritt. Du triffst finanzielle Entscheidungen aus dem Bauch heraus statt rational.", "en": "Emotional purchases sabotage you. You make financial decisions based on feelings, not logic."},
    "assessment.finance.weakness.reserves": {"de": "Du lebst von Gehalt zu Gehalt. Eine kleine Krise reicht, um dich finanziell zu ruinieren.", "en": "Living paycheck to paycheck. One crisis could ruin you financially."},
    "assessment.finance.pitfall.control": {"de": "Vermeide es, Ausgaben am Ende des Monats zu ignorieren. Schau den Tatsachen sofort ins Gesicht.", "en": "Avoid ignoring expenses at month's end. Face the reality immediately."},
    "assessment.finance.pitfall.budget": {"de": "Geh nicht ohne Einkaufszettel in den Supermarkt. Jede ungeplante Ausgabe summiert sich auf.", "en": "Don't shop without a list. Every unplanned purchase adds up."},
    "assessment.finance.pitfall.reserves": {"de": "Hör auf, Geld für Konsum auszugeben, bevor du nicht mindestens 10% deines Einkommens gespart hast.", "en": "Stop spending on consumption before saving at least 10% of your income."},

    # HEALTH
    "assessment.health.strength.sleep": {"de": "Dein Schlaf ist deine Superkraft. Du erholst dich tief und gehst mit maximaler Energie in den Tag.", "en": "Sleep is your superpower. You recover deeply and start the day energized."},
    "assessment.health.strength.nutrition": {"de": "Dein Körper bekommt den perfekten Kraftstoff. Du isst clean, bewusst und nährstoffreich.", "en": "Your body gets the perfect fuel. You eat clean, mindful, and nutritious."},
    "assessment.health.strength.regeneration": {"de": "Du achtest auf aktive Prävention. Yoga, Dehnen oder Spaziergänge halten deinen Körper geschmeidig.", "en": "You focus on active prevention. Yoga, stretching, or walks keep you resilient."},
    "assessment.health.weakness.sleep": {"de": "Schlafmangel zerstört dein Potenzial. Du bist oft erschöpft und deine Regeneration leidet massiv.", "en": "Lack of sleep destroys your potential. You are exhausted and your recovery suffers."},
    "assessment.health.weakness.nutrition": {"de": "Junk Food und Zucker rauben dir Energie. Du fütterst deinen Körper mit billigem Treibstoff.", "en": "Junk food and sugar steal your energy. You fuel your body with cheap trash."},
    "assessment.health.weakness.regeneration": {"de": "Du verbrennst auf beiden Seiten. Keine Pausen, keine Pflege – dein Körper wird das auf Dauer nicht mitmachen.", "en": "Burning the candle at both ends. No breaks, no care – your body will fail eventually."},
    "assessment.health.pitfall.sleep": {"de": "Vermeide Bildschirme 60 Minuten vor dem Schlafengehen. Das blaue Licht zerstört deine Melatonin-Produktion.", "en": "Avoid screens 60 minutes before bed. Blue light destroys your melatonin."},
    "assessment.health.pitfall.nutrition": {"de": "Lass die Finger von flüssigen Kalorien und Zucker-Snacks am Nachmittag. Das führt zu einem massiven Crash.", "en": "Stay away from liquid calories and afternoon sugar snacks. They lead to massive crashes."},
    "assessment.health.pitfall.regeneration": {"de": "Ignoriere kleine Schmerzen nicht. Wenn dein Körper Signale sendet, drück nicht einfach Schmerzmittel rein.", "en": "Don't ignore minor pains. When your body signals distress, don't just pop a pill."},

    # MENTAL
    "assessment.mental.strength.stress": {"de": "Dich bringt nichts aus der Ruhe. Unter Druck lieferst du deine besten Ergebnisse ab.", "en": "Nothing rattles you. Under pressure, you deliver your best work."},
    "assessment.mental.strength.focus": {"de": "Laser-Fokus. Wenn du arbeitest, existiert der Rest der Welt nicht mehr.", "en": "Laser focus. When you work, the rest of the world ceases to exist."},
    "assessment.mental.strength.mindfulness": {"de": "Du hast ein hohes Bewusstsein für dich selbst und reflektierst dein Handeln kritisch, aber fair.", "en": "High self-awareness. You reflect critically but fairly on your actions."},
    "assessment.mental.weakness.stress": {"de": "Stress frisst dich auf. Kleine Probleme werfen dich sofort aus der Bahn und rauben dir den Schlaf.", "en": "Stress eats you alive. Small problems derail you instantly and steal your sleep."},
    "assessment.mental.weakness.focus": {"de": "Dein Fokus ist zersplittert. Ständige Handykontrolle und Multitasking machen dich ineffizient.", "en": "Fragmented focus. Constant phone checking and multitasking make you inefficient."},
    "assessment.mental.weakness.mindfulness": {"de": "Dein Ego steht dir im Weg. Du suchst die Schuld oft bei anderen statt bei dir selbst.", "en": "Your ego is in the way. You blame others instead of reflecting on yourself."},
    "assessment.mental.pitfall.stress": {"de": "Vermeide es, direkt nach dem Aufstehen Mails oder Social Media zu checken. Du startest reaktiv in den Tag.", "en": "Avoid checking emails or social media right after waking up. You start the day reactive."},
    "assessment.mental.pitfall.focus": {"de": "Lass dein Handy bei tiefer Arbeit NIEMALS auf dem Schreibtisch liegen. Lege es in einen anderen Raum.", "en": "NEVER keep your phone on the desk during deep work. Put it in another room."},
    "assessment.mental.pitfall.mindfulness": {"de": "Reagiere nicht sofort auf Kritik. Atme dreimal tief durch, bevor du dich verteidigst.", "en": "Don't react to criticism immediately. Take three deep breaths before defending yourself."},

    # GROWTH
    "assessment.growth.strength.discipline": {"de": "Eiserne Disziplin. Du machst die Dinge, auch wenn du keine Lust hast. Das ist der Weg zum Erfolg.", "en": "Iron discipline. You do the work even when you don't feel like it. That's the way to success."},
    "assessment.growth.strength.efficiency": {"de": "Du arbeitest extrem klug. Statt nur hart zu arbeiten, nutzt du Hebel, um mehr in kürzerer Zeit zu schaffen.", "en": "Extremely smart worker. Instead of just working hard, you use leverage to achieve more."},
    "assessment.growth.strength.execution": {"de": "Du redest nicht, du machst. Deine Umsetzungsgeschwindigkeit ist überragend.", "en": "You don't talk, you act. Your execution speed is outstanding."},
    "assessment.growth.weakness.discipline": {"de": "Du bist ein Meister der Ausreden. Sobald es schwer wird, gibst du auf oder verschiebst es auf morgen.", "en": "Master of excuses. The moment it gets hard, you quit or push it to tomorrow."},
    "assessment.growth.weakness.efficiency": {"de": "Du bist chronisch 'busy', schaffst aber nichts. Du verwechselst Beschäftigung mit Produktivität.", "en": "Chronically 'busy', achieving nothing. You confuse activity with productivity."},
    "assessment.growth.weakness.execution": {"de": "Du planst zu viel und handelst zu wenig. Die beste Idee bringt nichts ohne Umsetzung.", "en": "Too much planning, too little action. The best idea is worthless without execution."},
    "assessment.growth.pitfall.discipline": {"de": "Hör auf, dich auf Motivation zu verlassen. Motivation ist vergänglich, Routinen bleiben.", "en": "Stop relying on motivation. Motivation fades, routines remain."},
    "assessment.growth.pitfall.efficiency": {"de": "Vermeide Perfektionismus. 80% erledigt ist besser als 0% perfekt.", "en": "Avoid perfectionism. 80% done is better than 0% perfect."},
    "assessment.growth.pitfall.execution": {"de": "Konsumiere keine weiteren Podcasts oder Bücher, bevor du das Gelernte nicht angewendet hast (Action Faking).", "en": "Don't consume more books or podcasts until you've applied what you learned (Action Faking)."},

    # FITNESS
    "assessment.fitness.strength.strength": {"de": "Deine Konsistenz im Training zahlt sich aus. Du baust kontinuierlich Stärke und Substanz auf.", "en": "Your consistency pays off. You are continuously building strength and substance."},
    "assessment.fitness.strength.endurance": {"de": "Du gehst an deine Grenzen. Deine Intensität im Workout zeigt, dass du echte Ergebnisse willst.", "en": "You push your limits. Your workout intensity shows you want real results."},
    "assessment.fitness.strength.mobility": {"de": "Du übernimmst Verantwortung für deinen Körper. Du trainierst nicht nur hart, sondern auch clever.", "en": "You take responsibility for your body. You train not only hard, but smart."},
    "assessment.fitness.weakness.strength": {"de": "Du bist komplett inkonsequent. Mal trainierst du, mal wochenlang nicht. So entsteht kein Fortschritt.", "en": "Completely inconsistent. Sometimes you train, sometimes you don't. That yields no progress."},
    "assessment.fitness.weakness.endurance": {"de": "Deine Workouts sind Spaziergänge. Du verlässt deine Komfortzone nicht und verschwendest deine Zeit.", "en": "Your workouts are walks in the park. You never leave your comfort zone and waste your time."},
    "assessment.fitness.weakness.mobility": {"de": "Du schiebst die Schuld auf 'Genetik' oder Zeitmangel. Keine Eigenverantwortung für deinen Zustand.", "en": "You blame 'genetics' or lack of time. No personal responsibility for your condition."},
    "assessment.fitness.pitfall.strength": {"de": "Verlasse dich nicht auf das Gefühl, 'heute nicht fit' zu sein. Auch ein schlechtes Workout ist besser als keins.", "en": "Don't rely on the feeling of 'not being fit today'. Even a bad workout is better than none."},
    "assessment.fitness.pitfall.endurance": {"de": "Hör auf, während des Trainings am Handy zu scrollen. Das killt jede Intensität.", "en": "Stop scrolling on your phone during workouts. It kills all intensity."},
    "assessment.fitness.pitfall.mobility": {"de": "Lass keine Ausreden mehr zu. Du hast jeden Tag 30 Minuten Zeit – du musst sie dir nur nehmen.", "en": "No more excuses. You have 30 minutes every day – you just have to prioritize it."},

    # LIFESTYLE
    "assessment.lifestyle.strength.routine": {"de": "Dein Umfeld ist ein Katalysator. Du umgibst dich mit Leuten, die dich nach oben ziehen.", "en": "Your environment is a catalyst. You surround yourself with people who pull you up."},
    "assessment.lifestyle.strength.environment": {"de": "Du setzt extrem hohe Standards an dich und dein Leben. Mittelmaß akzeptierst du nicht.", "en": "You set extremely high standards for yourself and your life. You do not accept mediocrity."},
    "assessment.lifestyle.strength.balance": {"de": "Du verstehst deinen Einflussbereich und machst dir keine Sorgen über Dinge, die du nicht ändern kannst.", "en": "You understand your circle of influence and don't worry about things you cannot change."},
    "assessment.lifestyle.weakness.routine": {"de": "Du hängst mit Leuten ab, die nur konsumieren und lästern. Dein Umfeld zieht dich auf ihr Level hinab.", "en": "You hang out with consumers and gossipers. Your environment drags you down to their level."},
    "assessment.lifestyle.weakness.environment": {"de": "Deine Standards sind am Boden. Du lässt Unordnung, toxische Beziehungen und schlechte Gewohnheiten zu.", "en": "Your standards are rock bottom. You tolerate clutter, toxic relationships, and bad habits."},
    "assessment.lifestyle.weakness.balance": {"de": "Du lässt dich von äußeren Umständen lenken. Statt dein Leben zu steuern, bist du nur Passagier.", "en": "You let external circumstances dictate your life. Instead of driving, you are just a passenger."},
    "assessment.lifestyle.pitfall.routine": {"de": "Vermeide es, Ja zu sozialen Events zu sagen, auf die du keine Lust hast. Schütze deine Energie.", "en": "Avoid saying yes to social events you don't want to attend. Protect your energy."},
    "assessment.lifestyle.pitfall.environment": {"de": "Hör auf, deinen Arbeitsplatz im Chaos versinken zu lassen. Ein unaufgeräumter Raum führt zu einem unaufgeräumten Geist.", "en": "Stop letting your workspace become a mess. A cluttered room leads to a cluttered mind."},
    "assessment.lifestyle.pitfall.balance": {"de": "Verschwende keine Zeit damit, dich über die Politik oder die Wirtschaft zu beschweren. Fokussiere dich auf deinen Einfluss.", "en": "Don't waste time complaining about politics or the economy. Focus on your circle of influence."}
}

strings = data.setdefault('strings', {})

languages = ["de", "en", "es", "fr", "it", "tr", "pt", "pt-BR"]

# Update strings with actual translations. For non-DE/EN, default to EN to avoid the ugly [en] tags
for key, vals in texts.items():
    if key not in strings:
        strings[key] = {"extractionState": "manual", "localizations": {}}
    
    for lang in languages:
        if lang == "de":
            val = vals["de"]
        elif lang == "en":
            val = vals["en"]
        else:
            val = vals["en"] # fallback to english directly for other languages so it looks clean
        
        strings[key]["localizations"][lang] = {
            "stringUnit": {
                "state": "translated",
                "value": val
            }
        }

# Also clean up the [en] tags in existing dynamic insight texts if any
for key, obj in strings.items():
    if "localizations" in obj:
        for lang, loc in obj["localizations"].items():
            if "stringUnit" in loc and "value" in loc["stringUnit"]:
                v = loc["stringUnit"]["value"]
                if v.startswith(f"[{lang}] "):
                    # Just remove the tag and keep the german text if it was auto-generated
                    loc["stringUnit"]["value"] = v.replace(f"[{lang}] ", "")

with open(filepath, 'w') as f:
    json.dump(data, f, indent=2, ensure_ascii=False)
