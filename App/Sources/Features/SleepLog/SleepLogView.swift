import SwiftUI
import SwiftData
import Charts

struct SleepLogView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \SleepEvent.startedAt, order: .reverse) private var events: [SleepEvent]

    @State private var activeEvent: SleepEvent?

    private var weeklyEvents: [SleepEvent] {
        let cutoff = Calendar.current.date(byAdding: .day, value: -7, to: .now) ?? .now
        return events.filter { $0.startedAt >= cutoff }
    }

    private var todayTotalSeconds: Int {
        let cal = Calendar.current
        let start = cal.startOfDay(for: .now)
        return events
            .filter { $0.startedAt >= start && $0.endedAt != nil }
            .reduce(0) { $0 + ($1.durationSeconds ?? 0) }
    }

    @State private var showingTummyTime: Bool = false

    var body: some View {
        ZStack {
            DynamicGradientBackground(
                palette: SoundPaletteResolver.placeholder
            )
            .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: Theme.Spacing.md) {
                    Text("잠 기록")
                        .font(Theme.Typography.h1)
                        .foregroundStyle(Theme.Palette.foreground)

                    QuickLogCard(
                        activeEvent: activeEvent,
                        onSleep: startSleeping,
                        onWake: stopSleeping
                    )

                    TodaySummaryCard(totalSeconds: todayTotalSeconds, eventCount: todayEventCount)

                    Button { showingTummyTime = true } label: {
                        HStack(spacing: Theme.Spacing.sm) {
                            Image(systemName: "figure.child.circle")
                                .font(.system(size: 28))
                                .foregroundStyle(Theme.Palette.primary)
                            VStack(alignment: .leading, spacing: 2) {
                                Text("배밀이 시작")
                                    .font(Theme.Typography.body)
                                    .foregroundStyle(Theme.Palette.foreground)
                                Text("타이머 + 코칭")
                                    .font(Theme.Typography.caption)
                                    .foregroundStyle(Theme.Palette.foregroundMuted)
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundStyle(Theme.Palette.foregroundMuted)
                        }
                        .padding(Theme.Spacing.md)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(GlassPanelBackground())
                    }
                    .buttonStyle(.plain)

                    WeeklyChartCard(events: weeklyEvents)

                    RecentEventsCard(events: Array(events.prefix(10)))

                    Spacer(minLength: Theme.Spacing.xl)
                }
                .padding(.horizontal, Theme.Spacing.lg)
                .padding(.top, Theme.Spacing.md)
            }
        }
        .preferredColorScheme(.dark)
        .onAppear { syncActive() }
        .sheet(isPresented: $showingTummyTime) {
            #if os(iOS)
            NavigationStack { TummyTimeView() }
            #endif
        }
    }

    private var todayEventCount: Int {
        let cal = Calendar.current
        let start = cal.startOfDay(for: .now)
        return events.filter { $0.startedAt >= start }.count
    }

    private func syncActive() {
        activeEvent = events.first { $0.endedAt == nil }
    }

    private func startSleeping() {
        guard activeEvent == nil else { return }
        let now: Date = .now
        let kind: SleepEvent.Kind = nightContext(at: now) ? .night : .nap
        let event = SleepEvent(startedAt: now, kind: kind)
        modelContext.insert(event)
        try? modelContext.save()
        activeEvent = event
    }

    private func stopSleeping() {
        guard let event = activeEvent else { return }
        event.endedAt = .now
        try? modelContext.save()
        activeEvent = nil
    }

    private func nightContext(at date: Date) -> Bool {
        let hour = Calendar.current.component(.hour, from: date)
        return hour >= 19 || hour < 6
    }
}

// MARK: - Cards

private struct QuickLogCard: View {
    let activeEvent: SleepEvent?
    let onSleep: () -> Void
    let onWake: () -> Void

