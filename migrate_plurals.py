import json
import os

XCSTRINGS_PATH = "Garten_Simulation/Localizable.xcstrings"

with open(XCSTRINGS_PATH, "r", encoding="utf-8") as f:
    data = json.load(f)

def make_plural_single_arg(key, specifier, variations_by_lang):
    if key not in data["strings"]:
        data["strings"][key] = {"extractionState": "manual", "localizations": {}}
        
    for lang, variations in variations_by_lang.items():
        base_value = variations.get("other", list(variations.values())[0])
        loc = {
            "stringUnit": {
                "state": "translated",
                "value": base_value.replace("%arg1$lld", "%lld").replace("%arg1$d", "%d")
            },
            "substitutions": {
                "arg1": {
                    "argNum": 1,
                    "formatSpecifier": specifier,
                    "variations": {
                        "plural": {}
                    }
                }
            }
        }
        
        for rule, text in variations.items():
            loc["substitutions"]["arg1"]["variations"]["plural"][rule] = {
                "stringUnit": {
                    "state": "translated",
                    "value": text
                }
            }
            
        data["strings"][key]["localizations"][lang] = loc

def make_plural_multi_arg(key, format_specifiers, plural_arg_name, plural_arg_num, variations_by_lang):
    if key not in data["strings"]:
        data["strings"][key] = {"extractionState": "manual", "localizations": {}}
        
    for lang, variations in variations_by_lang.items():
        base_value = variations.get("other", list(variations.values())[0])
        subs = {}
        for arg_name, (arg_num, spec) in format_specifiers.items():
            if arg_name == plural_arg_name:
                subs[arg_name] = {
                    "argNum": arg_num,
                    "formatSpecifier": spec,
                    "variations": {
                        "plural": {}
                    }
                }
                for rule, text in variations.items():
                    subs[arg_name]["variations"]["plural"][rule] = {
                        "stringUnit": {
                            "state": "translated",
                            "value": text
                        }
                    }
        
        data["strings"][key]["localizations"][lang] = {
            "stringUnit": {
                "state": "translated",
                "value": base_value.replace("%arg1$d", "%d").replace("%arg2$d", "%d")
            },
            "substitutions": subs
        }

# 1. routine.session.ready.subtitle (%lld)
routine_subs = {
    "de": {"one": "%arg1$lld Gewohnheit. Bereit?", "other": "%arg1$lld Gewohnheiten. Bereit?"},
    "en": {"one": "%arg1$lld habit. Ready?", "other": "%arg1$lld habits. Ready?"},
    "es": {"one": "%arg1$lld hábito. ¿Listo?", "other": "%arg1$lld hábitos. ¿Listo?"},
    "fr": {"one": "%arg1$lld habitude. Prêt ?", "other": "%arg1$lld habitudes. Prêt ?"},
    "it": {"one": "%arg1$lld abitudine. Pronto?", "other": "%arg1$lld abitudini. Pronto?"},
    "ja": {"other": "%arg1$lldの習慣。準備はいいですか？"},
    "ko": {"other": "%arg1$lld개의 습관. 준비되셨나요?"},
    "nl": {"one": "%arg1$lld gewoonte. Klaar?", "other": "%arg1$lld gewoontes. Klaar?"},
    "pl": {"one": "%arg1$lld nawyk. Gotowy?", "few": "%arg1$lld nawyki. Gotowy?", "many": "%arg1$lld nawyków. Gotowy?", "other": "%arg1$lld nawyków. Gotowy?"},
    "pt": {"one": "%arg1$lld hábito. Pronto?", "other": "%arg1$lld hábitos. Pronto?"},
    "tr": {"other": "%arg1$lld alışkanlık. Hazır mısın?"}
}
make_plural_single_arg("routine.session.ready.subtitle", "lld", routine_subs)

