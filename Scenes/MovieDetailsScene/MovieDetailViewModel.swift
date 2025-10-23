//
//  MovieDetailViewModel.swift
//  Movie Browser
//
//  Created by Alice Surdu on 18.10.2025.
//

import Foundation
import Combine

@MainActor
final class MovieDetailViewModel: ObservableObject {
  @Published var detail: MovieDetail?
  @Published var isLoading = false
  @Published var error: String?

  private let id: Int
  private let api: MovieAPIServiceType

  init(id: Int, api: MovieAPIServiceType) {
    self.id = id
    self.api = api
  }

  func load() {
    guard !isLoading else { return }
    isLoading = true
    error = nil

    Task {
      do {
        let output = try await api.getMovieDetail(input: .init(id: id))
        self.detail = output.detail
      } catch let err {
        self.error = err.localizedDescription
      }
      self.isLoading = false
    }
  }
}
