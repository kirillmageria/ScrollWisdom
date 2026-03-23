import SwiftUI

@main
struct ScrollWisdomApp: App {
    @State private var manager = ContentManager()
    @State private var notificationManager = NotificationManager()

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
            .preferredColorScheme(.dark)
        }
    }
}
