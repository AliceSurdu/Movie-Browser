//
//  AppRouter.swift
//  Movie Browser
//
//  Created by Alice Surdu on 18.10.2025.
//

import SwiftUI

// Structură auxiliară pentru Tag-uri (pentru TabView)
enum Tab {
    case home, bookmark, profile
}

// NOTE: Presupunem că MovieAPIServiceType, DefaultGraphQLClient și GraphQLClient sunt definite

struct AppRouter: View {
    @State private var path: [Movie] = []
    @State private var selectedTab: Tab = .home

    private var gql: GraphQLClient = DefaultGraphQLClient()
    private let movieAPI: MovieAPIServiceType

    init() {
        let client = DefaultGraphQLClient()
        self.gql = client
        self.movieAPI = MovieAPIService(gql: client)
    }

    var body: some View {
        // TabView este View-ul rădăcină
        TabView(selection: $selectedTab) {
            
            // PRIMUL TAB: Home (Încapsulat în NavigationStack)
            NavigationStack(path: $path) {
                // HomeView primește path-ul ca binding
                HomeView(viewModel: .init(api: movieAPI), path: $path)
                    .navigationDestination(for: Movie.self) { m in
                        MovieDetailView(viewModel: .init(id: m.id, api: self.movieAPI))
                    }
            }
            .tabItem { // Iconița pentru tab-ul Home
                // Folosesc o iconiță care imită designul cerut (cu buline)
                Image("movieRoll")
            }
            .tag(Tab.home)
            
            Text("")
                .tabItem {
                    Image(systemName: "ticket")
                }
                .tag(Tab.profile)

            // AL DOILEA TAB: Bookmark (Placeholder)
            Text("Saved Movies")
                .tabItem {
                    Image("saved")
                }
                .tag(Tab.bookmark)
            
        }
        .tint(.brand) // Culoarea activă a iconițelor
    }
}
