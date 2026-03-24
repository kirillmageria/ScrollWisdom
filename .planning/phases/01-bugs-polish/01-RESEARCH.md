# Phase 1: Bugs & Polish - Research

**Researched:** 2026-03-25
**Domain:** SwiftUI iOS 17+ bug fixes, dead code removal, platform API usage
**Confidence:** HIGH

## Summary

Phase 1 addresses five discrete bugs/polish items in an existing SwiftUI iOS 17+ app. All five are straightforward code changes with well-documented Apple APIs. No external dependencies are needed -- everything uses built-in iOS frameworks (Foundation, StoreKit, SwiftUI).

The changes span three files: PaywallView.swift (remove export feature row + localization strings), SettingsView.swift (Bundle version, Rate App via requestReview environment value, mailto: link for Feedback, static DateFormatter), and ContentManager.swift (delete dead `filteredCards` property).

**Primary recommendation:** These are all isolated, low-risk changes that can be executed in a single plan with 5 tasks (one per BUG requirement).

<phase_requirements>
## Phase Requirements

| ID | Description | Research Support |
|----|-------------|------------------|
| BUG-01 | Export feature removed from PaywallView | Lines 93-97 in PaywallView.swift: remove the 4th PaywallFeature block (export). Remove `paywall.feature.export.title` and `paywall.feature.export.desc` from all 6 .strings files. Set `showDivider: false` on the 3rd feature (notifs). |
| BUG-02 | App version from Bundle.main | SettingsView.swift line 258: replace hardcoded "1.0.0" with `Bundle.main.infoDictionary?["CFBundleShortVersionString"]`. See code pattern below. |
| BUG-03 | Rate and Feedback buttons perform real actions | SettingsView.swift lines 259-260: AboutRow for Rate needs `@Environment(\.requestReview)` action. AboutRow for Feedback needs `mailto:` URL via `openURL`. Requires refactoring AboutRow to accept an action closure or converting rows to Button/Link. |
| BUG-04 | Dead code filteredCards removed from ContentManager | ContentManager.swift lines 34-37: delete the `filteredCards` computed property. Verified: `.filteredCards` is not referenced anywhere in the codebase. |
| BUG-05 | DateFormatter in SettingsView extracted to static | SettingsView.swift lines 285-292: `timeString` creates a new DateFormatter on every call. Extract to `private static let` on SettingsView. |
</phase_requirements>

## Architecture Patterns

### Pattern 1: Bundle Version Reading (BUG-02)
**What:** Read app version from Info.plist at runtime instead of hardcoding
**When to use:** Any place displaying app version
**Confidence:** HIGH -- standard Apple API, unchanged for years

```swift
// Standard pattern for reading version
let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
```

In SettingsView context, replace:
```swift
// BEFORE (line 258)
AboutRow(icon: "info.circle", title: String(localized: "settings.version"), value: "1.0.0", showDivider: true)

// AFTER
AboutRow(icon: "info.circle", title: String(localized: "settings.version"),
         value: Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0",
         showDivider: true)
```

### Pattern 2: Request App Review (BUG-03 -- Rate)
**What:** iOS 16+ SwiftUI environment value for requesting App Store review
**When to use:** "Rate the app" button
**Confidence:** HIGH -- official SwiftUI API since iOS 16

```swift
// iOS 16+ SwiftUI pattern (NOT the old SKStoreReviewController)
@Environment(\.requestReview) private var requestReview

// Usage in button action:
requestReview()
```

**Important:** The `requestReview` environment value is available in SwiftUI since iOS 16. It replaces the older `SKStoreReviewController.requestReview(in:)` UIKit pattern. Since this app targets iOS 17+, this is the correct approach.

**Caveat:** Apple throttles review requests -- the system may choose not to show the dialog. This is expected behavior, not a bug.

### Pattern 3: Mailto Link for Feedback (BUG-03 -- Feedback)
**What:** Open email compose sheet via mailto: URL
**When to use:** "Send feedback" button
**Confidence:** HIGH -- standard URL scheme

```swift
@Environment(\.openURL) private var openURL

// Usage:
if let url = URL(string: "mailto:support@scrollwisdom.app?subject=ScrollWisdom%20Feedback") {
    openURL(url)
}
```

**Note:** The actual email address needs to be provided by the developer. Use a placeholder like `support@scrollwisdom.app` that can be updated. The `openURL` environment value is available since iOS 15.

### Pattern 4: Static DateFormatter (BUG-05)
**What:** Avoid creating DateFormatter on every computed property call
**When to use:** Any DateFormatter used repeatedly in a View
**Confidence:** HIGH -- well-known iOS performance pattern

