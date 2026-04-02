import XCTest
import Foundation

// MARK: - Helpers

private func parseStrings(_ url: URL) -> [String: String] {
    guard let content = try? String(contentsOf: url, encoding: .utf8) else { return [:] }
    var result: [String: String] = [:]
    let pattern = #""(.+?)"\s*=\s*"(.+?)";"#
    let regex = try? NSRegularExpression(pattern: pattern)
    let range = NSRange(content.startIndex..., in: content)
    regex?.enumerateMatches(in: content, range: range) { match, _, _ in
        guard let m = match,
              let k = Range(m.range(at: 1), in: content),
              let v = Range(m.range(at: 2), in: content) else { return }
        result[String(content[k])] = String(content[v])
    }
    return result
}

private func loadCards(_ filename: String) -> [[String: Any]] {
    // Look in the app bundle first, then the source directory
    let bundle = Bundle(for: LocalizationTestHelper.self)
    if let url = bundle.url(forResource: filename, withExtension: "json"),
       let data = try? Data(contentsOf: url),
       let cards = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]] {
        return cards
    }
    // Fallback: source directory relative path
    let projectRoot = URL(fileURLWithPath: #file)
        .deletingLastPathComponent()
        .deletingLastPathComponent()
    let paths: [String] = filename == "cards"
        ? ["ScrollWisdom/\(filename).json"]
        : ["ScrollWisdom/Data/\(filename).json"]
    for path in paths {
        let url = projectRoot.appendingPathComponent(path)
        if let data = try? Data(contentsOf: url),
           let cards = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]] {
            return cards
        }
    }
    return []
}

