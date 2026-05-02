import FirebaseAnalytics
import StoreKit

enum AnalyticsManager {

    // MARK: - Card events

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

    // Пользователь реально прочитал карточку (провёл ≥4 сек)
    static func cardEngaged(_ card: WisdomCard, dwellSeconds: Int) {
        Analytics.logEvent("card_engaged", parameters: [
            "card_id": card.id,
            "topic": card.topic.rawValue,
            "dwell_seconds": dwellSeconds,
        ])
    }

    // MARK: - Paywall events

    static func paywallShown(trigger: String) {
        Analytics.logEvent("paywall_shown", parameters: [
            "trigger": trigger,
        ])
    }

    static func paywallDismissed(trigger: String) {
        Analytics.logEvent("paywall_dismissed", parameters: [
            "trigger": trigger,
        ])
    }

    // MARK: - Subscription events

    static func subscriptionStarted(product: Product, transactionID: String) {
        Analytics.logEvent(AnalyticsEventPurchase, parameters: [
            AnalyticsParameterTransactionID: transactionID,
            AnalyticsParameterValue: NSDecimalNumber(decimal: product.price),
            AnalyticsParameterCurrency: Locale.current.currency?.identifier ?? "USD",
            AnalyticsParameterItemID: product.id,
            AnalyticsParameterItemCategory: "subscription",
        ])
    }

    static func subscriptionRestored() {
        Analytics.logEvent("subscription_restored", parameters: nil)
    }

    // MARK: - Streak events

    static func streakMilestone(_ days: Int) {
        Analytics.logEvent("streak_milestone", parameters: [
            "days": days,
        ])
    }

    static func streakBroken(previousStreak: Int) {
        Analytics.logEvent("streak_broken", parameters: [
            "previous_streak": previousStreak,
        ])
    }

    // MARK: - Onboarding & settings events

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

    // MARK: - Notification events

    static func notificationPermissionGranted() {
        Analytics.logEvent("notification_permission_granted", parameters: nil)
    }

    static func notificationPermissionDenied() {
        Analytics.logEvent("notification_permission_denied", parameters: nil)
    }

    static func notificationOpened() {
        Analytics.logEvent("notification_opened", parameters: nil)
    }

    // MARK: - User properties

    static func setSubscriptionTier(isPremium: Bool, productID: String?) {
        let tier: String
        if !isPremium {
            tier = "free"
        } else if productID == "com.scrollwisdom.monthly.v2" {
            tier = "monthly"
        } else {
            tier = "yearly"
        }
        Analytics.setUserProperty(tier, forName: "subscription_tier")
    }

    static func setTopicsCount(_ count: Int) {
        Analytics.setUserProperty("\(count)", forName: "topics_count")
    }

    static func setStreakBucket(_ streak: Int) {
        let bucket: String
        switch streak {
        case 0:       bucket = "0"
        case 1...3:   bucket = "1-3"
        case 4...7:   bucket = "4-7"
        case 8...30:  bucket = "8-30"
        default:      bucket = "30+"
        }
        Analytics.setUserProperty(bucket, forName: "streak_bucket")
    }
}
