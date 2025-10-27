//
//  AppRouter.swift
//  Movie Browser
//
//  Created by Alice Surdu on 18.10.2025.
//

import SwiftUI

/// Enum to define the main tabs of the application.
enum Tab {
    case home       // The main movie browsing tab
    case bookmark   // The saved/bookmarked movies tab
    case profile    // The user profile or tickets tab
}

/// The root view of the application.
/// `AppRouter` is responsible for setting up the main `TabView` and the
/// primary `NavigationStack` for the "Home" flow.
struct AppRouter: View {
    
    /// The navigation path for the "Home" tab, holding the stack of movies.
    @State private var path: [Movie] = []
    
    /// The currently selected tab.
    @State private var selectedTab: Tab = .home
    
    // MARK: - Dependencies
    
    /// The shared GraphQL client instance.
    private var gql: GraphQLClient = DefaultGraphQLClient()
    
    /// The API service responsible for fetching movie data.
    private let movieAPI: MovieAPIServiceType
    
    // MARK: - Initializer
    
    init() {
        let client = DefaultGraphQLClient()
        self.gql = client
        self.movieAPI = MovieAPIService(gql: client)
    }
    
    // MARK: - Body
    
    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack(path: $path) {
                HomeView(viewModel: .init(api: movieAPI), path: $path)
                    .navigationDestination(for: Movie.self) { movie in
                        MovieDetailView(viewModel: .init(id: movie.id, api: self.movieAPI))
                    }
            }
            .tabItem {
                Image(systemName: "popcorn")
            }
            .tag(Tab.home)
            
            Text("Tickets View (Placeholder)")
                .tabItem {
                    Image(systemName: "ticket")
                }
                .tag(Tab.profile)
            
            Text("Saved Movies View (Placeholder)")
                .tabItem {
                    Image(systemName: "bookmark")
                }
                .tag(Tab.bookmark)
        }
        .tint(.brand)
    }
}
