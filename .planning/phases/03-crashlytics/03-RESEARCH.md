# Phase 3: Crashlytics - Research

**Researched:** 2026-03-25
**Domain:** Firebase Crashlytics integration for iOS (SwiftUI, Swift Package Manager)
**Confidence:** HIGH

## Summary

Firebase Crashlytics integration for a pure SwiftUI app (no AppDelegate) is straightforward. The project uses iOS 17+, Xcode 26.3, and Swift 6.2 -- all fully compatible with the latest firebase-ios-sdk (v12.10.0). The decision to call `FirebaseApp.configure()` in the `@main` struct's `init()` is officially supported for Crashlytics (unlike Firebase Auth or Cloud Messaging which require AppDelegate swizzling).

The integration requires four distinct steps: (1) add firebase-ios-sdk via SPM with only `FirebaseCrashlytics` product, (2) add `GoogleService-Info.plist` from Firebase Console, (3) configure a dSYM upload build phase script, and (4) add initialization code. The dSYM upload script is the most error-prone step -- it must be the last build phase, and the script path is specific to SPM checkouts.

**Primary recommendation:** Follow the locked decisions exactly -- `FirebaseApp.configure()` in `ScrollWisdomApp.init()`, debug crash button in SettingsView behind `#if DEBUG`, only `FirebaseCrashlytics` product (no Analytics). Add subscription status custom value in `ScrollWisdomApp` where both `storeManager` and Firebase are accessible.

<user_constraints>
## User Constraints (from CONTEXT.md)

### Locked Decisions
- **D-01:** Call `FirebaseApp.configure()` in `init()` of `@main` struct `ScrollWisdomApp` -- no AppDelegate
- **D-02:** Debug-only crash button in `SettingsView` behind `#if DEBUG` using `fatalError("Test crash")`
- **D-03:** Only basic automatic crash reports -- no custom event analytics (deferred to v2)
- **D-04:** Optionally add `Crashlytics.crashlytics().setCustomValue()` for subscription status (isPremium)

### Claude's Discretion
- Exact placement of subscription status custom value (in StoreManager or ScrollWisdomApp)
- Structure of GoogleService-Info.plist in project

### Deferred Ideas (OUT OF SCOPE)
- FirebaseAnalytics -- event analytics (onboarding, paywall, subscription) -- v2
- Crashlytics user ID binding -- v2 with analytics
- Custom non-fatal logs for StoreKit errors -- v2
</user_constraints>

<phase_requirements>
## Phase Requirements

| ID | Description | Research Support |
|----|-------------|------------------|
| CRASH-01 | Firebase Crashlytics SDK integrated into project | SPM setup with firebase-ios-sdk v12.10.0, `FirebaseCrashlytics` product only, `-ObjC` linker flag, dSYM upload script |
| CRASH-02 | Crash reporting initializes at app startup | `FirebaseApp.configure()` in `ScrollWisdomApp.init()` -- confirmed working for Crashlytics without AppDelegate |
| CRASH-03 | Test crash confirms reports arrive in Firebase Console | `#if DEBUG` button with `fatalError()` in SettingsView, requires run-from-device (not debugger) to send report |
</phase_requirements>

## Standard Stack

### Core
| Library | Version | Purpose | Why Standard |
|---------|---------|---------|--------------|
| firebase-ios-sdk | 12.10.0 | Firebase platform SDK | Official Google SDK, latest stable release (March 2026) |
| FirebaseCrashlytics | (included in SDK) | Crash reporting | Only product needed -- do NOT add FirebaseAnalytics |

### Supporting
| Library | Version | Purpose | When to Use |
|---------|---------|---------|-------------|
| FirebaseCore | (auto-dependency) | Firebase initialization | Pulled automatically by FirebaseCrashlytics |

### Alternatives Considered
| Instead of | Could Use | Tradeoff |
|------------|-----------|----------|
| FirebaseCrashlytics | Sentry | More features but paid, adds complexity -- Firebase is free and sufficient for v1 |
| SPM | CocoaPods | SPM is recommended by Firebase for new projects, simpler integration |

**Installation:**
Via Xcode: File > Add Packages > `https://github.com/firebase/firebase-ios-sdk.git` > select `FirebaseCrashlytics` only.

