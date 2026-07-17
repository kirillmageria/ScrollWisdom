import SwiftUI
import FirebaseCore
import FirebaseAnalytics
import FirebaseCrashlytics
import UserNotifications

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        UNUserNotificationCenter.current().delegate = self
        return true
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        AnalyticsManager.notificationOpened()
        completionHandler()
    }
}

@main
struct ScrollWisdomApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    @State private var manager = ContentManager()
    @State private var notificationManager = NotificationManager()
    @State private var storeManager = StoreManager()

    init() {
        FirebaseApp.configure()
        #if DEBUG
        Analytics.setAnalyticsCollectionEnabled(false)
        #endif
    }

    @Environment(\.scenePhase) var scenePhase

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
                manager.notificationManager = notificationManager
                Crashlytics.crashlytics().setCustomValue(
                    storeManager.isPremium,
                    forKey: "is_premium"
                )
            }
            .onChange(of: storeManager.isPremium) { _, newValue in
                Crashlytics.crashlytics().setCustomValue(newValue, forKey: "is_premium")
            }
            .onChange(of: scenePhase) { _, phase in
                if phase == .active {
                    notificationManager.resetReEngagement()
                    notificationManager.scheduleDailyNotifications()
                }
            }
        }
    }
}
