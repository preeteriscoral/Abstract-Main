// MainTabView.swift

import SwiftUI

struct MainTabView: View {
    // Grab it from the environment
    @EnvironmentObject private var savedStore: SavedStore
    let userType: UserType  // however you pass this in

    var body: some View {
        TabView {
            ExploreView()
                .tabItem { Label("Explore",   systemImage: "magnifyingglass") }

            MarketplaceView()
                .tabItem { Label("Marketplace", systemImage: "cart") }

            MessagesView()
                .tabItem { Label("Messages",    systemImage: "bubble.right") }

            // now this will find the SavedStore
            CreatorProfileVariantY()
                .tabItem { Label("Profile",     systemImage: "person.crop.circle") }
        }
    }
}

