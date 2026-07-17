- Fixed formatting warnings for percentages in Localizable.xcstrings
- Cleaned up stale translation keys
- Ensured 100% translation coverage across all supported languages

- Neues Feature: Onboarding-Screen zur Benachrichtigungsabfrage hinzugefügt. (Bevor die rechtlichen Erklärungen akzeptiert werden, erscheint jetzt eine Abfrage im Apple-Stil, ob man Push-Benachrichtigungen erlauben möchte).

- Bugfix: Design des Notification-Mock-Dialogs im Onboarding korrigiert (Höhe der Buttons angepasst, Name zu 'Grovy' (ohne Anführungszeichen) geändert, 'Nicht erlauben' in schwarz-weiß).

- Bugfix: Mock-Notification-Dialog im Onboarding exakt in der Bildschirmmitte positioniert, sodass der echte Apple-Dialog nahtlos darüber erscheint.

- Bugfix: Weiter-Button im Notification-Onboarding erst sichtbar, nachdem eine Auswahl getroffen wurde. Animation vom Pfeil entfernt. Benachrichtigungs-Abfrage beim Erstellen eines Timers in der Pflanzen-Detail-Ansicht entfernt (wird nun exklusiv im Onboarding abgefragt).

- Design: Mock-Notification-Dialog exakt an das hochgeladene Screenshot-Design angepasst (weißer Kasten mit stark abgerundeten Ecken, linksbündiger Text, Pille-förmige graue Buttons für Erlauben/Ablehnen).

- Bugfix: Mock-Notification-Dialog schmaler gemacht, Pfeil unten als fetten (3D-ähnlichen) großen Pfeil (arrowshape.up.fill) angepasst. Alle Texte des Mock-Dialogs in 15 Sprachen übersetzt.

- Bugfix: Pfeil im Mock-Notification-Dialog im Onboarding durch den 3D-Button ('Item3DButton') ersetzt (wie im Glücksrad), inklusive des harten 3D-Schattens.

- Feature: Neues 'Screen Time' (Bildschirmzeit) Onboarding-Popup eingebaut, das exakt so aussieht wie das für Benachrichtigungen.
- Bugfix: Im Notification-Onboarding wird das Pfeil-Icon jetzt über einen ViewBuilder sicher als 'arrow.up' gerendert.
- Refactoring: Alte, verstreute Berechtigungsabfragen für Screen Time (in Focus, Routinen, etc.) gelöscht, da sie nun zentral im Onboarding stattfinden.
- Feature: In den Einstellungen wird jetzt bei 'Bildschirmzeit' ein 'Ein'/'Aus' Indikator angezeigt.

- Bugfix: Im Screen Time Mock-Dialog die Buttons und Texte exakt an das echte iOS-Design angepasst ('Weiter' links in grau, 'Nicht erlauben' rechts in blau).

- Design: Den Pfeil-Button im Onboarding durch ein echtes Pfeil-Icon ('arrowshape.up.fill') mit hartem Schatten ersetzt und den Abstand zum Button korrigiert, damit er exakt auf der richtigen Höhe ist.

- Animation: Der Pfeil im Onboarding hüpft nun flüssig auf und ab, um den Benutzer auf den Button aufmerksam zu machen.
- Design: Die Höhe (Spacing/Padding) der Mock-Dialoge wurde noch etwas reduziert (enger zusammengezogen), damit sie wirklich exakt wie die echten nativen Apple-Dialoge aussehen.
- Assessment detailed analysis implementation (Reality Check & Roadmap)
- Assessments (Dynamic Insights): Ersetzt statische Empfehlungen mit datenbasierten Insights, generiert aus User-Verhalten (Habits, Screen Time, 90 Day Challenge) sowie Einführung eines 'Reality Checks' (die harte Wahrheit) pro Kategorie.
- Added highly detailed, premium assessment analysis UI that breaks down the user's specific strengths, weaknesses, pitfalls, and benchmark comparison based on their raw scores.
- Localized and expanded all assessment insight texts in Localizable.xcstrings.

