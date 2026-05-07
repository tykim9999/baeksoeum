import SwiftUI
import NoiseEngine
import LullabyEngine

// Maps each audio source to:
//  - a 2-color gradient (primary -> deep) for content-derived background
//  - a one-line evidence-based benefit (Korean), shown as ghost text under hero
//  - an SF Symbol icon for the hero card
struct SoundPalette: Sendable {
    let primary: Color
    let deep: Color
    let benefit: String
    let icon: String
}

enum SoundPaletteResolver {

    static let placeholder = SoundPalette(
        primary: Color(hex: 0x274D7B),
        deep: Color(hex: 0x0A1A34),
        benefit: "잠들 준비를 시작해보세요",
        icon: "moon.stars.fill"
    )

    static func resolve(_ source: AudioCoordinator.Source) -> SoundPalette {
        switch source {
        case .none:
            return placeholder

        case .noise(let color):
            switch color {
            case .white:
                return SoundPalette(
                    primary: Color(hex: 0x4A5872),
                    deep:    Color(hex: 0x101F38),
                    benefit: "선명한 주파수로 두뇌 각성을 차단합니다",
                    icon:    "circle.dashed"
                )
            case .pink:
                return SoundPalette(
                    primary: Color(hex: 0x8C4F4A),
                    deep:    Color(hex: 0x1F1428),
                    benefit: "자연스러운 1/f 소리, 깊은 잠을 유도합니다",
                    icon:    "circle.hexagongrid.fill"
                )
            case .brown:
                return SoundPalette(
                    primary: Color(hex: 0x735439),
                    deep:    Color(hex: 0x1A1208),
                    benefit: "낮은 주파수가 심박을 안정시킵니다",
                    icon:    "waveform.path"
                )
            }

        case .lullaby(let track):
            switch track.id {
            case "brahms":
                return SoundPalette(
                    primary: Color(hex: 0x4A6A8C),
                    deep:    Color(hex: 0x0F1A2E),
                    benefit: "고전 자장가, 정서 안정을 돕습니다 (RCT 입증)",
                    icon:    "music.note"
                )
            case "wiegenlied":
                return SoundPalette(
                    primary: Color(hex: 0x6E5896),
                    deep:    Color(hex: 0x1A1230),
                    benefit: "모차르트 자장가, 깊은 평온을 줍니다",
                    icon:    "music.note"
                )
            case "twinkle":
                return SoundPalette(
                    primary: Color(hex: 0x4A8C8C),
                    deep:    Color(hex: 0x0F2E2E),
                    benefit: "친숙한 멜로디, 익숙함이 안심을 줍니다",
                    icon:    "star.fill"
                )
            case "jajangga":
                return SoundPalette(
                    primary: Color(hex: 0x96825C),
                    deep:    Color(hex: 0x2E2A1A),
                    benefit: "한국 전통 자장가, 모국어 리듬을 들려주세요",
                    icon:    "music.note"
                )
            case "seomjip":
                return SoundPalette(
                    primary: Color(hex: 0x5C8C7E),
                    deep:    Color(hex: 0x12241F),
                    benefit: "섬집아기, 따뜻한 정서를 전합니다",
                    icon:    "music.note"
                )
            default:
                return placeholder
            }

        case .womb(let track):
            switch track.id {
            case "heartbeat":
                return SoundPalette(
                    primary: Color(hex: 0x96424A),
                    deep:    Color(hex: 0x2A0E12),
                    benefit: "엄마의 심장 박동, 자궁 환경을 재현합니다",
                    icon:    "heart.fill"
                )
            case "flow":
                return SoundPalette(
                    primary: Color(hex: 0x4A7A8C),
                    deep:    Color(hex: 0x0E1F2E),
                    benefit: "양수 흐름, 신생아의 가장 익숙한 소리",
                    icon:    "drop.fill"
                )
            default:
                return placeholder
            }
        }
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
