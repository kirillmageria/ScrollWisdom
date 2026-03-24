import Foundation
import SwiftUI

@Observable
class ContentManager {
    var allCards: [WisdomCard] = []
    var savedCardIDs: Set<String> = []
    var selectedTopics: Set<WisdomCard.Topic> = Set(WisdomCard.Topic.allCases)
    var streak: Int = 0
    var cardsViewedToday: Int = 0
    var hasCompletedOnboarding: Bool = false

    private var viewedCardIDs: Set<String> = []

    private let savedKey = "savedCardIDs"
    private let topicsKey = "selectedTopics"
    private let streakKey = "streakCount"
    private let lastOpenKey = "lastOpenDate"
    private let onboardingKey = "hasCompletedOnboarding"
    private let cardsViewedTodayKey = "cardsViewedToday"
    private let cardsViewedDateKey = "cardsViewedDate"

    /// Returns cards filtered by user-selected topics AND available (free/premium) topics
    func feedCards(availableTopics: Set<WisdomCard.Topic>) -> [WisdomCard] {
        allCards.filter { card in
            selectedTopics.contains(card.topic) && availableTopics.contains(card.topic)
        }.shuffled()
    }

    var savedCards: [WisdomCard] {
        allCards.filter { savedCardIDs.contains($0.id) }
    }

    init() {
        loadCards()
        loadSavedState()
        updateStreak()
    }

    func loadCards() {
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

        for name in fileNames {
            if let url = Bundle.main.url(forResource: name, withExtension: "json"),
               let data = try? Data(contentsOf: url),
               let cards = try? JSONDecoder().decode([WisdomCard].self, from: data),
               !cards.isEmpty {
                allCards = cards
                return
            }
        }

        allCards = Self.sampleCards
    }

    func toggleSave(_ card: WisdomCard) {
        if savedCardIDs.contains(card.id) {
            savedCardIDs.remove(card.id)
        } else {
            savedCardIDs.insert(card.id)
        }
        saveToDisk()
    }

    func isSaved(_ card: WisdomCard) -> Bool {
        savedCardIDs.contains(card.id)
    }

    func markViewed(cardID: String) {
        if viewedCardIDs.insert(cardID).inserted {
            cardsViewedToday += 1
            UserDefaults.standard.set(cardsViewedToday, forKey: cardsViewedTodayKey)
        }
    }

    func completeOnboarding(topics: Set<WisdomCard.Topic>) {
        selectedTopics = topics
        hasCompletedOnboarding = true
        UserDefaults.standard.set(true, forKey: onboardingKey)
        let topicStrings = topics.map { $0.rawValue }
        UserDefaults.standard.set(topicStrings, forKey: topicsKey)
    }

    private func loadSavedState() {
        if let ids = UserDefaults.standard.array(forKey: savedKey) as? [String] {
            savedCardIDs = Set(ids)
        }
        if let topics = UserDefaults.standard.array(forKey: topicsKey) as? [String] {
            selectedTopics = Set(topics.compactMap { WisdomCard.Topic(rawValue: $0) })
        }
        streak = UserDefaults.standard.integer(forKey: streakKey)
        hasCompletedOnboarding = UserDefaults.standard.bool(forKey: onboardingKey)

        let today = Calendar.current.startOfDay(for: Date())
        if let savedDateStr = UserDefaults.standard.string(forKey: cardsViewedDateKey),
           let savedDate = ISO8601DateFormatter().date(from: savedDateStr),
           Calendar.current.isDate(savedDate, inSameDayAs: today) {
            cardsViewedToday = UserDefaults.standard.integer(forKey: cardsViewedTodayKey)
        } else {
            cardsViewedToday = 0
            UserDefaults.standard.set(ISO8601DateFormatter().string(from: today), forKey: cardsViewedDateKey)
        }
    }

    func toggleTopic(_ topic: WisdomCard.Topic) {
        if selectedTopics.contains(topic) {
            guard selectedTopics.count > 1 else { return }
            selectedTopics.remove(topic)
        } else {
            selectedTopics.insert(topic)
        }
        saveTopics()
    }

    func resetTopics(to topics: Set<WisdomCard.Topic>) {
        selectedTopics = topics
        saveTopics()
    }

    private func saveTopics() {
        let topicStrings = selectedTopics.map { $0.rawValue }
        UserDefaults.standard.set(topicStrings, forKey: topicsKey)
    }

    private func saveToDisk() {
        UserDefaults.standard.set(Array(savedCardIDs), forKey: savedKey)
    }

    private func updateStreak() {
        let today = Calendar.current.startOfDay(for: Date())
        if let lastStr = UserDefaults.standard.string(forKey: lastOpenKey),
           let lastDate = ISO8601DateFormatter().date(from: lastStr) {
            let lastDay = Calendar.current.startOfDay(for: lastDate)
            let diff = Calendar.current.dateComponents([.day], from: lastDay, to: today).day ?? 0
            if diff == 1 {
                streak += 1
            } else if diff > 1 {
                streak = 1
            }
        } else {
            streak = 1
        }
        UserDefaults.standard.set(streak, forKey: streakKey)
        UserDefaults.standard.set(ISO8601DateFormatter().string(from: today), forKey: lastOpenKey)
    }

    static let sampleCards: [WisdomCard] = [
        WisdomCard(id: "s1", quote: "You have power over your mind — not outside events.", author: "Marcus Aurelius", source: "Meditations", story: "Written during a plague in a military camp.", action: "Write 3 things bothering you. Ask: can I control this?", topic: .stoicism),
        WisdomCard(id: "s2", quote: "We suffer more in imagination than in reality.", author: "Seneca", source: "Letters to Lucilius", story: "Written to a friend paralyzed by fear.", action: "Write your biggest worry. What happened the last 3 times?", topic: .stoicism),
        WisdomCard(id: "s3", quote: "The chains of habit are too light to be felt until they are too heavy to be broken.", author: "Samuel Johnson", source: "Attributed", story: "Johnson battled depression his entire life but wrote a dictionary solo.", action: "Track one habit for 7 days. Just observe.", topic: .discipline),
    ]
}
