import SwiftUI

// MARK: - Corner helper (kept)
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}
struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

// MARK: - Small UI atoms (kept look)

struct DetailItem: View {
    let title: String
    let value: String
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title).font(.custom("Mulish-Regular", size: 12)).foregroundStyle(Color(.textSecondary))
            Text(value).font(.custom("Mulish-SemiBold", size: 12)).foregroundStyle(Color(.black))
        }
    }
}

struct CastMemberView: View {
    let person: Person
    var body: some View {
        VStack(spacing: 4) {
            AsyncRemoteImage(url: person.imageURL)
                .frame(width: 72, height: 72)
                .clipShape(RoundedRectangle(cornerRadius: 5))
            Text(person.name)
                .font(.custom("Mulish-Regular", size: 12))
                .multilineTextAlignment(.center)
        }
        .frame(width: 72)
    }
}

// Async image with graceful fallbacks (same visuals)
struct AsyncRemoteImage: View {
    let url: URL?
    var body: some View {
        AsyncImage(url: url) { phase in
            switch phase {
            case .success(let image):
                image.resizable().scaledToFill()
            case .failure(_):
                Color.gray.opacity(0.2)
            case .empty:
                Color.gray.opacity(0.1)
            @unknown default:
                Color.gray.opacity(0.2)
            }
        }
    }
}

// MARK: - Main View

// Layout constants so we don’t accidentally change sizes
private enum Layout {
    static let heroHeight: CGFloat = 300
    static let cardCorner: CGFloat = 25
    static let cardOffsetY: CGFloat = -40
}

struct MovieDetailView: View {
    @StateObject var viewModel: MovieDetailViewModel
    
    // Layout constants so we don’t accidentally change sizes
    private enum Layout {
        static let heroHeight: CGFloat = 300
        static let cardCorner: CGFloat = 25
        static let cardOffsetY: CGFloat = -40
    }
    
