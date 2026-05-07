import Testing
@testable import NoiseEngine

@Suite("BrownNoiseGenerator")
struct BrownNoiseGeneratorTests {

    @Test func shouldProduceSamplesWithinUnitRange() {
        var g = BrownNoiseGenerator()
        for _ in 0..<10_000 {
            let s = g.nextSample()
            #expect(s >= -1.0 && s <= 1.0)
        }
    }

    @Test func shouldHaveMeanNearZeroOverManySamples() {
        var g = BrownNoiseGenerator()
        let n = 100_000
        var sum: Double = 0
        for _ in 0..<n { sum += Double(g.nextSample()) }
        let mean = sum / Double(n)
        // Brown drifts more than white/pink; tolerance is wider.
        #expect(abs(mean) < 0.2)
    }

    @Test func shouldHaveLessHighFrequencyEnergyThanPink() {
        let n = 50_000

        var brown = BrownNoiseGenerator()
        var bPrev = brown.nextSample()
        var brownDiffSq: Double = 0
        for _ in 0..<n {
            let s = brown.nextSample()
            let d = Double(s - bPrev)
            brownDiffSq += d * d
            bPrev = s
        }

        var pink = PinkNoiseGenerator()
        var pPrev = pink.nextSample()
        var pinkDiffSq: Double = 0
        for _ in 0..<n {
            let s = pink.nextSample()
            let d = Double(s - pPrev)
            pinkDiffSq += d * d
            pPrev = s
        }

        // Brown is 1/f^2 vs pink 1/f, so HF energy is much smaller.
        #expect(brownDiffSq < pinkDiffSq * 0.5)
    }
}
