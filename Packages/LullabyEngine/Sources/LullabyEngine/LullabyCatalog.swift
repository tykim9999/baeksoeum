import Foundation

// Catalog of bundled lullabies and womb-sound tracks.
// Resource names must match files placed in App/Resources/Sounds/.
// All sources are CC0 (no-attribution-required) from Pixabay or public domain.
public enum LullabyCatalog {

    public static let lullabies: [Lullaby] = [
        Lullaby(id: "brahms",     titleKR: "브람스 자장가",   resourceName: "lullaby_brahms"),
        Lullaby(id: "wiegenlied", titleKR: "모차르트 자장가", resourceName: "lullaby_wiegenlied"),
        Lullaby(id: "twinkle",    titleKR: "반짝반짝 작은별", resourceName: "lullaby_twinkle"),
        Lullaby(id: "jajangga",   titleKR: "한국 자장가",     resourceName: "lullaby_jajangga"),
        Lullaby(id: "seomjip",    titleKR: "섬집아기",        resourceName: "lullaby_seomjip"),
    ]

    public static let wombSounds: [Lullaby] = [
        Lullaby(id: "heartbeat", titleKR: "엄마 심장 소리", resourceName: "womb_heartbeat"),
        Lullaby(id: "flow",      titleKR: "양수 소리",      resourceName: "womb_flow"),
    ]
}
