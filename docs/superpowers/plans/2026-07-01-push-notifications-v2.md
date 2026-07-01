# Push Notifications v2 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace 7 hardcoded notification quotes with real cards from `cards.json`, scheduling 30 days of personalized daily notifications that respect the user's selected topics.

**Architecture:** `NotificationManager` loads `cards.json` directly from Bundle (mirroring `ContentManager.loadCards()` locale logic) and maintains a shuffled card order in UserDefaults to avoid repeats. `scheduleDailyNotifications()` tops up to 30 pending notifications on every app foreground; `rescheduleDailyNotifications()` rebuilds all 30 when time or topics change. `ContentManager` holds a weak optional reference to `NotificationManager` and calls `onTopicsChanged()` after topic mutations.

**Tech Stack:** Swift, UserNotifications framework, XCTest, `@Observable`, UserDefaults

## Global Constraints

- iOS 17+ (`@Observable` macro already in use)
- No new dependencies — Bundle-only card loading, no ContentManager dependency in NotificationManager
- Notification identifier format: `daily_wisdom_YYYY-MM-DD` (ISO8601 date, dash-separated)
- Re-engagement notification (`re_engagement`) is NOT changed
- Max 30 `daily_wisdom_*` pending at once (31 total with re-engagement, well within iOS 64-slot limit)
- Quote body truncated to 150 chars with `…` if longer
- Locale fallback: try locale-specific JSON first (`cards_ru.json` etc.), fall back to `cards.json`
- UserDefaults key for selected topics (already used by ContentManager): `"selectedTopics"`

---

## Task 1: Card loading infrastructure + unit tests

**Files:**
- Modify: `ScrollWisdom/Models/NotificationManager.swift`
- Create: `ScrollWisdomTests/NotificationManagerTests.swift`

**Interfaces:**
- Produces:
  - `struct NotifCardData: Decodable` — `{ id: String, quote: String, author: String, topic: String }`
  - `struct NotifCard` — `{ author: String, quote: String }`
  - `static func truncate(_ quote: String, to maxLength: Int = 150) -> String`
  - `static func selectCards(from allCards: [NotifCardData], order: inout [String], index: inout Int, count: Int) -> [NotifCard]`
  - `private func loadCardsJSON() -> [NotifCardData]`
  - `func loadNotificationCards(count: Int) -> [NotifCard]` — internal visibility for testing

- [ ] **Step 1: Add data types and UserDefaults keys to NotificationManager.swift**

In `NotificationManager.swift`, add after the existing `private let minuteKey` declarations:

```swift
// New UserDefaults keys
private let cardOrderKey = "notif_card_order"
private let cardIndexKey = "notif_last_card_index"

// Lightweight card types — avoids importing WisdomCard from ContentManager
struct NotifCardData: Decodable {
    let id: String
    let quote: String
    let author: String
    let topic: String
}

struct NotifCard {
    let author: String
    let quote: String
}
```

- [ ] **Step 2: Add truncate static helper**

In `NotificationManager.swift`, add before the `notificationQuotes` static var:

```swift
static func truncate(_ quote: String, to maxLength: Int = 150) -> String {
    guard quote.count > maxLength else { return quote }
    return String(quote.prefix(maxLength)) + "…"
}
```

- [ ] **Step 3: Add selectCards static helper**

In `NotificationManager.swift`, add after `truncate`:

```swift
static func selectCards(
    from allCards: [NotifCardData],
    order: inout [String],
    index: inout Int,
    count: Int
) -> [NotifCard] {
    guard count > 0, !allCards.isEmpty else { return [] }
    let cardDict = Dictionary(uniqueKeysWithValues: allCards.map { ($0.id, $0) })
    var result: [NotifCard] = []
    while result.count < count {
        if index >= order.count {
            order = allCards.map { $0.id }.shuffled()
            index = 0
        }
        let id = order[index]
        index += 1
        if let card = cardDict[id] {
            result.append(NotifCard(
                author: card.author,
                quote: truncate(card.quote)
            ))
        }
    }
    return result
}
```

- [ ] **Step 4: Add loadCardsJSON() private method**

In `NotificationManager.swift`, add after `selectCards`:

