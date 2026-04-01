import SwiftUI

struct SavedView: View {
    @Environment(ContentManager.self) var manager
    @State private var searchText = ""
    @State private var selectedTopic: WisdomCard.Topic? = nil

    var filtered: [WisdomCard] {
        var cards = manager.savedCards
        if let topic = selectedTopic {
            cards = cards.filter { $0.topic == topic }
        }
        if !searchText.isEmpty {
            cards = cards.filter {
                $0.quote.localizedCaseInsensitiveContains(searchText) ||
                $0.author.localizedCaseInsensitiveContains(searchText) ||
                $0.topic.displayName.localizedCaseInsensitiveContains(searchText)
            }
        }
        return cards
    }

    var body: some View {
        ZStack {
            Color(hex: "#0a0a0f").ignoresSafeArea()

            if manager.savedCards.isEmpty {
                emptyState
            } else {
                ScrollView {
                    VStack(spacing: 0) {
                        // Header
                        HStack {
                            Text(String(localized: "saved.title"))
                                .font(.system(size: 28, weight: .bold, design: .serif))
                                .foregroundStyle(.white)
                            Spacer()
                            Text("\(manager.savedCards.count)")
                                .font(.system(size: 13, weight: .semibold, design: .monospaced))
                                .foregroundStyle(.white.opacity(0.3))
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(.white.opacity(0.06))
                                .clipShape(Capsule())
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 64)
                        .padding(.bottom, 16)

                        // Search
                        HStack(spacing: 10) {
                            Image(systemName: "magnifyingglass")
                                .font(.system(size: 14))
                                .foregroundStyle(.white.opacity(0.3))
                            TextField(String(localized: "saved.search"), text: $searchText)
                                .font(.system(size: 15))
                                .foregroundStyle(.white)
                                .tint(Color(hex: "#D4A84B"))
                                .autocorrectionDisabled()
                            if !searchText.isEmpty {
                                Button { searchText = "" } label: {
                                    Image(systemName: "xmark.circle.fill")
                                        .font(.system(size: 14))
                                        .foregroundStyle(.white.opacity(0.3))
                                }
                            }
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .background(.white.opacity(0.05))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .padding(.horizontal, 20)
                        .padding(.bottom, 14)

                        // Topic filters
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                TopicPill(label: "Все", emoji: nil, isSelected: selectedTopic == nil) {
                                    withAnimation(.spring(response: 0.3)) { selectedTopic = nil }
                                }
                                ForEach(WisdomCard.Topic.allCases, id: \.self) { topic in
                                    let count = manager.savedCards.filter { $0.topic == topic }.count
                                    if count > 0 {
                                        TopicPill(
                                            label: topic.displayName,
                                            emoji: topic.emoji,
                                            isSelected: selectedTopic == topic
                                        ) {
                                            withAnimation(.spring(response: 0.3)) {
                                                selectedTopic = selectedTopic == topic ? nil : topic
                                            }
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                        .padding(.bottom, 16)

                        // Cards
                        if filtered.isEmpty {
                            VStack(spacing: 10) {
                                Image(systemName: "magnifyingglass")
                                    .font(.system(size: 32))
                                    .foregroundStyle(.white.opacity(0.2))
                                Text("Ничего не найдено")
                                    .font(.system(size: 15))
                                    .foregroundStyle(.white.opacity(0.3))
                            }
                            .padding(.top, 60)
                        } else {
                            LazyVStack(spacing: 12) {
                                ForEach(filtered) { card in
                                    SavedCard(card: card) {
                                        withAnimation(.spring(response: 0.35)) {
                                            manager.toggleSave(card)
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.bottom, 100)
                        }
                    }
                }
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "bookmark")
                .font(.system(size: 44))
                .foregroundStyle(.white.opacity(0.15))
            Text(String(localized: "saved.empty.title"))
                .font(.system(size: 18, weight: .semibold, design: .serif))
                .foregroundStyle(.white.opacity(0.5))
            Text(String(localized: "saved.empty.subtitle"))
                .font(.system(size: 14))
                .foregroundStyle(.white.opacity(0.25))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 48)
        }
    }
}

// MARK: - Topic Pill

struct TopicPill: View {
    let label: String
    let emoji: String?
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 5) {
                if let emoji {
                    Text(emoji).font(.system(size: 12))
                }
                Text(label)
                    .font(.system(size: 13, weight: isSelected ? .semibold : .regular))
            }
            .foregroundStyle(isSelected ? Color(hex: "#D4A84B") : .white.opacity(0.45))
            .padding(.horizontal, 14)
            .padding(.vertical, 7)
            .background(isSelected ? Color(hex: "#D4A84B").opacity(0.12) : .white.opacity(0.05))
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .strokeBorder(
                        isSelected ? Color(hex: "#D4A84B").opacity(0.4) : .clear,
                        lineWidth: 1
                    )
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Saved Card

struct SavedCard: View {
    let card: WisdomCard
    let onRemove: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Topic
            HStack {
                Text(card.topic.emoji + "  " + card.topic.displayName.uppercased())
                    .font(.system(size: 10, weight: .semibold))
                    .tracking(1.5)
                    .foregroundStyle(.white.opacity(0.35))
                Spacer()
                Button(action: onRemove) {
                    Image(systemName: "bookmark.fill")
                        .font(.system(size: 14))
                        .foregroundStyle(Color(hex: "#D4A84B").opacity(0.7))
                }
            }
            .padding(.bottom, 12)

            // Quote
            Text(card.quote)
                .font(.system(size: 17, weight: .medium, design: .serif))
                .foregroundStyle(.white)
                .lineSpacing(4)
                .padding(.bottom, 8)

            // Author
            Text("— \(card.author)")
                .font(.system(size: 13))
                .foregroundStyle(.white.opacity(0.4))
                .padding(.bottom, 14)

            // Action block
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 5) {
                    Image(systemName: "arrow.up.right").font(.system(size: 9, weight: .bold))
                    Text(String(localized: "card.try_today"))
                        .font(.system(size: 10, weight: .semibold))
                        .tracking(0.8)
                }
                .foregroundStyle(Color(hex: "#D4A84B"))

                Text(card.action)
                    .font(.system(size: 13))
                    .foregroundStyle(.white.opacity(0.55))
                    .lineSpacing(3)
            }
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(.white.opacity(0.04))
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(hex: "#0f0f17"))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(.white.opacity(0.07), lineWidth: 0.5)
        )
    }
}
