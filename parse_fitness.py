import re
import sys

text = """
### Frage 1: Die dunkle Kälte (Deine korrigierte Idee)

> *"Dein Wecker klingelt um 5:30 Uhr für das geplante Workout. Es ist draußen eiskalt, dunkel und regnet."*

| Antwort | Text | `konsistenz` | `intensitaet` | `verantwortung` |
| --- | --- | --- | --- | --- |
| **A** | "Ich drücke auf Snooze. Schlaf ist schließlich auch wichtig für die Regeneration." | **-3** | 0 | **-2** |
| **B** | "Ich bleibe liegen und nehme mir fest vor, das Workout heute Abend nachzuholen (was ich dann nicht tue)." | **-2** | 0 | **-3** |
| **C** | "Ich stehe auf, mache aber nur ein kurzes, halbes Workout zu Hause im Warmen." | +1 | **-2** | +1 |
| **D** | "Ich fluche, stehe auf, friere und ziehe das geplante Workout zu 100% durch." | **+3** | **+2** | **+3** |

---

### Frage 2: Das tote Gym-Abo (Deine korrigierte Idee)

> *"Du zahlst seit 6 Monaten 50€ für ein Gym, warst aber diesen Monat erst ein einziges Mal dort. Was sagst du dir selbst?"*

| Antwort | Text | `konsistenz` | `intensitaet` | `verantwortung` |
| --- | --- | --- | --- | --- |
| **A** | "Ich hatte in letzter Zeit einfach extrem viel Stress und keine Zeit." | **-3** | 0 | **-3** |
| **B** | "Das Gym ist zu weit weg und die Geräte sind eh immer belegt." | **-2** | 0 | **-3** |
| **C** | "Ich kündige das Abo. Offensichtlich bin ich nicht der Typ dafür." | **-1** | 0 | +1 |
| **D** | "Ich bin undiszipliniert gewesen. Ich packe in dieser Sekunde meine Sporttasche." | **+2** | +1 | **+3** |

---

### Frage 3: Die letzte Wiederholung

> *"Du machst eine Übung. Dein Plan sagt 12 Wiederholungen. Bei Nummer 9 fangen deine Muskeln an, extrem zu brennen."*

| Antwort | Text | `konsistenz` | `intensitaet` | `verantwortung` |
| --- | --- | --- | --- | --- |
| **A** | "Ich höre bei 9 auf. Ich will mich ja nicht verletzen." | 0 | **-3** | **-2** |
| **B** | "Ich quäle mich auf 10 und breche dann ab. Das reicht auch." | 0 | **-1** | -1 |
| **C** | "Ich beiße die Zähne zusammen, zwinge mich bis zur 12 und lege keuchend ab." | +1 | **+2** | +2 |
| **D** | "Wenn 12 das Ziel ist und ich bei 12 noch Kraft habe, mache ich 14, bis der Muskel komplett versagt." | +1 | **+3** | **+2** |

---

### Frage 4: Die Zeit-Lüge

> *"Welcher dieser Sätze beschreibt deine aktuelle körperliche Verfassung am besten?"*

| Antwort | Text | `konsistenz` | `intensitaet` | `verantwortung` |
| --- | --- | --- | --- | --- |
| **A** | "Ich habe einfach nicht die Genetik für einen guten Körper." | 0 | 0 | **-3** |
| **B** | "Wenn ich mehr Freizeit hätte, wäre ich in Topform." | **-2** | 0 | **-3** |
| **C** | "Ich trainiere zwar, aber meine Ernährung macht mir meine Ergebnisse kaputt." | +1 | 0 | -1 |
| **D** | "Mein Körper ist das exakte Spiegelbild meiner Disziplin. Ich bekomme das, was ich verdiene." | **+2** | +1 | **+3** |

---

### Frage 5: Der ungemütliche Leg Day

> *"Heute steht dein absolutes Hass-Workout auf dem Plan (z.B. schweres Beintraining oder intensives Cardio). Du hast leichte Kopfschmerzen."*

| Antwort | Text | `konsistenz` | `intensitaet` | `verantwortung` |
| --- | --- | --- | --- | --- |
| **A** | "Ich lasse das Training heute komplett ausfallen. Der Körper braucht Ruhe." | **-2** | **-1** | **-2** |
| **B** | "Ich gehe hin, mache aber stattdessen Brust/Bizeps oder etwas Einfaches, das Spaß macht." | **-2** | **-2** | **-2** |
| **C** | "Ich gehe hin, mache das Hass-Workout, aber mit 50% weniger Gewicht/Geschwindigkeit." | +1 | **-1** | +1 |
| **D** | "Ich gehe hin und zerstöre das Hass-Workout exakt nach Plan. Kopfschmerzen sind keine Ausrede." | **+3** | **+3** | **+3** |

---

### Frage 6: Das Plateau

> *"Du trainierst seit 8 Wochen, siehst aber absolut keinen Fortschritt mehr im Spiegel oder auf der Waage."*

| Antwort | Text | `konsistenz` | `intensitaet` | `verantwortung` |
| --- | --- | --- | --- | --- |
| **A** | "Ich verliere die Motivation und höre auf. Das System funktioniert bei mir nicht." | **-3** | 0 | **-3** |
| **B** | "Ich trainiere lustlos genau gleich weiter und hoffe auf ein Wunder." | +1 | **-3** | **-2** |
| **C** | "Ich kaufe teure Supplements oder suche nach einer geheimen neuen Übung." | 0 | -1 | **-2** |
| **D** | "Ich analysiere meine Ernährung, erhöhe die Intensität und zwinge den Körper zur Anpassung." | **+3** | **+3** | **+3** |

---

### Frage 7: Ego-Lifting vs. Technik

> *"Du machst eine schwere Übung vor anderen Leuten im Gym. Das Gewicht ist eigentlich zu schwer, um es mit sauberer Technik zu bewegen."*

| Antwort | Text | `konsistenz` | `intensitaet` | `verantwortung` |
| --- | --- | --- | --- | --- |
| **A** | "Ich reiße das Gewicht mit absolut miserabler Form hoch, um stark auszusehen." | 0 | **+2** | **-3** |
| **B** | "Ich bitte jemanden, extrem viel mitzuhelfen, und behaupte danach, ich hätte es selbst gedrückt." | 0 | -1 | **-3** |
| **C** | "Ich lege Gewicht ab, bis ich es mit perfekter Form schaffe, auch wenn es peinlich wenig ist." | +1 | +1 | **+3** |
| **D** | "Ich trainiere sowieso nur an geführten Maschinen, weil mir freie Gewichte zu anstrengend sind." | 0 | **-2** | -1 |

---

### Frage 8: Die soziale Sabotage

> *"Du bist auf dem Weg zum Training. Deine Freunde rufen an: 'Komm sofort her, wir haben Pizza bestellt und fangen gleich an zu zocken!'"*

| Antwort | Text | `konsistenz` | `intensitaet` | `verantwortung` |
| --- | --- | --- | --- | --- |
| **A** | "Ich drehe sofort um. Man ist nur einmal jung und Training kann man nachholen." | **-3** | 0 | **-2** |
| **B** | "Ich fahre hin, habe aber ein extrem schlechtes Gewissen dabei." | **-2** | 0 | -1 |
| **C** | "Ich sage ihnen, dass ich in 60 Minuten komme, und ziehe mein Workout vorher in Rekordzeit durch." | **+2** | **+2** | **+2** |
| **D** | "Ich lehne eiskalt ab. Meine Workout-Zeiten sind nicht verhandelbar." | **+3** | +1 | **+3** |

---

### Frage 9: Das unsichtbare Tracking

> *"Wie genau dokumentierst du deine Trainingsfortschritte (Gewichte, Zeiten, Wiederholungen)?"*

| Antwort | Text | `konsistenz` | `intensitaet` | `verantwortung` |
| --- | --- | --- | --- | --- |
| **A** | "Gar nicht. Ich mache das, worauf ich an dem Tag spontan Lust habe." | **-2** | **-2** | **-2** |
| **B** | "Ich merke mir das ungefähr im Kopf." | -1 | -1 | -1 |
| **C** | "Ich habe einen groben Plan auf dem Handy und trage ab und zu mal was ein." | +1 | 0 | +1 |
| **D** | "Jede Einheit, jedes Gewicht und jede Zeit wird präzise geloggt. Ohne Daten kein Wachstum." | **+3** | **+2** | **+3** |

---

### Frage 10: Der Urlaubs-Test

> *"Du bist eine Woche im Urlaub oder auf einem Schul-Ausflug. Es gibt kein Gym und du hast keine Ausrüstung."*

| Antwort | Text | `konsistenz` | `intensitaet` | `verantwortung` |
| --- | --- | --- | --- | --- |
| **A** | "Urlaub ist Urlaub. Ich bewege mich eine Woche lang absolut gar nicht." | **-2** | -1 | -1 |
| **B** | "Ich nehme mir vor zu joggen, lasse die Schuhe aber die ganze Woche im Koffer." | **-3** | 0 | **-2** |
| **C** | "Ich gehe viel spazieren oder schwimmen, mache aber kein echtes Workout." | +1 | **-2** | +1 |
| **D** | "Ich wache morgens auf und zerstöre meinen Körper mit 300 Liegestützen und Kniebeugen im Hotelzimmer." | **+3** | **+3** | **+2** |

---

### Frage 11: Der Smartphone-Junkie

> *"Wie verhältst du dich zwischen deinen Sätzen während des Workouts?"*

| Antwort | Text | `konsistenz` | `intensitaet` | `verantwortung` |
| --- | --- | --- | --- | --- |
| **A** | "Ich scrolle auf TikTok/Instagram, vergesse die Zeit und sitze 5 Minuten am Gerät." | -1 | **-3** | **-2** |
| **B** | "Ich texte mit Freunden, mache aber nach Gefühl irgendwann weiter." | 0 | **-2** | -1 |
| **C** | "Ich kontrolliere exakt meine Pausenzeit auf der Uhr, atme und fokussiere mich auf den nächsten Satz." | **+2** | **+3** | **+2** |
| **D** | "Ich rede mit jedem im Gym und mein Puls fällt komplett in den Keller." | -1 | **-3** | -1 |

---

### Frage 12: Der Schmerz-Unterschied

> *"Während einer Übung spürst du ein starkes, brennendes Gefühl in den Muskeln, es ist extrem unangenehm. Was denkst du in dieser Millisekunde?"*

| Antwort | Text | `konsistenz` | `intensitaet` | `verantwortung` |
| --- | --- | --- | --- | --- |
| **A** | "'Das tut weh, ich muss sofort aufhören, bevor ich kaputt gehe.'" | 0 | **-3** | -1 |
| **B** | "'Ich hasse dieses Gefühl, wann ist das endlich vorbei?'" | +1 | -1 | 0 |
| **C** | "'Noch zwei Wiederholungen, dann habe ich es überstanden.'" | +2 | +1 | +1 |
| **D** | "'Dieses Brennen ist exakt der Punkt, an dem mein Körper wächst. Ich drücke weiter!'" | **+2** | **+3** | **+3** |

---

### Frage 13: Muskelkater des Todes

> *"Du wachst auf und hast so brutalen Muskelkater in den Beinen, dass du kaum die Treppe runterkommst. Heute steht Oberkörper auf dem Plan."*

| Antwort | Text | `konsistenz` | `intensitaet` | `verantwortung` |
| --- | --- | --- | --- | --- |
| **A** | "Ich bleibe im Bett. Mein ganzer Körper braucht Erholung." | **-3** | -1 | **-2** |
| **B** | "Ich gehe nicht ins Training, weil der Weg dorthin schon zu anstrengend ist." | **-3** | -1 | **-3** |
| **C** | "Ich werfe eine Schmerztablette ein und trainiere." | +1 | +1 | -1 |
| **D** | "Ich humple fluchend ins Gym, wärme mich auf und trainiere den Oberkörper exakt nach Plan." | **+3** | **+2** | **+3** |

---

### Frage 14: Der Spiegel-Test

> *"Du schaust an einem schlechten Tag in den Spiegel und bist mit deinem Körper absolut unzufrieden. Was ist deine erste Reaktion?"*

| Antwort | Text | `konsistenz` | `intensitaet` | `verantwortung` |
| --- | --- | --- | --- | --- |
| **A** | "Ich tröste mich mit Fast Food. Ist eh schon alles egal." | **-3** | -1 | **-3** |
| **B** | "Ich rede mir ein, dass 'innere Werte' eh viel wichtiger sind." | -1 | -1 | **-2** |
| **C** | "Ich werde wütend auf mich selbst und beschließe, morgen härter zu trainieren." | +2 | +1 | +2 |
| **D** | "Ich bestrafe die Schwäche sofort: Laufschuhe an, raus auf die Straße, 5 Kilometer rennen." | **+2** | **+3** | **+3** |

---

### Frage 15: Das wahre Ziel

> *"Warum willst du überhaupt fit oder stark sein?"*

| Antwort | Text | `konsistenz` | `intensitaet` | `verantwortung` |
| --- | --- | --- | --- | --- |
| **A** | "Ehrlich gesagt trainiere ich nur, damit andere mich attraktiv finden." | -1 | -1 | -1 |
| **B** | "Ich will auf Social Media gute Bilder posten können." | -1 | -1 | **-2** |
| **C** | "Ich trainiere aus Angst, später krank oder schwach zu werden." | +1 | 0 | +1 |
| **D** | "Ich will wissen, wo mein absolutes körperliches Limit liegt. Es geht um mentale Dominanz." | **+2** | **+3** | **+3** |
"""

