import SwiftUI
import UIKit

// MARK: – Models

struct Comment: Identifiable {
  let id = UUID()
  var username: String
  var text: String
  var likes: Int = 0
  var isLiked: Bool = false
  var replies: [Comment] = []
}

struct Post: Identifiable {
  let id = UUID()
  var images: [Image]
  var likes: Int
  var commentList: [Comment]
  var caption: String
  var datePosted: String
}

let demoPosts: [Post] = (1...5).map { i in
  Post(
    images: [
      Image("post\(i)_1"),
      Image("post\(i)_2"),
      Image("post\(i)_3")
    ],
    likes: Int.random(in: 0...500),
    commentList: [],
    caption: "This is the caption for post #\(i).",
    datePosted: "\(Int.random(in: 1...23))h"
  )
}


// MARK: – Root Detail View

struct PostDetailView: View {
  @EnvironmentObject private var savedStore: SavedStore
  @Environment(\.dismiss) private var dismiss
  let posts: [Post]

  var body: some View {
    NavigationStack {
      VStack(spacing: 0) {
        HStack {
          Button { dismiss() } label: {
            Image(systemName: "chevron.left")
              .font(.title2)
              .foregroundColor(.primary)
          }
          Spacer()
          Text("Exhibit")
            .font(.headline)
            .foregroundColor(.primary)
          Spacer()
          Image(systemName: "ellipsis")
            .rotationEffect(.degrees(90))
            .opacity(0)
        }
        .padding().zIndex(1)

        ScrollView(.vertical, showsIndicators: false) {
          LazyVStack(spacing: 0) {
            ForEach(posts) { post in
              SinglePostView(post: post)
                .environmentObject(savedStore)
                .frame(
                  width: UIScreen.main.bounds.width,
                  height: UIScreen.main.bounds.height
                    - UIApplication.shared.windows.first!.safeAreaInsets.top
                    - UIApplication.shared.windows.first!.safeAreaInsets.bottom
                    - 44
                )
            }
          }
        }
      }
      .ignoresSafeArea(edges: .bottom)
    }
  }
}


// MARK: – Single‐Post View

struct SinglePostView: View {
  @EnvironmentObject private var savedStore: SavedStore

  @State private var page = 0
  @State private var post: Post
  @State private var isLiked = false
  @State private var fireScale: CGFloat = 1
  @State private var showComments = false
  @State private var showShareSheet = false

  init(post: Post) {
    self._post = State(initialValue: post)
  }

  private var shareURL: URL {
    URL(string: "https://abstract.app/post/\(post.id)")!
  }

  var body: some View {
    VStack(spacing: 0) {
      // Image carousel
      ZStack {
        TabView(selection: $page) {
          ForEach(post.images.indices, id: \.self) { idx in
            post.images[idx]
              .resizable()
              .scaledToFit()
              .tag(idx)
          }
        }
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))

        Rectangle()
          .foregroundColor(.clear)
          .contentShape(Rectangle())
          .onTapGesture(count: 2) { toggleLike() }
      }
      .frame(maxHeight: .infinity)
      .overlay(Rectangle().stroke(Color.blue, lineWidth: 3))

      // Action bar
      HStack(spacing: 32) {
        Text(post.datePosted)
          .font(.caption2)
          .foregroundColor(.secondary)

        // Like
        VStack(spacing: 4) {
          Button { toggleLike() } label: {
            Image(systemName: isLiked ? "flame.fill" : "flame")
              .font(.title2)
              .foregroundColor(.red)
              .scaleEffect(fireScale)
          }
          .buttonStyle(.plain)
          Text("\(post.likes)")
            .font(.caption2)
            .foregroundColor(.primary)
        }

        // Comments
        VStack(spacing: 4) {
          Button { showComments = true } label: {
            Image(systemName: "bubble.right")
              .font(.title2)
              .foregroundColor(.primary)
          }
          .buttonStyle(.plain)
          Text("\(post.commentList.count)")
            .font(.caption2)
            .foregroundColor(.primary)
        }

        Spacer()

        // Share
        Button { showShareSheet = true } label: {
          Image(systemName: "square.and.arrow.up")
            .font(.title2)
            .foregroundColor(.primary)
        }
        .buttonStyle(.plain)
        .sheet(isPresented: $showShareSheet) {
          ActivityView(activityItems: [shareURL])
        }

        // Save
        Button {
          savedStore.toggle(post)
        } label: {
          Image(systemName: savedStore.isSaved(post)
                ? "bookmark.fill"
                : "bookmark")
            .font(.title2)
            .foregroundColor(.primary)
        }
        .buttonStyle(.plain)
      }
      .padding(.horizontal)
      .padding(.vertical, 8)

