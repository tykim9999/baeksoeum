import Testing
@testable import LullabyEngine

@Suite("LullabyCatalog")
struct LullabyCatalogTests {

    @Test func lullabiesShouldHaveUniqueIDs() {
        let ids = LullabyCatalog.lullabies.map(\.id)
        #expect(ids.count == Set(ids).count)
    }

    @Test func wombSoundsShouldHaveUniqueIDs() {
        let ids = LullabyCatalog.wombSounds.map(\.id)
        #expect(ids.count == Set(ids).count)
    }

    @Test func lullabiesShouldHaveResourceNames() {
        for l in LullabyCatalog.lullabies {
            #expect(l.resourceName.hasPrefix("lullaby_"))
            #expect(!l.titleKR.isEmpty)
        }
    }

    @Test func wombSoundsShouldHaveResourceNames() {
        for w in LullabyCatalog.wombSounds {
            #expect(w.resourceName.hasPrefix("womb_"))
            #expect(!w.titleKR.isEmpty)
        }
    }
}
