import SwiftUI

struct ProductRow: View {
    let product: Product

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(product.name)
                    .font(.headline)
                Text(product.productDescription)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            Spacer()
            Text(String(format: "$%.2f", product.price))
                .font(.subheadline)
        }
        .padding(.vertical, 4)
    }
}
