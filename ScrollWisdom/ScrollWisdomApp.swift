import SwiftUI

@main
struct ScrollWisdomApp: App {
    @State private var manager = ContentManager()
    
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
            .preferredColorScheme(.dark)
        }
    }
}
