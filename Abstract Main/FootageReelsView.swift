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

struct FootageReelsView: View {
    @EnvironmentObject private var savedStore: SavedStore

    let clips: [ClipModel]

    @State private var currentIndex: Int
    @State private var players: [AVPlayer]
    @State private var isLiked: [Bool]
    @State private var heartPop: Set<UUID> = []

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
                CommentsPlaceholderView(clip: clips[commentsIndex])
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
                // Use exactly the safe-area top inset so the button sits up high
                .padding(.top, topInset - 50)   // move it 8pts higher
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

                // Action buttons
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
                            .resizable()
                            .frame(width: 28, height: 28)
                            .foregroundColor(.white)
                    }

                    // Save
                    Button {
                        savedStore.toggle(clip)
                    } label: {
                        Image(systemName: savedStore.isSaved(clip) ? "bookmark.fill" : "bookmark")
                            .resizable()
                            .frame(width: 26, height: 28)
                            .foregroundColor(.white)
                    }

                    // Comments
                    Button {
                        commentsIndex = idx
                        showingComments = true
                    } label: {
                        Image(systemName: "bubble.right")
                            .resizable()
                            .frame(width: 26, height: 26)
                            .foregroundColor(.white)
                    }

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
                            .resizable()
                            .frame(width: 26, height: 26)
                            .foregroundColor(.white)
                    }
                }
                .padding(.trailing, 16)
            }
            .padding(.horizontal, 16)
            .padding(.bottom, bottomInset + 12)
        }
        // — Gestures & heart pop —
        .contentShape(Rectangle())
        .onTapGesture(count: 1) {
            let p = players[idx]
            if p.timeControlStatus == .playing { p.pause() }
            else { p.play() }
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
    }
}

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
#endif

