import json

file_path = "/Users/jannikschill/Documents/Garten-Simulation/Garten_Simulation/Localizable.xcstrings"
with open(file_path, "r") as f:
    d = json.load(f)

def update_it(key, value):
    if key in d["strings"]:
        if "localizations" not in d["strings"][key]:
            d["strings"][key]["localizations"] = {}
        d["strings"][key]["localizations"]["it"] = {
            "stringUnit": {
                "state": "translated",
                "value": value
            }
        }
        print(f"Updated {key} to {value}")

update_it("calorie.history.target", "Obiettivo")
update_it("plant.detail.note.add", "Aggiungi nota")
update_it("plant.detail.note.add.action", "Aggiungi")
update_it("plant.detail.note.delete.action", "Elimina")
update_it("plant.detail.note.delete.confirm", "Vuoi davvero eliminare la nota?")
update_it("plant.detail.note.edit", "Modifica nota")
update_it("plant.detail.note.placeholder", "Scrivi una nota...")
update_it("plant.detail.note.save", "Salva")
update_it("plant.detail.timer.set", "Imposta timer")
update_it("plant.detail.timer.cancel.action", "Annulla")
update_it("plant.detail.timer.cancel.confirm", "Vuoi davvero annullare il timer?")
update_it("plant.detail.menu.timer", "Timer")
update_it("plant.detail.timer", "Timer")
update_it("plant.detail.timer.active", "Promemoria giornaliero")

with open(file_path, "w") as f:
    json.dump(d, f, indent=2, ensure_ascii=False)

print("Patch complete.")
