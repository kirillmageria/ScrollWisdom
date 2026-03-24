# Project State: ScrollWisdom

## Project Reference

See: .planning/PROJECT.md (updated 2026-03-25)

**Core value:** Пользователь открывает приложение каждое утро и получает одну практичную мудрость — быстро, красиво, с конкретным действием на день.
**Current focus:** Phase 1 — Bugs & Polish

## Current Phase

**Phase 1 — Bugs & Polish**
Status: Complete (1/1 plans done)
Completed: 2026-03-25

## Completed Phases

- Phase 1: Bugs & Polish (01-01-PLAN.md) -- 2026-03-25

## Decisions

- Used @Environment(\.requestReview) for rate button (SwiftUI native, iOS 16+)
- Used mailto: link for feedback (simple, no dependencies)
- Static DateFormatter on SettingsView struct (one-time allocation)

## Notes

- Проект инициализирован 2026-03-25
- В текущей сессии уже исправлены: сохранение топиков, счётчик карточек, thread safety StoreManager, фоллбек фида
- Продукты в App Store Connect ещё не созданы
- Privacy Policy / Terms указывают на example.com
- Phase 1 complete: export removed from paywall, settings buttons functional, dead code deleted

---
*Last updated: 2026-03-25*
