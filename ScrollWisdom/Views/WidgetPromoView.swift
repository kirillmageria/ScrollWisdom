import SwiftUI

struct WidgetPromoView: View {
    @Environment(\.dismiss) var dismiss

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(hex: "#1a1a2e"), Color(hex: "#0a0a15")],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
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

                Spacer()

                // Widget mockup
                VStack(alignment: .leading, spacing: 0) {
                    Text("“")
                        .font(.system(size: 34, weight: .bold, design: .serif))
                        .foregroundStyle(Color(hex: "#f0a500"))
                        .frame(height: 22, alignment: .top)

                    Text(String(localized: "widget.promo.sample_quote"))
                        .font(.system(size: 14, weight: .medium, design: .serif))
                        .foregroundStyle(.white)
                        .lineSpacing(2)
                        .minimumScaleFactor(0.65)

                    Spacer(minLength: 6)

                    Text("MARCUS AURELIUS")
                        .font(.system(size: 9, weight: .semibold))
                        .tracking(1.2)
                        .foregroundStyle(Color(hex: "#f0a500"))
                }
                .padding(16)
                .frame(width: 160, height: 160)
                .background(
                    RoundedRectangle(cornerRadius: 36)
                        .fill(
                            LinearGradient(
                                colors: [Color(hex: "#1a1a2e"), Color(hex: "#0a0a15")],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 36)
                        .strokeBorder(.white.opacity(0.12), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.5), radius: 30, y: 10)

                Spacer().frame(height: 32)

                Text(String(localized: "widget.promo.title"))
                    .font(.system(size: 24, weight: .bold, design: .serif))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)

                Spacer().frame(height: 8)

                Text(String(localized: "widget.promo.subtitle"))
                    .font(.system(size: 14))
                    .foregroundStyle(.white.opacity(0.4))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)

                Spacer().frame(height: 28)

                VStack(spacing: 14) {
                    WidgetPromoStep(number: "1", text: String(localized: "widget.promo.step1"))
                    WidgetPromoStep(number: "2", text: String(localized: "widget.promo.step2"))
                    WidgetPromoStep(number: "3", text: String(localized: "widget.promo.step3"))
                }
                .padding(.horizontal, 32)

                Spacer()

                Button { dismiss() } label: {
                    Text(String(localized: "widget.promo.done"))
                        .font(.system(size: 17, weight: .bold))
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
                .padding(.horizontal, 20)
                .padding(.bottom, 24)
            }
        }
        .onAppear {
            AnalyticsManager.widgetPromoShown()
        }
    }
}

private struct WidgetPromoStep: View {
    let number: String
    let text: String

    var body: some View {
        HStack(spacing: 14) {
            Text(number)
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(Color(hex: "#f0a500"))
                .frame(width: 28, height: 28)
                .background(Circle().fill(Color(hex: "#f0a500").opacity(0.15)))

            Text(text)
                .font(.system(size: 14))
                .foregroundStyle(.white.opacity(0.8))
                .fixedSize(horizontal: false, vertical: true)

            Spacer()
        }
    }
}
