// FootageReelsView.swift

import SwiftUI
import AVKit
import Combine

// ————————————————————————————————————————————
// MARK: – Clip model (needed here so this file compiles)
// If you already have ClipModel in its own file, delete this block.
struct ClipModel: Identifiable {
    let id: UUID
    let url: URL
    let thumbnailURL: URL
    let views: Int
    let likes: Int
    let comments: Int
    let caption: String
}

// Comment model for reels
struct ClipComment: Identifiable {
    let id = UUID()
    var username: String
    var text: String
    var likes: Int = 0
    var isLiked: Bool = false
    var replies: [ClipComment] = []
}
struct FootageReelsView: View {
    @EnvironmentObject private var savedStore: SavedStore

    let clips: [ClipModel]

    @State private var currentIndex: Int
    @State private var players: [AVPlayer]
    @State private var isLiked: [Bool]
    @State private var heartPop: Set<UUID> = []
    @State private var clipComments: [[ClipComment]]
    @State private var showingComments = false
    @State private var commentsIndex = 0

    @Environment(\.dismiss) private var dismiss

    init(clips: [ClipModel], startIndex: Int) {
        self.clips = clips
        self._currentIndex = State(initialValue: startIndex)

        // Build & auto-loop AVPlayers
        let built = clips.map { clip -> AVPlayer in
            let p = AVPlayer(url: clip.url)
            p.actionAtItemEnd = .none
            NotificationCenter.default.addObserver(
                forName: .AVPlayerItemDidPlayToEndTime,
                object: p.currentItem,
                queue: .main
            ) { _ in
                p.seek(to: .zero)
                p.play()
            }
            return p
        }
        self._players = State(initialValue: built)
        self._isLiked = State(initialValue: Array(repeating: false, count: clips.count))
        self._clipComments = State(initialValue: clips.map { _ in [] })
    }

    var body: some View {
        GeometryReader { geo in
            let topInset = geo.safeAreaInsets.top
            let bottomInset = geo.safeAreaInsets.bottom

            TabView(selection: $currentIndex) {
                ForEach(clips.indices, id: \.self) { idx in
                    ZStack {
                        Color.black.ignoresSafeArea()

                        VideoPlayer(player: players[idx])
                            .onAppear   { players[idx].play() }
                            .onDisappear{ players[idx].pause() }                            .ignoresSafeArea()

                        if players[idx].timeControlStatus != .playing {
                            Image(systemName: "play.slash.fill")
                                .font(.system(size: 50))
                                .foregroundColor(.white.opacity(0.0))
                        }

                        overlayContent(
                            clip: clips[idx],
                            index: idx,
                            topInset: topInset,
                            bottomInset: bottomInset
                        )
                    }
                    .tag(idx)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .ignoresSafeArea()
            .sheet(isPresented: $showingComments) {
                ClipCommentsView(comments: $clipComments[commentsIndex])
            }
        }
    }

    @ViewBuilder
    private func overlayContent(
        clip: ClipModel,
        index idx: Int,
        topInset: CGFloat,
        bottomInset: CGFloat
    ) -> some View {
        VStack {
            // — Top back button —
            HStack {
                Button { dismiss() } label: {
                    Image(systemName: "chevron.left")
                        .font(.title2)
                        .foregroundColor(.white)
                }
                .padding(.leading, 16)
                .padding(.top, topInset - 50)
                Spacer()
            }

            Spacer()

            // — Bottom bar: caption & actions —
            HStack(alignment: .bottom) {
                // Caption
                VStack(alignment: .leading, spacing: 4) {
                    Text("@hdvapparel")
                        .bold()
                    Text(clip.caption)
                        .lineLimit(2)
                }
                .foregroundColor(.white)
                .font(.body)

                Spacer()

                // Action buttons (exactly one of each)
                VStack(spacing: 24) {
                    // Like
                    Button {
                        isLiked[idx].toggle()
                        heartPop.insert(clip.id)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                            heartPop.remove(clip.id)
                        }
                    } label: {
                        Image(systemName: isLiked[idx] ? "flame.fill" : "flame")
                            .font(.title2)          // Consistent sizing
                            .foregroundColor(.red)  // Same red as PostDetailView
                    }
                    .buttonStyle(.plain)

                    // Comments
                    Button {
                        commentsIndex = idx
                        showingComments = true
                    } label: {
                        Image(systemName: "bubble.right")
                            .font(.title2)
                            .foregroundColor(.white)
                    }
                    .buttonStyle(.plain)

                    // Share
                    Button {
                        let sheet = UIActivityViewController(
                            activityItems: [clip.url],
                            applicationActivities: nil
                        )
                        UIApplication.shared.windows.first?
                            .rootViewController?
                            .present(sheet, animated: true)
                    } label: {
                        Image(systemName: "square.and.arrow.up")
                            .font(.title2)
                            .foregroundColor(.white)
                    }
                    .buttonStyle(.plain)
                    
                    // Save
                    Button {
                        savedStore.toggle(clip)
                    } label: {
                        Image(systemName: savedStore.isSaved(clip) ? "bookmark.fill" : "bookmark")
                            .font(.title2)
                            .foregroundColor(.white)
                    }
                    .buttonStyle(.plain)


                }
                .padding(.trailing, 16)
            }
            .padding(.horizontal, 16)
            .padding(.bottom, bottomInset + 12)
        }
        .contentShape(Rectangle())
        // Gestures & heart pop overlay remain unchanged
        .onTapGesture(count: 1) {
            let p = players[idx]
            if p.timeControlStatus == .playing { p.pause() } else { p.play() }
        }
        .onTapGesture(count: 2) {
            isLiked[idx].toggle()
        }
        .overlay {
            if heartPop.contains(clip.id) {
                Image(systemName: "heart.fill")
                    .font(.system(size: 100))
                    .foregroundColor(.white.opacity(0.8))
                    .scaleEffect(1.2)
                    .transition(.scale)
                    .animation(.spring(), value: heartPop)
            }
        }
    } // <-- closes overlayContent

} // <-- closes FootageReelsView

// MARK: – Placeholder comments sheet
struct CommentsPlaceholderView: View {
    let clip: ClipModel
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            Text("Comments for “\(clip.caption)”")
                .navigationTitle("Comments")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Close") { dismiss() }
                    }
                }
        }
    }
}

