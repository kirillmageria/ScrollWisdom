---
phase: 1
slug: bugs-polish
status: draft
nyquist_compliant: false
wave_0_complete: false
created: 2026-03-25
---

# Phase 1 — Validation Strategy

> Per-phase validation contract for feedback sampling during execution.

---

## Test Infrastructure

| Property | Value |
|----------|-------|
| **Framework** | Xcode build (xcodebuild) — no unit test framework for this phase |
| **Config file** | none — all verifications are build + manual |
| **Quick run command** | `xcodebuild build -scheme ScrollWisdom -destination 'platform=iOS Simulator,name=iPhone 16' 2>&1 | tail -5` |
| **Full suite command** | same as quick (no automated tests in project yet) |
| **Estimated runtime** | ~30 seconds |

---

## Sampling Rate

- **After every task commit:** Run quick build to confirm no compile errors
- **After every plan wave:** Full build + manual spot-check on simulator
- **Before `/gsd:verify-work`:** Full build must succeed + all success criteria verified manually
- **Max feedback latency:** ~30 seconds (build time)

---

## Per-Task Verification Map

| Task ID | Plan | Wave | Requirement | Test Type | Automated Command | File Exists | Status |
|---------|------|------|-------------|-----------|-------------------|-------------|--------|
| 1-01-01 | 01 | 1 | BUG-01 | build + manual | `xcodebuild build ...` | ✅ | ⬜ pending |
| 1-01-02 | 01 | 1 | BUG-02 | build + manual | `xcodebuild build ...` | ✅ | ⬜ pending |
| 1-01-03 | 01 | 1 | BUG-03 | build + manual | `xcodebuild build ...` | ✅ | ⬜ pending |
| 1-01-04 | 01 | 1 | BUG-04 | build (grep) | `grep -r "filteredCards" ScrollWisdom/` | ✅ | ⬜ pending |
| 1-01-05 | 01 | 1 | BUG-05 | build + grep | `grep "static let.*DateFormatter" ScrollWisdom/Views/SettingsView.swift` | ✅ | ⬜ pending |

*Status: ⬜ pending · ✅ green · ❌ red · ⚠️ flaky*

---

## Wave 0 Requirements

*Existing infrastructure covers all phase requirements. This phase is bug fixes only — no new test infrastructure needed.*

---

## Manual-Only Verifications

| Behavior | Requirement | Why Manual | Test Instructions |
|----------|-------------|------------|-------------------|
| Paywall не показывает export фичу | BUG-01 | UI verification | Открыть PaywallView, убедиться что нет строки про экспорт |
| Версия в Settings совпадает с CFBundleShortVersionString | BUG-02 | UI verification | Settings → About → проверить версию |
| Rate App кнопка запрашивает review | BUG-03 | Requires simulator | Нажать Rate в Settings, появляется системный диалог |
| Feedback кнопка открывает Mail | BUG-03 | Requires device/simulator | Нажать Feedback, открывается Mail app с адресом |

---

## Validation Sign-Off

- [ ] All tasks have `<automated>` verify or Wave 0 dependencies
- [ ] Sampling continuity: no 3 consecutive tasks without automated verify
- [ ] Wave 0 covers all MISSING references
- [ ] No watch-mode flags
- [ ] Feedback latency < 30s
- [ ] `nyquist_compliant: true` set in frontmatter

**Approval:** pending
