import SwiftUI

struct OnboardingView: View {
    @Environment(ContentManager.self) var manager
    @Environment(NotificationManager.self) var notifManager
    @Environment(StoreManager.self) var store
    @State private var step = 0
    @State private var selectedTopics: Set<WisdomCard.Topic> = []
    @State private var showPaywall = false

    private let totalSteps = 4

    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [Color(hex: "#0a0a0f"), Color(hex: "#020203")],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            // Ambient glow
            Circle()
                .fill(Color(hex: "#D4A84B").opacity(0.07))
                .frame(width: 300, height: 300)
                .blur(radius: 60)
                .offset(x: 40, y: -60)
                .allowsHitTesting(false)

            VStack(spacing: 0) {
                // Progress bar
                if step > 0 {
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 2)
                                .fill(.white.opacity(0.08))
                            RoundedRectangle(cornerRadius: 2)
                                .fill(Color(hex: "#D4A84B"))
                                .frame(width: geo.size.width * CGFloat(step) / CGFloat(totalSteps - 1))
                                .animation(.spring(response: 0.4), value: step)
                        }
                    }
                    .frame(height: 3)
                    .padding(.horizontal, 32)
                    .padding(.top, 56)
                }

                Spacer()

                Group {
                    switch step {
                    case 0: welcomeStep
                    case 1: topicStep
                    case 2: previewStep
                    case 3: notificationStep
                    default: EmptyView()
                    }
                }
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal: .move(edge: .leading).combined(with: .opacity)
                ))
                .id(step)

                Spacer()

                // CTA Button
                Button {
                    handleCTA()
                } label: {
                    Text(ctaLabel)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(.white.opacity(0.08))
                        .background {
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color(hex: "#D4A84B").opacity(ctaGlowOpacity))
                                .blur(radius: 16)
                        }
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .strokeBorder(.white.opacity(0.15), lineWidth: 0.5)
                        )
                        .opacity(ctaEnabled ? 1 : 0.4)
                }
                .disabled(!ctaEnabled)
                .padding(.horizontal, 32)
                .padding(.bottom, 48)
                .animation(.easeOut(duration: 0.2), value: ctaEnabled)

                // Skip on notification screen
                if step == 3 {
                    Button {
                        completeOnboarding()
                    } label: {
                        Text(String(localized: "onboarding.skip"))
                            .font(.system(size: 14))
                            .foregroundStyle(.white.opacity(0.35))
                    }
                    .padding(.bottom, 24)
                }
            }
        }
        .sheet(isPresented: $showPaywall) {
            PaywallView()
                .environment(store)
        }
    }

    // MARK: - Steps

    var welcomeStep: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Quote
            HStack(spacing: 0) {
                Rectangle()
                    .fill(Color(hex: "#D4A84B"))
                    .frame(width: 2)
                    .padding(.vertical, 4)
                Spacer().frame(width: 16)
                VStack(alignment: .leading, spacing: 20) {
                    Text(String(localized: "onboarding.welcome.quote"))
                        .font(.system(size: 38, weight: .semibold, design: .serif))
                        .foregroundStyle(.white)
                        .lineSpacing(6)
                        .italic()
                    Text(String(localized: "onboarding.welcome.author"))
                        .font(.system(size: 14, weight: .regular))
                        .foregroundStyle(Color(hex: "#8A8F98"))
                        .tracking(0.5)
                }
            }
            .padding(.horizontal, 32)

        }
    }

    var topicStep: some View {
        VStack(spacing: 0) {
            VStack(spacing: 8) {
                Text(String(localized: "onboarding.topics.title"))
                    .font(.system(size: 26, weight: .bold, design: .serif))
                    .foregroundStyle(.white)
                Text(String(localized: "onboarding.topics.subtitle"))
                    .font(.system(size: 14))
                    .foregroundStyle(.white.opacity(0.4))
            }
            .padding(.bottom, 28)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                ForEach(WisdomCard.Topic.allCases, id: \.self) { topic in
                    let isSelected = selectedTopics.contains(topic)
                    let isFree = store.isTopicFree(topic)
                    Button {
                        if isFree {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                if isSelected { selectedTopics.remove(topic) } else { selectedTopics.insert(topic) }
                            }
                        } else {
                            showPaywall = true
                        }
                    } label: {
                        ZStack(alignment: .topTrailing) {
                            VStack(spacing: 12) {
                                Text(topic.emoji)
                                    .font(.system(size: 36))
                                VStack(spacing: 4) {
                                    Text(topic.displayName)
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundStyle(.white)
                                        .multilineTextAlignment(.center)
                                    if !isFree {
                                        Text("Premium")
                                            .font(.system(size: 9, weight: .semibold))
                                            .tracking(0.5)
                                            .foregroundStyle(Color(hex: "#D4A84B").opacity(0.7))
                                    }
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 110)
                            .background(isSelected ? Color(hex: "#D4A84B").opacity(0.12) : .white.opacity(0.04))
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .strokeBorder(
                                        isSelected ? Color(hex: "#D4A84B").opacity(0.5) : .white.opacity(0.07),
                                        lineWidth: isSelected ? 1 : 0.5
                                    )
                            )
                            .scaleEffect(isSelected ? 1.02 : 1.0)

                            if !isFree {
                                Image(systemName: "crown.fill")
                                    .font(.system(size: 10))
                                    .foregroundStyle(Color(hex: "#D4A84B").opacity(0.8))
                                    .padding(8)
                            }
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 32)
        }
    }

    var previewStep: some View {
        VStack(spacing: 0) {
            VStack(spacing: 8) {
                Text(String(localized: "onboarding.preview.title"))
                    .font(.system(size: 26, weight: .bold, design: .serif))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
            }
            .padding(.bottom, 32)

            // Mini card preview
            ZStack {
                LinearGradient(
                    colors: [Color(hex: "#1a1409"), Color(hex: "#0d0d0d")],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                VStack(alignment: .leading, spacing: 12) {
                    Text(String(localized: "onboarding.preview.topic"))
                        .font(.system(size: 9, weight: .semibold))
                        .tracking(3)
                        .foregroundStyle(.white.opacity(0.4))
                    Text(String(localized: "onboarding.preview.quote"))
                        .font(.system(size: 18, weight: .medium, design: .serif))
                        .foregroundStyle(.white)
                        .lineSpacing(4)
                    Text(String(localized: "onboarding.preview.author"))
                        .font(.system(size: 12))
                        .foregroundStyle(.white.opacity(0.5))
                    Rectangle()
                        .fill(.white.opacity(0.06))
                        .frame(height: 0.5)
                        .padding(.vertical, 4)
                    HStack(spacing: 4) {
                        Image(systemName: "arrow.up.right").font(.system(size: 9, weight: .bold))
                        Text(String(localized: "card.try_today")).font(.system(size: 10, weight: .semibold)).tracking(0.5)
                    }
                    .foregroundStyle(Color(hex: "#D4A84B"))
                    Text(String(localized: "onboarding.preview.action"))
                        .font(.system(size: 12))
                        .foregroundStyle(.white.opacity(0.55))
                        .lineSpacing(3)
                }
                .padding(20)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(height: 160)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .overlay(RoundedRectangle(cornerRadius: 20).strokeBorder(.white.opacity(0.08), lineWidth: 0.5))
            .rotationEffect(.degrees(-1.5))
            .shadow(color: .black.opacity(0.4), radius: 20, y: 10)
            .padding(.horizontal, 40)
            .padding(.bottom, 36)

            // Gesture hints
            HStack(spacing: 0) {
                gestureHint(icon: "arrow.up", text: String(localized: "onboarding.hint.swipe"))
                Spacer()
                gestureHint(icon: "heart", text: String(localized: "onboarding.hint.doubletap"))
                Spacer()
                gestureHint(icon: "bell", text: String(localized: "onboarding.hint.morning"))
            }
            .padding(.horizontal, 48)
        }
    }

    var notificationStep: some View {
        VStack(spacing: 0) {
            Image(systemName: "sun.horizon.fill")
                .font(.system(size: 56))
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color(hex: "#D4A84B"), Color(hex: "#E8C070")],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .padding(.bottom, 28)

            Text(String(localized: "settings.notif.morning"))
                .font(.system(size: 28, weight: .bold, design: .serif))
                .foregroundStyle(.white)
                .padding(.bottom, 16)

            Text(String(localized: "onboarding.notif.desc"))
                .font(.system(size: 16))
                .foregroundStyle(.white.opacity(0.5))
                .multilineTextAlignment(.center)
                .lineSpacing(5)
                .padding(.horizontal, 40)
        }
    }

    // MARK: - Helpers

    func gestureHint(icon: String, text: String) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundStyle(Color(hex: "#D4A84B").opacity(0.7))
            Text(text)
                .font(.system(size: 11))
                .foregroundStyle(.white.opacity(0.35))
                .multilineTextAlignment(.center)
                .lineSpacing(2)
        }
    }

    var ctaLabel: String {
        switch step {
        case 0: return String(localized: "onboarding.start")
        case 1: return String(localized: "onboarding.continue")
        case 2: return String(localized: "onboarding.continue")
        case 3: return String(localized: "onboarding.notifications.enable")
        default: return String(localized: "onboarding.continue")
        }
    }

    var ctaEnabled: Bool {
        step != 1 || !selectedTopics.isEmpty
    }

    var ctaGlowOpacity: Double {
        step == 1 ? (selectedTopics.isEmpty ? 0 : 0.15) : 0.1
    }

    func handleCTA() {
        if step == 3 {
            notifManager.requestPermission()
            completeOnboarding()
        } else {
            withAnimation(.spring(response: 0.38, dampingFraction: 0.85)) {
                step += 1
            }
        }
    }

    func completeOnboarding() {
        let topics = selectedTopics.isEmpty ? Set(WisdomCard.Topic.allCases) : selectedTopics
        manager.completeOnboarding(topics: topics)
    }
}