    var body: some View {
        VStack(spacing: Theme.Spacing.sm) {
            if let event = activeEvent {
                Text("자는 중")
                    .font(Theme.Typography.caption)
                    .foregroundStyle(Theme.Palette.foregroundMuted)
                Text(durationString(since: event.startedAt))
                    .font(Theme.Typography.display)
                    .foregroundStyle(Theme.Palette.foreground)
                    .monospacedDigit()
                Button(action: onWake) {
                    Text("깼어요")
                        .font(Theme.Typography.body)
                        .foregroundStyle(Theme.Palette.background)
                        .padding(.horizontal, Theme.Spacing.lg)
                        .padding(.vertical, Theme.Spacing.sm)
                        .background(Capsule().fill(Theme.Palette.primary))
                }
                .padding(.top, Theme.Spacing.xs)
            } else {
                Image(systemName: "moon.stars.fill")
                    .font(.system(size: 56))
                    .foregroundStyle(Theme.Palette.amber)
                Button(action: onSleep) {
                    Text("잠들었어요")
                        .font(Theme.Typography.body)
                        .foregroundStyle(Theme.Palette.background)
                        .padding(.horizontal, Theme.Spacing.lg)
                        .padding(.vertical, Theme.Spacing.sm)
                        .background(Capsule().fill(Theme.Palette.primary))
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(Theme.Spacing.lg)
        .background(GlassPanelBackground())
    }

    private func durationString(since: Date) -> String {
        let elapsed = Int(Date.now.timeIntervalSince(since))
        let h = elapsed / 3600
        let m = (elapsed % 3600) / 60
        return h > 0 ? "\(h)시간 \(m)분" : "\(m)분"
    }
}

private struct TodaySummaryCard: View {
    let totalSeconds: Int
    let eventCount: Int

    var body: some View {
        HStack(spacing: Theme.Spacing.md) {
            stat(value: hourMinute(totalSeconds), label: "오늘 잠")
            Divider().frame(height: 40).background(Color.white.opacity(0.15))
            stat(value: "\(eventCount)", label: "기록 횟수")
        }
        .frame(maxWidth: .infinity)
        .padding(Theme.Spacing.md)
        .background(GlassPanelBackground())
    }

    @ViewBuilder
    private func stat(value: String, label: String) -> some View {
        VStack(spacing: 2) {
            Text(value)
                .font(Theme.Typography.h2)
                .foregroundStyle(Theme.Palette.foreground)
            Text(label)
                .font(Theme.Typography.caption)
                .foregroundStyle(Theme.Palette.foregroundMuted)
        }
        .frame(maxWidth: .infinity)
    }

    private func hourMinute(_ seconds: Int) -> String {
        let h = seconds / 3600
        let m = (seconds % 3600) / 60
        return h > 0 ? "\(h)시간 \(m)분" : "\(m)분"
    }
}

private struct WeeklyChartCard: View {
    let events: [SleepEvent]

    private var dailyTotals: [(day: Date, hours: Double)] {
        let cal = Calendar.current
        var buckets: [Date: Double] = [:]
        for ev in events where ev.endedAt != nil {
            let day = cal.startOfDay(for: ev.startedAt)
            let hours = Double(ev.durationSeconds ?? 0) / 3600
            buckets[day, default: 0] += hours
        }
        // Last 7 days, oldest first
        return (0..<7).reversed().map { offset in
            let day = cal.date(byAdding: .day, value: -offset, to: cal.startOfDay(for: .now))!
            return (day, buckets[day] ?? 0)
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
            Text("최근 7일")
                .font(Theme.Typography.h2)
                .foregroundStyle(Theme.Palette.foreground)

            Chart(dailyTotals, id: \.day) { item in
                BarMark(
                    x: .value("Day", item.day, unit: .day),
                    y: .value("Hours", item.hours)
                )
                .foregroundStyle(Theme.Palette.primary)
                .cornerRadius(6)
            }
            .frame(height: 160)
            .chartYAxis {
                AxisMarks(position: .leading, values: [0, 4, 8, 12]) { value in
                    AxisGridLine().foregroundStyle(Color.white.opacity(0.1))
                    AxisValueLabel().foregroundStyle(Theme.Palette.foregroundMuted)
                }
            }
            .chartXAxis {
                AxisMarks(values: .stride(by: .day)) { value in
                    AxisValueLabel(format: .dateTime.weekday(.narrow))
                        .foregroundStyle(Theme.Palette.foregroundMuted)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(Theme.Spacing.md)
        .background(GlassPanelBackground())
    }
}

private struct RecentEventsCard: View {
    let events: [SleepEvent]

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
            Text("최근 기록")
                .font(Theme.Typography.h2)
                .foregroundStyle(Theme.Palette.foreground)

            if events.isEmpty {
                Text("아직 기록이 없어요. 잠들 때 \"잠들었어요\"를 눌러보세요.")
                    .font(Theme.Typography.caption)
                    .foregroundStyle(Theme.Palette.foregroundMuted)
                    .padding(.vertical, Theme.Spacing.sm)
            } else {
                ForEach(events) { ev in
                    EventRow(event: ev)
                    if ev.id != events.last?.id {
                        Divider().background(Color.white.opacity(0.08))
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(Theme.Spacing.md)
        .background(GlassPanelBackground())
    }
}

private struct EventRow: View {
    let event: SleepEvent

    var body: some View {
        HStack {
            Image(systemName: event.kind == .night ? "moon.fill" : "cloud.sun.fill")
                .foregroundStyle(event.kind == .night ? Theme.Palette.amber : Theme.Palette.primary)
                .frame(width: 24)
            VStack(alignment: .leading, spacing: 2) {
                Text(formatRange(event))
                    .font(Theme.Typography.caption)
                    .foregroundStyle(Theme.Palette.foreground)
                if let dur = event.durationSeconds {
                    Text(formatDuration(dur))
                        .font(Theme.Typography.caption)
                        .foregroundStyle(Theme.Palette.foregroundMuted)
                } else {
                    Text("진행 중")
                        .font(Theme.Typography.caption)
                        .foregroundStyle(Theme.Palette.primary)
                }
            }
            Spacer()
        }
        .padding(.vertical, Theme.Spacing.xs)
    }

    private func formatRange(_ event: SleepEvent) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "M월 d일 a h:mm"
        let start = formatter.string(from: event.startedAt)
        if let end = event.endedAt {
            formatter.dateFormat = "h:mm"
            return "\(start) → \(formatter.string(from: end))"
        }
        return start
    }

    private func formatDuration(_ seconds: Int) -> String {
        let h = seconds / 3600
        let m = (seconds % 3600) / 60
        return h > 0 ? "\(h)시간 \(m)분" : "\(m)분"
    }
}
