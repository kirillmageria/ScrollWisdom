import SwiftUI
import StoreKit

struct PaywallView: View {
    @Environment(StoreManager.self) var store
    @Environment(\.dismiss) var dismiss
    @State private var selectedPlan: String = StoreManager.yearlyID
    @State private var isPurchasing = false
    @State private var showError = false
    @State private var errorMessage = ""

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(hex: "#1a1a2e"), Color(hex: "#0a0a15")],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    // Close button
                    HStack {
                        Spacer()
                        Button { dismiss() } label: {
                            Image(systemName: "xmark")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(.white.opacity(0.4))
                                .frame(width: 30, height: 30)
                                .background(.white.opacity(0.08))
                                .clipShape(Circle())
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)

                    Spacer().frame(height: 24)

                    // Crown
                    ZStack {
                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: [Color(hex: "#f0a500").opacity(0.2), .clear],
                                    center: .center,
                                    startRadius: 10,
                                    endRadius: 60
                                )
                            )
                            .frame(width: 100, height: 100)

                        Image(systemName: "crown.fill")
                            .font(.system(size: 40))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [Color(hex: "#f0a500"), Color(hex: "#ff6b35")],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    }

                    Spacer().frame(height: 16)

                    Text(String(localized: "paywall.title"))
                        .font(.system(size: 26, weight: .bold, design: .serif))
                        .foregroundStyle(.white)

                    Spacer().frame(height: 6)

                    Text(String(localized: "paywall.subtitle"))
                        .font(.system(size: 14))
                        .foregroundStyle(.white.opacity(0.4))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)

                    Spacer().frame(height: 28)

                    // Features
                    VStack(spacing: 0) {
                        PaywallFeature(icon: "sparkles", color: "#f0a500",
                                       title: String(localized: "paywall.feature.topics.title"),
                                       desc: String(localized: "paywall.feature.topics.desc"),
                                       showDivider: true)
                        PaywallFeature(icon: "bookmark.fill", color: "#a855f7",
                                       title: String(localized: "paywall.feature.saves.title"),
                                       desc: String(localized: "paywall.feature.saves.desc"),
                                       showDivider: true)
                        PaywallFeature(icon: "bell.badge", color: "#3b82f6",
                                       title: String(localized: "paywall.feature.notifs.title"),
                                       desc: String(localized: "paywall.feature.notifs.desc"),
                                       showDivider: true)
                        PaywallFeature(icon: "doc.text", color: "#10b981",
                                       title: String(localized: "paywall.feature.export.title"),
                                       desc: String(localized: "paywall.feature.export.desc"),
                                       showDivider: false)
                    }
                    .padding(16)
                    .background(RoundedRectangle(cornerRadius: 16).fill(.white.opacity(0.04)))
                    .padding(.horizontal, 20)

                    Spacer().frame(height: 24)

                    // Plan selection
                    VStack(spacing: 10) {
                        PlanCard(
                            title: String(localized: "paywall.plan.yearly"),
                            price: store.yearlyProduct?.displayPrice ?? "$29.99",
                            detail: String(localized: "paywall.plan.yearly.detail"),
                            badge: String(localized: "paywall.plan.yearly.badge"),
                            isSelected: selectedPlan == StoreManager.yearlyID
                        ) { selectedPlan = StoreManager.yearlyID }

                        PlanCard(
                            title: String(localized: "paywall.plan.monthly"),
                            price: store.monthlyProduct?.displayPrice ?? "$3.99",
                            detail: String(localized: "paywall.plan.monthly.detail"),
                            badge: nil,
                            isSelected: selectedPlan == StoreManager.monthlyID
                        ) { selectedPlan = StoreManager.monthlyID }
                    }
                    .padding(.horizontal, 20)

                    Spacer().frame(height: 24)

                    // Subscribe button
                    Button {
                        Task { await subscribe() }
                    } label: {
                        Group {
                            if isPurchasing {
                                ProgressView().tint(.black)
                            } else {
                                Text(String(localized: "paywall.subscribe"))
                                    .font(.system(size: 17, weight: .bold))
                            }
                        }
                        .foregroundStyle(.black)
                        .frame(maxWidth: .infinity)
                        .frame(height: 54)
                        .background(
                            LinearGradient(
                                colors: [Color(hex: "#f0a500"), Color(hex: "#ff6b35")],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                    .disabled(isPurchasing)
                    .padding(.horizontal, 20)

                    Spacer().frame(height: 10)

                    Text(String(localized: "paywall.trial"))
                        .font(.system(size: 12))
                        .foregroundStyle(.white.opacity(0.3))

                    Spacer().frame(height: 20)

                    // Restore + legal
                    HStack(spacing: 16) {
                        Button {
                            Task { await store.restore() }
                        } label: {
                            Text(String(localized: "paywall.restore"))
                                .font(.system(size: 12))
                                .foregroundStyle(.white.opacity(0.3))
                        }

                        Circle().fill(.white.opacity(0.15)).frame(width: 3, height: 3)

                        Link(String(localized: "paywall.terms"), destination: URL(string: "https://example.com/terms")!)
                            .font(.system(size: 12))
                            .foregroundStyle(.white.opacity(0.3))

                        Circle().fill(.white.opacity(0.15)).frame(width: 3, height: 3)

                        Link(String(localized: "paywall.privacy"), destination: URL(string: "https://example.com/privacy")!)
                            .font(.system(size: 12))
                            .foregroundStyle(.white.opacity(0.3))
                    }

                    Spacer().frame(height: 40)
                }
            }
        }
        .alert(String(localized: "paywall.error"), isPresented: $showError) {
            Button("OK") {}
        } message: {
            Text(errorMessage)
        }
    }

    private func subscribe() async {
        isPurchasing = true
        let product = selectedPlan == StoreManager.yearlyID ? store.yearlyProduct : store.monthlyProduct
        guard let product else {
            errorMessage = "Product not available"
            showError = true
            isPurchasing = false
            return
        }
        do {
            let success = try await store.purchase(product)
            if success { dismiss() }
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
        isPurchasing = false
    }
}

