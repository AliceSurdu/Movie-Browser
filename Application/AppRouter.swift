//
//  AppRouter.swift
//  Movie Browser
//
//  Created by Alice Surdu on 18.10.2025.
//

import SwiftUI
import Foundation

struct AppRouter: View {
    private var gql: GraphQLClient = DefaultGraphQLClient()
  private let movieAPI: MovieAPIServiceType

  init() {
    let client = DefaultGraphQLClient()
    self.gql = client
    self.movieAPI = MovieAPIService(gql: client)
  }

  var body: some View {
    NavigationStack {
      HomeView(viewModel: .init(api: movieAPI))
        .navigationDestination(for: Movie.self) { m in
          MovieDetailView(movie: m, api: movieAPI)
        }
    }
  }
}
