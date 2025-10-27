//
//  MovieAPIServiceType.swift
//  Movie Browser
//
//  Created by Alice Surdu on 18.10.2025.
//

import Foundation

import Foundation

/// Defines the contract for the movie API service.
///
/// This protocol abstracts the data fetching logic, allowing for different
/// implementations (e.g., a live API service, a mock service for testing).
protocol MovieAPIServiceType {
    
    /// Fetches the list of "Now Showing" (Trending) movies.
    func getNowShowing(input: GetNowShowingInput) async throws -> MoviesListOutput
    
    /// Fetches the list of "Popular" (Top Scored) movies.
    func getPopular(input: GetPopularInput) async throws -> MoviesListOutput
    
    /// Fetches the detailed information for a single movie.
    func getMovieDetail(input: GetMovieDetailInput) async throws -> MovieDetailOutput
}