**Version verification:** firebase-ios-sdk v12.10.0 is the latest release as of 2026-03-16 (verified via GitHub and Swift Package Index).

## Architecture Patterns

### Recommended Project Structure
```
ScrollWisdom/
├── ScrollWisdomApp.swift      # Add init() with FirebaseApp.configure()
├── GoogleService-Info.plist   # NEW: Firebase config (from Firebase Console)
├── Models/
│   └── StoreManager.swift     # Existing -- read isPremium for custom value
└── Views/
    └── SettingsView.swift     # Add #if DEBUG crash button
```

### Pattern 1: Firebase Init in @main struct (no AppDelegate)
**What:** Call `FirebaseApp.configure()` in the App struct's `init()` method
**When to use:** When only using Crashlytics (and/or Firestore, Analytics) -- no Cloud Messaging
**Example:**
```swift
// Source: https://firebase.google.com/docs/ios/setup
import SwiftUI
import FirebaseCore
import FirebaseCrashlytics

@main
struct ScrollWisdomApp: App {
    @State private var manager = ContentManager()
    @State private var notificationManager = NotificationManager()
    @State private var storeManager = StoreManager()

    init() {
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            Group {
                if manager.hasCompletedOnboarding {
                    MainTabView()
                } else {
                    OnboardingView()
                }
            }
            .environment(manager)
            .environment(notificationManager)
            .environment(storeManager)
            .preferredColorScheme(.dark)
        }
    }
}
```

### Pattern 2: Custom Value for Subscription Status
**What:** Set Crashlytics custom key to distinguish premium vs free user crashes
**When to use:** After Firebase is configured and subscription status is known
**Recommendation:** Set in `ScrollWisdomApp` using `.onAppear` or `.task` on the root view, where both `storeManager` and Firebase are accessible. This keeps crash metadata logic in the app entry point, not inside StoreManager (which should remain focused on StoreKit).
```swift
// Source: https://firebase.google.com/docs/crashlytics/ios/customize-crash-reports
import FirebaseCrashlytics

// Inside body, on the root Group:
.task {
    Crashlytics.crashlytics().setCustomValue(storeManager.isPremium, forKey: "is_premium")
}
```
**Note:** Also update this value when subscription status changes. An `.onChange(of: storeManager.isPremium)` modifier is appropriate.

### Pattern 3: Debug-Only Test Crash Button
**What:** A button only compiled in DEBUG builds that triggers `fatalError()`
**Where:** SettingsView, in the About section
```swift
#if DEBUG
Button("Test Crash") {
    fatalError("Test crash for Crashlytics")
}
#endif
```

### Anti-Patterns to Avoid
- **Adding FirebaseAnalytics when not needed:** Adds unnecessary binary size and data collection. Analytics is explicitly deferred to v2.
- **Using AppDelegate just for Firebase:** Unnecessary complexity when only Crashlytics is needed. The `init()` approach is sufficient.
- **Leaving test crash button in release builds:** Always wrap in `#if DEBUG`.
- **Testing crashes with debugger attached:** Xcode debugger intercepts crashes -- crash reports will NOT be sent to Firebase while debugging.

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Crash reporting | Custom crash handler / signal handler | FirebaseCrashlytics | Signal handling is extremely complex, thread-unsafe, and platform-specific |
| dSYM symbolication | Manual symbol upload | Firebase run script build phase | Automated, handles all edge cases |
| Crash deduplication | Custom grouping logic | Firebase Console | Already groups by stack trace automatically |

**Key insight:** Crash reporting is deceptively complex (signal handlers, async-signal-safe functions, mach exceptions). Firebase handles all of this correctly.

## Common Pitfalls

### Pitfall 1: Missing dSYM Upload Script
**What goes wrong:** Crashes appear in Firebase Console but without symbolicated stack traces (just memory addresses)
**Why it happens:** The run script build phase for dSYM upload was not added or is misconfigured
**How to avoid:** Add the run script as the LAST build phase with the exact path and all 5 input files
**Warning signs:** Crash reports show hex addresses instead of function names

### Pitfall 2: Testing with Debugger Attached
**What goes wrong:** Test crash doesn't appear in Firebase Console
**Why it happens:** Xcode debugger intercepts the crash signal before Crashlytics can capture it
**How to avoid:** (1) Build and run from Xcode, (2) Stop the app in Xcode, (3) Launch app from device home screen, (4) Trigger crash, (5) Relaunch app to send report
**Warning signs:** Crash happens but nothing shows in Firebase Console after 5+ minutes

