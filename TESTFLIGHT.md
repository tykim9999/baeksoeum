# TestFlight — Family-Only Distribution

Last updated: 2026-05-07

How to ship 백색소음 to a small group (family) without going through full App Store review. Single Xcode archive serves both iPhone and Apple TV.

## Mental model

```
   Xcode Archive  →  App Store Connect  →  TestFlight (Internal)  →  Family devices
   (you, once)       (one record)            (no review)              (iPhone + Apple TV)
                                              ↑
                                              first build needs a one-time
                                              "Beta App Review" before
                                              external testers can use it.
                                              Internal testers (your team
                                              members) get builds instantly.
```

**One upload, both platforms.** Our `BaekSoeum` target uses
`supportedDestinations: [iOS, tvOS]`, so a single Archive contains both
binaries. App Store Connect lists them as separate platforms under the
same app record.

**Build expiry.** Each TestFlight build is valid for **90 days**. Plan
to upload a fresh build every ~80 days. Family members will see "Build
expired — please update" inside TestFlight.

---

## One-time setup (you, ~30 min)

### 1. Apple Developer console

Already done — team `L324XMPY22` is enrolled in the Apple Developer
Program ($99/yr).

### 2. App Store Connect — create app record

1. Open https://appstoreconnect.apple.com → My Apps → ⊕ New App
2. Fill in:
   - Platforms: **iOS** ✓ and **tvOS** ✓
   - Name: `백색소음`
   - Primary Language: Korean (Korean (South Korea))
   - Bundle ID: `com.tykim.baeksoeum.BaekSoeum` (must match the `xcodegen` `bundleIdPrefix`)
   - SKU: `BAEKSOEUM_001` (any unique string for your records)
   - User Access: Full Access
3. Save. The app record is created. App Information / Pricing / Availability tabs appear.
4. Pricing: **Free** (and pick at least Korea + United States in Availability)

### 3. App Store Connect — privacy

1. App Privacy → Get Started
2. "Do you collect data?" → **No** (per `PRIVACY.md`)
3. Save

### 4. Internal Tester group

1. App Store Connect → your app → **TestFlight** tab
2. Internal Testing → **Add Testers**
3. Each family member needs to be added to your dev team first:
   - https://appstoreconnect.apple.com/access/users → **Users and Access**
   - Invite Apple ID (their email) → role: **Developer** (or **App Manager**)
   - They confirm via email
4. Once added to the team, they appear in TestFlight Internal Testing → Add → tick → Add
5. Max 100 internal testers. Plenty for family.

---

## Each release (you, ~10 min)

### A. Bump version

If the previous build is the same `MARKETING_VERSION` and `CURRENT_PROJECT_VERSION`, App Store Connect will reject the upload. Either:

- Bump `CURRENT_PROJECT_VERSION` (build number) for an internal-only TestFlight refresh: `1` → `2` → `3`
- Bump `MARKETING_VERSION` for a feature release: `0.1.0` → `0.1.1`

Edit in `project.yml`, then `xcodegen generate`.

### B. Archive (Xcode UI)

1. In Xcode, set the destination to **Any iOS Device (arm64)** at the top
2. Product → **Archive**
3. Wait. The Organizer opens.
4. Repeat with destination **Any tvOS Device** for the tvOS build, OR enable both in one archive (Xcode 15+ supports multi-destination archive for multi-platform targets).

   For a single multi-platform archive:
   - Select scheme `BaekSoeum`
   - Destination: **Any Mac (Designed for iPad)** is irrelevant; pick **Any iOS Device (arm64)** then in Organizer choose "Distribute App for iOS" — for tvOS, archive a second time with tvOS destination. Two archives, but both go to the same app record.

### C. Distribute

In Organizer:

1. Select the new archive → **Distribute App**
2. **App Store Connect** → Upload
3. Sign with team `L324XMPY22`
4. Defaults: include bitcode (off in modern Xcode), upload symbols (on), strip Swift symbols (on)
5. Upload — takes 2-10 min

Same for the tvOS archive.

### D. Wait for processing

App Store Connect → TestFlight → **Builds**. Status goes:

```
Processing → (5-15 min) → Ready to Submit / Internal Testing
```

For the **first build only**: Apple does a one-time "Encryption / Export Compliance" check. Answer:

- "Does your app use encryption?" → **Yes** (HTTPS)
- "Does it qualify for the export exemption (3 TSU)?" → **Yes** (uses only HTTPS)
- "ITSAppUsesNonExemptEncryption" — set to NO in Info.plist (we don't, but adding it is safe)

### E. Internal testers get the build automatically

Once the build is "Ready" and you've added Internal Testers, they get an email + push notification: **"백색소음 — New TestFlight build available"**.

---

## Family install (each tester, ~3 min per device)

### iPhone / iPad

1. Open **TestFlight** (App Store has it free; if not installed, install once)
2. Sign in with the Apple ID you invited
3. Tap the email's "Open in TestFlight" or "View in TestFlight" link
4. Tap **Install** — the app installs alongside other apps on Home Screen
5. Done. Open like any other app.

### Apple TV

TestFlight is a **pre-installed system app** on tvOS 11+ (every modern Apple TV).

1. Use the **same Apple ID** on the Apple TV that received the email invite
2. On Apple TV: open the **TestFlight** app
3. The 백색소음 build appears in the list → **Install**
4. App appears on Apple TV's home screen

If TestFlight is missing from the home screen on Apple TV:
- Settings → Apps → TestFlight → **Show on Home Screen**

---

## Refresh cadence

Each TestFlight build is valid for **90 days**. We need a habit of:

1. Bump build number every ~80 days
2. Archive + upload
3. New build auto-replaces the old one for internal testers

Easy reminder: pick a calendar date the same day each quarter (e.g., 1st of every 3rd month) and set a recurring iCal event "Refresh 백색소음 TestFlight build".

---

## Things to watch

- **Audio in background**: requires `UIBackgroundModes: audio` (we have it). Apple reviewers sometimes flag this on first submission; the rationale is "ambient sleep sound playback after the app is backgrounded." Internal builds don't go through this review.
- **Bundle ID consistency**: Xcode build setting `PRODUCT_BUNDLE_IDENTIFIER` must equal App Store Connect's bundle ID. We have it via `bundleIdPrefix: com.tykim.baeksoeum` + target name `BaekSoeum`. Don't rename without updating both.
- **Privacy declaration**: if a future release adds analytics or 3rd-party SDKs, the privacy declaration in App Store Connect must be updated and `PRIVACY.md` revised.
- **Apple TV layered icon**: already shipped (`AppIcon.brandassets`). If Apple's automated checks flag it, regenerate via `Tools/RenderIcon/install.sh`.

---

## If TestFlight expires while you're traveling

The app keeps running on already-installed devices, but cannot be re-launched after expiry. Workaround: have a fresh build queued before extended trips. Or fall back to **Xcode Free Provisioning** for a dev re-install (re-signs every 7 days; not great).

---

## Going public later

When ready for App Store (anyone can install from Korea/US App Store):

1. App Store Connect → your app → **App Store** tab
2. Fill in: name, subtitle, keywords, description, screenshots (use `Tools/out/ux-journey/` shots), categories, age rating, support URL, privacy URL — most of this is already drafted in `MARKETING.md`
3. Select a build (the same one already in TestFlight)
4. Submit for Review
5. Apple reviews (usually 24-48h these days)
6. Approved → ships

The TestFlight Internal flow stays usable forever in parallel with public App Store distribution.
