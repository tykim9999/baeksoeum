import Foundation
import SwiftData

enum AppModelContainer {

    static let schema = Schema([
        Baby.self,
        SleepEvent.self,
        BedtimeRoutine.self,
        SoundPreferences.self,
    ])

    /// On-device only. To enable iCloud sync, follow CLOUDSYNC.md and change
    /// the cloudKitDatabase argument to:
    ///     .private("iCloud.com.tykim.baeksoeum.BaekSoeum")
    @MainActor
    static func makeShared() -> ModelContainer {
        let config = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false,
            cloudKitDatabase: .none
        )
        do {
            return try ModelContainer(for: schema, configurations: [config])
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }
}
