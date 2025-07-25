import SwiftUI

// MARK: – Which feed is showing
enum ProfileFeed: String, CaseIterable, Identifiable {
    case posts, clips, products, saved
    var id: String { rawValue }
    var title: String {
        switch self {
        case .posts:    return "Exhibit"
        case .clips:    return "Footage"
        case .products: return "Products"
        case .saved:    return "Saved"
        }
    }
}

struct CreatorProfileVariantY: View {
    @EnvironmentObject private var savedStore: SavedStore

    // MARK: – Editable profile data
    @State private var fullName = "HDV"
    @State private var handle   = "@hdvapparel"
    @State private var bio      = "Chicago Streetwear"

    // MARK: – Stats (static for now)
    let followerCount  = 200
    let followingCount = 120
    let postCount      = 20
    let clipCount      = 12
    let productCount   = 7

    // MARK: – Panel state
    @State private var panelOffset: CGFloat     = 0
    @GestureState private var dragTranslation: CGFloat = 0
    private let sidebarWidth: CGFloat = UIScreen.main.bounds.width / 2
    private let handleWidth: CGFloat  = 6
    private let gutter: CGFloat       = 8

    // MARK: – Which feed is active
    @State private var selectedFeed: ProfileFeed = .posts

    // MARK: – Sharing
    private var profileURL: URL {
        let username = handle.trimmingCharacters(in: CharacterSet(charactersIn: "@"))
        return URL(string: "https://abstract.app/\(username)")!
    }

    // MARK: – Full-screen avatar
    @State private var showingAvatar = false
    @State private var avatarImage: Image? = Image(systemName: "person.crop.circle")

    // ────────────────────────────────────────────────────────────────────────────
    // MARK: – NEW: reel presentation state
    @State private var showReels = false
    @State private var reelStart = 0

    var body: some View {
        NavigationStack {
            GeometryReader { geo in
                let raw     = panelOffset + dragTranslation
                let offset  = min(max(raw, -sidebarWidth), 0)  // clamp to [-sidebarWidth, 0]
                let isClosed = offset < -sidebarWidth * 0.75

                VStack(spacing: 0) {
                    if isClosed {
                        feedSelector
                            .padding(.horizontal)
                            .padding(.vertical, 8)
                            .background(Color(.systemBackground))
                    }

                    ZStack(alignment: .leading) {
                        sidebarContent(offset: offset)

                        if isClosed {
                            TabView(selection: $selectedFeed) {
                                ForEach(ProfileFeed.allCases) { feed in
                                    grid(for: feed,
                                         fullWidth: geo.size.width,
                                         offset: offset)
                                        .tag(feed)
                                }
                            }
                            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                        } else {
                            grid(for: selectedFeed,
                                 fullWidth: geo.size.width,
                                 offset: offset)
                        }
                    }
                    .overlay(alignment: .leading) {
                        handleView(fullHeight: geo.size.height, offset: offset)
                    }
                    .highPriorityGesture(dragGesture())
                    .animation(.interactiveSpring(response: 0.4,
                                                  dampingFraction: 0.8,
                                                  blendDuration: 0.5),
                               value: panelOffset)
                }
                .navigationBarHidden(true)
                .sheet(isPresented: $showingAvatar) { avatarSheet }
                // ────────────────────────────────────────────────────────────────────────
                // Attach the fullScreenCover _outside_ of your grid frames,
                // so it truly floats full screen.
                .fullScreenCover(isPresented: $showReels) {
                    FootageReelsView(clips: demoClips, startIndex: reelStart)
                        .environmentObject(savedStore)
                }
            }
        }
    }

