## [2026-06-30] - PDF Export Quiz & Kategorie-Stats Fixes
- Die Quiz-Ergebnisse im PDF zeigen nun den korrekten lokalisierten Text statt dem rawValue der Datenbank an (z.B. "Ausreden-Sucher" statt "ausreden_suche").
- Bei den Quiz-Ergebnissen wird jetzt zusätzlich die Beschreibung und der Punkt "Was man verbessern kann" mit angezeigt.
- Bei den allgemeinen Statistiken wird nun die Anzahl der Gieß-Vorgänge (Mischgut/Erfahrungspunkte) pro Kategorie aufgeschlüsselt angezeigt.
- Alle neuen Strings wurden erfolgreich in alle verfügbaren Sprachen übersetzt.

## [2026-06-30] - Export UI Anpassungen
- Die Option "Gute Gewohnheiten" in den Export-Einstellungen wurde nach unten zu den restlichen Optionen verschoben.
- Der Hintergrund der Export-Konfiguration ist nun in einem dezenten Grauton gehalten, damit sich die Buttons besser abheben.
- Alle Einstellungs-Buttons haben nun eine feine Umrandung, um sich noch deutlicher vom Hintergrund abzusetzen.
- Sämtliche neuen Texte wurden in alle Sprachen übersetzt (Englisch, etc.).

## [2026-06-30] - Fokus Session Metadaten
- `FocusSessionLog` erweitert, um festzuhalten, ob es sich um eine Routine oder normale Gewohnheit handelt, inklusive verknüpfter Aufgaben/Todos.
- PDF-Export Manager liest die neuen Fokus-Session Daten aus und stellt diese im Bericht dar (mit Gewohnheitsnamen und Aufgaben).
- PDF-Export zeigt nun bei den Routinen auch die Historie an (wann welche Routine abgeschlossen wurde).
- Übersetzungen mit dem Python-Script in `Localizable.xcstrings` aktualisiert.

## [2026-06-30] - UI & Export Updates
- Gute Gewohnheiten sind im PDF-Export nun standardmäßig deaktiviert, können aber über einen Toggle aktiviert werden.
- Der `Item3DButton` hat nun eine dezente Kontur erhalten, um Ränder besser sichtbar zu machen.
- Der Button "PDF generieren" nutzt nun das einheitliche `Item3DButton`-Design.
- Das Schließen-X oben rechts ist jetzt dicker (`.heavy`) und komplett schwarz.

## [2026-06-30] - PDF Export Refactor
- Modulare PDF-Generierung für Notizen, Statistiken, Timer, schlechte Gewohnheiten, Quizzes und Routinen eingebaut.
- `ImageRenderer` für Quiz Ergebnisse eingebaut, um diese als Bilder im PDF zu zeigen.
- Lange Streaks für schlechte Gewohnheiten kalkuliert und im PDF hinzugefügt.
- UI Refactoring der Export-Seite mit nativem Design und `NavigationStack` umgesetzt.
- Lokalisierungs-Updates in der `Localizable.xcstrings` durchgeführt.
- Sämtliche Tests im Terminal bestehen erfolgreich.

### Routine UI & Syntax Fix
- Ein Syntaxfehler in PflanzeDetailSheet (fehlende Klammer) wurde behoben.
- Routinen zeigen nun an, wenn Gewohnheiten heute bereits erledigt wurden, und vergeben keine doppelten Belohnungen.


### Assessment "1% Marginal Gains" Updates
- Sämtliche Texte für aufzubauende (Plus) und abzulegende (Minus) Gewohnheiten in den 24 Assessment-Profilen wurden nach der "1% Marginal Gains" Methode umgeschrieben.
- Die Texte fokussieren sich jetzt auf extreme Mini-Habits (z.B. "15 Sekunden kalt duschen", "1 Kreditkarte aus Autofill löschen"), anstatt unüberwindbare Aufgaben zu verlangen.
- Alle 11 Sprachen wurden entsprechend aktualisiert.

### Assessment Re-Refactoring (3-Kategorien-Profilsystem)
- Single-Score Bewertung wurde rückgängig gemacht. Das Quiz-System nutzt wieder die 3-Achsen-Bewertung (z.B. Kontrolle, Entscheidung, Risiko).
- Die 24 verschiedenen Profile wurden beibehalten und mit extrem personalisierten und ausführlichen Texten in allen 11 Sprachen angereichert.
- Nutzer erhalten nun bei jedem Ergebnis detaillierte Erklärungen, welche Gewohnheiten sie aufbauen und welche sie ablegen sollten.
- Die 3 Bewertungsbalken pro Kategorie werden wieder im UI angezeigt.

