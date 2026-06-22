import sys

strings = """

// MARK: - Fitness Assessment
"assessment.fitness.nav.title" = "Fitness Assessment";
"assessment.fitness.profile.schoenwetter_sportler.title" = "Schönwetter-Sportler";
"assessment.fitness.profile.schoenwetter_sportler.desc" = "Du trainierst nur, wenn die Bedingungen perfekt sind. Sobald es ungemütlich wird oder du keine Lust hast, drückst du dich. Dein Körper wird nie sein Potenzial entfalten, solange dein Geist bei jedem Widerstand aufgibt.";
"assessment.fitness.profile.schoenwetter_sportler.action" = "Konsistenz ist alles. Trainiere heute, auch wenn du absolut keine Lust hast.";

"assessment.fitness.profile.wohlfuehler.title" = "Wohlfühl-Sportler";
"assessment.fitness.profile.wohlfuehler.desc" = "Du bist zwar regelmäßig im Gym, aber du weigerst dich, an die Schmerzgrenze zu gehen. Dein Körper hat sich längst an dein Training gewöhnt und lacht darüber. Ohne echten Reiz gibt es kein Wachstum.";
"assessment.fitness.profile.wohlfuehler.action" = "Erhöhe die Intensität. Das Workout beginnt erst, wenn es wehtut.";

"assessment.fitness.profile.ausreden_sucher.title" = "Ausreden-Sucher";
"assessment.fitness.profile.ausreden_sucher.desc" = "Es ist immer die Genetik, die Zeit, das Wetter oder der Stress. Du übernimmst keine Verantwortung für deinen Körper und lügst dich selbst an, um dein Ego zu schützen.";
"assessment.fitness.profile.ausreden_sucher.action" = "Akzeptiere die Realität. Dein Körper ist das exakte Resultat deiner Entscheidungen.";

"assessment.fitness.profile.maschine.title" = "Die Maschine";
"assessment.fitness.profile.maschine.desc" = "Deine Disziplin ist aus Eisen. Du kontrollierst deinen Körper, nicht umgekehrt. Egal ob es regnet, du müde bist oder die Muskeln brennen – du ziehst durch und dominierst.";
"assessment.fitness.profile.maschine.action" = "Respekt. Behalte diesen unaufhaltsamen Fokus bei.";

"assessment.score.konsistenz" = "KONSISTENZ";
"assessment.score.intensitaet" = "INTENSITÄT";
"assessment.score.verantwortung" = "VERANTWORTUNG";

"""

with open('output.txt', 'r') as f:
    lines = f.readlines()

flag = False
for line in lines:
    if "STRINGS_CODE:" in line:
        flag = True
        continue
    if flag:
        strings += line

with open('Garten_Simulation/de.lproj/Localizable.strings', 'a') as f:
    f.write(strings)

