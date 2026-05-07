import SwiftUI
import SwiftData

@main
struct BaekSoeumApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(AppModelContainer.makeShared())
    }
}
