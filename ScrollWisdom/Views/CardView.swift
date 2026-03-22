import SwiftUI

struct CardView: View {
    let card: WisdomCard
    let isSaved: Bool
    let onSave: () -> Void
    let onShare: () -> Void
    
    @State private var showHeart = false
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: card.topic.gradient.map { Color(hex: $0) },
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 0) {
                Spacer().frame(height: 60)
                
                Text(card.topic.displayName.uppercased())
                    .font(.system(size: 11, weight: .semibold))
                    .tracking(3)
                    .foregroundStyle(.white.opacity(0.4))
                    .padding(.horizontal, 28)
                
                Spacer().frame(height: 28)
                
                Text("\u{201C}\(card.quote)\u{201D}")
                    .font(.system(size: 24, weight: .medium, design: .serif))
                    .foregroundStyle(.white)
                    .lineSpacing(5)
                    .padding(.horizontal, 28)
                
                Spacer().frame(height: 16)
                
                HStack(spacing: 8) {
                    Rectangle().fill(.white.opacity(0.3)).frame(width: 20, height: 1)
                    Text(card.author)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(.white.opacity(0.6))
                    if !card.source.isEmpty {
                        Text("\u{00B7}  \(card.source)")
                            .font(.system(size: 12))
                            .foregroundStyle(.white.opacity(0.35))
                    }
                }
                .padding(.horizontal, 28)
                
                Spacer().frame(height: 24)
                
                Text(card.story)
                    .font(.system(size: 15))
                    .foregroundStyle(.white.opacity(0.7))
                    .lineSpacing(5)
                    .padding(.horizontal, 28)
                
                Spacer().frame(height: 20)
                
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 6) {
                        Image(systemName: "arrow.up.right").font(.system(size: 11, weight: .bold))
                        Text(String(localized: "card.try_today"))
                            .font(.system(size: 12, weight: .semibold)).tracking(1)
                    }
                    .foregroundStyle(Color(hex: "#f0a500"))
                    
                    Text(card.action)
                        .font(.system(size: 14))
                        .foregroundStyle(.white.opacity(0.8))
                        .lineSpacing(4)
                }
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(.white.opacity(0.06))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .padding(.horizontal, 28)
                
                Spacer()
                
                HStack(spacing: 32) {
                    Button(action: onSave) {
                        VStack(spacing: 4) {
                            Image(systemName: isSaved ? "bookmark.fill" : "bookmark").font(.system(size: 22))
                            Text(String(localized: "card.save")).font(.system(size: 10))
                        }
                        .foregroundStyle(.white.opacity(isSaved ? 1 : 0.5))
                    }
                    Button(action: onShare) {
                        VStack(spacing: 4) {
                            Image(systemName: "square.and.arrow.up").font(.system(size: 22))
                            Text(String(localized: "card.share")).font(.system(size: 10))
                        }
                        .foregroundStyle(.white.opacity(0.5))
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.bottom, 100)
            }
            
            if showHeart {
                Image(systemName: "heart.fill")
                    .font(.system(size: 80))
                    .foregroundStyle(.white)
                    .transition(.scale.combined(with: .opacity))
            }
        }
        .onTapGesture(count: 2) { doubleTapSave() }
    }
    
    private func doubleTapSave() {
        if !isSaved { onSave() }
        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) { showHeart = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            withAnimation(.easeOut(duration: 0.3)) { showHeart = false }
        }
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 6: (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default: (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(.sRGB, red: Double(r)/255, green: Double(g)/255, blue: Double(b)/255, opacity: Double(a)/255)
    }
}
