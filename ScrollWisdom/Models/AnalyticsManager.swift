import FirebaseAnalytics

enum AnalyticsManager {

    static func cardViewed(_ card: WisdomCard, index: Int) {
        Analytics.logEvent("card_viewed", parameters: [
            "card_id": card.id,
            "topic": card.topic.rawValue,
            "author": card.author,
            "feed_index": index,
        ])
    }

    static func cardSaved(_ card: WisdomCard) {
        Analytics.logEvent("card_saved", parameters: [
            "card_id": card.id,
            "topic": card.topic.rawValue,
            "author": card.author,
        ])
    }

    static func cardUnsaved(_ card: WisdomCard) {
        Analytics.logEvent("card_unsaved", parameters: [
            "card_id": card.id,
            "topic": card.topic.rawValue,
        ])
    }

    static func cardShared(_ card: WisdomCard) {
        Analytics.logEvent("card_shared", parameters: [
            "card_id": card.id,
            "topic": card.topic.rawValue,
            "author": card.author,
        ])
    }

    static func paywallShown(trigger: String) {
        Analytics.logEvent("paywall_shown", parameters: [
            "trigger": trigger,
        ])
    }

    static func subscriptionStarted(productID: String) {
        Analytics.logEvent(AnalyticsEventPurchase, parameters: [
            AnalyticsParameterItemID: productID,
            AnalyticsParameterItemCategory: "subscription",
        ])
    }

    static func subscriptionRestored() {
        Analytics.logEvent("subscription_restored", parameters: nil)
    }

    static func onboardingCompleted(selectedTopics: [String]) {
        Analytics.logEvent("onboarding_completed", parameters: [
            "topics_count": selectedTopics.count,
            "topics": selectedTopics.joined(separator: ","),
        ])
    }

    static func topicToggled(_ topic: String, enabled: Bool) {
        Analytics.logEvent("topic_toggled", parameters: [
            "topic": topic,
            "enabled": enabled,
        ])
    }

    static func streakMilestone(_ days: Int) {
        Analytics.logEvent("streak_milestone", parameters: [
            "days": days,
        ])
    }
}