### Pitfall 3: GoogleService-Info.plist Not in Bundle
**What goes wrong:** Runtime crash or Firebase silently fails to initialize
**Why it happens:** Plist file was added to the project navigator but not included in the target's "Copy Bundle Resources" build phase
**How to avoid:** Verify the file appears in Build Phases > Copy Bundle Resources; ensure "Add to targets" checkbox was checked when adding
**Warning signs:** Console log: "The default Firebase app has not yet been configured"

### Pitfall 4: Crash Report Delay
**What goes wrong:** Developer thinks integration is broken because crash doesn't appear immediately
**Why it happens:** Firebase processes crash reports asynchronously; can take up to 5 minutes (sometimes longer for first crash)
**How to avoid:** After triggering crash, relaunch app (so it can send the report), then wait at least 5 minutes before checking Firebase Console
**Warning signs:** Impatience -- the first crash report always takes longest

### Pitfall 5: Missing -ObjC Linker Flag
**What goes wrong:** Link errors or runtime crashes due to missing Objective-C categories
**Why it happens:** Firebase SDK uses Objective-C categories that require the -ObjC linker flag
**How to avoid:** Add `-ObjC` to Build Settings > Other Linker Flags
**Warning signs:** Unrecognized selector crashes at runtime, or linker warnings

## Code Examples

### Complete ScrollWisdomApp.swift After Integration
```swift
// Source: https://firebase.google.com/docs/crashlytics/ios/get-started
import SwiftUI
import FirebaseCore
import FirebaseCrashlytics

@main
struct ScrollWisdomApp: App {
    @State private var manager = ContentManager()
    @State private var notificationManager = NotificationManager()
    @State private var storeManager = StoreManager()

    init() {
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            Group {
                if manager.hasCompletedOnboarding {
                    MainTabView()
                } else {
                    OnboardingView()
                }
            }
            .environment(manager)
            .environment(notificationManager)
            .environment(storeManager)
            .preferredColorScheme(.dark)
            .task {
                Crashlytics.crashlytics().setCustomValue(
                    storeManager.isPremium,
                    forKey: "is_premium"
                )
            }
            .onChange(of: storeManager.isPremium) { _, newValue in
                Crashlytics.crashlytics().setCustomValue(newValue, forKey: "is_premium")
            }
        }
    }
}
```

### dSYM Upload Run Script (for SPM)
```bash
# Build Phases > New Run Script Phase (MUST be last phase)
# Shell: /bin/sh
"${BUILD_DIR%/Build/*}/SourcePackages/checkouts/firebase-ios-sdk/Crashlytics/run"
```

**Input Files (all 5 required):**
```
${DWARF_DSYM_FOLDER_PATH}/${DWARF_DSYM_FILE_NAME}
${DWARF_DSYM_FOLDER_PATH}/${DWARF_DSYM_FILE_NAME}/Contents/Resources/DWARF/${PRODUCT_NAME}
${DWARF_DSYM_FOLDER_PATH}/${DWARF_DSYM_FILE_NAME}/Contents/Info.plist
$(TARGET_BUILD_DIR)/$(UNLOCALIZED_RESOURCES_FOLDER_PATH)/GoogleService-Info.plist
$(TARGET_BUILD_DIR)/$(EXECUTABLE_PATH)
```

### Debug Crash Button in SettingsView
```swift
// Add inside the About SettingsCard VStack, after the feedback button
#if DEBUG
Button {
    fatalError("Test crash for Crashlytics")
} label: {
    AboutRow(icon: "flame", title: "Test Crash", value: nil, showDivider: false)
}
.buttonStyle(.plain)
#endif
```

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|--------------|--------|
| CocoaPods/Carthage for Firebase | Swift Package Manager | Firebase SDK 8.0+ (2021) | SPM is now recommended for new projects |
| Fabric Crashlytics | Firebase Crashlytics | 2020 | Fabric fully sunset, use Firebase |
| Manual dSYM upload | Automated run script | firebase-ios-sdk 8.0+ | Script auto-uploads on each build |
| AppDelegate required | @main init() supported | firebase-ios-sdk 7.0+ | For Crashlytics, AppDelegate is not needed |

