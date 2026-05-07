import SwiftUI

// Shared visual components consumed across feature views.

struct DynamicGradientBackground: View {
    let palette: SoundPalette

    var body: some View {
        LinearGradient(
            stops: [
                .init(color: palette.primary.opacity(0.55), location: 0),
                .init(color: palette.deep, location: 0.6),
                .init(color: Color(.sRGB, red: 0.04, green: 0.10, blue: 0.20, opacity: 1), location: 1),
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        .animation(.easeInOut(duration: 1.2), value: palette.primary)
        .animation(.easeInOut(duration: 1.2), value: palette.deep)
    }
}

struct GlassPanelBackground: View {
    var cornerRadius: CGFloat = Theme.Radius.lg

    var body: some View {
        let shape = RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
        ZStack {
            shape.fill(.ultraThinMaterial)
            shape.stroke(Color.white.opacity(0.12), lineWidth: 1)
        }
    }
}

struct GlassCardBackground: View {
    let isSelected: Bool

    var body: some View {
        let shape = RoundedRectangle(cornerRadius: Theme.Radius.lg, style: .continuous)
        ZStack {
            shape.fill(.ultraThinMaterial)
            if isSelected {
                shape.fill(Theme.Palette.primary.opacity(0.22))
            }
            shape.stroke(
                isSelected ? Theme.Palette.primary : Color.white.opacity(0.15),
                lineWidth: isSelected ? 3 : 1
            )
        }
    }
}

struct GlassCapsuleBackground: View {
    let isSelected: Bool

    var body: some View {
        let shape = Capsule()
        ZStack {
            shape.fill(.ultraThinMaterial)
            if isSelected {
                shape.fill(Theme.Palette.primary.opacity(0.22))
            }
            shape.stroke(
                isSelected ? Theme.Palette.primary : Color.white.opacity(0.15),
                lineWidth: isSelected ? 3 : 1
            )
        }
    }
}
