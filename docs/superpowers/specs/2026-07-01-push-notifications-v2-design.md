# Push Notifications v2 — Design Spec

**Date:** 2026-07-01  
**Status:** Approved

## Problem

Current notification system sends 7 hardcoded quotes per language — not from the cards database. After 7 days without opening the app, notifications stop entirely. Users see the same 7 quotes in rotation indefinitely.

## Goals

- Use real cards from `cards.json` as notification content (quote + author)
- Cover 30 days of daily notifications without requiring the app to be opened
- Personalize to user's selected topics
- Recreate notifications immediately when user changes their topics

## Non-Goals

- Deep linking to a specific card on notification tap
- Server-side (APNs) push notifications
- Changing the re-engagement notification behavior

---

## Architecture

`NotificationManager` is the single class responsible for all notifications. No new classes introduced. Changes are self-contained within `NotificationManager` with one new call site in `ContentManager`.

`NotificationManager` loads `cards.json` directly (does not depend on `ContentManager`) to avoid circular dependencies.

---

## UserDefaults Keys

| Key | Type | Purpose |
|-----|------|---------|
| `notif_morning_hour` | Int | existing — user's chosen hour |
| `notif_morning_minute` | Int | existing — user's chosen minute |
| `notif_card_order` | [String] | shuffled list of card IDs for the current topic selection |
| `notif_last_card_index` | Int | next index to read from `notif_card_order` |

`notif_card_order` is generated once per topic selection: load all cards matching selected topics, shuffle, save IDs. When the index reaches the end, reshuffle and reset to 0. This guarantees no repeats until the full pool is exhausted.

---

## Notification Identifier Scheme

- Daily: `daily_wisdom_0` … `daily_wisdom_N` (up to 30)
- Re-engagement: `re_engagement` (unchanged)
- Total slots used: 31 of 64 iOS maximum

---

## Notification Format

```
Title: "[Author]"     →  "Marcus Aurelius"
Body:  "[Quote]"      →  "You have power over your mind — not outside events."
```

Quote is truncated to 150 characters with `…` if longer. No emoji in the title — author name as title matches the app's visual style.

---

## Methods

### `scheduleDailyNotifications()` — refactored (top-up mode)

Called on every app foreground. Does the minimum work needed:

1. Fetch pending notification requests from iOS
2. Count identifiers matching `daily_wisdom_*`
3. If count ≥ 7 → return early (sufficient buffer exists)
4. Find the fire date of the latest already-scheduled `daily_wisdom_*` (or today if none)
5. Load `(30 − count)` cards via `loadNotificationCards(count:)`
6. Schedule each card starting from the day after the latest scheduled date, at `morningHour:morningMinute`

### `rescheduleDailyNotifications()` — full rebuild

Called when time or topics change. Does not touch `notif_card_order` — caller is responsible for updating it before calling this method if topics changed.

1. Cancel all pending `daily_wisdom_*` notifications
2. Reset `notif_last_card_index` to 0
3. Load 30 cards via `loadNotificationCards(count:)`
4. Schedule starting from tomorrow at `morningHour:morningMinute`

### `onTopicsChanged()` — public, called by ContentManager

1. Read current `selectedTopics` from UserDefaults
2. Load matching cards from `cards.json`, shuffle, save IDs to `notif_card_order`
3. Call `rescheduleDailyNotifications()`

### `loadNotificationCards(count:) -> [NotifCard]` — private

1. Read `notif_card_order` from UserDefaults
2. If empty → generate: load `cards.json`, filter by `selectedTopics` from UserDefaults, shuffle IDs, save
3. Read `notif_last_card_index`
4. Slice `count` items starting at index (wrapping around with reshuffle if needed)
5. Update `notif_last_card_index`
6. Return cards with quote + author

`NotifCard` is a lightweight struct `{ quote: String, author: String }` — no need to decode full `WisdomCard`.

### `loadCardsJSON() -> [[String: Any]]` — private

Loads `cards.json` from Bundle. Reads `selectedTopics` from `UserDefaults` (key: `"selectedTopics"`) to filter. Returns array of matching cards. Falls back to empty array if file missing.

---

## Call Sites Changed

| File | Location | Change |
|------|----------|--------|
| `ScrollWisdomApp.swift` | `.onChange(of: scenePhase) { .active }` | Add `notificationManager.scheduleDailyNotifications()` alongside existing `resetReEngagement()` |
| `NotificationManager.swift` | `requestPermission()` granted branch | Replace `scheduleDailyNotifications()` with `rescheduleDailyNotifications()` |
| `NotificationManager.swift` | `updateTime(hour:minute:)` | Replace `scheduleDailyNotifications()` with `rescheduleDailyNotifications()` |
| `ContentManager.swift` | `updateTopics(_:)` and `setTopics(_:)` | Call `notificationManager.onTopicsChanged()` after saving topics |

`ContentManager` needs a reference to `NotificationManager`. Since both are `@Observable` singletons created in `ScrollWisdomApp`, inject via a `var notificationManager: NotificationManager?` property on `ContentManager` — set it in `ScrollWisdomApp` after both are initialized. Avoids changing `ContentManager.init()` signature.

---

## Edge Cases

**User has no topics selected:** Impossible — ContentManager enforces minimum 1 topic.

**cards.json unavailable:** `loadNotificationCards` returns empty array → `scheduleDailyNotifications` schedules nothing. Silent fail, no crash.

**User changes time in Settings:** `updateTime(hour:minute:)` calls `rescheduleDailyNotifications()` which cancels and rebuilds all 30 with new time. Re-engagement is not affected.

**Quote too long:** Truncate at 150 chars with `…`. iOS notification body has no hard character limit but truncates visually around 100–120 chars on lock screen. 150 gives a safe margin.

**Localization:** Cards are already localized — `ContentManager.loadCards()` picks the right file per locale. `NotificationManager` does the same: check device locale, pick `cards_ru.json` / `cards_es.json` / etc., fall back to `cards.json`.

---

## What Does NOT Change

- Re-engagement notification logic (timing, content, reset on app open)
- Permission request flow in OnboardingView
- `morningHour` / `morningMinute` defaults (08:00)
- Settings UI for notification time picker
