import SwiftUI
import SwiftData
import NoiseEngine
import LullabyEngine

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var audio = AudioCoordinator()
    @State private var sleepTimer = SleepTimer()
    @State private var pendingMode: PendingMode?

    enum PendingMode: Equatable { case glow, tummy, normal }

    var body: some View {
        rootView
            .preferredColorScheme(.dark)
            .onAppear {
                audio.attach(modelContext: modelContext)
                sleepTimer.onFadeStart = { duration in
                    audio.fadeOut(duration: duration)
                }
            }
            .onOpenURL(perform: handle)
    }

    private func handle(_ url: URL) {
        guard url.scheme == "baeksoeum" else { return }
        let host = url.host ?? ""
        let arg = url.pathComponents.dropFirst().first  // first path segment after scheme://host/

        switch host {
        case "glow":
            pendingMode = .glow
        case "tummy":
            pendingMode = .tummy
        case "exit":
            pendingMode = .normal
        case "noise":
            if let arg, let color = NoiseColor(rawValue: arg) {
                audio.select(.noise(color))
                if !audio.isPlaying { audio.play() }
            }
        case "lullaby":
            if let arg, let track = LullabyCatalog.lullabies.first(where: { $0.id == arg }) {
                audio.select(.lullaby(track))
                if !audio.isPlaying { audio.play() }
            }
        case "womb":
            if let arg, let track = LullabyCatalog.wombSounds.first(where: { $0.id == arg }) {
                audio.select(.womb(track))
                if !audio.isPlaying { audio.play() }
            }
        case "play":
            if !audio.isPlaying { audio.play() }
        case "pause":
            audio.pause()
        default:
            break
        }
    }

    @ViewBuilder
    private var rootView: some View {
        #if os(tvOS)
        SoundPlayerView(audio: audio, sleepTimer: sleepTimer, pendingMode: $pendingMode)
        #else
        TabView {
            SoundPlayerView(audio: audio, sleepTimer: sleepTimer, pendingMode: $pendingMode)
                .tabItem {
                    Label("소리", systemImage: "speaker.wave.2.fill")
                }
                .accessibilityIdentifier("tab-sound")

            SleepLogView()
                .tabItem {
                    Label("잠", systemImage: "moon.stars.fill")
                }
                .accessibilityIdentifier("tab-sleep")

            BedtimeRoutineView()
                .tabItem {
                    Label("루틴", systemImage: "list.bullet")
                }
                .accessibilityIdentifier("tab-routine")
        }
        .tint(Theme.Palette.primary)
        #endif
    }
}

struct SoundPlayerView: View {
    let audio: AudioCoordinator
    let sleepTimer: SleepTimer
    @Binding var pendingMode: ContentView.PendingMode?
    @FocusState private var focus: FocusTarget?
    @State private var isGlowMode: Bool = false
    @State private var isTummyTime: Bool = false

    enum FocusTarget: Hashable {
        case play
        case noise(NoiseColor)
        case lullaby(String)
        case womb(String)
        case timer(SleepTimer.Preset)
        case glowToggle
        case tummyToggle
    }