# 2. garden.habits.active (%d)
active_subs = {
    "de": {"one": "%arg1$d aktive Gewohnheit", "other": "%arg1$d aktive Gewohnheiten"},
    "en": {"one": "%arg1$d habit active", "other": "%arg1$d habits active"},
    "es": {"one": "%arg1$d hábito activo", "other": "%arg1$d hábitos activos"},
    "fr": {"one": "%arg1$d habitude active", "other": "%arg1$d habitudes actives"},
    "it": {"one": "%arg1$d abitudine attiva", "other": "%arg1$d abitudini attive"},
    "ja": {"other": "%arg1$d 個の習慣がアクティブです"},
    "ko": {"other": "활동 중인 습관 %arg1$d개"},
    "nl": {"one": "%arg1$d gewoonte actief", "other": "%arg1$d gewoonten actief"},
    "pl": {"one": "%arg1$d aktywny nawyk", "few": "%arg1$d aktywne nawyki", "many": "%arg1$d aktywnych nawyków", "other": "%arg1$d aktywnych nawyków"},
    "pt": {"one": "%arg1$d hábito ativo", "other": "%arg1$d hábitos ativos"},
    "tr": {"other": "%arg1$d aktif alışkanlık"}
}
make_plural_single_arg("garden.habits.active", "d", active_subs)

# 3. weed.detail.beschreibung (%d)
weed_desc_subs = {
    "de": {"one": "Oh nein! Um dieses Unkraut zu entfernen, musst du heute %arg1$d Gewohnheit abschließen.", "other": "Oh nein! Um dieses Unkraut zu entfernen, musst du heute %arg1$d Gewohnheiten abschließen."},
    "en": {"one": "Oh no! Complete %arg1$d habit today to remove this weed.", "other": "Oh no! Complete %arg1$d habits today to remove this weed."},
    "es": {"one": "¡Oh no! Completa %arg1$d hábito hoy para eliminar estas malas hierbas.", "other": "¡Oh no! Completa %arg1$d hábitos hoy para eliminar estas malas hierbas."},
    "fr": {"one": "Oh non ! Complète %arg1$d habitude aujourd'hui pour retirer ces mauvaises herbes.", "other": "Oh non ! Complète %arg1$d habitudes aujourd'hui pour retirer ces mauvaises herbes."},
    "it": {"one": "Oh no! Completa %arg1$d abitudine oggi per rimuovere queste erbacce.", "other": "Oh no! Completa %arg1$d abitudini oggi per rimuovere queste erbacce."},
    "ja": {"other": "なんてこった！この雑草を除去するには、今日 %arg1$d 個の習慣を完了してください。"},
    "ko": {"other": "안 돼! 이 잡초를 제거하려면 오늘 %arg1$d개의 습관을 완료하세요."},
    "nl": {"one": "O nee! Voltooi vandaag nog %arg1$d gewoonte om dit onkruid te verwijderen.", "other": "O nee! Voltooi vandaag nog %arg1$d gewoonten om dit onkruid te verwijderen."},
    "pl": {"one": "O nie! Ukończ dzisiaj %arg1$d nawyk, aby usunąć tego chwasta.", "few": "O nie! Ukończ dzisiaj %arg1$d nawyki, aby usunąć tego chwasta.", "many": "O nie! Ukończ dzisiaj %arg1$d nawyków, aby usunąć tego chwasta.", "other": "O nie! Ukończ dzisiaj %arg1$d nawyków, aby usunąć tego chwasta."},
    "pt": {"one": "Oh não! Completa %arg1$d hábito hoje para remover estas ervas daninhas.", "other": "Oh não! Completa %arg1$d hábitos hoje para remover estas ervas daninhas."},
    "tr": {"other": "Ah hayır! Bu otu ortadan kaldırmak için bugün %arg1$d alışkanlığı tamamlayın."}
}
make_plural_single_arg("weed.detail.beschreibung", "d", weed_desc_subs)