```swift
private func loadCardsJSON() -> [NotifCardData] {
    let locale = Locale.current.language.languageCode?.identifier ?? "en"
    let fileNames: [String]
    switch locale {
    case "ru": fileNames = ["cards_ru", "cards"]
    case "es": fileNames = ["cards_es", "cards"]
    case "de": fileNames = ["cards_de", "cards"]
    case "fr": fileNames = ["cards_fr", "cards"]
    case "pt": fileNames = ["cards_pt-BR", "cards"]
    default:   fileNames = ["cards"]
    }

    let selectedTopics = Set(
        (UserDefaults.standard.array(forKey: "selectedTopics") as? [String]) ?? []
    )

    for name in fileNames {
        guard let url = Bundle.main.url(forResource: name, withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let cards = try? JSONDecoder().decode([NotifCardData].self, from: data),
              !cards.isEmpty else { continue }
        if selectedTopics.isEmpty {
            return cards
        }
        return cards.filter { selectedTopics.contains($0.topic) }
    }
    return []
}
```

- [ ] **Step 5: Add loadNotificationCards(count:) method**

In `NotificationManager.swift`, add after `loadCardsJSON()`:

```swift
func loadNotificationCards(count: Int) -> [NotifCard] {
    guard count > 0 else { return [] }
    let allCards = loadCardsJSON()
    guard !allCards.isEmpty else { return [] }

    var order = UserDefaults.standard.stringArray(forKey: cardOrderKey) ?? []
    var index = UserDefaults.standard.integer(forKey: cardIndexKey)

    if order.isEmpty {
        order = allCards.map { $0.id }.shuffled()
        index = 0
    }

    let result = NotificationManager.selectCards(
        from: allCards,
        order: &order,
        index: &index,
        count: count
    )

    UserDefaults.standard.set(order, forKey: cardOrderKey)
    UserDefaults.standard.set(index, forKey: cardIndexKey)
    return result
}
```

- [ ] **Step 6: Create NotificationManagerTests.swift with failing tests**

Create `ScrollWisdomTests/NotificationManagerTests.swift`:

```swift
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
```

- [ ] **Step 7: Run tests — expect failure (selectCards not yet returning truncated quotes correctly or compile errors)**

```bash
cd ~/Desktop/ScrollWisdom && xcodebuild test \
  -scheme ScrollWisdom \
  -destination 'platform=iOS Simulator,name=iPhone 16' \
  -testClass NotificationManagerTests \
  2>&1 | grep -E "PASS|FAIL|error:|Build"
```

Expected: compile errors or test failures before implementation is complete. If all pass, verify `truncate` and `selectCards` match the code added in steps 2-3.

- [ ] **Step 8: Run tests — expect all passing**

After steps 1–5 complete the implementation, run again:

```bash
cd ~/Desktop/ScrollWisdom && xcodebuild test \
  -scheme ScrollWisdom \
  -destination 'platform=iOS Simulator,name=iPhone 16' \
  -testClass NotificationManagerTests \
  2>&1 | grep -E "PASS|FAIL|error:|Build"
```

Expected: `Test Suite 'NotificationManagerTests' passed`

- [ ] **Step 9: Commit**

```bash
cd ~/Desktop/ScrollWisdom && git add ScrollWisdom/Models/NotificationManager.swift ScrollWisdomTests/NotificationManagerTests.swift && git commit -m "feat: add card loading infrastructure for push notifications v2"
```

---

## Task 2: Scheduling methods + all wiring

**Files:**
- Modify: `ScrollWisdom/Models/NotificationManager.swift`
- Modify: `ScrollWisdom/Models/ContentManager.swift`
- Modify: `ScrollWisdom/ScrollWisdomApp.swift`

**Interfaces:**
- Consumes from Task 1:
  - `loadNotificationCards(count: Int) -> [NotifCard]`
  - `struct NotifCard { author: String, quote: String }`
- Produces:
  - `private func scheduleCards(_ cards: [NotifCard], startingFrom date: Date)` — shared scheduling helper
  - `func scheduleDailyNotifications()` — refactored (top-up, async)
  - `func rescheduleDailyNotifications()` — full rebuild (async)
  - `func onTopicsChanged()` — public, resets card order and rebuilds

- [ ] **Step 1: Add scheduleCards private helper to NotificationManager.swift**

Add after `loadNotificationCards`:

```swift
private func scheduleCards(_ cards: [NotifCard], startingFrom date: Date) {
    let formatter = ISO8601DateFormatter()
    formatter.formatOptions = [.withFullDate, .withDashSeparatorInDate]

    for (i, card) in cards.enumerated() {
        guard let fireDate = Calendar.current.date(byAdding: .day, value: i, to: date) else { continue }
        let dateString = formatter.string(from: fireDate)

        let content = UNMutableNotificationContent()
        content.title = card.author
        content.body = card.quote
        content.sound = .default

        var components = Calendar.current.dateComponents([.year, .month, .day], from: fireDate)
        components.hour = morningHour
        components.minute = morningMinute

        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        let request = UNNotificationRequest(
            identifier: "daily_wisdom_\(dateString)",
            content: content,
            trigger: trigger
        )
        UNUserNotificationCenter.current().add(request)
    }
}
```

