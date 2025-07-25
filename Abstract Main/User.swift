import Foundation
import SwiftData

@Model
final class User: Identifiable {
    var id: UUID = UUID()
    var email: String
    var name: String
    var isCreator: Bool

    init(email: String, name: String, isCreator: Bool = false) {
        self.email = email
        self.name = name
        self.isCreator = isCreator
    }
}
