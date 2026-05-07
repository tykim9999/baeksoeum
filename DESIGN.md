---
version: alpha
name: Lullaby Navy
description: Baby-night-noise design system inspired by Hatch Rest -- deep navy base, warm peach/amber glow accents, calm geometric typography. Dark-first for nursery use.

colors:
  # Base surfaces (dark-first; nursery context)
  background: "#0A1A34"        # near-black navy, primary surface
  surface: "#13294B"           # Hatch deep navy, raised surface
  surfaceElevated: "#274D7B"   # mid navy, focus / selected card
  surfaceLight: "#FAF8F4"      # cream, light-mode surface
  outline: "#3A5378"           # quiet navy outline / dividers

  # Foreground (text on dark)
  foreground: "#FAF8F4"        # warm cream, primary text on dark
  foregroundMuted: "#B8C2D4"   # soft slate, secondary text
  foregroundDim: "#738DB2"     # tertiary / disabled

  # Foreground (text on light)
  inkPrimary: "#0A1A34"        # deep navy ink for cream surface
  inkSecondary: "#1F4370"

  # Brand & accents (the "glow" palette -- Hatch nightlight DNA)
  primary: "#F4B27A"           # warm peach, primary brand glow
  primarySoft: "#F8C9A0"       # softer peach for hovers
  primaryDeep: "#D6855A"       # pressed / strong peach
  secondary: "#E8A4A4"         # rose pink, second accent
  amber: "#F2C46B"             # warm amber for "white-noise" highlight

  # Functional (semantic colors for noise types -- subdued, not vivid)
  white: "#F4F1EA"             # cream-white for white-noise swatch
  pink: "#E8A4A4"              # rose pink, baby-safe (not neon)
  brown: "#A87856"             # warm brown, not muddy

  # State
  focus: "#F4B27A"             # peach focus ring, visible on Apple TV
  success: "#7DB89C"
  warning: "#E8A57E"
  error: "#C76D6D"

typography:
  # Family: SF Pro on Apple platforms (system); Public Sans as web/cross-platform fallback.
  # Hatch uses proprietary ttCommonsPro -- we substitute with system geometric sans.
  display:
    fontFamily: "-apple-system, 'SF Pro Display', 'Public Sans', system-ui"
    fontSize: 48px
    fontWeight: 600
    lineHeight: 1.05
    letterSpacing: "-0.02em"
  h1:
    fontFamily: "-apple-system, 'SF Pro Display', 'Public Sans', system-ui"
    fontSize: 34px
    fontWeight: 600
    lineHeight: 1.1
    letterSpacing: "-0.015em"
  h2:
    fontFamily: "-apple-system, 'SF Pro Display', 'Public Sans', system-ui"
    fontSize: 22px
    fontWeight: 600
    lineHeight: 1.2
    letterSpacing: "-0.01em"
  body:
    fontFamily: "-apple-system, 'SF Pro Text', 'Public Sans', system-ui"
    fontSize: 17px
    fontWeight: 400
    lineHeight: 1.45
    letterSpacing: 0
  caption:
    fontFamily: "-apple-system, 'SF Pro Text', 'Public Sans', system-ui"
    fontSize: 13px
    fontWeight: 500
    lineHeight: 1.35
    letterSpacing: "0.01em"
  # Apple TV scale -- read at 10ft viewing distance (~2x iPhone)
  tvDisplay:
    fontFamily: "-apple-system, 'SF Pro Display', system-ui"
    fontSize: 96px
    fontWeight: 600
    lineHeight: 1.05
    letterSpacing: "-0.02em"
  tvBody:
    fontFamily: "-apple-system, 'SF Pro Text', system-ui"
    fontSize: 32px
    fontWeight: 500
    lineHeight: 1.3
    letterSpacing: 0

rounded:
  none: 0px
  sm: 8px
  md: 16px
  lg: 24px
  xl: 32px
  full: 9999px

spacing:
  xxs: 4px
  xs: 8px
  sm: 16px
  md: 24px
  lg: 40px
  xl: 80px
  xxl: 120px

components:
  card:
    backgroundColor: "{colors.surface}"
    rounded: "{rounded.md}"
    padding: 16px
    borderWidth: 0px
  cardSelected:
    backgroundColor: "{colors.surfaceElevated}"
    rounded: "{rounded.md}"
    padding: 16px
    borderColor: "{colors.primary}"
    borderWidth: 2px
  buttonPrimary:
    backgroundColor: "{colors.primary}"
    textColor: "{colors.background}"
    rounded: "{rounded.full}"
    paddingX: 24px
    paddingY: 14px
  buttonGhost:
    backgroundColor: "transparent"
    textColor: "{colors.foreground}"
    rounded: "{rounded.full}"
    paddingX: 20px
    paddingY: 12px
  playButton:
    backgroundColor: "{colors.primary}"
    iconColor: "{colors.background}"
    rounded: "{rounded.full}"
    sizeIOS: 96px
    sizeTV: 200px
  swatch:
    rounded: "{rounded.full}"
    sizeIOS: 64px
    sizeTV: 140px
    borderColor: "{colors.outline}"
    borderWidth: 1px
  slider:
    trackHeight: 4px
    trackColor: "{colors.outline}"
    fillColor: "{colors.primary}"
    thumbSize: 28px
    thumbColor: "{colors.foreground}"
  focusRing:
    color: "{colors.focus}"
    width: 4px
    offset: 4px
    rounded: "{rounded.lg}"
