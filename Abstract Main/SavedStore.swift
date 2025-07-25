import SwiftUI
import Combine

final class SavedStore: ObservableObject {
  @Published private(set) var savedPosts: [Post] = []
  @Published private(set) var savedClips: [ClipModel] = []

  func toggle(_ post: Post) {
    if let i = savedPosts.firstIndex(where: { $0.id == post.id }) {
      savedPosts.remove(at: i)
    } else {
      savedPosts.append(post)
    }
  }

  func toggle(_ clip: ClipModel) {
    if let i = savedClips.firstIndex(where: { $0.id == clip.id }) {
      savedClips.remove(at: i)
    } else {
      savedClips.append(clip)
    }
  }

  func isSaved(_ post: Post) -> Bool {
    savedPosts.contains(where: { $0.id == post.id })
  }

  func isSaved(_ clip: ClipModel) -> Bool {
    savedClips.contains(where: { $0.id == clip.id })
  }
}

