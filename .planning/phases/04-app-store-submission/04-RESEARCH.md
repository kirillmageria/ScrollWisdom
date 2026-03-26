# Phase 4: App Store Submission - Research

**Researched:** 2026-03-27
**Domain:** App Store Connect, subscription configuration, metadata, TestFlight, Apple Review
**Confidence:** HIGH

## Summary

Phase 4 covers everything needed to publish ScrollWisdom to the App Store: creating the App ID in App Store Connect, configuring subscription products, preparing screenshots and localized metadata (EN + RU), running a quick developer-only TestFlight cycle, and submitting for Apple review.

The project already has a working StoreKit 2 integration with a local `.storekit` configuration file defining both subscription products. The legal URLs (Privacy Policy, Terms of Service) are already hosted on GitHub Pages. Phases 1-3 are complete (bugs fixed, legal links updated, Crashlytics integrated). This phase is primarily an App Store Connect configuration and metadata phase -- most work happens in the ASC web UI and Xcode, not in code.

**Primary recommendation:** Follow a strict sequential flow: (1) create App ID and subscription products in ASC, (2) prepare screenshots via simulator, (3) fill metadata for EN and RU, (4) archive and upload build, (5) TestFlight 1-2 days, (6) submit for review.

<user_constraints>
## User Constraints (from CONTEXT.md)

### Locked Decisions
- D-01: Category -- Lifestyle (already set in project)
- D-02: Tone -- inspirational/philosophical (like Calm/Headspace)
- D-03: Claude writes descriptions (EN + RU), executor enters them in ASC
- D-04: Simulator screenshots without device frames -- sufficient for v1
- D-05: 5 screenshots in order: (1) Feed with quote card, (2) Onboarding topic selection, (3) Paywall premium, (4) Saved cards, (5) Settings with streak
- D-06: Sizes: iPhone 6.7" (1290x2796) and 6.1" (1179x2556) -- minimum Apple requires is 6.7"
- D-07: Product IDs from ScrollWisdomProducts.storekit: monthly $3.99, yearly $29.99, both with 3-day free trial
- D-08: Subscription Group Name: "ScrollWisdom Premium"
- D-09: Developer-only testing (Kirill), 1-2 days, then submit
- D-10: No external beta testers for v1

### Claude's Discretion
- Exact description text (Claude generates in plan)
- Keywords (~100 characters, Claude selects)
- Order of filling fields in App Store Connect

### Deferred Ideas (OUT OF SCOPE)
- "Last chance" discount paywall -- v2
- External TestFlight beta testers -- v2
- App Preview video -- v2
- Promotional text (seasonal) -- post-release
</user_constraints>

<phase_requirements>
## Phase Requirements

| ID | Description | Research Support |
|----|-------------|------------------|
| STORE-01 | App ID created in App Store Connect | ASC setup checklist, required fields documented below |
| STORE-02 | Subscription products created: monthly and yearly with 3-day trial | Subscription setup flow, product ID matching, introductory offer config |
| STORE-03 | Screenshots prepared for iPhone 6.7" and 6.1" | Exact pixel dimensions verified, simulator capture commands documented |
| STORE-04 | App description written (EN + RU minimum) | Required and optional metadata fields listed, character limits documented |
| STORE-05 | Keywords filled | 100-character limit, keyword strategy documented |
| STORE-06 | App passed TestFlight testing | TestFlight flow documented, developer-only internal testing |
| STORE-07 | App submitted for Apple review | Submission checklist, common rejection reasons documented |
</phase_requirements>

## App Store Connect Required Fields

### App-Level Setup (STORE-01)
| Field | Required | Value / Notes |
|-------|----------|---------------|
| App Name | YES | "ScrollWisdom" (30 chars max) |
| Bundle ID | YES | Must match Xcode project bundle identifier |
| SKU | YES | Any unique string, e.g., "scrollwisdom-v1" |
| Primary Language | YES | English (U.S.) |
| Category | YES | Lifestyle (D-01) |

