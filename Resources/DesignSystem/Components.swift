//
//  Components.swift
//  Movie Browser
//
//  Created by Alice Surdu on 18.10.2025.
//

import SwiftUI

// MARK: - Genre Tag

struct GenreTag: View {
    let text: String
    
    var body: some View {
        Text(text.uppercased())
            .font(.custom("Mulish-Regular", size: Spacing.sm))
            .padding(.horizontal, Spacing.md)
            .padding(.vertical, Spacing.xs)
            .background(Color.chipBG)
            .foregroundColor(Color.chipText)
            .cornerRadius(100)
    }
}

// MARK: - Section Header

struct SectionHeader: View {
    let title: String
    var isButtonVisible: Bool
    
    init(_ title: String, isButtonVisible: Bool = true) {
        self.title = title
        self.isButtonVisible = isButtonVisible
    }
    
    var body: some View {
        HStack {
            Text(title)
                .font(.custom("Merriweather UltraBold", size: Spacing.lg))
                .foregroundColor(Color.brand)
            
            Spacer()
            if isButtonVisible {
                Button("See more") {}
                    .font(.custom("Mulish-Regular", size: 10))
                    .foregroundColor(Color.textSecondary)
                    .padding(.horizontal, 10)
                    .padding(.vertical, Spacing.sm)
                    .background(
                        Capsule()
                            .fill(Color.white)
                    )
                    .overlay(
                        Capsule()
                            .stroke(Color("TextSecondary"), lineWidth: 1)
                    )
                    .buttonStyle(.plain)
            }
        }
    }
}

// MARK: - Async Image

struct AsyncRemoteImage: View {
    let url: URL?
    
    var body: some View {
        AsyncImage(url: url) { phase in
            switch phase {
            case .success(let image):
                // Image loaded successfully
                image.resizable().scaledToFill()
            case .failure(_):
                // Failed to load, show placeholder
                Color.gray.opacity(0.2)
            case .empty:
                // Loading, show subtle placeholder
                Color.gray.opacity(0.1)
            @unknown default:
                // Fallback for future cases
                Color.gray.opacity(0.2)
            }
        }
    }
}

// MARK: - Now Showing Movie Card

/// A view representing a movie card for the "Now Showing" horizontal list.
struct NowShowingCard: View {
    let movie: Movie
    
    /// A callback closure to handle tap gestures for navigation.
    var onTap: () -> Void
    
    private let cardWidth: CGFloat = 140
    private let cardHeight: CGFloat = 212
    private let cardRadius: CGFloat = 5
    
    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            // Poster Image
            AsyncRemoteImage(url: movie.posterURL)
                .frame(width: cardWidth, height: cardHeight)
                .clipShape(RoundedRectangle(cornerRadius: cardRadius, style: .continuous))
                .clipped()
                .shadow(color: .black.opacity(0.08), radius: 6, y: Spacing.xs)
            
            // Movie Title
            Text(movie.title)
                .font(.custom("Mulish-Bold", size: Spacing.mdPlus))
                .lineLimit(2)
                .truncationMode(.tail)
            
            // Movie Rating
            if let score = movie.score {
                HStack(spacing: Spacing.xs) {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                        .font(.caption)
                    Text("\(score, specifier: "%.1f")/10 IMDb")
                        .font(.custom("Mulish-Regular", size: Spacing.md))
                        .foregroundColor(Color.textSecondary)
                }
            }
        }
        .frame(width: cardWidth)
        .onTapGesture(perform: onTap)
    }
}

// MARK: - Popular Movie Card

/// A view representing a movie row for the "Popular" vertical list.
/// This view displays a small poster on the left and movie details
/// (title, rating, genres, duration) on the right.
struct PopularCard: View {
    
    /// The movie data model to display.
    let movie: Movie
    
    /// A callback closure to handle tap gestures for navigation.
    var onTap: () -> Void
    
    var body: some View {
        HStack(alignment: .top, spacing: Spacing.lg) {
            AsyncRemoteImage(url: movie.posterURL)
                .frame(width: 80, height: 120)
                .cornerRadius(5)
                .clipped()
            
            VStack(alignment: .leading, spacing: Spacing.sm) {
                Text(movie.title)
                    .font(.custom("Mulish-Bold", size: Spacing.mdPlus))
                    .lineLimit(3) // Allow up to 3 lines for longer titles
                
                // Rating IMDb
                if let score = movie.score {
                    HStack(spacing: Spacing.xs) {
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                        Text("\(score, specifier: "%.1f")/10 IMDb")
                            .font(.custom("Mulish-Regular", size: Spacing.md))
                            .foregroundColor(Color.textSecondary)
                    }
                }
                
                // Genres (show up to 3)
                HStack {
                    // We use .prefix(3) to avoid overflowing the UI
                    ForEach(movie.genres.prefix(3), id: \.self) { genre in
                        // Note: This relies on the GenreTag.swift component
                        GenreTag(text: genre)
                    }
                }
                
                // Duration
                HStack(spacing: Spacing.xs) {
                    Image(systemName: "clock")
                        .foregroundColor(.black)
                    Text(formattedDuration(minutes: movie.duration))
                        .font(.custom("Mulish-Regular", size: Spacing.md))
                        .foregroundColor(.black)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .onTapGesture(perform: onTap)
    }
}
    
    // MARK: - Detail Item
    
    struct DetailItem: View {
        let title: String
        let value: String
        var body: some View {
            VStack(alignment: .leading, spacing: Spacing.xs) {
                Text(title).font(.custom("Mulish-Regular", size: Spacing.md)).foregroundStyle(Color(.textSecondary))
                Text(value).font(.custom("Mulish-SemiBold", size: Spacing.md)).foregroundStyle(Color(.black))
            }
        }
    }

    // MARK: - Cast Member View
    
    struct CastMemberView: View {
        let person: Person
        var body: some View {
            VStack(spacing: Spacing.xs) {
                AsyncRemoteImage(url: person.imageURL)
                    .frame(width: 72, height: 72)
                    .clipShape(RoundedRectangle(cornerRadius: 5))
                Text(person.name)
                    .font(.custom("Mulish-Regular", size: Spacing.md))
                    .multilineTextAlignment(.center)
            }
            .frame(width: 72)
        }
    }
    
    // MARK: - Private Helpers
    
    private func formattedDuration(minutes: Int?) -> String {
        guard let minutes = minutes, minutes > 0 else { return "N/A" }
        
        let hours = minutes / 60
        let remainingMinutes = minutes % 60
        
        return "\(hours)h \(remainingMinutes)min"
    }