    var body: some View {
        
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 0) {
                ZStack(alignment: .top) {
                    GeometryReader { geo in
                        AsyncImage(url: viewModel.detail?.base.bannerURL) { phase in
                            (phase.image ?? Image(uiImage: .init()))
                                .resizable()
                                .scaledToFill()
                        }
                        .frame(width: geo.size.width, height: 300)
                        .clipped()
                    }
                    .frame(height: 300) // important: cap GeometryReader height
                    
                    VStack(alignment: .leading) {
                        contentCard
                        // FIX: Am eliminat Spacer()-ul care împiedica scroll-ul corect
                        // Spacer()
                    }
                    .background(Color(.systemBackground))
                    .cornerRadius(10, corners: [.topLeft, .topRight])
                    .padding(.top, 300 - 40) // 👈 overlap without offset
                }
            }
        }
        // Pastrează ignorarea safe area doar pentru top, dar ascunde Tab Bar-ul
        .ignoresSafeArea(.all, edges: .top)
        .scrollBounceBehavior(.basedOnSize)
        .background(Color(.systemBackground))
        .overlay(loadingOverlay)              // loading/error on top, not altering layout
        .onAppear { viewModel.load() }
        // FIX 2: Ascunde Tab Bar-ul pe acest ecran
        .toolbar(.hidden, for: .tabBar) //
    }
    
    // MARK: Hero header
    private var heroSection: some View {
        ZStack(alignment: .bottomLeading) {
            GeometryReader { geo in
                AsyncImage(url: viewModel.detail?.base.bannerURL) { phase in
                    (phase.image ?? Image(uiImage: .init()))
                        .resizable()
                        .scaledToFill()
                }
                .frame(width: geo.size.width, height: 300) // 👈 pin width + height
                .clipped()
            }
            .frame(height: 300)
            
            // Subtle readability gradient (keeps same look)
            LinearGradient(
                colors: [.clear, .black.opacity(0.25)],
                startPoint: .center, endPoint: .bottom
            )
            .frame(height: Layout.heroHeight)
            .allowsHitTesting(false)
            
            // Back and Play keep same positions/appearance
            VStack {
                HStack {
                    CircleIcon(system: "arrow.left")
                    Spacer()
                }
                Spacer()
                
                VStack(spacing: 0) {
                    Button(action: { /* Play trailer */ }) {
                        Image(systemName: "play.circle.fill")
                            .resizable()
                            .frame(width: 60, height: 60)
                            .foregroundColor(.white)
                            .shadow(radius: 5)
                    }
                    Text("Play Trailer")
                        .font(.caption)
                        .foregroundColor(.white)
                        .padding(.top, 8)
                }
                .padding(.bottom, 10)
                .offset(y: -50) // keep your exact visual offset
            }
            .padding(.top, 50)
            .padding(.horizontal)
        }
        .frame(maxHeight: 400) // preserves your max cap
    }
    
    // Small circle button with the same look as before
    private struct CircleIcon: View {
        let system: String
        var body: some View {
            Image(systemName: system)
                .foregroundColor(.white)
                .padding(10)
                .background(Color.black.opacity(0.3))
                .clipShape(Circle())
        }
    }
    
    // MARK: Card content
    private var contentCard: some View {
        VStack(alignment: .leading) {
            titleSection
            ratingSection
            tagsSection
            infoSection
            descriptionSection
            castSection
        }
        .padding(.horizontal, 24)
        .padding(.top, 24)
    }
    
    private var titleSection: some View {
        HStack(alignment: .top) {
            Text(viewModel.detail?.base.title ?? "")
                .font(.custom("Mulish-Bold", size: 20))
                .lineLimit(2)
            Spacer()
            Image(systemName: "bookmark")
                .foregroundColor(.gray)
        }
        .padding(.bottom, 8)
    }
    
    private var ratingSection: some View {
        Group {
            if let score = viewModel.detail?.base.score {
                HStack(spacing: 2) {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                    Text("\(score, specifier: "%.1f")/10 IMDb")
                        .font(.custom("Mulish-Regular", size: 12))
                        .foregroundColor(.textSecondary)
                }
                .padding(.bottom, 16)
            }
        }
    }
    
    private var tagsSection: some View {
        HStack(spacing: 8) {
            ForEach(viewModel.detail?.base.genres ?? [], id: \.self) { GenreTag(text: $0) }
        }
        .padding(.bottom, 16)
    }
    
    private var infoSection: some View {
        HStack(spacing: 50) {
            DetailItem(title: "Length",   value: formattedDuration(minutes: viewModel.detail?.base.duration))
            DetailItem(title: "Language", value: viewModel.detail?.country ?? "N/A")
            DetailItem(
                title: "Rating",
                value: {
                    if let score = viewModel.detail?.base.score {
                        String(format: "%.1f/10", score)
                    } else if let status = viewModel.detail?.status, !status.isEmpty {
                        status
                    } else {
                        "N/A"
                    }
                }()
            )
        }
        .padding(.bottom, 24)
    }
    
    private var descriptionSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            SectionHeader("Description", isButtonVisible: false)
            Text(cleanedSynopsis(viewModel.detail?.synopsis ?? ""))
                .font(.custom("Mulish-Regular", size: 12))
                .foregroundStyle(Color.textSecondary)
            
        }
        .padding(.bottom, 24)
    }
    
    private var castSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            SectionHeader("Cast")
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 13) {
                    ForEach(viewModel.detail?.cast ?? [], id: \.id) { CastMemberView(person: $0) }
                }
            }
        }
    }
    
    // MARK: Loading / error overlay (doesn’t change layout)
    private var loadingOverlay: some View {
        Group {
            if viewModel.isLoading {
                Color.black.opacity(0.05)
                    .ignoresSafeArea()
                    .overlay(ProgressView())
            } else if let error = viewModel.error {
                Color.clear.overlay(
                    VStack(spacing: 10) {
                        Image(systemName: "exclamationmark.triangle.fill").foregroundColor(.orange)
                        Text("Eroare: \(error)").font(.subheadline)
                    }
                        .padding()
                )
            }
        }
        .animation(.easeInOut(duration: 0.2), value: viewModel.isLoading || viewModel.error != nil)
    }
    
    // MARK: Utils
    private func formattedDuration(minutes: Int?) -> String {
        guard let minutes = minutes, minutes > 0 else { return "N/A" }
        let h = minutes / 60, m = minutes % 60
        return "\(h)h \(m)m"
    }
    
    private func cleanedSynopsis(_ synopsis: String?) -> String {
        guard let synopsis = synopsis else { return "" }
        let htmlStripped = synopsis.replacingOccurrences(
            of: "<[^>]+>",
            with: "",
            options: .regularExpression,
            range: nil
        )
        
        let newlinesRemoved = htmlStripped.replacingOccurrences(
            of: "\n",
            with: " ",
            options: .literal,
            range: nil
        )
        
        let multipleSpacesRemoved = newlinesRemoved.replacingOccurrences(
            of: " +",
            with: " ",
            options: .regularExpression,
            range: nil
        )
        
        return multipleSpacesRemoved.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
