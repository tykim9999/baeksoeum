import Testing
@testable import NoiseEngine

@Suite("WhiteNoiseGenerator")
struct WhiteNoiseGeneratorTests {

    @Test func shouldProduceSamplesWithinUnitRange() {
        var generator = WhiteNoiseGenerator()
        for _ in 0..<10_000 {
            let sample = generator.nextSample()
            #expect(sample >= -1.0 && sample <= 1.0)
        }
    }

    @Test func shouldHaveMeanNearZeroOverManySamples() {
        var generator = WhiteNoiseGenerator()
        let n = 100_000
        var sum: Double = 0
        for _ in 0..<n { sum += Double(generator.nextSample()) }
        let mean = sum / Double(n)
        #expect(abs(mean) < 0.02)
    }

    @Test func shouldProduceVaryingSamples() {
        var generator = WhiteNoiseGenerator()
        var seen = Set<Float>()
        for _ in 0..<1_000 { seen.insert(generator.nextSample()) }
        #expect(seen.count > 900)
    }
}
