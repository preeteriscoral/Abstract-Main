import Foundation     // ← for UUID
import SwiftData

@Model
final class Product: Identifiable {
    // must be var so the macro can hook it up
    var id: UUID = UUID()
    
    var name: String
    // rename to avoid clashing with the `description` macro
    var productDescription: String
    var price: Double
    var imageURL: String?

    init(
        name: String,
        productDescription: String,
        price: Double,
        imageURL: String? = nil
    ) {
        self.name = name
        self.productDescription = productDescription
        self.price = price
        self.imageURL = imageURL
    }
}
