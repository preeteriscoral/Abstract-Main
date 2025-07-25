// ExplorerProfileView.swift

import SwiftUI

struct ExplorerProfileView: View {
    @EnvironmentObject private var savedStore: SavedStore

    // Dummy “purchase history” array; replace with your real data later
    @State private var purchaseHistory: [String] = [
        "Big Buck Bunny T-Shirt",
        "Elephants Dream Poster"
    ]

    var body: some View {
        NavigationStack {
            List {
                purchaseHistorySection
                savedPostsSection
                savedProductsSection
                followingCreatorsSection
            }
            .navigationTitle("Explorer Profile")
            .listStyle(InsetGroupedListStyle())
        }
    }

    // MARK: – Section 1: Purchase History
    private var purchaseHistorySection: some View {
        Section(header: Text("Purchase History")) {
            if purchaseHistory.isEmpty {
                Text("You haven’t purchased anything yet.")
                    .foregroundColor(.secondary)
            } else {
                ForEach(purchaseHistory, id: \.self) { item in
                    HStack {
                        Image(systemName: "cart.fill")
                            .foregroundColor(.blue)
                        Text(item)
                    }
                }
            }
        }
    }

    // MARK: – Section 2: Saved Posts
    private var savedPostsSection: some View {
        Section(header: Text("Saved Posts")) {
            let saved = savedStore.savedPosts
            if saved.isEmpty {
                Text("You haven’t saved any posts.")
                    .foregroundColor(.secondary)
            } else {
                ForEach(saved) { post in
                    NavigationLink(
                        destination:
                            // Destination is PostDetailView(posts: [post])
                            PostDetailView(posts: [post])
                                .environmentObject(savedStore)
                    ) {
                        HStack {
                            RoundedRectangle(cornerRadius: 6)
                                .fill(Color.gray.opacity(0.3))
                                .frame(width: 60, height: 60)
                                .overlay(
                                    Text("Img")
                                        .foregroundColor(.white)
                                        .font(.caption)
                                )

                            // ← Use post.caption (since `Post` has a `caption` property, not `title`)
                            Text(post.caption)
                                .lineLimit(1)
                                .font(.body)
                        }
                    }
                }
            }
        }
    }

    // MARK: – Section 3: Saved Products
    private var savedProductsSection: some View {
        Section(header: Text("Saved Products")) {
            // Placeholder; you can wire up real saved‐products logic later
            Text("No saved products yet.")
                .foregroundColor(.secondary)
        }
    }

    // MARK: – Section 4: Following Creators
    private var followingCreatorsSection: some View {
        Section(header: Text("Following Creators")) {
            // Placeholder; wire up real “following” logic later
            Text("No followed creators yet.")
                .foregroundColor(.secondary)
        }
    }
}

struct ExplorerProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ExplorerProfileView()
            .environmentObject(SavedStore())
    }
}

