import Foundation

struct NotificationTexts {

    // MARK: - Individuelle Pflanzen-Erinnerung

    static func pflanzeErinnerung(pflanzenName: String) -> (title: String, body: String) {
        let lang = Locale.current.language.languageCode?.identifier ?? "de"
        let variant = Int.random(in: 1...5)
        switch lang {
        case "de":
            return deErinnerung(pflanzenName: pflanzenName, variant: variant)
        case "es":
            return esErinnerung(pflanzenName: pflanzenName, variant: variant)
        case "fr":
            return frErinnerung(pflanzenName: pflanzenName, variant: variant)
        case "it":
            return itErinnerung(pflanzenName: pflanzenName, variant: variant)
        case "pt":
            return ptErinnerung(pflanzenName: pflanzenName, variant: variant)
        default:
            return enErinnerung(pflanzenName: pflanzenName, variant: variant)
        }
    }

    // MARK: - Globale Abend-Erinnerung

    static func abendeErinnerung(anzahlPflanzen: Int) -> (title: String, body: String) {
        let lang = Locale.current.language.languageCode?.identifier ?? "de"
        switch lang {
        case "de":
            if anzahlPflanzen == 1 {
                return ("Nicht vergessen!", "Deine Pflanze wartet noch auf dich. Kurz gießen – Streak bleibt!")
            } else {
                return ("Noch \(anzahlPflanzen) Pflanzen", "\(anzahlPflanzen) Pflanzen warten noch auf Wasser. Jetzt gießen!")
            }
        case "es":
            if anzahlPflanzen == 1 {
                return ("¡No olvides!", "Tu planta todavía te espera. ¡Riégala para mantener tu racha!")
            } else {
                return ("\(anzahlPflanzen) plantas esperan", "\(anzahlPflanzen) plantas aún necesitan agua. ¡Riégalas ahora!")
            }
        case "fr":
            if anzahlPflanzen == 1 {
                return ("N'oublie pas !", "Ta plante t'attend encore. Arrose-la pour garder ta série !")
            } else {
                return ("\(anzahlPflanzen) plantes attendent", "\(anzahlPflanzen) plantes ont encore besoin d'eau. Arrose maintenant !")
            }
        case "it":
            if anzahlPflanzen == 1 {
                return ("Non dimenticare!", "La tua pianta ti sta ancora aspettando. Innaffiala per mantenere la serie!")
            } else {
                return ("\(anzahlPflanzen) piante aspettano", "\(anzahlPflanzen) piante hanno ancora bisogno d'acqua. Innaffia ora!")
            }
        case "pt":
            if anzahlPflanzen == 1 {
                return ("Não esqueças!", "A tua planta ainda te espera. Rega agora para manter a sequência!")
            } else {
                return ("\(anzahlPflanzen) plantas esperam", "\(anzahlPflanzen) plantas ainda precisam de água. Rega agora!")
            }
        default: // en
            if anzahlPflanzen == 1 {
                return ("Don't forget!", "Your plant is still waiting. Water it to keep your streak!")
            } else {
                return ("\(anzahlPflanzen) plants waiting", "\(anzahlPflanzen) plants still need water. Water them now!")
            }
        }
    }

    // MARK: - German Variants

    private static func deErinnerung(pflanzenName: String, variant: Int) -> (title: String, body: String) {
        switch variant {
        case 1:
            return ("Zeit zu gießen!", "\(pflanzenName) wartet auf dich. Gib ihr heute noch etwas Wasser!")
        case 2:
            return ("\(pflanzenName) hat Durst", "Deine Pflanze braucht dich! Gieß sie jetzt und erhalte deinen Streak.")
        case 3:
            return ("Garten-Erinnerung", "\(pflanzenName) möchte heute noch gegossen werden. Dein Streak zählt auf dich!")
        case 4:
            return ("Streakgefahr!", "Nicht vergessen: \(pflanzenName) wartet noch. Gieße jetzt und sichere deinen Streak!")
        default:
            return ("\(pflanzenName) ruft!", "Deine Pflanze braucht heute noch Wasser. Los geht's!")
        }
    }

    // MARK: - English Variants

    private static func enErinnerung(pflanzenName: String, variant: Int) -> (title: String, body: String) {
        switch variant {
        case 1:
            return ("Time to water!", "\(pflanzenName) is waiting for you. Give it some water today!")
        case 2:
            return ("\(pflanzenName) is thirsty", "Your plant needs you! Water it now and keep your streak.")
        case 3:
            return ("Garden reminder", "\(pflanzenName) still needs watering today. Your streak is counting on you!")
        case 4:
            return ("Streak alert!", "Don't forget: \(pflanzenName) is waiting. Water now and protect your streak!")
        default:
            return ("\(pflanzenName) is calling!", "Your plant needs water today. Let's go!")
        }
    }

