//
//  MovieAPIService.swift
//  Movie Browser
//
//  Created by Alice Surdu on 18.10.2025.
//

import Foundation

import Foundation

/// The main service responsible for fetching movie data from the GraphQL API.
///
/// This class conforms to `MovieAPIServiceType` and acts as an abstraction
/// layer between the ViewModels and the raw GraphQL client.
final class MovieAPIService: MovieAPIServiceType {
    
    /// The underlying GraphQL client used to perform queries.
    private let gql: GraphQLClient

    init(gql: GraphQLClient) {
        self.gql = gql
    }

    /// Fetches the list of "Now Showing" (Trending) movies.
    func getNowShowing(input: GetNowShowingInput) async throws -> MoviesListOutput {
        // Perform the query using the "trending" query string
        let dto: PageDTO<MovieItemDTO> = try await gql.query(
            Queries.trending,
            variables: ["page": input.page, "perPage": input.perPage]
        )
        
        // Map the DTOs (Data Transfer Objects) to the domain models
        return .init(movies: dto.Page.media.map(MovieMapper.mapItem))
    }

    /// Fetches the list of "Popular" (Top Scored) movies.
    func getPopular(input: GetPopularInput) async throws -> MoviesListOutput {
        // Perform the query using the "popular" query string
        let dto: PageDTO<MovieItemDTO> = try await gql.query(
            Queries.popular,
            variables: ["page": input.page, "perPage": input.perPage]
        )
        
        // Map the DTOs to the domain models
        return .init(movies: dto.Page.media.map(MovieMapper.mapItem))
    }

    /// Fetches the detailed information for a single movie by its ID.
    func getMovieDetail(input: GetMovieDetailInput) async throws -> MovieDetailOutput {
        // Perform the query using the "detail" query string
        let dto: DetailDTO = try await gql.query(
            Queries.detail,
            variables: ["id": input.id]
        )
        
        // Map the DTO to the domain model
        return .init(detail: MovieMapper.mapDetail(dto.Media))
    }
}
