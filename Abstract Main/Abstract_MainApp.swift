import SwiftUI

@main
struct AbstractMainApp: App {
    @StateObject private var savedStore = SavedStore()
    @StateObject private var postsStore = PostsStore()   // <-- new shared store

    var body: some Scene {
        WindowGroup {
            CreatorProfileVariantY()
                .environmentObject(savedStore)
                .environmentObject(postsStore)           // <-- inject
        }
    }
}