```swift
struct SettingsView: View {
    // Static formatter -- created once, reused
    private static let timeFormatter: DateFormatter = {
        let f = DateFormatter()
        f.timeStyle = .short
        return f
    }()

    private var timeString: String {
        var comps = DateComponents()
        comps.hour = notifManager.morningHour
        comps.minute = notifManager.morningMinute
        return Self.timeFormatter.string(from: Calendar.current.date(from: comps) ?? Date())
    }
}
```

### Pattern 5: Removing PaywallView Export Feature (BUG-01)
**What:** Remove the 4th feature row (export) from PaywallView and its localization strings
**Confidence:** HIGH -- direct code/string deletion

Current code in PaywallView.swift lines 93-97:
```swift
PaywallFeature(icon: "doc.text", color: "#10b981",
               title: String(localized: "paywall.feature.export.title"),
               desc: String(localized: "paywall.feature.export.desc"),
               showDivider: false)
```

Action: Delete this block AND change `showDivider: true` to `showDivider: false` on the preceding PaywallFeature (notifs, line 93).

Localization keys to remove from ALL 6 .strings files:
- `paywall.feature.export.title`
- `paywall.feature.export.desc`

Files: en.lproj, ru.lproj, es.lproj, de.lproj, fr.lproj, pt-BR.lproj (all under `ScrollWisdom/Localization/`)

### Anti-Patterns to Avoid
- **Creating AboutRow with no tap action:** Current AboutRow is a static display component. For Rate and Feedback rows, do NOT wrap AboutRow in a NavigationLink. Instead, make the row itself tappable (Button or onTapGesture) since these are imperative actions, not navigation.
- **Using SKStoreReviewController in SwiftUI:** The UIKit `SKStoreReviewController.requestReview(in:)` requires getting the window scene. Use the SwiftUI `@Environment(\.requestReview)` instead -- it is cleaner and correct for iOS 17+.
- **Non-static DateFormatter in computed property:** This is the actual bug being fixed. DateFormatter allocation is expensive -- Apple's own documentation warns against creating them in tight loops.

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| App Store review prompt | Custom review dialog | `@Environment(\.requestReview)` | Apple rejects apps with custom review prompts; system handles throttling |
| Email composition | Custom email form | `mailto:` URL + `openURL` | System handles app selection, no Mail.app dependency |
| Version string | Manual version tracking | `Bundle.main.infoDictionary` | Auto-synced with Xcode build settings |

## Common Pitfalls

### Pitfall 1: AboutRow Refactoring Scope Creep
**What goes wrong:** Making AboutRow too generic or refactoring the entire component
**Why it happens:** The current AboutRow has no action handler -- tempting to do a big refactor
**How to avoid:** Minimal change: either add an optional action closure to AboutRow, or replace the Rate/Feedback AboutRow usages with inline Button views that look identical. Keep the Version row unchanged.
**Warning signs:** Touching more than SettingsView.swift for this change

### Pitfall 2: Missing showDivider Fix When Removing Export
**What goes wrong:** Removing the export PaywallFeature but forgetting to update `showDivider` on the notifications row above it
**Why it happens:** The last item must have `showDivider: false`
**How to avoid:** When removing line 94-97, also change line 93 from `showDivider: true` to `showDivider: false`
**Warning signs:** Visual divider line hanging at the bottom of the features list

### Pitfall 3: requestReview Environment Requires View Context
**What goes wrong:** Trying to call `requestReview()` outside of a view body or in a non-main-actor context
**Why it happens:** `@Environment(\.requestReview)` must be declared on the View struct
**How to avoid:** Declare it as a property on SettingsView, call in button action
**Warning signs:** Compilation error about environment values

### Pitfall 4: Forgetting Localization Files
**What goes wrong:** Removing export strings from en.lproj but missing other languages
**Why it happens:** 6 localization files exist
**How to avoid:** Delete from ALL: en, ru, es, de, fr, pt-BR
**Warning signs:** Unused localization warnings (or lack thereof -- Xcode may not warn)

## Code Examples

### Current State: What Needs Changing

**SettingsView.swift About section (lines 256-261):**
```swift
SettingsCard {
    VStack(spacing: 0) {
        AboutRow(icon: "info.circle", title: String(localized: "settings.version"), value: "1.0.0", showDivider: true)
        AboutRow(icon: "star", title: String(localized: "settings.rate"), value: nil, showDivider: true)
        AboutRow(icon: "envelope", title: String(localized: "settings.feedback"), value: nil, showDivider: false)
    }
}
```

The Rate and Feedback rows show chevrons (via `value: nil` path in AboutRow) but have no tap action -- the SettingsCard wrapping them is not interactive.

