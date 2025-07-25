import Foundation
import SwiftData

@Model
final class Favorite: Identifiable {
    // must be var so the macro can hook it up
    var id: UUID = UUID()
    
    // just store the Product’s id—you can look up the Product later
    var productID: UUID

    init(productID: UUID) {
        self.productID = productID
    }
}
