import Foundation

// Linear fade-out volume curve. Pure value type; testable without audio.
public struct FadeCurve: Sendable, Equatable {
    public let startVolume: Float
    public let duration: TimeInterval

    public init(startVolume: Float, duration: TimeInterval) {
        self.startVolume = startVolume
        self.duration = duration
    }

    public func volume(at elapsed: TimeInterval) -> Float {
        if elapsed <= 0 { return startVolume }
        if elapsed >= duration { return 0 }
        let progress = Float(elapsed / duration)
        return startVolume * (1 - progress)
    }
}
