# Roadmap: ScrollWisdom

**Milestone:** v1.0 — App Store Release
**Goal:** Опубликовать приложение в App Store

---

## Phase 1 — Bugs & Polish

**Goal:** Устранить все оставшиеся баги и убрать нереализованные фичи из UI перед релизом.

**Requirements:** BUG-01, BUG-02, BUG-03, BUG-04, BUG-05

### Plans

**Plan 1.1 — Paywall & Settings cleanup**
- Убрать экспорт из PaywallView (фича, описание, иконка)
- Версия из `Bundle.main.infoDictionary["CFBundleShortVersionString"]`
- Кнопки Rate и Feedback в AboutRow — добавить действия (SKStoreReviewController + mailto)
- Удалить `filteredCards` из ContentManager
- Вынести `DateFormatter` в статическую переменную в SettingsView

**Verification:** Приложение собирается без предупреждений, paywall не упоминает экспорт, версия обновляется автоматически, кнопки работают.

---

## Phase 2 — Legal

**Goal:** Создать и опубликовать Privacy Policy и Terms of Service, обновить URL в коде.

**Requirements:** LEGAL-01, LEGAL-02, LEGAL-03

### Plans

**Plan 2.1 — Privacy Policy & Terms**
- Сгенерировать Privacy Policy (через /legal скилл или шаблон)
- Сгенерировать Terms of Service
- Опубликовать на хостинге (GitHub Pages, Notion или аналог)
- Заменить `https://example.com/terms` и `https://example.com/privacy` в PaywallView на реальные URL

**Verification:** Ссылки в приложении открывают реальные страницы с актуальным содержимым.

---

## Phase 3 — Crashlytics

**Goal:** Интегрировать crash reporting для мониторинга стабильности после релиза.

**Requirements:** CRASH-01, CRASH-02, CRASH-03

### Plans

**Plan 3.1 — Firebase Crashlytics integration**
- Создать Firebase проект, добавить iOS app
- Добавить Firebase SDK через Swift Package Manager
- Настроить `GoogleService-Info.plist`
- Инициализировать `FirebaseApp.configure()` в `ScrollWisdomApp.swift`
- Проверить что репорты приходят в консоль

**Verification:** Тестовый краш из debug-режима отображается в Firebase Console в течение нескольких минут.

---

## Phase 4 — App Store Submission

**Goal:** Опубликовать ScrollWisdom в App Store.

**Requirements:** STORE-01 — STORE-07

### Plans

**Plan 4.1 — App Store Connect setup**
- Создать App ID в Developer Portal
- Создать приложение в App Store Connect
- Создать subscription group с продуктами monthly ($3.99) и yearly ($29.99), 3-дневный триал
- Настроить sandbox тестирование

**Plan 4.2 — Store assets**
- Скриншоты для iPhone 6.7" (iPhone 15 Pro Max) и 6.1"
- Описание приложения EN + RU (основные языки)
- Ключевые слова (stoicism, wisdom, philosophy, daily quotes, marcus aurelius...)
- Иконка приложения финальная

**Plan 4.3 — TestFlight & Submit**
- Архивировать и загрузить билд через Xcode
- Пройти внутреннее тестирование TestFlight
- Заполнить все поля в App Store Connect (возрастной рейтинг, категория, privacy)
- Submit на ревью Apple

**Verification:** Приложение появляется в поиске App Store и доступно для загрузки. Подписка проходит через реальный StoreKit.

---

## Summary

| Phase | Focus | Requirements | Est. Complexity |
|-------|-------|-------------|-----------------|
| 1 | Bugs & Polish | BUG-01..05 | Low |
| 2 | Legal | LEGAL-01..03 | Low |
| 3 | Crashlytics | CRASH-01..03 | Low |
| 4 | App Store | STORE-01..07 | Medium |

---
*Created: 2026-03-25*
*Milestone: v1.0 App Store Release*
