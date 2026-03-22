import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            FeedView()
                .tabItem {
                    Image(systemName: "rectangle.stack.fill")
                    Text(String(localized: "tab.feed"))
                }
                .tag(0)
            
            SavedView()
                .tabItem {
                    Image(systemName: "bookmark.fill")
                    Text(String(localized: "tab.saved"))
                }
                .tag(1)
            
            SettingsView()
                .tabItem {
                    Image(systemName: "gearshape")
                    Text(String(localized: "tab.settings"))
                }
                .tag(2)
        }
        .tint(.white)
    }
}
