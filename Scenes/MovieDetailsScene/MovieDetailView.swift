//
//  MovieDetailViewModel.swift
//  Movie Browser
//
//  Created by Alice Surdu on 18.10.2025.
//

import SwiftUI

/// Displays the full details for a single movie.
struct MovieDetailView: View {
    @StateObject var viewModel: MovieDetailViewModel
    @Environment(\.dismiss) private var dismiss
    
    // MARK: - Layout Constants
    
    private enum Layout {
        static let heroHeight: CGFloat = 300
        static let cardOverlap: CGFloat = 40
    }
    
    // MARK: - Body
    
    var body: some View {
        
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 0) {
                ZStack(alignment: .top) {
                    heroSection
                        .frame(height: Layout.heroHeight)
                    VStack(alignment: .leading) {
                        contentCard
                    }
                    .background(Color(.systemBackground))
                    .cornerRadius(10, corners: [.topLeft, .topRight])
                    .padding(.top, Layout.heroHeight - Layout.cardOverlap)
                }
            }
        }
        .ignoresSafeArea(.all, edges: .top)
        .scrollBounceBehavior(.basedOnSize)
        .background(Color(.systemBackground))
        .overlay(loadingOverlay)
        .onAppear {
            viewModel.load()
        }
        .toolbar(.hidden, for: .tabBar)
        .navigationBarBackButtonHidden(true)
    }
    
    // MARK: - Private Subviews
    
    /// The top hero banner section with image and overlay buttons.
    private var heroSection: some View {
        ZStack(alignment: .top) {
            GeometryReader { geo in
                AsyncRemoteImage(url: viewModel.detail?.base.bannerURL)
                    .frame(width: geo.size.width, height: Layout.heroHeight)
                    .clipped()
            }
            .frame(height: Layout.heroHeight)
            
            HStack(alignment: .center) {
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "arrow.left")
                        .foregroundColor(.white)
                }
                Spacer()
                
                Button(action: {}) {
                    Image(systemName: "ellipsis")
                        .foregroundColor(.white)
                }
            }
            .padding(.horizontal, Spacing.xxl)
            .padding(.top, 62)
            
        }
        .overlay(alignment: .center) {
            VStack(spacing: Spacing.sm) {
                Button(action: { /* Play trailer */ }) {
                    Image(systemName: "play.circle.fill")
                        .resizable()
                        .frame(width: 45, height: 45)
                        .foregroundColor(.white)
                        .shadow(radius: 5)
                }
                Text("Play Trailer")
                    .font(.caption)
                    .foregroundColor(.white)
            }
        }
        .frame(maxHeight: 400)
    }
    
    /// A small circular icon button with a semi-transparent background.
    private struct CircleIcon: View {
        let system: String
        var body: some View {
            Image("Back")
                .foregroundColor(.white)
                .padding(10)
        }
    }
    
    /// The main content card holding all movie details.
    private var contentCard: some View {
        VStack(alignment: .leading) {
            titleSection
            ratingSection
            tagsSection
            infoSection
            descriptionSection
            castSection
        }
        .padding(.horizontal, Spacing.xxl)
        .padding(.top, Spacing.xxl)
        .padding(.bottom, 70)
    }
    
    // MARK: - Content Sections
    
    private var titleSection: some View {
        HStack(alignment: .top) {
            Text(viewModel.detail?.base.title ?? "Loading...")
                .font(.custom("Mulish-Bold", size: 20))
                .lineLimit(2)
            Spacer()
            Image(systemName: "bookmark")
                .foregroundColor(.gray)
        }
        .padding(.bottom, Spacing.sm)
    }
    
    private var ratingSection: some View {
        Group {
            if let score = viewModel.detail?.base.score {
                HStack(spacing: 2) {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                    Text("\(score, specifier: "%.1f")/10 IMDb")
                        .font(.custom("Mulish-Regular", size: Spacing.md))
                        .foregroundColor(.textSecondary)
                }
                .padding(.bottom, Spacing.lg)
            }
        }
    }
    
    private var tagsSection: some View {
        HStack(spacing: Spacing.sm) {
            ForEach(viewModel.detail?.base.genres ?? [], id: \.self) {
                GenreTag(text: $0)
            }
        }
        .padding(.bottom, Spacing.lg)
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
        .padding(.bottom, Spacing.xxl)
    }
    
    private var descriptionSection: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            SectionHeader("Description", isButtonVisible: false)
            Text(cleanedSynopsis(viewModel.detail?.synopsis ?? ""))
                .font(.custom("Mulish-Regular", size: Spacing.md))
                .foregroundStyle(Color.textSecondary)
                .lineLimit(nil)
        }
        .padding(.bottom, Spacing.xxl)
    }
    
    private var castSection: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            SectionHeader("Cast")
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 13) {
                    ForEach(viewModel.detail?.cast ?? [], id: \.id) { CastMemberView(person: $0) }
                }
            }
        }
    }
    
    // MARK: - Loading / Error Overlay
    
    /// An overlay that displays a loading indicator or an error message.
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
                        Text("Error: \(error)").font(.subheadline)
                    }
                        .padding()
                )
            }
        }
        // Animate the appearance/disappearance of the overlay
        .animation(.easeInOut(duration: 0.2), value: viewModel.isLoading || viewModel.error != nil)
    }
    
    // MARK: - Utils
    
    /// Formats a duration in minutes (e.g., 148) into "Xh Ym" (e.g., "2h 28m").
    private func formattedDuration(minutes: Int?) -> String {
        guard let minutes = minutes, minutes > 0 else { return "N/A" }
        let h = minutes / 60
        let m = minutes % 60
        return "\(h)h \(m)m"
    }
    
    /// Cleans a synopsis string by removing HTML tags and extra whitespace.
    private func cleanedSynopsis(_ synopsis: String?) -> String {
        guard let synopsis = synopsis else { return "" }
        
        // 1. Strip HTML tags like <br>, <i>
        let htmlStripped = synopsis.replacingOccurrences(
            of: "<[^>]+>",
            with: "",
            options: .regularExpression,
            range: nil
        )
        
        // 2. Replace newlines with a space
        let newlinesRemoved = htmlStripped.replacingOccurrences(
            of: "\n",
            with: " ",
            options: .literal,
            range: nil
        )
        
        // 3. Condense multiple spaces into one
        let multipleSpacesRemoved = newlinesRemoved.replacingOccurrences(
            of: " +",
            with: " ",
            options: .regularExpression,
            range: nil
        )
        
        // 4. Trim leading/trailing whitespace
        return multipleSpacesRemoved.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
