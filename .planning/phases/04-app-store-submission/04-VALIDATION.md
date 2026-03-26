---
phase: 4
slug: app-store-submission
status: draft
nyquist_compliant: false
wave_0_complete: false
created: 2026-03-27
---

# Phase 4 — Validation Strategy

> Per-phase validation contract for feedback sampling during execution.

---

## Test Infrastructure

| Property | Value |
|----------|-------|
| **Framework** | Manual verification (App Store Connect UI + Xcode) |
| **Config file** | N/A |
| **Quick run command** | `grep -c "APP_ID\|BUNDLE_ID" ScrollWisdom.xcodeproj/project.pbxproj` |
| **Full suite command** | Manual checklist in App Store Connect |
| **Estimated runtime** | N/A — human-action phase |

---

## Sampling Rate

- **After every task:** Manual checkpoint verification
- **After all plans:** App Store Connect listing complete, build uploaded, in review
- **Before `/gsd:verify-work`:** App submitted to Apple review

---

## Per-Task Verification Map

| Task | Plan | Requirement | Test Type | Status |
|------|------|-------------|-----------|--------|
| App ID created | 04-01 | STORE-01 | manual | ⬜ pending |
| Subscription products created | 04-01 | STORE-02 | manual | ⬜ pending |
| Screenshots uploaded | 04-02 | STORE-03 | manual | ⬜ pending |
| Description filled (EN+RU) | 04-02 | STORE-04 | manual | ⬜ pending |
| Keywords filled | 04-02 | STORE-05 | manual | ⬜ pending |
| TestFlight build tested | 04-03 | STORE-06 | manual | ⬜ pending |
| App submitted to review | 04-03 | STORE-07 | manual | ⬜ pending |

---

## Wave 0 Requirements

*No automated test stubs needed — this phase is entirely human-action (App Store Connect UI + Xcode Organizer). All verification is manual.*

---

## Manual-Only Verifications

| Behavior | Requirement | Why Manual | Test Instructions |
|----------|-------------|------------|-------------------|
| App ID created in ASC | STORE-01 | Requires App Store Connect web UI | Check ASC → Apps → App ID exists |
| Subscription products active | STORE-02 | Requires ASC subscription setup | ASC → Subscriptions → both products show "Ready to Submit" |
| Screenshots uploaded | STORE-03 | Requires ASC media upload | ASC → App listing → Screenshots filled for 6.7" |
| Description EN+RU filled | STORE-04 | Requires ASC text fields | ASC → App Info → Description not empty |
| Keywords filled | STORE-05 | Requires ASC text field | ASC → App Info → Keywords ≤ 100 chars |
| TestFlight build passes | STORE-06 | Requires device/simulator testing | Build runs, no crashes, all features work |
| Submitted to review | STORE-07 | Requires ASC submission | ASC → app status = "Waiting for Review" |

---

## Validation Sign-Off

- [ ] App ID and subscription products created in ASC
- [ ] All required screenshots uploaded
- [ ] Description and keywords filled in EN and RU
- [ ] TestFlight build tested successfully
- [ ] App submitted to Apple review
- [ ] `nyquist_compliant: true` set in frontmatter

**Approval:** pending
