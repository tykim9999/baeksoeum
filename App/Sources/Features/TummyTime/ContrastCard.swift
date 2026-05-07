import SwiftUI

// High-contrast B&W patterns for newborn visual stimulation (0-3 months).
//
// Evidence: newborn contrast sensitivity is ~58x weaker than adults at 2 months
// (PMC6016435). Pairing high-contrast cards with supervised tummy time aligns
// with AAP gross-motor + visual development guidance (AAP Pediatrics 2020).
// We don't claim cards "accelerate" development — only that the combination
// is harmless and tracks the recommended motor practice.
//
// Pure procedural SwiftUI: no bundled PNGs, infinitely scalable.
enum ContrastPattern: Int, CaseIterable, Identifiable, Sendable {
    case bullseye
    case checkerboard
    case verticalStripes
    case horizontalStripes
    case diagonalChevrons
    case star
    case face
    case concentricSquares
    case grid
    case sunburst

    var id: Int { rawValue }
}

struct ContrastCard: View {
    let pattern: ContrastPattern

    var body: some View {
        GeometryReader { geo in
            let size = min(geo.size.width, geo.size.height)
            ZStack {
                Color.white
                content(size: size)
                    .frame(width: size, height: size)
                    .position(x: geo.size.width / 2, y: geo.size.height / 2)
            }
        }
        .background(Color.white)
    }

    @ViewBuilder
    private func content(size: CGFloat) -> some View {
        switch pattern {
        case .bullseye:           BullseyeShape().fill(Color.black)
        case .checkerboard:       CheckerboardShape(grid: 4).fill(Color.black)
        case .verticalStripes:    StripesShape(count: 6, vertical: true).fill(Color.black)
        case .horizontalStripes:  StripesShape(count: 6, vertical: false).fill(Color.black)
        case .diagonalChevrons:   ChevronsShape(rows: 6).fill(Color.black)
        case .star:               StarBig().fill(Color.black)
        case .face:               SimpleFaceShape().fill(Color.black)
        case .concentricSquares:  ConcentricSquaresShape(rings: 4).fill(Color.black)
        case .grid:               GridShape(divisions: 5).stroke(Color.black, lineWidth: size * 0.025)
        case .sunburst:           SunburstShape(rays: 16).fill(Color.black)
        }
    }
}

// MARK: - Shapes

struct BullseyeShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let maxR = min(rect.width, rect.height) / 2
        // 4 alternating bands; outer = solid, then ring, ring, ring
        let bands = 4
        for i in 0..<bands where i.isMultiple(of: 2) {
            let outer = maxR * (CGFloat(bands - i) / CGFloat(bands))
            let inner = maxR * (CGFloat(bands - i - 1) / CGFloat(bands))
            var ring = Path()
            ring.addArc(center: center, radius: outer, startAngle: .zero, endAngle: .degrees(360), clockwise: true)
            var hole = Path()
            hole.addArc(center: center, radius: inner, startAngle: .zero, endAngle: .degrees(360), clockwise: true)
            path.addPath(ring.subtracting(hole))
        }
        return path
    }
}

struct CheckerboardShape: Shape {
    let grid: Int
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let cell = min(rect.width, rect.height) / CGFloat(grid)
        for r in 0..<grid {
            for c in 0..<grid {
                if (r + c).isMultiple(of: 2) {
                    let x = rect.minX + CGFloat(c) * cell
                    let y = rect.minY + CGFloat(r) * cell
                    path.addRect(CGRect(x: x, y: y, width: cell, height: cell))
                }
            }
        }
        return path
    }
}

struct StripesShape: Shape {
    let count: Int
    let vertical: Bool
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let stripe = (vertical ? rect.width : rect.height) / CGFloat(count * 2)
        for i in 0..<count {
            let pos = CGFloat(i * 2) * stripe
            if vertical {
                path.addRect(CGRect(x: rect.minX + pos, y: rect.minY, width: stripe, height: rect.height))
            } else {
                path.addRect(CGRect(x: rect.minX, y: rect.minY + pos, width: rect.width, height: stripe))
            }
        }
        return path
    }
}

