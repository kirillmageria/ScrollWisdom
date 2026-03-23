import SwiftUI

struct OnboardingView: View {
    @Environment(ContentManager.self) var manager
    @Environment(NotificationManager.self) var notifManager
    @State private var step = 0
    @State private var selectedTopics: Set<WisdomCard.Topic> = []

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                switch step {
                case 0: welcomeStep
                case 1: topicStep
                case 2: readyStep
                default: EmptyView()
                }

                Spacer()

                HStack(spacing: 8) {
                    ForEach(0..<3, id: \.self) { i in
                        Circle()
                            .fill(i == step ? .white : .white.opacity(0.2))
                            .frame(width: 6, height: 6)
                    }
                }
                .padding(.bottom, 20)

                Button {
                    if step == 2 {
                        notifManager.requestPermission()
                        let topics = selectedTopics.isEmpty ? Set(WisdomCard.Topic.allCases) : selectedTopics
                        manager.completeOnboarding(topics: topics)
                    } else {
                        withAnimation(.spring(response: 0.4)) { step += 1 }
                    }
                } label: {
                    Text(step == 2 ? String(localized: "onboarding.start") : String(localized: "onboarding.continue"))
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(.black)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                .padding(.horizontal, 28)
                .padding(.bottom, 40)
            }
        }
    }

    var welcomeStep: some View {
        VStack(spacing: 20) {
            Text("🏛").font(.system(size: 64))
            Text(String(localized: "onboarding.title"))
                .font(.system(size: 32, weight: .bold, design: .serif))
                .foregroundStyle(.white)
            Text(String(localized: "onboarding.subtitle"))
                .font(.system(size: 16))
                .foregroundStyle(.white.opacity(0.5))
                .multilineTextAlignment(.center)
                .lineSpacing(4)
                .padding(.horizontal, 40)
        }
    }

    var topicStep: some View {
        VStack(spacing: 24) {
            Text(String(localized: "onboarding.topics.title"))
                .font(.system(size: 26, weight: .bold, design: .serif))
                .foregroundStyle(.white)
            Text(String(localized: "onboarding.topics.subtitle"))
                .font(.system(size: 15))
                .foregroundStyle(.white.opacity(0.4))

            VStack(spacing: 10) {
                ForEach(WisdomCard.Topic.allCases, id: \.self) { topic in
                    let isSelected = selectedTopics.contains(topic)
                    Button {
                        if isSelected { selectedTopics.remove(topic) } else { selectedTopics.insert(topic) }
                    } label: {
                        HStack {
                            Text(topic.emoji).font(.system(size: 20))
                            Text(topic.displayName).font(.system(size: 16, weight: .medium))
                            Spacer()
                            if isSelected { Image(systemName: "checkmark.circle.fill").font(.system(size: 20)) }
                        }
                        .foregroundStyle(.white)
                        .padding(.horizontal, 20).padding(.vertical, 14)
                        .background(isSelected ? .white.opacity(0.12) : .white.opacity(0.05))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay(RoundedRectangle(cornerRadius: 12).strokeBorder(isSelected ? .white.opacity(0.3) : .clear, lineWidth: 1))
                    }
                }
            }
            .padding(.horizontal, 28)
        }
    }

    var readyStep: some View {
        VStack(spacing: 20) {
            Image(systemName: "sparkles").font(.system(size: 48)).foregroundStyle(.white.opacity(0.6))
            Text(String(localized: "onboarding.ready.title"))
                .font(.system(size: 28, weight: .bold, design: .serif))
                .foregroundStyle(.white)
            VStack(alignment: .leading, spacing: 12) {
                featureRow(icon: "hand.draw", text: String(localized: "onboarding.ready.swipe"))
                featureRow(icon: "heart", text: String(localized: "onboarding.ready.save"))
                featureRow(icon: "bell.badge", text: String(localized: "onboarding.ready.notification"))
            }
            .padding(.horizontal, 40).padding(.top, 8)
        }
    }

    func featureRow(icon: String, text: String) -> some View {
        HStack(spacing: 14) {
            Image(systemName: icon).font(.system(size: 18)).foregroundStyle(.white.opacity(0.5)).frame(width: 28)
            Text(text).font(.system(size: 15)).foregroundStyle(.white.opacity(0.7))
        }
    }
}