blocks = text.split("### Frage")
questions = []
for block in blocks[1:]:
    lines = block.strip().split("\n")
    # Title
    q_id = int(re.search(r'(\d+):', lines[0]).group(1))
    
    # Question Text
    q_text = ""
    for line in lines:
        if line.startswith("> *"):
            q_text = line.replace("> *\"", "").replace("\">", "").replace("\"*", "").replace("*\"", "").replace(">", "").replace("*", "").strip()
            if q_text.startswith('"') and q_text.endswith('"'):
                q_text = q_text[1:-1]
            break
            
    answers = []
    # Answers table
    for line in lines:
        if line.startswith("| **"):
            cols = [c.strip() for c in line.split("|")]
            ans_letter = cols[1].replace("**", "").strip()
            ans_text = cols[2].replace('"', '').strip()
            val1 = int(cols[3].replace("**", "").replace("+", "").strip())
            val2 = int(cols[4].replace("**", "").replace("+", "").strip())
            val3 = int(cols[5].replace("**", "").replace("+", "").strip())
            answers.append((ans_letter, ans_text, val1, val2, val3))
            
    questions.append((q_id, q_text, answers))

swift_code = "        // MARK: - Fitness Quiz Data\n\n"
strings_code = ""

for q_id, q_text, answers in questions:
    q_key = f"assessment.fitness.q{q_id}"
    strings_code += f'"{q_key}" = "{q_text}";\n'
    
    swift_code += f'        // F{q_id}\n'
    swift_code += f'        FitnessQuestion(id: {q_id}, textKey: "{q_key}", answers: [\n'
    
    for i, (ans_letter, ans_text, v1, v2, v3) in enumerate(answers):
        ans_key = f"{q_key}.{ans_letter.lower()}"
        strings_code += f'"{ans_key}" = "{ans_text}";\n'
        swift_code += f'            FitnessAnswer(id: {i}, textKey: "{ans_key}",\n'
        swift_code += f'                          delta: FitnessScoreDeltas(konsistenz: {v1:2}, intensitaet: {v2:2}, verantwortung: {v3:2})),\n'
    
    swift_code += "        ]),\n\n"

print("SWIFT_CODE:")
print(swift_code)
print("STRINGS_CODE:")
print(strings_code)

