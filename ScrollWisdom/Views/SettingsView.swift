import SwiftUI
import StoreKit

struct SettingsView: View {
    @Environment(ContentManager.self) var manager
    @Environment(NotificationManager.self) var notifManager
    @Environment(StoreManager.self) var store
    @State private var notifTime = Date()
    @State private var showTimePicker = false
    @State private var showPaywall = false
    @Environment(\.requestReview) private var requestReview
    @Environment(\.openURL) private var openURL

    private static let timeFormatter: DateFormatter = {
        let f = DateFormatter()
        f.timeStyle = .short
        return f
    }()

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {

                // MARK: - Header
                VStack(spacing: 4) {
                    Text(String(localized: "settings.title"))
                        .font(.system(size: 28, weight: .bold, design: .serif))
                        .foregroundStyle(.white)
                    Text(String(localized: "settings.subtitle"))
                        .font(.system(size: 13))
                        .foregroundStyle(.white.opacity(0.3))
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 60)
                .padding(.bottom, 4)

                // MARK: - Stats
                HStack(spacing: 12) {
                    StatCard(
                        value: "\(manager.streak)",
                        label: String(localized: "settings.streak"),
                        icon: "flame.fill",
                        gradient: [Color(hex: "#f0a500"), Color(hex: "#ff6b35")]
                    )
                    StatCard(
                        value: "\(manager.cardsViewedToday)",
                        label: String(localized: "settings.read_today"),
                        icon: "eye",
                        gradient: [Color(hex: "#3b82f6"), Color(hex: "#1d4ed8")]
                    )
                    StatCard(
                        value: "\(manager.savedCardIDs.count)",
                        label: String(localized: "settings.saved"),
                        icon: "bookmark.fill",
                        gradient: [Color(hex: "#a855f7"), Color(hex: "#7c3aed")]
                    )
                }
                .padding(.horizontal, 20)

                // MARK: - Notifications
                SettingsCard {
                    VStack(spacing: 0) {
                        HStack {
                            HStack(spacing: 10) {
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            colors: [Color(hex: "#f0a500"), Color(hex: "#ff6b35")],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 36, height: 36)
                                    .overlay(
                                        Image(systemName: "bell.badge")
                                            .font(.system(size: 16, weight: .medium))
                                            .foregroundStyle(.white)
                                    )

                                VStack(alignment: .leading, spacing: 2) {
                                    Text(String(localized: "settings.notif.morning"))
                                        .font(.system(size: 15, weight: .semibold))
                                        .foregroundStyle(.white)
                                    Text(notifManager.isAuthorized
                                         ? String(localized: "settings.notif.active")
                                         : String(localized: "settings.notif.inactive"))
                                        .font(.system(size: 12))
                                        .foregroundStyle(.white.opacity(0.4))
                                }
                            }

                            Spacer()

                            if notifManager.isAuthorized {
                                Button { withAnimation(.spring(response: 0.3)) { showTimePicker.toggle() } } label: {
                                    Text(timeString)
                                        .font(.system(size: 15, weight: .bold, design: .monospaced))
                                        .foregroundStyle(Color(hex: "#f0a500"))
                                        .padding(.horizontal, 14)
                                        .padding(.vertical, 8)
                                        .background(Color(hex: "#f0a500").opacity(0.12))
                                        .clipShape(RoundedRectangle(cornerRadius: 10))
                                }
                            } else {
                                Button { notifManager.requestPermission() } label: {
                                    Text(String(localized: "settings.notif.enable"))
                                        .font(.system(size: 13, weight: .semibold))
                                        .foregroundStyle(.black)
                                        .padding(.horizontal, 14)
                                        .padding(.vertical, 8)
                                        .background(Color(hex: "#f0a500"))
                                        .clipShape(RoundedRectangle(cornerRadius: 10))
                                }
                            }
                        }

                        if showTimePicker && notifManager.isAuthorized {
                            Rectangle()
                                .fill(.white.opacity(0.06))
                                .frame(height: 0.5)
                                .padding(.vertical, 12)

                            DatePicker("", selection: $notifTime, displayedComponents: .hourAndMinute)
                                .datePickerStyle(.wheel)
                                .labelsHidden()
                                .colorScheme(.dark)
                                .onChange(of: notifTime) { _, newValue in
                                    let comps = Calendar.current.dateComponents([.hour, .minute], from: newValue)
                                    notifManager.updateTime(hour: comps.hour ?? 8, minute: comps.minute ?? 0)
                                }
                        }
                    }
                }
                .padding(.horizontal, 20)