### Version-Level Metadata (STORE-04, STORE-05)
| Field | Required | Limit | Notes |
|-------|----------|-------|-------|
| App Name | YES | 30 chars | Displayed on App Store |
| Subtitle | YES | 30 chars | e.g., "Daily Stoic Wisdom" |
| Description | YES | 4000 chars | Full description, EN + RU |
| Keywords | YES | 100 chars | Comma-separated, per locale |
| What's New | YES (updates) | 4000 chars | Not needed for first version |
| Promotional Text | NO | 170 chars | Deferred to post-release |
| Support URL | YES | URL | `https://kirillmageria.github.io/ScrollWisdom/` |
| Marketing URL | NO | URL | Can use same as support |
| Privacy Policy URL | YES | URL | `https://kirillmageria.github.io/ScrollWisdom/privacy-policy.html` |
| Copyright | YES | text | e.g., "2026 Kirill Magerya" |
| Age Rating | YES | questionnaire | Content: Infrequent/Mild (no violence, no adult content) |
| Contact Info (review) | YES | phone + email | For Apple reviewer to contact |
| Demo Account | NO | - | Not needed (no login) |
| Notes for Review | RECOMMENDED | text | Explain subscription, mention no login required |

### Paid Applications Agreement
**CRITICAL:** Before creating subscription products, the Paid Applications Agreement must be signed in App Store Connect under Business > Agreements. Tax forms and banking information must be complete. Without this, subscription products cannot be created.

## Subscription Products Setup (STORE-02)

### Configuration in App Store Connect

1. **Create Subscription Group:** "ScrollWisdom Premium"
2. **Add Monthly Product:**
   - Reference Name: "Monthly Premium"
   - Product ID: `com.scrollwisdom.premium.monthly`
   - Duration: 1 Month
   - Price: $3.99 (Tier / manual price)
   - Introductory Offer: Free Trial, 3 Days, 1 period
   - Localization (EN): Display Name "Monthly Premium", Description "All topics, unlimited saves, no ads"
   - Localization (RU): Display Name + Description in Russian
3. **Add Yearly Product:**
   - Reference Name: "Yearly Premium"
   - Product ID: `com.scrollwisdom.premium.yearly`
   - Duration: 1 Year
   - Price: $29.99
   - Introductory Offer: Free Trial, 3 Days, 1 period
   - Localization (EN): Display Name "Yearly Premium", Description "All topics, unlimited saves, no ads -- save 37%"
   - Localization (RU): Display Name + Description in Russian
4. **Subscription Status:** Both must show "Ready to Submit" before app submission.

### Key Detail: Product IDs Must Match Exactly
The product IDs in App Store Connect MUST match `ScrollWisdomProducts.storekit` exactly:
- `com.scrollwisdom.premium.monthly`
- `com.scrollwisdom.premium.yearly`

Any mismatch will cause StoreKit 2 to fail to load products in production.

## Screenshots (STORE-03)

### Required Dimensions
| Display Size | Pixels (Portrait) | Devices | Required? |
|-------------|-------------------|---------|-----------|
| 6.7" | 1290 x 2796 | iPhone 14 Pro Max, 15 Plus, 16 Plus | YES (mandatory) |
| 6.1" | 1179 x 2556 | iPhone 14 Pro, 15, 16 | Optional but decided (D-06) |

**Important:** Dimensions must be pixel-perfect. Even 1284x2778 instead of 1290x2796 will be rejected.

### Simulator Strategy
Available simulators on this machine:
- iPhone 15 Pro Max -- produces 6.7" screenshots (1290x2796) -- USE THIS
- iPhone 16e -- 6.1" display -- check exact resolution
- iPhone 17 Pro Max -- newer device, may produce 6.9" screenshots (not the 6.7" target)

**Recommended approach:** Use `xcrun simctl io <device_id> screenshot` to capture PNGs from the simulator. The iPhone 15 Pro Max simulator produces exactly 1290x2796 screenshots.

### 5 Screenshot Scenes (D-05)
1. Feed with quote card (hero shot -- most important)
2. Onboarding (topic selection)
3. Paywall (premium features)
4. Saved cards collection
5. Settings with streak display

Each scene needs to be captured for both EN and RU localizations.

## Common Rejection Reasons (STORE-07)

