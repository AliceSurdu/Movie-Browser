//
//  APIError.swift
//  Movie Browser
//
//  Created by Alice Surdu on 18.10.2025.
//

import Foundation

enum APIError: Error, LocalizedError {
  case invalidURL
  case invalidResponse
  case status(Int, Data?)
  case transport(Error)
  case decoding(Error)

  var errorDescription: String? {
    switch self {
      case .invalidURL: "Invalid URL"
      case .invalidResponse: "Invalid response"
      case .status(let c, _): "HTTP \(c)"
      case .transport(let e): "Transport error: \(e.localizedDescription)"
      case .decoding(let e): "Decoding error: \(e.localizedDescription)"
    }
  }
}
