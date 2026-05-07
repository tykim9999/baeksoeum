import Foundation
import SwiftData

@Model
final class Baby {
    @Attribute(.unique) var id: UUID
    var name: String
    var birthDate: Date

    init(id: UUID = UUID(), name: String, birthDate: Date) {
        self.id = id
        self.name = name
        self.birthDate = birthDate
    }

    var ageInDays: Int {
        Calendar.current.dateComponents([.day], from: birthDate, to: .now).day ?? 0
    }

    var ageInMonths: Int {
        Calendar.current.dateComponents([.month], from: birthDate, to: .now).month ?? 0
    }
}
