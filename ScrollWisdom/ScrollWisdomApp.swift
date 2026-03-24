import SwiftUI

@main
struct ScrollWisdomApp: App {
    @State private var manager = ContentManager()
    @State private var notificationManager = NotificationManager()
    @State private var storeManager = StoreManager()

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
        }
    }
}
