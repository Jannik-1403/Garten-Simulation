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
