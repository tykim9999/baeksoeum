# Enabling iCloud Sync

SwiftData currently runs **on-device only** (`cloudKitDatabase: .none`). Switching to multi-device sync requires three manual steps that need access to the Apple Developer console.

## Step 1 — Apple Developer Console

1. Sign in to https://developer.apple.com/account/resources/identifiers/list with team `L324XMPY22`.
2. Edit the App ID `com.tykim.baeksoeum.BaekSoeum`. Enable:
   - **iCloud** -> "Include CloudKit support"
   - **Push Notifications** (CloudKit needs silent push for change notifications)
3. Create a CloudKit container: `iCloud.com.tykim.baeksoeum.BaekSoeum` (matches the app bundle ID prefix convention).

## Step 2 — Add entitlement to `project.yml`

```yaml
targets:
  BaekSoeum:
    entitlements:
      path: App/BaekSoeum.entitlements
      properties:
        com.apple.developer.icloud-services:
          - CloudKit
        com.apple.developer.icloud-container-identifiers:
          - iCloud.com.tykim.baeksoeum.BaekSoeum
        aps-environment: development
```

Then `xcodegen generate` to apply.

## Step 3 — Switch the ModelConfiguration

In `App/Sources/Persistence/AppModelContainer.swift`:

```swift
let config = ModelConfiguration(
    schema: schema,
    isStoredInMemoryOnly: false,
    cloudKitDatabase: .private("iCloud.com.tykim.baeksoeum.BaekSoeum")
)
```

## Verification

1. Two devices/simulators signed into the same iCloud test account.
2. Insert a `SleepEvent` on device A.
3. Within 5-15 seconds, device B's `@Query` reflects it.

## Privacy notes

- All data stays in the user's **private** CloudKit DB. Apple does not access the contents; the app cannot share across users.
- For App Store Korea (PIPA disclosure), explicitly state: "Baby data is stored only in the user's iCloud private database; it does not leave the user's devices via this app."
- No 3rd-party analytics, no ad SDKs.
