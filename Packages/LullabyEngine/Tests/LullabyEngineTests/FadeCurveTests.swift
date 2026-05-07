import Testing
@testable import LullabyEngine

@Suite("FadeCurve")
struct FadeCurveTests {

    @Test func shouldReturnStartVolumeBeforeFadeStarts() {
        let curve = FadeCurve(startVolume: 0.8, duration: 30)
        #expect(curve.volume(at: 0) == 0.8)
        #expect(curve.volume(at: -5) == 0.8)
    }

    @Test func shouldReturnZeroAfterDuration() {
        let curve = FadeCurve(startVolume: 0.8, duration: 30)
        #expect(curve.volume(at: 30) == 0)
        #expect(curve.volume(at: 60) == 0)
    }

    @Test func shouldDecreaseMonotonically() {
        let curve = FadeCurve(startVolume: 1.0, duration: 10)
        var previous: Float = 1.0
        for t in stride(from: 0.0, through: 10.0, by: 0.5) {
            let v = curve.volume(at: t)
            #expect(v <= previous, "volume should not increase between samples")
            previous = v
        }
    }

    @Test func shouldHaveLinearMidpoint() {
        let curve = FadeCurve(startVolume: 1.0, duration: 10)
        // At halfway, linear fade puts volume at half.
        let midpoint = curve.volume(at: 5)
        #expect(abs(midpoint - 0.5) < 0.001)
    }
}
