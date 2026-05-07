import SwiftUI

// Lullaby Navy app icon. Single composition; system applies the rounded mask.
//
// Layout:
//   - Background: navy radial gradient (deep at edges, slightly lifted center)
//   - Crescent moon: peach, off-center upper-left (classic Hatch placement)
//   - Three small stars: amber + cream, scattered upper-right
//
// Tokens (mirror of App/Sources/Theme.swift; kept inline so this tool is standalone):
//   background  #0A1A34
//   surface     #13294B
//   primary     #F4B27A   (peach)
//   amber       #F2C46B
//   foreground  #FAF8F4   (cream)
struct AppIconView: View {
    let size: CGFloat

    var body: some View {
        ZStack {
            // Background gradient: navy with subtle warm lift toward center
            RadialGradient(
                stops: [
                    .init(color: Color(hex: 0x1A2A48), location: 0),
                    .init(color: Color(hex: 0x0A1A34), location: 0.7),
                    .init(color: Color(hex: 0x06122A), location: 1.0),
                ],
                center: UnitPoint(x: 0.5, y: 0.55),
                startRadius: 0,
                endRadius: size * 0.7
            )

            // Stars (drawn behind moon so moon overlaps them slightly)
            star(at: .init(x: 0.78, y: 0.22), size: 0.045, color: Color(hex: 0xFAF8F4), opacity: 0.95)
            star(at: .init(x: 0.86, y: 0.36), size: 0.030, color: Color(hex: 0xF2C46B), opacity: 0.9)
            star(at: .init(x: 0.69, y: 0.32), size: 0.022, color: Color(hex: 0xFAF8F4), opacity: 0.7)
            star(at: .init(x: 0.92, y: 0.22), size: 0.018, color: Color(hex: 0xF2C46B), opacity: 0.85)

            // Crescent moon
            CrescentMoon()
                .fill(
                    LinearGradient(
                        colors: [Color(hex: 0xF8C9A0), Color(hex: 0xD6855A)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: Color(hex: 0xF4B27A).opacity(0.45), radius: size * 0.05)
                .frame(width: size * 0.55, height: size * 0.55)
                .offset(x: -size * 0.06, y: size * 0.06)
        }
        .frame(width: size, height: size)
        .background(Color(hex: 0x0A1A34))
    }

    @ViewBuilder
    private func star(at point: UnitPoint, size starSize: Double, color: Color, opacity: Double) -> some View {
        StarShape()
            .fill(color)
            .opacity(opacity)
            .shadow(color: color.opacity(0.6), radius: size * 0.02)
            .frame(width: size * starSize, height: size * starSize)
            .position(x: size * point.x, y: size * point.y)
    }
}

// Crescent: full circle minus an offset overlay circle.
struct CrescentMoon: Shape {
    func path(in rect: CGRect) -> Path {
        let r = min(rect.width, rect.height) / 2
        let center = CGPoint(x: rect.midX, y: rect.midY)
        var path = Path()
        path.addArc(center: center, radius: r, startAngle: .zero, endAngle: .degrees(360), clockwise: true)
        // Carve out the inner circle, offset to upper-right to leave a left-leaning crescent
        let innerRadius = r * 0.92
        let innerCenter = CGPoint(x: center.x + r * 0.32, y: center.y - r * 0.10)
        var inner = Path()
        inner.addArc(center: innerCenter, radius: innerRadius, startAngle: .zero, endAngle: .degrees(360), clockwise: true)
        return path.subtracting(inner)
    }
}

// 4-point star (sharp, simple). Two overlapping triangles + center cross.
struct StarShape: Shape {
    func path(in rect: CGRect) -> Path {
        let cx = rect.midX
        let cy = rect.midY
        let outer = min(rect.width, rect.height) / 2
        let inner = outer * 0.36
        var path = Path()
        let count = 4
        for i in 0..<(count * 2) {
            let radius = i.isMultiple(of: 2) ? outer : inner
            let angle = (Double(i) * .pi / Double(count)) - .pi / 2
            let x = cx + CGFloat(cos(angle)) * radius
            let y = cy + CGFloat(sin(angle)) * radius
            if i == 0 { path.move(to: .init(x: x, y: y)) }
            else { path.addLine(to: .init(x: x, y: y)) }
        }
        path.closeSubpath()
        return path
    }
}

extension Color {
    init(hex: UInt32) {
        self.init(
            .sRGB,
            red:   Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >>  8) & 0xFF) / 255,
            blue:  Double( hex        & 0xFF) / 255,
            opacity: 1
        )
    }
}
