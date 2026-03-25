---
gsd_state_version: 1.0
milestone: v1.0
milestone_name: milestone
status: In progress
last_updated: "2026-03-26T00:00:00.000Z"
progress:
  total_phases: 4
  completed_phases: 3
  total_plans: 3
  completed_plans: 3
---

# Project State: ScrollWisdom

## Project Reference

See: .planning/PROJECT.md (updated 2026-03-25)

**Core value:** Пользователь открывает приложение каждое утро и получает одну практичную мудрость — быстро, красиво, с конкретным действием на день.
**Current focus:** Phase 04 — App Store Submission

## Current Phase

**Phase 4 — App Store Submission**
Status: Not started

## Completed Phases

- Phase 1: Bugs & Polish (01-01-PLAN.md) -- 2026-03-25
- Phase 2: Legal (02-01-PLAN.md) -- 2026-03-25
- Phase 3: Crashlytics (03-01-PLAN.md) -- 2026-03-26

## Decisions

- Used @Environment(\.requestReview) for rate button (SwiftUI native, iOS 16+)
- Used mailto: link for feedback (simple, no dependencies)
- Static DateFormatter on SettingsView struct (one-time allocation)
- FirebaseApp.configure() in App init() per Firebase best practice
- Only FirebaseCrashlytics added via SPM -- no Analytics (deferred to v2)
- Debug crash button behind #if DEBUG compiler directive
- isPremium tracked as Crashlytics custom value with onChange listener

## Notes

- Проект инициализирован 2026-03-25
- В текущей сессии уже исправлены: сохранение топиков, счётчик карточек, thread safety StoreManager, фоллбек фида
- Продукты в App Store Connect ещё не созданы
- Privacy Policy / Terms указывают на example.com
- Phase 1 complete: export removed from paywall, settings buttons functional, dead code deleted
- Phase 3 complete: Firebase Crashlytics integrated, crash reporting verified end-to-end

---
*Last updated: 2026-03-26*