---

# 백색소음 -- Lullaby Navy Design System

A calm, dark-first design language for a baby/parent white-noise app on iPhone and Apple TV. Inspired by **Hatch Rest** -- the category leader for baby sleep sound machines -- with its deep navy base palette and warm "glow" accents borrowed from its iconic nightlight. Optimized for use **at 3am in a dark nursery**, where soft warm light is calming and harsh contrast is alarming.

## Overview

**Mood**: Quiet, warm, parental. Not playful, not corporate.

**Primary use cases**:
1. Parent on iPhone, dim room, holding baby, one-handed thumb reach.
2. Apple TV in living room playing through TV speakers; parent navigates from couch with Siri Remote.
3. Always-on overnight; should not emit cold blue light.

**Design pillars**:
- **Dark-first**: deep navy `background` and `surface`. Light mode exists as fallback only.
- **Warm glow**: peach (`#F4B27A`) and amber (`#F2C46B`) replace typical cold-blue accents -- mimicking Hatch nightlight.
- **Generous geometry**: large radii (16-32px), full pills for buttons. Nothing sharp.
- **Reading at distance**: typography scales 2x for Apple TV (`tvDisplay` 96px vs iOS `display` 48px).

**Anti-patterns we explicitly avoid** (see Do's and Don'ts).

## Colors

### Surface palette -- "Hatch navy"
| Token             | Hex       | Use                                              |
|-------------------|-----------|--------------------------------------------------|
| `background`      | #0A1A34   | Root surface in dark mode (the "night sky")      |
| `surface`         | #13294B   | Cards, sheets (Hatch's signature deep navy)      |
| `surfaceElevated` | #274D7B   | Selected card, focus container                   |
| `surfaceLight`    | #FAF8F4   | Light-mode root (warm cream, never pure white)   |
| `outline`         | #3A5378   | 1px dividers, swatch borders -- never aggressive |

