import SwiftUI
import SwiftData

struct ProductDetailView: View {
    @Environment(\.modelContext) private var modelContext

    // just take the Product reference directly
    let product: Product

    // observe favorites so the count updates live
    @Query private var allFavorites: [Favorite]

    private var favoriteCount: Int {
        allFavorites.filter { $0.productID == product.id }.count
    }

    var body: some View {
        VStack(spacing: 20) {
            Text(product.name)
                .font(.largeTitle)

            Text(product.productDescription)
                .font(.body)

            Text(String(format: "$%.2f", product.price))
                .font(.title2)

            Button("Toggle Favorite") {
                if let existing = allFavorites.first(where: { $0.productID == product.id }) {
                    modelContext.delete(existing)
                } else {
                    let fav = Favorite(productID: product.id)
                    modelContext.insert(fav)
                }
            }

            Text("❤️ Favorited \(favoriteCount) time\(favoriteCount == 1 ? "" : "s")")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding()
        .navigationTitle("Details")
    }
}
