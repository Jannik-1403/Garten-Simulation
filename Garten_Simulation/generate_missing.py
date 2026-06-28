import os, re
from deep_translator import GoogleTranslator

keys = [
    "routine.timer.paused",
    "routine.session.next",
    "routine.note.assign",
    "routine.note.assign.desc",
    "routine_titel",
    "Fokus-Score",
    "Priorität",
    "Unterziel hinzufügen...",
    "assessment.habits.break.title",
    "assessment.habits.build.title",
    "assessment.score.disziplin",
    "assessment.score.effizienz",
    "assessment.score.einfluss",
    "assessment.score.standards",
    "assessment.score.umfeld",
    "assessment.score.umsetzung",
    "assessment.soon",
    "canvas.show_all",
    "common.record",
    "common.this_month",
    "habit.stats.streak",
    "habit.stats.total",
    "path.no_task",
    "pfad_abgeschlossen_belohnung",
    "pfad_belohnung_meilenstein",
    "pfad_belohnung_meisterschaft",
    "pfad_einstellungen_titel",
    "pfad_meilenstein_belohnung",
    "pfad_tag_erledigt_belohnung",
    "pfad_zuruecksetzen_bestaetigen",
    "pfad_zuruecksetzen_button",
    "pfad_zuruecksetzen_nachricht",
    "pfad_zuruecksetzen_titel",
    "powerup.lives.full",
    "powerup.picker.no_plants",
    "profile.focus.same",
    "rarity.common",
    "rarity.epic",
    "rarity.legendary",
    "rarity.mystic",
    "rarity.rare",
    "ritual_config_add_habit",
    "ritual_config_headline",
    "ritual_config_start",
    "ritual_config_subheadline",
    "ritual_config_title",
    "shop.cheatday.confirm",
    "stats.score.focus.period_format",
    "timeline.no_notification",
    "timeline.scheduled_notifications"
]

defaults_en = {
    "routine.timer.paused": "routine.timer.paused",
    "routine.session.next": "Next up",
    "routine.note.assign": "Assign Note",
    "routine.note.assign.desc": "Add a note to this routine.",
    "routine_titel": "Routine",
    "Fokus-Score": "Focus Score",
    "Priorität": "Priority",
    "Unterziel hinzufügen...": "Add sub-goal...",
    "assessment.habits.break.title": "Habits to Break",
    "assessment.habits.build.title": "Habits to Build",
    "assessment.score.disziplin": "Discipline",
    "assessment.score.effizienz": "Efficiency",
    "assessment.score.einfluss": "Influence",
    "assessment.score.standards": "Standards",
    "assessment.score.umfeld": "Environment",
    "assessment.score.umsetzung": "Execution",
    "assessment.soon": "Coming Soon",
    "canvas.show_all": "Show All",
    "common.record": "Record",
    "common.this_month": "This Month",
    "habit.stats.streak": "Current Streak",
    "habit.stats.total": "Total Executions",
    "path.no_task": "No task for today.",
    "pfad_abgeschlossen_belohnung": "Path Completion Reward",
    "pfad_belohnung_meilenstein": "Milestone Reward",
    "pfad_belohnung_meisterschaft": "Mastery Reward",
    "pfad_einstellungen_titel": "Path Settings",
    "pfad_meilenstein_belohnung": "Milestone Reward",
    "pfad_tag_erledigt_belohnung": "Day Completed Reward",
    "pfad_zuruecksetzen_bestaetigen": "Confirm Reset",
    "pfad_zuruecksetzen_button": "Reset Path",
    "pfad_zuruecksetzen_nachricht": "Are you sure you want to reset your path? All progress will be lost.",
    "pfad_zuruecksetzen_titel": "Reset Path?",
    "powerup.lives.full": "Lives are full!",
    "powerup.picker.no_plants": "No plants available.",
    "profile.focus.same": "You focused for the same amount of time as yesterday. Keep it steady!",
    "rarity.common": "Common",
    "rarity.epic": "Epic",
    "rarity.legendary": "Legendary",
    "rarity.mystic": "Mystic",
    "rarity.rare": "Rare",
    "ritual_config_add_habit": "Add Habit",
    "ritual_config_headline": "Configure Routine",
    "ritual_config_start": "Start Routine",
    "ritual_config_subheadline": "Select the habits you want to include in this routine.",
    "ritual_config_title": "Routine Configuration",
    "shop.cheatday.confirm": "Activate Cheat Day?",
    "stats.score.focus.period_format": "Focus Score: %@",
    "timeline.no_notification": "No Notifications",
    "timeline.scheduled_notifications": "Scheduled Notifications"
}

langs = ["de", "es", "fr", "it", "pt", "ja", "ko", "pl", "nl", "tr"]

print("Translating missing strings...")
all_dicts = {}

for k, en_val in defaults_en.items():
    d = {"en": en_val}
    for lang in langs:
        try:
            d[lang] = GoogleTranslator(source='en', target=lang).translate(en_val)
        except Exception as e:
            d[lang] = en_val
    all_dicts[k] = d

def escape(s):
    return s.replace('"', '\\"').replace('\n', ' ')

def make_str(d):
    parts = []
    for lang_code, text in d.items():
        parts.append(f'"{lang_code}": "{escape(text)}"')
    return ", ".join(parts)

lines = []
for k, d in all_dicts.items():
    lines.append(f'        "{k}": [{make_str(d)}],')

with open("Localization/AppStrings.swift", "r") as f:
    content = f.read()

import re
match = re.search(r'("stats\.score\.msg\.low": \[.*?\],)', content)
if match:
    new_content = content[:match.end()] + "\n" + "\n".join(lines) + content[match.end():]
    with open("Localization/AppStrings.swift", "w") as f:
        f.write(new_content)
    print("Added all missing strings successfully!")
else:
    print("Could not find insertion point!")
