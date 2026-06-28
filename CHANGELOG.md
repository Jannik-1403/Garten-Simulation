# Changelog

## 2026-06-28 - Cleanup & TikTok Integration
- **Projekt Cleanup**: Über 50 veraltete Python-/Ruby-Skripte und Logdateien aus dem Hauptverzeichnis entfernt, um das Projekt schlank zu halten.
- **Assets Cleanup**: Ungenutzte Icons, fehlerhafte KI-Bildkopien und ungenutzte Charaktere aus `Assets.xcassets` entfernt. Bonsai-Stufen und das TikTok-Logo blieben erhalten.
- **Community Einstellungen**: Neuen Bereich "Community" in `SettingsView` hinzugefügt, inklusive verlinktem TikTok-Account (`@grovy807`) mit offiziellem Logo.
- **Lokalisierung**: TikTok-Texte direkt in `Localizable.xcstrings` für alle 11 Projektsprachen hinterlegt.

## 2026-06-28 - Onboarding Flow Korrektur
- **Reihenfolge**: App-Onboarding → Tour-Prompt → Routinen-Onboarding funktioniert jetzt korrekt nach Alles-Löschen.
- **Timing-Fix**: `routineOnboardingAbgeschlossen = false` wird jetzt BEVOR der Tab-Wechsel gesetzt → `onAppear` in `RoutinenView` sieht den korrekten Zustand.

## 2026-06-28 - Onboarding Timing-Bug behoben
- **Root Cause**: `routineOnboardingAbgeschlossen` war bei Erstnutzern bereits `false` → erneutes Setzen auf `false` löste kein `onChange` aus.
- **Fix**: Erzwungener `true → false`-Toggle mit 400ms Delay garantiert, dass SwiftUI die Änderung immer erkennt.
- **Zusatz**: `onChange(of: selectedTab)` in `RoutinenView` fängt Tab-Navigation ab als zweite Absicherung.

## 2026-06-28 - Onboarding-Routing & Item3DButton Fertig-Button
- **Vorschau-Frage umgebaut**: Sowohl "Ja" als auch "Nein" leiten jetzt direkt zum Routinen-Tab (Tab 4) weiter und triggern das Routine-Onboarding sofort.
- **Fertig-Button** im Routine-Onboarding ist jetzt ein `Item3DButton` (Orange, 3D-Druckeffekt, Haptic Feedback).

## 2026-06-28 - Routine Onboarding Vollständiger Bugfix
- **Timing-Bug behoben**: Onboarding erscheint jetzt sofort nach "Alles Löschen" ohne App-Neustart (via `@State showOnboarding` + `onChange` statt reaktivem Binding).
- **Doppelte Routinen nach Reset behoben**: `customRoutinesData` wird jetzt explizit auf `Data()` gesetzt, sodass `@AppStorage` den leeren Zustand sofort erkennt.
- **Sprachwechsel-Bug behoben**: Onboarding erscheint nicht mehr ungewollt beim Wechsel der App-Sprache.
- **Fertig-Button sichtbar gemacht**: Button hat jetzt einen orangen Gradient mit Schatten, klar erkennbar.

## 2026-06-28 - Routine Onboarding UI Überarbeitung
- Routine-Karten im Onboarding nutzen jetzt den `Item3DButton` mit 3D-Druckfeedback.
- Auswahlindikator (Checkbox) ist jetzt immer einheitlich orange statt in der jeweiligen Routinen-Farbe.
- "Bearbeiten"-Text wurde durch ein rundes Stift-Icon (`pencil`) ersetzt, konsistent mit der restlichen App.

## 2026-06-28 - Routine Onboarding Bugfix
- Fehler beim Laden des Routine-Onboardings nach App-Reset behoben (Fehlende Variablen in `RoutineOnboardingView` ergänzt).
- Compiler-Timeouts in `RoutinenView` behoben, indem komplexe SwiftUI-Strukturen in Unter-Views ausgelagert wurden.
- Test-Target Fehler behoben (Projekt-Dateien wurden fälschlicherweise in `Garten_SimulationTests` und `Garten_SimulationUITests` doppelt kompiliert).

