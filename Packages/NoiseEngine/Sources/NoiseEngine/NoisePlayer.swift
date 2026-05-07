import AVFoundation
import Foundation

public final class NoisePlayer: @unchecked Sendable {
    private let engine = AVAudioEngine()
    private var sourceNode: AVAudioSourceNode!
    private var fadeTimer: Timer?

    private var white = WhiteNoiseGenerator()
    private var pink = PinkNoiseGenerator()
    private var brown = BrownNoiseGenerator()
    private var color: NoiseColor

    public init(color: NoiseColor = .pink) {
        self.color = color
        let format = AVAudioFormat(
            standardFormatWithSampleRate: 44_100,
            channels: 1
        )!
        sourceNode = AVAudioSourceNode(format: format) { [weak self] _, _, frameCount, audioBufferList in
            guard let self else { return noErr }
            let abl = UnsafeMutableAudioBufferListPointer(audioBufferList)
            let frames = Int(frameCount)
            for frame in 0..<frames {
                let sample: Float
                switch self.color {
                case .white: sample = self.white.nextSample()
                case .pink: sample = self.pink.nextSample()
                case .brown: sample = self.brown.nextSample()
                }
                for buffer in abl {
                    let buf = UnsafeMutableBufferPointer<Float>(buffer)
                    buf[frame] = sample
                }
            }
            return noErr
        }
        engine.attach(sourceNode)
        engine.connect(sourceNode, to: engine.mainMixerNode, format: format)
    }

    public func play() throws {
        try configureSession()
        cancelFade()
        if !engine.isRunning {
            try engine.start()
        }
    }

    public func pause() {
        cancelFade()
        engine.pause()
    }

    public func setColor(_ color: NoiseColor) {
        self.color = color
    }

    public func setVolume(_ volume: Float) {
        engine.mainMixerNode.outputVolume = max(0, min(1, volume))
    }

    public func fadeOut(duration: TimeInterval, onComplete: (@Sendable () -> Void)? = nil) {
        cancelFade()
        let startVolume = engine.mainMixerNode.outputVolume
        let startTime = Date()
        let timer = Timer(timeInterval: 0.02, repeats: true) { [weak self] timer in
            guard let self else {
                timer.invalidate()
                onComplete?()
                return
            }
            let elapsed = Date().timeIntervalSince(startTime)
            if elapsed >= duration {
                timer.invalidate()
                self.engine.mainMixerNode.outputVolume = 0
                self.engine.pause()
                onComplete?()
            } else {
                let progress = Float(elapsed / duration)
                self.engine.mainMixerNode.outputVolume = startVolume * (1 - progress)
            }
        }
        RunLoop.main.add(timer, forMode: .common)
        fadeTimer = timer
    }

    private func cancelFade() {
        fadeTimer?.invalidate()
        fadeTimer = nil
    }

    private func configureSession() throws {
        #if os(iOS) || os(tvOS)
        let session = AVAudioSession.sharedInstance()
        try session.setCategory(.playback, mode: .default, options: [])
        try session.setActive(true)
        #endif
    }
}
