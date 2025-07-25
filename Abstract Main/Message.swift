import Foundation
import SwiftData  // Ensure you're targeting iOS 17 / macOS 14+ with Xcode 15+

@Model
final class Message: Identifiable {
    var id: UUID = UUID()
    var text: String
    var sender: String
    var timestamp: Date

    init(text: String, sender: String, timestamp: Date = Date()) {
        self.text = text
        self.sender = sender
        self.timestamp = timestamp
    }
}
