import SwiftUI
import FirebaseCore
import FirebaseCrashlytics

@main
struct ScrollWisdomApp: App {
    @State private var manager = ContentManager()
    @State private var notificationManager = NotificationManager()
    @State private var storeManager = StoreManager()

    init() {
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            Group {
                if manager.hasCompletedOnboarding {
                    MainTabView()
                } else {
                    OnboardingView()
                }
            }
            .environment(manager)
            .environment(notificationManager)
            .environment(storeManager)
            .preferredColorScheme(.dark)
            .task {
                Crashlytics.crashlytics().setCustomValue(
                    storeManager.isPremium,
                    forKey: "is_premium"
                )
            }
            .onChange(of: storeManager.isPremium) { _, newValue in
                Crashlytics.crashlytics().setCustomValue(newValue, forKey: "is_premium")
            }
        }
    }
}