                // MARK: - Topics with lock indicators
                SettingsCard {
                    VStack(spacing: 0) {
                        ForEach(Array(WisdomCard.Topic.allCases.enumerated()), id: \.element) { index, topic in
                            let isFree = store.isTopicFree(topic)
                            let isOn = manager.selectedTopics.contains(topic)

                            VStack(spacing: 0) {
                                HStack {
                                    Text(topic.emoji).font(.system(size: 18))
                                    Text(topic.displayName)
                                        .font(.system(size: 15, weight: .medium))
                                        .foregroundStyle(.white)

                                    if !isFree && !store.isPremium {
                                        Image(systemName: "crown.fill")
                                            .font(.system(size: 10))
                                            .foregroundStyle(Color(hex: "#f0a500"))
                                    }

                                    Spacer()

                                    if isFree || store.isPremium {
                                        Image(systemName: isOn ? "checkmark.circle.fill" : "circle")
                                            .font(.system(size: 18))
                                            .foregroundStyle(isOn ? Color(hex: "#f0a500") : .white.opacity(0.2))
                                    } else {
                                        Image(systemName: "lock.fill")
                                            .font(.system(size: 14))
                                            .foregroundStyle(.white.opacity(0.2))
                                    }
                                }
                                .padding(.vertical, 12)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    if isFree || store.isPremium {
                                        manager.toggleTopic(topic)
                                    } else {
                                        showPaywall = true
                                    }
                                }

                                if index < WisdomCard.Topic.allCases.count - 1 {
                                    Rectangle()
                                        .fill(.white.opacity(0.06))
                                        .frame(height: 0.5)
                                        .padding(.leading, 32)
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)

                // MARK: - Premium
                if !store.isPremium {
                    Button { showPaywall = true } label: {
                        VStack(spacing: 16) {
                            HStack {
                                Image(systemName: "crown.fill")
                                    .font(.system(size: 24))
                                    .foregroundStyle(
                                        LinearGradient(
                                            colors: [Color(hex: "#f0a500"), Color(hex: "#ff6b35")],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(String(localized: "settings.premium.title"))
                                        .font(.system(size: 16, weight: .bold))
                                        .foregroundStyle(.white)
                                    Text(String(localized: "settings.premium.subtitle"))
                                        .font(.system(size: 12))
                                        .foregroundStyle(.white.opacity(0.4))
                                }
                                Spacer()
                                Text(String(localized: "settings.premium.price"))
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundStyle(Color(hex: "#f0a500"))
                            }

                            HStack(spacing: 8) {
                                PremiumPill(icon: "infinity", text: String(localized: "settings.premium.pill.saves"))
                                PremiumPill(icon: "sparkles", text: String(localized: "settings.premium.pill.topics"))
                                PremiumPill(icon: "bell.badge", text: String(localized: "settings.premium.pill.notifs"))
                            }
                        }
                        .padding(16)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(.white.opacity(0.04))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .strokeBorder(
                                            LinearGradient(
                                                colors: [Color(hex: "#f0a500").opacity(0.4), Color(hex: "#ff6b35").opacity(0.1)],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            ),
                                            lineWidth: 1
                                        )
                                )
                        )
                    }
                    .padding(.horizontal, 20)
                } else {
                    // Premium active badge
                    HStack {
                        Image(systemName: "crown.fill")
                            .foregroundStyle(Color(hex: "#f0a500"))
                        Text(String(localized: "settings.premium.active"))
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(.white)
                        Spacer()
                        Text("Premium")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(.black)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(Color(hex: "#f0a500"))
                            .clipShape(Capsule())
                    }
                    .padding(16)
                    .background(RoundedRectangle(cornerRadius: 16).fill(.white.opacity(0.04)))
                    .padding(.horizontal, 20)
                }

                // MARK: - About
                SettingsCard {
                    VStack(spacing: 0) {
                        AboutRow(icon: "info.circle", title: String(localized: "settings.version"),
                                 value: Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0",
                                 showDivider: true)

                        Button {
                            requestReview()
                        } label: {
                            AboutRow(icon: "star", title: String(localized: "settings.rate"), value: nil, showDivider: true)
                        }
                        .buttonStyle(.plain)

                        Button {
                            if let url = URL(string: "mailto:support@scrollwisdom.app?subject=ScrollWisdom%20Feedback") {
                                openURL(url)
                            }
                        } label: {
                            #if DEBUG
                            AboutRow(icon: "envelope", title: String(localized: "settings.feedback"), value: nil, showDivider: true)
                            #else
                            AboutRow(icon: "envelope", title: String(localized: "settings.feedback"), value: nil, showDivider: false)
                            #endif
                        }
                        .buttonStyle(.plain)

                        #if DEBUG
                        Button {
                            fatalError("Test crash for Crashlytics")
                        } label: {
                            AboutRow(icon: "flame", title: "Test Crash", value: nil, showDivider: false)
                        }
                        .buttonStyle(.plain)
                        #endif
                    }
                }
                .padding(.horizontal, 20)

                Text("Scroll Wisdom")
                    .font(.system(size: 12, weight: .medium, design: .serif))
                    .foregroundStyle(.white.opacity(0.15))
                    .padding(.top, 8)
                    .padding(.bottom, 100)
            }
        }
        .background(Color.black)
        .ignoresSafeArea()
        .onAppear {
            var comps = DateComponents()
            comps.hour = notifManager.morningHour
            comps.minute = notifManager.morningMinute
            notifTime = Calendar.current.date(from: comps) ?? Date()
        }
        .sheet(isPresented: $showPaywall) {
            PaywallView()
        }
    }

    private var timeString: String {
        var comps = DateComponents()
        comps.hour = notifManager.morningHour
        comps.minute = notifManager.morningMinute
        return Self.timeFormatter.string(from: Calendar.current.date(from: comps) ?? Date())
    }
}

