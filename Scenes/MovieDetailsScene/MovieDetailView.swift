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
struct GenreTag: View {
    let text: String
    var body: some View {
        Text(text.uppercased())
            .font(.caption).fontWeight(.medium)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(Color(.systemBlue).opacity(0.1))
            .foregroundColor(.blue)
            .cornerRadius(8)
    }
}

struct DetailItem: View {
    let title: String
    let value: String
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title).font(.subheadline).foregroundColor(.secondary)
            Text(value).font(.subheadline).fontWeight(.medium)
        }
    }
}

struct CastMemberView: View {
    let person: Person
    var body: some View {
        VStack(spacing: 8) {
            AsyncRemoteImage(url: person.imageURL)
                .frame(width: 80, height: 80)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            Text(person.name)
                .font(.caption)
                .lineLimit(2)
                .multilineTextAlignment(.center)
        }
        .frame(width: 80)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(Text(person.name))
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
struct MovieDetailView: View {
    @StateObject var viewModel: MovieDetailViewModel

    // Layout constants so we don’t accidentally change sizes
    private enum Layout {
        static let heroHeight: CGFloat = 300
        static let cardCorner: CGFloat = 25
        static let cardOffsetY: CGFloat = -40
        static let sectionSpacing: CGFloat = 20
    }

    var body: some View {
        
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 0) {
                ZStack(alignment: .top) {
                    // HERO
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

                    // CARD (starts inside ZStack, heroH - overlap from the top)
                    VStack(alignment: .leading, spacing: 20) {
                        contentCard
                        Spacer()

                    }
                    .padding(20)
                    .background(Color(.systemBackground))
                    .cornerRadius(25, corners: [.topLeft, .topRight])
                    .shadow(radius: 5)
                    .padding(.top, 300 - 40) // 👈 overlap without offset
                }
            }
        }
        // keep ignoring only the top safe area
        .edgesIgnoringSafeArea(.top)
        .scrollBounceBehavior(.basedOnSize)
        .background(Color(.systemBackground))
        .overlay(loadingOverlay)              // loading/error on top, not altering layout
        .onAppear { viewModel.load() }
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
        VStack(alignment: .leading, spacing: Layout.sectionSpacing) {
            titleSection
            ratingSection
            tagsSection
            infoSection
            descriptionSection
            castSection
        }
        .padding(.horizontal)
        .padding(.top, 20)
        .accessibilityElement(children: .contain)
    }

    private var titleSection: some View {
        HStack(alignment: .top) {
            Text(viewModel.detail?.base.title ?? "")
                .font(.title).fontWeight(.bold)

            Spacer()

            Image(systemName: "bookmark")
                .foregroundColor(.gray)
                .font(.title2)
                .accessibilityLabel(Text("Bookmark"))
        }
    }

    private var ratingSection: some View {
        Group {
            if let score = viewModel.detail?.base.score {
                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                        .font(.subheadline)
                    Text("\(score, specifier: "%.1f")/10 IMDb")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
        }
    }

    private var tagsSection: some View {
        HStack {
            ForEach(viewModel.detail?.base.genres ?? [], id: \.self) { GenreTag(text: $0) }
        }
    }

    private var infoSection: some View {
        HStack(spacing: 40) {
            DetailItem(title: "Length",   value: formattedDuration(minutes: viewModel.detail?.base.duration))
            DetailItem(title: "Language", value: viewModel.detail?.title ?? "N/A")
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
        .padding(.vertical, 10)
    }

    private var descriptionSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Description")
                .font(.headline).fontWeight(.bold)
            Text(viewModel.detail?.synopsis ?? "")
                .font(.body).foregroundColor(.secondary)
                .lineLimit(5)
        }
    }

    private var castSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Cast").font(.headline).fontWeight(.bold)
                Spacer()
                Button("See more") { /* open cast */ }
                    .font(.subheadline)
                    .foregroundColor(.blue)
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 20) {
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
}
