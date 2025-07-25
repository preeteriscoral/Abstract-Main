// MarketplaceView.swift

import SwiftUI

struct MarketplaceView: View {
    var body: some View {
        NavigationStack {
            Text("Marketplace Coming Soon")
                .font(.title)
                .foregroundColor(.gray)
                .navigationTitle("Marketplace")
        }
    }
}

struct MarketplaceView_Previews: PreviewProvider {
    static var previews: some View {
        MarketplaceView()
    }
}

