import SwiftUI

struct SavedView: View {
    @Environment(ContentManager.self) var manager
    @State private var searchText = ""
    
    var filtered: [WisdomCard] {
        if searchText.isEmpty { return manager.savedCards }
        return manager.savedCards.filter {
            $0.quote.localizedCaseInsensitiveContains(searchText) ||
            $0.author.localizedCaseInsensitiveContains(searchText) ||
            $0.topic.displayName.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    var body: some View {
        NavigationStack {
            Group {
                if manager.savedCards.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "bookmark").font(.system(size: 48)).foregroundStyle(.quaternary)
                        Text(String(localized: "saved.empty.title"))
                            .font(.system(size: 18, weight: .medium)).foregroundStyle(.secondary)
                        Text(String(localized: "saved.empty.subtitle"))
                            .font(.system(size: 14)).foregroundStyle(.tertiary).multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(filtered) { card in
                                SavedCard(card: card, isSaved: true) { manager.toggleSave(card) }
                            }
                        }
                        .padding(.horizontal, 20).padding(.top, 8).padding(.bottom, 40)
                    }
                    .searchable(text: $searchText, prompt: String(localized: "saved.search"))
                }
            }
            .background(Color(.systemBackground))
            .navigationTitle(String(localized: "saved.title"))
            .toolbar {
                if !manager.savedCards.isEmpty {
                    ToolbarItem(placement: .topBarTrailing) {
                        Text("saved.count \(manager.savedCards.count)")
                            .font(.system(size: 13)).foregroundStyle(.secondary)
                    }
                }
            }
        }
    }
}

struct SavedCard: View {
    let card: WisdomCard
    let isSaved: Bool
    let onSave: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(card.topic.displayName.uppercased())
                    .font(.system(size: 10, weight: .semibold)).tracking(1.5).foregroundStyle(.secondary)
                Spacer()
                Button(action: onSave) {
                    Image(systemName: isSaved ? "bookmark.fill" : "bookmark")
                        .font(.system(size: 14)).foregroundStyle(isSaved ? .primary : .secondary)
                }
            }
            Text("\u{201C}\(card.quote)\u{201D}")
                .font(.system(size: 16, weight: .medium, design: .serif)).lineSpacing(3)
            Text("— \(card.author)")
                .font(.system(size: 13)).foregroundStyle(.secondary)
        }
        .padding(16)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}
