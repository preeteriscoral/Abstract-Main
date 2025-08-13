import SwiftUI
import Combine

final class PostsStore: ObservableObject {
    @Published var posts: [Post] = {
        // Build demo posts here so they live in the shared store
        // NOTE: if you don't have the "postX_Y" assets, replace with a placeholder image.
        func imgs(_ i: Int) -> [Image] {
            [
                Image("post\(i)_1"),
                Image("post\(i)_2"),
                Image("post\(i)_3")
            ]
        }
        return (1...5).map { i in
            Post(
                images: imgs(i),
                likes: Int.random(in: 0...500),
                commentList: [],
                caption: "This is the caption for post #\(i).",
                datePosted: "\(Int.random(in: 1...23))h",
                isLiked: false
            )
        }
    }()
}