### Subscription-Specific Rejections
1. **Missing Restore Purchases button** -- Apple requires a visible "Restore Purchases" mechanism. Verify it exists on the paywall or settings screen.
2. **Unclear subscription terms** -- The paywall must clearly show: price, billing period, free trial duration, and auto-renewal notice BEFORE the purchase button.
3. **Missing Terms of Service link** -- Must be accessible from the paywall.
4. **Subscription not in "Ready to Submit" status** -- Products must be fully configured before submission.

### General Rejections (Top Causes)
1. **Guideline 2.1 -- App Completeness** (~40% of rejections): Crashes, broken links, placeholder content. Test all flows end-to-end.
2. **Privacy issues**: App Privacy labels in ASC must accurately reflect data collection. ScrollWisdom likely collects: Crashlytics crash data (linked to device), no user accounts.
3. **Metadata mismatch**: Description must match actual app functionality. Do not overclaim features.

### ScrollWisdom-Specific Risks
- Ensure paywall shows subscription terms clearly (price, period, trial, auto-renewal)
- Ensure "Restore Purchases" is accessible
- Privacy Policy and Terms links must work (not example.com -- this was fixed in Phase 2)
- Crashlytics data collection must be declared in App Privacy section

## App Privacy Labels

ScrollWisdom must declare data collection in App Store Connect. Based on the app:

| Data Type | Collected? | Linked to User? | Used for Tracking? |
|-----------|-----------|-----------------|-------------------|
| Crash Data | YES (Crashlytics) | NO | NO |
| Diagnostics | YES (Crashlytics) | NO | NO |
| Purchases | YES (StoreKit) | NO | NO |

No user accounts, no analytics (deferred to v2), no third-party tracking.

## TestFlight Flow (STORE-06)

### Internal Testing (Developer Only -- D-09)
1. Archive app in Xcode: Product > Archive
2. Upload to App Store Connect via Xcode Organizer
3. Wait for processing (~5-15 minutes)
4. Build appears in TestFlight automatically for the developer (account holder)
5. Install via TestFlight app on physical device
6. Test for 1-2 days: all screens, subscription flow, crash reporting
7. No external group needed (D-10)

**Key:** Internal testers (team members in ASC) do NOT require Beta App Review. Only external groups require it.

## Submission Flow (STORE-07)

1. In App Store Connect > App > iOS App version, select the uploaded build
2. Ensure all metadata is filled (description, screenshots, keywords, etc.)
3. Ensure subscription products show "Ready to Submit"
4. Answer export compliance (likely "No" for encryption -- unless HTTPS counts, in which case select "Yes, uses exempt encryption")
5. Content Rights: confirm all content is original or properly licensed
6. Click "Submit for Review"
7. Status changes: "Waiting for Review" > "In Review" > "Approved" / "Rejected"

**Expected timeline:** iOS review currently averages 2-3 days in 2026, but can be up to 5-7 days during peak periods.

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Screenshot capture | Manual phone screenshots | `xcrun simctl io` command | Consistent pixel-perfect dimensions |
| App description | Write directly in ASC | Write in document first, paste in | Easier to review/iterate, keep for records |
| Subscription config | Guess at ASC fields | Match ScrollWisdomProducts.storekit exactly | Product IDs must be identical |

## Common Pitfalls

### Pitfall 1: Paid Applications Agreement Not Signed
**What goes wrong:** Cannot create subscription products; entire submission blocked.
**How to avoid:** Sign the agreement FIRST before any other ASC work. Check Business > Agreements.

