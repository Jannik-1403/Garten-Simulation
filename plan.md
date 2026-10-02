# Architektur-Plan: Echtes Paging & Habit-Zeitreise

## 1. Paging mit ScrollView (iOS 17+)
Um das gewünschte, fließende "Mitziehen"-Gefühl (wie eine `TabView`, die zwischen den Fingern verweilt) zu bekommen, stellen wir die Struktur von `GartenView` auf ein `ScrollView(.horizontal)` mit `.scrollTargetBehavior(.paging)` um. 
- Wir generieren ein Array von z.B. 100 vergangenen Tagen `[-100 ... 0]`.
- Jede Page enthält das gesamte Layout (`mainContentView`) für das spezifische Datum.
- `.scrollPosition(id: $currentDayOffset)` hält automatisch das Datum synchron mit der DailyScore Karte oben.

## 2. Habit-Zeitreise (`wasCompleted(on:)`)
Damit die Habits "von gestern" korrekt angezeigt werden, müssen wir ihr Modell erweitern:
- Statt auf das heutige `isCompleted` zuzugreifen, geben wir jeder `PflanzenCard` das `targetDate` der jeweiligen Page mit.
- `HabitModel` bekommt eine Funktion `wasCompleted(on: Date) -> Bool`.
- Diese prüft das `gekauftAm`-Datum: Ist das Target-Datum VOR der Existenz der App/Pflanze, wird die Karte als "grau" (oder deaktiviert/inaktiv) dargestellt.
- Das Abhaken in der Vergangenheit muss entweder gesperrt werden (nur Historie ansehen), oder es trägt das Datum explizit in die `wateringDates` der Vergangenheit ein.

## Herausforderungen:
- Die aktuelle Architektur (`GartenStore` und `HabitModel`) ist hart auf `Date()` (Heute) ausgelegt.
- Das Paging der kompletten Startseite erfordert ein Restrukturieren von `GartenView` (das ist eine 750 Zeilen Datei), in der wir den `ScrollView` Body in eine extra Subview `GartenPageView` auslagern müssen, damit jede Page ihren eigenen Kontext (`targetDate`) hat.
