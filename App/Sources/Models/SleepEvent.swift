import Foundation
import SwiftData

@Model
final class SleepEvent {
    @Attribute(.unique) var id: UUID
    var baby: Baby?
    var startedAt: Date
    var endedAt: Date?
    var kindRaw: String
    var notes: String?

    enum Kind: String, CaseIterable, Sendable {
        case night
        case nap
    }

    var kind: Kind {
        get { Kind(rawValue: kindRaw) ?? .night }
        set { kindRaw = newValue.rawValue }
    }

    var durationSeconds: Int? {
        guard let endedAt else { return nil }
        return Int(endedAt.timeIntervalSince(startedAt))
    }

    init(
        id: UUID = UUID(),
        baby: Baby? = nil,
        startedAt: Date = .now,
        endedAt: Date? = nil,
        kind: Kind = .night,
        notes: String? = nil
    ) {
        self.id = id
        self.baby = baby
        self.startedAt = startedAt
        self.endedAt = endedAt
        self.kindRaw = kind.rawValue
        self.notes = notes
    }
}