### Pitfall 2: Screenshot Dimension Mismatch
**What goes wrong:** Upload rejected by ASC with cryptic error.
**How to avoid:** Use the correct simulator (iPhone 15 Pro Max for 6.7"). Verify dimensions with `sips --getProperty pixelWidth --getProperty pixelHeight <file>`.

### Pitfall 3: Subscription Products Stuck in "Missing Metadata"
**What goes wrong:** Products not submittable because localization or pricing is incomplete.
**How to avoid:** Fill ALL required fields: reference name, product ID, duration, price, at least one localization with display name and description.

### Pitfall 4: Forgetting Export Compliance
**What goes wrong:** Build stuck in "Missing Compliance" status in TestFlight.
**How to avoid:** After upload, immediately go to TestFlight > Build > Manage Missing Compliance and answer the encryption questions. ScrollWisdom uses HTTPS (standard App Transport Security) -- select "Yes, uses exempt encryption" with exemption type "standard HTTPS".

### Pitfall 5: App Privacy Labels Incomplete
**What goes wrong:** Rejection or reviewer questions about data practices.
**How to avoid:** Declare Crashlytics data collection honestly. No tracking, no user-linked data.

## Environment Availability

| Dependency | Required By | Available | Version | Fallback |
|------------|------------|-----------|---------|----------|
| Xcode | Archive & upload | YES | 26.3 | -- |
| iPhone 15 Pro Max Sim | 6.7" screenshots | YES | available | -- |
| Apple Developer Account | ASC access | ASSUMED | -- | Cannot proceed without |
| Physical iPhone | TestFlight testing | ASSUMED | -- | Simulator (limited) |

**Missing dependencies with no fallback:**
- Apple Developer Program membership (paid, $99/year) -- must be active
- Paid Applications Agreement signed in ASC -- must be completed for subscriptions

## Validation Architecture

### Test Framework
| Property | Value |
|----------|-------|
| Framework | Manual validation (App Store submission is UI/config work) |
| Config file | N/A |
| Quick run command | `xcodebuild -scheme ScrollWisdom -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPhone 15 Pro Max' build` |
| Full suite command | Build + manual checklist verification |

### Phase Requirements -> Test Map
| Req ID | Behavior | Test Type | Automated Command | File Exists? |
|--------|----------|-----------|-------------------|-------------|
| STORE-01 | App ID exists in ASC | manual-only | N/A (ASC web UI) | N/A |
| STORE-02 | Subscription products configured | manual-only | N/A (ASC web UI) | N/A |
| STORE-03 | Screenshots at correct dimensions | smoke | `sips --getProperty pixelWidth --getProperty pixelHeight screenshots/*.png` | N/A -- Wave 0 |
| STORE-04 | Description filled EN + RU | manual-only | N/A (ASC web UI) | N/A |
| STORE-05 | Keywords filled | manual-only | N/A (ASC web UI) | N/A |
| STORE-06 | TestFlight build runs | manual | Install via TestFlight, test all screens | N/A |
| STORE-07 | App submitted for review | manual-only | N/A (ASC web UI) | N/A |

### Sampling Rate
- **Per task:** Verify each ASC configuration step visually
- **Phase gate:** All metadata filled, screenshots uploaded, build in TestFlight, subscription products "Ready to Submit"

### Wave 0 Gaps
None -- this phase is primarily manual App Store Connect configuration. No test infrastructure changes needed.

## Sources

### Primary (HIGH confidence)
- [Apple Developer - Screenshot Specifications](https://developer.apple.com/help/app-store-connect/reference/app-information/screenshot-specifications/) - official screenshot dimensions
- [Apple Developer - Auto-renewable Subscriptions](https://developer.apple.com/app-store/subscriptions/) - subscription setup
- [Apple Developer - Submit an In-App Purchase](https://developer.apple.com/help/app-store-connect/manage-submissions-to-app-review/submit-an-in-app-purchase/) - IAP submission

### Secondary (MEDIUM confidence)
- [RevenueCat - App Store Connect Setup Guide](https://www.revenuecat.com/docs/platform-resources/apple-platform-resources/app-store-connect-setup-guide) - ASC walkthrough
- [RevenueCat - App Store Rejections](https://www.revenuecat.com/docs/test-and-launch/app-store-rejections) - common rejection causes
- [Runway - Live App Review Times](https://www.runway.team/appreviewtimes) - current review timelines

### Tertiary (LOW confidence)
- [Screenhance - Screenshot Dimensions 2026](https://screenhance.com/blog/app-store-screenshot-dimensions-2026) - third-party dimensions guide

## Metadata

**Confidence breakdown:**
- ASC Required Fields: HIGH - verified against Apple docs and multiple sources
- Screenshot Dimensions: HIGH - verified against Apple specifications
- Subscription Setup: HIGH - matches existing .storekit file, well-documented process
- Rejection Reasons: MEDIUM - aggregated from multiple sources, subscription-specific items well-documented
- Review Timeline: MEDIUM - varies, 2-3 days is current average but not guaranteed

**Research date:** 2026-03-27
**Valid until:** 2026-04-27 (App Store process is stable, unlikely to change within 30 days)