**Recommended approach for Rate/Feedback:** Replace the AboutRow calls for Rate and Feedback with Button views that visually match but execute actions. Keep AboutRow for Version (static display). This requires adding `@Environment(\.requestReview)` and `@Environment(\.openURL)` to SettingsView.

### ContentManager.swift Dead Code (lines 34-37):
```swift
// Keep old filteredCards for backward compat
var filteredCards: [WisdomCard] {
    allCards.filter { selectedTopics.contains($0.topic) }.shuffled()
}
```

Confirmed: `.filteredCards` has ZERO references in the entire codebase. The comment "backward compat" is misleading -- nothing uses it. Safe to delete.

## Validation Architecture

### Test Framework
| Property | Value |
|----------|-------|
| Framework | None detected -- no test targets or test files in project |
| Config file | none -- see Wave 0 |
| Quick run command | N/A |
| Full suite command | N/A |

### Phase Requirements -> Test Map
| Req ID | Behavior | Test Type | Automated Command | File Exists? |
|--------|----------|-----------|-------------------|-------------|
| BUG-01 | PaywallView has no export feature row | manual | Build and visually verify paywall | N/A |
| BUG-02 | Version displays from Bundle | manual | Build, check Settings shows correct version | N/A |
| BUG-03 | Rate opens review prompt, Feedback opens mail | manual | Build, tap buttons in Settings | N/A |
| BUG-04 | filteredCards property removed | build | `xcodebuild build` -- compile succeeds | N/A |
| BUG-05 | DateFormatter is static | build | `xcodebuild build` -- compile succeeds | N/A |

### Sampling Rate
- **Per task commit:** `xcodebuild build -scheme ScrollWisdom -destination 'platform=iOS Simulator,name=iPhone 16' 2>&1 | tail -5` (verify compilation)
- **Per wave merge:** Same + manual visual verification
- **Phase gate:** Successful build + manual verification of all 5 success criteria

### Wave 0 Gaps
- No test infrastructure exists. These are UI polish bugs best verified by building and running.
- Automated UI tests could be added but would be disproportionate effort for these changes.
- Build verification (`xcodebuild build`) is sufficient as automated check -- all changes are compile-time verifiable (removed code won't break if unused, new API calls will fail compilation if wrong).

## Specific File Change Map

| File | Lines | Change | Requirement |
|------|-------|--------|-------------|
| `ScrollWisdom/Views/PaywallView.swift` | 91-97 | Remove export PaywallFeature, set notifs `showDivider: false` | BUG-01 |
| `ScrollWisdom/Localization/en.lproj/Localizable.strings` | 75-76 | Delete export keys | BUG-01 |
| `ScrollWisdom/Localization/ru.lproj/Localizable.strings` | 75-76 | Delete export keys | BUG-01 |
| `ScrollWisdom/Localization/es.lproj/Localizable.strings` | 75-76 | Delete export keys | BUG-01 |
| `ScrollWisdom/Localization/de.lproj/Localizable.strings` | 75-76 | Delete export keys | BUG-01 |
| `ScrollWisdom/Localization/fr.lproj/Localizable.strings` | 75-76 | Delete export keys | BUG-01 |
| `ScrollWisdom/Localization/pt-BR.lproj/Localizable.strings` | 75-76 | Delete export keys | BUG-01 |
| `ScrollWisdom/Views/SettingsView.swift` | 258 | Bundle.main version | BUG-02 |
| `ScrollWisdom/Views/SettingsView.swift` | 256-261 | Add requestReview + openURL, make Rate/Feedback tappable | BUG-03 |
| `ScrollWisdom/Views/SettingsView.swift` | 285-292 | Static DateFormatter | BUG-05 |
| `ScrollWisdom/Models/ContentManager.swift` | 34-37 | Delete filteredCards property | BUG-04 |

## Sources

### Primary (HIGH confidence)
- Direct source code inspection of PaywallView.swift, SettingsView.swift, ContentManager.swift
- Apple Developer Documentation: `Bundle.main.infoDictionary` -- stable API since iOS 2.0
- Apple Developer Documentation: `RequestReviewAction` (`@Environment(\.requestReview)`) -- available iOS 16+
- Apple Developer Documentation: `OpenURLAction` (`@Environment(\.openURL)`) -- available iOS 15+
- Apple Developer Documentation: DateFormatter performance guidance

### Secondary (MEDIUM confidence)
- Bundle identifier `KirillMageria.ScrollWisdom` from project.pbxproj (needed for App Store URL if using direct link approach)

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH - no external libraries needed, all Apple frameworks
- Architecture: HIGH - patterns are well-documented Apple APIs, code changes identified at line level
- Pitfalls: HIGH - based on direct code inspection, all edge cases visible

**Research date:** 2026-03-25
**Valid until:** 2026-06-25 (stable Apple APIs, no fast-moving dependencies)