      // Caption
      HStack {
        VStack(alignment: .leading, spacing: 4) {
          Text("@yourHandle").font(.subheadline).bold()
          Text(post.caption).font(.subheadline)
        }
        Spacer()
      }
      .padding(.horizontal)
      .padding(.bottom, 8)
    }
    .sheet(isPresented: $showComments) {
      CommentsView(post: $post)
        .environmentObject(savedStore)
    }
  }

  private func toggleLike() {
    withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
      isLiked.toggle()
      post.likes += isLiked ? 1 : -1
      fireScale = 1.4
    }
    withAnimation(.spring(response: 0.3, dampingFraction: 0.8).delay(0.1)) {
      fireScale = 1
    }
  }
}


// MARK: – Share Sheet Wrapper

struct ActivityView: UIViewControllerRepresentable {
  let activityItems: [Any]
  let applicationActivities: [UIActivity]? = nil

  func makeUIViewController(context: Context) -> UIActivityViewController {
    UIActivityViewController(
      activityItems: activityItems,
      applicationActivities: applicationActivities
    )
  }
  func updateUIViewController(
    _ uiViewController: UIActivityViewController,
    context: Context
  ) {}
}


// MARK: – Comments & Replies

struct CommentsView: View {
  @Binding var post: Post
  @EnvironmentObject private var savedStore: SavedStore
  @Environment(\.dismiss) private var dismiss

  @State private var commentText = ""
  @State private var replyToID: UUID? = nil
  @State private var expandedComments: Set<UUID> = []
  @State private var replyTexts: [UUID:String] = [:]

  private func binding(for id: UUID) -> Binding<String> {
    Binding(
      get: { replyTexts[id, default: ""] },
      set: { replyTexts[id] = $0 }
    )
  }

  var body: some View {
    NavigationStack {
      VStack(spacing: 0) {
        ScrollView(.vertical, showsIndicators: false) {
          LazyVStack(spacing: 0) {
            ForEach(post.commentList.indices, id: \.self) { idx in
              CommentRow(
                comment: $post.commentList[idx],
                expandedComments: $expandedComments,
                replyToID: $replyToID,
                replyText: binding(for: post.commentList[idx].id),
                onDelete: { post.commentList.remove(at: idx) },
                onToggleLike: {
                  post.commentList[idx].isLiked.toggle()
                  post.commentList[idx].likes +=
                    post.commentList[idx].isLiked ? 1 : -1
                },
                onToggleReplyLike: { ridx in
                  post.commentList[idx].replies[ridx].isLiked.toggle()
                  post.commentList[idx].replies[ridx].likes +=
                    post.commentList[idx].replies[ridx].isLiked ? 1 : -1
                },
                onSubmitReply: submitReply(parentID:text:)
              )
              Divider()
            }
          }
          .padding(.horizontal)
        }

        Divider()

        HStack {
          TextField("Add a comment…", text: $commentText)
            .textFieldStyle(RoundedBorderTextFieldStyle())
          Button("Post") {
            guard !commentText.isEmpty else { return }
            post.commentList.append(
              Comment(username: "@you", text: commentText)
            )
            commentText = ""
          }
          .disabled(commentText.isEmpty)
        }
        .padding()
        .background(Color(.systemBackground))
      }
      .navigationTitle("Comments")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .navigationBarLeading) {
          Button("Close") { dismiss() }
        }
      }
    }
  }

  private func submitReply(parentID: UUID, text: String) {
    guard !text.isEmpty else { return }
    if let i = post.commentList.firstIndex(where: { $0.id == parentID }) {
      post.commentList[i].replies.append(Comment(username: "@you", text: text))
    }
    expandedComments.insert(parentID)
    replyToID = nil
    replyTexts[parentID] = ""
  }
}


