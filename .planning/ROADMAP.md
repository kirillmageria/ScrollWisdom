# Roadmap: ScrollWisdom

## Overview

Довести ScrollWisdom до публикации в App Store: финальные баги, юридические документы, crash-репортинг, и полный App Store submission.

## Phases

- [ ] **Phase 1: Bugs & Polish** - Устранить оставшиеся баги и убрать нереализованные фичи из UI
- [ ] **Phase 2: Legal** - Privacy Policy и Terms of Service с реальными URL
- [ ] **Phase 3: Crashlytics** - Интеграция crash-репортинга для мониторинга после релиза
- [ ] **Phase 4: App Store Submission** - Настройка App Store Connect и публикация

## Phase Details

### Phase 1: Bugs & Polish
**Goal**: Устранить все оставшиеся баги и убрать нереализованные фичи перед релизом
**Depends on**: Nothing (first phase)
**Requirements**: BUG-01, BUG-02, BUG-03, BUG-04, BUG-05
**Success Criteria** (what must be TRUE):
  1. PaywallView не упоминает экспорт карточек
  2. Версия приложения читается из Bundle автоматически
  3. Кнопки Rate и Feedback в Settings выполняют реальные действия
  4. Мёртвый код `filteredCards` удалён из ContentManager
  5. DateFormatter в SettingsView вынесен в статическую переменную
**Plans:** 1 plan

Plans:
- [x] 01-01-PLAN.md — Remove export feature, fix Settings buttons/version/formatter, delete dead code

### Phase 2: Legal
**Goal**: Создать и опубликовать Privacy Policy и Terms of Service, обновить URL в коде
**Depends on**: Phase 1
**Requirements**: LEGAL-01, LEGAL-02, LEGAL-03
**Success Criteria** (what must be TRUE):
  1. Privacy Policy опубликована на реальном URL
  2. Terms of Service опубликованы на реальном URL
  3. Ссылки в PaywallView открывают реальные страницы
**Plans**: TBD

Plans:
- [ ] 02-01: Privacy Policy & Terms generation and integration

### Phase 3: Crashlytics
**Goal**: Интегрировать Firebase Crashlytics для мониторинга стабильности после релиза
**Depends on**: Phase 2
**Requirements**: CRASH-01, CRASH-02, CRASH-03
**Success Criteria** (what must be TRUE):
  1. Firebase SDK добавлен через Swift Package Manager
  2. FirebaseApp.configure() вызывается при старте приложения
  3. Тестовый краш отображается в Firebase Console
**Plans:** 1 plan

Plans:
- [x] 03-01-PLAN.md — Firebase SDK setup (SPM + config), initialization code, debug crash button, subscription custom value

### Phase 4: App Store Submission
**Goal**: Опубликовать ScrollWisdom в App Store
**Depends on**: Phase 3
**Requirements**: STORE-01, STORE-02, STORE-03, STORE-04, STORE-05, STORE-06, STORE-07
**Success Criteria** (what must be TRUE):
  1. App ID и продукты подписки созданы в App Store Connect
  2. Скриншоты и описание заполнены минимум для EN и RU
  3. Приложение прошло TestFlight тестирование
  4. Приложение отправлено на ревью Apple
**Plans**: TBD

Plans:
- [ ] 04-01: App Store Connect setup (App ID + subscription products)
- [ ] 04-02: Store assets (screenshots, description, keywords)
- [ ] 04-03: TestFlight & Submit

## Progress

| Phase | Plans Complete | Status | Completed |
|-------|----------------|--------|-----------|
| 1. Bugs & Polish | 1/1 | Complete | 2026-03-25 |
| 2. Legal | 0/1 | Not started | - |
| 3. Crashlytics | 1/1 | Complete | 2026-03-26 |
| 4. App Store Submission | 0/3 | Not started | - |