**Deprecated/outdated:**
- Fabric SDK: Fully sunset, replaced by Firebase Crashlytics
- `Crashlytics.sharedInstance()`: Use `Crashlytics.crashlytics()` (singleton accessor)

## Open Questions

1. **GoogleService-Info.plist availability**
   - What we know: Must be downloaded from Firebase Console for this specific project
   - What's unclear: Whether the Firebase project has already been created in the console
   - Recommendation: Plan should include a manual step for the user to create Firebase project and download the plist. This cannot be automated.

2. **Build Settings changes via code**
   - What we know: `-ObjC` linker flag and dSYM upload script must be added to Xcode build settings
   - What's unclear: Whether these can be reliably added via pbxproj editing or need manual Xcode UI steps
   - Recommendation: Document as manual Xcode steps -- modifying pbxproj programmatically is fragile and error-prone

## Environment Availability

| Dependency | Required By | Available | Version | Fallback |
|------------|------------|-----------|---------|----------|
| Xcode | Build & SPM | Yes | 26.3 | -- |
| Swift | Compilation | Yes | 6.2.4 | -- |
| Firebase Console project | GoogleService-Info.plist | Unknown | -- | User must create manually |
| Physical device or Simulator | Test crash verification | Yes | -- | Simulator works for crash, but device preferred |

**Missing dependencies with no fallback:**
- Firebase Console project + GoogleService-Info.plist: User must create this manually before code integration can work at runtime

**Missing dependencies with fallback:**
- None

## Validation Architecture

### Test Framework
| Property | Value |
|----------|-------|
| Framework | No test target exists in project |
| Config file | None |
| Quick run command | N/A |
| Full suite command | N/A |

### Phase Requirements -> Test Map
| Req ID | Behavior | Test Type | Automated Command | File Exists? |
|--------|----------|-----------|-------------------|-------------|
| CRASH-01 | Firebase SDK added via SPM, compiles | build | `xcodebuild build -scheme ScrollWisdom -destination 'platform=iOS Simulator,name=iPhone 16'` | N/A (build verification) |
| CRASH-02 | FirebaseApp.configure() called at startup | manual | Verify in code review -- no unit test possible without Firebase test fixtures | N/A |
| CRASH-03 | Test crash appears in Firebase Console | manual-only | Requires human: trigger crash on device, check Firebase Console after 5 min | N/A |

### Sampling Rate
- **Per task commit:** `xcodebuild build` -- verify project compiles with Firebase dependency
- **Per wave merge:** Same -- no automated test suite exists
- **Phase gate:** Build succeeds + manual verification of crash in Firebase Console

### Wave 0 Gaps
- No test target exists in the project. Creating one is out of scope for this phase (Crashlytics integration is primarily configuration, not testable logic).
- CRASH-03 is inherently manual-only -- it requires checking Firebase Console UI.

## Sources

### Primary (HIGH confidence)
- [Firebase Crashlytics iOS Get Started](https://firebase.google.com/docs/crashlytics/ios/get-started) - Complete setup guide, dSYM script, test crash steps
- [Firebase iOS Setup (Add to Apple project)](https://firebase.google.com/docs/ios/setup) - SPM installation, GoogleService-Info.plist, initialization patterns
- [Firebase Crashlytics Customize Reports](https://firebase.google.com/docs/crashlytics/ios/customize-crash-reports) - setCustomValue API, custom keys

### Secondary (MEDIUM confidence)
- [firebase-ios-sdk GitHub](https://github.com/firebase/firebase-ios-sdk) - v12.10.0 confirmed as latest release
- [Swift Package Index - Firebase](https://swiftpackageindex.com/firebase/firebase-ios-sdk) - Version verification
- [Peter Friese - Firebase SwiftUI Lifecycle](https://peterfriese.dev/swiftui-new-app-lifecycle-firebase/) - Confirms init() pattern works for Crashlytics

### Tertiary (LOW confidence)
- None

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH - Official Firebase docs, verified version
- Architecture: HIGH - Official patterns confirmed for SwiftUI without AppDelegate specifically for Crashlytics
- Pitfalls: HIGH - Well-documented common issues in Firebase docs and community

**Research date:** 2026-03-25
**Valid until:** 2026-04-25 (Firebase SDK is stable, patterns unlikely to change)