    // MARK: - Spanish Variants

    private static func esErinnerung(pflanzenName: String, variant: Int) -> (title: String, body: String) {
        switch variant {
        case 1:
            return ("¡Hora de regar!", "\(pflanzenName) te espera. ¡Dale un poco de agua hoy!")
        case 2:
            return ("\(pflanzenName) tiene sed", "¡Tu planta te necesita! Riégala ahora y mantén tu racha.")
        case 3:
            return ("Recordatorio del jardín", "\(pflanzenName) aún necesita agua hoy. ¡Tu racha depende de ti!")
        case 4:
            return ("¡Alerta de racha!", "No olvides: \(pflanzenName) espera. ¡Riega ahora y protege tu racha!")
        default:
            return ("¡\(pflanzenName) te llama!", "Tu planta necesita agua hoy. ¡Vamos!")
        }
    }

    // MARK: - French Variants

    private static func frErinnerung(pflanzenName: String, variant: Int) -> (title: String, body: String) {
        switch variant {
        case 1:
            return ("Heure d'arroser !", "\(pflanzenName) t'attend. Donne-lui un peu d'eau aujourd'hui !")
        case 2:
            return ("\(pflanzenName) a soif", "Ta plante a besoin de toi ! Arrose-la maintenant et garde ta série.")
        case 3:
            return ("Rappel jardin", "\(pflanzenName) a encore besoin d'être arrosée. Ta série compte sur toi !")
        case 4:
            return ("Alerte série !", "N'oublie pas : \(pflanzenName) attend. Arrose maintenant et protège ta série !")
        default:
            return ("\(pflanzenName) t'appelle !", "Ta plante a besoin d'eau aujourd'hui. Allons-y !")
        }
    }

    // MARK: - Italian Variants

    private static func itErinnerung(pflanzenName: String, variant: Int) -> (title: String, body: String) {
        switch variant {
        case 1:
            return ("È ora di innaffiare!", "\(pflanzenName) ti sta aspettando. Dagle un po' d'acqua oggi!")
        case 2:
            return ("\(pflanzenName) ha sete", "La tua pianta ha bisogno di te! Innaffiala ora e mantieni la tua serie.")
        case 3:
            return ("Promemoria giardino", "\(pflanzenName) ha ancora bisogno di acqua. La tua serie conta su di te!")
        case 4:
            return ("Allerta serie!", "Non dimenticare: \(pflanzenName) aspetta. Innaffia ora e proteggi la tua serie!")
        default:
            return ("\(pflanzenName) ti chiama!", "La tua pianta ha bisogno di acqua oggi. Dai!")
        }
    }

    // MARK: - Portuguese Variants

    private static func ptErinnerung(pflanzenName: String, variant: Int) -> (title: String, body: String) {
        switch variant {
        case 1:
            return ("Hora de regar!", "\(pflanzenName) está à tua espera. Dá-lhe um pouco de água hoje!")
        case 2:
            return ("\(pflanzenName) tem sede", "A tua planta precisa de ti! Rega agora e mantém a tua sequência.")
        case 3:
            return ("Lembrete do jardim", "\(pflanzenName) ainda precisa de rega hoje. A tua sequência conta contigo!")
        case 4:
            return ("Alerta de sequência!", "Não esqueças: \(pflanzenName) espera. Rega agora e protege a tua sequência!")
        default:
            return ("\(pflanzenName) está a chamar!", "A tua planta precisa de água hoje. Vamos lá!")
        }
    }

    // MARK: - Legacy (kept for any remaining callers)

    static func wartet(pflanzenName: String, stunden: Int) -> (title: String, body: String) {
        return pflanzeErinnerung(pflanzenName: pflanzenName)
    }

    static func streakGefahr(pflanzenName: String, streak: Int) -> (title: String, body: String) {
        return pflanzeErinnerung(pflanzenName: pflanzenName)
    }

    static func morgenMotivation(streak: Int) -> (title: String, body: String) {
        return ("🌅 Guten Morgen!", "Heute ist ein neuer Tag. Vergiss deine Pflanzen nicht!")
    }

    static func stillerAbend(anzahlUngegossen: Int) -> (title: String, body: String) {
        return abendeErinnerung(anzahlPflanzen: anzahlUngegossen)
    }
}
