# Changelog

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
