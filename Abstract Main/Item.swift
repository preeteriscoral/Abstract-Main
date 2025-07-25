import Foundation
import SwiftData  // Adjust based on your persistence choice

@Model
final class Item: Identifiable {
    var id: UUID = UUID()
    var timestamp: Date

    init(timestamp: Date = Date()) {
        self.timestamp = timestamp
    }
}