    var body: some View {
        let palette = SoundPaletteResolver.resolve(audio.current)

        ZStack {
            if isGlowMode {
                GlowModeView(
                    palette: palette,
                    nowPlayingTitle: headline(for: audio.current),
                    isPlaying: audio.isPlaying,
                    remainingTimerSeconds: sleepTimer.remainingSeconds > 0 ? sleepTimer.remainingSeconds : nil,
                    onExit: { isGlowMode = false }
                )
                .transition(.opacity)
            } else if isTummyTime {
                TummyTimeOverlay(onExit: { isTummyTime = false })
                    .transition(.opacity)
            } else {
                // Apply the gradient as .background so its .ignoresSafeArea
                // doesn't propagate to the layout sibling and collapse safe
                // area for content. Layout views respect safe area normally.
                #if os(tvOS)
                TVPlayerLayout(
                    audio: audio,
                    sleepTimer: sleepTimer,
                    palette: palette,
                    focus: $focus,
                    onEnterGlow: { withAnimation(.easeInOut(duration: 0.6)) { isGlowMode = true } },
                    onEnterTummy: { withAnimation(.easeInOut(duration: 0.6)) { isTummyTime = true } }
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(
                    DynamicGradientBackground(palette: palette)
                        .ignoresSafeArea()
                )
                #else
                iOSPlayerLayout(
                    audio: audio,
                    sleepTimer: sleepTimer,
                    palette: palette,
                    focus: $focus,
                    onEnterGlow: { withAnimation(.easeInOut(duration: 0.6)) { isGlowMode = true } }
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(
                    DynamicGradientBackground(palette: palette)
                        .ignoresSafeArea()
                )
                #endif
            }
        }
        .onAppear {
            #if os(tvOS)
            focus = .play
            #endif
        }
        .onChange(of: pendingMode) { _, mode in
            guard let mode else { return }
            withAnimation(.easeInOut(duration: 0.4)) {
                switch mode {
                case .glow:   isGlowMode = true;  isTummyTime = false
                case .tummy:  isTummyTime = true; isGlowMode = false
                case .normal: isGlowMode = false; isTummyTime = false
                }
            }
            pendingMode = nil
        }
    }
}

private struct TummyTimeOverlay: View {
    let onExit: () -> Void
    @FocusState private var focused: Bool

    var body: some View {
        ZStack(alignment: .topTrailing) {
            ContrastSlideshow(advanceInterval: 5)

            // Subtle exit hint (also captures input)
            Text("Menu / 클릭으로 종료")
                .font(Theme.Typography.caption)
                .foregroundStyle(Color.black.opacity(0.4))
                .padding(.horizontal, Theme.Spacing.sm)
                .padding(.vertical, Theme.Spacing.xxs)
                .background(Capsule().fill(Color.white.opacity(0.7)))
                .padding(Theme.Spacing.lg)
        }
        .contentShape(Rectangle())
        #if os(tvOS)
        .focusable(true)
        .focused($focused)
        .onExitCommand(perform: onExit)
        .onTapGesture(perform: onExit)
        .onAppear { focused = true }
        #else
        .onTapGesture(perform: onExit)
        #endif
    }
}

// MARK: - iOS layout (stacked)

private func headline(for source: AudioCoordinator.Source) -> String {
    switch source {
    case .none:                  return "달빛자장"
    case .noise(.white):         return "백색 소음"
    case .noise(.pink):          return "분홍 소음"
    case .noise(.brown):         return "갈색 소음"
    case .lullaby(let l):        return l.titleKR
    case .womb(let w):           return w.titleKR
    }
}

private struct iOSPlayerLayout: View {
    let audio: AudioCoordinator
    let sleepTimer: SleepTimer
    let palette: SoundPalette
    @FocusState.Binding var focus: SoundPlayerView.FocusTarget?
    let onEnterGlow: () -> Void

    var body: some View {
        ScrollView {
            VStack(spacing: Theme.Spacing.md) {
                Text("달빛자장")
                    .font(Theme.Typography.caption)
                    .foregroundStyle(Theme.Palette.foregroundMuted.opacity(0.7))
                    .padding(.top, Theme.Spacing.sm)

                HeroCard(palette: palette, isPlaying: audio.isPlaying)
                    .padding(.horizontal, Theme.Spacing.lg)

                VStack(spacing: Theme.Spacing.xxs) {
                    Text(headline(for: audio.current))
                        .font(Theme.Typography.h1)
                        .foregroundStyle(Theme.Palette.foreground)
                    Text(palette.benefit)
                        .font(Theme.Typography.caption)
                        .foregroundStyle(Theme.Palette.foreground.opacity(0.6))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, Theme.Spacing.lg)
                }

                PlayButton(
                    isPlaying: audio.isPlaying,
                    action: { audio.togglePlay() }
                )
                .focused($focus, equals: .play)

                SleepTimerChip(timer: sleepTimer, focus: $focus)

                GlowModeButton(action: onEnterGlow)
                    .padding(.top, Theme.Spacing.xs)

                SoundPicker(audio: audio, focus: $focus)
                    .padding(.top, Theme.Spacing.sm)

                #if os(iOS)
                VolumeSlider(volume: Binding(
                    get: { audio.volume },
                    set: { audio.volume = $0 }
                ))
                .padding(.horizontal, Theme.Spacing.lg)
                .padding(.vertical, Theme.Spacing.md)
                #endif
            }
            .frame(maxWidth: .infinity)
            .padding(.bottom, Theme.Spacing.xl)
        }
    }
}

// MARK: - tvOS layout (Apple Music-style hero + picker)

private struct TVPlayerLayout: View {
    let audio: AudioCoordinator
    let sleepTimer: SleepTimer
    let palette: SoundPalette
    @FocusState.Binding var focus: SoundPlayerView.FocusTarget?
    let onEnterGlow: () -> Void
    let onEnterTummy: () -> Void