- [ ] **Step 2: Replace scheduleDailyNotifications() with top-up version**

Replace the existing `func scheduleDailyNotifications()` (lines ~50–85 in current file) with:

```swift
func scheduleDailyNotifications() {
    UNUserNotificationCenter.current().getPendingNotificationRequests { [weak self] requests in
        guard let self else { return }

        let dailyRequests = requests.filter { $0.identifier.hasPrefix("daily_wisdom_") }
        let count = dailyRequests.count
        guard count < 7 else { return }

        // Find latest scheduled date from existing identifiers
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withFullDate, .withDashSeparatorInDate]
        let latestDate = dailyRequests
            .compactMap { req -> Date? in
                let suffix = String(req.identifier.dropFirst("daily_wisdom_".count))
                return formatter.date(from: suffix)
            }
            .max() ?? Date()

        let needed = 30 - count
        let cards = self.loadNotificationCards(count: needed)
        guard !cards.isEmpty else { return }

        let startDate = Calendar.current.date(byAdding: .day, value: 1, to: latestDate) ?? Date()
        self.scheduleCards(cards, startingFrom: startDate)
    }
}
```

- [ ] **Step 3: Add rescheduleDailyNotifications()**

Add after the new `scheduleDailyNotifications()`:

```swift
func rescheduleDailyNotifications() {
    UNUserNotificationCenter.current().getPendingNotificationRequests { [weak self] requests in
        guard let self else { return }

        let dailyIDs = requests
            .filter { $0.identifier.hasPrefix("daily_wisdom_") }
            .map { $0.identifier }
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: dailyIDs)

        UserDefaults.standard.set(0, forKey: self.cardIndexKey)

        let cards = self.loadNotificationCards(count: 30)
        guard !cards.isEmpty else { return }

        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date()
        self.scheduleCards(cards, startingFrom: tomorrow)
    }
}
```

- [ ] **Step 4: Add onTopicsChanged()**

Add after `rescheduleDailyNotifications()`:

```swift
func onTopicsChanged() {
    // Rebuild card order for new topic selection before rescheduling
    let allCards = loadCardsJSON()
    let newOrder = allCards.map { $0.id }.shuffled()
    UserDefaults.standard.set(newOrder, forKey: cardOrderKey)
    UserDefaults.standard.set(0, forKey: cardIndexKey)
    rescheduleDailyNotifications()
}
```

- [ ] **Step 5: Update requestPermission() — use rescheduleDailyNotifications on grant**

In `requestPermission()`, replace:
```swift
self.scheduleDailyNotifications()
self.scheduleReEngagementNotification()
```
with:
```swift
self.rescheduleDailyNotifications()
self.scheduleReEngagementNotification()
```

- [ ] **Step 6: Update updateTime(hour:minute:) — use rescheduleDailyNotifications**

In `updateTime(hour:minute:)`, replace:
```swift
if isAuthorized {
    scheduleDailyNotifications()
}
```
with:
```swift
if isAuthorized {
    rescheduleDailyNotifications()
}
```

- [ ] **Step 7: Delete the hardcoded notificationQuotes static var**

Remove the entire `static var notificationQuotes: [NotifQuote]` block (the large switch statement with 7 quotes per language). It is no longer used. Keep `reEngagementQuotes` — it remains unchanged.

Also remove the `NotifQuote` struct only if it is no longer referenced. Check:
```bash
grep -n "NotifQuote\|notificationQuotes" ~/Desktop/ScrollWisdom/ScrollWisdom/Models/NotificationManager.swift
```
If the only remaining reference is `reEngagementQuotes`, which uses `NotifQuote`, keep the `NotifQuote` struct and delete only `notificationQuotes`.

- [ ] **Step 8: Add notificationManager property to ContentManager.swift**

In `ContentManager.swift`, after the `private let onboardingKey` line, add:

```swift
var notificationManager: NotificationManager?
```

- [ ] **Step 9: Call onTopicsChanged() in toggleTopic(_:)**

In `ContentManager.swift`, in `toggleTopic(_ topic:)`, add after `saveTopics()`:

