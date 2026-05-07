# 백색소음

Last updated: 2026-05-07

A bedtime companion for first-time Korean parents (초보 엄마/아빠) of 0-24 month babies. Runs on iPhone and Apple TV. Every feature is grounded in peer-reviewed research; nothing is added that doesn't have evidence.

## Mental Model

The domain is **a parent's nursery at 2am**. Tired, eyes adjusting to dark, holding a baby, one hand free. The TV in the next room is showing nothing useful. The app is the bridge: iPhone is the controller, Apple TV is the nursery anchor.

```
                              ┌────────────────────────┐
                              │  Apple TV (nursery)    │
                              │  - sound playback      │
                              │  - Glow Mode (clock)   │
                              │  - tummy-time slides   │
                              └────────────────────────┘
                                         ▲
                                         │ (planned: iCloud sync)
                                         │
   ┌──────────────┐                      │
   │  Parent      │                      │
   │  (iPhone)    │ ────── 소리 ────────┤
   │              │ ────── 잠 (log) ─────┤  on-device only
   │              │ ────── 루틴 ─────────┤  (CloudKit deferred)
   └──────────────┘                      │
```

**One rule guides every feature decision: if it doesn't have a peer-reviewed paper or a major-pediatric-society guideline behind it, it does not ship.** No Wonder Weeks, no Mozart effect, no Dunstan baby language, no SIDS-claiming breathing monitors.

## Evidence base