- **Assessment UI Fixes & Lokalisierung**:
  - Design-Update für die Detailansicht ("Was man verbessern kann" & DataSourceSheet) auf das einheitliche 3D-Card-Design angepasst (scoreCardStyle).
  - Alle hartkodierten deutschen Texte aus `AssessmentResult+Detailed.swift` in `Localizable.xcstrings` ausgelagert (100% Abdeckung für alle 16 Sprachen), um Sprachfehler in der Detailansicht zu beheben.
  - Fehler im Übersetzungs-Script bei un-escapeten Anführungszeichen repariert.

- **Assessment UI Bereinigung**:
  - `DataSourceSheet` (die Detailansicht) komplett gelöscht, da sie vom Nutzer als unnötig empfunden wurde.
  - Abstand (Padding) zur "Was man verbessern kann" Ansicht hinzugefügt, damit diese nicht mehr direkt am Bildschirmrand klebt.

- **Individuelle Assessment-Icons**:
  - Alle generischen iOS Icons im Bereich "Was man verbessern kann" (Insights) wurden durch maßgeschneiderte Grafiken aus dem Asset-Katalog ersetzt (z. B. `Warndreieck`, `Heart death`, `Timer empty`, etc.).
  - Die neuen Grafiken werden nun doppelt so groß dargestellt (80x80), um den transparenten Hintergrund auszugleichen. Der Text verschiebt sich dabei nicht, da der Rahmen (ZStack) fest auf 40x40 verankert bleibt und das Bild an den Ecken sauber darüber lappt.

- **Icon Layout Fixes**:
  - Den runden, farbigen Hintergrund (`Circle().fill(...)`) bei allen Icons in der Detailansicht ("Was man verbessern kann") komplett entfernt.
  - Die Icon-Größe wieder auf das normale `40x40` Format zurückgesetzt, da die SVG-Vektorgrafiken bei der verdoppelten Größe das Layout gesprengt haben.

- **Icon Scale Fix**:
  - Das `Goal` Icon (für die 90-Tage Challenge) wird nun mittels `.scaleEffect(2.2)` um den Faktor 2,2 vergrößert, ohne das restliche Layout oder den danebenstehenden Text zu verschieben.

- **Interaktiver Fokus-Button in Assessments**:
  - Der "Fokus-Modus testen" Button (in den Verbesserungstipps) ist nun ein echter animierter 3D-Button (`DuolingoButtonStyle`), der beim Drücken grafisch reagiert.
  - Wenn man den Button drückt, öffnet sich direkt das individuelle Setup für eine Fokus-Session (Generic Focus Timer), aus der heraus man direkt eine Session starten kann.

- 100% Übersetzungsabdeckung in allen Sprachen hergestellt.
- Bugfix: Zeitzonenwechsel führen nicht mehr zu unfairem Streak-Verlust (Grace Period basierend auf absoluter Zeit eingeführt).
- Bugfix: Streak-Logik erfordert nun wieder strikt das Abhaken pro Kalendertag (48h-Toleranz entfernt), berücksichtigt aber weiterhin fehlerfrei Zeitzonenwechsel.
- Bugfix: Bildschirmzeit-Gewohnheit wird nun nicht mehr automatisch gegossen, wenn noch keine Limits in den Einstellungen definiert wurden.
- Bugfix: Mehrere SwiftUI ForEach-Warnungen in der StreakView behoben, die durch nicht-eindeutige IDs entstanden sind.
- Feature: Die automatische Erledigung der Bildschirmzeit-Gewohnheit wurde komplett entfernt. Zudem wurde die Bildschirmzeit-Pflanze (Aloe Vera) aus dem Shop entfernt, da sie automatisch verwaltet wird.
- Bugfix: Aloe Vera (Bildschirmzeit-Pflanze) ist wieder regulär im Shop verfügbar.
- Bugfix: Einmaliger Reset des Bildschirmzeit-Streaks auf 0 für Nutzer, bei denen der Streak durch den alten Bug fälschlicherweise auf 1 gesetzt wurde.
- Behoben: Unübersetzte Lokalisierungsschlüssel für 'Ungenügende Daten' in der Wochenbericht-Analyse in allen Sprachen behoben
