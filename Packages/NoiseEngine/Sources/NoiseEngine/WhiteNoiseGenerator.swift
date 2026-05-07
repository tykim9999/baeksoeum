public struct WhiteNoiseGenerator: Sendable {
    private var rng = SystemRandomNumberGenerator()

    public init() {}

    public mutating func nextSample() -> Float {
        Float.random(in: -1...1, using: &rng)
    }
}
