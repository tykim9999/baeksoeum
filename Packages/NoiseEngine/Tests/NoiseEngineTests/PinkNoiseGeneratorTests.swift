import Testing
@testable import NoiseEngine

@Suite("PinkNoiseGenerator")
struct PinkNoiseGeneratorTests {

    @Test func shouldProduceSamplesWithinUnitRange() {
        var g = PinkNoiseGenerator()
        for _ in 0..<10_000 {
            let s = g.nextSample()
            #expect(s >= -1.0 && s <= 1.0)
        }
    }

    @Test func shouldHaveMeanNearZeroOverManySamples() {
        var g = PinkNoiseGenerator()
        let n = 100_000
        var sum: Double = 0
        for _ in 0..<n { sum += Double(g.nextSample()) }
        let mean = sum / Double(n)
        #expect(abs(mean) < 0.05)
    }

    @Test func shouldHaveLessHighFrequencyEnergyThanWhite() {
        let n = 50_000
        var pink = PinkNoiseGenerator()
        var pinkPrev = pink.nextSample()
        var pinkDiffSq: Double = 0
        for _ in 0..<n {
            let s = pink.nextSample()
            let d = Double(s - pinkPrev)
            pinkDiffSq += d * d
            pinkPrev = s
        }

        var white = WhiteNoiseGenerator()
        var whitePrev = white.nextSample()
        var whiteDiffSq: Double = 0
        for _ in 0..<n {
            let s = white.nextSample()
            let d = Double(s - whitePrev)
            whiteDiffSq += d * d
            whitePrev = s
        }

        // Pink has 1/f spectrum, so first-difference (high-pass) energy is much
        // smaller than white. Threshold is conservative; in practice ratio is ~5-10x.
        #expect(pinkDiffSq < whiteDiffSq * 0.5)
    }
}
