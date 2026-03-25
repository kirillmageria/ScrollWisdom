---
phase: 03-crashlytics
plan: 01
subsystem: infra
tags: [firebase, crashlytics, spm, swift, crash-reporting]

# Dependency graph
requires:
  - phase: 02-legal
    provides: "App ready for production monitoring additions"
provides:
  - "Firebase Crashlytics SDK integrated via SPM"
  - "Crash reporting initialized at app startup"
  - "Subscription status tracked as Crashlytics custom value"
  - "Debug-only crash test button in Settings"
affects: [04-app-store-submission]

# Tech tracking
tech-stack:
  added: [firebase-ios-sdk, FirebaseCrashlytics, FirebaseCore]
  patterns: [firebase-init-in-app-init, debug-only-ui-via-compiler-directives, crashlytics-custom-values]

key-files:
  created: []
  modified:
    - ScrollWisdom/ScrollWisdomApp.swift
    - ScrollWisdom/Views/SettingsView.swift

key-decisions:
  - "FirebaseApp.configure() in App init() per Firebase best practice"
  - "Only FirebaseCrashlytics product added -- no Analytics (deferred to v2)"
  - "Debug crash button behind #if DEBUG compiler directive"
  - "isPremium tracked as Crashlytics custom value with onChange listener"

patterns-established:
  - "#if DEBUG pattern for dev-only UI elements"
  - "Crashlytics custom value updates via .task + .onChange modifiers"

requirements-completed: [CRASH-01, CRASH-02, CRASH-03]

# Metrics
duration: ~25min
completed: 2026-03-26
---

# Phase 3 Plan 1: Crashlytics Summary

**Firebase Crashlytics integrated via SPM with app-startup init, subscription custom value tracking, and debug crash button verified end-to-end**

## Performance

- **Duration:** ~25 min (across multiple sessions with user setup)
- **Tasks:** 3
- **Files modified:** 2 (code) + GoogleService-Info.plist + project.pbxproj (user-configured)

## Accomplishments
- Firebase Crashlytics SDK added via Swift Package Manager (only Crashlytics, no Analytics)
- FirebaseApp.configure() called at app startup in ScrollWisdomApp.init()
- Subscription status (isPremium) tracked as Crashlytics custom value, updated reactively
- Debug-only "Test Crash" button added to Settings > About section with flame icon
- dSYM upload build phase configured for symbolicated crash reports
- End-to-end crash reporting verified: test crash visible in Firebase Console

## Task Commits

Each task was committed atomically:

1. **Task 1: Firebase project setup and Xcode configuration** - completed by user (Firebase Console + Xcode GUI)
2. **Task 2: Add Firebase initialization and crash reporting code** - `835eef6` (feat)
3. **Task 3: Verify crash reporting works end-to-end** - user-verified (checkpoint:human-verify, approved)

## Files Created/Modified
- `ScrollWisdom/ScrollWisdomApp.swift` - Added Firebase imports, init() with FirebaseApp.configure(), isPremium custom value tracking
- `ScrollWisdom/Views/SettingsView.swift` - Added #if DEBUG crash test button with flame icon in About section
- `ScrollWisdom/GoogleService-Info.plist` - Firebase project configuration (added by user)
- `ScrollWisdom.xcodeproj/project.pbxproj` - SPM dependency, -ObjC linker flag, dSYM upload script (configured by user)

## Decisions Made
- FirebaseApp.configure() placed in App init() per Firebase documentation best practice
- Only FirebaseCrashlytics product linked via SPM -- FirebaseAnalytics deliberately excluded (deferred to v2 per D-03)
- Debug crash button uses fatalError() which is Swift stdlib -- no need to import FirebaseCrashlytics in SettingsView
- isPremium custom value set via .task modifier at launch and .onChange modifier for reactive updates

## Deviations from Plan

None - plan executed exactly as written.

## User Setup Required

Firebase project was configured by the user as part of Task 1:
- Firebase project "ScrollWisdom" created in Firebase Console
- iOS app registered with correct Bundle ID
- GoogleService-Info.plist downloaded and added to Xcode project
- firebase-ios-sdk added via SPM with FirebaseCrashlytics product only
- -ObjC linker flag added to Build Settings
- dSYM upload run script phase configured as last build phase

## Known Stubs

None - all functionality is fully wired and verified.

## Next Phase Readiness
- Crash reporting is active and verified -- ready for App Store submission (Phase 4)
- No blockers for Phase 4

## Self-Check: PASSED

- FOUND: ScrollWisdomApp.swift
- FOUND: SettingsView.swift
- FOUND: GoogleService-Info.plist
- FOUND: 03-01-SUMMARY.md
- FOUND: commit 835eef6

---
*Phase: 03-crashlytics*
*Completed: 2026-03-26*
