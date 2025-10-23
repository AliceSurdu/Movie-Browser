//
//  HomeViewModel.swift
//  Movie Browser
//
//  Created by Alice Surdu on 18.10.2025.
//

import Foundation
import Combine

@MainActor
final class HomeViewModel: ObservableObject {
  @Published var nowShowing: [Movie] = []
  @Published var popular: [Movie] = []
  @Published var isLoading = false
  @Published var error: String?

  private let api: MovieAPIServiceType
  init(api: MovieAPIServiceType) { self.api = api }

  func load() {
    guard !isLoading else { return }
    isLoading = true; error = nil
    Task {
      do {
        async let a = api.getNowShowing(input: .init(page: 1, perPage: 10))
        async let b = api.getPopular(input: .init(page: 1, perPage: 10))
        let (now, pop) = try await (a.movies, b.movies)
        self.nowShowing = now
        self.popular = pop
      } catch { self.error = error.localizedDescription }
      isLoading = false
    }
  }
}