    var body: some View {
        // ScrollView guarantees content fits / scrolls if needed and lets
        // .padding work as expected. Apple HIG tvOS: keep content within ~90%
        // of canvas; that's roughly 80pt top/bottom + 120pt sides on 1920x1080
        // logical points.
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: Theme.Spacing.xl) {
                // Hero -- art + title/benefit + transport
                HStack(alignment: .center, spacing: Theme.Spacing.xl) {
                    HeroCard(palette: palette, isPlaying: audio.isPlaying)
                        .frame(width: 320, height: 320)

                    VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                        Text(headline(for: audio.current))
                            .font(Theme.Typography.display)
                            .foregroundStyle(Theme.Palette.foreground)
                            .lineLimit(2)

                        Text(palette.benefit)
                            .font(Theme.Typography.body)
                            .foregroundStyle(Theme.Palette.foreground.opacity(0.65))
                            .frame(maxWidth: 720, alignment: .leading)
                            .padding(.bottom, Theme.Spacing.sm)

                        HStack(spacing: Theme.Spacing.lg) {
                            PlayButton(
                                isPlaying: audio.isPlaying,
                                action: { audio.togglePlay() }
                            )
                            .focused($focus, equals: .play)

                            SleepTimerChip(timer: sleepTimer, focus: $focus)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }

                // Picker rows
                SoundPicker(audio: audio, focus: $focus)

                // Mode toggles
                HStack(spacing: Theme.Spacing.md) {
                    GlowModeButton(action: onEnterGlow)
                        .focused($focus, equals: .glowToggle)
                    TummyTimeButton(action: onEnterTummy)
                        .focused($focus, equals: .tummyToggle)
                }
            }
            .padding(.top, 80)
            .padding(.bottom, 60)
            .padding(.horizontal, 120)
        }
    }

}

// MARK: - Hero card (large art tile)

private struct HeroCard: View {
    let palette: SoundPalette
    let isPlaying: Bool

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: Theme.Radius.xl)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: Theme.Radius.xl)
                        .fill(
                            RadialGradient(
                                colors: [palette.primary.opacity(0.5), .clear],
                                center: .center,
                                startRadius: 30,
                                endRadius: 250
                            )
                        )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: Theme.Radius.xl)
                        .stroke(Color.white.opacity(0.15), lineWidth: 1)
                )

            Image(systemName: palette.icon)
                .font(.system(size: iconSize, weight: .semibold))
                .foregroundStyle(.white.opacity(0.85))
                .shadow(color: palette.primary.opacity(0.7), radius: 24)
                .symbolEffect(.pulse, options: .repeating, isActive: false) // off; per DESIGN.md no continuous animation
        }
        .frame(maxWidth: .infinity)
        .frame(height: cardHeight)
        .animation(.easeInOut(duration: 0.6), value: palette.icon)
    }

    private var iconSize: CGFloat {
        #if os(tvOS)
        160
        #else
        96
        #endif
    }

    private var cardHeight: CGFloat {
        #if os(tvOS)
        360
        #else
        220
        #endif
    }
}

// MARK: - Sound picker (rows)

private struct SoundPicker: View {
    let audio: AudioCoordinator
    @FocusState.Binding var focus: SoundPlayerView.FocusTarget?

    var body: some View {
        VStack(alignment: .leading, spacing: pickerSpacing) {
            PickerRow(label: "노이즈") {
                ForEach(NoiseColor.allCases, id: \.self) { c in
                    SwatchButton(
                        color: c,
                        isSelected: audio.current == .noise(c),
                        action: {
                            audio.select(.noise(c))
                            if !audio.isPlaying { audio.play() }
                        }
                    )
                    .focused($focus, equals: .noise(c))
                }
            }

            PickerRow(label: "자장가") {
                ForEach(LullabyCatalog.lullabies) { l in
                    LullabyCard(
                        lullaby: l,
                        isSelected: audio.current == .lullaby(l),
                        action: {
                            audio.select(.lullaby(l))
                            if !audio.isPlaying { audio.play() }
                        }
                    )
                    .focused($focus, equals: .lullaby(l.id))
                }
            }

            PickerRow(label: "태아 음") {
                ForEach(LullabyCatalog.wombSounds) { w in
                    WombChip(
                        track: w,
                        isSelected: audio.current == .womb(w),
                        action: {
                            audio.select(.womb(w))
                            if !audio.isPlaying { audio.play() }
                        }
                    )
                    .focused($focus, equals: .womb(w.id))
                }
            }
        }
        .padding(.horizontal, Theme.Spacing.lg)
    }