// MARK: - Components

struct SettingsCard<Content: View>: View {
    @ViewBuilder let content: Content
    var body: some View {
        content
            .padding(16)
            .background(RoundedRectangle(cornerRadius: 16).fill(.white.opacity(0.04)))
    }
}

struct StatCard: View {
    let value: String
    let label: String
    let icon: String
    let gradient: [Color]
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon).font(.system(size: 18))
                .foregroundStyle(LinearGradient(colors: gradient, startPoint: .topLeading, endPoint: .bottomTrailing))
            Text(value).font(.system(size: 28, weight: .bold, design: .rounded)).foregroundStyle(.white)
            Text(label).font(.system(size: 11)).foregroundStyle(.white.opacity(0.35)).lineLimit(1)
        }
        .frame(maxWidth: .infinity).padding(.vertical, 16)
        .background(RoundedRectangle(cornerRadius: 16).fill(.white.opacity(0.04)))
    }
}

struct PremiumPill: View {
    let icon: String
    let text: String
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon).font(.system(size: 10))
            Text(text).font(.system(size: 11))
        }
        .foregroundStyle(.white.opacity(0.5))
        .padding(.horizontal, 10).padding(.vertical, 5)
        .background(.white.opacity(0.06)).clipShape(Capsule())
    }
}

struct AboutRow: View {
    let icon: String
    let title: String
    let value: String?
    let showDivider: Bool
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Image(systemName: icon).font(.system(size: 14)).foregroundStyle(.white.opacity(0.4)).frame(width: 24)
                Text(title).font(.system(size: 15)).foregroundStyle(.white.opacity(0.7))
                Spacer()
                if let value {
                    Text(value).font(.system(size: 14)).foregroundStyle(.white.opacity(0.3))
                } else {
                    Image(systemName: "chevron.right").font(.system(size: 12, weight: .medium)).foregroundStyle(.white.opacity(0.2))
                }
            }
            .padding(.vertical, 12)
            if showDivider {
                Rectangle().fill(.white.opacity(0.06)).frame(height: 0.5).padding(.leading, 38)
            }
        }
    }
}
