import Foundation

@Observable
@MainActor
final class SleepTimer {

    enum Preset: Hashable, CaseIterable {
        case off
        case fifteen
        case thirty
        case sixty

        var minutes: Int? {
            switch self {
            case .off:      nil
            case .fifteen:  15
            case .thirty:   30
            case .sixty:    60
            }
        }

        var label: String {
            switch self {
            case .off:      "타이머 끄기"
            case .fifteen:  "15분"
            case .thirty:   "30분"
            case .sixty:    "60분"
            }
        }
    }

    private(set) var preset: Preset = .off
    private(set) var remainingSeconds: Int = 0

    private var tickTask: Task<Void, Never>?
    let fadeDuration: TimeInterval = 30
    var onFadeStart: (@MainActor (TimeInterval) -> Void)?

    func arm(_ preset: Preset) {
        cancel()
        self.preset = preset
        guard let minutes = preset.minutes else { return }
        remainingSeconds = minutes * 60
        startTicking()
    }

    func cancel() {
        tickTask?.cancel()
        tickTask = nil
        preset = .off
        remainingSeconds = 0
    }

    private func startTicking() {
        tickTask = Task { [weak self] in
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(1))
                guard !Task.isCancelled else { return }
                self?.tick()
            }
        }
    }

    private func tick() {
        guard remainingSeconds > 0 else { return }
        remainingSeconds -= 1
        if remainingSeconds == Int(fadeDuration) {
            onFadeStart?(fadeDuration)
        }
        if remainingSeconds == 0 {
            tickTask?.cancel()
            tickTask = nil
            preset = .off
        }
    }
}
