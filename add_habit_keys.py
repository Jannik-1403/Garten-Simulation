import os

new_keys_de = {
    "habit.stats.title": "Statistiken",
    "habit.stats.count": "Bisher: %d",
    "habit.stats.streak": "Streak (Tage)",
    "habit.stats.total": "Gesamt",
    "habit.stats.month": "Dieser Monat",
    "habit.stats.impact": "Negativer Effekt",
    "habit.impact.title": "Die 1%-Methode",
    "habit.impact.explanation": "Laut James Clears 'Die 1%-Methode' wirst du durch diese Gewohnheit jedes Mal 1% schlechter (0,99). Dies hat auf lange Sicht einen immensen negativen Effekt auf dein Leben.",
    "habit.tips.title": "Tipps (Die 4 Gesetze)",
    "habit.tip.1": "Auslöser unsichtbar machen: Entferne alle Reize, die diese Gewohnheit auslösen, aus deiner Umgebung.",
    "habit.tip.2": "Verlangen unattraktiv machen: Führe dir die negativen Folgen vor Augen, um die Gewohnheit gedanklich abzuwerten.",
    "habit.tip.3": "Reaktion schwierig machen: Erhöhe die Hürden und Schritte, die nötig sind, um die Gewohnheit auszuführen.",
    "habit.tip.4": "Belohnung unbefriedigend machen: Führe eine sofortige Bestrafung oder einen Rechenschaftspartner ein.",
    "habit.relapse.report": "Rückfall melden"
}

new_keys_en = {
    "habit.stats.title": "Statistics",
    "habit.stats.count": "So far: %d",
    "habit.stats.streak": "Streak (Days)",
    "habit.stats.total": "Total",
    "habit.stats.month": "This Month",
    "habit.stats.impact": "Negative Impact",
    "habit.impact.title": "The 1% Method",
    "habit.impact.explanation": "According to James Clear's 'The 1% Method', you become 1% worse (0.99) every time you execute this habit. This has an immense negative compound effect on your life in the long run.",
    "habit.tips.title": "Tips (The 4 Laws)",
    "habit.tip.1": "Make it invisible: Remove all cues that trigger this habit from your environment.",
    "habit.tip.2": "Make it unattractive: Focus on the negative consequences to mentally devalue the habit.",
    "habit.tip.3": "Make it difficult: Increase the friction and steps required to execute the habit.",
    "habit.tip.4": "Make it unsatisfying: Introduce an immediate punishment or an accountability partner.",
    "habit.relapse.report": "Report Relapse"
}

lproj_dir = "Garten_Simulation"

for lproj in os.listdir(lproj_dir):
    if not lproj.endswith(".lproj"):
        continue
    
    file_path = os.path.join(lproj_dir, lproj, "Localizable.strings")
    if not os.path.exists(file_path):
        continue
        
    keys_to_use = new_keys_de if lproj == "de.lproj" else new_keys_en
    
    with open(file_path, "a") as f:
        f.write("\n")
        for k, v in keys_to_use.items():
            f.write(f'"{k}" = "{v}";\n')
    
    print(f"Updated {file_path}")