    private var pickerSpacing: CGFloat {
        #if os(tvOS)
        Theme.Spacing.md
        #else
        Theme.Spacing.sm
        #endif
    }
}

private struct PickerRow<Content: View>: View {
    let label: String
    @ViewBuilder var content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
            Text(label)
                .font(Theme.Typography.caption)
                .foregroundStyle(Theme.Palette.foregroundMuted.opacity(0.7))

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: Theme.Spacing.sm) {
                    content()
                }
                .padding(.vertical, Theme.Spacing.xxs)
            }
        }
    }
}

// MARK: - Selectable items

private struct SwatchButton: View {
    let color: NoiseColor
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: Theme.Spacing.xxs) {
                Circle()
                    .fill(swatch)
                    .frame(width: swatchSize, height: swatchSize)
                    .overlay(
                        Circle().stroke(.white.opacity(0.2), lineWidth: 1)
                    )
                Text(label)
                    .font(Theme.Typography.caption)
                    .foregroundStyle(Theme.Palette.foreground)
            }
            .padding(Theme.Spacing.sm)
            .frame(width: cardSize, height: cardSize)
            .background(
                GlassCardBackground(isSelected: isSelected)
            )
            .overlay(alignment: .topTrailing) {
                if isSelected { SelectedBadge() }
            }
        }
        .buttonStyle(GlassButtonStyle(isCircular: false))
        .accessibilityIdentifier("noise-\(color.rawValue)")
    }

    private var swatch: Color {
        switch color {
        case .white: Theme.Palette.swatchWhite
        case .pink:  Theme.Palette.swatchPink
        case .brown: Theme.Palette.swatchBrown
        }
    }

    private var label: String {
        switch color {
        case .white: "백색"
        case .pink:  "분홍"
        case .brown: "갈색"
        }
    }

    private var swatchSize: CGFloat {
        #if os(tvOS)
        80
        #else
        44
        #endif
    }

    private var cardSize: CGFloat {
        #if os(tvOS)
        160
        #else
        96
        #endif
    }
}

private struct LullabyCard: View {
    let lullaby: Lullaby
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: Theme.Spacing.xxs) {
                Image(systemName: "music.note")
                    .font(.system(size: iconSize, weight: .medium))
                    .foregroundStyle(Theme.Palette.amber)
                Text(lullaby.titleKR)
                    .font(Theme.Typography.caption)
                    .foregroundStyle(Theme.Palette.foreground)
                    .lineLimit(1)
            }
            .padding(Theme.Spacing.sm)
            .frame(width: cardWidth, height: cardSize)
            .background(
                GlassCardBackground(isSelected: isSelected)
            )
            .overlay(alignment: .topTrailing) {
                if isSelected { SelectedBadge() }
            }
        }
        .buttonStyle(GlassButtonStyle(isCircular: false))
        .accessibilityIdentifier("lullaby-\(lullaby.id)")
    }

    private var iconSize: CGFloat {
        #if os(tvOS)
        56
        #else
        28
        #endif
    }

    private var cardSize: CGFloat {
        #if os(tvOS)
        160
        #else
        96
        #endif
    }

    private var cardWidth: CGFloat {
        #if os(tvOS)
        180
        #else
        120
        #endif
    }
}

private struct WombChip: View {
    let track: Lullaby
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: Theme.Spacing.xs) {
                Image(systemName: track.id == "heartbeat" ? "heart.fill" : "drop.fill")
                    .foregroundStyle(Theme.Palette.primary)
                Text(track.titleKR)
                    .font(Theme.Typography.body)
                    .foregroundStyle(Theme.Palette.foreground)
            }
            .padding(.horizontal, Theme.Spacing.md)
            .padding(.vertical, Theme.Spacing.sm)
            .background(
                GlassCapsuleBackground(isSelected: isSelected)
            )
        }
        .buttonStyle(GlassButtonStyle(isCircular: false))
        .accessibilityIdentifier("womb-\(track.id)")
    }
}

