---
phase: 01-bugs-polish
plan: 01
subsystem: ui-cleanup
tags: [bugfix, polish, paywall, settings, dead-code]
dependency_graph:
  requires: []
  provides: [clean-paywall, functional-settings, no-dead-code]
  affects: [PaywallView, SettingsView, ContentManager, localization]
tech_stack:
  added: []
  patterns: [static-dateformatter, environment-requestReview, environment-openURL, bundle-version]
key_files:
  created: []
  modified:
    - ScrollWisdom/Views/PaywallView.swift
    - ScrollWisdom/Views/SettingsView.swift
    - ScrollWisdom/Models/ContentManager.swift
    - ScrollWisdom/Localization/en.lproj/Localizable.strings
    - ScrollWisdom/Localization/ru.lproj/Localizable.strings
    - ScrollWisdom/Localization/es.lproj/Localizable.strings
    - ScrollWisdom/Localization/de.lproj/Localizable.strings
    - ScrollWisdom/Localization/fr.lproj/Localizable.strings
    - ScrollWisdom/Localization/pt-BR.lproj/Localizable.strings
decisions:
  - Used @Environment(\.requestReview) for rate button instead of SKStoreReviewController
  - Used mailto: link for feedback instead of in-app form
  - Static DateFormatter as private static let on SettingsView struct
metrics:
  duration: 78s
  completed: 2026-03-25
---

# Phase 01 Plan 01: Bugs & Polish Summary

Removed unreleased export feature from paywall, made Rate/Feedback buttons functional via SwiftUI environment actions, replaced hardcoded version with Bundle.main lookup, deleted dead filteredCards code, and optimized DateFormatter to static allocation.

## What Was Done

### Task 1: Remove export feature from PaywallView and delete dead code (320c823)

- Deleted the export PaywallFeature block from PaywallView.swift (doc.text icon, #10b981 color)
- Changed notifs feature (bell.badge) to showDivider: false since it is now the last item
- Removed filteredCards computed property and its comment from ContentManager.swift
- Deleted paywall.feature.export.title and paywall.feature.export.desc from all 6 localization files (en, ru, es, de, fr, pt-BR)

### Task 2: Fix SettingsView -- dynamic version, functional buttons, static DateFormatter (100ca1d)

- Added @Environment(\.requestReview) and @Environment(\.openURL) to SettingsView
- Added private static let timeFormatter: DateFormatter as a one-time allocation
- Replaced hardcoded "1.0.0" with Bundle.main.infoDictionary?["CFBundleShortVersionString"]
- Wrapped Rate row in Button that calls requestReview()
- Wrapped Feedback row in Button that opens mailto:support@scrollwisdom.app
- Updated timeString to use Self.timeFormatter instead of creating DateFormatter() per call
- Applied .buttonStyle(.plain) to preserve existing visual appearance

## Deviations from Plan

None -- plan executed exactly as written.

## Commits

| # | Hash | Message |
|---|------|---------|
| 1 | 320c823 | fix(01-01): remove export feature from paywall and delete dead filteredCards code |
| 2 | 100ca1d | fix(01-01): dynamic version, functional Rate/Feedback buttons, static DateFormatter |

## Known Stubs

None -- all changes are fully wired with real data sources and actions.

## Verification

All acceptance criteria passed:
- No paywall.feature.export strings anywhere in codebase
- No filteredCards references anywhere in codebase
- Notifs PaywallFeature has showDivider: false
- CFBundleShortVersionString present in SettingsView
- requestReview() called on Rate button tap
- mailto: URL opened on Feedback button tap
- Static DateFormatter used via Self.timeFormatter
- No hardcoded "1.0.0" in SettingsView

## Self-Check: PASSED

All files found. All commits verified (320c823, 100ca1d).
