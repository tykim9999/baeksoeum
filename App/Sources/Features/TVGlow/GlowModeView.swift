import SwiftUI

// Ambient nursery mode: big clock + slow-breathing gradient + auto-dim.
// Designed for "set it and look at it all night" use. Exits on tap/back.
struct GlowModeView: View {
    let palette: SoundPalette
    let nowPlayingTitle: String
    let isPlaying: Bool
    let remainingTimerSeconds: Int?
    let onExit: () -> Void

    @State private var dimLevel: Double = 1.0
    @State private var idleTask: Task<Void, Never>?
    @FocusState private var isFocused: Bool

    var body: some View {
        ZStack {
            BreathingGradientBackground(palette: palette)
                .ignoresSafeArea()

            VStack(spacing: clockSpacing) {
                Spacer()

                TimelineView(.everyMinute) { ctx in
                    Text(ctx.date, format: .dateTime.hour(.twoDigits(amPM: .omitted)).minute(.twoDigits))
                        .font(.system(size: clockSize, weight: .light, design: .rounded))
                        .foregroundStyle(Theme.Palette.foreground)
                        .monospacedDigit()
                        .opacity(0.9)
                }

                VStack(spacing: 4) {
                    if isPlaying {
                        HStack(spacing: 8) {
                            Image(systemName: palette.icon)
                                .foregroundStyle(palette.primary)
                            Text(nowPlayingTitle)
                                .font(Theme.Typography.body)
                                .foregroundStyle(Theme.Palette.foregroundMuted)
                        }
                    }
                    if let s = remainingTimerSeconds, s > 0 {
                        Text(timerString(s))
                            .font(Theme.Typography.caption)
                            .foregroundStyle(Theme.Palette.foregroundMuted.opacity(0.7))
                            .monospacedDigit()
                    }
                }

                Spacer()

                Text(exitHint)
                    .font(Theme.Typography.caption)
                    .foregroundStyle(Theme.Palette.foregroundMuted.opacity(0.4))
                    .padding(.bottom, 40)
            }
        }
        .contentShape(Rectangle())
        #if os(iOS)
        .onTapGesture(perform: onExit)
        .toolbar(.hidden, for: .tabBar)
        .statusBarHidden(true)
        #endif
        #if os(tvOS)
        .focusable(true)
        .focused($isFocused)
        .onExitCommand(perform: onExit)
        .onTapGesture(perform: onExit)
        #endif
        .opacity(dimLevel)
        .onAppear {
            resetIdleDimmer()
            #if os(tvOS)
            isFocused = true
            #endif
        }
        .onDisappear {
            idleTask?.cancel()
            idleTask = nil
        }
    }

    private var clockSize: CGFloat {
        #if os(tvOS)
        220
        #else
        128
        #endif
    }

    private var clockSpacing: CGFloat {
        #if os(tvOS)
        32
        #else
        16
        #endif
    }

    private var exitHint: String {
        #if os(tvOS)
        "Menu 버튼 또는 클릭으로 종료"
        #else
        "화면을 탭하면 종료"
        #endif
    }

    private func resetIdleDimmer() {
        dimLevel = 1.0
        idleTask?.cancel()
        idleTask = Task {
            try? await Task.sleep(for: .seconds(120))
            await MainActor.run { withAnimation(.easeOut(duration: 6)) { dimLevel = 0.55 } }
            try? await Task.sleep(for: .seconds(180))
            await MainActor.run { withAnimation(.easeOut(duration: 6)) { dimLevel = 0.28 } }
        }
    }

    private func timerString(_ seconds: Int) -> String {
        let m = seconds / 60
        let s = seconds % 60
        return String(format: "%d:%02d", m, s)
    }
}

// Slow-cycle breathing gradient. Hue/intensity shifts on a ~30s cycle so the
// nursery feels alive without flicker. No frame-by-frame animation -- driver is
// a single .easeInOut.repeatForever, which CoreAnimation handles efficiently.
private struct BreathingGradientBackground: View {
    let palette: SoundPalette
    @State private var phase: Double = 0

    var body: some View {
        LinearGradient(
            stops: [
                .init(color: palette.primary.opacity(0.35 + 0.20 * phase), location: 0),
                .init(color: palette.deep.opacity(0.95), location: 0.55),
                .init(color: Color(.sRGB, red: 0.02, green: 0.05, blue: 0.10, opacity: 1), location: 1),
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        .onAppear {
            withAnimation(.easeInOut(duration: 30).repeatForever(autoreverses: true)) {
                phase = 1.0
            }
        }
    }
}
