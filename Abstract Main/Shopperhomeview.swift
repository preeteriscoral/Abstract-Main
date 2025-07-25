import SwiftUI

struct ShopperHomeView: View {
    var body: some View {
        TabView {
            ExploreView()
                .tabItem { Label("Explore", systemImage: "sparkles") }

            MarketplaceView()
                .tabItem { Label("Marketplace", systemImage: "list.bullet") }

            MessagesView()   // Your existing shopper messages screen
                .tabItem { Label("Messages", systemImage: "message") }

            ProfileView()    // Or AccountView, whatever you’ve named it
                .tabItem { Label("Profile", systemImage: "person.crop.circle") }
        }
    }
}

struct ShopperHomeView_Previews: PreviewProvider {
    static var previews: some View {
        ShopperHomeView()
            .modelContainer(for: [Product.self, Creator.self], inMemory: true)
    }
}
