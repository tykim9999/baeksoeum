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

    public func url(in bundle: Bundle) -> URL? {
        bundle.url(forResource: resourceName, withExtension: fileExtension)
    }
}