// MARK: - Components

struct PaywallFeature: View {
    let icon: String
    let color: String
    let title: String
    let desc: String
    let showDivider: Bool

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                Circle()
                    .fill(Color(hex: color).opacity(0.15))
                    .frame(width: 36, height: 36)
                    .overlay(
                        Image(systemName: icon)
                            .font(.system(size: 15, weight: .medium))
                            .foregroundStyle(Color(hex: color))
                    )

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.white)
                    Text(desc)
                        .font(.system(size: 12))
                        .foregroundStyle(.white.opacity(0.35))
                }

                Spacer()
            }
            .padding(.vertical, 10)

            if showDivider {
                Rectangle()
                    .fill(.white.opacity(0.05))
                    .frame(height: 0.5)
                    .padding(.leading, 48)
            }
        }
    }
}

struct PlanCard: View {
    let title: String
    let price: String
    let detail: String
    let badge: String?
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                // Radio
                Circle()
                    .strokeBorder(isSelected ? Color(hex: "#f0a500") : .white.opacity(0.2), lineWidth: 2)
                    .frame(width: 22, height: 22)
                    .overlay(
                        Circle()
                            .fill(isSelected ? Color(hex: "#f0a500") : .clear)
                            .frame(width: 12, height: 12)
                    )

                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 8) {
                        Text(title)
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(.white)
                        if let badge {
                            Text(badge)
                                .font(.system(size: 10, weight: .bold))
                                .foregroundStyle(.black)
                                .padding(.horizontal, 7)
                                .padding(.vertical, 2)
                                .background(Color(hex: "#f0a500"))
                                .clipShape(Capsule())
                        }
                    }
                    Text(detail)
                        .font(.system(size: 12))
                        .foregroundStyle(.white.opacity(0.35))
                }

                Spacer()

                Text(price)
                    .font(.system(size: 17, weight: .bold))
                    .foregroundStyle(.white)
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(isSelected ? .white.opacity(0.06) : .white.opacity(0.02))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .strokeBorder(isSelected ? Color(hex: "#f0a500").opacity(0.6) : .white.opacity(0.08), lineWidth: isSelected ? 1.5 : 0.5)
            )
        }
    }
}
