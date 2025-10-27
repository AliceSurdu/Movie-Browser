//
//  GraphQLClient.swift
//  Movie Browser
//
//  Created by Alice Surdu on 18.10.2025.
//

import Foundation

// MARK: - GraphQL Protocol
/// Defines the contract for a client that can execute GraphQL queries.
protocol GraphQLClient {
    /// Performs a GraphQL query.
    /// - Parameters:
    ///   - query: The GraphQL query string (e.g., from `Queries.swift`).
    ///   - variables: A dictionary of variables to be passed with the query.
    /// - Returns: A decoded object of type `Out`.
    /// - Throws: An `APIError` if the request fails, times out, or decoding fails.
    func query<Out: Decodable>(_ query: String, variables: [String: Any]?) async throws -> Out
}

// MARK: - Default GraphQL Client
/// The default implementation of `GraphQLClient` that communicates with the AniList public API.
final class DefaultGraphQLClient: GraphQLClient {
    
    // The single public endpoint for the AniList GraphQL API.
    private let url = URL(string: "https://graphql.anilist.co")!
    
    // A shared URLSession for all network requests.
    private let session: URLSession
    
    // A shared JSONDecoder for parsing responses.
    private let decoder: JSONDecoder
    
    /// The standard GraphQL response envelope. The actual data is nested inside a "data" key.
    private struct GraphQLEnvelope<DataType: Decodable>: Decodable {
        let data: DataType
    }
    
    init(session: URLSession = .shared, decoder: JSONDecoder = JSONDecoder()) {
        self.session = session
        self.decoder = decoder
    }
    
    func query<Out: Decodable>(_ query: String, variables: [String: Any]? = nil) async throws -> Out {
        
        // 1. Configure the URLRequest
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.httpBody = try JSONSerialization.data(withJSONObject: [
            "query": query,
            "variables": variables ?? [:]
        ])
        
        // 2. Perform the network request
        let (data, resp): (Data, URLResponse)
        do {
            (data, resp) = try await session.data(for: req)
        } catch {
            // Handle underlying transport errors (e.g., no internet)
            throw APIError.transport(error)
        }
        
        // 3. Validate the HTTP response
        guard let http = resp as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        
        guard (200..<300).contains(http.statusCode) else {
            // A non-2xx status is an API error
            throw APIError.status(http.statusCode, data)
        }
        
        // 4. Decode the response
        do {
            // Decode the outer envelope
            let envelope = try decoder.decode(GraphQLEnvelope<Out>.self, from: data)
            // Return the nested data
            return envelope.data
        } catch {
            // Handle JSON parsing errors
            throw APIError.decoding(error)
        }
    }
}
