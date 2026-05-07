import Foundation
import SwiftData

@Model
final class BedtimeRoutine {
    @Attribute(.unique) var id: UUID
    var baby: Baby?
    var steps: [String]
    var lastCompletedAt: Date?
    var streakDays: Int

    init(
        id: UUID = UUID(),
        baby: Baby? = nil,
        steps: [String] = BedtimeRoutine.defaultSteps,
        lastCompletedAt: Date? = nil,
        streakDays: Int = 0
    ) {
        self.id = id
        self.baby = baby
        self.steps = steps
        self.lastCompletedAt = lastCompletedAt
        self.streakDays = streakDays
    }

    // Default Korean bedtime routine. Evidence: bedtime routine consistency,
    // PMC2675894 (RCT, 5+ nights/wk reduces sleep-onset latency).
    static let defaultSteps: [String] = [
        "목욕",
        "마사지",
        "수유",
        "자장가",
        "소등"
    ]
}
