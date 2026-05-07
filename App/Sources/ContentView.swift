import SwiftUI
import SwiftData
import NoiseEngine
import LullabyEngine

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var audio = AudioCoordinator()
    @State private var sleepTimer = SleepTimer()

    var body: some View {
        rootView
            .preferredColorScheme(.dark)
            .onAppear {
                audio.attach(modelContext: modelContext)
                sleepTimer.onFadeStart = { duration in
                    audio.fadeOut(duration: duration)
                }
            }
    }

    @ViewBuilder
    private var rootView: some View {
        #if os(tvOS)
        SoundPlayerView(audio: audio, sleepTimer: sleepTimer)
        #else
        TabView {
            SoundPlayerView(audio: audio, sleepTimer: sleepTimer)
                .tabItem {
                    Label("소리", systemImage: "speaker.wave.2.fill")
                }

            SleepLogView()
                .tabItem {
                    Label("잠", systemImage: "moon.stars.fill")
                }

            BedtimeRoutineView()
                .tabItem {
                    Label("루틴", systemImage: "list.bullet")
                }
        }
        .tint(Theme.Palette.primary)
        #endif
    }
}

struct SoundPlayerView: View {
    let audio: AudioCoordinator
    let sleepTimer: SleepTimer
    @FocusState private var focus: FocusTarget?
    @State private var isGlowMode: Bool = false

    enum FocusTarget: Hashable {
        case play
        case noise(NoiseColor)
        case lullaby(String)
        case womb(String)
        case timer(SleepTimer.Preset)
        case glowToggle
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
            } else {
                DynamicGradientBackground(palette: palette)
                    .ignoresSafeArea()

                #if os(tvOS)
                TVPlayerLayout(
                    audio: audio,
                    sleepTimer: sleepTimer,
                    palette: palette,
                    focus: $focus,
                    onEnterGlow: { withAnimation(.easeInOut(duration: 0.6)) { isGlowMode = true } }
                )
                #else
                iOSPlayerLayout(
                    audio: audio,
                    sleepTimer: sleepTimer,
                    palette: palette,
                    focus: $focus,
                    onEnterGlow: { withAnimation(.easeInOut(duration: 0.6)) { isGlowMode = true } }
                )
                #endif
            }
        }
        .onAppear {
            #if os(tvOS)
            focus = .play
            #endif
        }
    }
}

// MARK: - iOS layout (stacked)

private func headline(for source: AudioCoordinator.Source) -> String {
    switch source {
    case .none:                  return "백색소음"
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
                Text("백색소음")
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

    var body: some View {
        VStack(spacing: 0) {
            // Top: hero
            HStack(alignment: .center, spacing: Theme.Spacing.xl) {
                HeroCard(palette: palette, isPlaying: audio.isPlaying)
                    .frame(width: 360, height: 360)

                VStack(alignment: .leading, spacing: Theme.Spacing.md) {
                    Text(headline(for: audio.current))
                        .font(Theme.Typography.display)
                        .foregroundStyle(Theme.Palette.foreground)
                        .lineLimit(2)

                    Text(palette.benefit)
                        .font(Theme.Typography.body)
                        .foregroundStyle(Theme.Palette.foreground.opacity(0.65))
                        .frame(maxWidth: 600, alignment: .leading)

                    HStack(spacing: Theme.Spacing.lg) {
                        PlayButton(
                            isPlaying: audio.isPlaying,
                            action: { audio.togglePlay() }
                        )
                        .focused($focus, equals: .play)

                        SleepTimerChip(timer: sleepTimer, focus: $focus)

                        GlowModeButton(action: onEnterGlow)
                            .focused($focus, equals: .glowToggle)
                    }
                    .padding(.top, Theme.Spacing.sm)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.horizontal, Theme.Spacing.xxl)
            .frame(maxHeight: .infinity)

            // Bottom: picker
            VStack(spacing: Theme.Spacing.md) {
                Divider()
                    .background(Color.white.opacity(0.08))
                    .padding(.horizontal, Theme.Spacing.xxl)

                SoundPicker(audio: audio, focus: $focus)
                    .padding(.bottom, Theme.Spacing.lg)
            }
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
    }
}

private struct SelectedBadge: View {
    var body: some View {
        Circle()
            .fill(Theme.Palette.primary)
            .frame(width: size, height: size)
            .overlay(
                Image(systemName: "checkmark")
                    .font(.system(size: size * 0.55, weight: .bold))
                    .foregroundStyle(Theme.Palette.background)
            )
            .offset(x: size * 0.25, y: -size * 0.25)
    }

    private var size: CGFloat {
        #if os(tvOS)
        32
        #else
        20
        #endif
    }
}

// MARK: - Play button + sleep timer

private struct PlayButton: View {
    let isPlaying: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                if isPlaying {
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    Theme.Palette.primary.opacity(0.4),
                                    Theme.Palette.primary.opacity(0)
                                ],
                                center: .center,
                                startRadius: Theme.Size.playButton * 0.5,
                                endRadius: Theme.Size.playButton * 1.5
                            )
                        )
                        .frame(width: Theme.Size.playButton * 2.8,
                               height: Theme.Size.playButton * 2.8)
                        .blur(radius: 18)
                }
                Circle()
                    .fill(Theme.Palette.primary)
                    .frame(width: Theme.Size.playButton, height: Theme.Size.playButton)
                Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                    .font(.system(size: Theme.Size.playButton * 0.4, weight: .semibold))
                    .foregroundStyle(Theme.Palette.background)
                    .offset(x: isPlaying ? 0 : Theme.Size.playButton * 0.04)
            }
        }
        .buttonStyle(GlassButtonStyle(isCircular: true))
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

private struct FocusReactiveContainer<Content: View>: View {
    let isCircular: Bool
    @ViewBuilder var content: () -> Content
    @Environment(\.isFocused) private var isFocused

    var body: some View {
        content()
            .scaleEffect(isFocused ? Theme.Focus.scale : 1.0)
            .shadow(
                color: Theme.Palette.primary.opacity(isFocused ? 0.55 : 0),
                radius: 32, x: 0, y: 0
            )
            .overlay {
                if isFocused {
                    Group {
                        if isCircular {
                            Circle()
                                .stroke(Theme.Palette.foreground, lineWidth: Theme.Focus.ringWidth)
                        } else {
                            RoundedRectangle(cornerRadius: Theme.Radius.lg + Theme.Focus.ringOffset, style: .continuous)
                                .stroke(Theme.Palette.foreground, lineWidth: Theme.Focus.ringWidth)
                        }
                    }
                    .padding(-Theme.Focus.ringOffset)
                }
            }
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