// Sits flush inside the card's top-right corner (no offset) so it doesn't
// notch the selection border. Card has its own peach 4pt outer ring; the
// badge is purely a glanceable confirmation icon.
private struct SelectedBadge: View {
    var body: some View {
        ZStack {
            Circle()
                .fill(Theme.Palette.primary)
                .frame(width: size, height: size)
                .overlay(
                    Circle().stroke(Theme.Palette.background, lineWidth: 2)
                )
            Image(systemName: "checkmark")
                .font(.system(size: size * 0.55, weight: .bold))
                .foregroundStyle(Theme.Palette.background)
        }
        .padding(Theme.Spacing.xxs)
    }

    private var size: CGFloat {
        #if os(tvOS)
        28
        #else
        18
        #endif
    }
}

// MARK: - Play button + sleep timer

private struct PlayButton: View {
    let isPlaying: Bool
    let action: () -> Void

    private var haloMultiplier: CGFloat {
        // Constrain so the glow doesn't dwarf the surrounding controls on TV.
        #if os(tvOS)
        1.6
        #else
        2.4
        #endif
    }

    private var haloOpacity: Double {
        #if os(tvOS)
        0.30
        #else
        0.40
        #endif
    }

    var body: some View {
        Button(action: action) {
            PlayButtonLabel(isPlaying: isPlaying, haloMultiplier: haloMultiplier, haloOpacity: haloOpacity)
        }
        .buttonStyle(GlassButtonStyle(isCircular: true))
        .accessibilityIdentifier("play-button")
        .accessibilityLabel(isPlaying ? "일시정지" : "재생")
    }
}

// Separate label view so it can read \.isFocused (set when the parent Button
// is focused) and draw a focus ring sized to the *actual peach circle*,
// not to the halo footprint frame.
private struct PlayButtonLabel: View {
    let isPlaying: Bool
    let haloMultiplier: CGFloat
    let haloOpacity: Double
    @Environment(\.isFocused) private var isFocused

    var body: some View {
        ZStack {
            if isPlaying {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Theme.Palette.primary.opacity(haloOpacity),
                                Theme.Palette.primary.opacity(0)
                            ],
                            center: .center,
                            startRadius: Theme.Size.playButton * 0.5,
                            endRadius: Theme.Size.playButton * (haloMultiplier * 0.5)
                        )
                    )
                    .frame(width: Theme.Size.playButton * haloMultiplier,
                           height: Theme.Size.playButton * haloMultiplier)
                    .blur(radius: 14)
            }

            // Peach circle + focus ring as one composed shape. The cream ring
            // sits 4pt outside the actual button edge, regardless of halo size.
            ZStack {
                Circle()
                    .fill(Theme.Palette.primary)
                if isFocused {
                    Circle()
                        .stroke(Theme.Palette.foreground, lineWidth: 4)
                        .padding(-4)
                }
            }
            .frame(width: Theme.Size.playButton, height: Theme.Size.playButton)

            Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                .font(.system(size: Theme.Size.playButton * 0.4, weight: .semibold))
                .foregroundStyle(Theme.Palette.background)
                .offset(x: isPlaying ? 0 : Theme.Size.playButton * 0.04)
        }
        // Reserve a fixed footprint so the halo can't push neighbors around.
        .frame(width: Theme.Size.playButton * haloMultiplier,
               height: Theme.Size.playButton * haloMultiplier)
    }
}

private struct SleepTimerChip: View {
    let timer: SleepTimer
    @FocusState.Binding var focus: SoundPlayerView.FocusTarget?

