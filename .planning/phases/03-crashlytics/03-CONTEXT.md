# Phase 3: Crashlytics - Context

**Gathered:** 2026-03-25
**Status:** Ready for planning

<domain>
## Phase Boundary

Интегрировать Firebase Crashlytics для мониторинга стабильности после релиза.
Только crash reporting — аналитика событий (FirebaseAnalytics) отложена до v2.

</domain>

<decisions>
## Implementation Decisions

### Инициализация Firebase
- **D-01:** Вызывать `FirebaseApp.configure()` в `init()` метода `@main` struct `ScrollWisdomApp` — без AppDelegate. Это официально поддерживаемый паттерн Firebase для чистых SwiftUI apps.

### Тестовый краш
- **D-02:** Добавить debug-only кнопку в `SettingsView` за `#if DEBUG`:
  ```swift
  #if DEBUG
  Button("Test Crash") { fatalError("Test crash") }
  #endif
  ```
  Кнопка не попадёт в release-сборку, можно тестировать в любое время.

### Метаданные crash reports
- **D-03:** Только базовые автоматические репорты — Crashlytics собирает крэши без дополнительного кода. Аналитика событий (user ID, paywall, subscription) отложена до v2 (решение из PROJECT.md).
- **D-04:** Опционально: добавить `Crashlytics.crashlytics().setCustomValue()` для subscription status (isPremium), чтобы различать крэши у платящих и бесплатных пользователей.

### Claude's Discretion
- Точное место добавления subscription status custom value (в StoreManager или ScrollWisdomApp)
- Структура GoogleService-Info.plist в проекте

</decisions>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Project entry point
- `ScrollWisdom/ScrollWisdomApp.swift` — @main struct, здесь добавляется `init()` с `FirebaseApp.configure()`

### App state
- `ScrollWisdom/Models/StoreManager.swift` — subscription status (isPremium), нужен для custom value в Crashlytics

### Settings view (debug button)
- `ScrollWisdom/Views/SettingsView.swift` — сюда добавляется #if DEBUG кнопка тестового краша

### Requirements
- `.planning/REQUIREMENTS.md` — CRASH-01, CRASH-02, CRASH-03

</canonical_refs>

<specifics>
## Specific Ideas

- Firebase добавляется через Swift Package Manager (URL: https://github.com/firebase/firebase-ios-sdk)
- Продукт: `FirebaseCrashlytics` (не добавлять FirebaseAnalytics — аналитика отложена)
- Минимальная iOS версия проекта — 17.0 (совместимо с Firebase)

</specifics>

<deferred>
## Deferred Ideas

- FirebaseAnalytics — аналитика событий (onboarding, paywall, subscription) — v2
- Crashlytics user ID привязка — v2 вместе с аналитикой
- Кастомные non-fatal логи для ошибок StoreKit — v2

</deferred>

---

*Phase: 03-crashlytics*
*Context gathered: 2026-03-25*