private func stringsURL(lang: String) -> URL {
    let lprojName = lang == "pt" ? "pt-BR" : lang
    return URL(fileURLWithPath: #file)
        .deletingLastPathComponent()
        .deletingLastPathComponent()
        .appendingPathComponent("ScrollWisdom/Localization/\(lprojName).lproj/Localizable.strings")
}

private let cyrillicRegex = try! NSRegularExpression(pattern: "[а-яёА-ЯЁ]")

private func containsCyrillic(_ s: String) -> Bool {
    cyrillicRegex.firstMatch(in: s, range: NSRange(s.startIndex..., in: s)) != nil
}

// Needed for Bundle(for:) lookup
private class LocalizationTestHelper {}

// MARK: - Keys intentionally identical to English (brand names or loanwords)
private let brandKeys: Set<String> = [
    "onboarding.title",         // App name
    "settings.premium.title",   // Brand name
    "card.share_via",           // App name in share text
]

// Keys that are legitimately the same word in specific languages
private let languageIdenticalKeys: [String: Set<String>] = [
    "de": ["tab.feed", "settings.version", "onboarding.welcome.author"],                        // Loanwords in German + proper names
    "es": ["paywall.error"],                                                                     // Same word in Spanish
    "fr": ["topic.discipline", "topic.leadership", "settings.notifications", "settings.version"], // Same in French
    "pt": [],
    "ru": [],
]

// MARK: - Tests

final class UIStringsTests: XCTestCase {
    let enStrings = parseStrings(stringsURL(lang: "en"))
    let languages = ["ru", "fr", "de", "es", "pt"]

    func testKeyCountMatches() {
        let enKeys = Set(enStrings.keys)
        for lang in languages {
            let strings = parseStrings(stringsURL(lang: lang))
            let missing = enKeys.subtracting(strings.keys)
            XCTAssert(missing.isEmpty, "[\(lang)] Missing keys: \(missing.sorted().joined(separator: ", "))")
        }
    }

    func testNoUntranslatedStrings() {
        let enKeys = Set(enStrings.keys)
        for lang in languages {
            let strings = parseStrings(stringsURL(lang: lang))
            let excluded = brandKeys.union(languageIdenticalKeys[lang] ?? [])
            let untranslated = enKeys
                .filter { !excluded.contains($0) }
                .filter { strings[$0] == enStrings[$0] }
            XCTAssert(untranslated.isEmpty, "[\(lang)] Untranslated: \(untranslated.sorted().joined(separator: ", "))")
        }
    }
}

final class CardJSONTests: XCTestCase {
    let enCards = loadCards("cards")
    lazy var enByID: [String: [String: Any]] = Dictionary(
        uniqueKeysWithValues: enCards.compactMap { card -> (String, [String: Any])? in
            guard let id = card["id"] as? String else { return nil }
            return (id, card)
        }
    )
    let nonRussianFiles: [(lang: String, filename: String)] = [
        ("fr", "cards_fr"),
        ("de", "cards_de"),
        ("es", "cards_es"),
        ("pt", "cards_pt-BR"),
    ]

    func testCardCount() {
        let files = [("en", "cards"), ("ru", "cards_ru")] + nonRussianFiles
        for (lang, file) in files {
            let cards = loadCards(file)
            XCTAssertEqual(cards.count, 350, "[\(lang)] Expected 350 cards, got \(cards.count)")
        }
    }

    func testTopicCount() {
        let allFiles = [("ru", "cards_ru"), ("en", "cards")] + nonRussianFiles
        let topics = ["stoicism", "discipline", "health", "money", "leadership", "relationships", "psychology"]
        for (lang, file) in allFiles {
            let cards = loadCards(file)
            for topic in topics {
                let count = cards.filter { ($0["topic"] as? String) == topic }.count
                XCTAssertEqual(count, 50, "[\(lang)] Topic '\(topic)' has \(count) cards, expected 50")
            }
        }
    }

    func testNoCyrillicInNonRussian() {
        for (lang, file) in nonRussianFiles {
            let cards = loadCards(file)
            var offenders: [String] = []
            for card in cards {
                let id = card["id"] as? String ?? "?"
                for field in ["quote", "author", "source", "story", "action"] {
                    if let val = card[field] as? String, containsCyrillic(val) {
                        offenders.append("\(id).\(field)")
                    }
                }
            }
            XCTAssert(offenders.isEmpty, "[\(lang)] Cyrillic found in: \(offenders.prefix(10).joined(separator: ", "))")
        }
    }

    func testNoUntranslatedQuotes() {
        for (lang, file) in nonRussianFiles {
            let cards = loadCards(file)
            var untranslated: [String] = []
            for card in cards {
                guard let id = card["id"] as? String,
                      let quote = card["quote"] as? String,
                      let enCard = enByID[id],
                      let enQuote = enCard["quote"] as? String else { continue }
                if quote == enQuote { untranslated.append(id) }
            }
            XCTAssert(untranslated.isEmpty, "[\(lang)] Untranslated IDs: \(untranslated.prefix(10).joined(separator: ", "))")
        }
    }

    func testRequiredFields() {
        let allFiles = [("ru", "cards_ru"), ("en", "cards")] + nonRussianFiles
        let required = ["id", "quote", "author", "source", "story", "action", "topic"]
        for (lang, file) in allFiles {
            let cards = loadCards(file)
            for card in cards {
                let id = card["id"] as? String ?? "?"
                for field in required {
                    let val = card[field] as? String ?? ""
                    XCTAssertFalse(val.isEmpty, "[\(lang)] Card \(id) missing '\(field)'")
                }
            }
        }
    }

    func testValidTopics() {
        let valid: Set<String> = ["stoicism", "discipline", "health", "money", "leadership", "relationships", "psychology"]
        let allFiles = [("ru", "cards_ru"), ("en", "cards")] + nonRussianFiles
        for (lang, file) in allFiles {
            let cards = loadCards(file)
            for card in cards {
                let id = card["id"] as? String ?? "?"
                let topic = card["topic"] as? String ?? ""
                XCTAssert(valid.contains(topic), "[\(lang)] Card \(id) invalid topic '\(topic)'")
            }
        }
    }
}

final class HardcodedStringTests: XCTestCase {
    // Checks that Swift source files contain no hardcoded Russian text
    func testNoHardcodedCyrillicInSwiftSources() {
        let projectRoot = URL(fileURLWithPath: #file)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .appendingPathComponent("ScrollWisdom")

        guard let enumerator = FileManager.default.enumerator(
            at: projectRoot,
            includingPropertiesForKeys: nil
        ) else {
            XCTFail("Cannot enumerate source files")
            return
        }

        let cyrillic = try! NSRegularExpression(pattern: "[а-яёА-ЯЁ]")
        var offenders: [String] = []

        // Files with intentional Cyrillic in locale-switched blocks
        let allowedFiles: Set<String> = ["NotificationManager.swift"]

        for case let fileURL as URL in enumerator {
            guard fileURL.pathExtension == "swift" else { continue }
            guard !allowedFiles.contains(fileURL.lastPathComponent) else { continue }
            guard let source = try? String(contentsOf: fileURL, encoding: .utf8) else { continue }

            // Check each line for Cyrillic outside of comments
            let lines = source.components(separatedBy: "\n")
            for (i, line) in lines.enumerated() {
                let trimmed = line.trimmingCharacters(in: .whitespaces)
                // Skip pure comment lines and localization .strings references
                if trimmed.hasPrefix("//") { continue }
                let range = NSRange(trimmed.startIndex..., in: trimmed)
                if cyrillic.firstMatch(in: trimmed, range: range) != nil {
                    let name = fileURL.lastPathComponent
                    offenders.append("\(name):\(i+1) → \(trimmed.prefix(80))")
                }
            }
        }

        XCTAssert(offenders.isEmpty,
            "Hardcoded Cyrillic found in Swift sources:\n" + offenders.joined(separator: "\n"))
    }
}
