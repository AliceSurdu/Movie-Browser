//
//  MovieMapper.swift
//  Movie Browser
//
//  Created by Alice Surdu on 27.10.2025.
//

import Foundation

/// A utility namespace for mapping DTOs (Data Transfer Objects) to domain models.
///
/// This static enum isolates the transformation logic from the API service
/// and the data models themselves.
enum MovieMapper {

    // MARK: - Private Helpers
    
    /// Safely unwraps the best available title from the DTO.
    private static func title(_ t: MovieItemDTO.Title) -> String {
        t.english ?? t.romaji ?? t.native ?? "Untitled"
    }

    /// Safely unwraps the best available poster image URL from the DTO.
    private static func poster(_ c: MovieItemDTO.Cover) -> URL? {
        URL(string: c.extraLarge ?? c.large ?? "")
    }

    // MARK: - Public Mappers
    
    /// Maps a `MovieItemDTO` (from a list) to a `Movie` domain model.
    static func mapItem(_ dto: MovieItemDTO) -> Movie {
        .init(
            id: dto.id,
            title: title(dto.title),
            // API returns score as 0-100, we convert to 0-10
            score: dto.averageScore.map { Double($0) / 10.0 },
            duration: dto.duration,
            genres: dto.genres ?? [],
            posterURL: poster(dto.coverImage),
            bannerURL: dto.bannerImage.flatMap(URL.init(string:))
        )
    }

    /// Maps a `DetailDTO.Media` (from the detail endpoint) to a `MovieDetail` domain model.
    static func mapDetail(_ m: DetailDTO.Media) -> MovieDetail {
        
        // 1. Create the base `Movie` object
        let base = Movie(
            id: m.id,
            title: title(m.title),
            score: m.averageScore.map { Double($0) / 10.0 },
            duration: m.duration,
            genres: m.genres ?? [],
            posterURL: poster(m.coverImage),
            bannerURL: m.bannerImage.flatMap(URL.init(string:))
        )
        
        // 2. Map the cast (characters)
        let cast: [Person] = m.characters?.edges.map { edge in
            .init(
                id: edge.node.id,
                name: edge.node.name.full ?? "Unknown",
                imageURL: edge.node.image?.large.flatMap(URL.init(string:))
            )
        } ?? []
        
        // 3. Assemble the final `MovieDetail` object
        return .init(
            base: base,
            synopsis: m.description ?? "",
            country: m.countryOfOrigin,
            status: m.status,
            title: title(m.title),
            averageScore: m.averageScore.map { Double($0) / 10.0 },
            cast: cast
        )
    }
}
