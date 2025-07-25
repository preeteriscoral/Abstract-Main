// ExploreView.swift

import SwiftUI
import SwiftData

struct ExploreView: View {
    // Sort by the actual `name` property
    @Query(sort: \Creator.name, order: .forward)
    var creators: [Creator]

    var body: some View {
        NavigationStack {
            List {
                ForEach(creators) { creator in
                    NavigationLink(
                        destination:
                            CreatorProfileVariantY()
                                .environmentObject(SavedStore())
                    ) {
                        HStack(spacing: 12) {
                            // Avatar thumbnail
                            if let avatarURL = creator.avatarURL,
                               let url = URL(string: avatarURL) {
                                AsyncImage(url: url) { image in
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                } placeholder: {
                                    Circle()
                                        .fill(Color.gray.opacity(0.3))
                                }
                                .frame(width: 48, height: 48)
                                .clipShape(Circle())
                            } else {
                                Circle()
                                    .fill(Color.gray.opacity(0.3))
                                    .frame(width: 48, height: 48)
                            }

                            // Name & bio
                            VStack(alignment: .leading, spacing: 2) {
                                Text(creator.name)
                                    .font(.headline)
                                Text(creator.bio)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
            .navigationTitle("Explore")
        }
    }
}

#Preview {
    ExploreView()
        .modelContainer(
            for: [Creator.self],
            inMemory: true
        )
        .environmentObject(SavedStore())
}