## 2026-06-28 - Entfernung inaktiver Widgets
- Das inaktive "Offene Gewohnheiten" Widget (`GroovyHabitsWidget`) wurde vollständig aus dem Projekt gelöscht.
- Die Registrierung im `WidgetBundle` wurde entfernt, sodass nur noch die Widgets für Wasserverbrauch, Streak, Wochenverlauf und Monatsverlauf verfügbar sind.
- Veraltete iOS 17 Warnung für `.onChange(of:perform:)` in `RoutinenView` behoben.
- `GENERATE_INFOPLIST_FILE` für UITests aktiviert, um Build-Fehler zu beheben.

## 2026-06-28 - Routine Onboarding & Icon Updates
- Ein neues Onboarding für Routinen (RoutineOnboardingView) wurde hinzugefügt, das nach Account-Reset oder bei leerem Profil die einfache Auswahl von vordefinierten Routinen erlaubt.
- Die Routine-Icons in der App wurden vergrößert, standardisiert (ohne festen runden Hintergrund) und an die jeweiligen Routinentypen (Morgen, Abend, Gym, Allgemein) angepasst.
- Account-Löschung setzt nun zuverlässig alle Routine-Daten und Onboarding-Status in den UserDefaults zurück.
- Alle Onboarding-Texte wurden in die `Localizable.xcstrings` ausgelagert und übersetzt.

## 2026-06-28 - Dynamische Habit-Berichte
- Entfernung des separaten 'Raum für Wachstum'-Blocks aus allen ResultViews.
- Intelligente Nutzung der bestehenden 'buildHabitsKey' und 'breakHabitsKey' für detaillierte Auswertungen.
- Die Texte für AUFBAUEN und ABBAUEN reagieren nun dynamisch auf das Profil/Score des Nutzers (z.B. perfekt = alles super, schlecht = klare Handlungsanweisungen).
- Übersetzungen für 24 verschiedene Profil-Ausprägungen in 11 Sprachen über Localizable.xcstrings ausgerollt.

## 2026-06-28
- Doppel-Benachrichtigungen erlaubt: Die Sperre (usedSlots) für Benachrichtigungen zur exakt selben Uhrzeit wurde entfernt, sodass Routine-Erinnerungen und andere gleichzeitige Gewohnheiten parallel gesendet werden.
- Routine-Benachrichtigungen lokalisiert: Die Texte nutzen jetzt String(localized:...) und wurden in alle 11 Projektsprachen in Localizable.xcstrings übersetzt.

## Widget Localization & Icons Update (2026-06-28)
- Replaced hardcoded 'drop.fill' icon with dynamic plant icon in the GroovyHabitsWidget.
- Converted all hardcoded texts in GartenWidget.swift, GroovyHabitsWidget.swift, and GroovyNewWidgetViews.swift to native String(localized:).
- Added GroovyHabitsWidget to the main WidgetBundle so it displays correctly.
- Fixed a crash in RoutineSessionView caused by the Watchdog terminating the app when running in the background with isIdleTimerDisabled enabled.
- Alles Löschen-Button im Einstellungsmenü setzt nun auch Quiz-Ergebnisse (Assessments) und geplante Benachrichtigungen korrekt zurück.

- Fix: Pluralformen für Gewohnheiten in allen 11 Sprachen korrigiert (String Catalog substitutions)

- Automatisches Zuweisen von Gewohnheiten zu Routinen beim Onboarding-Abschluss
- Bereits einer Routine zugewiesene Gewohnheiten werden bei der Erstellung/Bearbeitung anderer Routinen nicht mehr zur Auswahl angeboten

## [Export/Import Updates] - 2026-06-28
- Erweiterung von GartenSaveFile für den Export und Import der neuen Feature-Daten:
  - Lebensstand, Glücksrad-Drehungen, Seeds
  - Münz-Einnahmen, Ausgaben, Gießmenge, aktive Tage
  - Schlechte Gewohnheiten, Notizen und Coin-Transactions
  - Fokus-Sessions und dekorierte Items
  - Alle 6 Quiz-/Assessment-Ergebnisse (Finance, Mental, Growth, Health, Fitness, Lifestyle)
  - Die gespeicherten Routinen (customRoutinesData aus UserDefaults)
- Aktualisierung des DataExportImportManagers für Abwärtskompatibilität.
- AssessmentStore als EnvironmentObject in ExportImportView eingebunden.
