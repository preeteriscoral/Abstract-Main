import SwiftUI

@main
struct Abstract_MainApp: App {
    // Keep your savedStore as a single source of truth
    @StateObject private var savedStore = SavedStore()

    var body: some Scene {
        WindowGroup {
            // ← POINT YOUR ROOT HERE to whatever you're actively iterating on:
            CreatorProfileVariantY()
                .environmentObject(savedStore)
        }
    }
}

