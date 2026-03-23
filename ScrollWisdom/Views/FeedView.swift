import SwiftUI

struct FeedView: View {
    @Environment(ContentManager.self) var manager
    @State private var feedCards: [WisdomCard] = []
    
    var body: some View {
        ZStack {
            if feedCards.isEmpty {
                Color.black.ignoresSafeArea()
                VStack(spacing: 12) {
                    Image(systemName: "sparkles").font(.system(size: 40)).foregroundStyle(.white.opacity(0.3))
                    Text(String(localized: "feed.loading"))
                        .font(.system(size: 16)).foregroundStyle(.white.opacity(0.4))
                }
            } else {
                ScrollView(.vertical, showsIndicators: false) {
                    LazyVStack(spacing: 0) {
                        ForEach(Array(feedCards.enumerated()), id: \.element.id) { index, card in
                            CardView(
                                card: card,
                                isSaved: manager.isSaved(card),
                                onSave: { manager.toggleSave(card) },
                                onShare: { shareCard(card) }
                            )
                            .containerRelativeFrame(.vertical)
                            .onAppear {
                                manager.markViewed()
                                if index >= feedCards.count - 3 { appendMore() }
                            }
                        }
                    }
                }
                .scrollTargetBehavior(.paging)
                .ignoresSafeArea()
                
                VStack {
                    HStack {
                        Spacer()
                        HStack(spacing: 4) {
                            Image(systemName: "flame.fill").font(.system(size: 14))
                            Text("\(manager.streak)").font(.system(size: 14, weight: .semibold))
                        }
                        .foregroundStyle(.orange)
                        .padding(.horizontal, 12).padding(.vertical, 6)
                        .background(.ultraThinMaterial, in: Capsule())
                    }
                    .padding(.horizontal, 20).padding(.top, 8)
                    Spacer()
                }
            }
        }
        .onAppear { loadFeed() }
    }
    
    private func loadFeed() {
        feedCards = manager.filteredCards
        if feedCards.isEmpty { feedCards = ContentManager.sampleCards.shuffled() }
    }
    
    private func appendMore() {
        let more = manager.filteredCards.map { card in
            WisdomCard(
                id: "\(card.id)_\(feedCards.count + Int.random(in: 1000...9999))",
                quote: card.quote,
                author: card.author,
                source: card.source,
                story: card.story,
                action: card.action,
                topic: card.topic
            )
        }
        feedCards.append(contentsOf: more)
    }

    private func shareCard(_ card: WisdomCard) {
        let shareVia = String(localized: "card.share_via")
        let text = "\u{201C}\(card.quote)\u{201D}\n— \(card.author)\n\n\(card.action)\n\n\(shareVia)"
        let activityVC = UIActivityViewController(activityItems: [text], applicationActivities: nil)
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let root = windowScene.windows.first?.rootViewController {
            root.present(activityVC, animated: true)
        }
    }
}
