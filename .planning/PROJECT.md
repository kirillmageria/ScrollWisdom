# ScrollWisdom

## What This Is

iOS-приложение для ежедневной доставки философской мудрости в стиле TikTok — вертикальный фид с карточками от стоиков (Марк Аврелий, Эпиктет, Сенека). Каждая карточка содержит цитату, контекст и конкретное действие "Попробуй сегодня". Монетизация через подписку (freemium): 2 топика бесплатно, 3 в premium.

## Core Value

Пользователь открывает приложение каждое утро и получает одну практичную мудрость — быстро, красиво, с конкретным действием на день.

## Requirements

### Validated

<!-- Уже реализовано и работает -->

- ✓ Вертикальный фид с пагинацией (TikTok-стиль) — v0
- ✓ 900+ карточек мудрости с историями и действиями — v0
- ✓ Сохранение карточек с поиском — v0
- ✓ Onboarding в 3 шага с выбором топиков — v0
- ✓ Paywall с подпиской (StoreKit 2), monthly/yearly — v0
- ✓ Push-уведомления с настройкой времени — v0
- ✓ Streak-трекер — v0
- ✓ 6 языков: EN, RU, ES, DE, FR, PT-BR — v0
- ✓ 5 тем (2 бесплатных, 3 premium) — v0

### Active

<!-- Текущий scope — Milestone 1: Release -->

- [ ] Финальные баги и polish перед релизом
- [ ] Privacy Policy и Terms of Service с реальными URL
- [ ] Crash-репортинг (Crashlytics)
- [ ] App Store Connect настройка и submission

### Out of Scope

- **Экспорт карточек как картинок** — отложено до v2; не блокирует релиз, но убрать обещание из paywall
- **Аналитика (Firebase/Mixpanel)** — отложено до v2; на старте трафика мало, усложнит релиз
- **Android версия** — iOS only
- **Социальные фичи** — лайки, комментарии, sharing между пользователями; не в концепции MVP

## Context

- SwiftUI + `@Observable` (iOS 17+), StoreKit 2, UserNotifications
- Минимальная версия iOS: 15.1 (StoreKit 2), но `@Observable` требует iOS 17+
- Проект близок к релизу (~85-90% готов), основные баги уже исправлены в текущей сессии
- Продукты в App Store Connect ещё не созданы
- Privacy Policy / Terms пока указывают на example.com — блокирует submission

## Constraints

- **Platform**: iOS 17+ из-за `@Observable` macro
- **Monetization**: StoreKit 2, продукты нужно создать в App Store Connect до submission
- **Legal**: Privacy Policy обязательна для subscription-приложений по правилам Apple

## Key Decisions

| Decision | Rationale | Outcome |
|----------|-----------|---------|
| `@Observable` вместо `@StateObject` | Современный паттерн iOS 17+ | — Pending |
| StoreKit 2 | Нативный, безопасный, без third-party | ✓ Good |
| Freemium: 2 бесплатных топика | Снижает барьер входа, мотивирует upgrade | — Pending |
| Убрать экспорт из paywall до релиза | Не обещать то, чего нет | — Pending |
| Отложить аналитику | Ускорить релиз, добавить в v2 | — Pending |

---
*Last updated: 2026-03-25 после инициализации проекта*
