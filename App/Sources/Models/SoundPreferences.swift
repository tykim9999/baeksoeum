import Foundation
import SwiftData

@Model
final class SoundPreferences {
    @Attribute(.unique) var id: UUID
    var sourceKindRaw: String        // "noise" | "lullaby" | "womb" | "none"
    var sourceIDRaw: String?         // noise color name OR lullaby/womb id
    var volume: Float
    var defaultTimerMinutes: Int

    init(
        id: UUID = UUID(),
        sourceKind: SourceKind = .noise,
        sourceID: String? = "pink",
        volume: Float = 0.7,
        defaultTimerMinutes: Int = 0
    ) {
        self.id = id
        self.sourceKindRaw = sourceKind.rawValue
        self.sourceIDRaw = sourceID
        self.volume = volume
        self.defaultTimerMinutes = defaultTimerMinutes
    }

    enum SourceKind: String, Sendable {
        case noise
        case lullaby
        case womb
        case none
    }

    var sourceKind: SourceKind {
        get { SourceKind(rawValue: sourceKindRaw) ?? .none }
        set { sourceKindRaw = newValue.rawValue }
    }
}
