import Foundation
import UserNotifications

@Observable
class NotificationManager {
    var isAuthorized = false
    var morningHour: Int = 8
    var morningMinute: Int = 0

    private let hourKey = "notif_morning_hour"
    private let minuteKey = "notif_morning_minute"
    private static let reEngagementID = "re_engagement"

    init() {
        morningHour = UserDefaults.standard.object(forKey: hourKey) as? Int ?? 8
        morningMinute = UserDefaults.standard.object(forKey: minuteKey) as? Int ?? 0
        checkAuthorization()
    }

    // MARK: - Request permission

    func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, _ in
            DispatchQueue.main.async {
                self.isAuthorized = granted
                if granted {
                    AnalyticsManager.notificationPermissionGranted()
                    self.scheduleDailyNotifications()
                    self.scheduleReEngagementNotification()
                } else {
                    AnalyticsManager.notificationPermissionDenied()
                }
            }
        }
    }

    func checkAuthorization() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                self.isAuthorized = settings.authorizationStatus == .authorized
                if self.isAuthorized {
                    self.resetReEngagement()
                }
            }
        }
    }

    // MARK: - Daily notifications

    func scheduleDailyNotifications() {
        // Удаляем только daily_wisdom_*, не трогаем re_engagement
        let dailyIDs = (0..<7).map { "daily_wisdom_\($0)" }
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: dailyIDs)

        let quotes = Self.notificationQuotes.shuffled()

        for dayOffset in 0..<7 {
            let quote = quotes[dayOffset % quotes.count]

            let content = UNMutableNotificationContent()
            content.title = quote.title
            content.body = quote.body
            content.sound = .default

            var dateComponents = DateComponents()
            dateComponents.hour = morningHour
            dateComponents.minute = morningMinute

            if let futureDate = Calendar.current.date(byAdding: .day, value: dayOffset, to: Date()) {
                let futureDateComponents = Calendar.current.dateComponents([.year, .month, .day], from: futureDate)
                dateComponents.year = futureDateComponents.year
                dateComponents.month = futureDateComponents.month
                dateComponents.day = futureDateComponents.day
            }

            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
            let request = UNNotificationRequest(
                identifier: "daily_wisdom_\(dayOffset)",
                content: content,
                trigger: trigger
            )

            UNUserNotificationCenter.current().add(request)
        }
    }

    func updateTime(hour: Int, minute: Int) {
        morningHour = hour
        morningMinute = minute
        UserDefaults.standard.set(hour, forKey: hourKey)
        UserDefaults.standard.set(minute, forKey: minuteKey)

        if isAuthorized {
            scheduleDailyNotifications()
        }
    }

    // MARK: - Re-engagement notification

    // Вызывается при каждом открытии приложения: отменяем старую, ставим новую на +3 дня
    func resetReEngagement() {
        guard isAuthorized else { return }
        UNUserNotificationCenter.current().removePendingNotificationRequests(
            withIdentifiers: [Self.reEngagementID]
        )
        scheduleReEngagementNotification()
    }

    private func scheduleReEngagementNotification() {
        guard let quote = Self.reEngagementQuotes.randomElement() else { return }

        let content = UNMutableNotificationContent()
        content.title = quote.title
        content.body = quote.body
        content.sound = .default

        guard let fireDate = Calendar.current.date(byAdding: .day, value: 3, to: Date()) else { return }
        var components = Calendar.current.dateComponents([.year, .month, .day], from: fireDate)
        components.hour = 19
        components.minute = 0

//        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        let request = UNNotificationRequest(
            identifier: Self.reEngagementID,
            content: content,
            trigger: trigger
        )
        UNUserNotificationCenter.current().add(request)
    }

    // MARK: - Notification content (localized)

    struct NotifQuote {
        let title: String
        let body: String
    }

    static var notificationQuotes: [NotifQuote] {
        let locale = Locale.current.language.languageCode?.identifier ?? "en"

        switch locale {
        case "ru":
            return [
                NotifQuote(title: "🏛 Утренняя мудрость", body: "«Ты властен над своим разумом — не над внешними событиями.» — Марк Аврелий"),
                NotifQuote(title: "💰 Мысль на сегодня", body: "«Богатство не в том, чтобы иметь много, а в том, чтобы мало желать.» — Эпиктет"),
                NotifQuote(title: "⚡ Доза дисциплины", body: "«Мы страдаем чаще в воображении, чем в реальности.» — Сенека"),
                NotifQuote(title: "👑 Утренний урок", body: "«Препятствие — это путь.» — Марк Аврелий"),
                NotifQuote(title: "❤️ Время подумать", body: "«Знающий других мудр. Знающий себя — просветлён.» — Лао-цзы"),
                NotifQuote(title: "🏛 Начни день с мудрости", body: "«Не свободен тот, кто не властен над собой.» — Эпиктет"),
                NotifQuote(title: "⚡ Пора действовать", body: "«Лучшее время посадить дерево было 20 лет назад. Второе лучшее — сейчас.»"),
            ]
        case "es":
            return [
                NotifQuote(title: "🏛 Sabiduría matutina", body: "«Tienes poder sobre tu mente, no sobre los eventos externos.» — Marco Aurelio"),
                NotifQuote(title: "💰 Pensamiento del día", body: "«La riqueza no consiste en tener mucho, sino en desear poco.» — Epicteto"),
                NotifQuote(title: "⚡ Dosis de disciplina", body: "«Sufrimos más en la imaginación que en la realidad.» — Séneca"),
                NotifQuote(title: "👑 Lección matutina", body: "«El obstáculo es el camino.» — Marco Aurelio"),
                NotifQuote(title: "❤️ Momento de reflexión", body: "«Quien conoce a otros es sabio; quien se conoce a sí mismo está iluminado.» — Lao Tzu"),
                NotifQuote(title: "🏛 Empieza con sabiduría", body: "«No es libre quien no es dueño de sí mismo.» — Epicteto"),
                NotifQuote(title: "⚡ Hora de actuar", body: "«El mejor momento para plantar un árbol fue hace 20 años. El segundo mejor es ahora.»"),
            ]
        case "de":
            return [
                NotifQuote(title: "🏛 Morgenweisheit", body: "«Du hast Macht über deinen Geist — nicht über äußere Ereignisse.» — Marc Aurel"),
                NotifQuote(title: "💰 Gedanke des Tages", body: "«Reichtum besteht nicht darin, viel zu besitzen, sondern wenig zu begehren.» — Epiktet"),
                NotifQuote(title: "⚡ Dosis Disziplin", body: "«Wir leiden häufiger in der Vorstellung als in der Wirklichkeit.» — Seneca"),
                NotifQuote(title: "👑 Morgenlektion", body: "«Das Hindernis ist der Weg.» — Marc Aurel"),
                NotifQuote(title: "❤️ Zeit zum Nachdenken", body: "«Wer andere kennt, ist klug. Wer sich selbst kennt, ist erleuchtet.» — Laotse"),
                NotifQuote(title: "🏛 Starte mit Weisheit", body: "«Nicht frei ist, wer sich nicht selbst beherrscht.» — Epiktet"),
                NotifQuote(title: "⚡ Zeit zu handeln", body: "«Die beste Zeit, einen Baum zu pflanzen, war vor 20 Jahren. Die zweitbeste ist jetzt.»"),
            ]
        case "fr":
            return [
                NotifQuote(title: "🏛 Sagesse du matin", body: "«Tu as pouvoir sur ton esprit — pas sur les événements extérieurs.» — Marc Aurèle"),
                NotifQuote(title: "💰 Pensée du jour", body: "«La richesse ne consiste pas à avoir beaucoup, mais à désirer peu.» — Épictète"),
                NotifQuote(title: "⚡ Dose de discipline", body: "«Nous souffrons plus souvent en imagination que dans la réalité.» — Sénèque"),
                NotifQuote(title: "👑 Leçon du matin", body: "«L'obstacle est le chemin.» — Marc Aurèle"),
                NotifQuote(title: "❤️ Moment de réflexion", body: "«Celui qui connaît les autres est sage. Celui qui se connaît est éclairé.» — Lao Tseu"),
                NotifQuote(title: "🏛 Commence avec sagesse", body: "«N'est pas libre celui qui n'est pas maître de lui-même.» — Épictète"),
                NotifQuote(title: "⚡ C'est l'heure d'agir", body: "«Le meilleur moment pour planter un arbre était il y a 20 ans. Le deuxième meilleur est maintenant.»"),
            ]
        case "pt":
            return [
                NotifQuote(title: "🏛 Sabedoria matinal", body: "«Você tem poder sobre sua mente — não sobre os eventos externos.» — Marco Aurélio"),
                NotifQuote(title: "💰 Pensamento do dia", body: "«A riqueza não consiste em ter muito, mas em desejar pouco.» — Epicteto"),
                NotifQuote(title: "⚡ Dose de disciplina", body: "«Sofremos mais na imaginação do que na realidade.» — Sêneca"),
                NotifQuote(title: "👑 Lição da manhã", body: "«O obstáculo é o caminho.» — Marco Aurélio"),
                NotifQuote(title: "❤️ Momento de reflexão", body: "«Quem conhece os outros é sábio. Quem conhece a si mesmo é iluminado.» — Lao Tsé"),
                NotifQuote(title: "🏛 Comece com sabedoria", body: "«Não é livre quem não é senhor de si mesmo.» — Epicteto"),
                NotifQuote(title: "⚡ Hora de agir", body: "«O melhor momento para plantar uma árvore foi há 20 anos. O segundo melhor é agora.»"),
            ]
        default:
            return [
                NotifQuote(title: "🏛 Morning Wisdom", body: "\"You have power over your mind — not outside events.\" — Marcus Aurelius"),
                NotifQuote(title: "💰 Thought for Today", body: "\"Wealth consists not in having great possessions, but in having few wants.\" — Epictetus"),
                NotifQuote(title: "⚡ Daily Discipline", body: "\"We suffer more often in imagination than in reality.\" — Seneca"),
                NotifQuote(title: "👑 Morning Lesson", body: "\"The obstacle is the way.\" — Marcus Aurelius"),
                NotifQuote(title: "❤️ Time to Reflect", body: "\"He who knows others is wise; he who knows himself is enlightened.\" — Lao Tzu"),
                NotifQuote(title: "🏛 Start with Wisdom", body: "\"No man is free who is not master of himself.\" — Epictetus"),
                NotifQuote(title: "⚡ Time to Act", body: "\"The best time to plant a tree was 20 years ago. The second best time is now.\""),
            ]
        }
    }

    static var reEngagementQuotes: [NotifQuote] {
        let locale = Locale.current.language.languageCode?.identifier ?? "en"

        switch locale {
        case "ru":
            return [
                NotifQuote(title: "Ты не заходил несколько дней", body: "Начни жить прямо сейчас — Сенека"),
                NotifQuote(title: "Начни снова сегодня", body: "Ничто великое не создаётся внезапно — Эпиктет"),
                NotifQuote(title: "Загляни на минуту", body: "Каждый день — маленькая жизнь — Сенека"),
                NotifQuote(title: "Возвращайся, цитата ждёт", body: "Трудности показывают, кто мы есть — Эпиктет"),
                NotifQuote(title: "Есть мысль, которая тебя зацепит", body: "Потерянного времени не вернуть — Марк Аврелий"),
            ]
        case "es":
            return [
                NotifQuote(title: "Llevas unos días sin entrar", body: "Empieza a vivir ahora mismo — Séneca"),
                NotifQuote(title: "Empieza de nuevo hoy", body: "Nada grande se crea de repente — Epicteto"),
                NotifQuote(title: "Entra un momento", body: "Cada día es una pequeña vida — Séneca"),
                NotifQuote(title: "Vuelve, hay una idea esperándote", body: "Las dificultades nos muestran quiénes somos — Epicteto"),
                NotifQuote(title: "Un pensamiento que vale la pena", body: "El tiempo perdido no vuelve — Marco Aurelio"),
            ]
        case "de":
            return [
                NotifQuote(title: "Du warst ein paar Tage weg", body: "Fang jetzt an zu leben — Seneca"),
                NotifQuote(title: "Fang heute neu an", body: "Nichts Großes entsteht plötzlich — Epiktet"),
                NotifQuote(title: "Schau kurz rein", body: "Jeder Tag ist ein kleines Leben — Seneca"),
                NotifQuote(title: "Ein Gedanke wartet auf dich", body: "Schwierigkeiten zeigen, wer wir sind — Epiktet"),
                NotifQuote(title: "Komm zurück für einen Moment", body: "Verlorene Zeit kehrt nicht zurück — Marc Aurel"),
            ]
        case "fr":
            return [
                NotifQuote(title: "Tu n'es pas venu depuis quelques jours", body: "Commence à vivre maintenant — Sénèque"),
                NotifQuote(title: "Recommence aujourd'hui", body: "Rien de grand ne se crée soudainement — Épictète"),
                NotifQuote(title: "Reviens une minute", body: "Chaque jour est une petite vie — Sénèque"),
                NotifQuote(title: "Une pensée t'attend", body: "Les épreuves révèlent qui nous sommes — Épictète"),
                NotifQuote(title: "Un instant de clarté t'attend", body: "Le temps perdu ne revient pas — Marc Aurèle"),
            ]
        case "pt":
            return [
                NotifQuote(title: "Faz alguns dias que não entras", body: "Começa a viver agora mesmo — Sêneca"),
                NotifQuote(title: "Começa de novo hoje", body: "Nada grande é criado de repente — Epicteto"),
                NotifQuote(title: "Entra por um momento", body: "Cada dia é uma pequena vida — Sêneca"),
                NotifQuote(title: "Há um pensamento esperando por ti", body: "As dificuldades revelam quem somos — Epicteto"),
                NotifQuote(title: "Volta, vale a pena", body: "O tempo perdido não volta — Marco Aurélio"),
            ]
        default:
            return [
                NotifQuote(title: "You haven't visited in a few days", body: "Begin at once to live — Seneca"),
                NotifQuote(title: "Start again today", body: "No great thing is created suddenly — Epictetus"),
                NotifQuote(title: "Come back for a moment", body: "Every day is a little life — Seneca"),
                NotifQuote(title: "A thought worth reading is waiting", body: "Difficulties show what men are — Epictetus"),
                NotifQuote(title: "Don't let time slip away", body: "Time lost cannot be regained — Marcus Aurelius"),
            ]
        }
    }
}
