// Brown (Brownian / red) noise: leaky integrator of white noise.
// Leak coefficient prevents DC drift; scale keeps output stddev well below clip range.
public struct BrownNoiseGenerator: Sendable {
    private var white = WhiteNoiseGenerator()
    private var state: Float = 0

    public init() {}

    public mutating func nextSample() -> Float {
        let w = white.nextSample()
        state = state * 0.997 + w * 0.05
        return min(max(state, -1), 1)
    }
}
