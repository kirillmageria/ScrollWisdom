//
//  ScrollWisdomWidget.swift
//  ScrollWisdomWidget
//
//  Created by Kirill Magerya on 21.07.2026.
//

import WidgetKit
import SwiftUI

// MARK: - Model (standalone copy — the widget bundles its own cards JSON)

struct WidgetCard: Codable {
    let id: String
    let quote: String
    let author: String
}

enum CardStore {
    static func loadCards() -> [WidgetCard] {
        // Locale.current in an extension resolves against the extension's own
        // localizations (en only), so read the user's system language list instead.
        let preferred = Locale.preferredLanguages.first ?? "en"
        let locale = String(preferred.prefix(2))

        let fileNames: [String]
        switch locale {
        case "ru": fileNames = ["cards_ru", "cards"]
        case "es": fileNames = ["cards_es", "cards"]
        case "de": fileNames = ["cards_de", "cards"]
        case "fr": fileNames = ["cards_fr", "cards"]
        case "pt": fileNames = ["cards_pt-BR", "cards"]
        default:   fileNames = ["cards"]
        }

        for name in fileNames {
            if let url = Bundle.main.url(forResource: name, withExtension: "json"),
               let data = try? Data(contentsOf: url),
               let cards = try? JSONDecoder().decode([WidgetCard].self, from: data),
               !cards.isEmpty {
                return cards
            }
        }
        return []
    }

    /// Deterministic card for a given date: same quote all day, new one tomorrow.
    static func card(for date: Date, maxQuoteLength: Int? = nil) -> WidgetCard {
        var cards = loadCards()
        if let maxQuoteLength {
            let short = cards.filter { $0.quote.count <= maxQuoteLength }
            if !short.isEmpty { cards = short }
        }
        guard !cards.isEmpty else {
            return WidgetCard(id: "fallback",
                              quote: "You have power over your mind — not outside events.",
                              author: "Marcus Aurelius")
        }
        let day = Calendar.current.ordinality(of: .day, in: .era, for: date) ?? 0
        return cards[day % cards.count]
    }
}

// MARK: - Timeline

struct QuoteEntry: TimelineEntry {
    let date: Date
    let card: WidgetCard
}

struct QuoteProvider: TimelineProvider {
    let maxQuoteLength: Int?

    func placeholder(in context: Context) -> QuoteEntry {
        QuoteEntry(date: .now, card: CardStore.card(for: .now, maxQuoteLength: maxQuoteLength))
    }

    func getSnapshot(in context: Context, completion: @escaping (QuoteEntry) -> Void) {
        completion(placeholder(in: context))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<QuoteEntry>) -> Void) {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: .now)
        // Entries for today + next 6 days; WidgetKit re-requests before they run out.
        let entries = (0..<7).compactMap { offset -> QuoteEntry? in
            guard let date = calendar.date(byAdding: .day, value: offset, to: today) else { return nil }
            return QuoteEntry(date: date, card: CardStore.card(for: date, maxQuoteLength: maxQuoteLength))
        }
        completion(Timeline(entries: entries, policy: .atEnd))
    }
}

// MARK: - Views

private let gold = Color(red: 0xF0 / 255, green: 0xA5 / 255, blue: 0x00 / 255)

struct QuoteWidgetView: View {
    let entry: QuoteEntry
    @Environment(\.widgetFamily) var family

    var body: some View {
        switch family {
        case .accessoryRectangular:
            VStack(alignment: .leading, spacing: 2) {
                Text(entry.card.quote)
                    .font(.system(size: 12, weight: .medium))
                    .lineLimit(3)
                    .minimumScaleFactor(0.8)
                Text("— \(entry.card.author)")
                    .font(.system(size: 10))
                    .opacity(0.7)
            }
            .containerBackground(.clear, for: .widget)
        default:
            VStack(alignment: .leading, spacing: 0) {
                Text("“")
                    .font(.system(size: family == .systemSmall ? 34 : 42, weight: .bold, design: .serif))
                    .foregroundStyle(gold)
                    .frame(height: family == .systemSmall ? 22 : 28, alignment: .top)

                Text(entry.card.quote)
                    .font(.system(size: family == .systemSmall ? 14 : 17, weight: .medium, design: .serif))
                    .foregroundStyle(.white)
                    .lineSpacing(2)
                    .minimumScaleFactor(0.65)

                Spacer(minLength: 6)

                Text(entry.card.author.uppercased())
                    .font(.system(size: family == .systemSmall ? 9 : 10, weight: .semibold))
                    .tracking(1.2)
                    .foregroundStyle(gold)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .containerBackground(for: .widget) {
                LinearGradient(
                    colors: [Color(red: 0x1A / 255, green: 0x1A / 255, blue: 0x2E / 255),
                             Color(red: 0x0A / 255, green: 0x0A / 255, blue: 0x15 / 255)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            }
        }
    }
}

// MARK: - Widget

struct ScrollWisdomWidget: Widget {
    let kind: String = "ScrollWisdomWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: QuoteProvider(maxQuoteLength: 120)) { entry in
            QuoteWidgetView(entry: entry)
        }
        .configurationDisplayName(String(localized: "widget.name", defaultValue: "Daily Wisdom"))
        .description(String(localized: "widget.description", defaultValue: "A new stoic quote every day."))
        .supportedFamilies([.systemSmall, .systemMedium, .accessoryRectangular])
    }
}

#Preview(as: .systemSmall) {
    ScrollWisdomWidget()
} timeline: {
    QuoteEntry(date: .now, card: CardStore.card(for: .now, maxQuoteLength: 120))
}

#Preview(as: .systemMedium) {
    ScrollWisdomWidget()
} timeline: {
    QuoteEntry(date: .now, card: CardStore.card(for: .now, maxQuoteLength: 120))
}
