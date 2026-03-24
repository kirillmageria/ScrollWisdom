# Requirements: ScrollWisdom

**Defined:** 2026-03-25
**Core Value:** Пользователь открывает приложение каждое утро и получает одну практичную мудрость — быстро, красиво, с конкретным действием на день.

## v1 Requirements

### Bugs & Polish

- [ ] **BUG-01**: Экспорт карточек убран из PaywallView (не рекламировать нереализованную фичу)
- [ ] **BUG-02**: Версия приложения читается из `Bundle.main` вместо захардкоженной "1.0.0"
- [ ] **BUG-03**: Кнопки "Оценить" и "Обратная связь" в Settings открывают реальные ссылки
- [ ] **BUG-04**: Мёртвый код `filteredCards` в ContentManager удалён
- [ ] **BUG-05**: `DateFormatter` в `SettingsView.timeString` вынесен в статическую переменную

### Legal & Compliance

- [ ] **LEGAL-01**: Privacy Policy опубликована на реальном URL
- [ ] **LEGAL-02**: Terms of Service опубликованы на реальном URL
- [ ] **LEGAL-03**: URL в PaywallView обновлены с example.com на реальные ссылки

### Stability

- [ ] **CRASH-01**: Firebase Crashlytics SDK интегрирован в проект
- [ ] **CRASH-02**: Crash reporting инициализируется при старте приложения
- [ ] **CRASH-03**: Тестовый краш подтверждает что репорты приходят в Firebase Console

### App Store

- [ ] **STORE-01**: App ID создан в App Store Connect
- [ ] **STORE-02**: Продукты подписки созданы: `com.scrollwisdom.premium.monthly` и `com.scrollwisdom.premium.yearly` с 3-дневным триалом
- [ ] **STORE-03**: Скриншоты подготовлены для iPhone 6.7" и 6.1" (минимум)
- [ ] **STORE-04**: Описание приложения написано (EN + RU минимум)
- [ ] **STORE-05**: Ключевые слова заполнены
- [ ] **STORE-06**: App прошёл TestFlight тестирование
- [ ] **STORE-07**: Приложение отправлено на ревью Apple

## v2 Requirements

### Growth

- **GROW-01**: Экспорт карточки как красивой картинки (для Stories/соцсетей)
- **GROW-02**: Аналитика событий (onboarding_complete, paywall_shown, subscription_started)
- **GROW-03**: StoreKit запрос отзыва в нужный момент (после 3 дней streak)
- **GROW-04**: Widget с ежедневной цитатой

### Content

- **CONT-01**: Возможность добавлять новые карточки через remote config (без обновления приложения)
- **CONT-02**: Персонализация — алгоритм учитывает просмотренные карточки

## Out of Scope

| Feature | Reason |
|---------|--------|
| Android | iOS only, нет ресурсов |
| Социальные фичи | Не в концепции; усложнит без пользы для MVP |
| Web версия | Мобильный опыт — суть продукта |
| Собственный backend | JSON в bundle достаточно для v1 |

## Traceability

| Requirement | Phase | Status |
|-------------|-------|--------|
| BUG-01 | Phase 1 | Pending |
| BUG-02 | Phase 1 | Pending |
| BUG-03 | Phase 1 | Pending |
| BUG-04 | Phase 1 | Pending |
| BUG-05 | Phase 1 | Pending |
| LEGAL-01 | Phase 2 | Pending |
| LEGAL-02 | Phase 2 | Pending |
| LEGAL-03 | Phase 2 | Pending |
| CRASH-01 | Phase 3 | Pending |
| CRASH-02 | Phase 3 | Pending |
| CRASH-03 | Phase 3 | Pending |
| STORE-01 | Phase 4 | Pending |
| STORE-02 | Phase 4 | Pending |
| STORE-03 | Phase 4 | Pending |
| STORE-04 | Phase 4 | Pending |
| STORE-05 | Phase 4 | Pending |
| STORE-06 | Phase 4 | Pending |
| STORE-07 | Phase 4 | Pending |

**Coverage:**
- v1 requirements: 18 total
- Mapped to phases: 18
- Unmapped: 0 ✓

---
*Requirements defined: 2026-03-25*
*Last updated: 2026-03-25 after initial definition*
