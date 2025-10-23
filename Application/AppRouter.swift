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

// AppRouter.swift (Cod Corectat)

struct AppRouter: View {
    // 1. Declari stiva de navigare (path) ca @State.
    // Tipul de date trebuie să fie explicit: Array de tipurile care pot fi navigate
    @State private var path: [Movie] = []
    
    // ... (restul variabilelor și init rămân la fel) ...
    private var gql: GraphQLClient = DefaultGraphQLClient()
    private let movieAPI: MovieAPIServiceType

    init() {
        self.gql = DefaultGraphQLClient()
        self.movieAPI = MovieAPIService(gql: DefaultGraphQLClient())
    }

    var body: some View {
        // 2. NavigationStack folosește path-ul ca binding
        NavigationStack(path: $path) {
            // 3. Pasezi path-ul ca binding către HomeView
            HomeView(viewModel: .init(api: movieAPI), path: $path)
                .navigationDestination(for: Movie.self) { m in
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