    // MARK: – Avatar sheet
    private var avatarSheet: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            avatarImage?
                .resizable()
                .scaledToFit()
                .padding()
            Button {
                showingAvatar = false
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.largeTitle)
                    .foregroundColor(.white)
                    .padding()
            }
            .position(x: UIScreen.main.bounds.width - 40, y: 60)
        }
    }

    // MARK: – Sidebar panel
    private func sidebarContent(offset: CGFloat) -> some View {
        ZStack(alignment: .topTrailing) {
            Color(.systemBackground)
            VStack(alignment: .leading, spacing: 16) {
                Spacer().frame(height: 32)

                (avatarImage ?? Image(systemName: "person.crop.circle"))
                    .resizable()
                    .frame(width: 100, height: 100)
                    .clipShape(Circle())
                    .onTapGesture { showingAvatar = true }

                VStack(alignment: .leading, spacing: 4) {
                    Text(fullName).font(.title2).bold()
                    Text(handle).font(.subheadline).foregroundColor(.secondary)
                    Text(bio).font(.caption).foregroundColor(.secondary)
                }

                Divider()

                VStack(alignment: .leading, spacing: 8) {
                    Text("\(followerCount)").font(.headline).bold()
                    Text("Followers").font(.caption).foregroundColor(.secondary)
                    Text("\(followingCount)").font(.headline).bold()
                    Text("Following").font(.caption).foregroundColor(.secondary)
                }

                Divider()

                VStack(alignment: .leading, spacing: 12) {
                    ProfileStatRow(title: "Exhibit", value: postCount)
                    ProfileStatRow(title: "Footage", value: clipCount)
                    ProfileStatRow(title: "Products", value: productCount)
                }

                Spacer()

                HStack(spacing: 12) {
                    NavigationLink(destination:
                        EditProfileView(fullName: $fullName,
                                        handle:   $handle,
                                        bio:      $bio,
                                        avatar:   $avatarImage)
                    ) {
                        Text("Edit Profile")
                            .font(.callout).bold()
                            .foregroundColor(.primary)
                            .padding(.vertical, 4)
                            .padding(.horizontal, 10)
                            .background(Capsule().fill(Color.secondary.opacity(0.1)))
                    }
                    .buttonStyle(.plain)

                    ShareLink(item: profileURL) {
                        Text("Share Profile")
                            .font(.callout).bold()
                            .foregroundColor(.primary)
                            .padding(.vertical, 4)
                            .padding(.horizontal, 10)
                            .background(Capsule().fill(Color.secondary.opacity(0.1)))
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(24)

            NavigationLink(destination: SettingsView()) {
                Image(systemName: "gearshape.fill")
                    .font(.title3)
                    .foregroundColor(.primary)
                    .padding(16)
            }
            .buttonStyle(.plain)
        }
        .frame(width: sidebarWidth)
        .clipped()
        .opacity(Double((sidebarWidth - abs(offset)) / sidebarWidth))
    }

    // MARK: – Top-bar pills
    private var feedSelector: some View {
        HStack(spacing: 16) {
            ForEach(ProfileFeed.allCases) { feed in
                Button {
                    selectedFeed = feed
                } label: {
                    Text(feed.title)
                        .font(.subheadline).bold()
                        .foregroundColor(selectedFeed == feed ? .primary : .secondary)
                        .padding(.vertical, 6)
                        .padding(.horizontal, 12)
                        .background(
                            Capsule()
                                .fill(selectedFeed == feed
                                      ? Color.blue.opacity(0.2)
                                      : Color.clear)
                        )
                }
                .buttonStyle(.plain)
            }
        }
    }

    // MARK: – Grid builder
    @ViewBuilder
    private func grid(for feed: ProfileFeed,
                      fullWidth: CGFloat,
                      offset: CGFloat) -> some View {
        let visibleW = fullWidth - (sidebarWidth + offset)
        let spacing = gutter

        switch feed {
        case .posts:
            ScrollView {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())],
                          spacing: spacing) {
                    ForEach(0..<postCount, id:\.self) { idx in
                        NavigationLink {
                            PostDetailView(posts: demoPosts)
                                .navigationBarHidden(true)
                                .navigationBarBackButtonHidden(true)
                        } label: {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.gray.opacity(0.3))
                                .frame(height: [120, 160, 140][idx % 3])
                        }
                    }
                }
                .padding(spacing)
            }
            .frame(width: visibleW - handleWidth/2)
            .offset(x: sidebarWidth + offset)

        case .clips:
            // Tapping a thumbnail now triggers our full–screen modal
            ScrollView {
                LazyVGrid(columns: [ GridItem(.adaptive(minimum: 90), spacing: spacing) ],
                          spacing: spacing) {
                    ForEach(0..<clipCount, id:\.self) { idx in
                        let clip = demoClips[idx]
                        AsyncImage(url: clip.thumbnailURL) { img in
                            img
                                .resizable()
                                .scaledToFill()
                                .frame(width: (visibleW - spacing*2)/3,
                                       height: (visibleW - spacing*2)/3)
                                .clipped()
                                .cornerRadius(6)
                                .overlay(
                                    HStack(spacing: 4) {
                                        Image(systemName: "play.fill")
                                        Text("\(idx+1)")
                                    }
                                    .font(.caption2).bold()
                                    .padding(6)
                                    .background(Color.black.opacity(0.6))
                                    .foregroundColor(.white)
                                    .clipShape(Capsule())
                                    .padding(8),
                                    alignment: .bottomLeading
                                )
                                .onTapGesture {
                                    reelStart = idx
                                    showReels = true
                                }
                        } placeholder: {
                            RoundedRectangle(cornerRadius: 6)
                                .fill(Color.gray.opacity(0.3))
                                .frame(width: (visibleW - spacing*2)/3,
                                       height: (visibleW - spacing*2)/3)
                        }
                    }
                }
                .padding(spacing)
            }
            .frame(width: visibleW - handleWidth/2)
            .offset(x: sidebarWidth + offset)

        case .products:
            ScrollView {
                LazyVGrid(columns: [GridItem(.flexible()),
                                    GridItem(.flexible()),
                                    GridItem(.flexible())],
                          spacing: spacing) {
                    ForEach(0..<productCount, id:\.self) { idx in
                        VStack(spacing: 8) {
                            Text("PRODUCT \(idx+1)")
                                .font(.caption).bold()
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.gray.opacity(0.3))
                                .aspectRatio(1, contentMode: .fit)
                            Text("\(idx+1) Items")
                                .font(.caption2)
                        }
                        .padding(8)
                        .background(Color(.systemBackground))
                        .overlay(RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.secondary.opacity(0.5), lineWidth:1))
                    }
                }
                .padding(spacing)
            }
            .frame(width: visibleW - handleWidth/2)
            .offset(x: sidebarWidth + offset)

        case .saved:
            postGrid(for: savedStore.savedPosts,
                     fullWidth: fullWidth,
                     offset: offset)
        }
    }

    // MARK: – Two-column grid helper (for posts & saved)
    private func postGrid(
        for posts: [Post],
        fullWidth: CGFloat,
        offset: CGFloat
    ) -> some View {
        let heights: [CGFloat] = [120, 160, 140]
        let spacing = gutter
        let visibleW = fullWidth - (sidebarWidth + offset)

        return ScrollView {
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())],
                      spacing: spacing) {
                ForEach(posts) { post in
                    NavigationLink {
                        PostDetailView(posts: [post])
                            .navigationBarHidden(true)
                            .navigationBarBackButtonHidden(true)
                    } label: {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.gray.opacity(0.3))
                            .frame(height: heights.randomElement()!)
                    }
                }
            }
            .padding(spacing)
        }
        .frame(width: visibleW - handleWidth/2)
        .offset(x: sidebarWidth + offset)
    }

    // MARK: – Grab handle
    private func handleView(fullHeight: CGFloat, offset: CGFloat) -> some View {
        let rawX = sidebarWidth + offset - handleWidth/2
        let xPos = max(handleWidth/2, rawX)
        return Capsule()
            .fill(Color.secondary.opacity(0.6))
            .frame(width: handleWidth, height: 50)
            .position(x: xPos, y: fullHeight/2)
            .shadow(radius: 1)
    }

    // MARK: – Drag gesture
    private func dragGesture() -> some Gesture {
        DragGesture(minimumDistance: 20)
            .updating($dragTranslation) { v, state, _ in
                let dx     = v.translation.width
                let closed = panelOffset <= -sidebarWidth * 0.75
                state = (dx > 0 && closed && selectedFeed != .posts) ? 0 : dx
            }
            .onEnded { v in
                let t      = v.translation.width
                let thr: CGFloat = 80
                let closed = panelOffset <= -sidebarWidth * 0.75
                if t < -thr {
                    if !closed { panelOffset = -sidebarWidth }
                    else { selectedFeed = selectedFeed == .posts ? .clips : .products }
                } else if t > thr && panelOffset == -sidebarWidth {
                    if selectedFeed == .posts { panelOffset = 0 }
                    else { selectedFeed = .posts }
                }
            }
    }
}

// MARK: – Profile-stat row helper
private struct ProfileStatRow: View {
    let title: String
    let value: Int
    var body: some View {
        HStack {
            Text(title).font(.headline)
            Spacer()
            Text("\(value)").font(.subheadline).foregroundColor(.secondary)
        }
    }
}

// MARK: – Demo data for posts & clips
private let demoClips: [ClipModel] = (1...12).map { i in
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

// MARK: – Preview
struct CreatorProfileVariantY_Previews: PreviewProvider {
    static var previews: some View {
        CreatorProfileVariantY()
            .environmentObject(SavedStore())
            .previewInterfaceOrientation(.portrait)
    }
}

