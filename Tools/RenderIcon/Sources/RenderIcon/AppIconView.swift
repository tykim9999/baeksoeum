import SwiftUI

// Lullaby Navy app icon. Renders the iOS square icon, the tvOS landscape
// 3-layer icon (back / middle / front), and the Top Shelf hero.
//
// Tokens (mirror of App/Sources/Theme.swift; inline so this tool is standalone):
//   background  #0A1A34
//   surface     #13294B
//   primary     #F4B27A   (peach)
//   amber       #F2C46B
//   foreground  #FAF8F4   (cream)

enum IconLayer {
    case full           // single composition (iOS)
    case back           // gradient ground only (tvOS layer)
    case middle         // crescent moon, transparent bg (tvOS layer)
    case front          // stars, transparent bg (tvOS layer)
}

enum IconShape {
    case square         // iOS — 1:1
    case landscape      // tvOS app icon — 5:3 (400x240, 1280x768)
}

struct AppIconView: View {
    let width: CGFloat
    let height: CGFloat
    let layer: IconLayer
    let shape: IconShape

    init(width: CGFloat, height: CGFloat, layer: IconLayer = .full, shape: IconShape = .square) {
        self.width = width
        self.height = height
        self.layer = layer
        self.shape = shape
    }

    var body: some View {
        ZStack {
            if drawBack {
                background
            }
            if drawStars {
                stars
            }
            if drawMoon {
                moon
            }
        }
        .frame(width: width, height: height)
        .background(drawBack ? Color(hex: 0x0A1A34) : Color.clear)
    }

    private var drawBack: Bool   { layer == .full || layer == .back }
    private var drawMoon: Bool   { layer == .full || layer == .middle }
    private var drawStars: Bool  { layer == .full || layer == .front }

    // MARK: Background gradient

    private var background: some View {
        RadialGradient(
            stops: [
                .init(color: Color(hex: 0x1A2A48), location: 0),
                .init(color: Color(hex: 0x0A1A34), location: 0.7),
                .init(color: Color(hex: 0x06122A), location: 1.0),
            ],
            center: gradientCenter,
            startRadius: 0,
            endRadius: max(width, height) * 0.7
        )
    }

    private var gradientCenter: UnitPoint {
        switch shape {
        case .square:    return .init(x: 0.5, y: 0.55)
        case .landscape: return .init(x: 0.42, y: 0.55)
        }
    }

    // MARK: Stars

    private var stars: some View {
        ZStack {
            ForEach(0..<starSpecs.count, id: \.self) { i in
                let s = starSpecs[i]
                StarShape()
                    .fill(s.color)
                    .opacity(s.opacity)
                    .shadow(color: s.color.opacity(0.6), radius: s.size * 0.5)
                    .frame(width: s.size, height: s.size)
                    .position(x: width * s.x, y: height * s.y)
            }
        }
    }

    private var starSpecs: [StarSpec] {
        switch shape {
        case .square:
            return [
                .init(x: 0.78, y: 0.22, size: width * 0.045, color: Color(hex: 0xFAF8F4), opacity: 0.95),
                .init(x: 0.86, y: 0.36, size: width * 0.030, color: Color(hex: 0xF2C46B), opacity: 0.90),
                .init(x: 0.69, y: 0.32, size: width * 0.022, color: Color(hex: 0xFAF8F4), opacity: 0.70),
                .init(x: 0.92, y: 0.22, size: width * 0.018, color: Color(hex: 0xF2C46B), opacity: 0.85),
            ]
        case .landscape:
            return [
                .init(x: 0.72, y: 0.30, size: width * 0.048, color: Color(hex: 0xFAF8F4), opacity: 0.95),
                .init(x: 0.82, y: 0.50, size: width * 0.030, color: Color(hex: 0xF2C46B), opacity: 0.90),
                .init(x: 0.65, y: 0.55, size: width * 0.022, color: Color(hex: 0xFAF8F4), opacity: 0.70),
                .init(x: 0.88, y: 0.30, size: width * 0.020, color: Color(hex: 0xF2C46B), opacity: 0.85),
            ]
        }
    }

