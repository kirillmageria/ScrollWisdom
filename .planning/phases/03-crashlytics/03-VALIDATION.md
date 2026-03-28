---
phase: 3
slug: crashlytics
status: draft
nyquist_compliant: false
wave_0_complete: false
created: 2026-03-25
---

# Phase 3 — Validation Strategy

> Per-phase validation contract for feedback sampling during execution.

---

## Test Infrastructure

| Property | Value |
|----------|-------|
| **Framework** | xcodebuild (manual build verification) |
| **Config file** | ScrollWisdom.xcodeproj |
| **Quick run command** | `xcodebuild build -scheme ScrollWisdom -destination 'platform=iOS Simulator,name=iPhone 16' 2>&1 | tail -5` |
| **Full suite command** | `xcodebuild build -scheme ScrollWisdom -destination 'platform=iOS Simulator,name=iPhone 16' 2>&1 | grep -E 'error:|BUILD'` |
| **Estimated runtime** | ~60 seconds |

---

## Sampling Rate

- **After every task commit:** Run quick build check
- **After every plan wave:** Run full build + manual Firebase Console verification
- **Before `/gsd:verify-work`:** Clean build must succeed + test crash must appear in Firebase Console
- **Max feedback latency:** 60 seconds (build)

---

## Per-Task Verification Map

| Task ID | Plan | Wave | Requirement | Test Type | Automated Command | Status |
|---------|------|------|-------------|-----------|-------------------|--------|
| 3-01-01 | 01 | 1 | CRASH-01 | build | `xcodebuild build ... \| grep 'BUILD SUCCEEDED'` | ⬜ pending |
| 3-01-02 | 01 | 1 | CRASH-02 | build + manual | build succeeds + app launches without crash | ⬜ pending |
| 3-01-03 | 01 | 2 | CRASH-03 | manual | crash visible in Firebase Console within 5 min | ⬜ pending |

*Status: ⬜ pending · ✅ green · ❌ red · ⚠️ flaky*

---

## Wave 0 Requirements

*No automated test stubs needed — Firebase Crashlytics has no unit-testable API. Verification is build success + manual Firebase Console check.*

---

## Manual-Only Verifications

| Behavior | Requirement | Why Manual | Test Instructions |
|----------|-------------|------------|-------------------|
| Crash report appears in Firebase Console | CRASH-03 | Firebase SDK sends reports asynchronously, requires real device/simulator run without debugger | 1. Build & run WITHOUT Xcode debugger. 2. Tap "Test Crash" in Settings. 3. Relaunch app. 4. Check Firebase Console → Crashlytics within 5 min. |
| App launches without crash after FirebaseApp.configure() | CRASH-02 | Requires runtime execution | Run app on simulator, verify it reaches main screen |

---

## Validation Sign-Off

- [ ] All tasks have build verification or manual steps documented
- [ ] Clean build passes after all changes
- [ ] Test crash visible in Firebase Console
- [ ] `nyquist_compliant: true` set in frontmatter

**Approval:** pending
