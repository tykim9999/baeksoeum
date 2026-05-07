# Audio Asset Audit

Last updated: 2026-05-07

For a sleep app, the bundled audio is the product. This file documents what's
shipping, what's procedural vs recorded, and the realistic path to real-recorded
content for App Store release.

## What's currently bundled (v0.1.x)

| File | Method | Duration | Bitrate | Scientific criteria met? | Ship-readiness |
|------|--------|----------|---------|--------------------------|----------------|
| `lullaby_brahms.mp3`     | Procedural F-major triad pad (174.61 + 220 + 261.63 + 87.30 Hz) with slow tremolo, lowpass 2kHz, fade in/out | 60s | 192k | YES — slow tempo, consonant, low-freq dominant (PMC8220405) | Family TestFlight ✓; App Store ⚠ (pleasant ambient but not the "Brahms melody") |
| `lullaby_wiegenlied.mp3` | G-major triad pad (196 + 246.94 + 293.66 + 98) | 60s | 192k | YES | same as above |
| `lullaby_twinkle.mp3`    | C-major triad pad (261.63 + 329.63 + 392 + 130.81) | 60s | 192k | YES | same |
| `lullaby_jajangga.mp3`   | A pentatonic-leaning pad (220 + 261.63 + 329.63 + 110) | 60s | 192k | YES | same |
| `lullaby_seomjip.mp3`    | D-minor pentatonic pad (146.83 + 174.61 + 220 + 73.42) | 60s | 192k | YES | same |
| `womb_heartbeat.mp3`     | Procedurally synthesized lub-DUB at 60 BPM (S1=50Hz, S2=70Hz, ~0.30s S1-S2 interval) + light brown-noise rumble | 60s | 128k | YES — matches PubMed 36747385 maternal-cardiac criteria | Ship ✓ |
| `womb_flow.mp3`          | Brown noise lowpass-filtered to 180Hz | 60s | 128k | YES — matches intrauterine acoustic profile | Ship ✓ |

## Why procedural is scientifically valid

The peer-reviewed evidence for these features specifies the **acoustic profile**, not a specific cultural recording. Music-therapy criteria (PMC8220405):

- Slow tempo (60-80 BPM)
- Consonant harmony
- Low-frequency dominant
- No abrupt dynamic changes
- Continuous / loopable

The procedural pads meet all five criteria. The science doesn't require "the canonical Brahms recording" — it requires music-therapy-appropriate ambient sound. A 78 RPM scratchy recording with surface hiss and -39 LUFS loudness would *fail* the "no abrupt dynamics" + cleanliness criteria, even though it's the "real" composition.

For heartbeat, the science (PubMed 36747385) specifies:
- 60-72 BPM rhythmic pulse
- "lub-DUB" double-thump pattern (S1 + S2 cardiac sounds)
- Sub-100Hz frequency dominant

Our procedural lub-DUB at exactly 60 BPM with proper S1/S2 timing matches this profile better than a generic single-pulse tremolo would.

## Trade-off: cultural authenticity vs scientific compliance

| Dimension | Procedural pads | Real-recorded lullaby (e.g. Brahms 78 RPM) |
|-----------|-----------------|--------------------------------------------|
| Slow tempo | ✓ | ✓ |
| Consonant harmony | ✓ (chord) | ✓ (composed) |
| Low-frequency dominant | ✓ (lowpassed) | partial (full-spectrum) |
| Clean / loopable | ✓ | ✗ (surface hiss) |
| No abrupt dynamics | ✓ | ✗ (musical phrasing) |
| Cultural authenticity ("this IS Brahms") | ✗ | ✓ |
| App Store license safe | ✓ (own creation) | ⚠ (78 RPM era — depends on exact year + jurisdiction) |
| Loudness ready | ✓ (-16 LUFS-ish) | ✗ (need +20dB normalization) |

For a v1 app prioritizing infant sleep outcomes, the procedural pads are the right call. They're scientifically aligned, cleanly loopable, and legally safe.

For App Store marketing ("Brahms's Wiegenlied!"), real-recorded music is the cultural ask. That's a v2 sourcing project, not a v1 blocker.

## Sources surveyed

| Source | License clarity | Audio quality | Effort | Best for | Verdict |
|--------|-----------------|---------------|--------|----------|---------|
| **Internet Archive 78 RPM** | UNCLEAR — no explicit CC0/PD declarations on items | Vintage shellac hiss; -39 LUFS; tempo correct | Low (no key, REST API) | Historical recordings | App Store risky; family-only OK |
| **IA license-filtered (CC0/PD)** | CLEAR | OK | Low | — | Wrong genre — only "Lullaby of Birdland" jazz, no classical lullaby |
| **Pixabay Music** | CLEAR (free commercial, no attribution) | Modern stock-music quality | Medium — JS-heavy, anti-bot blocks curl; need playwright + audio extraction script | Generic lullaby ambient | Best for v2 if scripted |
| **Freesound.org CC0 filter** | CLEAR CC0 | Variable — community uploads | Medium — free API key registration (1 min) | **Heartbeat, womb sounds** — has medical-grade recordings | Best for womb/heartbeat in v2 |
| **YouTube Audio Library** | CLEAR (free for any use) | Curated by Google | High — manual download per track, no API | Classical lullaby instrumentals | Best for v2 lullabies |
| **Wikimedia Commons** | CLEAR PD/CC0 | OK | Low (no key) | PD compositions | Few classical lullaby recordings; not a complete catalog |
| **AI-generated** (Stable Audio Open / Suno / Udio) | RISKY — license varies; commercial-ship status unclear | Variable | High setup | Custom-spec ambient | Not recommended for App Store |
| **Procedural ffmpeg** (current) | CLEAR (own creation, MIT-equivalent) | Synthetic but science-aligned | Zero ongoing | Ambient drones | Ships now ✓ |

## Recommended path to real-recorded for v2

If/when you want named-melody lullabies (e.g. App Store marketing wants a recognizable Brahms), the cleanest path:

1. **Heartbeat / womb flow**: register Freesound.org API key (free), filter `license:"Creative Commons 0"` + search "fetal heartbeat", "womb sounds". 5-10 min, finds medical-grade recordings.

2. **Western classical lullabies (Brahms, Mozart, Twinkle)**: YouTube Audio Library has free-for-commercial-use piano renditions. Manual download each. ~30 min.

3. **Korean traditional 자장가 / 섬집아기**: not easily sourced as CC0. Options:
   - Commission a Korean musician for ~$50-100/track instrumental piano renditions (Kmong, Fiverr)
   - National Gugak Center (국립국악원) has some traditional recordings — check their licensing
   - Or keep procedural pentatonic pads for these (cultural authenticity less critical when the listener is a 3-month-old)

## Re-rendering the procedural assets

If you tweak the chord choices or filters in the `ffmpeg` invocations:

```bash
# See git history for full ffmpeg commands per file
cd App/Resources/Sounds
# (re-run the exact command from the audit commit; or edit + rebuild)
```

The lub-DUB heartbeat generator lives in this commit history under the
`/tmp/audio-candidates/` ad-hoc Python script. If we end up regenerating
often, lift it into `Tools/RenderHeartbeat/` as a proper Swift Package
executable (matches the `Tools/RenderIcon/` pattern).

## Bundled-asset cost

Total app-bundled audio: 7 files × ~1MB each ≈ 9 MB. Acceptable for a free
sleep app. iCloud sync of preferences (not audio) is unaffected.
