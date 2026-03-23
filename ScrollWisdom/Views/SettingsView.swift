import SwiftUI

struct SettingsView: View {
    @Environment(ContentManager.self) var manager
    @Environment(NotificationManager.self) var notifManager
    @State private var notifTime = Date()
    @State private var showTimePicker = false

    var body: some View {
        NavigationStack {
            List {
                // Stats
                Section {
                    HStack(spacing: 16) {
                        StatBox(value: "\(manager.streak)", label: String(localized: "settings.streak"), icon: "flame.fill", color: .orange)
                        StatBox(value: "\(manager.cardsViewedToday)", label: String(localized: "settings.read_today"), icon: "eye", color: .blue)
                        StatBox(value: "\(manager.savedCardIDs.count)", label: String(localized: "settings.saved"), icon: "bookmark.fill", color: .purple)
                    }
                    .listRowInsets(EdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16))
                    .listRowBackground(Color.clear)
                }

                // Notifications
                Section(String(localized: "settings.notifications")) {
                    if notifManager.isAuthorized {
                        HStack {
                            Image(systemName: "bell.badge")
                                .foregroundStyle(.orange)
                            Text(String(localized: "settings.notif.morning"))
                            Spacer()
                            Button(action: { showTimePicker.toggle() }) {
                                Text(timeString)
                                    .font(.system(size: 15, weight: .medium))
                                    .foregroundStyle(.orange)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(Color.orange.opacity(0.15))
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                            }
                        }

                        if showTimePicker {
                            DatePicker(
                                String(localized: "settings.notif.time"),
                                selection: $notifTime,
                                displayedComponents: .hourAndMinute
                            )
                            .datePickerStyle(.wheel)
                            .onChange(of: notifTime) { _, newValue in
                                let comps = Calendar.current.dateComponents([.hour, .minute], from: newValue)
                                notifManager.updateTime(hour: comps.hour ?? 8, minute: comps.minute ?? 0)
                            }
                        }
                    } else {
                        Button {
                            notifManager.requestPermission()
                        } label: {
                            HStack {
                                Image(systemName: "bell.slash")
                                    .foregroundStyle(.secondary)
                                Text(String(localized: "settings.notif.enable"))
                                    .foregroundStyle(.primary)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundStyle(.secondary)
                                    .font(.system(size: 12))
                            }
                        }
                    }
                }

                // Topics
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

                // About
                Section(String(localized: "settings.about")) {
                    HStack {
                        Text(String(localized: "settings.version"))
                        Spacer()
                        Text("1.0.0").foregroundStyle(.secondary)
                    }
                }

                // Premium
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
        .onAppear {
            var comps = DateComponents()
            comps.hour = notifManager.morningHour
            comps.minute = notifManager.morningMinute
            notifTime = Calendar.current.date(from: comps) ?? Date()
        }
    }

    private var timeString: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        var comps = DateComponents()
        comps.hour = notifManager.morningHour
        comps.minute = notifManager.morningMinute
        let date = Calendar.current.date(from: comps) ?? Date()
        return formatter.string(from: date)
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
