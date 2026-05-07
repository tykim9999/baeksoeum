import SwiftUI

// iOS tummy-time timer + parent prompts.
//
// Evidence: AAP recommends supervised tummy time from birth, building gradually
// to 30 min/day by 3 months, to support gross motor development and reduce
// plagiocephaly (AAP Pediatrics 2020 systematic review).
//
// In-memory only for v0.1.x. SleepEvent-style persistence + history can come
// later if parents want trend tracking.
struct TummyTimeView: View {
    @State private var elapsedSeconds: Int = 0
    @State private var isRunning: Bool = false
    @State private var promptIndex: Int = 0
    @State private var tickTask: Task<Void, Never>?
    @State private var promptTask: Task<Void, Never>?
    @State private var showSlideshow: Bool = false

    @Environment(\.dismiss) private var dismiss

    private let prompts: [String] = [
        "고개를 들 수 있도록 격려해주세요",
        "양손을 받쳐 어깨를 살짝 올려주세요",
        "장난감을 시야에 두면 머리를 따라 돌립니다",
        "엎드린 채로 마사지를 해주세요",
        "노래를 불러주세요 -- 안정에 도움이 됩니다",
        "엄마/아빠 얼굴을 가까이 보여주세요",
    ]

    var body: some View {
        ZStack {
            DynamicGradientBackground(palette: SoundPaletteResolver.placeholder)
                .ignoresSafeArea()

            VStack(spacing: Theme.Spacing.lg) {
                Text("배밀이 시간")
                    .font(Theme.Typography.h1)
                    .foregroundStyle(Theme.Palette.foreground)
                    .padding(.top, Theme.Spacing.lg)

                TimerCard(elapsedSeconds: elapsedSeconds, dailyTarget: dailyTargetSeconds)

                PromptCard(text: prompts[promptIndex % prompts.count])

                HStack(spacing: Theme.Spacing.md) {
                    Button(action: toggle) {
                        HStack(spacing: Theme.Spacing.xs) {
                            Image(systemName: isRunning ? "pause.fill" : "play.fill")
                            Text(isRunning ? "일시정지" : "시작")
                        }
                        .font(Theme.Typography.body)
                        .foregroundStyle(Theme.Palette.background)
                        .padding(.horizontal, Theme.Spacing.lg)
                        .padding(.vertical, Theme.Spacing.sm)
                        .background(Capsule().fill(Theme.Palette.primary))
                    }

                    Button(action: reset) {
                        Image(systemName: "arrow.counterclockwise")
                            .font(Theme.Typography.body)
                            .foregroundStyle(Theme.Palette.foreground)
                            .padding(Theme.Spacing.sm)
                            .background(GlassCapsuleBackground(isSelected: false))
                    }
                }

                EvidenceCaption()

                Spacer()
            }
            .padding(.horizontal, Theme.Spacing.lg)
        }
        .preferredColorScheme(.dark)
        .navigationTitle("배밀이")
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("닫기") { dismiss() }
                    .foregroundStyle(Theme.Palette.foreground)
            }
        }
        .onDisappear { stop() }
    }

    // AAP target builds gradually toward 30 minutes/day by ~3 months. Cap shown.
    private var dailyTargetSeconds: Int { 30 * 60 }

    private func toggle() {
        isRunning ? stop() : start()
    }

    private func start() {
        isRunning = true
        tickTask?.cancel()
        tickTask = Task { [advanceInterval = 1] in
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(advanceInterval))
                guard !Task.isCancelled else { return }
                await MainActor.run { elapsedSeconds += advanceInterval }
            }
        }
        promptTask?.cancel()
        promptTask = Task {
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(20))
                guard !Task.isCancelled else { return }
                await MainActor.run { promptIndex += 1 }
            }
        }
    }

    private func stop() {
        isRunning = false
        tickTask?.cancel()
        tickTask = nil
        promptTask?.cancel()
        promptTask = nil
    }

    private func reset() {
        stop()
        elapsedSeconds = 0
        promptIndex = 0
    }
}

// MARK: - Cards

private struct TimerCard: View {
    let elapsedSeconds: Int
    let dailyTarget: Int

    private var progress: Double {
        min(1, Double(elapsedSeconds) / Double(dailyTarget))
    }

    var body: some View {
        VStack(spacing: Theme.Spacing.sm) {
            Text(timeString(elapsedSeconds))
                .font(.system(size: 84, weight: .light, design: .rounded))
                .foregroundStyle(Theme.Palette.foreground)
                .monospacedDigit()

            ProgressView(value: progress)
                .tint(Theme.Palette.primary)

            Text("AAP 권장: 3개월까지 하루 30분")
                .font(Theme.Typography.caption)
                .foregroundStyle(Theme.Palette.foregroundMuted.opacity(0.8))
        }
        .padding(Theme.Spacing.lg)
        .frame(maxWidth: .infinity)
        .background(GlassPanelBackground())
    }

    private func timeString(_ seconds: Int) -> String {
        let m = seconds / 60
        let s = seconds % 60
        return String(format: "%d:%02d", m, s)
    }
}

private struct PromptCard: View {
    let text: String

    var body: some View {
        Text(text)
            .font(Theme.Typography.body)
            .foregroundStyle(Theme.Palette.foreground)
            .multilineTextAlignment(.center)
            .padding(Theme.Spacing.md)
            .frame(maxWidth: .infinity, minHeight: 80)
            .background(GlassPanelBackground())
    }
}

private struct EvidenceCaption: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Label("과학적 근거", systemImage: "doc.text")
                .font(Theme.Typography.caption)
                .foregroundStyle(Theme.Palette.amber)

            Text("배밀이는 대근육 발달을 돕고 두상 비대칭(plagiocephaly)을 줄입니다 (AAP Pediatrics 2020). 항상 깨어 있을 때, 보호자 감독 하에 시도하세요. 잠은 반드시 등을 대고 재웁니다.")
                .font(Theme.Typography.caption)
                .foregroundStyle(Theme.Palette.foreground.opacity(0.65))
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(Theme.Spacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(GlassPanelBackground())
    }
}
