// Pink noise via Paul Kellet's economy filter (parallel one-pole IIR bank).
// Approximates a -3 dB/octave (1/f) spectrum across the audible band.
public struct PinkNoiseGenerator: Sendable {
    private var white = WhiteNoiseGenerator()
    private var b0: Float = 0
    private var b1: Float = 0
    private var b2: Float = 0
    private var b3: Float = 0
    private var b4: Float = 0
    private var b5: Float = 0
    private var b6: Float = 0

    public init() {}

    public mutating func nextSample() -> Float {
        let w = white.nextSample()
        b0 = 0.99886 * b0 + w * 0.0555179
        b1 = 0.99332 * b1 + w * 0.0750759
        b2 = 0.96900 * b2 + w * 0.1538520
        b3 = 0.86650 * b3 + w * 0.3104856
        b4 = 0.55000 * b4 + w * 0.5329522
        b5 = -0.7616 * b5 - w * 0.0168980
        let pink = b0 + b1 + b2 + b3 + b4 + b5 + b6 + w * 0.5362
        b6 = w * 0.115926
        // Empirical scale; output stddev ~ 0.33 after this. Clamp guards rare 3+ sigma outliers.
        let scaled = pink * 0.11
        return min(max(scaled, -1), 1)
    }
}