// MARK: – Preview
#if DEBUG
private let demoClips: [ClipModel] = (1...5).map { i in
    ClipModel(
        id: UUID(),
        url: URL(string:
            "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4"
        )!,
        thumbnailURL: URL(string:
            "https://peach.blender.org/wp-content/uploads/title_anouncement.jpg?x11217"
        )!,
        views: Int.random(in: 0...10_000),
        likes: Int.random(in: 0...1_000),
        comments: Int.random(in: 0...500),
        caption: "Clip #\(i)"
    )
}

struct FootageReelsView_Previews: PreviewProvider {
    static var previews: some View {
        FootageReelsView(clips: demoClips, startIndex: 0)
            .environmentObject(SavedStore())
            .previewDevice("iPhone 14 Pro")
    }
}
// Full comments UI for reels
struct ClipCommentsView: View {
    @Binding var comments: [ClipComment]
    @Environment(\.dismiss) private var dismiss

    @State private var commentText = ""
    @State private var replyToID: UUID? = nil
    @State private var expandedComments: Set<UUID> = []
    @State private var replyTexts: [UUID: String] = [:]

    private func binding(for id: UUID) -> Binding<String> {
        Binding(
            get: { replyTexts[id, default: ""] },
            set: { replyTexts[id] = $0 }
        )
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(comments.indices, id: \.self) { idx in
                            ClipCommentRow(
                                comment: $comments[idx],
                                expandedComments: $expandedComments,
                                replyToID: $replyToID,
                                replyText: binding(for: comments[idx].id),
                                onDelete: { comments.remove(at: idx) },
                                onToggleLike: {
                                    comments[idx].isLiked.toggle()
                                    comments[idx].likes += comments[idx].isLiked ? 1 : -1
                                },
                                onToggleReplyLike: { rIdx in
                                    comments[idx].replies[rIdx].isLiked.toggle()
                                    comments[idx].replies[rIdx].likes += comments[idx].replies[rIdx].isLiked ? 1 : -1
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
                        comments.append(ClipComment(username: "@you", text: commentText))
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
        if let i = comments.firstIndex(where: { $0.id == parentID }) {
            comments[i].replies.append(ClipComment(username: "@you", text: text))
        }
        expandedComments.insert(parentID)
        replyToID = nil
        replyTexts[parentID] = ""
    }
}

// A single comment row with likes, replies and delete actions
struct ClipCommentRow: View {
    @Binding var comment: ClipComment
    @Binding var expandedComments: Set<UUID>
    @Binding var replyToID: UUID?
    @Binding var replyText: String
    var onDelete: () -> Void
    var onToggleLike: () -> Void
    var onToggleReplyLike: (_ replyIndex: Int) -> Void
    var onSubmitReply: (_ parentID: UUID, _ text: String) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Main comment line
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
                                if expandedComments.contains(comment.id) {
                                    expandedComments.remove(comment.id)
                                } else {
                                    expandedComments.insert(comment.id)
                                }
                            } label: {
                                Image(systemName: expandedComments.contains(comment.id) ? "chevron.down" : "chevron.right")
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

            // Reply input
            if replyToID == comment.id {
                HStack {
                    TextField("Reply…", text: $replyText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    Button("Post") {
                        onSubmitReply(comment.id, replyText)
                    }
                    .disabled(replyText.isEmpty)
                    Button("Cancel") {
                        replyToID = nil
                        replyText = ""
                    }
                    .foregroundColor(.secondary)
                }
                .padding(.leading, 40)
            }

            // Replies
            if expandedComments.contains(comment.id) {
                ForEach(comment.replies.indices, id: \.self) { rIdx in
                    let reply = comment.replies[rIdx]
                    HStack(alignment: .top, spacing: 8) {
                        Spacer().frame(width: 40)
                        Circle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 24, height: 24)
                        VStack(alignment: .leading, spacing: 4) {
                            Text(reply.username).font(.footnote).bold()
                            Text(reply.text).font(.footnote)
                            HStack(spacing: 8) {
                                Button {
                                    onToggleReplyLike(rIdx)
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
        .padding(.vertical, 4)
    }
}
#endif