    // MARK: Moon

    private var moon: some View {
        let moonSize = shape == .square ? width * 0.55 : height * 0.65
        let offsetX: CGFloat = shape == .square ? -width * 0.06 : -width * 0.10
        let offsetY: CGFloat = shape == .square ? height * 0.06 : height * 0.05

        return CrescentMoon()
            .fill(
                LinearGradient(
                    colors: [Color(hex: 0xF8C9A0), Color(hex: 0xD6855A)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .shadow(color: Color(hex: 0xF4B27A).opacity(0.45), radius: moonSize * 0.10)
            .frame(width: moonSize, height: moonSize)
            .offset(x: offsetX, y: offsetY)
    }
}

// 1024x1024 (square) convenience.
extension AppIconView {
    init(size: CGFloat) {
        self.init(width: size, height: size, layer: .full, shape: .square)
    }
}

// MARK: - Top Shelf hero (1920x720, navy ground + icon + wordmark)

struct TopShelfView: View {
    let width: CGFloat
    let height: CGFloat

    var body: some View {
        ZStack {
            // Navy gradient ground with warm lift
            LinearGradient(
                colors: [
                    Color(hex: 0x1A2A48),
                    Color(hex: 0x0A1A34),
                    Color(hex: 0x06122A),
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            HStack(spacing: width * 0.04) {
                // Compact icon (just moon + stars over transparent — they read on bg)
                ZStack {
                    StarShape()
                        .fill(Color(hex: 0xFAF8F4)).opacity(0.85)
                        .shadow(color: Color(hex: 0xFAF8F4).opacity(0.6), radius: 8)
                        .frame(width: height * 0.06, height: height * 0.06)
                        .offset(x: height * 0.18, y: -height * 0.20)

                    StarShape()
                        .fill(Color(hex: 0xF2C46B)).opacity(0.85)
                        .frame(width: height * 0.04, height: height * 0.04)
                        .offset(x: height * 0.22, y: -height * 0.05)

                    CrescentMoon()
                        .fill(
                            LinearGradient(
                                colors: [Color(hex: 0xF8C9A0), Color(hex: 0xD6855A)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .shadow(color: Color(hex: 0xF4B27A).opacity(0.45), radius: 30)
                        .frame(width: height * 0.55, height: height * 0.55)
                }
                .frame(width: height * 0.7, height: height * 0.7)

                VStack(alignment: .leading, spacing: height * 0.04) {
                    Text("달빛자장")
                        .font(.system(size: height * 0.18, weight: .semibold, design: .default))
                        .foregroundStyle(Color(hex: 0xFAF8F4))
                    Text("잠, 자장가, 그리고 따뜻한 빛")
                        .font(.system(size: height * 0.06, weight: .regular, design: .default))
                        .foregroundStyle(Color(hex: 0xFAF8F4).opacity(0.65))
                }
            }
        }
        .frame(width: width, height: height)
        .background(Color(hex: 0x0A1A34))
    }
}

// MARK: - Shapes

struct StarSpec {
    let x: Double
    let y: Double
    let size: CGFloat
    let color: Color
    let opacity: Double
}

struct CrescentMoon: Shape {
    func path(in rect: CGRect) -> Path {
        let r = min(rect.width, rect.height) / 2
        let center = CGPoint(x: rect.midX, y: rect.midY)
        var path = Path()
        path.addArc(center: center, radius: r, startAngle: .zero, endAngle: .degrees(360), clockwise: true)
        let innerRadius = r * 0.92
        let innerCenter = CGPoint(x: center.x + r * 0.32, y: center.y - r * 0.10)
        var inner = Path()
        inner.addArc(center: innerCenter, radius: innerRadius, startAngle: .zero, endAngle: .degrees(360), clockwise: true)
        return path.subtracting(inner)
    }
}

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
