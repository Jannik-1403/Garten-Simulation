- Zielgewicht kann nun auch ohne die Pflanze 'Krafttraining' eingegeben werden.
- Die eingegebenen Zieldaten werden automatisch mit der Pflanze verknüpft, sobald diese im Shop gekauft wird.
- Der 'Ziel ändern' Button ist nicht mehr deaktiviert und der Text wurde korrekt in alle Sprachen übersetzt.
- Englische Texte in den Kalorien- und Gewichtsziel-Einstellungen wurden nun erfolgreich in alle verfügbaren Sprachen übersetzt.
- In den Entwickler-Optionen (Developer Options) gibt es nun einen Cheat-Button, um 100.000 Münzen hinzuzufügen.
- Alle zuletzt hinzugefügten Texte wurden in die restlichen Projektsprachen (Türkisch, Japanisch, Koreanisch, etc.) übersetzt, sodass wieder 100% Abdeckung herrscht.
- **Bildschirmzeit-Übersetzung:** Der standardmäßige "Choose Activities"-Titel beim Screen Time Picker wurde durch eine lokalisierte Version ersetzt ("Apps auswählen" im Deutschen), sodass dieser jetzt ebenfalls in allen 16 unterstützten Sprachen korrekt übersetzt wird.

## [2026-09-27] – Routine-Start-Widget

- Neues `GroovyRoutineStartWidget` (Small) hinzugefügt
- Widget zeigt: "Routine starten" (Header), Emoji-Icon, Routine-Name, Play-Button
- Tap auf Widget öffnet direkt die RoutineSessionView der konfigurierten Routine
- Deep Link `grovy://routines?routineId=<uuid>` in App-URL-Handler eingebaut
- `pendingRoutineStartID` im GardenStore als Brücke zwischen Widget-Tap und RoutinenView
- `handlePendingRoutineStart()` in RoutinenView startet Routine automatisch als FullScreenCover
- 4 neue Lokalisierungs-Keys in 16 Sprachen (de, en, es, fr, hi, it, ja, ko, nl, pl, pt, pt-BR, ru, tr, zh-Hans, zh-Hant)
