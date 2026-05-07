import SwiftUI

// Design tokens from DESIGN.md ("Lullaby Navy"). SSOT for the UI.
// Edit DESIGN.md first, mirror here. Do not hand-tune values in Views.
enum Theme {

    enum Palette {
        static let background      = Color(hex: 0x0A1A34)
        static let surface         = Color(hex: 0x13294B)
        static let surfaceElevated = Color(hex: 0x274D7B)
        static let outline         = Color(hex: 0x3A5378)

        static let foreground      = Color(hex: 0xFAF8F4)
        static let foregroundMuted = Color(hex: 0xB8C2D4)
        static let foregroundDim   = Color(hex: 0x738DB2)

        static let primary         = Color(hex: 0xF4B27A)
        static let primarySoft     = Color(hex: 0xF8C9A0)
        static let primaryDeep     = Color(hex: 0xD6855A)
        static let amber           = Color(hex: 0xF2C46B)

        // Noise swatches (baby-safe, not neon)
        static let swatchWhite     = Color(hex: 0xF4F1EA)
        static let swatchPink      = Color(hex: 0xE8A4A4)
        static let swatchBrown     = Color(hex: 0xA87856)

        static let focus           = primary
    }

    enum Spacing {
        static let xxs: CGFloat = 4
        static let xs:  CGFloat = 8
        static let sm:  CGFloat = 16
        static let md:  CGFloat = 24
        static let lg:  CGFloat = 40
        static let xl:  CGFloat = 80
        static let xxl: CGFloat = 120
    }

    enum Radius {
        static let sm:   CGFloat = 8
        static let md:   CGFloat = 16
        static let lg:   CGFloat = 24
        static let xl:   CGFloat = 32
        static let full: CGFloat = 9999
    }

    enum Typography {
        #if os(tvOS)
        static let display = Font.system(size: 96, weight: .semibold, design: .default)
        static let h1      = Font.system(size: 56, weight: .semibold, design: .default)
        static let h2      = Font.system(size: 40, weight: .semibold, design: .default)
        static let body    = Font.system(size: 32, weight: .medium,    design: .default)
        static let caption = Font.system(size: 24, weight: .medium,    design: .default)
        #else
        static let display = Font.system(size: 48, weight: .semibold, design: .default)
        static let h1      = Font.system(size: 34, weight: .semibold, design: .default)
        static let h2      = Font.system(size: 22, weight: .semibold, design: .default)
        static let body    = Font.system(size: 17, weight: .regular,  design: .default)
        static let caption = Font.system(size: 13, weight: .medium,   design: .default)
        #endif
    }

    enum Size {
        #if os(tvOS)
        static let playButton:  CGFloat = 200
        static let swatch:      CGFloat = 140
        static let cardPadding: CGFloat = Spacing.md
        #else
        static let playButton:  CGFloat = 96
        static let swatch:      CGFloat = 64
        static let cardPadding: CGFloat = Spacing.sm
        #endif
    }

    enum Focus {
        #if os(tvOS)
        static let ringWidth:  CGFloat = 8
        static let ringOffset: CGFloat = 8
        #else
        static let ringWidth:  CGFloat = 4
        static let ringOffset: CGFloat = 4
        #endif
        static let scale:      CGFloat = 1.08
    }
}

private extension Color {
    init(hex: UInt32, opacity: Double = 1) {
        self.init(
            .sRGB,
            red:   Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >>  8) & 0xFF) / 255,
            blue:  Double( hex        & 0xFF) / 255,
            opacity: opacity
        )
    }
}