| Feature | Citation | Strength |
|---------|----------|----------|
| White / pink noise | [PMC11283987](https://pmc.ncbi.nlm.nih.gov/articles/PMC11283987/) — meta-analysis, +137 min sleep | STRONG |
| Lullabies | [PMC8220405](https://pmc.ncbi.nlm.nih.gov/articles/PMC8220405/) — relaxation response, cross-cultural | STRONG |
| Bedtime routine consistency | [PMC2675894](https://pmc.ncbi.nlm.nih.gov/articles/PMC2675894/) — RCT, 405 dyads, 5+ nights/wk | STRONG |
| Womb / heartbeat sounds | [PubMed 36747385](https://pubmed.ncbi.nlm.nih.gov/36747385/) — preterm primary | MODERATE |
| Tummy time → motor + flat-head | [AAP Pediatrics 2020](https://publications.aap.org/pediatrics/article/145/6/e20192168/) | STRONG |
| High-contrast B&W cards (newborn vision) | [PMC6016435](https://pmc.ncbi.nlm.nih.gov/articles/PMC6016435/) — anatomically grounded; no acceleration RCT | WEAK (paired with tummy time, not standalone) |

## Repo layout

```
my-appletv-app/
  README.md
  DESIGN.md                            Lullaby Navy design system (tokens + sections per Stitch spec)
  CLOUDSYNC.md                         3-step iCloud provisioning guide (deferred)
  project.yml                          xcodegen spec (iOS 18 + tvOS 18 multi-platform target)

  App/
    Sources/
      BaekSoeumApp.swift               @main, attaches SwiftData ModelContainer
      ContentView.swift                Router: TabView (iOS) / single SoundPlayerView (tvOS)
      Theme.swift                      Lullaby Navy tokens (palette / spacing / typography / sizes / focus)

      Audio/
        AudioCoordinator.swift         Single AVAudioSession owner, dispatches noise/lullaby/womb
        SleepTimer.swift               15/30/60 min presets, fades audio at expiry

      Design/
        SoundPalette.swift             Per-source gradient + Korean evidence-based benefit text
        Components.swift               DynamicGradientBackground, GlassPanelBackground, etc.

      Features/
        Sound/                         (in ContentView) iOS stacked + tvOS Apple Music-style hero
        SleepLog/SleepLogView.swift    잠들었어요 / 깼어요 quick log + 7-day SwiftUI Charts
        Routine/BedtimeRoutineView.swift   custom step list + streak counter
        TVGlow/GlowModeView.swift      Big clock + breathing gradient + auto-dim ambient mode

      Models/                          SwiftData @Model: Baby, SleepEvent, BedtimeRoutine, SoundPreferences
      Persistence/AppModelContainer.swift  ModelContainer factory, .none cloudKitDatabase

    Resources/
      Sounds/                          Placeholder ambient MP3s (real CC0 audio sourcing in Sounds/README.md)
      Assets.xcassets/                 AppIcon.appiconset (iOS) + AppIcon.brandassets (tvOS)

  Packages/
    NoiseEngine/                       Mathematically-generated white/pink/brown noise (9 tests)
    LullabyEngine/                     File-based player + linear FadeCurve (8 tests)

  Tools/
    RenderIcon/                        SwiftUI Canvas → PNG icon renderer (run + install.sh)
```

## Getting started

```bash
# 1. Generate the Xcode project from project.yml
xcodegen generate

# 2. Build for iOS Simulator
xcodebuild -project BaekSoeum.xcodeproj -scheme BaekSoeum \
  -destination 'platform=iOS Simulator,name=iPhone 17' build

# 3. Build for tvOS Simulator
xcodebuild -project BaekSoeum.xcodeproj -scheme BaekSoeum \
  -destination 'platform=tvOS Simulator,name=Apple TV 4K (3rd generation)' build

# 4. Run all engine tests
cd Packages/NoiseEngine && swift test
cd Packages/LullabyEngine && swift test
```

The repo is greenfield: no Apple Developer console steps, no certificates, no provisioning. `swift test` runs offline; iOS / tvOS Simulator runs use a local "Sign to Run Locally" identity.

## Re-rendering the app icon

```bash
cd Tools/RenderIcon
swift run RenderIcon         # 12 PNGs to ./out/
./install.sh                 # copy + write nested Contents.json into Asset Catalog
```

The `install.sh` script handles both `AppIcon.appiconset` (iOS, 1 PNG) and `AppIcon.brandassets` (tvOS, 7 PNGs across `App Icon - Small.imagestack`, `App Icon - Large.imagestack`, and `Top Shelf Image.imageset`).

## Versioning

`project.yml` -> `MARKETING_VERSION`. Tagged in git as `vX.Y.Z`.

## What ships in v0.1.0

- White / pink / brown noise (math, no audio assets needed)
- 5 lullabies + 2 womb sounds (placeholder ambient tones; real CC0 sourcing pre-ship per `App/Resources/Sounds/README.md`)
- Sleep timer with 30s linear fade
- iOS: TabView (소리 / 잠 / 루틴)
  - Sound player with hero card + per-source gradient + benefit text
  - Sleep log with quick "잠들었어요 / 깼어요" + SwiftUI Charts weekly bar
  - Bedtime routine with default Korean steps + RCT-aligned streak counter
- tvOS: Apple Music-style hero layout (large art + benefit + play + picker rows)
- Glow Mode (both platforms): big clock + breathing gradient + auto-dim
- Liquid Glass (.ultraThinMaterial) surfaces + dynamic per-sound gradient backgrounds
- Persistence: last source + volume restored across launches (SwiftData on-device)
- iOS app icon (`AppIcon.appiconset`) + tvOS layered brand asset + Top Shelf hero

## What's deferred

- **iCloud sync** (multi-device shared state) — see `CLOUDSYNC.md` for the 3-step Apple Developer + entitlement walkthrough
- **Tummy time mode** — paired iPhone timer + Apple TV high-contrast B&W slideshow (Phase F)
- **Real CC0 audio assets** — current MP3s are ffmpeg-generated placeholders, valid for development
- **App Store metadata + Korean PIPA disclosure** (Phase G)

## License

This repo includes evidence-based product copy ("자연스러운 1/f 소리, 깊은 잠을 유도합니다" etc.) tied to specific peer-reviewed citations. Cite the original papers, not us, if reusing the framing.
