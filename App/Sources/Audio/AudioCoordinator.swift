import Foundation
import SwiftData
import NoiseEngine
import LullabyEngine

@Observable
@MainActor
final class AudioCoordinator {

    enum Source: Equatable {
        case none
        case noise(NoiseColor)
        case lullaby(Lullaby)
        case womb(Lullaby)
    }

    private(set) var current: Source = .none
    private(set) var isPlaying: Bool = false
    var volume: Float = 0.7 {
        didSet {
            applyVolume()
            if !isLoading { savePreferences() }
        }
    }

    private let noisePlayer = NoisePlayer()
    private let lullabyPlayer = LullabyPlayer()
    private var modelContext: ModelContext?
    private var prefs: SoundPreferences?
    private var isLoading: Bool = false

    init() {}

    func attach(modelContext: ModelContext) {
        self.modelContext = modelContext
        loadPreferences()
    }

    private func loadPreferences() {
        guard let modelContext else { return }
        let descriptor = FetchDescriptor<SoundPreferences>()
        let p: SoundPreferences
        if let existing = try? modelContext.fetch(descriptor).first {
            p = existing
        } else {
            p = SoundPreferences()
            modelContext.insert(p)
            try? modelContext.save()
        }
        self.prefs = p
        applyPreferences(p)
    }

    private func applyPreferences(_ p: SoundPreferences) {
        isLoading = true
        defer { isLoading = false }

        switch p.sourceKind {
        case .noise:
            if let id = p.sourceIDRaw, let color = NoiseColor(rawValue: id) {
                current = .noise(color)
                noisePlayer.setColor(color)
            } else {
                current = .noise(.pink)
                noisePlayer.setColor(.pink)
            }
        case .lullaby:
            if let id = p.sourceIDRaw,
               let track = LullabyCatalog.lullabies.first(where: { $0.id == id }) {
                current = .lullaby(track)
            }
        case .womb:
            if let id = p.sourceIDRaw,
               let track = LullabyCatalog.wombSounds.first(where: { $0.id == id }) {
                current = .womb(track)
            }
        case .none:
            current = .none
        }
        volume = p.volume
        applyVolume()
    }

    private func savePreferences() {
        guard let prefs else { return }
        prefs.volume = volume
        switch current {
        case .noise(let c):
            prefs.sourceKind = .noise
            prefs.sourceIDRaw = c.rawValue
        case .lullaby(let l):
            prefs.sourceKind = .lullaby
            prefs.sourceIDRaw = l.id
        case .womb(let l):
            prefs.sourceKind = .womb
            prefs.sourceIDRaw = l.id
        case .none:
            prefs.sourceKind = .none
            prefs.sourceIDRaw = nil
        }
        try? modelContext?.save()
    }

    func select(_ source: Source) {
        switch source {
        case .none:
            stop()
        case .noise(let color):
            stopLullaby()
            noisePlayer.setColor(color)
            current = source
            if isPlaying {
                try? noisePlayer.play()
                applyVolume()
            }
        case .lullaby(let track), .womb(let track):
            noisePlayer.pause()
            current = source
            if isPlaying {
                playCurrentLullaby(track)
            }
        }
        savePreferences()
    }

    func togglePlay() {
        if isPlaying {
            pause()
        } else {
            play()
        }
    }

    func play() {
        switch current {
        case .none:
            return
        case .noise:
            do {
                try noisePlayer.play()
                applyVolume()
                isPlaying = true
            } catch {
                print("noise play failed: \(error)")
            }
        case .lullaby(let track), .womb(let track):
            playCurrentLullaby(track)
            isPlaying = true
        }
    }

    func pause() {
        noisePlayer.pause()
        lullabyPlayer.pause()
        isPlaying = false
    }

    func stop() {
        noisePlayer.pause()
        lullabyPlayer.stop()
        current = .none
        isPlaying = false
    }

    func fadeOut(duration: TimeInterval, onComplete: (@Sendable () -> Void)? = nil) {
        switch current {
        case .none:
            onComplete?()
        case .noise:
            noisePlayer.fadeOut(duration: duration) { [weak self] in
                Task { @MainActor [weak self] in
                    self?.isPlaying = false
                    onComplete?()
                }
            }
        case .lullaby, .womb:
            lullabyPlayer.fadeOut(duration: duration) { [weak self] in
                Task { @MainActor [weak self] in
                    self?.isPlaying = false
                    onComplete?()
                }
            }
        }
    }

    private func playCurrentLullaby(_ track: Lullaby) {
        do {
            try lullabyPlayer.play(lullaby: track, in: .main, volume: volume, loops: true)
        } catch {
            print("lullaby play failed: \(error)")
        }
    }

    private func stopLullaby() {
        lullabyPlayer.stop()
    }

    private func applyVolume() {
        let v = max(0, min(1, volume))
        noisePlayer.setVolume(v)
        lullabyPlayer.setVolume(v)
    }
}
