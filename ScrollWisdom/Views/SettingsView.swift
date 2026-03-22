import SwiftUI

struct SettingsView: View {
    @Environment(ContentManager.self) var manager
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    HStack(spacing: 16) {
                        StatBox(value: "\(manager.streak)", label: String(localized: "settings.streak"), icon: "flame.fill", color: .orange)
                        StatBox(value: "\(manager.cardsViewedToday)", label: String(localized: "settings.read_today"), icon: "eye", color: .blue)
                        StatBox(value: "\(manager.savedCardIDs.count)", label: String(localized: "settings.saved"), icon: "bookmark.fill", color: .purple)
                    }
                    .listRowInsets(EdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16))
                    .listRowBackground(Color.clear)
                }
                
                Section(String(localized: "settings.topics")) {
                    ForEach(WisdomCard.Topic.allCases, id: \.self) { topic in
                        let isOn = manager.selectedTopics.contains(topic)
                        Button {
                            if isOn {
                                if manager.selectedTopics.count > 1 { manager.selectedTopics.remove(topic) }
                            } else {
                                manager.selectedTopics.insert(topic)
                            }
                        } label: {
                            HStack {
                                Text(topic.emoji)
                                Text(topic.displayName).foregroundStyle(.primary)
                                Spacer()
                                Image(systemName: isOn ? "checkmark.circle.fill" : "circle")
                                    .foregroundStyle(isOn ? .blue : .secondary)
                            }
                        }
                    }
                }
                
                Section(String(localized: "settings.about")) {
                    HStack {
                        Text(String(localized: "settings.version"))
                        Spacer()
                        Text("1.0.0").foregroundStyle(.secondary)
                    }
                }
                
                Section {
                    Button {
                        // TODO: Show paywall
                    } label: {
                        HStack {
                            Image(systemName: "crown.fill").foregroundStyle(.orange)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(String(localized: "settings.premium.title"))
                                    .font(.system(size: 15, weight: .semibold)).foregroundStyle(.primary)
                                Text(String(localized: "settings.premium.subtitle"))
                                    .font(.system(size: 12)).foregroundStyle(.secondary)
                            }
                            Spacer()
                            Text(String(localized: "settings.premium.price"))
                                .font(.system(size: 13, weight: .medium)).foregroundStyle(.orange)
                        }
                    }
                }
            }
            .navigationTitle(String(localized: "settings.title"))
        }
    }
}

struct StatBox: View {
    let value: String
    let label: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon).font(.system(size: 16)).foregroundStyle(color)
            Text(value).font(.system(size: 22, weight: .bold))
            Text(label).font(.system(size: 11)).foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
