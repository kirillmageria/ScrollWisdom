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
    
    private let savedKey = "savedCardIDs"
    private let topicsKey = "selectedTopics"
    private let streakKey = "streakCount"
    private let lastOpenKey = "lastOpenDate"
    private let onboardingKey = "hasCompletedOnboarding"
    
    var filteredCards: [WisdomCard] {
        allCards.filter { selectedTopics.contains($0.topic) }.shuffled()
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
        // Try locale-specific file first, then fallback to default
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
            if let url = Bundle.main.url(forResource: name, withExtension: "json") {
                if let data = try? Data(contentsOf: url),
                   let cards = try? JSONDecoder().decode([WisdomCard].self, from: data),
                   !cards.isEmpty {
                    allCards = cards
                    return
                }
            }
        }

        // Fallback to sample cards
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
    
    func markViewed() {
        cardsViewedToday += 1
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
    
    // MARK: - Fallback sample cards (English)
    static let sampleCards: [WisdomCard] = [
        WisdomCard(id: "s1", quote: "You have power over your mind — not outside events. Realize this, and you will find strength.", author: "Marcus Aurelius", source: "Meditations, Book VI", story: "Aurelius wrote this in a military camp during a devastating plague. His army was dying, the empire crumbling — yet every evening he opened his journal.", action: "Write down 3 things bothering you. Next to each, ask: Can I control this?", topic: .stoicism),
        WisdomCard(id: "s2", quote: "We suffer more often in imagination than in reality.", author: "Seneca", source: "Letters to Lucilius", story: "Seneca wrote this to a friend paralyzed by fear of an upcoming trial. The trial came and went without consequence.", action: "Write down your biggest worry. Below it, list what actually happened the last 3 times you worried this much.", topic: .stoicism),
        WisdomCard(id: "s3", quote: "Wealth consists not in having great possessions, but in having few wants.", author: "Epictetus", source: "Discourses", story: "Epictetus was born a slave. After gaining freedom, he chose to live with almost nothing. He taught that desire, not poverty, is the real prison.", action: "Check your recent purchases. Find 3 things you bought but never needed.", topic: .money),
    ]
}