### Foreground
- On dark: `foreground` (#FAF8F4 cream) > `foregroundMuted` (#B8C2D4) > `foregroundDim` (#738DB2)
- On light: `inkPrimary` (#0A1A34) > `inkSecondary` (#1F4370)

### Glow / brand accents
| Token         | Hex       | Use                                       |
|---------------|-----------|-------------------------------------------|
| `primary`     | #F4B27A   | Play button, primary CTA, focus glow      |
| `primarySoft` | #F8C9A0   | Hover / pressed (lighter)                 |
| `primaryDeep` | #D6855A   | Active press                              |
| `secondary`   | #E8A4A4   | Rose pink for secondary CTA               |
| `amber`       | #F2C46B   | Warm highlights, "white-noise" indicator  |

### Noise-color swatches (semantic, baby-safe)
| Color   | Token | Hex     | Note                                        |
|---------|-------|---------|---------------------------------------------|
| White   | white | #F4F1EA | Cream-white. Pure #FFFFFF is too clinical.  |
| Pink    | pink  | #E8A4A4 | Rose, not bubblegum. Calming.               |
| Brown   | brown | #A87856 | Warm walnut, not muddy.                     |

## Typography

### Family
**System default** on Apple platforms (`-apple-system` / `SF Pro Display` & `SF Pro Text`). Public Sans as cross-platform fallback. We deliberately do **not** ship a custom font: system fonts are pre-rendered, optimized, and respect Dynamic Type / accessibility settings out of the box. (Hatch's proprietary ttCommonsPro inspires geometry but is not redistributable.)

### Scale
| Token       | Size  | Weight | Line height | Use                                  |
|-------------|-------|--------|-------------|--------------------------------------|
| `display`   | 48px  | 600    | 1.05        | iOS hero titles                      |
| `h1`        | 34px  | 600    | 1.1         | iOS section heads                    |
| `h2`        | 22px  | 600    | 1.2         | iOS subheads                         |
| `body`      | 17px  | 400    | 1.45        | iOS body                             |
| `caption`   | 13px  | 500    | 1.35        | iOS metadata                         |
| `tvDisplay` | 96px  | 600    | 1.05        | tvOS hero (10ft reading distance)    |
| `tvBody`    | 32px  | 500    | 1.3         | tvOS body                            |

### Tracking
- Display sizes: tight (`-0.02em` to `-0.015em`) for confident headlines
- Body: 0
- Caption: open (`+0.01em`) for clarity at small size

## Layout

### Grid & rhythm
- **Spacing scale**: 8px base. Tokens `xxs:4`, `xs:8`, `sm:16`, `md:24`, `lg:40`, `xl:80`, `xxl:120`.
- **Touch target minimum**: 44pt iOS / 60pt tvOS (focus-engine generous).
- **Safe areas**: respect platform safe area insets always; never paint into the dynamic island or tvOS title-safe edges.

### Density
- **iOS**: comfortable. `md` (24px) gap between hero elements; `sm` (16px) within a card.
- **tvOS**: spacious. Promote one rank: gaps that are `md` on iOS become `lg` (40px) on TV; `lg` becomes `xl` (80px).

### Composition rules
- Centered vertical stack for the main player screen (title -> color row -> play button -> volume).
- Color row: equal-spaced 3-up on iOS, equal-spaced 3-up with focus-engine cards on tvOS.
- Volume slider: iOS only. tvOS uses Siri Remote system volume.

## Elevation & Depth

We use **soft, low-contrast** shadows in light mode and **brightness shifts** (not shadows) in dark mode -- shadows on dark navy are nearly invisible and add visual noise.

| Level | Light mode                                  | Dark mode                              |
|-------|---------------------------------------------|----------------------------------------|
| 0     | flat                                        | `background` (#0A1A34)                 |
| 1     | `0 1px 2px rgba(10,26,52,0.06)`             | `surface` (#13294B)                    |
| 2     | `0 4px 12px rgba(10,26,52,0.08)`            | `surfaceElevated` (#274D7B)            |
| 3 (modal) | `0 16px 48px rgba(10,26,52,0.18)`       | `surfaceElevated` + 1px `outline` ring |

**Glow** (focus / active): `0 0 0 4px rgba(244,178,122,0.35)` peach focus ring, `4px` offset. Required on tvOS focused element.

## Shapes

- **Default radius**: `md` (16px) for cards, sheets, swatches' bounding cards.
- **Pill** (`full`): primary CTA buttons, focus chips. Conveys "soft / approachable".
- **Circular**: play button, color swatches.
- **Sharp corners**: never. Even dividers/separators have hairline rounding via 1px outline.

Visual rhythm: every element on screen should pair its radius to one of `sm`/`md`/`lg`/`xl`/`full`. No bespoke radii.

## Components

### Play / Pause button (`playButton`)
- iOS: 96pt circle, peach (`primary`) fill, navy icon.
- tvOS: 200pt circle. Receives default focus on app launch. Focus state: peach glow ring (`focusRing`) + 1.05 scale + slight upward translate (4pt).
- States: idle, focused (tvOS), pressed, playing (icon swap to pause), buffering (subtle 1.2s pulse on icon, never the whole button).

### Color swatch card (`card` / `cardSelected`)
- iOS: 64pt circle swatch + label below, optional surrounding card. Selected state: `surfaceElevated` background + 2px peach border.
- tvOS: 140pt circle inside an `xl` (32px) radius card. Focus state: scale 1.08, `focusRing` glow, label scales up.
- Always 3-up: `white` / `pink` / `brown`. Never reorder.

### Volume slider (`slider`) -- iOS only
- 4px track, fill in `primary` peach. 28px thumb in `foreground` cream with 1px outline.
- Speaker icons left/right (low/high) in `foregroundMuted`.
- tvOS: omit. System volume is owned by Apple TV / Siri Remote.

### Buttons
- `buttonPrimary`: peach pill, navy text. Full radius, 24/14 padding.
- `buttonGhost`: transparent, cream text, full radius. Used for secondary actions (e.g., sleep timer).

### Focus ring (`focusRing`) -- critical on tvOS
- 4px peach (`focus` = `primary`), 4px offset, parent radius + 4 (or `lg` if container has none).
- Always paired with a 1.05-1.08 scale on focused element so motion confirms the focus shift.

## Do's and Don'ts

### Do
- Default to dark mode. The app's primary persona is awake at 2am in a dim nursery.
- Use peach/amber for any "active" or "focus" indicator. Cold-blue accents read as alert/notification, not calm.
- Scale typography and component sizes 1.5-2x on tvOS. The same UI on a 1080p TV from 10ft would be unreadable at iOS sizes.
- Pair every focus state on tvOS with both color (glow ring) AND motion (1.05-1.08 scale). Single-channel focus is missable.
- Test the screen at minimum brightness in a dark room. If anything glares, tone the surface or accent down.
- Keep copy minimal. "백색소음" + 3 swatch labels is enough on the player screen.

### Don't
- Don't use pure `#FFFFFF` text on `#000000`. Use `foreground` (#FAF8F4) cream on `background` (#0A1A34) navy. Pure black/white is harsh in low light.
- Don't animate continuously while playing. Pulsing visualizations look exciting in screenshots and ruin sleep environments. The loudest "indicator" should be the noise itself.
- Don't use red, neon green, or saturated yellow anywhere. These are alert colors and break the calm tone.
- Don't show numeric volume percentages or dB. Parents shouldn't be doing math at 3am.
- Don't auto-pause or auto-stop. A noise app must be reliable; stopping mid-night is the worst possible bug.
- Don't add playful illustrations (cartoon clouds, rainbow icons). Parents are not the target of cuteness; they want grown-up calm. Cuteness is for the baby's room, not the screen they look at while exhausted.
- Don't ship a custom display font in v0. SF Pro / system fonts respect Dynamic Type, ship instantly, and are excellent.