struct CommentRow: View {
  @Binding var comment: Comment
  @Binding var expandedComments: Set<UUID>
  @Binding var replyToID: UUID?
  @Binding var replyText: String

  var onDelete: () -> Void
  var onToggleLike: () -> Void
  var onToggleReplyLike: (_ ridx: Int) -> Void
  var onSubmitReply: (_ parentID: UUID, _ text: String) -> Void

  var body: some View {
    VStack(alignment: .leading, spacing: 8) {
      HStack(alignment: .top, spacing: 8) {
        Circle()
          .fill(Color.gray.opacity(0.4))
          .frame(width: 32, height: 32)
        VStack(alignment: .leading, spacing: 4) {
          Text(comment.username).font(.subheadline).bold()
          Text(comment.text).font(.body)
          HStack(spacing: 8) {
            Button(action: onToggleLike) {
              Image(systemName: comment.isLiked ? "flame.fill" : "flame")
                .font(.caption)
                .foregroundColor(.red)
            }
            Text("\(comment.likes)").font(.caption2).foregroundColor(.secondary)
            Button { replyToID = comment.id } label: {
              Text("Reply").font(.caption2).foregroundColor(.blue)
            }
            if !comment.replies.isEmpty {
              Button {
                expandedComments.toggleMembership(of: comment.id)
              } label: {
                Image(systemName:
                  expandedComments.contains(comment.id) ? "chevron.down" : "chevron.right"
                )
                .font(.caption2)
                .foregroundColor(.secondary)
              }
            }
          }
        }
        Spacer()
      }
      .contentShape(Rectangle())
      .onTapGesture(count: 2, perform: onToggleLike)
      .swipeActions(edge: .trailing) {
        Button(role: .destructive, action: onDelete) {
          Label("Delete", systemImage: "trash")
        }
      }

      if replyToID == comment.id {
        HStack {
          TextField("Reply…", text: $replyText)
            .textFieldStyle(RoundedBorderTextFieldStyle())
          Button("Post") {
            onSubmitReply(comment.id, replyText)
          }
          .disabled(replyText.isEmpty)
          Button("Cancel") { replyToID = nil; replyText = "" }
            .foregroundColor(.secondary)
        }
        .padding(.leading, 40)
      }

      if expandedComments.contains(comment.id) {
        ForEach(comment.replies.indices, id: \.self) { ridx in
          let reply = comment.replies[ridx]
          HStack(alignment: .top, spacing: 8) {
            Spacer().frame(width: 40)
            Circle().fill(Color.gray.opacity(0.3)).frame(width:24, height:24)
            VStack(alignment: .leading, spacing:4) {
              Text(reply.username).font(.footnote).bold()
              Text(reply.text).font(.footnote)
              HStack(spacing:8) {
                Button {
                  onToggleReplyLike(ridx)
                } label: {
                  Image(systemName: reply.isLiked ? "flame.fill" : "flame")
                    .font(.caption2)
                    .foregroundColor(.red)
                }
                Text("\(reply.likes)").font(.caption2).foregroundColor(.secondary)
              }
            }
            Spacer()
          }
        }
      }
    }
    .padding(.vertical,4)
  }
}

// MARK: – Helpers
extension Set where Element: Hashable {
  mutating func toggleMembership(of element: Element) {
    if contains(element) { remove(element) }
    else { insert(element) }
  }
}

// MARK: – Preview
struct PostDetailView_Previews: PreviewProvider {
  static var previews: some View {
    PostDetailView(posts: demoPosts)
      .environmentObject(SavedStore())
      .previewInterfaceOrientation(.portrait)
  }
}