struct ChevronsShape: Shape {
    let rows: Int
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let h = rect.height / CGFloat(rows)
        for r in 0..<rows where r.isMultiple(of: 2) {
            let y = rect.minY + CGFloat(r) * h
            path.move(to: .init(x: rect.minX, y: y))
            path.addLine(to: .init(x: rect.midX, y: y + h * 0.5))
            path.addLine(to: .init(x: rect.maxX, y: y))
            path.addLine(to: .init(x: rect.maxX, y: y + h))
            path.addLine(to: .init(x: rect.midX, y: y + h * 1.5))
            path.addLine(to: .init(x: rect.minX, y: y + h))
            path.closeSubpath()
        }
        return path
    }
}

struct StarBig: Shape {
    func path(in rect: CGRect) -> Path {
        let cx = rect.midX
        let cy = rect.midY
        let outer = min(rect.width, rect.height) / 2 * 0.95
        let inner = outer * 0.42
        var path = Path()
        let count = 5
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

struct SimpleFaceShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let cx = rect.midX
        let cy = rect.midY
        let r = min(rect.width, rect.height) / 2 * 0.85

        // Outer face circle
        var outline = Path()
        outline.addArc(center: .init(x: cx, y: cy), radius: r, startAngle: .zero, endAngle: .degrees(360), clockwise: true)
        var inner = Path()
        inner.addArc(center: .init(x: cx, y: cy), radius: r * 0.85, startAngle: .zero, endAngle: .degrees(360), clockwise: true)
        path.addPath(outline.subtracting(inner))

        // Eyes
        let eyeR = r * 0.10
        path.addArc(center: .init(x: cx - r * 0.32, y: cy - r * 0.18), radius: eyeR, startAngle: .zero, endAngle: .degrees(360), clockwise: true)
        path.addArc(center: .init(x: cx + r * 0.32, y: cy - r * 0.18), radius: eyeR, startAngle: .zero, endAngle: .degrees(360), clockwise: true)

        // Smile (curved arc)
        let smile = Path { p in
            p.addArc(center: .init(x: cx, y: cy + r * 0.05),
                     radius: r * 0.45,
                     startAngle: .degrees(20), endAngle: .degrees(160),
                     clockwise: false)
        }
        path.addPath(smile.strokedPath(.init(lineWidth: r * 0.06, lineCap: .round)))
        return path
    }
}

struct ConcentricSquaresShape: Shape {
    let rings: Int
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let s = min(rect.width, rect.height)
        let center = CGPoint(x: rect.midX, y: rect.midY)
        for i in 0..<rings where i.isMultiple(of: 2) {
            let outerSide = s * (CGFloat(rings - i) / CGFloat(rings))
            let innerSide = s * (CGFloat(rings - i - 1) / CGFloat(rings))
            let outer = CGRect(x: center.x - outerSide / 2, y: center.y - outerSide / 2, width: outerSide, height: outerSide)
            let inner = CGRect(x: center.x - innerSide / 2, y: center.y - innerSide / 2, width: innerSide, height: innerSide)
            var ring = Path()
            ring.addRect(outer)
            var hole = Path()
            hole.addRect(inner)
            path.addPath(ring.subtracting(hole))
        }
        return path
    }
}

struct GridShape: Shape {
    let divisions: Int
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let stepX = rect.width / CGFloat(divisions)
        let stepY = rect.height / CGFloat(divisions)
        for i in 0...divisions {
            let x = rect.minX + CGFloat(i) * stepX
            path.move(to: .init(x: x, y: rect.minY))
            path.addLine(to: .init(x: x, y: rect.maxY))
            let y = rect.minY + CGFloat(i) * stepY
            path.move(to: .init(x: rect.minX, y: y))
            path.addLine(to: .init(x: rect.maxX, y: y))
        }
        return path
    }
}

struct SunburstShape: Shape {
    let rays: Int
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let cx = rect.midX
        let cy = rect.midY
        let r = min(rect.width, rect.height) / 2
        for i in 0..<rays where i.isMultiple(of: 2) {
            let a1 = (Double(i)     * 2 * .pi / Double(rays)) - .pi / 2
            let a2 = (Double(i + 1) * 2 * .pi / Double(rays)) - .pi / 2
            path.move(to: .init(x: cx, y: cy))
            path.addLine(to: .init(x: cx + CGFloat(cos(a1)) * r, y: cy + CGFloat(sin(a1)) * r))
            path.addLine(to: .init(x: cx + CGFloat(cos(a2)) * r, y: cy + CGFloat(sin(a2)) * r))
            path.closeSubpath()
        }
        return path
    }
}