# 4. weed_popup_body (%d, %d)
weed_popup_subs = {
    "de": {"one": "Unkraut blockiert deine Pflanzen – nur %arg1$d%% XP pro Gießen. Erledige %arg2$d Gewohnheit für das aktuelle Unkraut – oder zahle Coins.", "other": "Unkraut blockiert deine Pflanzen – nur %arg1$d%% XP pro Gießen. Erledige %arg2$d Gewohnheiten für das aktuelle Unkraut – oder zahle Coins."},
    "en": {"one": "Weeds block your plants – only %arg1$d%% XP per watering. Complete %arg2$d habit for the current weed – or pay coins.", "other": "Weeds block your plants – only %arg1$d%% XP per watering. Complete %arg2$d habits for the current weed – or pay coins."},
    "es": {"one": "Las malas hierbas bloquean tus plantas – solo %arg1$d%% de XP por riego. Completa %arg2$d hábito para la actual – o paga monedas.", "other": "Las malas hierbas bloquean tus plantas – solo %arg1$d%% de XP por riego. Completa %arg2$d hábitos para la actual – o paga monedas."},
    "fr": {"one": "Les mauvaises herbes bloquent tes plantes – seulement %arg1$d%% d'XP par arrosage. Accomplis %arg2$d habitude pour celle en cours – ou paye des pièces.", "other": "Les mauvaises herbes bloquent tes plantes – seulement %arg1$d%% d'XP par arrosage. Accomplis %arg2$d habitudes pour celle en cours – ou paye des pièces."},
    "it": {"one": "Le erbacce bloccano le tue piante – solo %arg1$d%% XP per annaffiatura. Completa %arg2$d abitudine per quella attuale – o paga monete.", "other": "Le erbacce bloccano le tue piante – solo %arg1$d%% XP per annaffiatura. Completa %arg2$d abitudini per quella attuale – o paga monete."},
    "ja": {"other": "雑草が植物の邪魔をします - 水やりあたりの XP はわずか %arg1$d%% です。現在の大麻の %arg2$d 個の習慣を完了するか、コインを支払います。"},
    "ko": {"other": "잡초가 식물을 막습니다. 물을 뿌릴 때마다 %arg1$d%% XP만 제공됩니다. 현재 잡초에 대해 %arg2$d개의 습관을 완료하거나 코인을 지불하세요."},
    "nl": {"one": "Onkruid blokkeert je planten – slechts %arg1$d%% XP per gietbeurt. Voltooi %arg2$d gewoonte voor de huidige wiet – of betaal munten.", "other": "Onkruid blokkeert je planten – slechts %arg1$d%% XP per gietbeurt. Voltooi %arg2$d gewoonten voor de huidige wiet – of betaal munten."},
    "pl": {"one": "Chwasty blokują Twoje rośliny – tylko %arg1$d%% XP na podlewanie. Ukończ %arg2$d nawyk dla bieżącego zioła – lub zapłać monetami.", "few": "Chwasty blokują Twoje rośliny – tylko %arg1$d%% XP na podlewanie. Ukończ %arg2$d nawyki dla bieżącego zioła – lub zapłać monetami.", "many": "Chwasty blokują Twoje rośliny – tylko %arg1$d%% XP na podlewanie. Ukończ %arg2$d nawyków dla bieżącego zioła – lub zapłać monetami.", "other": "Chwasty blokują Twoje rośliny – tylko %arg1$d%% XP na podlewanie. Ukończ %arg2$d nawyków dla bieżącego zioła – lub zapłać monetami."},
    "pt": {"one": "As ervas daninhas bloqueiam as tuas plantas – só %arg1$d%% de XP por rega. Completa %arg2$d hábito para a atual – ou paga moedas.", "other": "As ervas daninhas bloqueiam as tuas plantas – só %arg1$d%% de XP por rega. Completa %arg2$d hábitos para a atual – ou paga moedas."},
    "tr": {"other": "Yabani otlar bitkilerinizi engeller; sulama başına yalnızca %arg1$d%% XP. Mevcut ot için %arg2$d alışkanlığı tamamlayın veya jeton ödeyin."}
}

format_specs = {
    "arg1": (1, "d"),
    "arg2": (2, "d")
}
make_plural_multi_arg("weed_popup_body", format_specs, "arg2", 2, weed_popup_subs)

with open(XCSTRINGS_PATH, "w", encoding="utf-8") as f:
    json.dump(data, f, indent=2, ensure_ascii=False)

print("Migration successful.")
