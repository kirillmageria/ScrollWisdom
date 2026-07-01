import XCTest
@testable import ScrollWisdom

final class NotificationManagerTests: XCTestCase {

    // MARK: - truncate

    func test_truncate_shortQuote_unchanged() {
        let quote = "Be present."
        XCTAssertEqual(NotificationManager.truncate(quote), "Be present.")
    }

    func test_truncate_exactlyAtLimit_unchanged() {
        let quote = String(repeating: "a", count: 150)
        XCTAssertEqual(NotificationManager.truncate(quote), quote)
    }

    func test_truncate_longQuote_cutWithEllipsis() {
        let quote = String(repeating: "a", count: 151)
        let result = NotificationManager.truncate(quote)
        XCTAssertEqual(result.count, 151) // 150 chars + "…" (1 unicode scalar)
        XCTAssertTrue(result.hasSuffix("…"))
        XCTAssertFalse(result.hasPrefix(quote)) // not the full original
    }

    // MARK: - selectCards

    private func makeCards(_ count: Int) -> [NotifCardData] {
        (0..<count).map {
            NotifCardData(id: "id_\($0)", quote: "Quote \($0)", author: "Author \($0)", topic: "stoicism")
        }
    }

    func test_selectCards_returnsRequestedCount() {
        let cards = makeCards(10)
        var order: [String] = []
        var index = 0
        let result = NotificationManager.selectCards(from: cards, order: &order, index: &index, count: 5)
        XCTAssertEqual(result.count, 5)
    }

    func test_selectCards_emptyCards_returnsEmpty() {
        var order: [String] = []
        var index = 0
        let result = NotificationManager.selectCards(from: [], order: &order, index: &index, count: 5)
        XCTAssertTrue(result.isEmpty)
    }

    func test_selectCards_advancesIndex() {
        let cards = makeCards(10)
        var order = cards.map { $0.id }
        var index = 0
        _ = NotificationManager.selectCards(from: cards, order: &order, index: &index, count: 3)
        XCTAssertEqual(index, 3)
    }

    func test_selectCards_wrapsAroundWhenExhausted() {
        let cards = makeCards(3)
        var order = cards.map { $0.id }
        var index = 0
        // Request more than pool size — should wrap around
        let result = NotificationManager.selectCards(from: cards, order: &order, index: &index, count: 5)
        XCTAssertEqual(result.count, 5)
        // After wrap, index continues from position 2 (5 - 3 = 2)
        XCTAssertEqual(index, 2)
    }

    func test_selectCards_generatesOrderIfEmpty() {
        let cards = makeCards(5)
        var order: [String] = []
        var index = 0
        _ = NotificationManager.selectCards(from: cards, order: &order, index: &index, count: 3)
        XCTAssertFalse(order.isEmpty)
    }

    func test_selectCards_truncatesLongQuotes() {
        let longQuote = String(repeating: "x", count: 200)
        let card = NotifCardData(id: "1", quote: longQuote, author: "Author", topic: "stoicism")
        var order = ["1"]
        var index = 0
        let result = NotificationManager.selectCards(from: [card], order: &order, index: &index, count: 1)
        XCTAssertEqual(result.first?.quote.hasSuffix("…"), true)
        XCTAssertLessThanOrEqual(result.first?.quote.count ?? 0, 151) // 150 + "…"
    }
}
