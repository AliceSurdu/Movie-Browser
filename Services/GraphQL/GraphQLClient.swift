//
//  GraphQLClient.swift
//  Movie Browser
//
//  Created by Alice Surdu on 18.10.2025.
//

import Foundation

// Envelope-ul răspunsului GraphQL (mutat la nivel de fișier, nu în funcție)
private struct GraphQLEnvelope<DataType: Decodable>: Decodable {
  let data: DataType?
}

protocol GraphQLClient {
  func query<Out: Decodable>(_ query: String, variables: [String: Any]?) async throws -> Out
}

final class DefaultGraphQLClient: GraphQLClient {
  // AniList public endpoint
  private let url = URL(string: "https://graphql.anilist.co")!
  private let session: URLSession = .shared

  func query<Out: Decodable>(_ query: String,
                             variables: [String: Any]? = nil) async throws -> Out {
    var req = URLRequest(url: url)
    req.httpMethod = "POST"
    req.setValue("application/json", forHTTPHeaderField: "Content-Type")
    req.httpBody = try JSONSerialization.data(withJSONObject: [
      "query": query,
      "variables": variables ?? [:]
    ])

    do {
      let (data, resp) = try await session.data(for: req)
      guard let http = resp as? HTTPURLResponse else { throw APIError.invalidResponse }
      guard 200..<300 ~= http.statusCode else { throw APIError.status(http.statusCode, data) }

      // Decodăm envelope-ul generic top-level (fără shadowing)
      do {
        let decoded = try JSONDecoder().decode(GraphQLEnvelope<Out>.self, from: data)
        if let d = decoded.data { return d }
        throw APIError.invalidResponse
      } catch {
        throw APIError.decoding(error)
      }
    } catch let e as APIError {
      throw e
    } catch {
      throw APIError.transport(error)
    }
  }
}
