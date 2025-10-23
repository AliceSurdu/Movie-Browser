//
//  AppRouter.swift
//  Movie Browser
//
//  Created by Alice Surdu on 18.10.2025.
//

import SwiftUI
import Foundation

// Presupunem că MovieAPIServiceType, DefaultGraphQLClient și GraphQLClient sunt definite
// și că ai acces la ele.

struct AppRouter: View {
    // Păstrăm gql ca private, dar movieAPI trebuie să fie accesibil
    // pentru a fi pasat către MovieDetailView
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
                // Când o entitate de tip Movie este pasată, navighează la MovieDetailView
                .navigationDestination(for: Movie.self) { m in
                    // REPARAT: Folosim id-ul filmului (m.id) și instanța movieAPI
                    MovieDetailView(viewModel:
                        .init(
                            id: m.id,
                            api: self.movieAPI
                        )
                    )
                }
        }
    }
}
