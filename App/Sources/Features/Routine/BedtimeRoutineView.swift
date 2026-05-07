import SwiftUI
import SwiftData

struct BedtimeRoutineView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var routines: [BedtimeRoutine]

    private var routine: BedtimeRoutine? { routines.first }

    @State private var runningStepIndex: Int?

    var body: some View {
        ZStack {
            DynamicGradientBackground(palette: SoundPaletteResolver.placeholder)
                .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: Theme.Spacing.md) {
                    Text("잠자리 루틴")
                        .font(Theme.Typography.h1)
                        .foregroundStyle(Theme.Palette.foreground)

                    StreakCard(streakDays: routine?.streakDays ?? 0)

                    StepsCard(
                        steps: routine?.steps ?? BedtimeRoutine.defaultSteps,
                        runningStepIndex: runningStepIndex,
                        onStart: startRoutine,
                        onAdvance: advanceRoutine,
                        onComplete: completeRoutine
                    )

                    EvidenceCard()

                    Spacer(minLength: Theme.Spacing.xl)
                }
                .padding(.horizontal, Theme.Spacing.lg)
                .padding(.top, Theme.Spacing.md)
            }
        }
        .preferredColorScheme(.dark)
        .onAppear { ensureRoutineExists() }
    }

    private func ensureRoutineExists() {
        guard routine == nil else { return }
        let new = BedtimeRoutine()
        modelContext.insert(new)
        try? modelContext.save()
    }

    private func startRoutine() {
        runningStepIndex = 0
    }

    private func advanceRoutine() {
        guard let i = runningStepIndex else { return }
        let steps = routine?.steps ?? BedtimeRoutine.defaultSteps
        if i + 1 < steps.count {
            runningStepIndex = i + 1
        } else {
            completeRoutine()
        }
    }

    private func completeRoutine() {
        guard let r = routine else { return }
        let cal = Calendar.current
        let today = cal.startOfDay(for: .now)
        if let last = r.lastCompletedAt {
            let lastDay = cal.startOfDay(for: last)
            let daysApart = cal.dateComponents([.day], from: lastDay, to: today).day ?? 0
            if daysApart == 1 {
                r.streakDays += 1
            } else if daysApart > 1 {
                r.streakDays = 1
            } // else same day, no change
        } else {
            r.streakDays = 1
        }
        r.lastCompletedAt = .now
        try? modelContext.save()
        runningStepIndex = nil
    }
}

private struct StreakCard: View {
    let streakDays: Int

    var body: some View {
        HStack(spacing: Theme.Spacing.md) {
            Image(systemName: "flame.fill")
                .font(.system(size: 32))
                .foregroundStyle(streakDays >= 5 ? Theme.Palette.primary : Theme.Palette.foregroundMuted)
            VStack(alignment: .leading, spacing: 2) {
                Text("\(streakDays)일 연속")
                    .font(Theme.Typography.h2)
                    .foregroundStyle(Theme.Palette.foreground)
                Text(subtitle)
                    .font(Theme.Typography.caption)
                    .foregroundStyle(Theme.Palette.foregroundMuted)
            }
            Spacer()
        }
        .padding(Theme.Spacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(GlassPanelBackground())
    }

    private var subtitle: String {
        if streakDays == 0 { return "오늘 첫 루틴을 시작해보세요" }
        if streakDays >= 5 { return "수면 효과가 입증된 5일 이상! 잘하고 있어요" }
        return "5일 이상 연속하면 수면 효과가 커져요 (RCT 입증)"
    }
}

private struct StepsCard: View {
    let steps: [String]
    let runningStepIndex: Int?
    let onStart: () -> Void
    let onAdvance: () -> Void
    let onComplete: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
            Text("오늘의 단계")
                .font(Theme.Typography.h2)
                .foregroundStyle(Theme.Palette.foreground)

            ForEach(Array(steps.enumerated()), id: \.offset) { idx, step in
                StepRow(
                    index: idx + 1,
                    name: step,
                    state: state(for: idx)
                )
                if idx != steps.count - 1 {
                    Divider().background(Color.white.opacity(0.08))
                }
            }

            actionButton
                .padding(.top, Theme.Spacing.sm)
        }
        .padding(Theme.Spacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(GlassPanelBackground())
    }

    private func state(for index: Int) -> StepRow.State {
        guard let running = runningStepIndex else { return .idle }
        if index < running { return .done }
        if index == running { return .active }
        return .upcoming
    }

    private var actionButton: some View {
        let (label, action) = computeAction()
        return Button(action: action) {
            Text(label)
                .font(Theme.Typography.body)
                .foregroundStyle(Theme.Palette.background)
                .frame(maxWidth: .infinity)
                .padding(.vertical, Theme.Spacing.sm)
                .background(Capsule().fill(Theme.Palette.primary))
        }
    }

    private func computeAction() -> (String, () -> Void) {
        if let i = runningStepIndex {
            if i + 1 < steps.count {
                return ("다음 단계", onAdvance)
            }
            return ("완료", onComplete)
        }
        return ("루틴 시작", onStart)
    }
}

private struct StepRow: View {
    enum State { case idle, upcoming, active, done }
    let index: Int
    let name: String
    let state: State

    var body: some View {
        HStack(spacing: Theme.Spacing.sm) {
            ZStack {
                Circle()
                    .fill(circleColor)
                    .frame(width: 32, height: 32)
                Group {
                    switch state {
                    case .done:
                        Image(systemName: "checkmark")
                            .foregroundStyle(Theme.Palette.background)
                    default:
                        Text("\(index)")
                            .foregroundStyle(textColor)
                    }
                }
                .font(Theme.Typography.caption)
            }
            Text(name)
                .font(Theme.Typography.body)
                .foregroundStyle(textColor)
            Spacer()
        }
        .padding(.vertical, Theme.Spacing.xs)
    }

    private var circleColor: Color {
        switch state {
        case .idle, .upcoming: Color.white.opacity(0.12)
        case .active:          Theme.Palette.primary.opacity(0.5)
        case .done:            Theme.Palette.primary
        }
    }

    private var textColor: Color {
        switch state {
        case .idle, .upcoming: Theme.Palette.foregroundMuted
        case .active:          Theme.Palette.foreground
        case .done:            Theme.Palette.foreground.opacity(0.7)
        }
    }
}

private struct EvidenceCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
            Label("과학적 근거", systemImage: "doc.text")
                .font(Theme.Typography.caption)
                .foregroundStyle(Theme.Palette.amber)

            Text("일관된 잠자리 루틴은 잠드는 시간을 단축하고 밤중 깸을 줄입니다 (RCT, 405가족, PMC2675894). 주 5일 이상 같은 시간에 같은 순서로 진행하면 효과가 커집니다.")
                .font(Theme.Typography.caption)
                .foregroundStyle(Theme.Palette.foreground.opacity(0.65))
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(Theme.Spacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(GlassPanelBackground())
    }
}
