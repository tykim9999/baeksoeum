import AVFoundation
import Foundation

public final class LullabyPlayer: @unchecked Sendable {
    private var player: AVAudioPlayer?
    private var fadeTimer: Timer?

    public init() {}

    public func play(lullaby: Lullaby, in bundle: Bundle, volume: Float = 0.7, loops: Bool = true) throws {
        guard let url = lullaby.url(in: bundle) else {
            throw LullabyError.resourceNotFound(lullaby.resourceName)
        }
        let p = try AVAudioPlayer(contentsOf: url)
        p.numberOfLoops = loops ? -1 : 0
        p.volume = max(0, min(1, volume))
        p.prepareToPlay()
        p.play()
        cancelFade()
        self.player = p
    }

    public func pause() {
        player?.pause()
    }

    public func resume() {
        player?.play()
    }

    public func stop() {
        cancelFade()
        player?.stop()
        player = nil
    }

    public var isPlaying: Bool {
        player?.isPlaying ?? false
    }

    public var volume: Float {
        player?.volume ?? 0
    }

    public func setVolume(_ value: Float) {
        player?.volume = max(0, min(1, value))
    }

    public func fadeOut(duration: TimeInterval, onComplete: (@Sendable () -> Void)? = nil) {
        guard let player else { onComplete?(); return }
        cancelFade()
        let curve = FadeCurve(startVolume: player.volume, duration: duration)
        let startTime = Date()
        let timer = Timer(timeInterval: 0.02, repeats: true) { [weak self] timer in
            guard let self, let p = self.player else {
                timer.invalidate()
                onComplete?()
                return
            }
            let elapsed = Date().timeIntervalSince(startTime)
            p.volume = curve.volume(at: elapsed)
            if elapsed >= duration {
                timer.invalidate()
                p.stop()
                self.player = nil
                onComplete?()
            }
        }
        RunLoop.main.add(timer, forMode: .common)
        fadeTimer = timer
    }

    private func cancelFade() {
        fadeTimer?.invalidate()
        fadeTimer = nil
    }
}

public enum LullabyError: Error, Equatable {
    case resourceNotFound(String)
}
