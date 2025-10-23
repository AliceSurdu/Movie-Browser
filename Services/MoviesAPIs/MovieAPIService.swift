//
//  MovieAPIService.swift
//  Movie Browser
//
//  Created by Alice Surdu on 18.10.2025.
//

import Foundation

// MARK: - DTOs (private de Service)
private struct PageDTO<T: Decodable>: Decodable {
  let Page: Inner
  struct Inner: Decodable { let media: [T] }
}

private struct MovieItemDTO: Decodable {
  let id: Int
  let title: Title
  let averageScore: Int?
  let duration: Int?
  let genres: [String]?
  let coverImage: Cover
  let bannerImage: String?
  struct Title: Decodable { let english: String?; let romaji: String?; let native: String? }
  struct Cover: Decodable { let extraLarge: String?; let large: String? }
}

private struct DetailDTO: Decodable {
  let Media: Media
  struct Media: Decodable {
    let id: Int
    let title: MovieItemDTO.Title
    let averageScore: Int?
    let duration: Int?
    let genres: [String]?
    let bannerImage: String?
    let coverImage: MovieItemDTO.Cover
    let description: String?
    let countryOfOrigin: String?
    let status: String?
    let characters: Characters?
  }
  struct Characters: Decodable {
    let edges: [Edge]
    struct Edge: Decodable {
      let node: Node
      struct Node: Decodable {
        let id: Int
        let name: Name
        let image: Image?
        struct Name: Decodable { let full: String? }
        struct Image: Decodable { let large: String? }
      }
    }
  }
}

// MARK: - Mapper
private enum MovieMapper {
  static func title(_ t: MovieItemDTO.Title) -> String {
    t.english ?? t.romaji ?? t.native ?? "Untitled"
  }

  static func poster(_ c: MovieItemDTO.Cover) -> URL? {
    URL(string: c.extraLarge ?? c.large ?? "")
  }

  static func mapItem(_ dto: MovieItemDTO) -> Movie {
    .init(
      id: dto.id,
      title: title(dto.title),
      score: dto.averageScore.map { Double($0)/10.0 },
      duration: dto.duration,
      genres: dto.genres ?? [],
      posterURL: poster(dto.coverImage),
      bannerURL: dto.bannerImage.flatMap(URL.init(string:))
    )
  }

  static func mapDetail(_ m: DetailDTO.Media) -> MovieDetail {
    let base = Movie(
      id: m.id,
      title: title(m.title),
      score: m.averageScore.map { Double($0)/10.0 },
      duration: m.duration,
      genres: m.genres ?? [],
      posterURL: poster(m.coverImage),
      bannerURL: m.bannerImage.flatMap(URL.init(string:))
    )
    let cast: [Person] = m.characters?.edges.map {
      .init(id: $0.node.id,
            name: $0.node.name.full ?? "",
            imageURL: $0.node.image?.large.flatMap(URL.init(string:)))
    } ?? []
    return .init(base: base,
                 synopsis: m.description ?? "",
                 country: m.countryOfOrigin,
                 status: m.status,
                 title: title(m.title),
                 averageScore: m.averageScore.map { Double($0)/10.0 },
                 cast: cast)
  }
}

// MARK: - Service
final class MovieAPIService: MovieAPIServiceType {
  private let gql: GraphQLClient
  init(gql: GraphQLClient) { self.gql = gql }

  func getNowShowing(input: GetNowShowingInput) async throws -> MoviesListOutput {
    let dto: PageDTO<MovieItemDTO> = try await gql.query(
      Queries.trending, variables: ["page": input.page, "perPage": input.perPage]
    )
    return .init(movies: dto.Page.media.map(MovieMapper.mapItem))
  }

  func getPopular(input: GetPopularInput) async throws -> MoviesListOutput {
    let dto: PageDTO<MovieItemDTO> = try await gql.query(
      Queries.popular, variables: ["page": input.page, "perPage": input.perPage]
    )
    return .init(movies: dto.Page.media.map(MovieMapper.mapItem))
  }

  func getMovieDetail(input: GetMovieDetailInput) async throws -> MovieDetailOutput {
    let dto: DetailDTO = try await gql.query(Queries.detail, variables: ["id": input.id])
    return .init(detail: MovieMapper.mapDetail(dto.Media))
  }
}
