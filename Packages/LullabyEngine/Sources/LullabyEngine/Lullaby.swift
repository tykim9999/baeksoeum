import Foundation

public struct Lullaby: Sendable, Identifiable, Hashable {
    public let id: String
    public let titleKR: String
    public let attribution: String?
    public let resourceName: String
    public let fileExtension: String

    public init(
        id: String,
        titleKR: String,
        attribution: String? = nil,
        resourceName: String,
        fileExtension: String = "mp3"
    ) {
        self.id = id
        self.titleKR = titleKR
        self.attribution = attribution
        self.resourceName = resourceName
        self.fileExtension = fileExtension
    }

    /// Look in the "Sounds" subdirectory first (xcodegen `type: folder` ships
    /// resources at `<App>.app/Sounds/`); fall back to the bundle root for
    /// flat-resource layouts (xcodegen `type: group`).
    public func url(in bundle: Bundle) -> URL? {
        bundle.url(forResource: resourceName, withExtension: fileExtension, subdirectory: "Sounds")
            ?? bundle.url(forResource: resourceName, withExtension: fileExtension)
    }
}
