//
//  APIError.swift
//  Movie Browser
//
//  Created by Alice Surdu on 18.10.2025.
//

import Foundation

/// Represents all possible errors that can occur within the API layer.
///
/// Conforming to `LocalizedError` provides user-friendly error messages.
enum APIError: Error, LocalizedError {
    /// The URL provided was malformed.
    case invalidURL
    
    /// The server's response was not a valid HTTP response.
    case invalidResponse
    
    /// The server returned a non-2xx HTTP status code (e.g., 404, 500).
    case status(Int, Data?)
    
    /// An underlying network error occurred (e.g., no internet connection).
    case transport(Error)
    
    /// The client failed to decode the JSON response.
    case decoding(Error)

    /// A user-friendly description of the error.
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            "Invalid URL"
        case .invalidResponse:
            "Invalid response"
        case .status(let code, _):
            "Server returned status \(code)"
        case .transport(let e):
            "Transport error: \(e.localizedDescription)"
        case .decoding(let e):
            "Decoding error: \(e.localizedDescription)"
        }
    }
}