### Assessment Single-Score Refactoring
- Alle 6 Assessments (Finance, Mental, Growth, Health, Fitness, Lifestyle) verwenden nun ein einheitliches Single-Score System.
- Die komplexen 3-Achsen Scores wurden auf einen einzigen integer Score reduziert (Minuspunkte, Pluspunkte).
- Das Ergebnis wird nun in 4 Leveln kategorisiert (Level 1 bis Level 4).
- Alle Profile und Result-Views wurden aktualisiert, um nur noch den Gesamtscore (Total Score) anzuzeigen.
- Lokalisierungen für alle 11 Sprachen für die neuen Level 1-4 wurden hinzugefügt.

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

## [Native Close Button für Quiz-Ergebnisse] - 2026-06-28
- 'X'-Button (LiquidGlassDismissButton) im Profil/Quizbereich hat nun ein natives iOS-Design.
- Das Overlay für den Dismiss-Button wird nun absolut platziert und überlagert nicht mehr mit der versteckten Navigationsleiste, was Fehler bei der Sichtbarkeit behebt.

## [Native Close Button für Quiz-Ergebnisse Fix] - 2026-06-28
- Komplett zurück auf Standard-iOS-Ansicht: NavigationBar bleibt erhalten und nutzt ein natives ToolbarItem (grauer Kreis mit 'X'), damit der Inhalt nicht unschön nach oben in die Statusleiste rutscht.

## 2026-06-29 - String Catalog Build-Fehler Behebung
- Behoben: Xcode Build-Fehler aufgrund von ungültigen Format-Specifiern (`%-S`, `%-D`, `%-F`, etc.) in `Localizable.xcstrings` repariert, die Abstürze bei der Swift-Typgenerierung verursacht haben.
- Mismatched positional format arguments (z.B. `%d` und `%@`) repariert, sodass Lokalisierungen mit re-geordneten Parametern sauber kompilieren (z.B. `%1$@`).
- Alle Unit- und UI-Tests durchlaufen wieder erfolgreich.
- Fehlerhafte, rohe Lokalisierungsschlüssel wurden im Code durch standardisierte Schlüssel ersetzt (z.B. `focus.session.start`).
- Ungenutzte Rohtexte wurden aus dem `Localizable.xcstrings` Katalog bereinigt.
- Fehlende Übersetzungen (besonders im Türkischen für Sonderzeichen und Platzhalter) wurden automatisiert ergänzt, um 100% Übersetzungsabdeckung zu gewährleisten.
- Alle ausstehenden und fehlenden String-Einträge in sämtlichen 11 Sprachen wurden vollautomatisiert aufgefüllt. Es wurden gezielt vorhandene Übersetzungen aus `AppStrings.swift` verwendet. 
- Platzhalter (wie `%lld` oder leere Zeichen) wurden in die jeweilige Übersetzung übernommen, sodass die Xcode-Lokalisierungsanzeige jetzt für alle Sprachen zuverlässig bei 100% steht.

## 2026-06-29 - Schlechte Gewohnheiten Drag-and-Drop
- Die Darstellung von schlechten Gewohnheiten (Trash) auf der Startseite wurde von einer horizontalen Liste auf ein Grid-Layout (`LazyVGrid`) umgestellt, ähnlich wie bei den guten Gewohnheiten (`PflanzenCard`).
- Ein neues `BadHabitCard` UI-Element wurde eingeführt.
- Schlechte Gewohnheiten unterstützen nun Drag-and-Drop: Zieht man das `SchlechteGewohnheitKreuz` auf die Karte, öffnet sich das Sheet zum Melden eines Rückfalls (`TriggerSelectionSheet`). Das Kreuz springt nach dem Loslassen sofort zurück und bleibt nutzbar.
- Der graue Timer-Hintergrundkreis wurde bei `BadHabitCard` entfernt und der Icon-Button wurde Rot gefärbt.
- Ein Zähler (rotes Badge) oben rechts an der BadHabitCard zeigt nun an, wie oft man am heutigen Tag bereits rückfällig wurde.
- Die horizontale Breite der BadHabitCard-Elemente im Grid wurde exakt an die Breite der PflanzenCard-Elemente angepasst.