    var body: some View {
        HStack(spacing: Theme.Spacing.xs) {
            ForEach(SleepTimer.Preset.allCases, id: \.self) { p in
                if p == .off {
                    if timer.preset != .off {
                        Button { timer.cancel() } label: {
                            Image(systemName: "xmark")
                                .font(Theme.Typography.caption)
                                .foregroundStyle(Theme.Palette.foregroundMuted)
                                .padding(.horizontal, Theme.Spacing.sm)
                                .padding(.vertical, Theme.Spacing.xs)
                                .background(GlassCapsuleBackground(isSelected: false))
                        }
                        .buttonStyle(GlassButtonStyle(isCircular: false))
                        .focused($focus, equals: .timer(p))
                    }
                } else {
                    let isActive = timer.preset == p
                    Button {
                        isActive ? timer.cancel() : timer.arm(p)
                    } label: {
                        Text(label(for: p))
                            .font(Theme.Typography.caption)
                            .foregroundStyle(isActive ? Theme.Palette.background : Theme.Palette.foreground)
                            .padding(.horizontal, Theme.Spacing.md)
                            .padding(.vertical, Theme.Spacing.xs)
                            .background(GlassCapsuleBackground(isSelected: isActive))
                    }
                    .buttonStyle(GlassButtonStyle(isCircular: false))
                    .focused($focus, equals: .timer(p))
                }
            }
        }
    }

    private func label(for p: SleepTimer.Preset) -> String {
        if timer.preset == p && p != .off {
            let m = timer.remainingSeconds / 60
            let s = timer.remainingSeconds % 60
            return String(format: "%d:%02d", m, s)
        }
        return p.label
    }
}

// MARK: - Glass button style (focus + press)

private struct GlowModeButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: Theme.Spacing.xs) {
                Image(systemName: "moon.stars.fill")
                    .foregroundStyle(Theme.Palette.amber)
                Text("달빛 모드")
                    .font(Theme.Typography.caption)
                    .foregroundStyle(Theme.Palette.foreground)
            }
            .padding(.horizontal, Theme.Spacing.md)
            .padding(.vertical, Theme.Spacing.xs)
            .background(GlassCapsuleBackground(isSelected: false))
        }
        .buttonStyle(GlassButtonStyle(isCircular: false))
        .accessibilityIdentifier("glow-toggle")
    }
}

private struct TummyTimeButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: Theme.Spacing.xs) {
                Image(systemName: "figure.child.circle")
                    .foregroundStyle(Theme.Palette.primary)
                Text("배밀이 시각자극")
                    .font(Theme.Typography.caption)
                    .foregroundStyle(Theme.Palette.foreground)
            }
            .padding(.horizontal, Theme.Spacing.md)
            .padding(.vertical, Theme.Spacing.xs)
            .background(GlassCapsuleBackground(isSelected: false))
        }
        .buttonStyle(GlassButtonStyle(isCircular: false))
        .accessibilityIdentifier("tummy-toggle")
    }
}

private struct GlassButtonStyle: ButtonStyle {
    let isCircular: Bool

    func makeBody(configuration: Configuration) -> some View {
        FocusReactiveContainer(isCircular: isCircular) {
            configuration.label
                .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
                .animation(.spring(response: 0.25, dampingFraction: 0.8), value: configuration.isPressed)
        }
    }
}

// Apple-TV-native focus treatment: lift (scale) + soft peach halo glow.
// No stroke ring on cards/chips -- it would stack with the peach selection
// border. Lift + halo + bg-tint convey focus clearly (see Apple Music +
// native .card style). Circular play button draws its own cream ring
// inside its body, sized to the actual button (not the halo footprint).
private struct FocusReactiveContainer<Content: View>: View {
    let isCircular: Bool
    @ViewBuilder var content: () -> Content
    @Environment(\.isFocused) private var isFocused

    var body: some View {
        content()
            .scaleEffect(isFocused ? Theme.Focus.scale : 1.0)
            .shadow(
                color: Theme.Palette.primary.opacity(isFocused ? 0.42 : 0),
                radius: 26, x: 0, y: 0
            )
            .animation(.spring(response: 0.3, dampingFraction: 0.75), value: isFocused)
    }
}

// MARK: - Volume slider (iOS only)

#if os(iOS)
private struct VolumeSlider: View {
    @Binding var volume: Float

    var body: some View {
        HStack(spacing: Theme.Spacing.sm) {
            Image(systemName: "speaker.fill")
                .foregroundStyle(Theme.Palette.foregroundMuted)
            Slider(value: Binding(
                get: { Double(volume) },
                set: { volume = Float($0) }
            ))
            .tint(Theme.Palette.primary)
            Image(systemName: "speaker.wave.3.fill")
                .foregroundStyle(Theme.Palette.foregroundMuted)
        }
    }
}
#endif

#Preview {
    ContentView()
}
