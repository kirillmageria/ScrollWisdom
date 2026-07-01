import Foundation
import UserNotifications

// Lightweight card types — avoids importing WisdomCard from ContentManager
struct NotifCardData: Decodable {
    let id: String
    let quote: String
    let author: String
    let topic: String
}

struct NotifCard {
    let author: String
    let quote: String
}

@Observable
class NotificationManager {
    var isAuthorized = false
    var morningHour: Int = 8
    var morningMinute: Int = 0

    private let hourKey = "notif_morning_hour"
    private let minuteKey = "notif_morning_minute"
    private static let reEngagementID = "re_engagement"

    // New UserDefaults keys
    private let cardOrderKey = "notif_card_order"
    private let cardIndexKey = "notif_last_card_index"

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
                    self.rescheduleDailyNotifications()
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

    private func scheduleCards(_ cards: [NotifCard], startingFrom date: Date) {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withFullDate, .withDashSeparatorInDate]

        for (i, card) in cards.enumerated() {
            guard let fireDate = Calendar.current.date(byAdding: .day, value: i, to: date) else { continue }
            let dateString = formatter.string(from: fireDate)

            let content = UNMutableNotificationContent()
            content.title = card.author
            content.body = card.quote
            content.sound = .default

            var components = Calendar.current.dateComponents([.year, .month, .day], from: fireDate)
            components.hour = morningHour
            components.minute = morningMinute

            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
            let request = UNNotificationRequest(
                identifier: "daily_wisdom_\(dateString)",
                content: content,
                trigger: trigger
            )
            UNUserNotificationCenter.current().add(request)
        }
    }

    func scheduleDailyNotifications() {
        UNUserNotificationCenter.current().getPendingNotificationRequests { [weak self] requests in
            guard let self else { return }

            let dailyRequests = requests.filter { $0.identifier.hasPrefix("daily_wisdom_") }
            let count = dailyRequests.count
            guard count < 7 else { return }

            // Find latest scheduled date from existing identifiers
            let formatter = ISO8601DateFormatter()
            formatter.formatOptions = [.withFullDate, .withDashSeparatorInDate]
            let latestDate = dailyRequests
                .compactMap { req -> Date? in
                    let suffix = String(req.identifier.dropFirst("daily_wisdom_".count))
                    return formatter.date(from: suffix)
                }
                .max() ?? Date()

            let needed = 30 - count
            let cards = self.loadNotificationCards(count: needed)
            guard !cards.isEmpty else { return }

            let startDate = Calendar.current.date(byAdding: .day, value: 1, to: latestDate) ?? Date()
            self.scheduleCards(cards, startingFrom: startDate)
        }
    }

    func rescheduleDailyNotifications() {
        UNUserNotificationCenter.current().getPendingNotificationRequests { [weak self] requests in
            guard let self else { return }

            let dailyIDs = requests
                .filter { $0.identifier.hasPrefix("daily_wisdom_") }
                .map { $0.identifier }
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: dailyIDs)

            UserDefaults.standard.set(0, forKey: self.cardIndexKey)

            let cards = self.loadNotificationCards(count: 30)
            guard !cards.isEmpty else { return }

            let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date()
            self.scheduleCards(cards, startingFrom: tomorrow)
        }
    }

    func onTopicsChanged() {
        // Rebuild card order for new topic selection before rescheduling
        let allCards = loadCardsJSON()
        let newOrder = allCards.map { $0.id }.shuffled()
        UserDefaults.standard.set(newOrder, forKey: cardOrderKey)
        UserDefaults.standard.set(0, forKey: cardIndexKey)
        rescheduleDailyNotifications()
    }

    func updateTime(hour: Int, minute: Int) {
        morningHour = hour
        morningMinute = minute
        UserDefaults.standard.set(hour, forKey: hourKey)
        UserDefaults.standard.set(minute, forKey: minuteKey)

        if isAuthorized {
            rescheduleDailyNotifications()
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

        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        let request = UNNotificationRequest(
            identifier: Self.reEngagementID,
            content: content,
            trigger: trigger
        )
        UNUserNotificationCenter.current().add(request)
    }

    // MARK: - Card loading

    static func truncate(_ quote: String, to maxLength: Int = 150) -> String {
        guard quote.count > maxLength else { return quote }
        return String(quote.prefix(maxLength)) + "…"
    }

    static func selectCards(
        from allCards: [NotifCardData],
        order: inout [String],
        index: inout Int,
        count: Int
    ) -> [NotifCard] {
        guard count > 0, !allCards.isEmpty else { return [] }
        let cardDict = Dictionary(uniqueKeysWithValues: allCards.map { ($0.id, $0) })
        var result: [NotifCard] = []
        while result.count < count {
            if index >= order.count {
                order = allCards.map { $0.id }.shuffled()
                index = 0
            }
            let id = order[index]
            index += 1
            if let card = cardDict[id] {
                result.append(NotifCard(
                    author: card.author,
                    quote: truncate(card.quote)
                ))
            }
        }
        return result
    }

    private func loadCardsJSON() -> [NotifCardData] {
        let locale = Locale.current.language.languageCode?.identifier ?? "en"
        let fileNames: [String]
        switch locale {
        case "ru": fileNames = ["cards_ru", "cards"]
        case "es": fileNames = ["cards_es", "cards"]
        case "de": fileNames = ["cards_de", "cards"]
        case "fr": fileNames = ["cards_fr", "cards"]
        case "pt": fileNames = ["cards_pt-BR", "cards"]
        default:   fileNames = ["cards"]
        }

        let selectedTopics = Set(
            (UserDefaults.standard.array(forKey: "selectedTopics") as? [String]) ?? []
        )

        for name in fileNames {
            guard let url = Bundle.main.url(forResource: name, withExtension: "json"),
                  let data = try? Data(contentsOf: url),
                  let cards = try? JSONDecoder().decode([NotifCardData].self, from: data),
                  !cards.isEmpty else { continue }
            if selectedTopics.isEmpty {
                return cards
            }
            return cards.filter { selectedTopics.contains($0.topic) }
        }
        return []
    }

    func loadNotificationCards(count: Int) -> [NotifCard] {
        guard count > 0 else { return [] }
        let allCards = loadCardsJSON()
        guard !allCards.isEmpty else { return [] }

        var order = UserDefaults.standard.stringArray(forKey: cardOrderKey) ?? []
        var index = UserDefaults.standard.integer(forKey: cardIndexKey)

        if order.isEmpty {
            order = allCards.map { $0.id }.shuffled()
            index = 0
        }

        let result = NotificationManager.selectCards(
            from: allCards,
            order: &order,
            index: &index,
            count: count
        )

        UserDefaults.standard.set(order, forKey: cardOrderKey)
        UserDefaults.standard.set(index, forKey: cardIndexKey)
        return result
    }

    // MARK: - Notification content (localized)

    struct NotifQuote {
        let title: String
        let body: String
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
