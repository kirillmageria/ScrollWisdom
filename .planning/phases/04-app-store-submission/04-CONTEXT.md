# Phase 4: App Store Submission - Context

**Gathered:** 2026-03-26
**Status:** Ready for planning

<domain>
## Phase Boundary

Всё необходимое для публикации ScrollWisdom в App Store: App Store Connect настройка, скриншоты, описание, TestFlight, сабмит.

</domain>

<decisions>
## Implementation Decisions

### Категория и тон
- **D-01:** Категория — **Lifestyle** (уже выбрана в проекте, оставляем)
- **D-02:** Тон описания — **вдохновляющий/философский** (упор на мудрость стоиков, ежедневные практики, личностный рост — как Calm/Headspace)
- **D-03:** Описание пишет Claude (EN + RU), исполнитель вносит в App Store Connect

### Скриншоты
- **D-04:** Скриншоты с симулятора (без фреймов iPhone) — достаточно для первого релиза
- **D-05:** 5 скриншотов в порядке: 1) Фид с карточкой цитаты, 2) Onboarding (выбор топиков), 3) Paywall (premium), 4) Сохранённые карточки, 5) Настройки со streak
- **D-06:** Размеры: iPhone 6.7" (1290×2796) и 6.1" (1179×2556) — минимум Apple требует 6.7"

### Продукты подписки
- **D-07:** Product IDs из ScrollWisdomProducts.storekit:
  - Monthly: `com.scrollwisdom.premium.monthly` — $3.99/мес, 3-day free trial
  - Yearly: `com.scrollwisdom.premium.yearly` — $29.99/год, 3-day free trial
- **D-08:** Subscription Group Name: "ScrollWisdom Premium"

### TestFlight
- **D-09:** Тестирует только разработчик (сам Кирилл) — 1-2 дня, затем сабмит
- **D-10:** Внешние бета-тестеры не нужны для v1

### Claude's Discretion
- Точный текст описания (Claude генерирует в плане)
- Ключевые слова (Claude подбирает, ~100 символов)
- Порядок заполнения полей в App Store Connect

</decisions>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Project config
- `ScrollWisdom/ScrollWisdomProducts.storekit` — Product IDs и цены подписок
- `.planning/REQUIREMENTS.md` — STORE-01..07 требования

### Legal URLs (уже готовы)
- Privacy Policy: `https://kirillmageria.github.io/ScrollWisdom/privacy-policy.html`
- Terms of Service: `https://kirillmageria.github.io/ScrollWisdom/terms-of-service.html`

</canonical_refs>

<specifics>
## Specific Ideas

- Описание должно упоминать: Марк Аврелий, Эпиктет, Сенека, 900+ карточек, 6 языков, ежедневные действия
- Подзаголовок (30 символов): что-то про "Daily Stoic Wisdom" или "Wisdom for Daily Life"
- Ключевые слова (~100 символов): stoicism, marcus aurelius, daily wisdom, stoic quotes, philosophy, mindfulness, self improvement
- Support URL: `https://kirillmageria.github.io/ScrollWisdom/` или отдельная страница

</specifics>

<deferred>
## Deferred Ideas

- "Последний шанс" discount paywall (как в Motivation app) — v2, требует отдельный UI экран
- Внешние бета-тестеры TestFlight — v2 / при следующем обновлении
- App Preview видео — v2
- Промо-текст (сезонный) — после релиза

</deferred>

---

*Phase: 04-app-store-submission*
*Context gathered: 2026-03-26*