```swift
notificationManager?.onTopicsChanged()
```

The method should now look like:
```swift
func toggleTopic(_ topic: WisdomCard.Topic) {
    if selectedTopics.contains(topic) {
        guard selectedTopics.count > 1 else { return }
        selectedTopics.remove(topic)
        AnalyticsManager.topicToggled(topic.rawValue, enabled: false)
    } else {
        selectedTopics.insert(topic)
        AnalyticsManager.topicToggled(topic.rawValue, enabled: true)
    }
    AnalyticsManager.setTopicsCount(selectedTopics.count)
    saveTopics()
    notificationManager?.onTopicsChanged()
}
```

- [ ] **Step 10: Call onTopicsChanged() in resetTopics(to:)**

In `ContentManager.swift`, in `resetTopics(to topics:)`, add after `saveTopics()`:

```swift
notificationManager?.onTopicsChanged()
```

The method should now look like:
```swift
func resetTopics(to topics: Set<WisdomCard.Topic>) {
    selectedTopics = topics
    saveTopics()
    notificationManager?.onTopicsChanged()
}
```

- [ ] **Step 11: Wire notificationManager into ContentManager in ScrollWisdomApp.swift**

In `ScrollWisdomApp.swift`, in the `.task { }` modifier, add the wiring before the Crashlytics line:

```swift
.task {
    manager.notificationManager = notificationManager
    Crashlytics.crashlytics().setCustomValue(
        storeManager.isPremium,
        forKey: "is_premium"
    )
}
```

- [ ] **Step 12: Add scheduleDailyNotifications() call on foreground in ScrollWisdomApp.swift**

In `ScrollWisdomApp.swift`, update the `onChange(of: scenePhase)` block:

```swift
.onChange(of: scenePhase) { _, phase in
    if phase == .active {
        notificationManager.resetReEngagement()
        notificationManager.scheduleDailyNotifications()
    }
}
```

- [ ] **Step 13: Build the project**

```bash
cd ~/Desktop/ScrollWisdom && xcodebuild build \
  -scheme ScrollWisdom \
  -destination 'platform=iOS Simulator,name=iPhone 16' \
  2>&1 | grep -E "error:|warning:|Build succeeded|Build FAILED"
```

Expected: `Build succeeded`

- [ ] **Step 14: Run all tests**

```bash
cd ~/Desktop/ScrollWisdom && xcodebuild test \
  -scheme ScrollWisdom \
  -destination 'platform=iOS Simulator,name=iPhone 16' \
  2>&1 | grep -E "PASS|FAIL|error:|Test Suite.*passed|Test Suite.*failed"
```

Expected: All test suites pass (existing LocalizationTests + new NotificationManagerTests).

- [ ] **Step 15: Manual smoke test in simulator**

1. Build and run on iOS Simulator (iPhone 16)
2. Complete onboarding (or clear app data to re-trigger it) — grant notifications when asked
3. After granting permission, open a terminal and run:
   ```bash
   # No direct way to inspect scheduled notifications from outside the app,
   # but you can verify via Xcode debugger or add a temporary debug log:
   # In scheduleDailyNotifications(), before return, add:
   # print("[Notif] Pending daily count: \(count), will schedule \(needed) more")
   ```
4. Check Xcode console for: `[Notif] Pending daily count: 0, will schedule 30 more`
5. Change topics in Settings → verify `onTopicsChanged()` is called (add `print` temporarily if needed)
6. Change notification time in Settings → verify notifications are rescheduled (same print approach)
7. Remove any debug `print` statements before committing

- [ ] **Step 16: Commit**

```bash
cd ~/Desktop/ScrollWisdom && git add \
  ScrollWisdom/Models/NotificationManager.swift \
  ScrollWisdom/Models/ContentManager.swift \
  ScrollWisdom/ScrollWisdomApp.swift \
  && git commit -m "feat: push notifications v2 — 30-day card-based scheduling with topic personalization"
```

---

## Post-Implementation Verification Checklist

Manual checks to do in the simulator before marking complete:

- [ ] Fresh install → grant notifications → verify 30 `daily_wisdom_YYYY-MM-DD` in pending (use Notification Debugger or temporary print in `scheduleCards`)
- [ ] Change topics → notifications immediately rescheduled with new topic cards
- [ ] Change notification time → all 30 rescheduled at new time
- [ ] Background app for 1 day and reopen → count stays near 30 (top-up fires)
- [ ] Re-engagement notification still schedules at +3 days, 19:00 (unchanged)
