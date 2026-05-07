import SwiftUI

// Auto-advancing high-contrast B&W card slideshow for newborn visual stimulation.
// Pairs with iOS tummy-time timer; designed for the Apple TV.
struct ContrastSlideshow: View {
    @State private var index: Int = 0
    @State private var task: Task<Void, Never>?
    let advanceInterval: TimeInterval

    init(advanceInterval: TimeInterval = 5) {
        self.advanceInterval = advanceInterval
    }

    var body: some View {
        ZStack {
            ForEach(ContrastPattern.allCases) { pattern in
                ContrastCard(pattern: pattern)
                    .opacity(pattern.id == currentPattern.id ? 1 : 0)
                    .animation(.easeInOut(duration: 0.8), value: index)
            }
        }
        .ignoresSafeArea()
        .onAppear { startCycle() }
        .onDisappear { task?.cancel() }
    }

    private var currentPattern: ContrastPattern {
        let all = ContrastPattern.allCases
        return all[index % all.count]
    }

    private func startCycle() {
        task?.cancel()
        task = Task {
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(advanceInterval))
                guard !Task.isCancelled else { return }
                await MainActor.run { index += 1 }
            }
        }
    }
}