- Updated coin amounts in shop translations to match actual received values (500, 1800, 3500) for all languages.

## 2026-06-29 - Routine Timer Edit
- Routine Timer: 'Alle Tage gleich machen' Option über die drei Punkte (...) oben rechts im Timer-Edit-Screen hinzugefügt.
- Routine-Abschluss überarbeitet: Gewohnheiten werden korrekt bewässert und bringen exakt die erwarteten Münzen/XP, ohne Timer-Boni.
- Gewohnheiten werden im Routine-Onboarding nicht mehr automatisch hinzugefügt.
- Routine-Icons in der Session-Ansicht (Intro) vergrößert.
- Routine-Icons aus der Listenansicht links entfernt.
- Plural-/Singular-Logik für Gewohnheiten in der Routine-Ansicht korrigiert.
- Fehlerhafte Routine-Icons (GymRoutine etc.) gefixt.
- **Fix (Bad Habits & Localization):** Im Garten-Inventar wird bei schlechten Gewohnheiten nun korrekterweise "Schlechte Gewohnheiten" als Untertitel statt "Dekoration" angezeigt.
- **Fix (Bad Habits & Localization):** Der harte Text für das "Schlechte Gewohnheit"-Label in der `BadHabitCard` wurde in `Localizable.xcstrings` ausgelagert und in alle 11 Projektsprachen übersetzt.
- **Fix (Localization):** Die rohen Schlüssel für Beschreibungen und Objektbeschreibungen bei "Unnötig online geshoppt" (`trash.online_shopping_app.desc` und `trash.online_shopping_app.obj_desc`) wurden repariert und in alle 11 Projektsprachen übersetzt.
- Refactored Timer UI in PflanzeDetailSheet and RoutinenView to use a fullscreen edit view and added an 'Apply to all days' toggle button.
- Syntax Error (Missing brace) in PflanzeDetailSheet behoben.
- Compile-Warnung (var zu let) in RoutineOnboardingView behoben.

## PDF Notiz-Export Feature
- `PDFExportManager.swift` hinzugefügt, um aus allen Notizen der App ein strukturiertes PDF zu generieren.
- Ein globaler Export-Button wurde in der `PflanzeDetailSheet` und der `InventoryItemDetailSheet` (für Schlechte Gewohnheiten) neben dem "Notizen"-Header ergänzt.
- Neue Lokalisierungsschlüssel für den PDF-Export in `Localizable.xcstrings` hinterlegt und in alle Sprachen übersetzt.
- UI: Info-Button und Erklärungssheet für 'Schlechte Gewohnheiten' im Shop entfernt.
- **Export Selection Sheet:** Ein natives "Drei-Punkte-Menü" wurde in der oberen linken Ecke der Detailansichten (`PflanzeDetailSheet` & `InventoryItemDetailSheet`) eingeführt.
- **Benutzerdefinierter Export:** Anwender können nun zwischen "Gesamte App", "Nur dieser Eintrag" und "Benutzerdefiniert" wählen. Bei benutzerdefiniert lassen sich spezifische Gewohnheiten und schlechte Gewohnheiten gezielt für den Export via Checkboxen aus- und abwählen.
- UI: Info-Button und Erklärungssheet 'Schlechte Gewohnheiten' im Shop vollständig entfernt.

## 30.06.2026
- Export Button aus PflanzeDetailSheet und InventoryItemDetailSheet entfernt.
- In den Einstellungen unter Profil einen neuen PDF Export Konfigurator hinzugefügt.
- Beim Gießen (manuell oder durch Routine) wird nun automatisch eine Notiz angelegt.
- Die exportierte PDF enthält nun umfassende Daten: Gute/Schlechte Gewohnheiten, Statistiken, Quiz Ergebnisse, Fokus Zeit und Routinen.

- Lokalisierungs-Fix: Die Anzeige der rohen Kategorie-Schlüssel (z. B. 'character.category.body') in den Charakter-Einstellungen (CharacterCustomizationView) wurde repariert und verwendet nun  mit Standardwerten sowie echten Übersetzungen.
- Lokalisierungs-Fix: Die Anzeige der rohen Kategorie-Schlüssel (z. B. 'character.category.body') in den Charakter-Einstellungen (CharacterCustomizationView) wurde repariert und verwendet nun `String(localized: ...)` mit Standardwerten sowie echten Übersetzungen in 11 Sprachen.
