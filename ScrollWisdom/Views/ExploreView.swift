import SwiftUI

struct ExploreView: View {
    @Environment(ContentManager.self) var manager
    @State private var selectedTopic: WisdomCard.Topic?
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Topic chips
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            ForEach(WisdomCard.Topic.allCases, id: \.self) { topic in
                                TopicChip(
                                    topic: topic,
                                    isSelected: selectedTopic == topic,
                                    count: manager.allCards.filter { $0.topic == topic }.count
                                ) {
                                    withAnimation(.spring(response: 0.3)) {
                                        selectedTopic = selectedTopic == topic ? nil : topic
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                    
                    // Cards grid
                    let filtered = selectedTopic == nil
                        ? manager.allCards
                        : manager.allCards.filter { $0.topic == selectedTopic }
                    
                    LazyVStack(spacing: 12) {
                        ForEach(filtered) { card in
                            ExploreCard(card: card, isSaved: manager.isSaved(card)) {
                                manager.toggleSave(card)
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                }
                .padding(.top, 8)
                .padding(.bottom, 40)
            }
            .background(Color(.systemBackground))
            .navigationTitle("Explore")
        }
    }
}

struct TopicChip: View {
    let topic: WisdomCard.Topic
    let isSelected: Bool
    let count: Int
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Text(topic.emoji)
                    .font(.system(size: 14))
                Text(topic.displayName)
                    .font(.system(size: 13, weight: .medium))
                Text("\(count)")
                    .font(.system(size: 11))
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(isSelected ? Color.primary.opacity(0.1) : Color(.secondarySystemBackground))
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .strokeBorder(isSelected ? Color.primary.opacity(0.3) : Color.clear, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

struct ExploreCard: View {
    let card: WisdomCard
    let isSaved: Bool
    let onSave: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(card.topic.displayName.uppercased())
                    .font(.system(size: 10, weight: .semibold))
                    .tracking(1.5)
                    .foregroundStyle(.secondary)
                Spacer()
                Button(action: onSave) {
                    Image(systemName: isSaved ? "bookmark.fill" : "bookmark")
                        .font(.system(size: 14))
                        .foregroundStyle(isSaved ? .primary : .secondary)
                }
            }
            
            Text("\u{201C}\(card.quote)\u{201D}")
                .font(.system(size: 16, weight: .medium, design: .serif))
                .lineSpacing(3)
            
            Text("— \(card.author)")
                .font(.system(size: 13))
                .foregroundStyle(.secondary)
        }
        .padding(16)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}

#Preview {
    ExploreView()
        .environment(ContentManager())
}
