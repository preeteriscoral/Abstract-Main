import Foundation
import SwiftData

@Model
final class Creator: Identifiable {
    // 1) Explicitly call the initializer, not “.init()”
    @Attribute(.unique) var id: UUID = UUID()
    
    var name: String
    var bio: String
    
    // 2) Give your optional a literal default so the macro can see it
    var avatarURL: String? = nil

    init(
        name: String,
        bio: String,
        avatarURL: String? = nil
    ) {
        self.name = name
        self.bio = bio
        self.avatarURL = avatarURL
    }
}

