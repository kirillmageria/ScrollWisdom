import SwiftUI
import StoreKit

struct FeedView: View {
    @Environment(ContentManager.self) var manager
    @Environment(StoreManager.self) var store
    @Environment(\.requestReview) private var requestReview
    @State private var feedCards: [WisdomCard] = []
    @State private var currentCardID: String?
    @State private var showPaywall = false
    private let freeSaveLimit = 10

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
                                onSave: {
                                    if !manager.isSaved(card) && !store.isPremium && manager.savedCardIDs.count >= freeSaveLimit {
                                        showPaywall = true
                                        return
                                    }
                                    manager.toggleSave(card)
                                    if manager.savedCardIDs.count == 3 {
                                        requestReview()
                                    }
                                },
                                onShare: { shareCard(card) }
                            )
                            .containerRelativeFrame(.vertical)
                            .id(card.id)
                            .onAppear {
                                if index >= feedCards.count - 3 { appendMore() }
                            }
                        }
                    }
                    .scrollTargetLayout()
                }
                .scrollTargetBehavior(.paging)
                .scrollPosition(id: $currentCardID)
                .ignoresSafeArea()
                .onAppear {
                    if currentCardID == nil, let first = feedCards.first {
                        currentCardID = first.id
                        manager.markViewed(cardID: first.id)
                    }
                }
                .onChange(of: currentCardID) { _, newID in
                    if let newID {
                        manager.markViewed(cardID: newID)
                        if manager.cardsViewedToday == 10 {
                            requestReview()
                        }
                    }
                }

                // Top overlay — streak
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
        .onAppear {
            if feedCards.isEmpty {
                loadFeed()
            }
        }
        .onChange(of: store.isPremium) { _, _ in
            loadFeed()
        }
        .onChange(of: manager.selectedTopics) { _, _ in
            loadFeed()
        }
        .sheet(isPresented: $showPaywall) {
            PaywallView()
                .environment(store)
        }
    }

    private func loadFeed() {
        let available = store.availableTopics()
        feedCards = manager.feedCards(availableTopics: available)
        if feedCards.isEmpty {
            // selectedTopics не пересекается с available (напр. выбраны только premium-топики без подписки)
            // показываем все доступные карточки и сбрасываем selectedTopics
            manager.resetTopics(to: available)
            feedCards = manager.feedCards(availableTopics: available)
        }
    }

    private func appendMore() {
        let available = store.availableTopics()
        let more = manager.feedCards(availableTopics: available).map { card in
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
